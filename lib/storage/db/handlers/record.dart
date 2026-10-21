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

import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../common/types.dart';
import '../db_cell.dart';
import '../db_helper.dart';
import '../sql.dart';
import '../table.dart';
import 'habit.dart';
import 'sync.dart';

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
  static const String isDeleted = 'is_deleted';
  static const String syncExtras = 'sync_extras';
}

/// Converts the record deletion marker between domain and SQLite values.
final class RecordDeletionCodec extends Codec<bool, int> {
  const RecordDeletionCodec();

  @override
  Converter<int, bool> get decoder => const _RecordDeletionDecoder();

  @override
  Converter<bool, int> get encoder => const _RecordDeletionEncoder();
}

final class _RecordDeletionDecoder extends Converter<int, bool> {
  const _RecordDeletionDecoder();

  @override
  bool convert(int input) => input == 1;
}

final class _RecordDeletionEncoder extends Converter<bool, int> {
  const _RecordDeletionEncoder();

  @override
  int convert(bool input) => input ? 1 : 0;
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
  final String? reason;
  @JsonKey(name: RecordDBCellKey.isDeleted)
  final int? isDeleted;
  @JsonKey(name: RecordDBCellKey.syncExtras)
  final String? syncExtras;

  RecordDBCell({
    this.id,
    this.parentId,
    this.recordDate,
    this.recordType,
    this.recordValue,
    this.createT,
    this.modifyT,
    this.uuid,
    this.parentUUID,
    this.reason,
    this.isDeleted,
    this.syncExtras,
  });

  RecordDBCell.build({
    required this.parentId,
    required this.parentUUID,
    required this.recordDate,
    required this.recordType,
    required this.recordValue,
    this.createT,
    this.modifyT,
    this.uuid,
    this.reason,
    this.isDeleted,
    this.syncExtras,
  }) : id = null;

  factory RecordDBCell.fromJson(Map<String, Object?> cell) =>
      _$RecordDBCellFromJson(cell);

  @override
  Map<String, Object?> toJson() => _$RecordDBCellToJson(this);
}

extension RecordDBCellDeletion on RecordDBCell {
  bool get deleted => const RecordDeletionCodec().decode(isDeleted ?? 0);
}

class RecordDBHelper extends DBHelperHandler {
  const RecordDBHelper(super.helper);

  @override
  String get table => TableName.records;

  String get habitTable => TableName.habits;

  String get syncTable => TableName.sync;

  /// Reads the current habit, record and sync revision under the same write
  /// transaction as the mutation. The resolver may return null for a stale action.
  /// All writes use the ordinary record/sync transaction helpers below.
  Future<RecordDBCell?> mutateCurrentHabitRecord({
    required HabitUUID habitUUID,
    required int epochDay,
    required RecordDBCell? Function(
      HabitDBCell habit,
      RecordDBCell? record,
      SyncDBCell? sync,
    )
    resolve,
  }) => db.transaction((txn) async {
    final habits = await txn.query(
      habitTable,
      where: '${HabitDBCellKey.uuid} = ?',
      whereArgs: [habitUUID],
      limit: 1,
    );
    if (habits.isEmpty) return null;
    final rows = await txn.query(
      table,
      where:
          '${RecordDBCellKey.parentUUID} = ? AND '
          '${RecordDBCellKey.recordDate} = ?',
      whereArgs: [habitUUID, epochDay],
      limit: 1,
    );
    final current = rows.isEmpty ? null : RecordDBCell.fromJson(rows.single);
    final syncRows = current == null
        ? const <Map<String, Object?>>[]
        : await txn.query(
            syncTable,
            where: '${SyncDbCellKey.recordUUID} = ?',
            whereArgs: [current.uuid],
            limit: 1,
          );
    final changed = resolve(
      HabitDBCell.fromJson(habits.single),
      current,
      syncRows.isEmpty ? null : SyncDBCell.fromJson(syncRows.single),
    );
    if (changed == null) return null;
    if (current == null) {
      await _insertNewRecordTransaction(changed, txn);
    } else {
      await _updateRecordTransaction(changed, txn);
    }
    return changed;
  });

  /// A coherent display read while another engine may be changing records.
  Future<
    ({
      List<HabitDBCell> habits,
      List<RecordDBCell> records,
      Map<String, SyncDBCell> recordSync,
    })
  >
  loadHabitsAndRecordsInDateRange({
    required int fromEpochDay,
    required int toEpochDay,
  }) => db.transaction((txn) async {
    final habits = await txn.query(habitTable);
    final records = await txn.query(
      table,
      where:
          '${RecordDBCellKey.recordDate} >= ? AND '
          '${RecordDBCellKey.recordDate} <= ?',
      whereArgs: [fromEpochDay, toEpochDay],
    );
    final syncRows = await txn.rawQuery(
      'SELECT $syncTable.* FROM $syncTable '
      'JOIN $table ON $syncTable.${SyncDbCellKey.recordUUID} '
      '= $table.${RecordDBCellKey.uuid} '
      'WHERE $table.${RecordDBCellKey.recordDate} >= ? '
      'AND $table.${RecordDBCellKey.recordDate} <= ?',
      [fromEpochDay, toEpochDay],
    );
    return (
      habits: habits.map(HabitDBCell.fromJson).toList(growable: false),
      records: records.map(RecordDBCell.fromJson).toList(growable: false),
      recordSync: {
        for (final row in syncRows)
          row[SyncDbCellKey.recordUUID]! as String: SyncDBCell.fromJson(row),
      },
    );
  });

  Future<int> insertNewRecord(RecordDBCell record) {
    assert(record.uuid != null);

    return db.transaction((db) => _insertNewRecordTransaction(record, db));
  }

  Future<int> _insertNewRecordTransaction(
    RecordDBCell record,
    Transaction txn,
  ) async {
    final result = await txn.insert(
      table,
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (result > 0) {
      await Future.wait([
        txn.insert(
          syncTable,
          SyncDBCell.genFromRecord(record).toJson(),
          conflictAlgorithm: ConflictAlgorithm.rollback,
        ),
        txn.rawUpdate(
          CustomSql.increaseHabitSyncTotalDirtySql(
            conflictAlgorithm: ConflictAlgorithm.rollback,
          ),
          [record.parentUUID],
        ),
      ]);
    }
    return result;
  }

  Future<void> insertOrUpdateMultiRecords(Iterable<RecordDBCell> records) {
    return db.transaction((db) async {
      final tasks = <Future>[];
      for (var record in records) {
        tasks.add(
          db
              .query(
                table,
                where: "${RecordDBCellKey.uuid} = ?",
                whereArgs: [record.uuid],
                limit: 1,
              )
              .then(
                (result) => result.isEmpty
                    ? _insertNewRecordTransaction(record, db)
                    : _updateRecordTransaction(record, db),
              ),
        );
      }

      await Future.wait(tasks);
    });
  }

  Future<int> updateRecord(RecordDBCell record) {
    assert(record.uuid != null);

    return db.transaction((db) => _updateRecordTransaction(record, db));
  }

  Future<int> _updateRecordTransaction(
    RecordDBCell record,
    Transaction txn,
  ) async {
    final result = await txn.update(
      table,
      record.toJson(),
      where: '${RecordDBCellKey.uuid} = ?',
      whereArgs: [record.uuid],
    );
    if (result > 0) {
      await Future.wait([
        txn.rawUpdate(
          CustomSql.increaseRecordSyncDirtySql(
            conflictAlgorithm: ConflictAlgorithm.rollback,
          ),
          [record.uuid],
        ),
        txn.rawUpdate(
          CustomSql.increaseHabitSyncTotalDirtySql(
            conflictAlgorithm: ConflictAlgorithm.rollback,
          ),
          [record.parentUUID],
        ),
      ]);
    }
    return result;
  }

  static const _loadRecordDataColumns = [
    RecordDBCellKey.parentUUID,
    RecordDBCellKey.uuid,
    RecordDBCellKey.recordDate,
    RecordDBCellKey.recordType,
    RecordDBCellKey.recordValue,
    RecordDBCellKey.isDeleted,
  ];

  Future<Iterable<RecordDBCell>> loadRecords(HabitUUID uuid) async {
    final sql =
        """
SELECT ${_loadRecordDataColumns.map((e) => '$table.$e').join(', ')}
FROM $table
JOIN $habitTable
  ON $table.${RecordDBCellKey.parentUUID}
        = $habitTable.${HabitDBCellKey.uuid}
WHERE $table.${RecordDBCellKey.recordDate}
        >= $habitTable.${HabitDBCellKey.startDate}
  AND
      $table.${RecordDBCellKey.parentUUID} = ?;
""";
    final results = await db.rawQuery(sql, [uuid]);
    return results.map(RecordDBCell.fromJson);
  }

  Future<RecordDBCell?> loadSingleRecord(HabitRecordUUID uuid) async {
    final results = await db.query(
      table,
      where: "${RecordDBCellKey.uuid} = ?",
      whereArgs: [uuid],
    );
    return results.isEmpty ? null : RecordDBCell.fromJson(results.first);
  }

  static const _loadAllRecordDataColumns = [
    RecordDBCellKey.parentUUID,
    RecordDBCellKey.uuid,
    RecordDBCellKey.recordDate,
    RecordDBCellKey.recordType,
    RecordDBCellKey.recordValue,
    RecordDBCellKey.isDeleted,
  ];

  Future<Iterable<RecordDBCell>> loadAllRecords({
    List<HabitUUID>? uuidFilter,
  }) async {
    if (uuidFilter != null) {
      return _loadRecords(uuidFilter);
    }
    return _loadAllRecords();
  }

  Future<Iterable<RecordDBCell>> _loadAllRecords() async {
    final results = await db.query(table, columns: _loadAllRecordDataColumns);
    return results.map(RecordDBCell.fromJson);
  }

  Future<Iterable<RecordDBCell>> _loadRecords(List<HabitUUID> uuidList) async {
    final results = await db.query(
      table,
      where:
          "${RecordDBCellKey.parentUUID} "
          "IN (${uuidList.map((e) => '?').join(', ')}) ",
      whereArgs: uuidList,
      columns: _loadAllRecordDataColumns,
    );
    return results.map(RecordDBCell.fromJson);
  }

  Future<Iterable<RecordDBCell>> loadRecordsExportData(
    List<HabitUUID> uuidList,
  ) async {
    if (uuidList.isEmpty) return const [];

    final results = await db.query(
      table,
      where:
          "${RecordDBCellKey.parentUUID} "
          "IN (${uuidList.map((e) => '?').join(', ')})",
      whereArgs: uuidList,
    );
    return results.map(RecordDBCell.fromJson);
  }

  Future<Iterable<RecordDBCell>> loadAllRecordsExportData() async {
    final results = await db.query(table);
    return results.map(RecordDBCell.fromJson);
  }
}
