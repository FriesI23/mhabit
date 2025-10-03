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

import 'package:flutter/material.dart';

import '../common/consts.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../extensions/num_extensions.dart';
import '../logging/helper.dart';
import '../model/habit_daily_goal.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_freq.dart';
import '../model/habit_reminder.dart';
import '../storage/db/handlers/habit.dart';
import '../storage/db_helper_provider.dart';
import 'commons.dart';

class HabitFormViewModel extends ChangeNotifier
    with
        ScrollControllerChangeNotifierMixin,
        DBHelperLoadedMixin,
        DBOperationsMixin
    implements ProviderMounted {
  final TextEditingController _nameFieldInputController;
  final TextEditingController _dailyGoalFieldInputController;
  final TextEditingController _dailyGoalUnitFieldInputController;
  final TextEditingController _dailyGoalExtraFieldInpuController;
  final TextEditingController _descFieldInputController;
  // inside status
  bool _mounted = true;

  final HabitForm _form;

  HabitFormViewModel({
    HabitForm? initForm,
    required ScrollController appbarScrollController,
    required TextEditingController nameFieldInputController,
    required TextEditingController dailyGoalFieldInputController,
    required TextEditingController dailyGoalUnitFieldInputController,
    required TextEditingController dailyGoalExtraFieldInpuController,
    required TextEditingController descFieldInputController,
  })  : _form = initForm ??
            HabitForm(
                name: '',
                colorType: defaultHabitColorType,
                startDate: HabitStartDate.dateTime(DateTime.now()),
                frequency: HabitFrequency.daily,
                dailyGoalUnit: defaultHabitDailyGoalUnit,
                targetDays: defaultHabitTargetDays,
                desc: ''),
        _nameFieldInputController = nameFieldInputController,
        _dailyGoalFieldInputController = dailyGoalFieldInputController,
        _dailyGoalUnitFieldInputController = dailyGoalUnitFieldInputController,
        _dailyGoalExtraFieldInpuController = dailyGoalExtraFieldInpuController,
        _descFieldInputController = descFieldInputController {
    initVerticalScrollController(notifyListeners, appbarScrollController);
    _nameFieldInputController.text = _form.name ?? '';
    _dailyGoalFieldInputController.text =
        _form.dailyGoal?.toSimpleString() ?? '';
    _dailyGoalUnitFieldInputController.text = _form.dailyGoalUnit ?? '';
    _dailyGoalExtraFieldInpuController.text = _form.dailyGoalExtra != null
        ? _form.dailyGoalExtra!.toSimpleString()
        : '';
    _descFieldInputController.text = _form.desc ?? '';
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _nameFieldInputController.dispose();
    _dailyGoalFieldInputController.dispose();
    _dailyGoalUnitFieldInputController.dispose();
    _dailyGoalExtraFieldInpuController.dispose();
    _descFieldInputController.dispose();
    disposeVerticalScrollController();
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  TextEditingController get nameFieldInputController =>
      _nameFieldInputController;

  TextEditingController get dailyGoalFieldInputController =>
      _dailyGoalFieldInputController;

  TextEditingController get dailyGoalUnitFieldInputController =>
      _dailyGoalUnitFieldInputController;

  TextEditingController get dailyGoalExtraFieldInpuController =>
      _dailyGoalExtraFieldInpuController;

  TextEditingController get descFieldInputController =>
      _descFieldInputController;

  String get name => _form.name!;
  set name(String newName) {
    appLog.value
        .debug("$runtimeType.name", beforeVal: _form.name, afterVal: newName);
    _form.name = newName;
    notifyListeners();
  }

  HabitType get habitType => _form.type ?? defaultHabitType;
  set habitType(HabitType newHabitType) {
    appLog.value.debug("$runtimeType.habitType",
        beforeVal: _form.type, afterVal: newHabitType);
    _form.type = newHabitType;
    notifyListeners();
  }

  HabitColorType get colorType => _form.colorType!;
  set colorType(HabitColorType newColorType) {
    appLog.value.debug("$runtimeType.colorType",
        beforeVal: _form.colorType, afterVal: newColorType);
    _form.colorType = newColorType;
    notifyListeners();
  }

  num get dailyGoal {
    if (_form.dailyGoal != null) return _form.dailyGoal!;
    return HabitDailyGoalHelper.getDefaultDailyGoal(habitType);
  }

  bool get isDailyGoalValueValid =>
      HabitDailyGoalHelper(habitType: habitType, dailyGoal: dailyGoal)
          .isGoalValid;

  set dailyGoal(num newDailyGoal) {
    appLog.value.debug("$runtimeType.dailyGoal",
        beforeVal: _form.dailyGoal, afterVal: newDailyGoal);
    _form.dailyGoal = newDailyGoal;
    notifyListeners();
  }

  String get dailyGoalUnit => _form.dailyGoalUnit!;
  set dailyGoalUnit(String newDailyGoalUnit) {
    appLog.value.debug("$runtimeType.dailyGoalUnit",
        beforeVal: _form.dailyGoalUnit, afterVal: newDailyGoalUnit);
    _form.dailyGoalUnit = newDailyGoalUnit;
    notifyListeners();
  }

  num? get dailyGoalExtra => _form.dailyGoalExtra;
  set dailyGoalExtra(num? newDailyGoalExtra) {
    appLog.value.debug("$runtimeType.dailyGoalExtra",
        beforeVal: _form.dailyGoalExtra, afterVal: newDailyGoalExtra);
    _form.dailyGoalExtra = newDailyGoalExtra;
    notifyListeners();
  }

  bool get isDailyGoalExtraValueValid =>
      dailyGoalExtra == null || dailyGoalExtra! >= dailyGoal;

  HabitFrequency get frequency => _form.frequency!;
  set frequency(HabitFrequency newHabitFrequency) {
    appLog.value.debug("$runtimeType.frequency",
        beforeVal: _form.frequency, afterVal: newHabitFrequency);
    _form.frequency = newHabitFrequency;
    notifyListeners();
  }

  HabitStartDate get startDate => _form.startDate!;
  set startDate(HabitStartDate newDate) {
    appLog.value.debug("$runtimeType.startDate",
        beforeVal: _form.startDate, afterVal: newDate);
    _form.startDate = newDate;
    notifyListeners();
  }

  int get targetDays => _form.targetDays!;
  set targetDays(int newTargetDays) {
    appLog.value.debug("$runtimeType.targetDays",
        beforeVal: _form.targetDays, afterVal: newTargetDays);
    _form.targetDays = newTargetDays;
    notifyListeners();
  }

  String get desc => _form.desc!;
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
    switch (_form.editMode) {
      case HabitDisplayEditMode.create:
        return await _saveNewHabit(returnResult: true);
      case HabitDisplayEditMode.edit:
        return await _saveExistHabit(returnResult: true);
    }
  }

  Future<HabitDBCell?> _saveNewHabit({bool returnResult = false}) async {
    final freq = frequency.toJson();
    final now = DateTime.now().millisecondsSinceEpoch ~/ onSecondMS;
    final dbCell = HabitDBCell(
        type: habitType.dbCode,
        uuid: genHabitUUID(),
        status: HabitStatus.activated.dbCode,
        name: name,
        desc: desc,
        color: colorType.dbCode,
        dailyGoal: dailyGoal,
        dailyGoalUnit: dailyGoalUnit,
        dailyGoalExtra: dailyGoalExtra,
        freqType: freq["type"],
        freqCustom: jsonEncode(freq["args"]),
        startDate: startDate.epochDay,
        targetDays: targetDays,
        remindCustom: reminder != null ? jsonEncode(reminder!.toJson()) : null,
        remindQuestion: reminder != null ? reminderQuest : null,
        sortPosition: double.infinity,
        createT: now,
        modifyT: now);

    final dbid = await habitDBHelper.insertNewHabit(dbCell);
    final result =
        returnResult ? await habitDBHelper.queryHabitByDBID(dbid) : null;
    appLog.db.info("new habit saved", ex: [dbid, result]);
    return result;
  }

  Future<HabitDBCell?> _saveExistHabit({bool returnResult = false}) async {
    final freq = frequency.toJson();
    final habitUUID = _form.editParams!.uuid;
    final dbCell = HabitDBCell(
      type: habitType.dbCode,
      uuid: habitUUID,
      name: name,
      desc: desc,
      color: colorType.dbCode,
      dailyGoal: dailyGoal,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
      freqType: freq["type"],
      freqCustom: jsonEncode(freq["args"]),
      startDate: startDate.epochDay,
      targetDays: targetDays,
      remindCustom: reminder != null ? jsonEncode(reminder!.toJson()) : null,
      remindQuestion: reminder != null ? reminderQuest : null,
    );

    final count =
        await habitDBHelper.updateExistHabit(dbCell, includeNullKeys: const [
      HabitDBCellKey.remindCustom,
      HabitDBCellKey.remindQuestion,
      HabitDBCellKey.dailyGoalExtra,
    ]);
    final result = (count > 0 && returnResult)
        ? await habitDBHelper.queryHabitByUUID(habitUUID)
        : null;
    appLog.db.info("exist habit saved", ex: [count, result]);
    return result;
  }
}
