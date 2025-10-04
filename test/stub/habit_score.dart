// Copyright 2024 Fries_I23
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

import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_score.dart';

class HabitScoreStub implements HabitScore {
  @override
  HabitDailyGoal? dailGoalExtra;
  @override
  HabitDailyGoal dailyGoal;
  @override
  HabitType habitType;
  @override
  int targetDays;

  final HabitScore _super;

  num Function(
          bool autoCompleted, HabitRecordStatus status, HabitDailyGoal? value)?
      hookCalcDecreasedPrt;
  num Function(num y)? hookCalcHabitGrowCurveDay;
  num Function(num x)? hookCalcHabitGrowCurveValue;
  num Function(
          bool autoCompleted, HabitRecordStatus status, HabitDailyGoal? value)?
      hookCalcIncreasedDay;
  num Function(num days, num offset, num targetDays)? hookGetNewDays;
  num Function(num score, num offset)? hookGetNewScore;

  HabitScoreStub(
      {this.dailGoalExtra,
      required this.dailyGoal,
      required this.habitType,
      required this.targetDays,
      this.hookCalcDecreasedPrt,
      this.hookCalcHabitGrowCurveDay,
      this.hookCalcHabitGrowCurveValue,
      this.hookCalcIncreasedDay,
      this.hookGetNewDays,
      this.hookGetNewScore})
      : _super = HabitScore.getImp(
            type: habitType,
            targetDays: targetDays,
            dailyGoal: dailyGoal,
            dailGoalExtra: dailGoalExtra);

  HabitScoreStub.easeTest({
    this.dailyGoal = 1.0,
    this.habitType = HabitType.unknown,
    this.targetDays = 10,
    this.hookCalcDecreasedPrt,
    this.hookCalcHabitGrowCurveDay,
    this.hookCalcHabitGrowCurveValue,
    this.hookCalcIncreasedDay,
    this.hookGetNewDays,
    this.hookGetNewScore,
  }) : _super = HabitScore.getImp(
            type: habitType, targetDays: targetDays, dailyGoal: dailyGoal) {
    hookCalcDecreasedPrt = hookCalcDecreasedPrt ??
        (p0, p1, p2) => throw AssertionError("Not Expect");
    hookCalcHabitGrowCurveDay =
        hookCalcHabitGrowCurveDay ?? (p0) => throw AssertionError("Not Expect");
    hookCalcHabitGrowCurveValue = hookCalcHabitGrowCurveValue ??
        (p0) => throw AssertionError("Not Expect");
    hookCalcIncreasedDay = hookCalcIncreasedDay ??
        (p0, p1, p2) => throw AssertionError("Not Expect");
    hookGetNewDays =
        hookGetNewDays ?? (p0, p1, p2) => throw AssertionError("Not Expect");
    hookGetNewScore =
        hookGetNewScore ?? (p0, p1) => throw AssertionError("Not Expect");
  }

  @override
  num calcDecreasedPrt(
      {bool autoCompleted = false,
      HabitRecordStatus status = HabitRecordStatus.unknown,
      HabitDailyGoal? value}) {
    return hookCalcDecreasedPrt?.call(autoCompleted, status, value) ??
        _super.calcDecreasedPrt(
            autoCompleted: autoCompleted, status: status, value: value);
  }

  @override
  num calcHabitGrowCurveDay(num y) {
    return hookCalcHabitGrowCurveDay?.call(y) ??
        _super.calcHabitGrowCurveDay(y);
  }

  @override
  num calcHabitGrowCurveValue(num x) {
    return hookCalcHabitGrowCurveValue?.call(x) ??
        _super.calcHabitGrowCurveValue(x);
  }

  @override
  num calcIncreasedDay(
      {bool autoCompleted = false,
      HabitRecordStatus status = HabitRecordStatus.unknown,
      HabitDailyGoal? value}) {
    return hookCalcIncreasedDay?.call(autoCompleted, status, value) ??
        _super.calcIncreasedDay(
            autoCompleted: autoCompleted, status: status, value: value);
  }

  @override
  num getNewDays(num days, num offset, {num targetDays = double.infinity}) {
    return hookGetNewDays?.call(days, offset, targetDays) ??
        _super.getNewDays(days, offset, targetDays: targetDays);
  }

  @override
  num getNewScore(num score, num offset) {
    return hookGetNewScore?.call(score, offset) ??
        _super.getNewScore(score, offset);
  }
}
