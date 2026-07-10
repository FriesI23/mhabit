// Copyright 2026 Fries_I23
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

import '../../../common/types.dart';
import '../../../models/app_sync_tasks.dart';
import '../../../models/group.dart';
import '../db_helper.dart';
import '../table.dart';
import 'sync.dart';

/// Group-specific sync DB operations.
///
/// Composed into [SyncDBHelper] via the Strangler Pattern; callers currently
/// go through [SyncDBHelper] delegation wrappers.
class SyncGroupDBHelper {
  final DBHelper helper;

  const SyncGroupDBHelper(this.helper);

  Database get db => helper.db;

  static const _loadAllGroupsSyncInfoColumns = [
    SyncDbCellKey.id,
    SyncDbCellKey.groupUUID,
    SyncDbCellKey.lastConfigUUID,
    SyncDbCellKey.lastMark,
    SyncDbCellKey.lastMark2,
    SyncDbCellKey.dirty,
    SyncDbCellKey.dirtyTotal,
  ];

  Future<Iterable<SyncDBCell>> loadAllGroupsSyncInfo({
    List<String> columns = _loadAllGroupsSyncInfoColumns,
  }) async {
    final result = await db.query(
      TableName.sync,
      distinct: true,
      columns: columns,
      where: '${SyncDbCellKey.groupUUID} IS NOT NULL',
    );
    return result.map(SyncDBCell.fromJson);
  }

  Future<bool> syncGroupDataToDb(
    WebDavSyncGroupData data, {
    String? configId,
    String? sessionId,
  }) {
    final uuid = data.uuid;
    if (uuid == null) return Future.value(false);

    return helper.db.transaction((txn) async {
      final existingSync = await txn.query(
        TableName.sync,
        columns: [SyncDbCellKey.id, SyncDbCellKey.lastMark2],
        where: '${SyncDbCellKey.groupUUID} = ?',
        whereArgs: [uuid],
      );

      if (existingSync.isEmpty) {
        await txn.insert(TableName.groups, data.toGroupDBCell().toJson());
        await txn.insert(
          TableName.sync,
          data.genSyncDBCell(configId: configId).toJson(),
        );
      } else {
        final syncId = existingSync.first[SyncDbCellKey.id] as int;
        final localEtag =
            existingSync.first[SyncDbCellKey.lastMark2] as String?;
        if ((localEtag ?? '').isNotEmpty && localEtag == data.etag) {
          return true;
        }
        await txn.update(
          TableName.groups,
          data.toGroupDBCell().toJson(),
          where: '${GroupDBCellKey.uuid} = ?',
          whereArgs: [uuid],
        );
        final syncCell = data.genSyncDBCell(configId: configId);
        await txn.update(
          TableName.sync,
          syncCell.toJson(),
          where: '${SyncDbCellKey.id} = ?',
          whereArgs: [syncId],
        );
      }
      return true;
    });
  }

  Future<WebDavSyncGroupData?> loadGroupDataFromDb(
    HabitUUID uuid, {
    required String? configId,
    required String? sessionId,
  }) async {
    const tNameGroups = TableName.groups;
    const tNameSync = TableName.sync;
    const dirtyKey = '${tNameGroups}_${SyncDbCellKey.dirty}';
    const lastMarkKey = '${tNameGroups}_${SyncDbCellKey.lastMark}';
    const dirtyTotalKey = '${tNameGroups}_${SyncDbCellKey.dirtyTotal}';
    const configIdKey = '${tNameGroups}_${SyncDbCellKey.lastConfigUUID}';
    const lastMark2Key = '${tNameGroups}_${SyncDbCellKey.lastMark2}';

    final result = await db.rawQuery(
      '''
      SELECT g.*,
        s.${SyncDbCellKey.dirty} AS $dirtyKey,
        s.${SyncDbCellKey.dirtyTotal} AS $dirtyTotalKey,
        s.${SyncDbCellKey.lastMark} AS $lastMarkKey,
        s.${SyncDbCellKey.lastConfigUUID} AS $configIdKey,
        s.${SyncDbCellKey.lastMark2} AS $lastMark2Key
      FROM $tNameGroups g
      INNER JOIN $tNameSync s ON s.${SyncDbCellKey.groupUUID} = g.${GroupDBCellKey.uuid}
      WHERE g.${GroupDBCellKey.uuid} = ?
    ''',
      [uuid],
    );

    if (result.isEmpty) return null;

    final cell = GroupDBCell.fromJson(result.first);
    final syncDirty = result.first[dirtyKey] as int?;
    final syncDirtyTotal = result.first[dirtyTotalKey] as int?;
    final syncSessionId = result.first[lastMarkKey] as String?;
    final syncEtag = result.first[lastMark2Key] as String?;
    final loadedConfigId = result.first[configIdKey] as String?;

    return WebDavSyncGroupData.fromGroupDBCell(
      cell,
      dirty: syncDirty,
      dirtyTotal: syncDirtyTotal,
      sessionId: ((syncDirty ?? 0) > 0 || loadedConfigId != configId)
          ? sessionId
          : syncSessionId,
      etag: syncEtag,
    );
  }

  Future<void> clearGroupDirtyMark(
    WebDavSyncGroupData data, {
    String? etag,
    String? configId,
    String? sessionId,
  }) async {
    assert(data.dirty != null);
    assert(data.dirtyTotal != null);
    final groupDirty = data.dirty!;
    final groupDirtyTotal = data.dirtyTotal!;
    await db.rawUpdate(
      "UPDATE ${TableName.sync} "
      "SET ${SyncDbCellKey.dirty} = "
      "CASE "
      "WHEN ${SyncDbCellKey.dirty} = ? THEN 0 "
      "ELSE MAX(1, ${SyncDbCellKey.dirty} - ?) "
      "END "
      ", ${SyncDbCellKey.dirtyTotal} = "
      "CASE "
      "WHEN ${SyncDbCellKey.dirtyTotal} = ? THEN 0 "
      "ELSE MAX(1, ${SyncDbCellKey.dirtyTotal} - ?) "
      "END "
      ", ${SyncDbCellKey.lastMark2} = ?"
      "${configId != null ? ', ${SyncDbCellKey.lastConfigUUID} = ?' : ''}"
      "${sessionId != null ? ', ${SyncDbCellKey.lastSesionUUID} = ?' : ''}"
      " WHERE ${SyncDbCellKey.groupUUID} = ?",
      [
        groupDirty,
        groupDirty,
        groupDirtyTotal,
        groupDirtyTotal,
        etag,
        ?configId,
        ?sessionId,
        data.uuid,
      ],
    );
  }
}
