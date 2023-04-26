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

import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../common/types.dart';
import '../db/db_helper/habits.dart';
import 'habit_display.dart';
import 'habit_freq.dart';
import 'habit_reminder.dart';

enum HabitType implements EnumWithDBCodeABC {
  unknown(code: 0),
  normal(code: 1);

  final int _code;

  const HabitType({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static HabitType? getFromDBCode(int dbCode,
      {HabitType? withDefault = HabitType.unknown}) {
    for (var value in HabitType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

@JsonEnum(valueField: 'code')
enum HabitStatus implements EnumWithDBCodeABC<HabitStatus> {
  unknown(code: 0),
  activated(code: 1),
  deleted(code: 2),
  archived(code: 3);

  final int code;

  const HabitStatus({required this.code});

  @override
  int get dbCode => code;

  static HabitStatus? getFromDBCode(int dbCode,
      {HabitStatus? withDefault = HabitStatus.unknown}) {
    for (var value in HabitStatus.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

@JsonEnum(valueField: 'code')
enum HabitColorType implements EnumWithDBCodeABC<HabitColorType> {
  cc1(code: 1),
  cc2(code: 2),
  cc3(code: 3),
  cc4(code: 4),
  cc5(code: 5),
  cc6(code: 6),
  cc7(code: 7),
  cc8(code: 8),
  cc9(code: 9),
  cc10(code: 10);

  final int code;

  const HabitColorType({required this.code});

  @override
  int get dbCode => code;

  static HabitColorType? getFromDBCode(int dbCode,
      {HabitColorType? withDefault = HabitColorType.cc1}) {
    for (var value in HabitColorType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

@JsonEnum(valueField: 'code')
enum HabitFrequencyType implements EnumWithDBCodeABC<HabitRecordStatus> {
  unknown(code: 0),
  weekly(code: 1),
  monthly(code: 2),
  custom(code: 3);

  final int code;

  const HabitFrequencyType({required this.code});

  @override
  int get dbCode => code;

  static HabitFrequencyType? getFromDBCode(int dbCode,
      {HabitFrequencyType? withDefault = HabitFrequencyType.unknown}) {
    for (var value in HabitFrequencyType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

@JsonEnum(valueField: 'code')
enum HabitRecordStatus implements EnumWithDBCodeABC<HabitRecordStatus> {
  unknown(code: 0),
  done(code: 1),
  skip(code: 2);

  final int code;

  const HabitRecordStatus({required this.code});

  @override
  int get dbCode => code;

  static HabitRecordStatus? getFromDBCode(int dbCode,
      {HabitRecordStatus? withDefault = HabitRecordStatus.unknown}) {
    for (var value in HabitRecordStatus.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

enum HabitDailyComplateStatus { zero, ok, goodjob, tryhard }

class HabitForm {
  String? name;
  HabitColorType? colorType;
  HabitDailyGoal? dailyGoal;
  String? dailyGoalUnit;
  HabitDailyGoal? dailyGoalExtra;
  HabitFrequency? frequency;
  HabitStartDate? startDate;
  int? targetDays;
  String? desc;
  HabitReminder? reminder;
  String? reminderQuest;
  final HabitDisplayEditMode editMode;
  final HabitDisplayEditParams? editParams;

  HabitForm({
    this.name,
    this.colorType,
    this.dailyGoal,
    this.dailyGoalUnit,
    this.dailyGoalExtra,
    this.frequency,
    this.startDate,
    this.targetDays,
    this.desc,
    this.reminder,
    this.reminderQuest,
    this.editMode = HabitDisplayEditMode.create,
    this.editParams,
  });

  HabitForm.fromHabitDBCell(HabitDBCell cell,
      {required this.editMode, this.editParams})
      : name = cell.name,
        colorType = HabitColorType.getFromDBCode(cell.color!)!,
        dailyGoal = cell.dailyGoal,
        dailyGoalUnit = cell.dailyGoalUnit,
        dailyGoalExtra = cell.dailyGoalExtra,
        frequency = HabitFrequency.fromMap(
            {"type": cell.freqType, "args": jsonDecode(cell.freqCustom!)}),
        startDate = HabitStartDate.fromEpochDay(cell.startDate!),
        targetDays = cell.targetDays,
        desc = cell.desc,
        reminder = cell.remindCustom != null
            ? HabitReminder.fromJson(jsonDecode(cell.remindCustom!))
            : null,
        reminderQuest = cell.remindQuestion;
}

class HabitDailyRecordForm {
  final num value;
  final num targetValue;

  const HabitDailyRecordForm(this.value, this.targetValue);

  static HabitDailyComplateStatus getComplateStatus(
      num value, num targetValue) {
    if (value > targetValue) {
      return HabitDailyComplateStatus.goodjob;
    } else if (value == targetValue) {
      return HabitDailyComplateStatus.ok;
    } else if (value > 0) {
      return HabitDailyComplateStatus.tryhard;
    } else {
      return HabitDailyComplateStatus.zero;
    }
  }

  HabitDailyComplateStatus get complateStatus =>
      getComplateStatus(value, targetValue);
}
