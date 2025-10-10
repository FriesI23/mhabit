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
import 'package:json_annotation/json_annotation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/types.dart';
import '../l10n/localizations.dart';
import '../storage/db/handlers/habit.dart';
import 'habit_daily_goal.dart';
import 'habit_display.dart';
import 'habit_freq.dart';
import 'habit_reminder.dart';

@JsonEnum(valueField: 'code')
enum HabitType implements EnumWithDBCode {
  unknown(code: 0),
  normal(code: 1),
  negative(code: 2);

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

  static String getHabitTypeName(HabitType type, [L10n? l10n]) {
    switch (type) {
      case HabitType.unknown:
        return '';
      case HabitType.normal:
        return l10n?.habitEdit_habitType_positiveText ?? "Positive";
      case HabitType.negative:
        return l10n?.habitEdit_habitType_negativeText ?? "Negative";
    }
  }

  static IconData getHabitTypeFlagIcon(HabitType type) {
    switch (type) {
      case HabitType.unknown:
      case HabitType.normal:
        return MdiIcons.circleOutline;
      case HabitType.negative:
        return MdiIcons.circleOffOutline;
    }
  }

  String getTypeName([L10n? l10n]) => HabitType.getHabitTypeName(this, l10n);

  IconData getIcon() => HabitType.getHabitTypeFlagIcon(this);
}

@JsonEnum(valueField: 'code')
enum HabitStatus implements EnumWithDBCode<HabitStatus> {
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
enum HabitColorType implements EnumWithDBCode<HabitColorType> {
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
enum HabitFrequencyType implements EnumWithDBCode<HabitRecordStatus> {
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
enum HabitRecordStatus implements EnumWithDBCode<HabitRecordStatus> {
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

enum HabitDailyComplateStatus {
  zero,
  ok,
  goodjob,
  tryhard,
  noeffect,
}

class HabitForm {
  String name;
  HabitType type;
  HabitColorType colorType;
  HabitDailyGoalData dailyGoal;
  HabitFrequency frequency;
  HabitStartDate startDate;
  int targetDays;
  String? desc;
  HabitReminder? reminder;
  String? reminderQuest;
  final HabitDisplayEditMode editMode;
  final HabitDisplayEditParams? editParams;

  HabitForm({
    required this.name,
    required this.type,
    required this.colorType,
    required this.dailyGoal,
    required this.frequency,
    required this.startDate,
    required this.targetDays,
    this.desc,
    this.reminder,
    this.reminderQuest,
    this.editMode = HabitDisplayEditMode.create,
    this.editParams,
  });

  HabitForm._fromHabitDBCell({
    required this.name,
    required this.type,
    required this.colorType,
    required this.dailyGoal,
    required this.frequency,
    required this.startDate,
    required this.targetDays,
    this.desc,
    this.reminder,
    this.reminderQuest,
    required this.editMode,
    required this.editParams,
  });

  HabitForm.empty({
    HabitType type = defaultHabitType,
    HabitColorType colorType = defaultHabitColorType,
  }) : this(
            name: '',
            type: type,
            colorType: colorType,
            startDate: HabitStartDate.dateTime(DateTime.now()),
            frequency: HabitFrequency.daily,
            dailyGoal: HabitDailyGoalData(type: type),
            targetDays: defaultHabitTargetDays,
            desc: '');

  factory HabitForm.fromHabitDBCell(HabitDBCell cell,
      {required HabitDisplayEditMode editMode,
      HabitDisplayEditParams? editParams}) {
    assert(cell.name != null &&
        cell.type != null &&
        cell.color != null &&
        cell.freqCustom != null &&
        cell.startDate != null);
    final name = cell.name!;
    final type = HabitType.getFromDBCode(cell.type!)!;
    final dailyGoal = HabitDailyGoalData(
        type: type,
        dailyGoal: cell.dailyGoal,
        dailyGoalUnit: cell.dailyGoalUnit,
        dailyGoalExtra: cell.dailyGoalExtra);
    final frequency = HabitFrequency.fromJson(
        {"type": cell.freqType, "args": jsonDecode(cell.freqCustom!)});
    final startDate = HabitStartDate.fromEpochDay(cell.startDate!);
    final targetDays = cell.targetDays!;
    final reminder = cell.remindCustom != null
        ? HabitReminder.fromJson(jsonDecode(cell.remindCustom!))
        : null;
    return HabitForm._fromHabitDBCell(
        name: name,
        type: type,
        colorType: HabitColorType.getFromDBCode(cell.color!)!,
        dailyGoal: dailyGoal,
        frequency: frequency,
        startDate: startDate,
        targetDays: targetDays,
        desc: cell.desc,
        reminder: reminder,
        reminderQuest: cell.remindQuestion,
        editMode: editMode,
        editParams: editParams);
  }

  @override
  String toString() {
    return 'HabitForm(name=$name,type=$type,colorType=$colorType,'
        'dailyGoal=$dailyGoal,frequency=$frequency,'
        'startDate=$startDate,targetDays=$targetDays,desc=$desc,'
        'reminder=$reminder,reminderQuest=$reminderQuest,editMode=$editMode,'
        'editParams=$editParams)';
  }
}
