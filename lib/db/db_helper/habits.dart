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

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../model/habit_form.dart';
import '../db.dart';

part 'habits.g.dart';

const String dbHabitsTableName = 'mh_habits';

class HabitDBCellKey {
  static const String id = 'id_';
  static const String type = 'type_';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String uuid = 'uuid';
  static const String status = 'status';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String color = 'color';
  static const String dailyGoal = 'daily_goal';
  static const String dailyGoalUnit = 'daily_goal_unit';
  static const String dailyGoalExtra = 'daily_goal_extra';
  static const String freqType = 'freq_type';
  static const String freqCustom = 'freq_custom';
  static const String startDate = 'start_date';
  static const String targetDays = 'target_days';
  static const String remindCustom = 'remind_cutsom';
  static const String remindQuestion = 'remind_question';
  static const String sortPosition = 'sort_position';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class HabitDBCell implements DBCellBase {
  @JsonKey(name: HabitDBCellKey.id)
  final DBID? id;
  @JsonKey(name: HabitDBCellKey.type)
  final int? type;
  @JsonKey(name: HabitDBCellKey.createT)
  final int? createT;
  @JsonKey(name: HabitDBCellKey.modifyT)
  final int? modifyT;
  @JsonKey(name: HabitDBCellKey.uuid)
  final HabitUUID? uuid;
  @JsonKey(name: HabitDBCellKey.status)
  final int? status;
  @JsonKey(name: HabitDBCellKey.name)
  final String? name;
  @JsonKey(name: HabitDBCellKey.desc)
  final String? desc;
  @JsonKey(name: HabitDBCellKey.color)
  final int? color;
  @JsonKey(name: HabitDBCellKey.dailyGoal)
  final num? dailyGoal;
  @JsonKey(name: HabitDBCellKey.dailyGoalUnit)
  final String? dailyGoalUnit;
  @JsonKey(name: HabitDBCellKey.dailyGoalExtra)
  final num? dailyGoalExtra;
  @JsonKey(name: HabitDBCellKey.freqType)
  final int? freqType;
  @JsonKey(name: HabitDBCellKey.freqCustom)
  final String? freqCustom;
  @JsonKey(name: HabitDBCellKey.startDate)
  final int? startDate;
  @JsonKey(name: HabitDBCellKey.targetDays)
  final int? targetDays;
  @JsonKey(name: HabitDBCellKey.remindCustom)
  final String? remindCustom;
  @JsonKey(name: HabitDBCellKey.remindQuestion)
  final String? remindQuestion;
  @JsonKey(name: HabitDBCellKey.sortPosition)
  final HabitSortPostion? sortPosition;

  const HabitDBCell(
      {this.id,
      this.type,
      this.createT,
      this.modifyT,
      this.uuid,
      this.status,
      this.name,
      this.desc,
      this.color,
      this.dailyGoal,
      this.dailyGoalUnit,
      this.dailyGoalExtra,
      this.freqType,
      this.freqCustom,
      this.startDate,
      this.targetDays,
      this.remindCustom,
      this.remindQuestion,
      this.sortPosition});

  factory HabitDBCell.fromMap(Map<String, Object?> cell) =>
      _$HabitDBCellFromJson(cell);

  @override
  Map<String, Object?> toMap() => _$HabitDBCellToJson(this);

  @override
  String toString() {
    return "HabitDB${toMap().toString()}";
  }
}

Future<int> insertNewHabitCellToDB(
  HabitDBCell habit, {
  void Function(HabitDBCell? result)? resultcallback,
}) async {
  var dbid = await DB().db.insert(
        dbHabitsTableName,
        habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
  if (resultcallback != null) {
    var result = await DB().db.query(
          dbHabitsTableName,
          where: "${HabitDBCellKey.id} = ?",
          whereArgs: [dbid],
          limit: 1,
        );
    if (result.isEmpty) {
      resultcallback(null);
    } else {
      resultcallback(HabitDBCell.fromMap(result[0]));
    }
  }
  return dbid;
}

Future<int> updateExistHabitCellToDB(
  HabitDBCell habit, {
  List includeNullKeys = const [],
  void Function(HabitDBCell? result)? resultcallback,
}) async {
  final map = habit.toMap();
  for (var key in includeNullKeys) {
    if (!map.containsKey(key)) map[key] = null;
  }

  var count = await DB().db.update(
        dbHabitsTableName,
        map,
        where: "${HabitDBCellKey.uuid} = ?",
        whereArgs: [habit.uuid],
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
  if (resultcallback != null) {
    var result = (await DB().db.query(
          dbHabitsTableName,
          where: "${HabitDBCellKey.uuid} = ?",
          whereArgs: [habit.uuid],
          limit: 1,
        ));

    if (result.isEmpty) {
      resultcallback(null);
    } else {
      resultcallback(HabitDBCell.fromMap(result[0]));
    }
  }
  return count;
}

const _loadHabitDetailColums = [
  HabitDBCellKey.id,
  HabitDBCellKey.uuid,
  HabitDBCellKey.type,
  HabitDBCellKey.name,
  HabitDBCellKey.desc,
  HabitDBCellKey.color,
  HabitDBCellKey.dailyGoal,
  HabitDBCellKey.dailyGoalUnit,
  HabitDBCellKey.dailyGoalExtra,
  HabitDBCellKey.targetDays,
  HabitDBCellKey.freqType,
  HabitDBCellKey.freqCustom,
  HabitDBCellKey.startDate,
  HabitDBCellKey.status,
  HabitDBCellKey.remindCustom,
  HabitDBCellKey.remindQuestion,
  HabitDBCellKey.sortPosition,
  HabitDBCellKey.createT,
  HabitDBCellKey.modifyT,
];

Future<HabitDBCell?> loadHabitDetailFromDB(HabitUUID uuid) async {
  var results = await DB().db.query(dbHabitsTableName,
      columns: _loadHabitDetailColums,
      where: "${HabitDBCellKey.uuid} = ?",
      whereArgs: [uuid],
      limit: 1);

  if (results.isEmpty) return null;
  return HabitDBCell.fromMap(results[0]);
}

const _loadHabitAboutDataCollectionColumns = [
  HabitDBCellKey.id,
  HabitDBCellKey.uuid,
  HabitDBCellKey.type,
  HabitDBCellKey.name,
  HabitDBCellKey.color,
  HabitDBCellKey.dailyGoal,
  HabitDBCellKey.dailyGoalExtra,
  HabitDBCellKey.targetDays,
  HabitDBCellKey.freqType,
  HabitDBCellKey.freqCustom,
  HabitDBCellKey.startDate,
  HabitDBCellKey.remindCustom,
  HabitDBCellKey.remindQuestion,
  HabitDBCellKey.status,
  HabitDBCellKey.sortPosition,
  HabitDBCellKey.createT,
];

Future<Iterable<HabitDBCell>> loadHabitAboutDataCollectionFromDB() async {
  final queryArgs = loadedHabitStatus.map((e) => e.dbCode).toList();
  var result = await DB().db.query(
        dbHabitsTableName,
        columns: _loadHabitAboutDataCollectionColumns,
        where: "${HabitDBCellKey.status} "
            "IN (${queryArgs.map((e) => '?').join(', ')})",
        whereArgs: queryArgs,
      );

  Iterable<HabitDBCell> iterResult() sync* {
    for (final cell in result) {
      yield HabitDBCell.fromMap(cell);
    }
  }

  return iterResult();
}

Future<void> refreshSelectedHabitsSortPostion(
    List<HabitUUID> uuidList, List<num> posList) async {
  assert(uuidList.length == posList.length, true);
  var batch = DB().db.batch();
  uuidList.forEachIndexed((index, uuid) {
    batch.update(
      dbHabitsTableName,
      {HabitDBCellKey.sortPosition: posList[index]},
      where: "${HabitDBCellKey.uuid} = ?",
      whereArgs: [uuid],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  });
  await batch.commit();
}

Future<int> changeSelectedHabitStatus(
    List<HabitUUID> uuidList, HabitStatus newStatus) {
  var result = DB().db.update(
        dbHabitsTableName,
        {HabitDBCellKey.status: newStatus.dbCode},
        where: "${HabitDBCellKey.uuid} "
            "IN (${uuidList.map((e) => '?').join(', ')})",
        whereArgs: uuidList,
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
  return result;
}
