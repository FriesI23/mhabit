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
import 'package:mhabit/model/habit_date.dart';
import 'package:mhabit/model/habit_form.dart';
import 'package:mhabit/model/habit_summary.dart';
import 'package:mhabit/model/habit_score.dart';
import 'package:tuple/tuple.dart';

void main() {
  group("test HabitScore factory", () {
    test('getImp returns instance of NormalHabitScore', () {
      final habitScore = HabitScore.getImp(
        type: HabitType.normal,
        targetDays: 30,
        dailyGoal: 5,
      );

      expect(habitScore, isA<NormalHabitScore>());
    });
  });
  group("test NormalHabitScore", () {
    test("NormalHabitScore::init", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(hs.targetDays, 100);
      expect(hs.dailyGoal, 10);
      expect(hs.scoreNormal, 1.0);
      expect(hs.scoreZero, 0.0);
      expect(hs.scoreExtraMax, 1.5);
      expect(hs.prtNormal, 0.0);
      expect(hs.prtZero, -1.0);
      expect(hs.prtPartial, -0.5);
    });
    test("NormalHabitScore::calcRealScoreExtra", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(hs.debugCalcRealScoreExtra(10, 100, null), 1.0);
      expect(hs.debugCalcRealScoreExtra(110, 100, null), 1.1);
      expect(hs.debugCalcRealScoreExtra(150, 100, null), 1.5);
      expect(hs.debugCalcRealScoreExtra(200, 100, null), 1.5);
    });

    test("NormalHabitScore::calcRealScoreExtra with extendedVal", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(hs.debugCalcRealScoreExtra(100, 100, 150), 1.0);
      expect(hs.debugCalcRealScoreExtra(100, 100, 300), 1.0);
      expect(hs.debugCalcRealScoreExtra(200, 100, 150), 1.5);
      expect(hs.debugCalcRealScoreExtra(200, 100, 300), 1.25);
      expect(hs.debugCalcRealScoreExtra(299, 100, 300) < 1.5, true);
      expect(hs.debugCalcRealScoreExtra(300, 100, 300), 1.5);
      expect(hs.debugCalcRealScoreExtra(300, 100, 1100), 1.1);
    });
    test("NormalHabitScore::calcDecreasedPrt:noAutoComplete", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.unknown,
          value: 0.0,
        ),
        hs.prtZero,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.unknown,
          value: 100.0,
        ),
        hs.prtZero,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.skip,
          value: 0.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.skip,
          value: 100.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 0,
        ),
        hs.prtZero,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 9.0,
        ),
        hs.prtPartial,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 10.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 100.0,
        ),
        hs.prtNormal,
      );
    });
    test("NormalHabitScore::calcDecreasedPrt:autoComplete", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.unknown,
          value: 0.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.unknown,
          value: 100.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.skip,
          value: 0.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.skip,
          value: 100.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 9.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 10.0,
        ),
        hs.prtNormal,
      );
      expect(
        hs.calcDecreasedPrt(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 100.0,
        ),
        hs.prtNormal,
      );
    });
    test("NormalHabitScore::calcIncreasedDay:noAutoComplete", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.unknown,
          value: 0.0,
        ),
        hs.scoreZero,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.skip,
          value: 0.0,
        ),
        hs.scoreZero,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 0.0,
        ),
        hs.scoreZero,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 5.0,
        ),
        hs.scoreZero,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 10.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 15.0,
        ),
        hs.debugCalcRealScoreExtra(15.0, 10.0, null),
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: false,
          status: HabitRecordStatus.done,
          value: 25.0,
        ),
        hs.debugCalcRealScoreExtra(15.0, 10.0, null),
      );
    });
    test("NormalHabitScore::calcIncreasedDay:autoComplete", () {
      var hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.unknown,
          value: 0.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.skip,
          value: 0.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 0.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 5.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 10.0,
        ),
        hs.scoreNormal,
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 15.0,
        ),
        hs.debugCalcRealScoreExtra(15.0, 10.0, null),
      );
      expect(
        hs.calcIncreasedDay(
          autoCompleted: true,
          status: HabitRecordStatus.done,
          value: 25.0,
        ),
        hs.debugCalcRealScoreExtra(15.0, 10.0, null),
      );
    });
    test("NormalHabitScore::calcHabitGrowCurveValue", () {
      var hs = NormalHabitScore(targetDays: 10, dailyGoal: 10);
      var xlist = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      var ylist = <num>[];
      var cylist = [
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
        100.0
      ];
      for (var x in xlist) {
        ylist.add(hs.calcHabitGrowCurveValue(x));
      }
      ylist.forEachIndexed((index, element) {
        assert(cylist[index] == num.parse(element.toStringAsFixed(2)), true);
      });
    });
  });
  group("test HabitScoreCalculator calc total score", () {
    test("HabitScoreCalculator calc normal", () {
      var dateList = <HabitDate>[
        HabitDate(2020, 1, 1),
        HabitDate(2020, 1, 2),
        HabitDate(2020, 1, 3),
        HabitDate(2020, 1, 4),
        HabitDate(2020, 1, 5),
        HabitDate(2020, 1, 6),
        HabitDate(2020, 1, 7),
        HabitDate(2020, 1, 8),
        HabitDate(2020, 1, 9),
        HabitDate(2020, 1, 10),
      ];

      var data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
      for (var i in dateList) {
        data[i] = Tuple2(
            HabitSummaryRecord.generate(
              i,
              status: HabitRecordStatus.done,
              value: 10.0,
            ),
            false);
      }

      var calc = HabitScoreCalculator(
        habitScore: HabitScore.getImp(
            type: HabitType.normal, targetDays: 10, dailyGoal: 1),
        startDate: HabitDate(2020, 1, 1),
        endDate: HabitDate(2020, 1, 10),
        iterable: data.keys,
        isAutoComplated: (date) => data[date]!.item2,
        getHabitRecord: (date) => data[date]!.item1,
      );

      num result = 0.0;
      calc.calculate(
        onTotalScoreCalculated: (score) => result = score,
      );

      expect(result >= 100.0, true);
    });

    test("HabitScoreCalculator calc with some failed", () {
      var dateList = <HabitDate>[
        HabitDate(2020, 1, 1),
        HabitDate(2020, 1, 2),
        HabitDate(2020, 1, 3),
        HabitDate(2020, 1, 4),
        HabitDate(2020, 1, 5),
        HabitDate(2020, 1, 6),
        HabitDate(2020, 1, 7),
        HabitDate(2020, 1, 8),
        HabitDate(2020, 1, 9),
        HabitDate(2020, 1, 10),
      ];
      var valueList = <num>[
        0.0, // d: 0.00 s: 0.00
        0.0, // d: 0.00 s: 0.00
        10.0, // d: 1.00 s: 3.92
        10.0, // d: 2.00 s: 6.76
        13.0, // d: 3.30 s: 19.32
        20.0, // d: 4.80 s: 45.85
        5.0, // d: 4.55 s: 40.86
        10.0, // d: 5.55 s: 61.32
        10.0, // d: 6.55 s: 78.65
        10.0 // d: 7.55 s: 89.97
      ];

      var data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
      dateList.forEachIndexed((index, element) {
        data[element] = Tuple2(
            HabitSummaryRecord.generate(
              element,
              status: HabitRecordStatus.done,
              value: valueList[index],
            ),
            false);
      });

      var calc = HabitScoreCalculator(
        habitScore: HabitScore.getImp(
            type: HabitType.normal, targetDays: 10, dailyGoal: 10.0),
        startDate: HabitDate(2020, 1, 1),
        endDate: HabitDate(2020, 1, 10),
        iterable: data.keys,
        isAutoComplated: (date) => data[date]!.item2,
        getHabitRecord: (date) => data[date]!.item1,
      );

      num result = 0.0;
      calc.calculate(
        onTotalScoreCalculated: (score) => result = score,
      );

      expect(double.parse(result.toStringAsFixed(2)), 89.97);
    });
    test("HabitScoreCalculator calc with automarked", () {
      var dateList = <HabitDate>[
        HabitDate(2020, 1, 1),
        HabitDate(2020, 1, 2),
        HabitDate(2020, 1, 3),
        HabitDate(2020, 1, 4),
        HabitDate(2020, 1, 5),
        HabitDate(2020, 1, 6),
        HabitDate(2020, 1, 7),
        HabitDate(2020, 1, 8),
        HabitDate(2020, 1, 9),
        HabitDate(2020, 1, 10),
      ];
      var valueList = <num>[
        0.0, // d: 0.00 s: 0.00
        0.0, // d: 0.00 s: 0.00
        10.0, // d: 1.00 s: 3.92
        10.0, // d: 2.00 s: 6.76
        13.0, // d: 3.30 s: 19.32
        20.0, // d: 4.80 s: 45.85
        5.0, // d: 4.55 s: 40.86
        10.0, // d: 5.55 s: 61.32
        10.0, // d: 6.55 s: 78.65
        10.0 // d: 7.55 s: 89.97
      ];

      var data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
      dateList.forEachIndexed((index, element) {
        data[element] = Tuple2(
            HabitSummaryRecord.generate(
              element,
              status: HabitRecordStatus.done,
              value: valueList[index],
            ),
            true);
      });

      var calc = HabitScoreCalculator(
        habitScore: HabitScore.getImp(
            type: HabitType.normal, targetDays: 10, dailyGoal: 10.0),
        startDate: HabitDate(2020, 1, 1),
        endDate: HabitDate(2020, 1, 10),
        iterable: data.keys,
        isAutoComplated: (date) => data[date]!.item2,
        getHabitRecord: (date) => data[date]!.item1,
      );

      num result = 0.0;
      calc.calculate(
        onTotalScoreCalculated: (score) => result = score,
      );

      expect(result > 100, true);
    });
  });
}
