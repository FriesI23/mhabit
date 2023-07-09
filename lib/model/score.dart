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

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

import '../common/math.dart';
import '../common/types.dart';
import 'habit_date.dart';
import 'habit_form.dart';
import 'habit_summary.dart';

class HabitScore {
  static const _scoreNormal = 1.0;
  static const _scoreExtraMax = 1.5;
  static const _scoreZero = 0.0;

  final int targetDays;
  final HabitDailyGoal dailyGoal;
  final HabitDailyGoal? dailGoalExtra;
  final HabitType habitType;
  final num _prtZero;
  final num _prtPartial;
  late final Tuple2<num, num> _interval;

  HabitScore(
      {required this.targetDays,
      required this.dailyGoal,
      this.dailGoalExtra,
      this.habitType = HabitType.normal})
      : _prtZero = -100 / targetDays,
        _prtPartial = -100 / targetDays / 2 {
    _interval = Tuple2(
      habitGrowCurve(x: 0, days: targetDays),
      habitGrowCurve(x: targetDays, days: targetDays),
    );
  }

  num get scoreNormal => _scoreNormal;
  num get scoreExtraMax => _scoreExtraMax;
  num get scoreZero => _scoreZero;
  num get prtPartial => _prtPartial;
  num get prtZero => _prtZero;
  num get prtNormal => 0.0;

  @visibleForTesting
  num debugCalcRealScoreExtra(HabitDailyGoal value, HabitDailyGoal targetValue,
      HabitDailyGoal? targetExtendedValue) {
    return _calcRealScoreExtra(
      value,
      targetValue: targetValue,
      targetExtendedValue: targetExtendedValue,
    );
  }

  num _calcRealScoreExtra(HabitDailyGoal value,
      {HabitDailyGoal? targetValue, HabitDailyGoal? targetExtendedValue}) {
    targetValue = targetValue ?? dailyGoal;
    targetExtendedValue = targetExtendedValue ?? dailGoalExtra;
    final scoreExtendedPrt = targetExtendedValue != null
        ? math.max(targetExtendedValue / targetValue, 1)
        : scoreExtraMax;
    final result = (scoreExtraMax - 1) /
            (scoreExtendedPrt - 1) *
            (math.max(value / targetValue, 1) - 1) +
        1;
    return math.min(result, scoreExtraMax);
  }

  num calcDecreasedPrt({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal value = 0.0,
  }) {
    if (autoCompleted) {
      return prtNormal;
    } else {
      switch (status) {
        case HabitRecordStatus.unknown:
          return prtZero;
        case HabitRecordStatus.done:
          switch (HabitDailyRecordForm.getComplateStatus(value, dailyGoal,
              habitType: habitType)) {
            case HabitDailyComplateStatus.zero:
              return prtZero;
            case HabitDailyComplateStatus.tryhard:
              return prtPartial;
            default:
              return prtNormal;
          }
        case HabitRecordStatus.skip:
          return prtNormal;
      }
    }
  }

  num calcIncreasedDay({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal value = 0.0,
  }) {
    if (autoCompleted) {
      switch (status) {
        case HabitRecordStatus.done:
          switch (HabitDailyRecordForm.getComplateStatus(value, dailyGoal,
              habitType: habitType)) {
            case HabitDailyComplateStatus.goodjob:
              return _calcRealScoreExtra(value);
            default:
              return scoreNormal;
          }
        default:
          return scoreNormal;
      }
    } else {
      switch (status) {
        case HabitRecordStatus.done:
          switch (HabitDailyRecordForm.getComplateStatus(value, dailyGoal,
              habitType: habitType)) {
            case HabitDailyComplateStatus.ok:
              return scoreNormal;
            case HabitDailyComplateStatus.goodjob:
              return _calcRealScoreExtra(value);
            default:
              return scoreZero;
          }
        default:
          return scoreZero;
      }
    }
  }

  num calcHabitGrowCurveValue(num x) {
    return habitGrowCurve(x: x, days: targetDays, interv: _interval);
  }

  num calcHabitGrowCurveDay(num y) {
    return habitCrowCurveInverse(y: y, days: targetDays, interv: _interval);
  }

  num getNewScore(num score, num offset) {
    return math.min(math.max(score + offset, 0), 100);
  }

  num getNewDays(num days, num offset, {num targetDays = double.infinity}) {
    return math.min(math.max(days + offset, 0), targetDays);
  }
}

class HabitScoreCalculator {
  final int targetDays;
  final HabitDailyGoal dailyGoal;
  final HabitDailyGoal? dailyGoalExtra;
  final HabitStartDate startDate;
  final HabitRecordDate? endDate;
  final Iterable<HabitDate> iterable;
  final bool Function(HabitDate date) isAutoComplated;
  final HabitSummaryRecord? Function(HabitDate date) getHabitRecord;

  HabitScoreCalculator({
    required this.targetDays,
    required this.dailyGoal,
    this.dailyGoalExtra,
    required this.startDate,
    this.endDate,
    required this.iterable,
    required this.isAutoComplated,
    required this.getHabitRecord,
  });

  void calculate({
    void Function(num score)? onTotalScoreCalculated,
    OnScoreChangeCallback? onScoreChanged,
  }) {
    num crtScore = 0.0;
    num crtDays = 0.0;
    num lastScore = crtScore;

    var habitScore = HabitScore(
      targetDays: targetDays,
      dailyGoal: dailyGoal,
      dailGoalExtra: dailyGoalExtra,
    );
    HabitRecordDate crtDate = startDate;
    var endDate = this.endDate ?? HabitRecordDate.dateTime(DateTime.now());

    for (var date in iterable) {
      if (date > endDate) break;
      if (crtDate > date) continue;

      var duringDays = date.epochDay - crtDate.epochDay;
      lastScore = crtScore;
      crtScore = habitScore.getNewScore(
          crtScore, (duringDays * habitScore.calcDecreasedPrt()));
      if (crtScore != lastScore) {
        onScoreChanged?.call(crtDate, date, lastScore, crtScore);
      }
      if (crtScore >= 100) {
        onTotalScoreCalculated?.call(crtScore);
        return;
      }
      crtDays = habitScore.calcHabitGrowCurveDay(crtScore);
      crtDate = date.addDays(1);

      num increaseDays, decreasePrt;
      var autoComplated = isAutoComplated(date);
      var record = getHabitRecord(date);
      if (record != null) {
        increaseDays = habitScore.calcIncreasedDay(
          autoCompleted: autoComplated,
          status: record.status,
          value: record.value,
        );
        decreasePrt = habitScore.calcDecreasedPrt(
          autoCompleted: autoComplated,
          status: record.status,
          value: record.value,
        );
      } else {
        increaseDays = habitScore.calcIncreasedDay(
          autoCompleted: autoComplated,
        );
        decreasePrt = habitScore.calcDecreasedPrt(
          autoCompleted: autoComplated,
        );
      }

      // debugPrint('calc score:'
      //     ' $date $crtScore $crtDays $increaseDays $decreasePrt'
      //     ' $frequency $targetDays');
      lastScore = crtScore;
      crtScore = habitScore.getNewScore(crtScore, decreasePrt);
      if (crtScore != lastScore) {
        onScoreChanged?.call(date, date, lastScore, crtScore);
      }
      if (crtScore >= 100) {
        onTotalScoreCalculated?.call(crtScore);
        return;
      }
      crtDays = habitScore.calcHabitGrowCurveDay(crtScore);

      // debugPrint('..1 $crtScore $crtDays');
      crtDays = habitScore.getNewDays(crtDays, increaseDays);
      lastScore = crtScore;
      crtScore = habitScore.calcHabitGrowCurveValue(crtDays);
      if (crtScore != lastScore) {
        onScoreChanged?.call(date, date, lastScore, crtScore);
      }
      if (crtScore >= 100) {
        onTotalScoreCalculated?.call(crtScore);
        return;
      }
      // debugPrint('..2 $crtScore $crtDays');
    }

    var lastDuringDays = endDate.epochDay - crtDate.epochDay + 1;
    lastScore = crtScore;
    crtScore = habitScore.getNewScore(
        crtScore, (lastDuringDays * habitScore.calcDecreasedPrt()));
    if (lastScore != crtScore) {
      onScoreChanged?.call(
          crtDate.subtractDays(1), endDate, lastScore, crtScore);
    }
    onTotalScoreCalculated?.call(crtScore);
    // crtDays = habitScore.calcHabitGrowCurveDay(crtScore);
    // debugPrint("$startDate -> $endDate | $crtDate "
    //     "| lastDuringDays=$lastDuringDays, result=$crtScore");
  }
}

class HabitScoreChangedProtoData {
  final HabitDate fromDate;
  final HabitDate toDate;
  final num fromScore;
  final num toScore;

  const HabitScoreChangedProtoData({
    required this.fromDate,
    required this.toDate,
    required this.fromScore,
    required this.toScore,
  });

  num get dailyScoreChangedValue =>
      (toScore - fromScore) / toDate.difference(fromDate).inDays.abs();

  Iterable<MapEntry<HabitDate, num>> expandToDate() sync* {
    if (fromDate == toDate) {
      yield MapEntry(toDate, toScore);
      return;
    }

    var changed = dailyScoreChangedValue;
    var crtDate = fromDate;
    var crtScore = fromScore;

    yield MapEntry(crtDate, crtScore);
    while (crtDate <= toDate) {
      yield MapEntry(crtDate, crtScore);
      crtDate = crtDate.addDays(1);
      crtScore += changed;
    }
  }

  @override
  String toString() {
    return 'HabitScoreChangedProtoData('
        'fromDate: $fromDate, '
        'toDate: $toDate, '
        'fromScore: $fromScore, '
        'toScore: $toScore)';
  }
}
