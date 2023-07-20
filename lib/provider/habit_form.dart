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
import '../common/logging.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../db/db_helper/habits.dart';
import '../extension/num_extensions.dart';
import '../model/habit_daily_goal.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_freq.dart';
import '../model/habit_reminder.dart';
import 'commons.dart';

class HabitFormViewModel extends ChangeNotifier
    with ScrollControllerChangeNotifierMixin
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
    if (_form.editMode == HabitDisplayEditMode.edit) {
      _nameFieldInputController.text = _form.name!;
      _dailyGoalFieldInputController.text = _form.dailyGoal!.toSimpleString();
      _dailyGoalUnitFieldInputController.text = _form.dailyGoalUnit!;
      _dailyGoalExtraFieldInpuController.text = _form.dailyGoalExtra != null
          ? _form.dailyGoalExtra!.toSimpleString()
          : '';
      _descFieldInputController.text = _form.desc!;
    }
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
    _form.name = newName;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.name: '
        '${_form.name} -> $newName');
  }

  HabitType get habitType => _form.type ?? defaultHabitType;
  set habitType(HabitType newHabitType) {
    _form.type = newHabitType;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.habitType: '
        '${_form.type} -> $newHabitType');
  }

  HabitColorType get colorType => _form.colorType!;
  set colorType(HabitColorType newColorType) {
    _form.colorType = newColorType;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.colorType: '
        '${_form.colorType} -> $newColorType');
  }

  num get dailyGoal {
    if (_form.dailyGoal != null) return _form.dailyGoal!;
    return HabitDailyGoalHelper.getDefaultDailyGoal(habitType);
  }

  bool get isDailyGoalValueValid =>
      HabitDailyGoalHelper(habitType: habitType, dailyGoal: dailyGoal)
          .isGoalValid;

  set dailyGoal(num newDailyGoal) {
    _form.dailyGoal = newDailyGoal;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.dailyGoal: '
        '${_form.dailyGoal} -> $newDailyGoal');
  }

  String get dailyGoalUnit => _form.dailyGoalUnit!;
  set dailyGoalUnit(String newDailyGoalUnit) {
    _form.dailyGoalUnit = newDailyGoalUnit;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.dailyGoalUnit: '
        '${_form.dailyGoalUnit} -> $newDailyGoalUnit');
  }

  num? get dailyGoalExtra => _form.dailyGoalExtra;
  set dailyGoalExtra(num? newDailyGoalExtra) {
    _form.dailyGoalExtra = newDailyGoalExtra;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.dailyGoalExtra: '
        '${_form.dailyGoalExtra} -> $newDailyGoalExtra');
  }

  bool get isDailyGoalExtraValueValid =>
      dailyGoalExtra == null || dailyGoalExtra! >= dailyGoal;

  HabitFrequency get frequency => _form.frequency!;
  set frequency(HabitFrequency newHabitFrequency) {
    _form.frequency = newHabitFrequency;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.habitFrequency: '
        '${_form.frequency} -> $newHabitFrequency');
  }

  HabitStartDate get startDate => _form.startDate!;
  set startDate(HabitStartDate newDate) {
    _form.startDate = newDate;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.newDate: '
        '${_form.startDate} -> $newDate');
  }

  int get targetDays => _form.targetDays!;
  set targetDays(int newTargetDays) {
    _form.targetDays = newTargetDays;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.targetDays: '
        '${_form.targetDays} -> $newTargetDays');
  }

  String get desc => _form.desc!;
  set desc(String newDesc) {
    _form.desc = newDesc;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.desc: '
        '${_form.desc} -> $newDesc');
  }

  HabitReminder? get reminder => _form.reminder;
  set reminder(HabitReminder? newReminder) {
    _form.reminder = newReminder;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.reminder: '
        '${_form.reminder} -> $newReminder');
  }

  String? get reminderQuest => _form.reminderQuest;
  set reminderQuest(String? newQuest) {
    _form.reminderQuest = newQuest;
    notifyListeners();
    DebugLog.setValue('HabitFormViewModel.reminderQuest: '
        '${_form.reminderQuest} -> $newQuest');
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
      WarnLog.saveHabit("habit unsaved, mode=${_form.editMode}");
      return null;
    }
    switch (_form.editMode) {
      case HabitDisplayEditMode.create:
        return await saveNewHabit(returnResult: true);
      case HabitDisplayEditMode.edit:
        return await saveExistHabit(returnResult: true);
    }
  }

  Future<HabitDBCell?> saveNewHabit({bool returnResult = false}) async {
    var freq = frequency.toMap();
    var now = DateTime.now().millisecondsSinceEpoch ~/ onSecondMS;
    var dbCell = HabitDBCell(
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

    HabitDBCell? result;
    void Function(HabitDBCell? cell)? resultCallback;
    if (returnResult) {
      resultCallback = (cell) {
        result = cell;
      };
    }
    int dbid =
        await insertNewHabitCellToDB(dbCell, resultcallback: resultCallback);
    DebugLog.db("new habit saved: dbid=$dbid, dbcell=$result");
    return result;
  }

  Future<HabitDBCell?> saveExistHabit({bool returnResult = false}) async {
    var freq = frequency.toMap();
    var dbCell = HabitDBCell(
      type: habitType.dbCode,
      uuid: _form.editParams!.uuid,
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

    HabitDBCell? result;
    void Function(HabitDBCell? cell)? resultCallback;
    if (returnResult) {
      resultCallback = (cell) {
        result = cell;
      };
    }

    int count = await updateExistHabitCellToDB(
      dbCell,
      includeNullKeys: const [
        HabitDBCellKey.remindCustom,
        HabitDBCellKey.remindQuestion,
        HabitDBCellKey.dailyGoalExtra,
      ],
      resultcallback: resultCallback,
    );
    DebugLog.db("exist habit saved: dbid=$count, dbcell=$result");
    return result;
  }
}
