// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:sqflite/sqflite.dart';

import 'handler/sync.dart';
import 'table.dart';

String buildConflictAlgorithm(ConflictAlgorithm conflictAlgorithm) =>
    switch (conflictAlgorithm) {
      ConflictAlgorithm.rollback => "OR ROLLBACK",
      ConflictAlgorithm.abort => "OR ABORT",
      ConflictAlgorithm.fail => "OR FAIL",
      ConflictAlgorithm.ignore => "OR IGNORE",
      ConflictAlgorithm.replace => "OR REPLACE",
    };

class CustomSql {
  static const String autoUpdateRecordsModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_records_modify_t
AFTER UPDATE ON ${TableName.records}
BEGIN
  UPDATE ${TableName.records}
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END""";

  static const String autoUpdateHabitsModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_habits_modify_t
AFTER UPDATE ON ${TableName.habits}
BEGIN
  UPDATE ${TableName.habits}
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END
""";

  static const String rmAutoAddSortPostionWhenAddNewHabitTrigger = """
DROP TRIGGER IF EXISTS auto_insert_mh_habits_sort_position;
""";

  static const String autoAddSortPostionWhenAddNewHabit = """
CREATE TRIGGER auto_insert_mh_habits_sort_position
AFTER INSERT ON ${TableName.habits}
BEGIN
  UPDATE ${TableName.habits}
  SET sort_position = NEW.id_
  WHERE uuid = NEW.uuid AND sort_position = 9e999;
END
""";

  static const String autoUpdateSyncModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_sync_modify_t
AFTER UPDATE ON ${TableName.sync}
BEGIN
  UPDATE ${TableName.sync}
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE id_ = NEW.id_;
END
""";

  /// required arguments: [recordUUID]
  static String increaseRecordSyncDirtySql(
      {ConflictAlgorithm? conflictAlgorithm}) {
    final sql = StringBuffer();
    sql.write("UPDATE");
    if (conflictAlgorithm != null) {
      sql
        ..write(" ")
        ..write(buildConflictAlgorithm(conflictAlgorithm));
    }
    sql
      ..write(" ${TableName.sync}")
      ..write(" SET ${SyncDbCellKey.dirty} = ${SyncDbCellKey.dirty} + 1")
      ..write(" WHERE ${SyncDbCellKey.recordUUID} = ?");

    return sql.toString();
  }

  /// required arguments: [habitUUID]
  static String increaseHabitSyncDirtySql(
      {ConflictAlgorithm? conflictAlgorithm}) {
    final sql = StringBuffer();
    sql.write("UPDATE");
    if (conflictAlgorithm != null) {
      sql
        ..write(" ")
        ..write(buildConflictAlgorithm(conflictAlgorithm));
    }
    sql
      ..write(" ${TableName.sync}")
      ..write(" SET ${SyncDbCellKey.dirty} = ${SyncDbCellKey.dirty} + 1")
      ..write(" WHERE ${SyncDbCellKey.habitUUID} = ?");

    return sql.toString();
  }

  /// required arguments: [habitUUIDList]
  static String increaseMultiHabitsSyncDirtySql(
      {required int count, ConflictAlgorithm? conflictAlgorithm}) {
    final sql = StringBuffer();
    sql.write("UPDATE");
    if (conflictAlgorithm != null) {
      sql
        ..write(" ")
        ..write(buildConflictAlgorithm(conflictAlgorithm));
    }
    sql
      ..write(" ${TableName.sync}")
      ..write(" SET ${SyncDbCellKey.dirty} = ${SyncDbCellKey.dirty} + 1")
      ..write(" WHERE ${SyncDbCellKey.habitUUID}")
      ..write(" IN (${List.generate(count, (index) => '?').join(', ')})");

    return sql.toString();
  }
}
