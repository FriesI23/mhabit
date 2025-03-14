// Copyright 2025 Fries_I23
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

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../common/types.dart';
import '../../../logging/helper.dart';
import '../../../model/app_sync_task.dart';
import '../db_cell.dart';
import '../db_helper.dart';
import '../table.dart';
import 'habit.dart';
import 'record.dart';

part 'sync.g.dart';

class SyncDbCellKey {
  static const id = 'id_';
  static const createT = 'create_t';
  static const modifyT = 'modify_t';
  static const habitUUID = 'habit_uuid';
  static const recordUUID = 'record_uuid';
  static const dirty = 'dirty';
  static const lastConfigUUID = 'last_config_uuid';
  static const lastSesionUUID = 'last_session_uuid';
  static const lastMark = 'last_mark';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class SyncDBCell with DBCell {
  @JsonKey(name: SyncDbCellKey.id)
  final DBID? id;
  @JsonKey(name: SyncDbCellKey.createT)
  final int? createT;
  @JsonKey(name: SyncDbCellKey.modifyT)
  final int? modifyT;
  @JsonKey(name: SyncDbCellKey.habitUUID)
  final HabitUUID? habitUUID;
  @JsonKey(name: SyncDbCellKey.recordUUID)
  final HabitUUID? recordUUID;
  @JsonKey(name: SyncDbCellKey.dirty)
  final int? dirty;
  @JsonKey(name: SyncDbCellKey.lastConfigUUID)
  final String? lastConfigUUID;
  @JsonKey(name: SyncDbCellKey.lastSesionUUID)
  final String? lastSesionUUID;
  @JsonKey(name: SyncDbCellKey.lastMark)
  final String? lastMark;

  const SyncDBCell({
    this.id,
    this.createT,
    this.modifyT,
    this.habitUUID,
    this.recordUUID,
    this.dirty,
    this.lastConfigUUID,
    this.lastSesionUUID,
    this.lastMark,
  });

  SyncDBCell.genFromRecord(RecordDBCell cell)
      : this(recordUUID: cell.uuid, dirty: 1);

  SyncDBCell.genFromHabit(HabitDBCell cell)
      : this(habitUUID: cell.uuid, dirty: 1);

  factory SyncDBCell.fromJson(JsonMap cell) => _$SyncDBCellFromJson(cell);

  @override
  Map<String, Object?> toJson() => _$SyncDBCellToJson(this);
}

class SyncDBHelper extends DBHelperHandler {
  const SyncDBHelper(super.helper);

  @override
  String get table => TableName.sync;

  static const _loadAllHabitsSyncInfoColumns = [
    SyncDbCellKey.id,
    SyncDbCellKey.habitUUID,
    SyncDbCellKey.recordUUID,
    SyncDbCellKey.lastConfigUUID,
    SyncDbCellKey.lastMark,
    SyncDbCellKey.dirty,
  ];

  Future<Iterable<SyncDBCell>> loadAllHabitsSyncInfo(
      {List<String> columns = _loadAllHabitsSyncInfoColumns}) async {
    final result = await db.query(
      table,
      distinct: true,
      columns: columns,
      where: "${SyncDbCellKey.habitUUID} IS NOT NULL "
          "AND ${SyncDbCellKey.recordUUID} IS NULL",
    );
    return result.map(SyncDBCell.fromJson);
  }

  static const _loadHabitRecordsSyncInfoColumns = [
    SyncDbCellKey.id,
    SyncDbCellKey.habitUUID,
    SyncDbCellKey.recordUUID,
    SyncDbCellKey.lastConfigUUID,
    SyncDbCellKey.lastMark,
    SyncDbCellKey.dirty,
  ];

  Future<Iterable<SyncDBCell>> loadHabitRecordsSyncInfo(
      {required HabitUUID uuid,
      List<String> columns = _loadHabitRecordsSyncInfoColumns}) async {
    const tNameSync = TableName.sync;
    const tNameRrds = TableName.records;
    final selectIter =
        _loadHabitRecordsSyncInfoColumns.map((e) => "$tNameSync.$e");
    final result = await db.rawQuery(
        "SELECT DISTINCT ${selectIter.join(', ')} "
        "FROM $tNameSync "
        "JOIN $tNameRrds ON $tNameSync.${SyncDbCellKey.recordUUID} "
        "= $tNameRrds.${RecordDBCellKey.uuid} "
        "WHERE $tNameRrds.${RecordDBCellKey.parentId} == ? "
        "AND $tNameSync.${SyncDbCellKey.recordUUID} IS NOT NULL",
        [uuid]);
    return result.map(SyncDBCell.fromJson);
  }

  Future<bool> syncHabitDataToDb(WebDavSyncHabitData data,
      {String? configId, String? sessionId}) async {
    assert(data.uuid != null);
    const dbidKeyAlias = 'habitDBID';
    const tNameHabits = TableName.habits;
    const tNameSync = TableName.sync;

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db
        .info("syncHabitDataToDb", ex: ["started", data, configId, sessionId]);
    return helper.db.transaction((db) async {
      final habitSyncInfo = await db
          .query(tNameSync,
              distinct: true,
              columns: const [
                SyncDbCellKey.lastMark,
                "(SELECT ${HabitDBCellKey.id} FROM $tNameHabits "
                    "WHERE ${HabitDBCellKey.uuid} = "
                    "$tNameSync.${SyncDbCellKey.habitUUID}) AS $dbidKeyAlias"
              ],
              where: "${SyncDbCellKey.habitUUID} = ?",
              whereArgs: [habitUUID],
              limit: 1)
          .then((results) => results.firstOrNull);
      if (habitSyncInfo == null) {
        return insertNewHabitDataToDbTransaction(db, data,
            configId: configId, sessionId: sessionId);
      }
      final etag = habitSyncInfo[SyncDbCellKey.lastMark] as String?;
      if ((etag ?? '').isNotEmpty && etag == data.etag) {
        return true;
      }
      final dbid = habitSyncInfo[dbidKeyAlias]! as int;
      return updateHabitDataToDbTransaction(db, data, dbid,
          configId: configId, sessionId: sessionId);
    }, exclusive: true).whenComplete(() {
      appLog.db.info("syncHabitDataToDb",
          ex: ["complete", data, configId, sessionId]);
    });
  }

  Future<bool> insertNewHabitDataToDbTransaction(
      Transaction db, WebDavSyncHabitData data,
      {String? configId, String? sessionId}) async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db.debug("insertNewHabitDataToDbTransaction",
        ex: ["started", data, configId, sessionId]);
    final DBID dbid =
        await db.insert(TableName.habits, data.toHabitDBCell().toJson());
    await db.insert(table,
        data.genSyncDBCell(configId: configId, sessionId: sessionId).toJson(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
    await batchInsertOrUpdateHabitRecordsToDbTransaction(
        db, data.records, dbid, habitUUID,
        configId: configId, sessionId: sessionId);
    appLog.db.debug("insertNewHabitDataToDbTransaction",
        ex: ["complete", data, dbid, configId, sessionId]);
    return true;
  }

  Future<bool> updateHabitDataToDbTransaction(
      Transaction db, WebDavSyncHabitData data, DBID dbid,
      {String? configId, String? sessionId}) async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db.debug("updateHabitDataToDbTransaction",
        ex: ["started", data, dbid, configId, sessionId]);
    await batchInsertOrUpdateHabitRecordsToDbTransaction(
        db, data.records, dbid, habitUUID,
        configId: configId, sessionId: sessionId);
    await db.update(TableName.habits,
        data.toHabitDBCell().copyWith(id: null, uuid: null).toJson(),
        where: "${HabitDBCellKey.uuid} = ?", whereArgs: [habitUUID]);
    await db.update(
        table,
        data
            .genSyncDBCell(configId: configId, sessionId: sessionId)
            .copyWith(id: null, habitUUID: null, recordUUID: null, dirty: null)
            .toJson(),
        where: "${SyncDbCellKey.habitUUID} = ?",
        whereArgs: [habitUUID]);
    appLog.db.debug("updateHabitDataToDbTransaction",
        ex: ["complete", data, dbid, configId, sessionId]);
    return true;
  }

  Future<void> batchInsertOrUpdateHabitRecordsToDbTransaction(
      Transaction db,
      Iterable<WebDavSyncRecordData> records,
      DBID parentId,
      HabitUUID parentUUID,
      {String? configId,
      String? sessionId}) async {
    final filteredRecordList = records
        .where((e) => e.uuid != null && e.parentUUID == parentUUID)
        .toList();
    appLog.db.debug("batchInsertOrUpdateHabitRecordsToDbTransaction", ex: [
      "started",
      records,
      filteredRecordList,
      parentId,
      parentUUID,
      configId,
      sessionId
    ]);
    if (filteredRecordList.isEmpty) return;

    final localSyncRecordsInfoMap = await db
        .query(
          table,
          distinct: true,
          columns: [SyncDbCellKey.recordUUID, SyncDbCellKey.lastMark],
          where: "${SyncDbCellKey.recordUUID} "
              "IN (${filteredRecordList.map((e) => '?').join(', ')})",
          whereArgs:
              filteredRecordList.map((e) => e.uuid).toList(growable: false),
        )
        .then(
          (results) => Map.fromEntries(results
              .map(SyncDBCell.fromJson)
              .map((e) => MapEntry(e.recordUUID, e))),
        );
    appLog.db.debug("batchInsertOrUpdateHabitRecordsToDbTransaction", ex: [
      "query local sync records infos",
      filteredRecordList,
      localSyncRecordsInfoMap,
      configId,
      sessionId
    ]);

    // Ensure the conditions in both loops stay consistent to avoid mismatches
    // during insert/update operations.
    //
    // batch-loop-1: update record table's data
    final batch = db.batch();
    for (var record in filteredRecordList) {
      if (!localSyncRecordsInfoMap.containsKey(record.uuid)) {
        batch.insert(TableName.records,
            record.toRecordDBCell().copyWith(parentId: parentId).toJson(),
            conflictAlgorithm: ConflictAlgorithm.rollback);
      } else if (localSyncRecordsInfoMap[record.uuid]?.lastMark !=
          record.etag) {
        batch.update(
            TableName.records,
            record
                .toRecordDBCell()
                .copyWith(
                    id: null, parentId: null, uuid: null, parentUUID: null)
                .toJson(),
            where: "${RecordDBCellKey.uuid} = ?",
            whereArgs: [record.uuid],
            conflictAlgorithm: ConflictAlgorithm.rollback);
      }
    }
    // batch-loop-2: update sync table's data
    for (var record in filteredRecordList) {
      if (!localSyncRecordsInfoMap.containsKey(record.uuid)) {
        batch.insert(
            table,
            record
                .genSyncDBCell(configId: configId, sessionId: sessionId)
                .toJson(),
            conflictAlgorithm: ConflictAlgorithm.rollback);
      } else if (localSyncRecordsInfoMap[record.uuid]?.lastMark !=
          record.etag) {
        batch.update(
            table,
            record
                .genSyncDBCell(configId: configId, sessionId: sessionId)
                .copyWith(
                    id: null, habitUUID: null, recordUUID: null, dirty: null)
                .toJson(),
            where: "${SyncDbCellKey.recordUUID} = ?",
            whereArgs: [record.uuid],
            conflictAlgorithm: ConflictAlgorithm.rollback);
      }
    }

    await batch.commit(noResult: true);
    return;
  }

  Future<WebDavSyncHabitData?> loadDirtyHabitDataFromBb(HabitUUID uuid,
      {bool withRecords = true, required String? configId}) {
    const tNameSync = TableName.sync;
    const tNameHabits = TableName.habits;
    const tNameRecords = TableName.records;
    const dirtyKey = '$tNameSync\_${SyncDbCellKey.dirty}';
    const ph = "_NULL";

    return db.transaction((db) async {
      final habit = await db.rawQuery(
          "SELECT DISTINCT $tNameHabits.*, "
          "$tNameSync.${SyncDbCellKey.dirty} AS $dirtyKey "
          "FROM $tNameHabits "
          "JOIN $tNameSync ON $tNameHabits.${HabitDBCellKey.uuid} "
          "= $tNameSync.${SyncDbCellKey.habitUUID} "
          "WHERE $tNameHabits.${HabitDBCellKey.uuid} = ? "
          "AND ("
          "$tNameSync.${SyncDbCellKey.dirty} > 0 "
          "OR COALESCE($tNameSync.${SyncDbCellKey.lastConfigUUID}, '$ph') "
          "!= ? "
          ")",
          [uuid, configId ?? ph]).then((results) {
        final result = results.firstOrNull;
        return result != null
            ? WebDavSyncHabitData.fromHabitDBCell(HabitDBCell.fromJson(result),
                dirty: result[dirtyKey] as int?)
            : null;
      });
      if (!withRecords || habit == null) return habit;

      final records = await db.rawQuery(
          "SELECT DISTINCT $tNameRecords.*, "
          "$tNameSync.${SyncDbCellKey.dirty} AS $dirtyKey "
          "FROM $tNameRecords "
          "JOIN $tNameSync ON $tNameRecords.${RecordDBCellKey.uuid} "
          "= $tNameSync.${SyncDbCellKey.recordUUID} "
          "WHERE $tNameRecords.${RecordDBCellKey.parentUUID} = ? "
          "AND ("
          "$tNameSync.${SyncDbCellKey.dirty} > 0 "
          "OR COALESCE($tNameSync.${SyncDbCellKey.lastConfigUUID}, '$ph') "
          "!= ? "
          ")",
          [uuid, configId ?? ph]).then(
        (results) => results
            .map((result) => WebDavSyncRecordData.fromRecordDBCell(
                RecordDBCell.fromJson(result),
                dirty: result[dirtyKey] as int?))
            .toList(),
      );
      return habit.copyWith(records: records);
    });
  }

  Future<int> clearRecordDirtyMark(HabitRecordUUID uuid, int crtDirty,
      {String? etag, String? configId, String? sessionId}) {
    return db.rawUpdate(
      "UPDATE $table "
      "SET ${SyncDbCellKey.dirty} = "
      "CASE "
      "WHEN ${SyncDbCellKey.dirty} = ? THEN 0 "
      "ELSE MAX(1, ${SyncDbCellKey.dirty} - ?) "
      "END"
      "${etag != null ? ', ${SyncDbCellKey.lastMark} = ?' : ''}"
      "${configId != null ? ', ${SyncDbCellKey.lastConfigUUID} = ?' : ''}"
      "${sessionId != null ? ', ${SyncDbCellKey.lastSesionUUID} = ?' : ''}"
      " WHERE ${SyncDbCellKey.recordUUID} = ?",
      [
        crtDirty,
        crtDirty,
        if (etag != null) etag,
        if (configId != null) configId,
        if (sessionId != null) sessionId,
        uuid
      ],
    );
  }

  Future<int> clearHabitDirtyMark(HabitUUID uuid, int crtDirty,
      {String? etag, String? configId, String? sessionId}) {
    return db.rawUpdate(
      "UPDATE $table "
      "SET ${SyncDbCellKey.dirty} = "
      "CASE "
      "WHEN ${SyncDbCellKey.dirty} = ? THEN 0 "
      "ELSE MAX(1, ${SyncDbCellKey.dirty} - ?) "
      "END"
      "${etag != null ? ', ${SyncDbCellKey.lastMark} = ?' : ''}"
      "${configId != null ? ', ${SyncDbCellKey.lastConfigUUID} = ?' : ''}"
      "${sessionId != null ? ', ${SyncDbCellKey.lastSesionUUID} = ?' : ''}"
      " WHERE ${SyncDbCellKey.habitUUID} = ?",
      [
        crtDirty,
        crtDirty,
        if (etag != null) etag,
        if (configId != null) configId,
        if (sessionId != null) sessionId,
        uuid
      ],
    );
  }
}
