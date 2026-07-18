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

import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../storage/db/handlers/group.dart' show GroupDBHelper;
import 'group.dart';
import 'group_export.dart';

/// Imports Group data from a JSON export file.
///
/// Each group receives a new UUID (via [genHabitUUID]).
/// Returns a mapping from old UUID → new UUID so that
/// [HabitImport] can replace [groupId] references.
class GroupImport {
  final GroupDBHelper helper;
  final Iterable<Object?> _jsonData;

  const GroupImport(this.helper, {Iterable<Object?> data = const []})
    : _jsonData = data;

  int get groupsCount => _jsonData.length;

  /// Creates groups in the database with new UUIDs.
  ///
  /// Skips entries whose [GroupExportData.uuid] is null or empty,
  /// and entries whose [GroupExportData.name] is null or empty.
  ///
  /// Returns a mapping of old UUID → new UUID so that
  /// [HabitImport] can replace [groupId] references.
  /// The exported uuid is never written to the DB — it is only used
  /// for association.
  Future<Map<String, GroupUUID>> importGroups() async {
    final mapping = <String, GroupUUID>{};
    for (var json in _jsonData) {
      final group = GroupExportData.fromJson(json);
      final oldUuid = group.uuid;
      if (oldUuid == null || oldUuid.isEmpty) continue;
      if (group.name == null || group.name!.trim().isEmpty) continue;

      final newUuid = genHabitUUID();
      final cell = GroupDBCell(
        uuid: newUuid,
        name: group.name,
        desc: group.desc,
        icon: group.icon,
        color: group.color,
        customColor: group.customColor,
        customColorTinted: group.customColorTinted,
        status: 1,
      );

      try {
        await helper.insertNewGroup(cell);
        mapping[oldUuid] = newUuid;
      } on Exception catch (e) {
        appLog.import.error(
          '$runtimeType.importGroups',
          ex: ['Failed to import group', oldUuid],
          error: e,
        );
        // Continue importing remaining groups.
      }
    }
    return mapping;
  }
}
