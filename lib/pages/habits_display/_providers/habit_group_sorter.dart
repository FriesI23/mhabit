// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../../../common/consts.dart';
import '../../../extensions/habit_group_extensions.dart';
import '../../../extensions/iterable_extensions.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../models/habit_summary.dart';

/// Builds a flat grouped sort-cache list from the given [data].
///
/// Habits are always grouped by their effective group ID in [groups]
/// (resolving orphan references to `null`). Groups are ordered according to
/// [groupType]:
/// - [HabitDisplayGroupType.name]: by group name, alphabetically.
/// - [HabitDisplayGroupType.colorType]: by each group's [HabitGroupData.color].
/// - [HabitDisplayGroupType.createDate]: by the order in [groups].
///
/// [groupDirection] controls the order direction for groups.
/// Within each group, habits are sorted by [sortType]/[sortDirection].
///
/// Groups with no habits are skipped. Collapsed groups (by
/// [collapsedUUIDs]) only emit the header, omitting their habit items.
List<HabitSortCache<dynamic>> buildGroupedSortCacheList({
  required HabitSummaryDataCollection data,
  required List<HabitGroupData> groups,
  required Set<String?> collapsedUUIDs,
  HabitsDisplayFilter? filter,
  HabitDisplaySortType sortType = defaultSortType,
  HabitDisplaySortDirection sortDirection = defaultSortDirection,
  HabitDisplayGroupType groupType = defaultGroupType,
  HabitDisplaySortDirection groupDirection = defaultGroupSortDirection,
}) {
  final result = <HabitSortCache<dynamic>>[];

  final habitByGroup = <String?, List<HabitSummaryData>>{};
  for (final habit in data.values) {
    if (filter != null && !filter.displayFilterFunction(habit)) continue;
    final gid = resolveEffectiveGroupId(habit.groupId, groups);
    habitByGroup.putIfAbsent(gid, () => []).add(habit);
  }

  // Sort groups according to groupType, then apply groupDirection.
  final orderedGroups = _orderGroups(groups, groupType, groupDirection);

  for (final group in orderedGroups) {
    final gid = group.uuid;
    final habits = habitByGroup.remove(gid);
    if (habits == null || habits.isEmpty) continue;

    result.add(
      GroupHeaderSortCache(
        groupUUID: group.uuid,
        name: group.name,
        icon: group.icon,
        color: group.color,
        count: habits.length,
      ),
    );

    if (!collapsedUUIDs.contains(gid)) {
      result.addAll(
        habits.sortedBy(sortType, sortDirection).toHabitSummarySortCacheList(),
      );
    }
  }

  final uncategorized = habitByGroup.remove(null) ?? [];
  for (final entry in habitByGroup.entries) {
    uncategorized.addAll(entry.value);
  }

  if (uncategorized.isNotEmpty || result.isEmpty) {
    final header = GroupHeaderSortCache(
      groupUUID: null,
      name: '',
      count: uncategorized.length,
    );
    result.add(header);

    if (!collapsedUUIDs.contains(null)) {
      result.addAll(
        uncategorized
            .sortedBy(sortType, sortDirection)
            .toHabitSummarySortCacheList(),
      );
    }
  }

  return result;
}

/// Returns [groups] sorted according to [groupType] and [direction].
List<HabitGroupData> _orderGroups(
  List<HabitGroupData> groups,
  HabitDisplayGroupType groupType,
  HabitDisplaySortDirection direction,
) => groups.sortedBy(groupType, direction);

/// Applies [options] keyword/status/type filtering to [sorted].
///
/// Group header items always pass through; only habit items are tested.
/// Returns a new list without mutating the original.
List<HabitSortCache<dynamic>> filterGroupedList(
  List<HabitSortCache<dynamic>> sorted,
  HabitDisplaySearchOptions options,
) => sorted
    .where(
      (e) => switch (e) {
        GroupHeaderSortCache() => true,
        HabitSummaryDataSortCache(data: final HabitSummaryData d) =>
          options.filter(d, caps: true, keywords: options.splitKeywords),
        HabitSummaryDataSortCache(data: null) => false,
      },
    )
    .toList();

/// Recalculates the [GroupHeaderSortCache.count] fields in [list] to match
/// the actual number of habit items between consecutive group headers.
///
/// Mutates headers in-place because the list is rebuilt on every sort pass.
void updateGroupHeaderCounts(List<HabitSortCache<dynamic>> list) {
  final (:header, :count) = list
      .fold<({GroupHeaderSortCache? header, int count})>(
        (header: null, count: 0),
        (acc, element) {
          switch (element) {
            case GroupHeaderSortCache h:
              acc.header?.count = acc.count;
              return (header: h, count: 0);
            case HabitSummaryDataSortCache():
              return (header: acc.header, count: acc.count + 1);
          }
        },
      );
  if (header != null) header.count = count;
}

/// Resolves [groupId] to an effective group identifier.
///
/// Returns `null` when [groupId] is null or references a group that no longer
/// exists in [groups].
String? resolveEffectiveGroupId(String? groupId, List<HabitGroupData> groups) {
  if (groupId == null) return null;
  if (groups.any((g) => g.uuid == groupId)) return groupId;
  return null;
}
