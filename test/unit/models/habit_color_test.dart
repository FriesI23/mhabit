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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_form.dart';

void main() {
  group('HabitColor.fromRaw', () {
    test('returns BuiltInHabitColor when customColor is null', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc1,
        customColor: null,
      );
      expect(color, isA<BuiltInHabitColor>());
      expect(color, const HabitColor.builtIn(HabitColorType.cc1));
    });

    test('returns CustomHabitColor when customColor is non-null', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc1,
        customColor: 0xFF123456,
      );
      expect(color, isA<CustomHabitColor>());
      expect(color, const CustomHabitColor(0xFF123456));
    });

    test(
      'returns CustomHabitColor even when customColor happens to match a built-in seed',
      () {
        // 0xFF6750A4 is the source for cc1; the identity must remain custom.
        const matchingArgb = 0xFF6750A4;
        final color = HabitColor.fromRaw(
          colorType: HabitColorType.cc1,
          customColor: matchingArgb,
        );
        expect(color, isA<CustomHabitColor>());
        expect(color, isNot(const HabitColor.builtIn(HabitColorType.cc1)));
        expect(
          color,
          const CustomHabitColor(matchingArgb),
          reason:
              'a custom color numerically equal to a built-in seed must stay CustomHabitColor',
        );
      },
    );

    test('colorType parameter is ignored when customColor is non-null', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc5,
        customColor: 0xFFABCDEF,
      );
      expect(color, isA<CustomHabitColor>());
      expect(color, const CustomHabitColor(0xFFABCDEF));
    });

    test('defaults tinted to true when customColorTinted is null', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc1,
        customColor: 0xFF123456,
        customColorTinted: null,
      );
      expect(color, const CustomHabitColor(0xFF123456, tinted: true));
    });

    test('reads tinted: false from customColorTinted == 0', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc1,
        customColor: 0xFF123456,
        customColorTinted: 0,
      );
      expect(color, const CustomHabitColor(0xFF123456, tinted: false));
    });

    test('reads tinted: true from customColorTinted == 1', () {
      final color = HabitColor.fromRaw(
        colorType: HabitColorType.cc1,
        customColor: 0xFF123456,
        customColorTinted: 1,
      );
      expect(color, const CustomHabitColor(0xFF123456, tinted: true));
    });
  });

  group('BuiltInHabitColor', () {
    test('equality — same colorType are equal', () {
      const a = HabitColor.builtIn(HabitColorType.cc1);
      const b = HabitColor.builtIn(HabitColorType.cc1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality — different colorType are unequal', () {
      const a = HabitColor.builtIn(HabitColorType.cc1);
      const b = HabitColor.builtIn(HabitColorType.cc2);
      expect(a, isNot(equals(b)));
    });

    test('equality — never equal to CustomHabitColor', () {
      const builtIn = HabitColor.builtIn(HabitColorType.cc1);
      const custom = CustomHabitColor(0xFF6750A4);
      expect(builtIn, isNot(equals(custom)));
      expect(custom, isNot(equals(builtIn)));
    });

    test('dbColorType returns the colorType', () {
      const color = HabitColor.builtIn(HabitColorType.cc5);
      expect(color.dbColorType, HabitColorType.cc5);
    });

    test('dbCustomColor returns null', () {
      const color = HabitColor.builtIn(HabitColorType.cc1);
      expect(color.dbCustomColor, isNull);
    });

    test('dbCustomColorTinted returns null', () {
      const color = HabitColor.builtIn(HabitColorType.cc1);
      expect(color.dbCustomColorTinted, isNull);
    });

    test('toString includes the colorType', () {
      const color = HabitColor.builtIn(HabitColorType.cc3);
      expect(color.toString(), contains('cc3'));
    });
  });

  group('CustomHabitColor', () {
    test('equality — same argb are equal', () {
      const a = CustomHabitColor(0xFF123456);
      const b = CustomHabitColor(0xFF123456);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality — different argb are unequal', () {
      const a = CustomHabitColor(0xFF123456);
      const b = CustomHabitColor(0xFF654321);
      expect(a, isNot(equals(b)));
    });

    test('equality — same argb but different tinted are unequal', () {
      const a = CustomHabitColor(0xFF123456, tinted: true);
      const b = CustomHabitColor(0xFF123456, tinted: false);
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('tinted defaults to true', () {
      const color = CustomHabitColor(0xFF123456);
      expect(color.tinted, isTrue);
    });

    test('dbColorType returns cc1 as placeholder', () {
      const color = CustomHabitColor(0xFFABCDEF);
      expect(color.dbColorType, HabitColorType.cc1);
    });

    test('dbCustomColor returns the argb', () {
      const color = CustomHabitColor(0xFFABCDEF);
      expect(color.dbCustomColor, 0xFFABCDEF);
    });

    test('dbCustomColorTinted returns 1 when tinted', () {
      const color = CustomHabitColor(0xFFABCDEF, tinted: true);
      expect(color.dbCustomColorTinted, 1);
    });

    test('dbCustomColorTinted returns 0 when not tinted', () {
      const color = CustomHabitColor(0xFFABCDEF, tinted: false);
      expect(color.dbCustomColorTinted, 0);
    });

    test('toString includes the value', () {
      const color = CustomHabitColor(0xFF123456);
      expect(color.toString(), contains('CustomHabitColor'));
      expect(color.toString(), contains('4279383126'));
    });
  });

  group('HabitColor.compareTo', () {
    test('built-in colors are ordered by colorType enum index', () {
      const cc1_ = HabitColor.builtIn(HabitColorType.cc1);
      const cc2_ = HabitColor.builtIn(HabitColorType.cc2);
      const cc10_ = HabitColor.builtIn(HabitColorType.cc10);
      expect(cc1_.compareTo(cc2_), lessThan(0));
      expect(cc2_.compareTo(cc1_), greaterThan(0));
      expect(cc2_.compareTo(cc10_), lessThan(0));
      expect(cc10_.compareTo(cc1_), greaterThan(0));
      expect(cc1_.compareTo(cc1_), 0);
    });

    test('all built-in colors come before custom colors', () {
      const builtIn = HabitColor.builtIn(HabitColorType.cc10);
      const custom = CustomHabitColor(0xFF000000);
      expect(builtIn.compareTo(custom), lessThan(0));
      expect(custom.compareTo(builtIn), greaterThan(0));
    });

    test('custom colors are ordered by argb value', () {
      const low = CustomHabitColor(0x00000000);
      const mid = CustomHabitColor(0x00ABCDEF);
      const high = CustomHabitColor(0xFFFFFFFF);
      expect(low.compareTo(mid), lessThan(0));
      expect(mid.compareTo(high), lessThan(0));
      expect(high.compareTo(low), greaterThan(0));
      expect(mid.compareTo(mid), 0);
    });
  });

  group('HabitColor const constructors', () {
    test('BuiltInHabitColor can be const', () {
      const color = HabitColor.builtIn(HabitColorType.cc1);
      expect(color, isA<BuiltInHabitColor>());
    });

    test('CustomHabitColor can be const', () {
      const color = CustomHabitColor(0xFF123456);
      expect(color, isA<CustomHabitColor>());
    });
  });

  group('Implements Comparable<HabitColor>', () {
    test('List.sort works with HabitColor', () {
      final colors = <HabitColor>[
        const CustomHabitColor(0xFFFFFFFF),
        const HabitColor.builtIn(HabitColorType.cc10),
        const HabitColor.builtIn(HabitColorType.cc1),
        const CustomHabitColor(0x00000000),
      ];
      colors.sort();
      expect(colors, [
        const HabitColor.builtIn(HabitColorType.cc1),
        const HabitColor.builtIn(HabitColorType.cc10),
        const CustomHabitColor(0x00000000),
        const CustomHabitColor(0xFFFFFFFF),
      ]);
    });
  });
}
