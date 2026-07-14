// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../common/consts.dart';
import '../../../common/types.dart';
import '../../../common/utils.dart';
import '../../../logging/helper.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_daily_goal.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
import '../../../models/habit_freq.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_reminder.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/app_sync.dart';
import '../../../providers/workflow/group_manager.dart';
import '../../../providers/workflow/habits_manager.dart';
import '../../../storage/db/handlers/habit.dart';
import '../../../utils/app_clock.dart';

class HabitFormViewModel extends ChangeNotifier
    with PinnedAppbarMixin
    implements ProviderMounted, AppEventLoaded {
  // inside status
  bool _mounted = true;
  late HabitFormAccess _access;
  GroupManager? _groupManager;
  GroupCollection? _groupCollection;

  StreamSubscription<AppEvent>? _groupEventSubscription;
  StreamSubscription<String>? _startSyncSub;
  int _groupVersion = 0;

  final HabitForm _form;

  HabitFormViewModel({HabitForm? initForm})
    : _form = initForm ?? HabitForm.empty();

  @override
  void dispose() {
    if (!_mounted) return;
    _groupEventSubscription?.cancel();
    _startSyncSub?.cancel();
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  void attachAccess(HabitFormAccess newAccess) {
    _access = newAccess;
  }

  void attachGroupManager(GroupManager gm) {
    _groupManager = gm;
  }

  Future<void> _reloadGroups() async {
    final cells = await _groupManager?.loadAllActiveGroups() ?? [];
    _groupCollection = GroupCollection.fromDBQueryResult(cells);
  }

  /// Whether initial group loading has completed.
  ///
  /// Returns `false` before [ensureGroupsLoaded] is called (typically during
  /// the provider `post` hook), allowing callers to defer group-dependent work.
  bool get hasLoadedGroups => _groupCollection != null;

  /// Ensures groups are loaded exactly once; no-op if already loaded.
  ///
  /// Called from the provider `post` hook. Subsequent reloads are triggered
  /// by events via [_reloadGroups] directly.
  Future<void> ensureGroupsLoaded() async {
    if (_groupCollection != null) return;
    await _reloadGroups();
    if (!_mounted) return;
    _groupVersion++;
    notifyListeners();
  }

  List<HabitGroupData> get groups => _groupCollection?.toList() ?? [];

  /// Combined (version, groupId) for the UI to watch via [Selector].
  ///
  /// The version side-carries a monotonic counter that changes each time the
  /// group list is reloaded, so [Selector] can detect list updates without
  /// deep-comparing [groups]. The [groupId] side tracks the currently selected
  /// group so the picker tile reflects selection changes.
  ({int version, String? groupId}) get groupState =>
      (version: _groupVersion, groupId: _form.groupId);

  void attachSyncWorkflow(AppSyncWorkflowAccess workflow) {
    _startSyncSub?.cancel();
    _startSyncSub = workflow.startSyncEvents.listen((_) async {
      await _reloadGroups();
      if (!_mounted) return;
      _groupVersion++;
      notifyListeners();
    });
  }

  @override
  void updateAppEvent(AppEventBus newAppEvent) {
    _groupEventSubscription?.cancel();
    _groupEventSubscription = newAppEvent.on<GroupChangedEvent>().listen((
      _,
    ) async {
      if (!_mounted) return;
      await _reloadGroups();
      _groupVersion++;
      notifyListeners();
    });
  }

  Future<bool> requestReminderPermission() async =>
      (await _access.requestReminderPermission()) ?? true;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  String get name => _form.name;
  set name(String value) {
    final oldValue = _form.name;
    _form.name = value;
    appLog.value.debug("HabitForm.name", beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  HabitType get habitType => _form.type;
  set habitType(HabitType newHabitType) {
    appLog.value.debug(
      "$runtimeType.habitType",
      beforeVal: _form.type,
      afterVal: newHabitType,
    );
    _form.type = newHabitType;
    _form.dailyGoal = _form.dailyGoal.transform(type: _form.type);
    notifyListeners();
  }

  HabitColor get color => _form.color;
  set color(HabitColor newColor) {
    appLog.value.debug(
      "$runtimeType.color",
      beforeVal: _form.color,
      afterVal: newColor,
    );
    _form.color = newColor;
    notifyListeners();
  }

  bool get isDailyGoalValueValid => _form.dailyGoal.isGoalValid;

  HabitDailyGoalContainer get dailyGoal => _form.dailyGoal;

  num get dailyGoalValue => _form.dailyGoal.dailyGoal;
  set dailyGoalValue(num newDailyGoal) {
    appLog.value.debug(
      "$runtimeType.dailyGoal",
      beforeVal: _form.dailyGoal.dailyGoal,
      afterVal: newDailyGoal,
      ex: [_form.dailyGoal.type],
    );
    _form.dailyGoal.dailyGoal = newDailyGoal;
    notifyListeners();
  }

  String get dailyGoalUnit => _form.dailyGoal.dailyGoalUnit;
  set dailyGoalUnit(String newDailyGoalUnit) {
    appLog.value.debug(
      "$runtimeType.dailyGoalUnit",
      beforeVal: _form.dailyGoal.dailyGoalUnit,
      afterVal: newDailyGoalUnit,
      ex: [_form.dailyGoal.type],
    );
    _form.dailyGoal.dailyGoalUnit = newDailyGoalUnit;
    notifyListeners();
  }

  num? get dailyGoalExtra => _form.dailyGoal.dailyGoalExtra;
  set dailyGoalExtra(num? newDailyGoalExtra) {
    appLog.value.debug(
      "$runtimeType.dailyGoalExtra",
      beforeVal: _form.dailyGoal.dailyGoalExtra,
      afterVal: newDailyGoalExtra,
      ex: [_form.dailyGoal.type],
    );
    _form.dailyGoal.dailyGoalExtra = newDailyGoalExtra;
    notifyListeners();
  }

  bool get isDailyGoalExtraValueValid {
    final dailyGoalExtra = this.dailyGoalExtra;
    return dailyGoalExtra == null || dailyGoalExtra >= dailyGoalValue;
  }

  HabitFrequency get frequency => _form.frequency;
  set frequency(HabitFrequency newHabitFrequency) {
    appLog.value.debug(
      "$runtimeType.frequency",
      beforeVal: _form.frequency,
      afterVal: newHabitFrequency,
    );
    _form.frequency = newHabitFrequency;
    notifyListeners();
  }

  HabitStartDate get startDate => _form.startDate;
  set startDate(HabitStartDate newDate) {
    appLog.value.debug(
      "$runtimeType.startDate",
      beforeVal: _form.startDate,
      afterVal: newDate,
    );
    _form.startDate = newDate;
    notifyListeners();
  }

  int get targetDays => _form.targetDays;
  set targetDays(int newTargetDays) {
    appLog.value.debug(
      "$runtimeType.targetDays",
      beforeVal: _form.targetDays,
      afterVal: newTargetDays,
    );
    _form.targetDays = newTargetDays;
    notifyListeners();
  }

  String get desc => _form.desc ?? "";
  set desc(String newDesc) {
    appLog.value.debug(
      "$runtimeType.desc",
      beforeVal: _form.desc,
      afterVal: newDesc,
    );
    _form.desc = newDesc;
    notifyListeners();
  }

  HabitReminder? get reminder => _form.reminder;
  set reminder(HabitReminder? newReminder) {
    appLog.value.debug(
      "$runtimeType.reminder",
      beforeVal: _form.reminder,
      afterVal: newReminder,
    );
    _form.reminder = newReminder;
    notifyListeners();
  }

  String? get reminderQuest => _form.reminderQuest;
  set reminderQuest(String? newQuest) {
    appLog.value.debug(
      "$runtimeType.reminderQuest",
      beforeVal: _form.reminderQuest,
      afterVal: newQuest,
    );
    _form.reminderQuest = newQuest;
    notifyListeners();
  }

  String? get groupId => _form.groupId;
  set groupId(String? newGroupId) {
    appLog.value.debug(
      "$runtimeType.groupId",
      beforeVal: _form.groupId,
      afterVal: newGroupId,
    );
    _form.groupId = newGroupId;
    notifyListeners();
  }

  HabitUUID? get uuid => _form.editParams?.uuid;

  DateTime? get createT => _form.editParams?.createT;

  DateTime? get modifyT => _form.editParams?.modifyT;

  HabitDisplayEditMode get editMode => _form.editMode;

  bool canSaveHabit() {
    return name.isNotEmpty &&
        isDailyGoalValueValid &&
        isDailyGoalExtraValueValid;
  }

  bool allowZeroDailyGoal() {
    switch (habitType) {
      case HabitType.unknown:
      case HabitType.normal:
        return false;
      case HabitType.negative:
        return true;
    }
  }

  Future<HabitDBCell?> saveHabit() async {
    if (!canSaveHabit()) {
      appLog.habit.warn(
        "$runtimeType.saveHabit",
        ex: ["Habit unsaved", _form.editMode, name],
      );
      return null;
    }
    return switch (_form.editMode) {
      HabitDisplayEditMode.create => _saveNewHabit(),
      HabitDisplayEditMode.edit => _saveExistHabit(),
    };
  }

  Future<HabitDBCell?> _saveNewHabit() async {
    final freq = frequency.toJson();
    final now = AppClock().now().millisecondsSinceEpoch ~/ onSecondMS;
    final reminder = this.reminder;
    final dbCell = HabitDBCell(
      type: habitType.dbCode,
      uuid: genHabitUUID(),
      status: HabitStatus.activated.dbCode,
      name: name,
      desc: desc,
      color: color.dbColorType.dbCode,
      customColor: color.dbCustomColor,
      customColorTinted: color.dbCustomColorTinted,
      dailyGoal: dailyGoalValue,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
      freqType: freq["type"],
      freqCustom: jsonEncode(freq["args"]),
      startDate: startDate.epochDay,
      targetDays: targetDays,
      remindCustom: reminder != null ? jsonEncode(reminder.toJson()) : null,
      remindQuestion: reminder != null ? reminderQuest : null,
      sortPosition: double.infinity,
      createT: now,
      modifyT: now,
      groupId: _form.groupId,
    );
    return _access.saveNewHabitAndUpdateReminder(dbCell);
  }

  Future<HabitDBCell?> _saveExistHabit() async {
    assert(_form.editParams != null);

    final freq = frequency.toJson();
    final habitUUID = _form.editParams!.uuid;
    final reminder = this.reminder;
    final dbCell = HabitDBCell(
      type: habitType.dbCode,
      uuid: habitUUID,
      name: name,
      desc: desc,
      color: color.dbColorType.dbCode,
      customColor: color.dbCustomColor,
      customColorTinted: color.dbCustomColorTinted,
      dailyGoal: dailyGoalValue,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
      freqType: freq["type"],
      freqCustom: jsonEncode(freq["args"]),
      startDate: startDate.epochDay,
      targetDays: targetDays,
      remindCustom: reminder != null ? jsonEncode(reminder.toJson()) : null,
      remindQuestion: reminder != null ? reminderQuest : null,
      groupId: _form.groupId,
    );
    return _access.updateExistHabitAndUpdateReminder(dbCell);
  }
}
