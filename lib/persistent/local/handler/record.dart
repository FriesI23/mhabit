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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../common/types.dart';
import '../table.dart';
import '../db_cell.dart';
import '../db_helper.dart';
import 'habit.dart';

part 'record.g.dart';

class RecordDBCellKey {
  static const String id = 'id_';
  static const String parentId = 'parent_id';
  static const String recordDate = 'record_date';
  static const String recordType = 'record_type';
  static const String recordValue = 'record_value';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String uuid = 'uuid';
  static const String parentUUID = 'parent_uuid';
  static const String reason = 'reason';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class RecordDBCell with DBCell {
  @JsonKey(name: RecordDBCellKey.id)
  final DBID? id;
  @JsonKey(name: RecordDBCellKey.parentId)
  final DBID? parentId;
  @JsonKey(name: RecordDBCellKey.recordDate)
  final int? recordDate;
  @JsonKey(name: RecordDBCellKey.recordType)
  final int? recordType;
  @JsonKey(name: RecordDBCellKey.recordValue)
  final num? recordValue;
  @JsonKey(name: RecordDBCellKey.createT)
  final int? createT;
  @JsonKey(name: RecordDBCellKey.modifyT)
  final int? modifyT;
  @JsonKey(name: RecordDBCellKey.uuid)
  final HabitRecordUUID? uuid;
  @JsonKey(name: RecordDBCellKey.parentUUID)
  final HabitUUID? parentUUID;
  @JsonKey(name: RecordDBCellKey.reason)
  final HabitUUID? reason;

  RecordDBCell(
      {this.id,
      this.parentId,
      this.recordDate,
      this.recordType,
      this.recordValue,
      this.createT,
      this.modifyT,
      this.uuid,
      this.parentUUID,
      this.reason});

  factory RecordDBCell.fromJson(Map<String, Object?> cell) =>
      _$RecordDBCellFromJson(cell);

  @override
  Map<String, Object?> toJson() => _$RecordDBCellToJson(this);
}

class RecordDBHelper extends DBHelperHandler {
  RecordDBHelper(super.helper);

  @override
  String get table => TableName.records;

  String get habitTable => TableName.habits;

  Future<int> insertNewRecord(RecordDBCell record) {
    return db.insert(table, record.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Iterable<int>> insertMultiRecords(
      Iterable<RecordDBCell> records) async {
    final bath = db.batch();
    for (var record in records) {
      bath.insert(table, record.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    final result = await bath.commit(noResult: false);
    return result.map((e) => e as int);
  }

  Future<int> updateRecord(RecordDBCell record) {
    assert(record.uuid != null);

    return db.update(table, record.toJson(),
        where: '${RecordDBCellKey.uuid} = ?',
        whereArgs: [record.uuid],
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  static const _loadRecordDataColumns = [
    RecordDBCellKey.parentUUID,
    RecordDBCellKey.uuid,
    RecordDBCellKey.recordDate,
    RecordDBCellKey.recordType,
    RecordDBCellKey.recordValue,
  ];

  Future<Iterable<RecordDBCell>> loadRecords(HabitUUID uuid) async {
    final sql = """
SELECT ${_loadRecordDataColumns.map((e) => '$table.$e').join(', ')}
FROM $table
JOIN $habitTable
  ON $table.${RecordDBCellKey.parentUUID}
        = $habitTable.${HabitDBCellKey.uuid}
WHERE $table.${RecordDBCellKey.recordDate}
        >= $habitTable.${HabitDBCellKey.startDate}
  AND
      $table.${RecordDBCellKey.parentUUID} = "$uuid";
""";
    final results = await db.rawQuery(sql);
    return results.map((e) => RecordDBCell.fromJson(e));
  }

  Future<RecordDBCell?> loadSingleRecord(HabitRecordUUID uuid) async {
    final results = await db
        .query(table, where: "${RecordDBCellKey.uuid} = ?", whereArgs: [uuid]);
    return results.isEmpty ? null : RecordDBCell.fromJson(results.first);
  }

  static const _loadAllRecordDataColumns = [
    RecordDBCellKey.parentUUID,
    RecordDBCellKey.uuid,
    RecordDBCellKey.recordDate,
    RecordDBCellKey.recordType,
    RecordDBCellKey.recordValue
  ];

  Future<Iterable<RecordDBCell>> loadAllRecords() async {
    final results = await db.query(table, columns: _loadAllRecordDataColumns);
    return results.map((e) => RecordDBCell.fromJson(e));
  }

  Future<Iterable<RecordDBCell>> loadRecordsExportData(
      List<HabitUUID> uuidList) async {
    if (uuidList.isEmpty) return const [];

    final results = await db.query(table,
        where: "${RecordDBCellKey.parentUUID} "
            "IN (${uuidList.map((e) => '?').join(', ')})",
        whereArgs: uuidList);
    return results.map((e) => RecordDBCell.fromJson(e));
  }

  Future<Iterable<RecordDBCell>> loadAllRecordsExportData() async {
    final results = await db.query(table);
    return results.map((e) => RecordDBCell.fromJson(e));
  }
}
