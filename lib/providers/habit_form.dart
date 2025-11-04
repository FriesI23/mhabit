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

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../models/habit_daily_goal.dart';
import '../models/habit_display.dart';
import '../models/habit_form.dart';
import '../models/habit_freq.dart';
import '../models/habit_reminder.dart';
import '../models/habit_summary.dart';
import '../storage/db/handlers/habit.dart';
import 'commons.dart';
import 'habits_manager.dart';

class HabitFormViewModel extends ChangeNotifier
    with HabitsManagerLoadedMixin, PinnedAppbarMixin
    implements ProviderMounted {
  // inside status
  bool _mounted = true;

  final HabitForm _form;

  HabitFormViewModel({HabitForm? initForm})
      : _form = initForm ?? HabitForm.empty();

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

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
    appLog.value.debug("$runtimeType.habitType",
        beforeVal: _form.type, afterVal: newHabitType);
    _form.type = newHabitType;
    _form.dailyGoal = _form.dailyGoal.transform(type: _form.type);
    notifyListeners();
  }

  HabitColorType get colorType => _form.colorType;
  set colorType(HabitColorType newColorType) {
    appLog.value.debug("$runtimeType.colorType",
        beforeVal: _form.colorType, afterVal: newColorType);
    _form.colorType = newColorType;
    notifyListeners();
  }

  bool get isDailyGoalValueValid => _form.dailyGoal.isGoalValid();

  HabitDailyGoalContainer get dailyGoal => _form.dailyGoal;

  num get dailyGoalValue => _form.dailyGoal.dailyGoal;
  set dailyGoalValue(num newDailyGoal) {
    appLog.value.debug("$runtimeType.dailyGoal",
        beforeVal: _form.dailyGoal.dailyGoal,
        afterVal: newDailyGoal,
        ex: [_form.dailyGoal.type]);
    _form.dailyGoal.dailyGoal = newDailyGoal;
    notifyListeners();
  }

  String get dailyGoalUnit => _form.dailyGoal.dailyGoalUnit;
  set dailyGoalUnit(String newDailyGoalUnit) {
    appLog.value.debug("$runtimeType.dailyGoalUnit",
        beforeVal: _form.dailyGoal.dailyGoalUnit,
        afterVal: newDailyGoalUnit,
        ex: [_form.dailyGoal.type]);
    _form.dailyGoal.dailyGoalUnit = newDailyGoalUnit;
    notifyListeners();
  }

  num? get dailyGoalExtra => _form.dailyGoal.dailyGoalExtra;
  set dailyGoalExtra(num? newDailyGoalExtra) {
    appLog.value.debug("$runtimeType.dailyGoalExtra",
        beforeVal: _form.dailyGoal.dailyGoalExtra,
        afterVal: newDailyGoalExtra,
        ex: [_form.dailyGoal.type]);
    _form.dailyGoal.dailyGoalExtra = newDailyGoalExtra;
    notifyListeners();
  }

  bool get isDailyGoalExtraValueValid {
    final dailyGoalExtra = this.dailyGoalExtra;
    return dailyGoalExtra == null || dailyGoalExtra >= dailyGoalValue;
  }

  HabitFrequency get frequency => _form.frequency;
  set frequency(HabitFrequency newHabitFrequency) {
    appLog.value.debug("$runtimeType.frequency",
        beforeVal: _form.frequency, afterVal: newHabitFrequency);
    _form.frequency = newHabitFrequency;
    notifyListeners();
  }

  HabitStartDate get startDate => _form.startDate;
  set startDate(HabitStartDate newDate) {
    appLog.value.debug("$runtimeType.startDate",
        beforeVal: _form.startDate, afterVal: newDate);
    _form.startDate = newDate;
    notifyListeners();
  }

  int get targetDays => _form.targetDays;
  set targetDays(int newTargetDays) {
    appLog.value.debug("$runtimeType.targetDays",
        beforeVal: _form.targetDays, afterVal: newTargetDays);
    _form.targetDays = newTargetDays;
    notifyListeners();
  }

  String get desc => _form.desc ?? "";
  set desc(String newDesc) {
    appLog.value
        .debug("$runtimeType.desc", beforeVal: _form.desc, afterVal: newDesc);
    _form.desc = newDesc;
    notifyListeners();
  }

  HabitReminder? get reminder => _form.reminder;
  set reminder(HabitReminder? newReminder) {
    appLog.value.debug("$runtimeType.reminder",
        beforeVal: _form.reminder, afterVal: newReminder);
    _form.reminder = newReminder;
    notifyListeners();
  }

  String? get reminderQuest => _form.reminderQuest;
  set reminderQuest(String? newQuest) {
    appLog.value.debug("$runtimeType.reminderQuest",
        beforeVal: _form.reminderQuest, afterVal: newQuest);
    _form.reminderQuest = newQuest;
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
      appLog.habit.warn("$runtimeType.saveHabit",
          ex: ["Habit unsaved", _form.editMode, name]);
      return null;
    }
    final cell = switch (_form.editMode) {
      HabitDisplayEditMode.create => await _saveNewHabit(),
      HabitDisplayEditMode.edit => await _saveExistHabit()
    };
    if (!mounted || cell == null) return cell;
    final habit = HabitSummaryData.fromDBQueryCell(cell);
    await habitsManager.updateHabitReminder(habit);
    return cell;
  }

  Future<HabitDBCell?> _saveNewHabit() async {
    final freq = frequency.toJson();
    final now = DateTime.now().millisecondsSinceEpoch ~/ onSecondMS;
    final reminder = this.reminder;
    final dbCell = HabitDBCell(
        type: habitType.dbCode,
        uuid: genHabitUUID(),
        status: HabitStatus.activated.dbCode,
        name: name,
        desc: desc,
        color: colorType.dbCode,
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
        modifyT: now);
    return habitsManager.saveNewHabitToDB(dbCell, returnResult: true);
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
      color: colorType.dbCode,
      dailyGoal: dailyGoalValue,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
      freqType: freq["type"],
      freqCustom: jsonEncode(freq["args"]),
      startDate: startDate.epochDay,
      targetDays: targetDays,
      remindCustom: reminder != null ? jsonEncode(reminder.toJson()) : null,
      remindQuestion: reminder != null ? reminderQuest : null,
    );
    return habitsManager.updateExistHabitToDB(dbCell, returnResult: true);
  }
}
