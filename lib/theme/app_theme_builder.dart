// Copyright 2023 Fries_I23
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

import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoTextThemeData, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/app_info.dart';
import '../common/consts.dart';
import '../extensions/custom_color_extensions.dart';
import '../models/app_theme_color.dart';
import '../widgets/_widgets/predictive_back_page_transitions_builder.dart';
import '../widgets/styles.dart';
import 'color.dart';
import 'linux_bundled_font.dart';

// Tuned from composited iOS 26 native navigation screenshots. Apple does not
// publish equivalent Liquid Glass alpha constants for custom Flutter chrome.
const _appleGlassBackgroundColor = CupertinoDynamicColor.withBrightness(
  debugLabel: 'mhabitAppleGlassBackground',
  color: Color(0xCCFFFFFF),
  darkColor: Color(0x0FFFFFFF),
);

const _linuxFontFamilyFallbacks = [
  'Ubuntu',
  'Adwaita Sans',
  'Cantarell',
  'DejaVu Sans',
  'Liberation Sans',
  'Arial',
  'Noto Color Emoji',
  'Noto Sans CJK SC',
  'Noto Sans CJK TC',
  'Noto Sans CJK JP',
  'Noto Sans CJK KR',
];

/// Assembles the app [ThemeData] from the resolved theme-color inputs.
///
/// Owns the theme-decision helpers that used to live inline in the app
/// entry ([getThemeColor], [getSystemLightColor], [getSystemDarkColor],
/// font resolution, menu theme, and the Cupertino mapping), so the theme
/// pipeline is a single testable unit. Behavior is identical to the
/// previous inline builders.
class AppThemeBuilder {
  const AppThemeBuilder();

  /// Builds the light theme from [themeColor] and the dynamic scheme.
  ThemeData buildLight({
    required AppThemeColor themeColor,
    required Color themeMainColor,
    ColorScheme? dynamicScheme,
  }) => _build(
    brightness: Brightness.light,
    systemScheme: getSystemLightColor(),
    mainColor: getThemeColor(
      themeColor,
      themeMainColor: themeMainColor,
      dynamicScheme: dynamicScheme,
      customColor: lightCustomColors,
    ),
    customColor: lightCustomColors,
  );

  /// Builds the dark theme from [themeColor] and the dynamic scheme.
  ThemeData buildDark({
    required AppThemeColor themeColor,
    required Color themeMainColor,
    ColorScheme? dynamicScheme,
  }) => _build(
    brightness: Brightness.dark,
    systemScheme: getSystemDarkColor(),
    mainColor: getThemeColor(
      themeColor,
      themeMainColor: themeMainColor,
      dynamicScheme: dynamicScheme,
      customColor: darkCustomColors,
    ),
    customColor: darkCustomColors,
  );

  ThemeData _build({
    required Brightness brightness,
    required ColorScheme? systemScheme,
    required Color? mainColor,
    required CustomColors customColor,
  }) {
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        ...const PageTransitionsTheme().builders,
        if (AppInfo().shouldEnablePredictBackPage())
          TargetPlatform.android:
              const CustomPredictiveBackPageTransitionsBuilder(),
      },
    );
    final colorScheme = mainColor != null
        ? ColorScheme.fromSeed(seedColor: mainColor, brightness: brightness)
        : systemScheme;
    final baseTheme = ThemeData(
      fontFamily: getFontFamily(),
      fontFamilyFallback: getFontFamilyFallbacks(),
      pageTransitionsTheme: pageTransitionsTheme,
      brightness: mainColor == null ? brightness : null,
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: kAppBarTheme,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      menuTheme: _mobileMenuTheme,
      extensions: [customColor],
    );
    final cupertinoTextTheme = _getCupertinoTextTheme(
      primaryColor: baseTheme.colorScheme.primary,
    );
    // Maps the app scheme onto Cupertino components so apple variants follow
    // the app's dynamic color instead of the Cupertino default blue. Linux
    // also keeps a text-only override when using the system Material scheme.
    final cupertinoOverrideTheme =
        colorScheme == null && cupertinoTextTheme == null
        ? null
        : CupertinoThemeData(
            brightness: colorScheme?.brightness,
            primaryColor: colorScheme?.primary,
            textTheme: cupertinoTextTheme,
            barBackgroundColor: colorScheme == null
                ? null
                : _appleGlassBackgroundColor,
            scaffoldBackgroundColor: colorScheme?.surface,
          );
    final theme = baseTheme.copyWith(
      cupertinoOverrideTheme: cupertinoOverrideTheme,
    );
    return theme.copyWith(
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        backgroundColor: theme.colorScheme.surfaceContainer,
        elevation: 1.0,
      ),
    );
  }

  String? getFontFamily() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux => linuxBundledFontFamily,
      _ => null,
    };
  }

  List<String>? getFontFamilyFallbacks() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.linux => _linuxFontFamilyFallbacks,
      _ => null,
    };
  }

  CupertinoTextThemeData? _getCupertinoTextTheme({Color? primaryColor}) {
    if (defaultTargetPlatform != TargetPlatform.linux) return null;

    final defaults = CupertinoTextThemeData(
      primaryColor: primaryColor ?? const CupertinoThemeData().primaryColor,
    );
    TextStyle withLinuxFonts(TextStyle style) => style.copyWith(
      fontFamily: linuxBundledFontFamily,
      fontFamilyFallback: _linuxFontFamilyFallbacks,
    );

    return defaults.copyWith(
      textStyle: withLinuxFonts(defaults.textStyle),
      actionTextStyle: withLinuxFonts(defaults.actionTextStyle),
      actionSmallTextStyle: withLinuxFonts(defaults.actionSmallTextStyle),
      tabLabelTextStyle: withLinuxFonts(defaults.tabLabelTextStyle),
      navTitleTextStyle: withLinuxFonts(defaults.navTitleTextStyle),
      navLargeTitleTextStyle: withLinuxFonts(defaults.navLargeTitleTextStyle),
      navActionTextStyle: withLinuxFonts(defaults.navActionTextStyle),
      pickerTextStyle: withLinuxFonts(defaults.pickerTextStyle),
      dateTimePickerTextStyle: withLinuxFonts(defaults.dateTimePickerTextStyle),
    );
  }

  static MenuThemeData? get _mobileMenuTheme => switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.android => const MenuThemeData(
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    ),
    _ => null,
  };

  Color? getThemeColor(
    AppThemeColor themeColor, {
    Color? themeMainColor,
    ColorScheme? dynamicScheme,
    CustomColors? customColor,
  }) {
    switch (themeColor) {
      case SystemAppThemeColor():
        return null;
      case PrimaryAppThemeColor():
        return appDefaultThemeMainColor;
      case DynamicAppThemeColor():
        final colorData = dynamicScheme?.primary.toARGB32();
        return colorData != null ? Color(colorData) : themeMainColor;
      case InternalAppThemeColor():
        final colorType = themeColor.colorType;
        return customColor?.getBuiltInColor(colorType) ?? themeMainColor;
      default:
        return themeMainColor;
    }
  }

  ColorScheme? getSystemLightColor() => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    _ => null,
  };

  ColorScheme? getSystemDarkColor() => switch (defaultTargetPlatform) {
    TargetPlatform.android => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F0F0F),
    ),
    TargetPlatform.iOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: Colors.black,
    ),
    TargetPlatform.macOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    ),
    _ => null,
  };
}
