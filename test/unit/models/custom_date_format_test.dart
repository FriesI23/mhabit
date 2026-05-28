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

import 'package:mhabit/models/custom_date_format.dart';
import 'package:test/test.dart';

void main() {
  group("CustomDateYmdHmsConfig", () {
    test('Test constructor', () {
      const config = CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.yearMonthDay,
        splitChar: DateSplitCharEnum.dash,
        twelveHoursOn: false,
        useSystemFormat: false,
      );

      expect(config.ymdFormat, YearMonthDayFormtEnum.yearMonthDay);
      expect(config.splitChar, DateSplitCharEnum.dash);
      expect(config.twelveHoursOn, false);
      expect(config.useSystemFormat, false);

      final formatter = config.getFormatter();
      expect(formatter.pattern, 'yyyy-M-d HH:mm:ss');
    });

    test('Test getFormatter with system format', () {
      const config = CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.yearMonthDay,
        splitChar: DateSplitCharEnum.dash,
        twelveHoursOn: false,
        useSystemFormat: false,
      );

      final formatter = config.getFormatter();
      expect(formatter.pattern, 'yyyy-M-d HH:mm:ss');
    });

    test('Test getFormatter with custom format', () {
      const config = CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.monthDayYear,
        splitChar: DateSplitCharEnum.slash,
        twelveHoursOn: true,
        useSystemFormat: false,
      );

      // Fixed `\u202f` for DateFormat pattern in new intl version
      final patternWithRegex = 'M/d/yyyy h:mm:ss a'.replaceAllMapped(
        RegExp(r'\s'),
        (match) => r'\s',
      );
      final formatter = config.getFormatter('en_US');
      expect(formatter.pattern, matches(patternWithRegex));
    });

    test('Test getFormatter with custom format', () {
      const config = CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.dayMonthYear,
        splitChar: DateSplitCharEnum.space,
        twelveHoursOn: false,
        useSystemFormat: false,
      );

      // Fixed `\u202f` for DateFormat pattern in new intl version
      final patternWithRegex = 'd M yyyy HH:mm:ss'.replaceAllMapped(
        RegExp(r'\s'),
        (match) => r'\s',
      );
      final formatter = config.getFormatter('en_US');
      expect(formatter.pattern, matches(patternWithRegex));
    });

    test('Test getFormatter with custom format and month with name', () {
      const config = CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.dayMonthYear,
        splitChar: DateSplitCharEnum.space,
        useMonthWithName: true,
        twelveHoursOn: true,
        useSystemFormat: false,
      );

      // Fixed `\u202f` for DateFormat pattern in new intl version
      final patternWithRegex = 'd LLL y h:mm:ss a'.replaceAllMapped(
        RegExp(r'\s'),
        (match) => r'\s',
      );
      final formatter = config.getFormatter('en_US');
      expect(formatter.pattern, matches(patternWithRegex));
    });
  });
}
