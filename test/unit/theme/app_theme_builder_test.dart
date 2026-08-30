import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/extensions/custom_color_extensions.dart';
import 'package:mhabit/models/app_theme_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/theme/app_theme_builder.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit/widgets/styles.dart';

void _withPlatform(TargetPlatform platform, void Function() body) {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  body();
}

void _expectMaterialRailSurface(ThemeData theme) {
  expect(theme.appBarTheme, same(kAppBarTheme));
  expect(
    theme.navigationRailTheme.backgroundColor,
    theme.colorScheme.surfaceContainer,
  );
  expect(theme.navigationRailTheme.elevation, 1.0);
}

void main() {
  const builder = AppThemeBuilder();
  const fallbackMainColor = Color(0xFF112233);

  group('AppThemeBuilder.buildLight / buildDark', () {
    test(
      'seed path: brightness comes from the scheme and app chrome is set',
      () {
        final theme = builder.buildLight(
          themeColor: const PrimaryAppThemeColor(),
          themeMainColor: fallbackMainColor,
        );
        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.light);
        expect(theme.colorScheme.brightness, Brightness.light);
        _expectMaterialRailSurface(theme);
        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
        expect(theme.extensions.values.whereType<CustomColors>(), hasLength(1));
      },
    );

    test('dark seed path mirrors the light one', () {
      final theme = builder.buildDark(
        themeColor: const PrimaryAppThemeColor(),
        themeMainColor: fallbackMainColor,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      _expectMaterialRailSurface(theme);
    });

    test('system path keeps the explicit brightness with a null scheme', () {
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        _withPlatform(platform, () {
          final theme = builder.buildLight(
            themeColor: const SystemAppThemeColor(),
            themeMainColor: fallbackMainColor,
          );
          expect(theme.brightness, Brightness.light, reason: '$platform');
          expect(theme.cupertinoOverrideTheme, isNull, reason: '$platform');
          _expectMaterialRailSurface(theme);
        });
      }
    });
  });

  group('AppThemeBuilder.getSystemLightColor', () {
    test('produces a white-surface light scheme on apple and android', () {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      ]) {
        _withPlatform(platform, () {
          final scheme = builder.getSystemLightColor();
          expect(scheme, isNotNull, reason: '$platform');
          expect(scheme!.brightness, Brightness.light, reason: '$platform');
          expect(scheme.surface, Colors.white, reason: '$platform');
        });
      }
    });

    test('is null on desktop / fuchsia platforms', () {
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        _withPlatform(platform, () {
          expect(builder.getSystemLightColor(), isNull, reason: '$platform');
          expect(builder.getSystemDarkColor(), isNull, reason: '$platform');
        });
      }
    });
  });

  group('AppThemeBuilder.getSystemDarkColor', () {
    test('per-platform dark surface colors', () {
      final expectedSurfaces = {
        TargetPlatform.android: const Color(0xFF0F0F0F),
        TargetPlatform.iOS: Colors.black,
        TargetPlatform.macOS: const Color(0xFF1E1E1E),
      };
      expectedSurfaces.forEach((platform, surface) {
        _withPlatform(platform, () {
          final scheme = builder.getSystemDarkColor();
          expect(scheme, isNotNull, reason: '$platform');
          expect(scheme!.brightness, Brightness.dark, reason: '$platform');
          expect(scheme.surface, surface, reason: '$platform');
        });
      });
    });
  });

  group('AppThemeBuilder cupertino mapping', () {
    test('maps scheme chrome and uses the neutral apple glass tint', () {
      _withPlatform(TargetPlatform.macOS, () {
        final theme = builder.buildLight(
          themeColor: const SystemAppThemeColor(),
          themeMainColor: fallbackMainColor,
        );
        final scheme = theme.colorScheme;
        final override = theme.cupertinoOverrideTheme;
        expect(override, isNotNull);
        expect(override!.brightness, scheme.brightness);
        expect(override.primaryColor, scheme.primary);
        expect(
          override.barBackgroundColor,
          const CupertinoDynamicColor.withBrightness(
            debugLabel: 'mhabitAppleGlassBackground',
            color: Color(0xCCFFFFFF),
            darkColor: Color(0x0FFFFFFF),
          ),
        );
        expect(override.scaffoldBackgroundColor, scheme.surface);
      });
    });

    test(
      'keeps dark apple glass independent from elevated scheme surfaces',
      () {
        _withPlatform(TargetPlatform.macOS, () {
          final theme = builder.buildDark(
            themeColor: const SystemAppThemeColor(),
            themeMainColor: fallbackMainColor,
          );
          final scheme = theme.colorScheme;
          final override = theme.cupertinoOverrideTheme;
          expect(override, isNotNull);
          expect(
            override!.barBackgroundColor,
            isNot(scheme.surfaceContainerHigh.withValues(alpha: 0.8)),
          );
          expect(
            override.barBackgroundColor,
            isNot(scheme.surface.withValues(alpha: 0.8)),
          );
          expect(override.scaffoldBackgroundColor, scheme.surface);
        });
      },
    );
  });

  group('AppThemeBuilder.getThemeColor', () {
    test('font family stays null off the linux aarch64 path', () {
      _withPlatform(TargetPlatform.macOS, () {
        expect(builder.getFontFamily(), isNull);
        expect(builder.getFontFamilyFallbacks(), isNull);
      });
    });

    test('system resolves to null', () {
      expect(
        builder.getThemeColor(
          const SystemAppThemeColor(),
          themeMainColor: fallbackMainColor,
        ),
        isNull,
      );
    });

    test('primary resolves to the default main color', () {
      expect(
        builder.getThemeColor(
          const PrimaryAppThemeColor(),
          themeMainColor: fallbackMainColor,
        ),
        appDefaultThemeMainColor,
      );
    });

    test('dynamic prefers the dynamic scheme primary', () {
      final scheme = ColorScheme.fromSeed(seedColor: appDefaultThemeMainColor);
      expect(
        builder.getThemeColor(
          const DynamicAppThemeColor(),
          themeMainColor: fallbackMainColor,
          dynamicScheme: scheme,
        ),
        scheme.primary,
      );
    });

    test('dynamic falls back to the main color without a scheme', () {
      expect(
        builder.getThemeColor(
          const DynamicAppThemeColor(),
          themeMainColor: fallbackMainColor,
        ),
        fallbackMainColor,
      );
    });

    test('internal resolves to the built-in color from CustomColors', () {
      final builtIn = lightCustomColors.getBuiltInColor(HabitColorType.cc1);
      expect(builtIn, isNotNull);
      expect(
        builder.getThemeColor(
          const InternalAppThemeColor(colorType: HabitColorType.cc1),
          themeMainColor: fallbackMainColor,
          customColor: lightCustomColors,
        ),
        builtIn,
      );
    });

    test('internal falls back to the main color without custom colors', () {
      expect(
        builder.getThemeColor(
          const InternalAppThemeColor(colorType: HabitColorType.cc1),
          themeMainColor: fallbackMainColor,
        ),
        fallbackMainColor,
      );
    });
  });
}
