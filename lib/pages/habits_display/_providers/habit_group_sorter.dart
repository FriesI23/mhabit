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

import 'package:flutter/foundation.dart';

import '../../../extensions/habit_group_extensions.dart';
import '../../../extensions/iterable_extensions.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../models/habit_summary.dart';

sealed class HabitSortOrder {
  const HabitSortOrder._();

  factory HabitSortOrder.byType(
    HabitDisplaySortType type,
    HabitDisplaySortDirection direction,
  ) = _HabitSortByType;

  factory HabitSortOrder.byNatural(List<HabitSummaryData> order) =
      _HabitSortByNatural;

  List<HabitSummaryData> apply(List<HabitSummaryData> habits);
}

final class _HabitSortByType extends HabitSortOrder {
  final HabitDisplaySortType type;
  final HabitDisplaySortDirection direction;
  _HabitSortByType(this.type, this.direction) : super._();

  @override
  List<HabitSummaryData> apply(List<HabitSummaryData> habits) =>
      habits.sortedBy(type, direction);
}

final class _HabitSortByNatural extends HabitSortOrder {
  final List<HabitSummaryData> _order;
  _HabitSortByNatural(this._order) : super._();

  @override
  List<HabitSummaryData> apply(List<HabitSummaryData> habits) {
    final habitSet = habits.map((h) => h.uuid).toSet();
    return _order.where((h) => habitSet.contains(h.uuid)).toList();
  }
}

sealed class GroupSortOrder {
  const GroupSortOrder._();

  factory GroupSortOrder.byType(
    HabitDisplayGroupType type,
    HabitDisplaySortDirection direction,
  ) = _GroupSortByType;

  factory GroupSortOrder.byNatural(List<HabitGroupData> order) =
      _GroupSortByNatural;

  List<HabitGroupData> apply(
    List<HabitGroupData> groups,
    Map<String?, List<HabitSummaryData>> habitByGroup,
  );
}

final class _GroupSortByType extends GroupSortOrder {
  final HabitDisplayGroupType type;
  final HabitDisplaySortDirection direction;
  _GroupSortByType(this.type, this.direction) : super._();

  @override
  List<HabitGroupData> apply(
    List<HabitGroupData> groups,
    Map<String?, List<HabitSummaryData>> habitByGroup,
  ) => _orderGroups(groups, type, direction, habitByGroup: habitByGroup);
}

final class _GroupSortByNatural extends GroupSortOrder {
  final List<HabitGroupData> _order;
  _GroupSortByNatural(this._order) : super._();

  @override
  List<HabitGroupData> apply(
    List<HabitGroupData> groups,
    Map<String?, List<HabitSummaryData>> habitByGroup,
  ) => _order;
}

/// Builds a flat grouped sort-cache list from the given [data].
///
/// Habits are always grouped by their effective group ID in [groups]
/// (resolving orphan references to `null`). [habitOrder] controls
/// per-group habit ordering; [groupOrder] controls the group order.
///
/// Groups with no habits are skipped. Collapsed groups (by
/// [collapsedUUIDs]) only emit the header, omitting their habit items.
List<HabitSortCache<dynamic>> buildGroupedSortCacheList({
  required HabitSummaryDataCollection data,
  required List<HabitGroupData> groups,
  required Set<String?> collapsedUUIDs,
  required HabitSortOrder habitOrder,
  required GroupSortOrder groupOrder,
  HabitsDisplayFilter? filter,
}) {
  final result = <HabitSortCache<dynamic>>[];

  final habitByGroup = <String?, List<HabitSummaryData>>{};
  for (final habit in data.values) {
    if (filter != null && !filter.displayFilterFunction(habit)) continue;
    final gid = resolveEffectiveGroupId(habit.groupId, groups);
    habitByGroup.putIfAbsent(gid, () => []).add(habit);
  }

  final orderedGroups = groupOrder.apply(groups, habitByGroup);

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
      result.addAll(habitOrder.apply(habits).toHabitSummarySortCacheList());
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
        habitOrder.apply(uncategorized).toHabitSummarySortCacheList(),
      );
    }
  }

  return result;
}

List<HabitGroupData> _orderGroups(
  List<HabitGroupData> groups,
  HabitDisplayGroupType groupType,
  HabitDisplaySortDirection direction, {
  Map<String?, List<HabitSummaryData>>? habitByGroup,
}) => switch (groupType) {
  HabitDisplayGroupType.name => groups.sortedBy(
    HabitGroupOrderType.name,
    direction,
  ),
  HabitDisplayGroupType.colorType => groups.sortedBy(
    HabitGroupOrderType.colorType,
    direction,
  ),
  HabitDisplayGroupType.createDate => groups.sortedBy(
    HabitGroupOrderType.createDate,
    direction,
  ),
  HabitDisplayGroupType.habitCount => orderGroupsByHabitCount(
    groups,
    direction,
    habitByGroup: habitByGroup,
  ),
  HabitDisplayGroupType.manual => groups.sortedBy(
    HabitGroupOrderType.manual,
    direction,
  ),
};

/// Sorts [groups] by the number of habits in each group.
///
/// The default asc direction puts the group with most habits first.
/// [habitByGroup] maps group UUIDs to their habits; missing entries
/// are treated as zero.
@visibleForTesting
List<HabitGroupData> orderGroupsByHabitCount(
  List<HabitGroupData> groups,
  HabitDisplaySortDirection direction, {
  Map<String?, List<HabitSummaryData>>? habitByGroup,
}) {
  final effectiveMap = habitByGroup ?? const {};
  final count = {
    for (final g in groups) g.uuid: (effectiveMap[g.uuid]?.length ?? 0),
  };
  final sorted = groups.toList()
    ..sort((a, b) {
      final ca = count[b.uuid] ?? 0;
      final cb = count[a.uuid] ?? 0;
      return ca.compareTo(cb);
    });
  if (direction == HabitDisplaySortDirection.desc) {
    return sorted.reversed.toList();
  }
  return sorted;
}

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
