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

import '../common/enums.dart';

/// Grouping type for habit display, analogous to [HabitDisplaySortType]
/// but excluding [HabitDisplaySortType.manual].
enum HabitDisplayGroupType implements EnumWithDBCode {
  name(code: 1),
  colorType(code: 2),
  createDate(code: 3),
  habitCount(code: 4);

  final int _code;

  const HabitDisplayGroupType({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static HabitDisplayGroupType? getFromDBCode(
    int dbCode, {
    HabitDisplayGroupType? withDefault,
  }) => HabitDisplayGroupType.values.byDBCode(dbCode, withDefault: withDefault);

  static Iterable<HabitDisplayGroupType> get menuOrderedList => const [
    HabitDisplayGroupType.name,
    HabitDisplayGroupType.colorType,
    HabitDisplayGroupType.createDate,
    HabitDisplayGroupType.habitCount,
  ];
}

/// Group-intrinsic ordering types for [HabitGroupData] sorting.
///
/// Unlike [HabitDisplayGroupType] which includes extrinsic types such as
/// [HabitDisplayGroupType.habitCount], this enum only covers sort types
/// that can be computed from [HabitGroupData] fields alone.
///
/// Use [fromGroupType] to safely convert a [HabitDisplayGroupType].
enum HabitGroupOrderType {
  name,
  colorType,
  createDate;

  /// Maps a [HabitDisplayGroupType] to its corresponding
  /// [HabitGroupOrderType].
  ///
  /// Returns `null` for extrinsic types (e.g.
  /// [HabitDisplayGroupType.habitCount]) that require data beyond
  /// [HabitGroupData] itself.
  static HabitGroupOrderType? fromGroupType(HabitDisplayGroupType type) =>
      switch (type) {
        HabitDisplayGroupType.name => HabitGroupOrderType.name,
        HabitDisplayGroupType.colorType => HabitGroupOrderType.colorType,
        HabitDisplayGroupType.createDate => HabitGroupOrderType.createDate,
        HabitDisplayGroupType.habitCount => null,
      };
}
