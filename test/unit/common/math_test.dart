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
import 'package:mhabit/common/math.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('test intervalTrans', () {
    test("intervalTrans 01", () {
      final result = intervalTrans(
        55,
        itervFrom: const Tuple2(0, 100),
        itervTo: const Tuple2(-10, 10),
      );
      expect(result, 1.0);
    });
    test("intervalTrans 02", () {
      final result = intervalTrans(
        24,
        itervFrom: const Tuple2(0, 100),
        itervTo: const Tuple2(-10, 10),
      );
      expect(result, -5.2);
    });
  });
  group('test habitGrowCurve', () {
    test('baisc 10', () {
      final xlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final ylist = <num>[];
      final cylist = [
        0.0,
        2.2,
        6.76,
        15.56,
        30.29,
        50.0,
        69.71,
        84.44,
        93.24,
        97.8,
        100.0,
      ];
      const days = 10;
      final interv = Tuple2(
        habitGrowCurve(x: 0, days: days),
        habitGrowCurve(x: days, days: days),
      );
      for (var x in xlist) {
        ylist.add(habitGrowCurve(x: x, days: days, interv: interv));
      }
      ylist.forEachIndexed((index, element) {
        assert(cylist[index] == num.parse(element.toStringAsFixed(2)), true);
      });
    });
    test('baisc 66', () {
      final xlist = [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
        33,
        34,
        35,
        36,
        37,
        38,
        39,
        40,
        41,
        42,
        43,
        44,
        45,
        46,
        47,
        48,
        49,
        50,
        51,
        52,
        53,
        54,
        55,
        56,
        57,
        58,
        59,
        60,
        61,
        62,
        63,
        64,
        65,
        66,
      ];
      final ylist = <num>[];
      final cylist = [
        0.0,
        0.24,
        0.5,
        0.8,
        1.13,
        1.5,
        1.92,
        2.39,
        2.91,
        3.5,
        4.15,
        4.87,
        5.68,
        6.57,
        7.56,
        8.65,
        9.85,
        11.17,
        12.62,
        14.2,
        15.91,
        17.77,
        19.77,
        21.92,
        24.22,
        26.65,
        29.23,
        31.93,
        34.75,
        37.67,
        40.67,
        43.74,
        46.86,
        50.0,
        53.14,
        56.26,
        59.33,
        62.33,
        65.25,
        68.07,
        70.77,
        73.35,
        75.78,
        78.08,
        80.23,
        82.23,
        84.09,
        85.8,
        87.38,
        88.83,
        90.15,
        91.35,
        92.44,
        93.43,
        94.32,
        95.13,
        95.85,
        96.5,
        97.09,
        97.61,
        98.08,
        98.5,
        98.87,
        99.2,
        99.5,
        99.76,
        100.0,
      ];
      const days = 66;
      final interv = Tuple2(
        habitGrowCurve(x: 0, days: days),
        habitGrowCurve(x: days, days: days),
      );
      for (var x in xlist) {
        ylist.add(habitGrowCurve(x: x, days: days, interv: interv));
      }
      ylist.forEachIndexed((index, element) {
        assert(cylist[index] == num.parse(element.toStringAsFixed(2)), true);
      });
    });
  });

  group('test habitCrowCurveInverse', () {
    test('basic 10', () {
      final cxlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final xlist = <num>[];
      final ylist = [
        0.0,
        2.2,
        6.76,
        15.56,
        30.29,
        50.0,
        69.71,
        84.44,
        93.24,
        97.8,
        100.0,
      ];
      const days = 10;
      final interv = Tuple2(
        habitGrowCurve(x: 0, days: days),
        habitGrowCurve(x: days, days: days),
      );
      for (var y in ylist) {
        xlist.add(habitCrowCurveInverse(y: y, days: days, interv: interv));
      }
      xlist.forEachIndexed((index, element) {
        assert(cxlist[index] == num.parse(element.toStringAsFixed(2)), true);
      });
    });
  });
}
