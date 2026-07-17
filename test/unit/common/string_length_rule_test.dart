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
import 'package:mhabit/common/rules.dart';

void main() {
  group('SimpleStringLengthRule', () {
    test('clamp: returns original when within softLimit', () {
      const rule = SimpleStringLengthRule(10);
      expect(rule.clamp('hello'), 'hello');
    });

    test('clamp: returns original at exactly softLimit', () {
      const rule = SimpleStringLengthRule(10);
      expect(rule.clamp('1234567890'), '1234567890');
    });

    test('clamp: truncates to softLimit when exceeded', () {
      const rule = SimpleStringLengthRule(5);
      expect(rule.clamp('hello world'), 'hello');
    });

    test('hardLimit defaults to softLimit when not specified', () {
      const rule = SimpleStringLengthRule(10);
      expect(rule.hardLimit, 10);
      expect(rule.softLimit, 10);
    });

    test('hardLimit can differ from softLimit', () {
      const rule = SimpleStringLengthRule(10, hardLimit: 20);
      expect(rule.softLimit, 10);
      expect(rule.hardLimit, 20);
    });
  });

  group('groupNameRule', () {
    test('softLimit is 100', () {
      expect(groupNameRule.softLimit, 100);
    });

    test('hardLimit equals softLimit (default)', () {
      expect(groupNameRule.hardLimit, 100);
    });

    test('clamps name longer than 100 chars', () {
      final longName = 'A' * 150;
      final clamped = groupNameRule.clamp(longName);
      expect(clamped.length, 100);
      expect(clamped, startsWith('AAA'));
    });
  });

  group('groupDescRule', () {
    test('softLimit is 300', () {
      expect(groupDescRule.softLimit, 300);
    });

    test('hardLimit is 600', () {
      expect(groupDescRule.hardLimit, 600);
    });

    test('clamps desc to 300 (softLimit)', () {
      final longDesc = 'B' * 500;
      final clamped = groupDescRule.clamp(longDesc);
      expect(clamped.length, 300);
    });
  });
}
