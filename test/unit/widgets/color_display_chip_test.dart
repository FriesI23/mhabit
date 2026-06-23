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
import 'package:mhabit/widgets/_widgets/color_display_chip.dart';

void main() {
  group('getEffectiveColorName', () {
    test('built-in color resolves to its localized cc name', () {
      final name = getEffectiveColorName(
        const HabitColor.builtIn(HabitColorType.cc3),
        null,
      );
      expect(name, HabitColorType.getColorName(HabitColorType.cc3, null));
      expect(name, isNot('Custom'));
    });

    test('custom color (tinted) always resolves to "Custom", never a'
        ' per-color name', () {
      final name = getEffectiveColorName(
        const HabitColor.custom(0xFF336699),
        null,
      );
      expect(name, 'Custom');
    });

    test('custom color (untinted) also resolves to "Custom"', () {
      final name = getEffectiveColorName(
        const HabitColor.custom(0xFF336699, tinted: false),
        null,
      );
      expect(name, 'Custom');
    });

    test('custom color matching a built-in seed value still shows "Custom",'
        ' not the matching built-in name', () {
      // HabitColor identity is structural (customColor == null vs not), so a
      // custom value that happens to equal a built-in seed must not collapse
      // back into that built-in's display name.
      final builtInColor = lightCustomColors.getColor(
        const HabitColor.builtIn(HabitColorType.cc1),
        brightness: Brightness.light,
      )!;
      final name = getEffectiveColorName(
        HabitColor.custom(builtInColor.toARGB32()),
        null,
      );
      expect(name, 'Custom');
      expect(
        name,
        isNot(HabitColorType.getColorName(HabitColorType.cc1, null)),
      );
    });
  });
}
