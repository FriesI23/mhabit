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

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_score.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../stub/habit_score.dart';
import '../utils.dart';

class HabitScoreTestCase extends TestCase {
  static HabitScoreTestCase? _inst;

  HabitScoreTestCase._internal() {
    _inst = this;
  }

  factory HabitScoreTestCase() => _inst ?? HabitScoreTestCase._internal();

  void groupTestFactor() => group("test HabitScore factory", () {
        test('getImp returns instance of NormalHabitScore', () {
          final habitScore = HabitScore.getImp(
            type: HabitType.normal,
            targetDays: 30,
            dailyGoal: 5,
          );

          expect(habitScore, isA<NormalHabitScore>());
        });
      });

  void groupTestScore() => group("test NormalHabitScore", () {
        test("NormalHabitScore::init", () {
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
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
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
          expect(hs.debugCalcRealScoreExtra(10, 100, null), 1.0);
          expect(hs.debugCalcRealScoreExtra(110, 100, null), 1.1);
          expect(hs.debugCalcRealScoreExtra(150, 100, null), 1.5);
          expect(hs.debugCalcRealScoreExtra(200, 100, null), 1.5);
        });

        test("NormalHabitScore::calcRealScoreExtra with extendedVal", () {
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
          expect(hs.debugCalcRealScoreExtra(100, 100, 150), 1.0);
          expect(hs.debugCalcRealScoreExtra(100, 100, 300), 1.0);
          expect(hs.debugCalcRealScoreExtra(200, 100, 150), 1.5);
          expect(hs.debugCalcRealScoreExtra(200, 100, 300), 1.25);
          expect(hs.debugCalcRealScoreExtra(299, 100, 300) < 1.5, true);
          expect(hs.debugCalcRealScoreExtra(300, 100, 300), 1.5);
          expect(hs.debugCalcRealScoreExtra(300, 100, 1100), 1.1);
        });
        test("NormalHabitScore::calcDecreasedPrt:noAutoComplete", () {
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
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
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
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
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
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
          final hs = NormalHabitScore(targetDays: 100, dailyGoal: 10);
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
          final hs = NormalHabitScore(targetDays: 10, dailyGoal: 10);
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
            100.0
          ];
          for (var x in xlist) {
            ylist.add(hs.calcHabitGrowCurveValue(x));
          }
          ylist.forEachIndexed((index, element) {
            assert(
                cylist[index] == num.parse(element.toStringAsFixed(2)), true);
          });
        });
      });

  void groupTestNeScore() => group("test NegativeHabitScore", () {
        test("NormalHabitScore::init", () {
          final hs = NegativeHabitScore(targetDays: 100, dailyGoal: 10);
          expect(hs.targetDays, 100);
          expect(hs.dailyGoal, 10);
          expect(hs.scoreNormal, 1.0);
          expect(hs.scoreZero, 0.0);
          expect(hs.scoreExtraMax, 1.5);
          expect(hs.prtNormal, 0.0);
          expect(hs.prtNoEffect, 0.0);
          expect(hs.prtPartial, -0.5);
        });
        test("NormalHabitScore::calcRealScoreExtra", () {
          final hs = NegativeHabitScore(targetDays: 100, dailyGoal: 10);
          expect(hs.debugCalcRealScoreExtra(99, 100, null), 0);
          expect(hs.debugCalcRealScoreExtra(100, 100, null), 1.0);
          expect(hs.debugCalcRealScoreExtra(101, 100, null), 0);
        });
        test("NormalHabitScore::calcRealScoreExtra with extendedVal", () {
          final hs = NegativeHabitScore(
              targetDays: 100, dailyGoal: 10, dailGoalExtra: 100);
          expect(hs.debugCalcRealScoreExtra(150, 100, 200), 1.25);
          expect(hs.debugCalcRealScoreExtra(100, 100, 150), 1.5);
          expect(hs.debugCalcRealScoreExtra(130, 100, 150), 1.2);
          expect(hs.debugCalcRealScoreExtra(120, 100, 150), 1.3);
          expect(hs.debugCalcRealScoreExtra(110, 100, 150), 1.4);
          expect(hs.debugCalcRealScoreExtra(150, 100, 150), 1.0);
          expect(hs.debugCalcRealScoreExtra(160, 100, 150), 0);
          expect(hs.debugCalcRealScoreExtra(90, 100, 150), 0);
        });
      });

  @override
  void groupCases() {
    groupTestFactor();
    groupTestScore();
    groupTestNeScore();
  }
}

class HabitScoreCalculatorTestCase extends TestCase {
  static HabitScoreCalculatorTestCase? _inst;

  HabitScoreCalculatorTestCase._internal() {
    _inst = this;
  }

  factory HabitScoreCalculatorTestCase() =>
      _inst ?? HabitScoreCalculatorTestCase._internal();

  void groupTestCalc() =>
      group("test HabitScoreCalculator calc total score", () {
        test("HabitScoreCalculator calc normal", () {
          final dateList = <HabitDate>[
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

          final data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
          for (var i in dateList) {
            data[i] = Tuple2(
                HabitSummaryRecord.generate(
                  i,
                  status: HabitRecordStatus.done,
                  value: 10.0,
                  parentUUID: null,
                  uuid: const Uuid().v4(),
                ),
                false);
          }

          final calc = HabitScoreCalculator(
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
          final dateList = <HabitDate>[
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
          final valueList = <num>[
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

          final data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
          dateList.forEachIndexed((index, element) {
            data[element] = Tuple2(
                HabitSummaryRecord.generate(
                  element,
                  status: HabitRecordStatus.done,
                  value: valueList[index],
                  parentUUID: null,
                  uuid: const Uuid().v4(),
                ),
                false);
          });

          final calc = HabitScoreCalculator(
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
          final dateList = <HabitDate>[
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
          final valueList = <num>[
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

          final data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
          dateList.forEachIndexed((index, element) {
            data[element] = Tuple2(
                HabitSummaryRecord.generate(
                  element,
                  status: HabitRecordStatus.done,
                  value: valueList[index],
                  parentUUID: null,
                  uuid: const Uuid().v4(),
                ),
                true);
          });

          final calc = HabitScoreCalculator(
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

          expect(result > 100, true, reason: "test failed, got $result");
        });
      });

  void groupTestCalcSubProgress() =>
      group("test HabitScoreCalculator sub methods", () {
        test('calcEachScoreBetweenRecordDate', () {
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScore.getImp(
                  type: HabitType.normal, targetDays: 20, dailyGoal: 1),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          num result;
          result = calculator.calcEachScoreBetweenRecordDate(
              HabitDate(2023, 1, 5), HabitDate(2023, 1, 1), 50.0);
          expect(result, equals(30.0));
          result = calculator.calcEachScoreBetweenRecordDate(
              HabitDate(2023, 1, 5), HabitDate(2023, 1, 2), 50.0);
          expect(result, equals(35.0));
        });

        test('calcEachScoreBetweenRecordDate (crtDate <= lastDate)', () {
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScore.getImp(
                  type: HabitType.normal, targetDays: 20, dailyGoal: 1),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          for (var c in [
            (HabitDate(2023, 1, 1), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 2), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 3), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 4), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 5)),
          ]) {
            final score = Random().nextDouble() * 100;
            final result =
                calculator.calcEachScoreBetweenRecordDate(c.$1, c.$2, score);
            expect(result, equals(score), reason: "failed $c");
          }

          for (var c in [
            (HabitDate(2023, 1, 6), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 7), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 8), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 9), HabitDate(2023, 1, 5)),
          ]) {
            final score = Random().nextDouble() * 100;
            final result =
                calculator.calcEachScoreBetweenRecordDate(c.$1, c.$2, score);
            expect(result, lessThanOrEqualTo(score), reason: "failed $c");
          }
        });

        test('calcScoreAfterLastRecordToEnd', () {
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScore.getImp(
                  type: HabitType.normal, targetDays: 10, dailyGoal: 1),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          num result;
          result = calculator.calcScoreAfterLastRecordToEnd(
              HabitDate(2023, 1, 10), HabitDate(2023, 1, 13), 70.0);
          expect(result, equals(30.0));
          result = calculator.calcScoreAfterLastRecordToEnd(
              HabitDate(2023, 1, 10), HabitDate(2023, 1, 14), 70.0);
          expect(result, equals(20.0));
        });

        test('calcScoreAfterLastRecordToEnd (endDate < crtDate)', () {
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScore.getImp(
                  type: HabitType.normal, targetDays: 10, dailyGoal: 1),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          for (var c in [
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 1)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 2)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 3)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 4)),
          ]) {
            final score = Random().nextDouble() * 100;
            final result =
                calculator.calcScoreAfterLastRecordToEnd(c.$1, c.$2, score);
            expect(result, equals(score), reason: "failed $c");
          }

          for (var c in [
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 5)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 6)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 7)),
            (HabitDate(2023, 1, 5), HabitDate(2023, 1, 8)),
          ]) {
            final score = Random().nextDouble() * 100;
            final result =
                calculator.calcScoreAfterLastRecordToEnd(c.$1, c.$2, score);
            expect(result, lessThanOrEqualTo(score), reason: "failed $c");
          }
        });

        test('calcIncreaseDaysBetweenRecordDate, no record', () {
          const mockValue = 9.8;
          bool called = false;
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScoreStub.easeTest(
                hookCalcIncreasedDay: (autoCompleted, status, value) {
                  expect(value, null);
                  expect(status, HabitRecordStatus.unknown);
                  expect(autoCompleted, false);
                  called = true;
                  return mockValue;
                },
              ),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          final num result = calculator.calcIncreaseDaysBetweenRecordDate(
              record: null, isAutoCompleted: false);
          expect(result, equals(mockValue));
          expect(called, true);
        });

        test('calcIncreaseDaysBetweenRecordDate, with record', () {
          const mockValue = 9.8;
          const mockStatus = HabitRecordStatus.done;
          bool called = false;
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScoreStub.easeTest(
                hookCalcIncreasedDay: (autoCompleted, status, value) {
                  expect(value, mockValue);
                  expect(status, mockStatus);
                  expect(autoCompleted, true);
                  called = true;
                  return value!;
                },
              ),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          final record = HabitSummaryRecord.generate(
            HabitDate.now(),
            status: mockStatus,
            value: mockValue,
            parentUUID: null,
            uuid: const Uuid().v4(),
          );
          final num result = calculator.calcIncreaseDaysBetweenRecordDate(
              record: record, isAutoCompleted: true);
          expect(result, equals(mockValue));
          expect(called, true);
        });

        test('calcDecreasePrtBetweenRecordDate, no record', () {
          const mockValue = 9.8;
          bool called = false;
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScoreStub.easeTest(
                hookCalcDecreasedPrt: (autoCompleted, status, value) {
                  expect(value, null);
                  expect(status, HabitRecordStatus.unknown);
                  expect(autoCompleted, false);
                  called = true;
                  return mockValue;
                },
              ),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          final num result = calculator.calcDecreasePrtBetweenRecordDate(
              record: null, isAutoCompleted: false);
          expect(result, equals(mockValue));
          expect(called, true);
        });

        test('calcDecreasePrtBetweenRecordDate, with record', () {
          const mockValue = 9.8;
          const mockStatus = HabitRecordStatus.done;
          bool called = false;
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScoreStub.easeTest(
                hookCalcDecreasedPrt: (autoCompleted, status, value) {
                  expect(value, mockValue);
                  expect(status, mockStatus);
                  expect(autoCompleted, true);
                  called = true;
                  return value!;
                },
              ),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          final record = HabitSummaryRecord.generate(
            HabitDate.now(),
            status: mockStatus,
            value: mockValue,
            parentUUID: null,
            uuid: const Uuid().v4(),
          );
          final num result = calculator.calcDecreasePrtBetweenRecordDate(
              record: record, isAutoCompleted: true);
          expect(result, equals(mockValue));
          expect(called, true);
        });

        test('triggerScoreChangedEvent', () {
          final HabitScoreCalculator calculator = HabitScoreCalculator(
              habitScore: HabitScoreStub.easeTest(),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          final bool result1 = calculator.triggerScoreChangedEvent(
              fromDate: HabitDate(2023, 1, 1),
              fromScore: 50.0,
              toDate: HabitDate(2023, 1, 5),
              toScore: 60.0,
              onScoreChanged: (fromDate, toDate, fromScore, toScore) {
                expect(fromScore, equals(50.0));
                expect(toScore, equals(60.0));
              },
              onTotalScoreCalculated: (score) {
                throw AssertionError("Not expect");
              });
          expect(result1, equals(false));

          final bool result2 = calculator.triggerScoreChangedEvent(
              fromDate: HabitDate(2023, 1, 1),
              fromScore: 50.0,
              toDate: HabitDate(2023, 1, 5),
              toScore: 160.0,
              onScoreChanged: (fromDate, toDate, fromScore, toScore) {
                expect(fromScore, equals(50.0));
                expect(toScore, equals(160.0));
              },
              onTotalScoreCalculated: (score) {
                expect(score, equals(160.0));
              });
          expect(result2, equals(true));
        });
      });

  @override
  void groupCases() {
    groupTestCalc();
    groupTestCalcSubProgress();
  }
}

class ArchivedHabitScoreCalculatorTestCase extends TestCase {
  static ArchivedHabitScoreCalculatorTestCase? _inst;

  ArchivedHabitScoreCalculatorTestCase._internal() {
    _inst = this;
  }

  factory ArchivedHabitScoreCalculatorTestCase() =>
      _inst ?? ArchivedHabitScoreCalculatorTestCase._internal();

  void groupTestCalc() =>
      group("test ArchivedHabitScoreCalculator calc total score", () {
        test("ArchivedHabitScoreCalculator calc normal", () {
          final dateList = <HabitDate>[
            HabitDate(2020, 1, 1),
            HabitDate(2020, 1, 2),
            HabitDate(2020, 1, 3),
            HabitDate(2020, 1, 4),
            HabitDate(2020, 1, 5),
          ];

          final data = <HabitDate, Tuple2<HabitSummaryRecord?, bool>>{};
          for (var i in dateList) {
            data[i] = Tuple2(
                HabitSummaryRecord.generate(
                  i,
                  status: HabitRecordStatus.done,
                  value: 10.0,
                  parentUUID: null,
                  uuid: const Uuid().v4(),
                ),
                false);
          }

          final calc = ArchivedHabitScoreCalculator(
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

          final ctrlCalc = HabitScoreCalculator(
            habitScore: HabitScore.getImp(
                type: HabitType.normal, targetDays: 10, dailyGoal: 1),
            startDate: HabitDate(2020, 1, 1),
            endDate: HabitDate(2020, 1, 10),
            iterable: data.keys,
            isAutoComplated: (date) => data[date]!.item2,
            getHabitRecord: (date) => data[date]!.item1,
          );

          num ctrlResult = 0.0;
          ctrlCalc.calculate(
            onTotalScoreCalculated: (score) => ctrlResult = score,
          );

          expect(89 <= result && result <= 90.0, true);
          expect(39 <= ctrlResult && ctrlResult <= 40.0, true);
        });
      });

  void groupTestCalcSubProgress() =>
      group("test ArchivedHabitScoreCalculator sub methods", () {
        test('calcScoreAfterLastRecordToEnd', () {
          final calculator = ArchivedHabitScoreCalculator(
              habitScore: HabitScore.getImp(
                  type: HabitType.normal, targetDays: 10, dailyGoal: 1),
              startDate: HabitDate(2023, 1, 1),
              iterable: [],
              isAutoComplated: (date) => false,
              getHabitRecord: (date) => null);

          num result;
          final randNum = Random().nextDouble() * 100;
          result = calculator.calcScoreAfterLastRecordToEnd(
              HabitDate(2023, 1, 10), HabitDate(2023, 1, 13), randNum);
          expect(result, equals(randNum));
          result = calculator.calcScoreAfterLastRecordToEnd(
              HabitDate(2023, 1, 10), HabitDate(2023, 1, 14), randNum);
          expect(result, equals(randNum));
        });
      });

  @override
  void groupCases() {
    groupTestCalc();
    groupTestCalcSubProgress();
  }
}

void main() {
  for (var element in <TestCase>[
    HabitScoreTestCase(),
    HabitScoreCalculatorTestCase(),
    ArchivedHabitScoreCalculatorTestCase()
  ]) {
    element.groupCases();
  }
}
