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

import 'package:flutter/foundation.dart';

import '../../common/rules.dart';
import '../../common/types.dart';
import '../../common/utils.dart';
import '../../extensions/group_icon_extensions.dart';
import '../../logging/helper.dart';
import '../../models/group.dart';
import '../../models/group_export.dart';
import '../../models/group_import.dart';
import '../../models/habit_color.dart';
import '../../models/habit_group.dart';
import '../../storage/db_helper_provider.dart';

abstract interface class GroupExportAccess {
  Future<Iterable<GroupExportData>> loadGroupExportData();
}

abstract interface class GroupImportAccess {
  Future<Map<String, GroupUUID>> importGroupsData(Iterable<Object?> jsonData);

  int getImportGroupsCount(Iterable<Object?> jsonData);
}

/// Manages Group CRUD at the business-logic layer.
///
/// Stateless service — similar to [HabitsManager]. Callers own their own
/// cache (typically in a page ViewModel) and call [loadAllActiveGroups] when
/// they need current data.
///
/// Sync writes to mh_sync are deferred to Parse 2.
class GroupManager
    with DBHelperLoadedMixin
    implements GroupExportAccess, GroupImportAccess {
  Future<List<GroupDBCell>> loadAllActiveGroups() =>
      groupDBHelper.loadAllActiveGroups();

  /// Loads active groups as a [GroupCollection] domain snapshot.
  ///
  /// On [Exception], logs an error and returns `null` in release mode;
  /// in debug mode the exception propagates to the caller.
  Future<GroupCollection?> tryLoadGroupCollection() async {
    try {
      final cells = await loadAllActiveGroups();
      return GroupCollection.fromDBQueryResult(cells);
    } on Exception catch (e) {
      appLog.load.error("GroupManager.loadGroupCollection", ex: ["failed", e]);
      if (kDebugMode) rethrow;
      return null;
    }
  }

  Future<HabitGroupData> createGroup({
    required String name,
    String? desc,
    GroupIcon? icon,
    GroupColor? color,
  }) async {
    // Block empty or whitespace-only name
    if (name.trim().isEmpty) {
      throw ArgumentError('Group name must not be empty');
    }
    final safeName = groupNameRule.clamp(name);
    final safeDesc = desc != null ? groupDescRule.clamp(desc) : null;
    final uuid = genHabitUUID();
    final cell = GroupDBCell(
      uuid: uuid,
      name: safeName,
      desc: safeDesc,
      icon: icon?.iconData.codePoint,
      color: color?.dbColorType.dbCode,
      customColor: color?.dbCustomColor,
      customColorTinted: color?.dbCustomColorTinted,
      status: 1,
    );
    await groupDBHelper.insertNewGroup(cell);
    return HabitGroupData.fromDBQueryCell(cell);
  }

  Future<void> updateGroup(GroupDBCell group) async {
    await groupDBHelper.updateExistGroup(group);
  }

  /// Domain-level update for a group by [uuid].
  ///
  /// Converts domain types back to raw DB fields.  [GroupDBCell.toJson]
  /// always includes icon/color fields (including `null`) so that clearing
  /// a previously-set icon or color works correctly.
  Future<void> updateGroupData({
    required String uuid,
    required String name,
    String? desc,
    GroupIcon? icon,
    HabitColor? color,
  }) async {
    final safeName = groupNameRule.clamp(name);
    final rawDesc = (desc?.isEmpty ?? true) ? null : desc;
    final safeDesc = rawDesc != null ? groupDescRule.clamp(rawDesc) : null;
    await groupDBHelper.updateExistGroup(
      GroupDBCell(
        uuid: uuid,
        name: safeName,
        desc: safeDesc,
        icon: icon?.iconData.codePoint,
        color: color?.dbColorType.dbCode,
        customColor: color?.dbCustomColor,
        customColorTinted: color?.dbCustomColorTinted,
      ),
    );
  }

  Future<GroupDBCell?> loadGroupByUUID(String uuid) =>
      groupDBHelper.loadGroupByUUID(uuid);

  /// Loads a single group as a domain model by [uuid].
  Future<HabitGroupData?> loadGroupDataByUUID(String uuid) async {
    final cell = await loadGroupByUUID(uuid);
    return cell != null ? HabitGroupData.fromDBQueryCell(cell) : null;
  }

  /// Restores a soft-deleted group (sets status back to active).
  Future<void> restoreGroup(String uuid) async {
    final cell = await loadGroupByUUID(uuid);
    if (cell == null) return;
    await updateGroup(cell.copyWith(status: 1));
  }

  Future<void> deleteGroup(String uuid) async {
    await groupDBHelper.deleteGroup(uuid);
  }

  //#region import and export
  @override
  Future<Iterable<GroupExportData>> loadGroupExportData() async {
    final groups = await groupDBHelper.loadAllActiveGroups();
    return groups.map(GroupExportData.fromGroupDBCell);
  }

  @override
  Future<Map<String, GroupUUID>> importGroupsData(Iterable<Object?> jsonData) =>
      GroupImport(groupDBHelper, data: jsonData).importGroups();

  @override
  int getImportGroupsCount(Iterable<Object?> jsonData) =>
      GroupImport(groupDBHelper, data: jsonData).groupsCount;
  //#endregion
}
