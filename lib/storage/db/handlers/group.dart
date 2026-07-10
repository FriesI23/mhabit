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

import '../../../models/group.dart';
import '../db_helper.dart';
import '../table.dart';

class GroupDBHelper extends DBHelperHandler {
  const GroupDBHelper(super.helper);

  @override
  String get table => TableName.groups;

  Future<int> insertNewGroup(GroupDBCell group) async {
    assert(group.uuid != null);
    // Parse 1: no sync table write (deferred to Parse 2)
    return db.insert(table, group.toJson());
  }

  Future<int> updateExistGroup(GroupDBCell group) async {
    assert(group.uuid != null);
    return db.update(
      table,
      group.toJson(),
      where: "${GroupDBCellKey.uuid} = ?",
      whereArgs: [group.uuid],
    );
  }

  /// Soft delete: sets status = 2.
  Future<int> deleteGroup(String uuid) async {
    return db.update(
      table,
      {GroupDBCellKey.status: 2},
      where: "${GroupDBCellKey.uuid} = ?",
      whereArgs: [uuid],
    );
  }

  Future<List<GroupDBCell>> loadAllActiveGroups() async {
    final result = await db.query(
      table,
      where: "${GroupDBCellKey.status} = ?",
      whereArgs: [1],
      orderBy: "${GroupDBCellKey.sortOrder} ASC",
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
}
