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

import 'habit_color_type.dart';

/// Unified business-layer color for a habit. The persistence layer
/// (`HabitDBCell`) keeps `colorType`/`customColor` as two separate raw
/// fields; this is the only normalized shape the business layer and UI
/// should consume.
sealed class HabitColor implements Comparable<HabitColor> {
  const HabitColor();

  /// Builds from the raw persistence fields. Which variant results is
  /// decided purely by which field is populated, never by comparing
  /// [customColor] against a built-in seed value: a custom color that
  /// happens to numerically match a built-in seed must still render and
  /// display as custom, not be silently reinterpreted as a built-in pick.
  ///
  /// [customColorTinted] is the raw `0`/`1`/`null` persistence value for
  /// [CustomHabitColor.tinted]. A missing value (`null`) — whether because
  /// the data predates this field or because it was never written —
  /// defaults to tinted-on, matching the picker's default toggle state.
  factory HabitColor.fromRaw({
    required HabitColorType colorType,
    int? customColor,
    int? customColorTinted,
  }) {
    return customColor == null
        ? HabitColor.builtIn(colorType)
        : HabitColor.custom(
            customColor,
            tinted: customColorTinted == null || customColorTinted != 0,
          );
  }

  const factory HabitColor.builtIn(HabitColorType colorType) =
      BuiltInHabitColor;
  const factory HabitColor.custom(int argb, {bool tinted}) = CustomHabitColor;

  /// Unpacks back into the raw persistence fields. This and
  /// [HabitColor.fromRaw] are the only places allowed to touch the raw
  /// `colorType`/`customColor`/`customColorTinted` shape; everything else
  /// consumes [HabitColor].
  HabitColorType get dbColorType;
  int? get dbCustomColor;
  int? get dbCustomColorTinted;

  /// Orders built-in colors by palette position (`cc1` < `cc2` < ... <
  /// `cc10`), with all custom colors sorted after every built-in color and
  /// ordered among themselves by ARGB value, then by [CustomHabitColor.tinted]
  /// (untinted before tinted) when the ARGB matches — two custom colors that
  /// share an ARGB but differ in `tinted` are unequal per [==], so
  /// `compareTo` must not return `0` for them too; only an exact ARGB +
  /// tinted match collapses to `0`, consistent with [==]. Encapsulated here
  /// so callers never need to reach into [dbColorType]/[dbCustomColor] just
  /// to compare two colors.
  @override
  int compareTo(HabitColor other) => switch ((this, other)) {
    (
      BuiltInHabitColor(colorType: final a),
      BuiltInHabitColor(colorType: final b),
    ) =>
      a.index.compareTo(b.index),
    (BuiltInHabitColor(), CustomHabitColor()) => -1,
    (CustomHabitColor(), BuiltInHabitColor()) => 1,
    (
      CustomHabitColor(argb: final a, tinted: final at),
      CustomHabitColor(argb: final b, tinted: final bt),
    ) =>
      a != b ? a.compareTo(b) : (at == bt ? 0 : (at ? 1 : -1)),
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
  int? get dbCustomColorTinted => null;

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

  /// Whether [getColor] should resolve this color through
  /// [ColorScheme.fromSeed] (the same Material You tone the other three role
  /// colors already use) rather than staying close to the picked [argb]
  /// value. Defaults to `true` — most custom colors are expected to opt in
  /// to the tonal look; turning it off is the escape hatch for users who
  /// want the exact picked color rendered as-is.
  final bool tinted;

  const CustomHabitColor(this.argb, {this.tinted = true});

  @override
  HabitColorType get dbColorType => HabitColorType.cc1;
  @override
  int? get dbCustomColor => argb;
  @override
  int? get dbCustomColorTinted => tinted ? 1 : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomHabitColor &&
          argb == other.argb &&
          tinted == other.tinted);

  @override
  int get hashCode => Object.hash(argb, tinted);

  @override
  String toString() => 'CustomHabitColor($argb, tinted: $tinted)';
}

/// Null-safe comparison for two [HabitColor?] values, placing `null` after
/// all non-null values.
extension CompareNullableColor on HabitColor? {
  int compareToNullable(HabitColor? other) {
    if (this == null && other == null) return 0;
    if (this == null) return 1;
    if (other == null) return -1;
    return this!.compareTo(other);
  }
}
