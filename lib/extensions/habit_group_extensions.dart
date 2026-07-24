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

import '../models/habit_color.dart';
import '../models/habit_display.dart';
import '../models/habit_group.dart';
import '../models/habit_group_display.dart';

import 'datetime_extensions.dart';

/// Sort helpers for [HabitGroupData] lists.
extension HabitGroupSortExtension on List<HabitGroupData> {
  /// Returns a new list sorted by [type] in [direction].
  ///
  /// For [HabitGroupOrderType.colorType], missing colours sort after all
  /// present colours.  For [HabitGroupOrderType.createDate], groups with a
  /// null [HabitGroupData.createT] sort after those with a known date.
  ///
  /// Only covers [HabitGroupOrderType] — group-intrinsic sorts that can be
  /// computed from [HabitGroupData] fields alone. Extrinsic types such as
  /// [HabitDisplayGroupType.habitCount] must be routed through
  /// [buildGroupedSortCacheList] or a similar context-aware dispatcher.
  List<HabitGroupData> sortedBy(
    HabitGroupOrderType type,
    HabitDisplaySortDirection direction,
  ) {
    final sorted = toList();
    final comparator = switch (type) {
      // FIXME: uses Unicode code-unit ordering, not natural-language sorting.
      HabitGroupOrderType.name =>
        (HabitGroupData a, HabitGroupData b) => a.name.compareTo(b.name),
      HabitGroupOrderType.colorType =>
        (HabitGroupData a, HabitGroupData b) =>
            a.color.compareToNullable(b.color),
      // Comparator is intentionally reversed (b, a) so that the default
      // asc direction puts the newest group first.
      HabitGroupOrderType.createDate =>
        (HabitGroupData a, HabitGroupData b) =>
            b.createT.compareToNullable(a.createT),
    };
    sorted.sort(comparator);
    if (direction == HabitDisplaySortDirection.desc) {
      return sorted.reversed.toList();
    }
    return sorted;
  }
}
