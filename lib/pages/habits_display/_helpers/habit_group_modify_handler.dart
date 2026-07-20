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

import '../../../common/types.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_summary.dart';

/// Information about a habit affected by a batch group modification.
class HabitGroupModifyItem {
  final HabitUUID uuid;
  final String name;
  final HabitColor? color;
  final GroupUUID? oldGroupId;

  const HabitGroupModifyItem({
    required this.uuid,
    required this.name,
    this.color,
    this.oldGroupId,
  });
}

/// Encapsulates the data-building logic for batch group modification.
///
/// Builds [affectedHabits] and [sourceGroups] from the selected habit data,
/// and provides [allAlreadyInTarget] to short-circuit no-op modifications.
/// Does **not** contain any UI or widget-construction calls.
class HabitGroupModifyHandler {
  final List<HabitSummaryData> selectedData;
  final String? Function(GroupUUID?) getGroupName;
  final GroupUUID? targetGroupId;
  final bool _isNewGroup;

  HabitGroupModifyHandler({
    required this.selectedData,
    required this.getGroupName,
    required this.targetGroupId,
  }) : _isNewGroup = false;

  /// For a group that has not yet been created.
  HabitGroupModifyHandler.forNewGroup({
    required this.selectedData,
    required this.getGroupName,
  }) : targetGroupId = null,
       _isNewGroup = true;

  /// Whether all selected habits are already in the target group
  /// (or already removed from any group, when target is `null`).
  bool get allAlreadyInTarget {
    if (_isNewGroup) return false;
    return affectedHabits.every((h) => h.oldGroupId == targetGroupId);
  }

  late final List<HabitGroupModifyItem> affectedHabits = _buildAffectedHabits();

  late final Map<String?, List<HabitGroupModifyItem>> sourceGroups =
      _buildSourceGroups();

  List<HabitGroupModifyItem> _buildAffectedHabits() {
    return [
      for (final data in selectedData)
        HabitGroupModifyItem(
          uuid: data.uuid,
          name: data.name,
          color: data.color,
          oldGroupId: data.groupId,
        ),
    ];
  }

  Map<String?, List<HabitGroupModifyItem>> _buildSourceGroups() {
    final result = <String?, List<HabitGroupModifyItem>>{};
    for (final info in affectedHabits) {
      if (info.oldGroupId != null && info.oldGroupId != targetGroupId) {
        final name = getGroupName(info.oldGroupId);
        result.putIfAbsent(name, () => []).add(info);
      }
    }
    return result;
  }
}
