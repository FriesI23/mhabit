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
import 'package:sqflite/sqflite.dart';

import '../../common/types.dart';
import '../db.dart';
import 'habits.dart';

part 'records.g.dart';

const String dbRecordsTableName = 'mh_records';

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
class RecordDBCell implements DBCellBase {
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

  factory RecordDBCell.fromMap(Map<String, Object?> cell) =>
      _$RecordDBCellFromJson(cell);

  @override
  Map<String, dynamic> toMap() => _$RecordDBCellToJson(this);

  @override
  String toString() {
    return "RecordDB${toMap().toString()}";
  }
}

Future<int> insertNewRecordCellToDB(RecordDBCell record) async {
  return await DB().db.insert(dbRecordsTableName, record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<Iterable<int>> insertMultiRecordsCellToDB(
    Iterable<RecordDBCell> records) async {
  Batch bath = DB().db.batch();
  for (var record in records) {
    bath.insert(dbRecordsTableName, record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  final result = await bath.commit(noResult: false);
  return result.map((e) => e as int);
}

Future<int> updateRecordDBCell(RecordDBCell record) async {
  assert(record.uuid != null);
  return await DB().db.update(dbRecordsTableName, record.toMap(),
      where: '${RecordDBCellKey.uuid} = ?',
      whereArgs: [record.uuid],
      conflictAlgorithm: ConflictAlgorithm.rollback);
}

const _loadRecordDataColumns = [
  RecordDBCellKey.parentUUID,
  RecordDBCellKey.uuid,
  RecordDBCellKey.recordDate,
  RecordDBCellKey.recordType,
  RecordDBCellKey.recordValue,
];

Future<Iterable<RecordDBCell>> loadRecordDataFromDB(HabitUUID uuid) async {
  var sql = """
SELECT ${_loadRecordDataColumns.map((e) => '$dbRecordsTableName.$e').join(', ')}
FROM $dbRecordsTableName
JOIN $dbHabitsTableName
  ON $dbRecordsTableName.${RecordDBCellKey.parentUUID}
        = $dbHabitsTableName.${HabitDBCellKey.uuid}
WHERE $dbRecordsTableName.${RecordDBCellKey.recordDate}
        >= $dbHabitsTableName.${HabitDBCellKey.startDate}
  AND
      $dbRecordsTableName.${RecordDBCellKey.parentUUID} = "$uuid";
""";
  var result = await DB().db.rawQuery(sql);

  Iterable<RecordDBCell> iterResult() sync* {
    for (final cell in result) {
      yield RecordDBCell.fromMap(cell);
    }
  }

  return iterResult();
}

Future<RecordDBCell?> loadSingleRecordFromDB(HabitRecordUUID uuid) async {
  var result = await DB().db.query(dbRecordsTableName,
      where: "${RecordDBCellKey.uuid} = ?", whereArgs: [uuid]);
  if (result.isEmpty) return null;
  return RecordDBCell.fromMap(result.first);
}

const _loadAllRecordDataColumns = [
  RecordDBCellKey.parentUUID,
  RecordDBCellKey.uuid,
  RecordDBCellKey.recordDate,
  RecordDBCellKey.recordType,
  RecordDBCellKey.recordValue
];

Future<Iterable<RecordDBCell>> loadAllRecordDataFromDB() async {
  var result = await DB().db.query(
        dbRecordsTableName,
        columns: _loadAllRecordDataColumns,
      );

  Iterable<RecordDBCell> iterResult() sync* {
    for (final cell in result) {
      yield RecordDBCell.fromMap(cell);
    }
  }

  return iterResult();
}
