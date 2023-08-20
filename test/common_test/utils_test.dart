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

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/utils.dart';

void main() {
  group("test combineIterables", () {
    test("test normal combine", () {
      var list1 = [1, 4, 7, 10, 99];
      var list2 = [2, 4, 8, 9, 12, 45];
      var list3 = [];
      list3
        ..addAll(list1)
        ..addAll(list2);
      list3.sort();
      combineIterables(list1, list2, compare: (a, b) => a.compareTo(b))
          .forEachIndexed((index, element) {
        assert(element == list3[index], true);
      });
    });
  });
  group('test clamp', () {
    test('clamp should return value within range', () {
      num clampedValue = clamp(5, min: 0, max: 10);
      expect(clampedValue, 5);
    });

    test('clamp should return min when value is less than min', () {
      num clampedValue = clamp(-2, min: 0, max: 10);
      expect(clampedValue, 0);
    });

    test('clamp should return max when value is greater than max', () {
      num clampedValue = clamp(15.0, min: 0.0, max: 10.0);
      expect(clampedValue, 10.0);
    });
  });

  group('test clampInt', () {
    test('clampInt should return value within range', () {
      int clampedValue = clampInt(5, min: 0, max: 10);
      expect(clampedValue, 5);
    });

    test('clampInt should return min when value is less than min', () {
      int clampedValue = clampInt(-2, min: 0, max: 10);
      expect(clampedValue, 0);
    });

    test('clampInt should return max when value is greater than max', () {
      int clampedValue = clampInt(15, min: 0, max: 10);
      expect(clampedValue, 10);
    });
  });
}
