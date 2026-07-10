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

import 'package:flutter/material.dart'
    show Brightness, Color, ColorScheme, HSLColor;

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
/// extension's tone properties. For custom colors, [getColor]'s behavior is
/// controlled by [CustomHabitColor.tinted]: when tinted (the default),
/// [getColor] uses the toned `.primary` of a [ColorScheme.fromSeed]-derived
/// scheme, same as the other three role colors below; when not tinted, it
/// stays as close as possible to the user-picked ARGB value instead, since
/// the toned primary can visibly drift from the color the user actually
/// selected. In the untinted case the only adjustment applied is a minimal
/// lightness nudge (see [_visibleLightness]) for colors that would otherwise
/// nearly disappear against the current theme's surface — most picked
/// colors pass through completely unchanged. The *other* three role colors
/// ([getOnColor], [getColorContainer], [getColorOnContainer]) are never
/// affected by [CustomHabitColor.tinted] — they always need a fully
/// contrast-appropriate, brightness-aware tone that isn't just the raw
/// value, so they always derive from [ColorScheme.fromSeed] seeded with that
/// same raw value, cached by `(argb, brightness)` so repeated calls for the
/// same custom seed + brightness pair avoid redundant seed-scheme
/// construction.
extension HabitColorExtension on CustomColors {
  /// Per-(argb, brightness) → [ColorScheme] cache for custom colors.
  /// A custom color's scheme is deterministic for a given seed and
  /// brightness, so caching eliminates redundant [ColorScheme.fromSeed]
  /// work across rebuilds. Capped at [_maxCustomSchemeCacheSize] with FIFO
  /// eviction so picking many distinct colors in a long-running session
  /// can't grow this without bound.
  static const _maxCustomSchemeCacheSize = 64;
  static final _customSchemeCache = <(int, Brightness), ColorScheme>{};

  /// Returns the cached [ColorScheme] for a custom ARGB seed +
  /// [Brightness], computing it once on first access.
  static ColorScheme _customScheme(int argb, Brightness brightness) {
    final key = (argb, brightness);
    final cached = _customSchemeCache[key];
    if (cached != null) return cached;
    final scheme = ColorScheme.fromSeed(
      seedColor: Color(argb),
      brightness: brightness,
    );
    if (_customSchemeCache.length >= _maxCustomSchemeCacheSize) {
      _customSchemeCache.remove(_customSchemeCache.keys.first);
    }
    return _customSchemeCache[key] = scheme;
  }

  // A near-white custom color is barely visible on a light theme's surface
  // (typically lightness ~0.96–1.0), and a near-black one is barely visible
  // on a dark theme's surface (typically lightness ~0.07–0.12). These
  // thresholds only catch those two extremes — most picked colors (anything
  // with a moderately saturated, non-extreme tone) are well clear of both
  // and pass through with zero adjustment.
  static const _minVisibleLightnessOnDark = 0.2;
  static const _maxVisibleLightnessOnLight = 0.85;

  /// Nudges [argb]'s lightness just enough to stay visible against the
  /// current theme's surface, keeping hue and saturation untouched so the
  /// result still reads as "the color the user picked" rather than a
  /// re-toned approximation. Returns [argb] itself whenever no nudge is
  /// needed.
  static Color _visibleLightness(int argb, Brightness brightness) {
    final hsl = HSLColor.fromColor(Color(argb));
    final lightness = switch (brightness) {
      Brightness.light when hsl.lightness > _maxVisibleLightnessOnLight =>
        _maxVisibleLightnessOnLight,
      Brightness.dark when hsl.lightness < _minVisibleLightnessOnDark =>
        _minVisibleLightnessOnDark,
      _ => null,
    };
    return lightness == null
        ? Color(argb)
        : hsl.withLightness(lightness).toColor();
  }

  /// Returns the primary-color tone for [color].
  ///
  /// * Built-in colors map to the corresponding `ccN` tone.
  /// * Custom colors with [CustomHabitColor.tinted] set (the default) use
  ///   [ColorScheme.primary] of a seed-derived scheme, same as the other
  ///   three role colors below.
  /// * Custom colors with tinting turned off stay as close as possible to
  ///   the user-picked ARGB value instead, with only
  ///   [_visibleLightness]'s minimal nudge applied for colors that would
  ///   otherwise nearly disappear against the current theme's surface.
  Color? getColor(HabitColor color, {required Brightness brightness}) =>
      switch (color) {
        BuiltInHabitColor(colorType: final t) => getBuiltInColor(t),
        CustomHabitColor(argb: final v, tinted: true) => _customScheme(
          v,
          brightness,
        ).primary,
        CustomHabitColor(argb: final v, tinted: false) => _visibleLightness(
          v,
          brightness,
        ),
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
