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

import 'habit_form.dart';

/// Unified business-layer color for a habit. The persistence layer
/// (`HabitDBCell`) keeps `colorType`/`customColor` as two separate raw
/// fields; this is the only normalized shape the business layer and UI
/// should consume.
sealed class HabitColor implements Comparable<HabitColor> {
  const HabitColor();

  /// Builds from the two raw persistence fields. Which variant results is
  /// decided purely by which field is populated, never by comparing
  /// [customColor] against a built-in seed value: a custom color that
  /// happens to numerically match a built-in seed must still render and
  /// display as custom, not be silently reinterpreted as a built-in pick.
  factory HabitColor.fromRaw({
    required HabitColorType colorType,
    int? customColor,
  }) {
    return customColor == null
        ? HabitColor.builtIn(colorType)
        : HabitColor.custom(customColor);
  }

  const factory HabitColor.builtIn(HabitColorType colorType) =
      BuiltInHabitColor;
  const factory HabitColor.custom(int argb) = CustomHabitColor;

  /// Unpacks back into the two raw persistence fields. This and
  /// [HabitColor.fromRaw] are the only places allowed to touch the raw
  /// `colorType`/`customColor` shape; everything else consumes [HabitColor].
  HabitColorType get dbColorType;
  int? get dbCustomColor;

  /// Orders built-in colors by palette position (`cc1` < `cc2` < ... <
  /// `cc10`), with all custom colors sorted after every built-in color and
  /// ordered among themselves by ARGB value. Encapsulated here so callers
  /// never need to reach into [dbColorType]/[dbCustomColor] just to compare
  /// two colors.
  @override
  int compareTo(HabitColor other) => switch ((this, other)) {
    (
      BuiltInHabitColor(colorType: final a),
      BuiltInHabitColor(colorType: final b),
    ) =>
      a.index.compareTo(b.index),
    (BuiltInHabitColor(), CustomHabitColor()) => -1,
    (CustomHabitColor(), BuiltInHabitColor()) => 1,
    (CustomHabitColor(argb: final a), CustomHabitColor(argb: final b)) =>
      a.compareTo(b),
  };
}

final class BuiltInHabitColor extends HabitColor {
  final HabitColorType colorType;

  const BuiltInHabitColor(this.colorType);

  @override
  HabitColorType get dbColorType => colorType;
  @override
  int? get dbCustomColor => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuiltInHabitColor && colorType == other.colorType);

  @override
  int get hashCode => colorType.hashCode;

  @override
  String toString() => 'BuiltInHabitColor($colorType)';
}

final class CustomHabitColor extends HabitColor {
  final int argb;

  const CustomHabitColor(this.argb);

  @override
  HabitColorType get dbColorType => HabitColorType.cc1;
  @override
  int? get dbCustomColor => argb;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomHabitColor && argb == other.argb);

  @override
  int get hashCode => argb.hashCode;

  @override
  String toString() => 'CustomHabitColor($argb)';
}
