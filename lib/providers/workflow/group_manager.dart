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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../common/utils.dart';
import '../../models/group.dart';
import '../../providers/support/commons.dart';
import '../../storage/db_helper_provider.dart';

/// Manages Group CRUD at the business-logic layer.
///
/// Sync writes to mh_sync are deferred to Parse 2.
class GroupManager extends ChangeNotifier
    with DBHelperLoadedMixin
    implements ProviderMounted {
  List<GroupDBCell> _groups = [];
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  List<GroupDBCell> get groups => List.unmodifiable(_groups);

  Future<void> loadGroups() async {
    _groups = await groupDBHelper.loadAllActiveGroups();
    notifyListeners();
  }

  Future<GroupDBCell> createGroup({
    required String name,
    String? desc,
    int? icon,
    int? color,
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
      color: color,
      status: 1,
    );
    await groupDBHelper.insertNewGroup(cell);
    await loadGroups();
    return cell;
  }

  Future<void> updateGroup(GroupDBCell group) async {
    await groupDBHelper.updateExistGroup(group);
    await loadGroups();
  }

  Future<void> deleteGroup(String uuid) async {
    await groupDBHelper.deleteGroup(uuid);
    await loadGroups();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }
}
