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
import '../../../models/app_sync_tasks.dart';
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
  static const dirtyTotal = 'dirty_total';
  static const lastConfigUUID = 'last_config_uuid';
  static const lastSesionUUID = 'last_session_uuid';
  static const lastMark = 'last_mark';
  static const lastMark2 = 'last_mark_2';
}

/// More model design refs:
/// [Local](docs/webdav_sync_design.md#local)
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
  @JsonKey(name: SyncDbCellKey.dirtyTotal)
  final int? dirtyTotal;
  @JsonKey(name: SyncDbCellKey.lastConfigUUID)
  final String? lastConfigUUID;
  @JsonKey(name: SyncDbCellKey.lastSesionUUID)
  final String? lastSesionUUID;
  @JsonKey(name: SyncDbCellKey.lastMark)
  final String? lastMark;
  @JsonKey(name: SyncDbCellKey.lastMark2)
  final String? lastMark2;

  const SyncDBCell({
    this.id,
    this.createT,
    this.modifyT,
    this.habitUUID,
    this.recordUUID,
    this.dirty,
    this.dirtyTotal,
    this.lastConfigUUID,
    this.lastSesionUUID,
    this.lastMark,
    this.lastMark2,
  });

  factory SyncDBCell.genFromRecord(RecordDBCell cell) {
    assert(cell.uuid != null);
    return SyncDBCell(recordUUID: cell.uuid, dirty: 1);
  }

  factory SyncDBCell.genFromHabit(HabitDBCell cell) {
    assert(cell.uuid != null);
    return SyncDBCell(habitUUID: cell.uuid, dirty: 1, dirtyTotal: 1);
  }

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
    SyncDbCellKey.lastMark2,
    SyncDbCellKey.dirty,
    SyncDbCellKey.dirtyTotal,
  ];

  Future<Iterable<SyncDBCell>> loadAllHabitsSyncInfo({
    List<String> columns = _loadAllHabitsSyncInfoColumns,
  }) async {
    final result = await db.query(
      table,
      distinct: true,
      columns: columns,
      where: "${SyncDbCellKey.habitUUID} IS NOT NULL",
    );
    return result.map(SyncDBCell.fromJson);
  }

  Future<bool> syncHabitDataToDb(
    WebDavSyncHabitData data, {
    String? configId,
    String? sessionId,
  }) async {
    assert(data.uuid != null);
    const dbidKeyAlias = 'habitDBID';
    const tNameHabits = TableName.habits;
    const tNameSync = TableName.sync;

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db.info(
      "syncHabitDataToDb",
      ex: ["started", data, configId, sessionId],
    );
    return helper.db
        .transaction((db) async {
          final habitSyncInfoMap = await db
              .query(
                tNameSync,
                distinct: true,
                columns: const [
                  SyncDbCellKey.lastSesionUUID,
                  SyncDbCellKey.lastMark,
                  SyncDbCellKey.lastMark2,
                  "(SELECT ${HabitDBCellKey.id} FROM $tNameHabits "
                      "WHERE ${HabitDBCellKey.uuid} = "
                      "$tNameSync.${SyncDbCellKey.habitUUID}) AS $dbidKeyAlias",
                ],
                where: "${SyncDbCellKey.habitUUID} = ?",
                whereArgs: [habitUUID],
                limit: 1,
              )
              .then((results) => results.firstOrNull);
          if (habitSyncInfoMap == null) {
            return insertNewHabitDataToDbTransaction(
              db,
              data,
              configId: configId,
              sessionId: sessionId,
            );
          }

          final habitSyncInfo = SyncDBCell.fromJson(habitSyncInfoMap);
          final etag = habitSyncInfo.lastMark2;
          if ((etag ?? '').isNotEmpty && etag == data.etag) {
            appLog.db.debug(
              "[$sessionId] syncHabitDataToDb",
              ex: ["same etag", etag, data.etag, data, configId],
            );
            return true;
          }

          final dbid = habitSyncInfoMap[dbidKeyAlias]! as int;
          return updateHabitDataToDbTransaction(
            db,
            data,
            dbid,
            habitSyncInfo: habitSyncInfo,
            configId: configId,
            sessionId: sessionId,
          );
        }, exclusive: true)
        .whenComplete(() {
          appLog.db.info(
            "[$sessionId] syncHabitDataToDb",
            ex: ["complete", data, configId],
          );
        });
  }

  Future<bool> insertNewHabitDataToDbTransaction(
    Transaction db,
    WebDavSyncHabitData data, {
    String? configId,
    String? sessionId,
  }) async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db.debug(
      "[$sessionId] insertNewHabitDataToDbTransaction",
      ex: ["started", data, configId],
    );
    final DBID dbid = await db.insert(
      TableName.habits,
      data.toHabitDBCell().toJson(),
    );
    await db.insert(
      table,
      data
          .genSyncDBCell(configId: configId)
          .copyWith(lastSesionUUID: sessionId)
          .toJson(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    await batchInsertOrUpdateHabitRecordsToDbTransaction(
      db,
      data.records.values,
      dbid,
      habitUUID,
      configId: configId,
      sessionId: sessionId,
    );
    appLog.db.debug(
      "[$sessionId] insertNewHabitDataToDbTransaction",
      ex: ["complete", data, dbid, configId],
    );
    return true;
  }

  Future<bool> updateHabitDataToDbTransaction(
    Transaction db,
    WebDavSyncHabitData data,
    DBID dbid, {
    required SyncDBCell habitSyncInfo,
    String? configId,
    String? sessionId,
  }) async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return false;

    appLog.db.debug(
      "[$sessionId] updateHabitDataToDbTransaction",
      ex: ["started", data, dbid, configId, () => habitSyncInfo.toJson()],
    );
    await batchInsertOrUpdateHabitRecordsToDbTransaction(
      db,
      data.records.values,
      dbid,
      habitUUID,
      configId: configId,
      sessionId: sessionId,
    );

    int count = 0;
    int syncCount = 0;
    if (habitSyncInfo.lastMark != data.sessionId) {
      if (habitSyncInfo.lastSesionUUID != data.sessionId) {
        count += await db.update(
          TableName.habits,
          data.toHabitDBCell().copyWith(id: null, uuid: null).toJson(),
          where: "${HabitDBCellKey.uuid} = ?",
          whereArgs: [habitUUID],
        );
      }
      syncCount += await db.update(
        table,
        data
            .genSyncDBCell(configId: configId)
            .copyWith(
              id: null,
              habitUUID: null,
              recordUUID: null,
              dirty: null,
              dirtyTotal: null,
              lastSesionUUID: sessionId,
            )
            .toJson(),
        where: "${SyncDbCellKey.habitUUID} = ?",
        whereArgs: [habitUUID],
      );
    } else {
      await db.update(
        table,
        data
            .genSyncDBCell(configId: configId)
            .copyWith(
              id: null,
              habitUUID: null,
              recordUUID: null,
              dirty: null,
              dirtyTotal: null,
              lastMark: null,
              lastSesionUUID: sessionId,
            )
            .toJson(),
        where: "${SyncDbCellKey.habitUUID} = ?",
        whereArgs: [habitUUID],
      );
    }
    appLog.db.debug(
      "[$sessionId] updateHabitDataToDbTransaction",
      ex: [
        "complete",
        "<$count,$syncCount>",
        data,
        dbid,
        configId,
        () => habitSyncInfo.toJson(),
      ],
    );

    return true;
  }

  Future<void> batchInsertOrUpdateHabitRecordsToDbTransaction(
    Transaction db,
    Iterable<WebDavSyncRecordData> records,
    DBID parentId,
    HabitUUID parentUUID, {
    String? configId,
    String? sessionId,
  }) async {
    final filteredRecordList = records
        .where((e) => e.uuid != null && e.parentUUID == parentUUID)
        .toList();
    appLog.db.debug(
      "[$sessionId] batchInsertOrUpdateHabitRecordsToDbTransaction",
      ex: [
        "started",
        records,
        filteredRecordList,
        parentId,
        parentUUID,
        configId,
      ],
    );
    if (filteredRecordList.isEmpty) return;

    final localSyncRecordsInfoMap = await db
        .query(
          table,
          distinct: true,
          columns: const [
            SyncDbCellKey.recordUUID,
            SyncDbCellKey.lastMark,
            SyncDbCellKey.lastSesionUUID,
          ],
          where:
              "${SyncDbCellKey.recordUUID} "
              "IN (${filteredRecordList.map((e) => '?').join(', ')})",
          whereArgs: filteredRecordList
              .map((e) => e.uuid)
              .toList(growable: false),
        )
        .then(
          (results) => Map.fromEntries(
            results
                .map(SyncDBCell.fromJson)
                .map((e) => MapEntry(e.recordUUID, e)),
          ),
        );
    appLog.db.debug(
      "batchInsertOrUpdateHabitRecordsToDbTransaction",
      ex: [
        "query local sync records infos",
        filteredRecordList,
        localSyncRecordsInfoMap,
        configId,
        sessionId,
      ],
    );

    // Ensure the conditions in both loops stay consistent to avoid mismatches
    // during insert/update operations.
    //
    // batch-loop-1: update record table's data
    int insertCount = 0;
    int updateCount = 0;
    final batch = db.batch();
    for (var record in filteredRecordList) {
      final recordSyncInfo = localSyncRecordsInfoMap[record.uuid];
      if (!localSyncRecordsInfoMap.containsKey(record.uuid)) {
        insertCount += 1;
        batch.insert(
          TableName.records,
          record.toRecordDBCell().copyWith(parentId: parentId).toJson(),
          conflictAlgorithm: ConflictAlgorithm.rollback,
        );
      } else if (recordSyncInfo?.lastMark != record.sessionId) {
        if (recordSyncInfo?.lastSesionUUID == record.sessionId) continue;
        updateCount += 1;
        batch.update(
          TableName.records,
          record
              .toRecordDBCell()
              .copyWith(id: null, parentId: null, uuid: null, parentUUID: null)
              .toJson(),
          where: "${RecordDBCellKey.uuid} = ?",
          whereArgs: [record.uuid],
          conflictAlgorithm: ConflictAlgorithm.rollback,
        );
      }
    }
    int insertSyncCount = 0;
    int updateSyncCount = 0;
    // batch-loop-2: update sync table's data
    for (var record in filteredRecordList) {
      final recordSyncInfo = localSyncRecordsInfoMap[record.uuid];
      if (!localSyncRecordsInfoMap.containsKey(record.uuid)) {
        insertSyncCount += 1;
        batch.insert(
          table,
          record
              .genSyncDBCell(configId: configId)
              .copyWith(lastSesionUUID: sessionId)
              .toJson(),
          conflictAlgorithm: ConflictAlgorithm.rollback,
        );
      } else if (recordSyncInfo?.lastMark != record.sessionId) {
        updateSyncCount += 1;
        batch.update(
          table,
          record
              .genSyncDBCell(configId: configId)
              .copyWith(
                id: null,
                habitUUID: null,
                recordUUID: null,
                dirty: null,
                lastSesionUUID: sessionId,
              )
              .toJson(),
          where: "${SyncDbCellKey.recordUUID} = ?",
          whereArgs: [record.uuid],
          conflictAlgorithm: ConflictAlgorithm.rollback,
        );
      }
    }

    await batch.commit(noResult: true);
    appLog.db.debug(
      "batchInsertOrUpdateHabitRecordsToDbTransaction",
      ex: [
        "complete",
        filteredRecordList.length,
        "<$insertCount.$insertSyncCount>",
        "<$updateCount,$updateSyncCount>",
        configId,
        sessionId,
      ],
    );
    return;
  }

  Future<WebDavSyncHabitData?> loadHabitDataFromBb(
    HabitUUID uuid, {
    bool withRecords = true,
    required String? configId,
    required String? sessionId,
  }) {
    const tNameSync = TableName.sync;
    const tNameHabits = TableName.habits;
    const tNameRecords = TableName.records;
    const dirtyKey = '${tNameSync}_${SyncDbCellKey.dirty}';
    const lastMarkKey = '${tNameSync}_${SyncDbCellKey.lastMark}';
    const configIdKey = '${tNameSync}_${SyncDbCellKey.lastConfigUUID}';
    const dirtyTotalKey = '${tNameSync}_${SyncDbCellKey.dirtyTotal}';

    return db.transaction((db) async {
      final habit = await db
          .rawQuery(
            "SELECT DISTINCT $tNameHabits.*, "
            "$tNameSync.${SyncDbCellKey.dirty} AS $dirtyKey, "
            "$tNameSync.${SyncDbCellKey.dirtyTotal} AS $dirtyTotalKey, "
            "$tNameSync.${SyncDbCellKey.lastMark} AS $lastMarkKey, "
            "$tNameSync.${SyncDbCellKey.lastConfigUUID} AS $configIdKey "
            "FROM $tNameHabits "
            "JOIN $tNameSync ON $tNameHabits.${HabitDBCellKey.uuid} "
            "= $tNameSync.${SyncDbCellKey.habitUUID} "
            "WHERE $tNameHabits.${HabitDBCellKey.uuid} = ?",
            [uuid],
          )
          .then((results) {
            final result = results.firstOrNull;
            if (result == null) return null;
            final dirty = result[dirtyKey] as int?;
            final dirtyTotal = result[dirtyTotalKey] as int?;
            final lastMarkId = result[lastMarkKey] as String?;
            final lastConfigId = result[configIdKey] as String?;
            return WebDavSyncHabitData.fromHabitDBCell(
              HabitDBCell.fromJson(result),
              dirty: dirty,
              dirtyTotal: dirtyTotal,
              sessionId: ((dirty ?? 0) > 0 || lastConfigId != configId)
                  ? sessionId
                  : lastMarkId,
            );
          });
      if (!withRecords || habit == null) return habit;

      final records = await db
          .rawQuery(
            "SELECT DISTINCT $tNameRecords.*, "
            "$tNameSync.${SyncDbCellKey.dirty} AS $dirtyKey, "
            "$tNameSync.${SyncDbCellKey.lastMark} AS $lastMarkKey, "
            "$tNameSync.${SyncDbCellKey.lastConfigUUID} AS $configIdKey "
            "FROM $tNameRecords "
            "JOIN $tNameSync ON $tNameRecords.${RecordDBCellKey.uuid} "
            "= $tNameSync.${SyncDbCellKey.recordUUID} "
            "WHERE $tNameRecords.${RecordDBCellKey.parentUUID} = ?",
            [uuid],
          )
          .then(
            (results) => results.map((result) {
              final dirty = result[dirtyKey] as int?;
              final lastMarkId = result[lastMarkKey] as String?;
              final lastConfigId = result[configIdKey] as String?;
              return WebDavSyncRecordData.fromRecordDBCell(
                RecordDBCell.fromJson(result),
                dirty: dirty,
                sessionId: ((dirty ?? 0) > 0 || lastConfigId != configId)
                    ? sessionId
                    : lastMarkId,
              );
            }),
          );
      return habit.copyWith(
        records: Map.fromEntries(
          records
              .map((e) => e.uuid != null ? MapEntry(e.uuid!, e) : null)
              .nonNulls,
        ),
      );
    });
  }

  Future<void> clearHabitDirtyMark(
    WebDavSyncHabitData data, {
    String? etag,
    String? configId,
    String? sessionId,
  }) {
    assert(data.dirtyTotal != null);
    assert(data.dirty != null);
    assert(data.uuid != null);

    return db.transaction((db) async {
      await Future.wait(
        data.records.values.where((e) => e.uuid != null && (e.dirty ?? 0) > 0).map((
          e,
        ) {
          final recordDirty = e.dirty!;
          final recordUUID = e.uuid!;
          return db.rawUpdate(
            "UPDATE $table "
            "SET ${SyncDbCellKey.dirty} = "
            "CASE "
            "WHEN ${SyncDbCellKey.dirty} = ? THEN 0 "
            "ELSE MAX(1, ${SyncDbCellKey.dirty} - ?) "
            "END"
            "${configId != null ? ', ${SyncDbCellKey.lastConfigUUID} = ?' : ''}"
            "${sessionId != null ? ', ${SyncDbCellKey.lastSesionUUID} = ?' : ''}"
            " WHERE ${SyncDbCellKey.recordUUID} = ?",
            [
              recordDirty,
              recordDirty,
              if (configId != null) configId,
              if (sessionId != null) sessionId,
              recordUUID,
            ],
          );
        }),
      );

      final habitDirty = data.dirty;
      final habitDirtyTotal = data.dirtyTotal;
      final habitUUID = data.uuid;
      await db.rawUpdate(
        "UPDATE $table "
        "SET ${SyncDbCellKey.dirty} = "
        "CASE "
        "WHEN ${SyncDbCellKey.dirty} = ? THEN 0 "
        "ELSE MAX(1, ${SyncDbCellKey.dirty} - ?) "
        "END"
        ", ${SyncDbCellKey.dirtyTotal} = "
        "CASE "
        "WHEN ${SyncDbCellKey.dirtyTotal} = ? THEN 0 "
        "ELSE MAX(1, ${SyncDbCellKey.dirtyTotal} - ?) "
        "END"
        ", ${SyncDbCellKey.lastMark2} = ?"
        "${configId != null ? ', ${SyncDbCellKey.lastConfigUUID} = ?' : ''}"
        "${sessionId != null ? ', ${SyncDbCellKey.lastSesionUUID} = ?' : ''}"
        " WHERE ${SyncDbCellKey.habitUUID} = ?",
        [
          habitDirty,
          habitDirty,
          habitDirtyTotal,
          habitDirtyTotal,
          etag,
          if (configId != null) configId,
          if (sessionId != null) sessionId,
          habitUUID,
        ],
      );
    });
  }
}
