// Copyright 2025 Fries_I23
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

// ignore_for_file: prefer_const_constructors

import 'package:mhabit/extensions/iterable_extensions.dart';
import 'package:test/test.dart';

void testSortPostionRankExtension() =>
    group("test SortPostionRankExtension", () {
      test('makeUniqueAndIncreasing with empty list', () {
        expect(<num>[].makeUniqueAndIncreasing(1), []);
        expect(<num>[].makeUniqueAndIncreasing(10), []);
      });
      test('makeUniqueAndIncreasing with increment <= 0', () {
        for (var value in [0, -0.1, -10, -999]) {
          expect(
            () => <num>[].makeUniqueAndIncreasing(value),
            throwsA(TypeMatcher<ArgumentError>()),
          );
        }
      });
      test("makeUniqueAndIncreasing", () {
        final cases = <({List<num> input, num increment, List<num> expect})>[];

        void doTest() {
          for (var value in cases) {
            expect(
              value.input.makeUniqueAndIncreasing(value.increment),
              equals(value.expect, 9999),
              reason: "case failed: $value",
            );
          }
        }

        cases.addAll([
          (input: [1, 1, 1, 1], increment: 1, expect: [1, 2, 3, 4]),
          (
            input: [100, 100, 100, 100],
            increment: 50,
            expect: [100, 150, 200, 250],
          ),
          (
            input: [0.1, 0.1, 0.1, 0.1],
            increment: 0.05,
            expect: [0.1, 0.15, 0.2, 0.25],
          ),
          (input: [2, 2, 3, 3, 4, 4], increment: 1, expect: [2, 3, 4, 5, 6, 7]),
          (input: [1, 2, 3, 4, 4], increment: 0.5, expect: [1, 2, 3, 4, 4.5]),
          (
            input: [10, 10, 11, 11, 12, 12],
            increment: 1,
            expect: [10, 11, 12, 13, 14, 15],
          ),
          (input: [5, 5, 5, 6], increment: 2, expect: [5, 7, 9, 11]),
          (
            input: [1, 1.5, 1.5, 2, 2],
            increment: 0.2,
            expect: [1, 1.5, 1.7, 2, 2.2],
          ),
          (
            input: [50, 50, 51, 51, 51],
            increment: 0.5,
            expect: [50, 50.5, 51, 51.5, 52],
          ),
          (input: [0, 0, 0, 0], increment: 0.1, expect: [0, 0.1, 0.2, 0.3]),
          (
            input: [1, 1.99999, 1.99999, 2, 3, 4],
            increment: 0.00001,
            expect: [1, 1.99999, 2, 2.00001, 3, 4],
          ),
        ]);
        doTest();
      });

      test("makeUniqueAndIncreasing with no sorted", () {
        final cases = <({List<num> input, num increment, List<num> expect})>[];

        void doTest() {
          for (var value in cases) {
            expect(
              value.input.makeUniqueAndIncreasing(
                value.increment,
                isSorted: false,
              ),
              equals(value.expect, 9999),
              reason: "case failed: $value",
            );
          }
        }

        cases.addAll([
          (input: [2, 4, 4, 3, 3, 2], increment: 1, expect: [2, 3, 4, 5, 6, 7]),
          (
            input: [10, 10, 11, 11, 12, 12],
            increment: 1,
            expect: [10, 11, 12, 13, 14, 15],
          ),
          (input: [5, 6, 5, 5], increment: 2, expect: [5, 7, 9, 11]),
          (
            input: [2, 1.5, 2, 1, 1.5],
            increment: 0.2,
            expect: [1, 1.5, 1.7, 2, 2.2],
          ),
        ]);
        doTest();
      });

      test("makeUniqueAndIncreasing with custom decimal places", () {
        final cases =
            <
              ({
                List<num> input,
                num increment,
                List<num> expect,
                int decimalPlaces,
              })
            >[];

        void doTest() {
          for (var value in cases) {
            expect(
              value.input.makeUniqueAndIncreasing(
                value.increment,
                decimalPlaces: value.decimalPlaces,
              ),
              equals(value.expect, 9999),
              reason: "case failed: $value",
            );
          }
        }

        cases.addAll([
          (
            input: [0, 0, 0.0001, 0.00011, 0.00022],
            increment: 0.0001,
            expect: [0, 0.0001, 0.0002, 0.00021, 0.00022],
            decimalPlaces: 5,
          ),
          (
            input: [0.1, 0.2, 0.3, 0.4],
            increment: 0.05,
            expect: [0.1, 0.2, 0.3, 0.4], // 结果应保持不变
            decimalPlaces: 2,
          ),
        ]);
        doTest();
      });
    });

void main() {
  testSortPostionRankExtension();
}
