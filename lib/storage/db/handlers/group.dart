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

import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';

import '../../../common/types.dart';
import '../../../models/group.dart';
import '../db_helper.dart';
import '../sql.dart';
import '../table.dart';
import 'sync.dart';

class GroupDBHelper extends DBHelperHandler {
  const GroupDBHelper(super.helper);

  @override
  String get table => TableName.groups;

  Future<int> insertNewGroup(GroupDBCell group) {
    assert(group.uuid != null);

    return db.transaction((db) async {
      final result = await db.insert(table, group.toJson());
      if (result > 0) {
        await db.insert(
          TableName.sync,
          SyncDBCell.genFromGroup(group).toJson(),
        );
      }
      return result;
    });
  }

  Future<int> updateExistGroup(GroupDBCell group) {
    assert(group.uuid != null);

    return db.transaction((db) async {
      final result = await db.update(
        table,
        group.toJson(),
        where: "${GroupDBCellKey.uuid} = ?",
        whereArgs: [group.uuid],
      );
      if (result == 0) return result;

      final syncRows = await db.rawUpdate(
        CustomSql.increaseGroupSyncDirtySql(),
        [group.uuid],
      );
      if (syncRows == 0) {
        throw StateError('Missing sync row for group uuid: ${group.uuid}');
      }
      return result;
    });
  }

  /// Soft delete: sets status = 2.
  ///
  /// Associated habits keep [groupId] unchanged so a future restore
  /// (status ← 1) automatically reattaches them without data loss.
  Future<int> deleteGroup(String uuid) {
    return db.transaction((db) async {
      final result = await db.update(
        table,
        {GroupDBCellKey.status: 2},
        where: "${GroupDBCellKey.uuid} = ?",
        whereArgs: [uuid],
      );
      if (result == 0) return result;

      final syncRows = await db.rawUpdate(
        CustomSql.increaseGroupSyncDirtySql(),
        [uuid],
      );
      if (syncRows == 0) {
        throw StateError('Missing sync row for group uuid: $uuid');
      }
      return result;
    });
  }

  /// Batch-update group status for all [uuids] in a single exclusive
  /// transaction. Use [status] = 2 for soft-delete, 1 for restore.
  Future<void> updateGroupsStatus(List<String> uuids, int status) async {
    if (uuids.isEmpty) return;
    await db.transaction((db) async {
      final batch = db.batch();
      for (final uuid in uuids) {
        batch.update(
          table,
          {GroupDBCellKey.status: status},
          where: "${GroupDBCellKey.uuid} = ?",
          whereArgs: [uuid],
        );
      }
      batch.rawUpdate(
        CustomSql.increaseMultiGroupsSyncDirtySql(
          count: uuids.length,
          conflictAlgorithm: ConflictAlgorithm.rollback,
        ),
        uuids,
      );
      await batch.commit();
    }, exclusive: true);
  }

  Future<List<GroupDBCell>> loadAllActiveGroups() async {
    final result = await db.query(
      table,
      where: "${GroupDBCellKey.status} = ?",
      whereArgs: [1],
      orderBy: "${GroupDBCellKey.createT} ASC",
    );
    return result.map(GroupDBCell.fromJson).toList();
  }

  Future<GroupDBCell?> loadGroupByUUID(String uuid) async {
    final result = await db.query(
      table,
      where: "${GroupDBCellKey.uuid} = ?",
      whereArgs: [uuid],
    );
    if (result.isEmpty) return null;
    return GroupDBCell.fromJson(result.first);
  }

  /// Batch-updates [GroupDBCellKey.sortPosition] for the given groups.
  ///
  /// [uuidList] and [posList] must have the same length.
  /// Each row also bumps the sync dirty flag.
  Future<void> updateSelectedGroupsSortPosition(
    List<String> uuidList,
    List<GroupSortPosition> posList,
  ) async {
    assert(uuidList.length == posList.length, true);

    db.transaction((db) async {
      final batch = db.batch();
      uuidList.forEachIndexed((index, uuid) {
        batch.update(
          table,
          {GroupDBCellKey.sortPosition: posList[index]},
          where: "${GroupDBCellKey.uuid} = ?",
          whereArgs: [uuid],
          conflictAlgorithm: ConflictAlgorithm.rollback,
        );
      });
      batch.rawUpdate(
        CustomSql.increaseMultiGroupsSyncDirtySql(
          count: uuidList.length,
          conflictAlgorithm: ConflictAlgorithm.rollback,
        ),
        uuidList,
      );
      await batch.commit();
    }, exclusive: true);
  }
}
