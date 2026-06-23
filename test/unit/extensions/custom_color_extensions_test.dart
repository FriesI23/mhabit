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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/custom_color_extensions.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/theme/color.dart';

void main() {
  group('HabitColorExtension — built-in colors', () {
    for (final t in HabitColorType.values) {
      group('cc${t.code}', () {
        final color = HabitColor.builtIn(t);

        test('getColor returns non-null', () {
          expect(
            lightCustomColors.getColor(color, brightness: Brightness.light),
            isNotNull,
          );
          expect(
            lightCustomColors.getColor(color, brightness: Brightness.dark),
            isNotNull,
          );
        });

        test('getOnColor returns non-null', () {
          expect(
            lightCustomColors.getOnColor(color, brightness: Brightness.light),
            isNotNull,
          );
          expect(
            lightCustomColors.getOnColor(color, brightness: Brightness.dark),
            isNotNull,
          );
        });

        test('getColorContainer returns non-null', () {
          expect(
            lightCustomColors.getColorContainer(
              color,
              brightness: Brightness.light,
            ),
            isNotNull,
          );
          expect(
            lightCustomColors.getColorContainer(
              color,
              brightness: Brightness.dark,
            ),
            isNotNull,
          );
        });

        test('getColorOnContainer returns non-null', () {
          expect(
            lightCustomColors.getColorOnContainer(
              color,
              brightness: Brightness.light,
            ),
            isNotNull,
          );
          expect(
            lightCustomColors.getColorOnContainer(
              color,
              brightness: Brightness.dark,
            ),
            isNotNull,
          );
        });
      });
    }
  });

  group('HabitColorExtension — custom colors', () {
    const testArgbValues = [0xFF123456, 0xFFABCDEF, 0x00000000, 0xFFFFFFFF];

    for (final argb in testArgbValues) {
      group('argb $argb', () {
        // tinted defaults to true, so getColor below goes through the same
        // ColorScheme.fromSeed path as the other three role colors.
        final color = CustomHabitColor(argb);

        test('getColor returns non-null in light and dark', () {
          expect(
            lightCustomColors.getColor(color, brightness: Brightness.light),
            isNotNull,
          );
          expect(
            darkCustomColors.getColor(color, brightness: Brightness.dark),
            isNotNull,
          );
        });

        test('getOnColor returns non-null in both brightness', () {
          expect(
            lightCustomColors.getOnColor(color, brightness: Brightness.light),
            isNotNull,
          );
          expect(
            darkCustomColors.getOnColor(color, brightness: Brightness.dark),
            isNotNull,
          );
        });

        test('getColorContainer returns non-null in both brightness', () {
          expect(
            lightCustomColors.getColorContainer(
              color,
              brightness: Brightness.light,
            ),
            isNotNull,
          );
          expect(
            darkCustomColors.getColorContainer(
              color,
              brightness: Brightness.dark,
            ),
            isNotNull,
          );
        });

        test('getColorOnContainer returns non-null in both brightness', () {
          expect(
            lightCustomColors.getColorOnContainer(
              color,
              brightness: Brightness.light,
            ),
            isNotNull,
          );
          expect(
            darkCustomColors.getColorOnContainer(
              color,
              brightness: Brightness.dark,
            ),
            isNotNull,
          );
        });

        test('getColor matches the seeded ColorScheme primary', () {
          final expectedLight = ColorScheme.fromSeed(
            seedColor: Color(argb),
            brightness: Brightness.light,
          ).primary;
          final expectedDark = ColorScheme.fromSeed(
            seedColor: Color(argb),
            brightness: Brightness.dark,
          ).primary;
          expect(
            lightCustomColors.getColor(color, brightness: Brightness.light),
            expectedLight,
          );
          expect(
            darkCustomColors.getColor(color, brightness: Brightness.dark),
            expectedDark,
          );
        });

        test('getOnColor differs between light and dark', () {
          final light = lightCustomColors.getOnColor(
            color,
            brightness: Brightness.light,
          );
          final dark = darkCustomColors.getOnColor(
            color,
            brightness: Brightness.dark,
          );
          expect(light, isNot(equals(dark)));
        });
      });
    }
  });

  group('HabitColorExtension — custom colors (tinted: false)', () {
    const testArgbValues = [0xFF123456, 0xFFABCDEF, 0x00000000, 0xFFFFFFFF];

    for (final argb in testArgbValues) {
      group('argb $argb', () {
        final color = CustomHabitColor(argb, tinted: false);

        test('getColor returns non-null in light and dark', () {
          expect(
            lightCustomColors.getColor(color, brightness: Brightness.light),
            isNotNull,
          );
          expect(
            darkCustomColors.getColor(color, brightness: Brightness.dark),
            isNotNull,
          );
        });

        test('getColor preserves hue and saturation in both brightnesses '
            '(only lightness may be nudged for visibility)', () {
          final rawHsl = HSLColor.fromColor(Color(argb));
          final light = HSLColor.fromColor(
            lightCustomColors.getColor(color, brightness: Brightness.light)!,
          );
          final dark = HSLColor.fromColor(
            darkCustomColors.getColor(color, brightness: Brightness.dark)!,
          );
          expect(light.hue, closeTo(rawHsl.hue, 0.5));
          expect(light.saturation, closeTo(rawHsl.saturation, 0.01));
          expect(dark.hue, closeTo(rawHsl.hue, 0.5));
          expect(dark.saturation, closeTo(rawHsl.saturation, 0.01));
        });

        test('getOnColor/getColorContainer/getColorOnContainer are '
            'unaffected by tinted: false (still seeded)', () {
          final tinted = CustomHabitColor(argb);
          expect(
            lightCustomColors.getOnColor(color, brightness: Brightness.light),
            lightCustomColors.getOnColor(tinted, brightness: Brightness.light),
          );
          expect(
            lightCustomColors.getColorContainer(
              color,
              brightness: Brightness.light,
            ),
            lightCustomColors.getColorContainer(
              tinted,
              brightness: Brightness.light,
            ),
          );
          expect(
            lightCustomColors.getColorOnContainer(
              color,
              brightness: Brightness.light,
            ),
            lightCustomColors.getColorOnContainer(
              tinted,
              brightness: Brightness.light,
            ),
          );
        });
      });
    }
  });

  group('HabitColorExtension — getColor tinted toggle', () {
    const argb = 0xFF336699;

    test('tinted: true returns the seeded ColorScheme primary', () {
      const color = CustomHabitColor(argb, tinted: true);
      final expected = ColorScheme.fromSeed(
        seedColor: const Color(argb),
        brightness: Brightness.light,
      ).primary;
      expect(
        lightCustomColors.getColor(color, brightness: Brightness.light),
        expected,
      );
    });

    test('tinted: false returns the visibility-nudged raw value', () {
      const color = CustomHabitColor(argb, tinted: false);
      expect(
        lightCustomColors.getColor(color, brightness: Brightness.light),
        const Color(argb),
      );
    });
  });

  group('HabitColorExtension — getColor visibility nudge (tinted: false)', () {
    test('near-white custom color is nudged down for light theme but left '
        'unchanged for dark theme', () {
      const color = CustomHabitColor(0xFFFFFFFF, tinted: false);
      final light = lightCustomColors.getColor(
        color,
        brightness: Brightness.light,
      );
      final dark = darkCustomColors.getColor(
        color,
        brightness: Brightness.dark,
      );
      expect(light, isNot(equals(const Color(0xFFFFFFFF))));
      expect(HSLColor.fromColor(light!).lightness, closeTo(0.85, 0.01));
      expect(dark, equals(const Color(0xFFFFFFFF)));
    });

    test('near-black custom color is nudged up for dark theme but left '
        'unchanged for light theme', () {
      const color = CustomHabitColor(0xFF000000, tinted: false);
      final light = lightCustomColors.getColor(
        color,
        brightness: Brightness.light,
      );
      final dark = darkCustomColors.getColor(
        color,
        brightness: Brightness.dark,
      );
      expect(light, equals(const Color(0xFF000000)));
      expect(dark, isNot(equals(const Color(0xFF000000))));
      expect(HSLColor.fromColor(dark!).lightness, closeTo(0.2, 0.01));
    });

    test('mid-tone custom color passes through unchanged in both themes', () {
      const color = CustomHabitColor(0xFF336699, tinted: false);
      final light = lightCustomColors.getColor(
        color,
        brightness: Brightness.light,
      );
      final dark = darkCustomColors.getColor(
        color,
        brightness: Brightness.dark,
      );
      expect(light, equals(const Color(0xFF336699)));
      expect(dark, equals(const Color(0xFF336699)));
    });
  });

  group('HabitColorExtension — cache behavior', () {
    const argb = 0xFFAABBCC;

    test('same (argb, brightness) pair returns same ColorScheme', () {
      // getOnColor (not getColor) is used here: it's always seeded
      // regardless of `tinted`, so it reliably exercises the cache.
      final result1 = lightCustomColors.getOnColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      final result2 = lightCustomColors.getOnColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      // Color values should be identical (cached ColorScheme reused).
      expect(result1, equals(result2));
    });

    test('different brightness returns different value for same argb', () {
      final light = lightCustomColors.getOnColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      final dark = darkCustomColors.getOnColor(
        const CustomHabitColor(argb),
        brightness: Brightness.dark,
      );
      expect(light, isNot(equals(dark)));
    });
  });
}
