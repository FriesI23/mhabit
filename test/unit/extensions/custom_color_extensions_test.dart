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

        test('light and dark return different role colors', () {
          final light = lightCustomColors.getColor(
            color,
            brightness: Brightness.light,
          );
          final dark = darkCustomColors.getColor(
            color,
            brightness: Brightness.dark,
          );
          expect(light, isNot(equals(dark)));
        });
      });
    }
  });

  group('HabitColorExtension — builtInColors', () {
    test('returns 10 non-null colors in HabitColorType order', () {
      final colors = lightCustomColors.builtInColors;
      expect(colors.length, HabitColorType.values.length);
      expect(colors, everyElement(isNotNull));
      expect(colors, [
        for (final t in HabitColorType.values)
          lightCustomColors.getBuiltInColor(t),
      ]);
    });
  });

  group('HabitColorExtension — getBuiltInColorType', () {
    test('returns correct type for each built-in swatch', () {
      for (final t in HabitColorType.values) {
        final swatch = lightCustomColors.getBuiltInColor(t)!;
        expect(
          lightCustomColors.getBuiltInColorType(swatch),
          t,
          reason: 'cc${t.code} swatch should reverse-look up to its own type',
        );
      }
    });

    test('returns null for a non-built-in color', () {
      const notBuiltIn = Color(0x12345678);
      expect(lightCustomColors.getBuiltInColorType(notBuiltIn), isNull);
    });

    test('returns null for a custom-color seed that matches no built-in', () {
      // 0xFF000002 is not in the built-in palette.
      const nonBuiltIn = Color(0xFF000002);
      expect(lightCustomColors.getBuiltInColorType(nonBuiltIn), isNull);
    });
  });

  group('HabitColorExtension — cache behavior', () {
    const argb = 0xFFAABBCC;

    test('same (argb, brightness) pair returns same ColorScheme', () {
      final result1 = lightCustomColors.getColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      final result2 = lightCustomColors.getColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      // Color values should be identical (cached ColorScheme reused).
      expect(result1, equals(result2));
    });

    test('different brightness returns different value for same argb', () {
      final light = lightCustomColors.getColor(
        const CustomHabitColor(argb),
        brightness: Brightness.light,
      );
      final dark = darkCustomColors.getColor(
        const CustomHabitColor(argb),
        brightness: Brightness.dark,
      );
      expect(light, isNot(equals(dark)));
    });
  });
}
