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
  /// For [HabitDisplayGroupType.colorType], missing colours sort after all
  /// present colours.  For [HabitDisplayGroupType.createDate], groups with a
  /// null [HabitGroupData.createT] sort after those with a known date.
  List<HabitGroupData> sortedBy(
    HabitDisplayGroupType type,
    HabitDisplaySortDirection direction,
  ) {
    final sorted = toList();
    final comparator = switch (type) {
      HabitDisplayGroupType.name =>
        (HabitGroupData a, HabitGroupData b) => a.name.compareTo(b.name),
      HabitDisplayGroupType.colorType =>
        (HabitGroupData a, HabitGroupData b) =>
            a.color.compareToNullable(b.color),
      HabitDisplayGroupType.createDate =>
        (HabitGroupData a, HabitGroupData b) =>
            a.createT.compareToNullable(b.createT),
    };
    sorted.sort(comparator);
    if (direction == HabitDisplaySortDirection.desc) {
      return sorted.reversed.toList();
    }
    return sorted;
  }
}
