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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/types.dart';
import '../db/db_helper/habits.dart';
import '../db/db_helper/records.dart';
import 'common.dart';

part 'habit_export.g.dart';

class RecordExportDataKey {
  static const String recordDate = 'record_date';
  static const String recordType = 'record_type';
  static const String recordValue = 'record_value';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class RecordExportData implements JsonAdaptor {
  @JsonKey(name: RecordExportDataKey.recordDate)
  final int? recordDate;
  @JsonKey(name: RecordExportDataKey.recordType)
  final int? recordType;
  @JsonKey(name: RecordExportDataKey.recordValue)
  final num? recordValue;
  @JsonKey(name: RecordExportDataKey.createT)
  final int? createT;
  @JsonKey(name: RecordExportDataKey.modifyT)
  final int? modifyT;

  const RecordExportData(
      {this.recordDate,
      this.recordType,
      this.recordValue,
      this.createT,
      this.modifyT});

  RecordExportData.fromHabitDBCell(RecordDBCell cell)
      : recordDate = cell.recordDate,
        recordType = cell.recordType,
        recordValue = cell.recordValue,
        createT = cell.createT,
        modifyT = cell.modifyT;

  factory RecordExportData.fromJson(dynamic json) =>
      _$RecordExportDataFromJson(json);

  RecordDBCell toRecordDBCell() => RecordDBCell(
        recordDate: recordDate,
        recordType: recordType,
        recordValue: recordValue,
        createT: createT,
        modifyT: modifyT,
      );

  @override
  Map<String, dynamic> toJson() => _$RecordExportDataToJson(this);
}

class HabitExportDataKey {
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String type = 'type';
  static const String status = 'status';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String color = 'color';
  static const String dailyGoal = 'daily_goal';
  static const String dailyGoalUnit = 'daily_goal_unit';
  static const String dailyGoalExtra = 'daily_goal_extra';
  static const String freqType = 'freq_type';
  static const String freqCustom = 'freq_custom';
  static const String reminder = 'reminder';
  static const String reminderQuest = 'reminder_quest';
  static const String startDate = 'start_date';
  static const String targetDays = 'target_days';
  static const String sortPosition = 'sort_position';
  static const String records = 'records';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class HabitExportData implements JsonAdaptor {
  @JsonKey(name: HabitExportDataKey.createT)
  final int? createT;
  @JsonKey(name: HabitExportDataKey.modifyT)
  final int? modifyT;
  @JsonKey(name: HabitExportDataKey.type)
  final int? type;
  @JsonKey(name: HabitExportDataKey.status)
  final int? status;
  @JsonKey(name: HabitExportDataKey.name)
  final String? name;
  @JsonKey(name: HabitExportDataKey.desc)
  final String? desc;
  @JsonKey(name: HabitExportDataKey.color)
  final int? color;
  @JsonKey(name: HabitExportDataKey.dailyGoal)
  final num? dailyGoal;
  @JsonKey(name: HabitExportDataKey.dailyGoalUnit)
  final String? dailyGoalUnit;
  @JsonKey(name: HabitExportDataKey.dailyGoalExtra)
  final num? dailyGoalExtra;
  @JsonKey(name: HabitExportDataKey.freqType)
  final int? freqType;
  @JsonKey(name: HabitExportDataKey.freqCustom)
  final String? freqCustom;
  @JsonKey(name: HabitExportDataKey.reminder)
  final String? reminder;
  @JsonKey(name: HabitExportDataKey.reminderQuest)
  final String? reminderQuest;
  @JsonKey(name: HabitExportDataKey.startDate)
  final int? startDate;
  @JsonKey(name: HabitExportDataKey.targetDays)
  final int? targetDays;
  @JsonKey(name: HabitExportDataKey.records, toJson: _recordsToJson)
  final List<RecordExportData> records;

  const HabitExportData(
      {this.createT,
      this.modifyT,
      this.type,
      this.status,
      this.name,
      this.desc,
      this.color,
      this.dailyGoal,
      this.dailyGoalUnit,
      this.dailyGoalExtra,
      this.freqType,
      this.freqCustom,
      this.reminder,
      this.reminderQuest,
      this.startDate,
      this.targetDays,
      this.records = const []});

  HabitExportData.fromHabitDBCell(HabitDBCell cell, {this.records = const []})
      : createT = cell.createT,
        modifyT = cell.modifyT,
        type = cell.type,
        status = cell.status,
        name = cell.name,
        desc = cell.desc,
        color = cell.color,
        dailyGoal = cell.dailyGoal,
        dailyGoalUnit = cell.dailyGoalUnit,
        dailyGoalExtra = cell.dailyGoalExtra,
        freqType = cell.freqType,
        freqCustom = cell.freqCustom,
        reminder = cell.remindCustom,
        reminderQuest = cell.remindQuestion,
        startDate = cell.startDate,
        targetDays = cell.targetDays;

  factory HabitExportData.fromJson(dynamic json) =>
      _$HabitExportDataFromJson(json);

  HabitDBCell toHabitDBCell() => HabitDBCell(
        createT: createT,
        modifyT: modifyT,
        type: type,
        status: status,
        name: name,
        desc: desc,
        color: color,
        dailyGoal: dailyGoal,
        dailyGoalUnit: dailyGoalUnit,
        dailyGoalExtra: dailyGoalExtra,
        freqType: freqType,
        freqCustom: freqCustom,
        remindCustom: reminder,
        remindQuestion: reminderQuest,
        startDate: startDate,
        targetDays: targetDays,
      );

  @override
  Map<String, dynamic> toJson() => _$HabitExportDataToJson(this);

  Iterable<RecordDBCell> getRecordDBCells() sync* {
    for (var record in records) {
      yield record.toRecordDBCell();
    }
  }

  static List<Map<String, dynamic>> _recordsToJson(
      List<RecordExportData> records) {
    return records.map((e) => e.toJson()).toList();
  }
}

abstract class HabitExporterABC {
  Future<Iterable<HabitExportData>> exportData({bool withRecords = true});
}

mixin HabitExporterMixin {
  Map<DBID, HabitExportData> buildExportDataMap(
      Iterable<HabitDBCell> habits, Iterable<RecordDBCell> records) {
    final results = <DBID, HabitExportData>{};

    for (var cell in habits) {
      final habit = HabitExportData.fromHabitDBCell(cell, records: []);
      if (cell.id != null) results[cell.id!] = habit;
    }

    for (var cell in records) {
      final record = RecordExportData.fromHabitDBCell(cell);
      if (results.containsKey(cell.parentId)) {
        results[cell.parentId]?.records.add(record);
      }
    }

    return results;
  }
}

class HabitExporter with HabitExporterMixin implements HabitExporterABC {
  final List<HabitUUID> uuidList;

  const HabitExporter({this.uuidList = const []});

  @override
  Future<Iterable<HabitExportData>> exportData(
      {bool withRecords = true}) async {
    Iterable<HabitDBCell> habits;
    Iterable<RecordDBCell> records;

    final habitFuture = loadHabitsExportDataFromDB(uuidList);
    if (withRecords) {
      final recordsFuture = loadHRecordsExportDataFromDB(uuidList);
      records = await recordsFuture;
    } else {
      records = [];
    }

    habits = await habitFuture;

    return buildExportDataMap(habits, records).values;
  }
}

class HabitExportAll with HabitExporterMixin implements HabitExporterABC {
  const HabitExportAll();

  @override
  Future<Iterable<HabitExportData>> exportData(
      {bool withRecords = true}) async {
    Iterable<HabitDBCell> habits;
    Iterable<RecordDBCell> records;

    final habitFuture = loadAllHabitExportDataFromDB();
    if (withRecords) {
      final recordsFuture = loadHAllRecordExportDataFromDB();
      records = await recordsFuture;
    } else {
      records = [];
    }

    habits = await habitFuture;

    return buildExportDataMap(habits, records).values;
  }
}
