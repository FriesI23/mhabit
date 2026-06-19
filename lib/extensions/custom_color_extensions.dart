// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart' show Brightness, Color, ColorScheme;

import '../models/habit_color.dart';
import '../models/habit_form.dart' show HabitColorType;
// `show CustomColors`, not a wildcard import: `theme/color.dart` re-exports
// `_colors/custom_color.dart`, which also declares top-level `cc1`..`cc10`
// constants (the un-toned seed values, distinct from `CustomColors.cc1`
// etc). A wildcard import would let a typo'd bare `ccN` reference silently
// resolve to those top-level constants instead of failing to compile.
import '../theme/color.dart' show CustomColors;

/// Extension on [CustomColors] that resolves [HabitColor] to Material
/// role colors (primary, on-primary, primary-container,
/// on-primary-container).
///
/// Built-in colors (cc1–cc10) are looked up directly from the theme
/// extension's tone properties.  Custom colors are computed via
/// [ColorScheme.fromSeed] and cached by `(argb, brightness)` so that
/// repeated calls for the same custom seed + brightness pair avoid
/// redundant seed-scheme construction.
extension HabitColorExtension on CustomColors {
  // -----------------------------------------------------------------
  // Cache for custom-color schemes
  // -----------------------------------------------------------------

  /// Per-(argb, brightness) → [ColorScheme] cache for custom colors.
  /// A custom color's scheme is deterministic for a given seed and
  /// brightness, so caching eliminates redundant [ColorScheme.fromSeed]
  /// work across rebuilds.
  static final _customSchemeCache = <(int, Brightness), ColorScheme>{};

  /// Returns the cached [ColorScheme] for a custom ARGB seed +
  /// [Brightness], computing it once on first access.
  static ColorScheme _customScheme(int argb, Brightness brightness) =>
      _customSchemeCache.putIfAbsent((argb, brightness), () {
        return ColorScheme.fromSeed(
          seedColor: Color(argb),
          brightness: brightness,
        );
      });

  // -----------------------------------------------------------------
  // Public color-role resolution — HabitColor → Material role
  // -----------------------------------------------------------------

  /// Returns the primary-color tone for [color].
  ///
  /// * Built-in colors map to the corresponding `ccN` tone.
  /// * Custom colors return [ColorScheme.primary] of the seed-derived
  ///   scheme computed from the custom ARGB value.
  Color? getColor(HabitColor color, {required Brightness brightness}) =>
      switch (color) {
        BuiltInHabitColor(colorType: final t) => getBuiltInColor(t),
        CustomHabitColor(argb: final v) => _customScheme(v, brightness).primary,
      };

  /// Returns the on-primary-color tone for [color].
  Color? getOnColor(HabitColor color, {required Brightness brightness}) =>
      switch (color) {
        BuiltInHabitColor(colorType: final t) => getBuiltInOnColor(t),
        CustomHabitColor(argb: final v) => _customScheme(
          v,
          brightness,
        ).onPrimary,
      };

  /// Returns the primary-container color tone for [color].
  Color? getColorContainer(
    HabitColor color, {
    required Brightness brightness,
  }) => switch (color) {
    BuiltInHabitColor(colorType: final t) => getBuiltInColorContainer(t),
    CustomHabitColor(argb: final v) => _customScheme(
      v,
      brightness,
    ).primaryContainer,
  };

  /// Returns the on-primary-container color tone for [color].
  Color? getColorOnContainer(
    HabitColor color, {
    required Brightness brightness,
  }) => switch (color) {
    BuiltInHabitColor(colorType: final t) => getBuiltInColorOnContainer(t),
    CustomHabitColor(argb: final v) => _customScheme(
      v,
      brightness,
    ).onPrimaryContainer,
  };

  // -----------------------------------------------------------------
  // Built-in palette reverse lookup (color -> type)
  // -----------------------------------------------------------------

  /// Per-[CustomColors] cache of built-in swatch color -> [HabitColorType],
  /// keyed by instance identity. The built-in palette is static for a
  /// given [CustomColors], so this is built once and reused across
  /// repeated reverse lookups (e.g. from a color picker grid).
  static final _builtInColorTypeCache =
      <CustomColors, Map<Color, HabitColorType>>{};

  Map<Color, HabitColorType> get _builtInColorTypes =>
      _builtInColorTypeCache.putIfAbsent(
        this,
        () => {for (final t in HabitColorType.values) ?getBuiltInColor(t): t},
      );

  /// Reverse lookup from a built-in swatch [color] to its [HabitColorType].
  /// Returns null if [color] doesn't match any built-in swatch (e.g. it's
  /// a custom seed color).
  HabitColorType? getBuiltInColorType(Color color) => _builtInColorTypes[color];

  /// All built-in swatch colors, in [HabitColorType] order.
  List<Color> get builtInColors => [
    for (final t in HabitColorType.values) ?getBuiltInColor(t),
  ];

  // -----------------------------------------------------------------
  // Built-in palette direct access (public helpers)
  // -----------------------------------------------------------------

  /// Returns the primary tone for a built-in palette slot.
  Color? getBuiltInColor(HabitColorType t) => switch (t) {
    HabitColorType.cc1 => cc1,
    HabitColorType.cc2 => cc2,
    HabitColorType.cc3 => cc3,
    HabitColorType.cc4 => cc4,
    HabitColorType.cc5 => cc5,
    HabitColorType.cc6 => cc6,
    HabitColorType.cc7 => cc7,
    HabitColorType.cc8 => cc8,
    HabitColorType.cc9 => cc9,
    HabitColorType.cc10 => cc10,
  };

  /// Returns the on-primary tone for a built-in palette slot.
  Color? getBuiltInOnColor(HabitColorType t) => switch (t) {
    HabitColorType.cc1 => onCc1,
    HabitColorType.cc2 => onCc2,
    HabitColorType.cc3 => onCc3,
    HabitColorType.cc4 => onCc4,
    HabitColorType.cc5 => onCc5,
    HabitColorType.cc6 => onCc6,
    HabitColorType.cc7 => onCc7,
    HabitColorType.cc8 => onCc8,
    HabitColorType.cc9 => onCc9,
    HabitColorType.cc10 => onCc10,
  };

  /// Returns the primary-container tone for a built-in palette slot.
  Color? getBuiltInColorContainer(HabitColorType t) => switch (t) {
    HabitColorType.cc1 => cc1Container,
    HabitColorType.cc2 => cc2Container,
    HabitColorType.cc3 => cc3Container,
    HabitColorType.cc4 => cc4Container,
    HabitColorType.cc5 => cc5Container,
    HabitColorType.cc6 => cc6Container,
    HabitColorType.cc7 => cc7Container,
    HabitColorType.cc8 => cc8Container,
    HabitColorType.cc9 => cc9Container,
    HabitColorType.cc10 => cc10Container,
  };

  /// Returns the on-primary-container tone for a built-in palette slot.
  Color? getBuiltInColorOnContainer(HabitColorType t) => switch (t) {
    HabitColorType.cc1 => onCc1Container,
    HabitColorType.cc2 => onCc2Container,
    HabitColorType.cc3 => onCc3Container,
    HabitColorType.cc4 => onCc4Container,
    HabitColorType.cc5 => onCc5Container,
    HabitColorType.cc6 => onCc6Container,
    HabitColorType.cc7 => onCc7Container,
    HabitColorType.cc8 => onCc8Container,
    HabitColorType.cc9 => onCc9Container,
    HabitColorType.cc10 => onCc10Container,
  };
}
