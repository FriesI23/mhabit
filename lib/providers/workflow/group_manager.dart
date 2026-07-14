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

import '../../common/types.dart';
import '../../common/utils.dart';
import '../../models/group.dart';
import '../../storage/db_helper_provider.dart';

/// Manages Group CRUD at the business-logic layer.
///
/// Stateless service — similar to [HabitsManager]. Callers own their own
/// cache (typically in a page ViewModel) and call [loadAllActiveGroups] when
/// they need current data.
///
/// Sync writes to mh_sync are deferred to Parse 2.
class GroupManager with DBHelperLoadedMixin {
  Future<List<GroupDBCell>> loadAllActiveGroups() =>
      groupDBHelper.loadAllActiveGroups();

  Future<GroupDBCell> createGroup({
    required String name,
    String? desc,
    int? icon,
    GroupColor? color,
  }) async {
    // Block empty or whitespace-only name
    if (name.trim().isEmpty) {
      throw ArgumentError('Group name must not be empty');
    }
    final uuid = genHabitUUID();
    final cell = GroupDBCell(
      uuid: uuid,
      name: name,
      desc: desc,
      icon: icon,
      color: color?.dbColorType.dbCode,
      customColor: color?.dbCustomColor,
      customColorTinted: color?.dbCustomColorTinted,
      status: 1,
    );
    await groupDBHelper.insertNewGroup(cell);
    return cell;
  }

  Future<void> updateGroup(GroupDBCell group) async {
    await groupDBHelper.updateExistGroup(group);
  }

  Future<void> deleteGroup(String uuid) async {
    await groupDBHelper.deleteGroup(uuid);
  }
}
