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

import '../../common/math.dart';
import '../../common/types.dart';
import '../habit_daily_record_form.dart';
import '../habit_form.dart';

abstract class HabitScore {
  late final int targetDays;
  late final HabitDailyGoal dailyGoal;
  late final HabitDailyGoal? dailGoalExtra;
  late final HabitType habitType;

  factory HabitScore.getImp({
    required HabitType type,
    required int targetDays,
    required HabitDailyGoal dailyGoal,
    HabitDailyGoal? dailGoalExtra,
  }) {
    switch (type) {
      case HabitType.unknown:
      case HabitType.normal:
        return NormalHabitScore(
          targetDays: targetDays,
          dailyGoal: dailyGoal,
          dailGoalExtra: dailGoalExtra,
        );
      case HabitType.negative:
        return NegativeHabitScore(
          targetDays: targetDays,
          dailyGoal: dailyGoal,
          dailGoalExtra: dailGoalExtra,
        );
    }
  }

  num calcDecreasedPrt({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  });

  num calcIncreasedDay({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  });

  num calcHabitGrowCurveValue(num x);

  num calcHabitGrowCurveDay(num y);

  num getNewScore(num score, num offset);

  num getNewDays(num days, num offset, {num targetDays = double.infinity});
}

class NormalHabitScore implements HabitScore {
  @override
  late final int targetDays;
  @override
  late final HabitDailyGoal dailyGoal;
  @override
  late final HabitDailyGoal? dailGoalExtra;
  final num _prtZero;
  final num _prtPartial;
  late final Tuple2<num, num> _interval;

  NormalHabitScore({
    required this.targetDays,
    required this.dailyGoal,
    this.dailGoalExtra,
  })  : _prtZero = -100 / targetDays,
        _prtPartial = -100 / targetDays / 2 {
    _interval = Tuple2(
      habitGrowCurve(x: 0, days: targetDays),
      habitGrowCurve(x: targetDays, days: targetDays),
    );
  }

  @override
  HabitType get habitType => HabitType.normal;

  @override
  set habitType(HabitType newHabitType) {}

  num get scoreNormal => 1.0;
  num get scoreExtraMax => 1.5;
  num get scoreZero => 0.0;
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

  @override
  num calcDecreasedPrt({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  }) {
    value = value ?? 0.0;
    if (autoCompleted) {
      return prtNormal;
    } else {
      switch (status) {
        case HabitRecordStatus.unknown:
          return prtZero;
        case HabitRecordStatus.done:
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
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

  @override
  num calcIncreasedDay({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  }) {
    value = value ?? 0.0;
    if (autoCompleted) {
      switch (status) {
        case HabitRecordStatus.done:
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
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
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
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

  @override
  num calcHabitGrowCurveValue(num x) {
    return habitGrowCurve(x: x, days: targetDays, interv: _interval);
  }

  @override
  num calcHabitGrowCurveDay(num y) {
    return habitCrowCurveInverse(y: y, days: targetDays, interv: _interval);
  }

  @override
  num getNewScore(num score, num offset) {
    return math.min(math.max(score + offset, 0), 100);
  }

  @override
  num getNewDays(num days, num offset, {num targetDays = double.infinity}) {
    return math.min(math.max(days + offset, 0), targetDays);
  }
}

class NegativeHabitScore implements HabitScore {
  @override
  late final int targetDays;
  @override
  late final HabitDailyGoal dailyGoal;
  @override
  late final HabitDailyGoal? dailGoalExtra;
  final num _prtZero;
  final num _prtNoEffect;
  final num _prtPartial;
  late final Tuple2<num, num> _interval;

  NegativeHabitScore({
    required this.targetDays,
    required this.dailyGoal,
    this.dailGoalExtra,
  })  : _prtNoEffect = 0,
        _prtZero = -100 / targetDays,
        _prtPartial = -100 / targetDays / 2 {
    _interval = Tuple2(
      habitGrowCurve(x: 0, days: targetDays),
      habitGrowCurve(x: targetDays, days: targetDays),
    );
  }

  @override
  HabitType get habitType => HabitType.negative;

  @override
  set habitType(HabitType newHabitType) {}

  num get scoreNormal => 1.0;
  num get scoreExtraMax => 1.5;
  num get scoreZero => 0.0;
  num get prtPartial => _prtPartial;
  num get prtZero => _prtZero;
  num get prtNoEffect => _prtNoEffect;
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
    targetExtendedValue = targetExtendedValue ?? dailGoalExtra ?? targetValue;
    if (value < targetValue) {
      return scoreZero;
    } else if (value > targetExtendedValue) {
      return scoreZero;
    } else if (value == targetExtendedValue) {
      return scoreNormal;
    } else if (value == targetValue) {
      return scoreExtraMax;
    } else {
      final progress =
          (value - targetValue) / (targetExtendedValue - targetValue);
      return scoreExtraMax - (progress * (scoreExtraMax - scoreNormal));
    }
  }

  @override
  num calcDecreasedPrt({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  }) {
    value = value ?? 0.0;
    if (autoCompleted) {
      return prtNormal;
    } else {
      switch (status) {
        case HabitRecordStatus.unknown:
          return prtZero;
        case HabitRecordStatus.done:
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
            case HabitDailyComplateStatus.noeffect:
              return prtNoEffect;
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

  @override
  num calcIncreasedDay({
    bool autoCompleted = false,
    HabitRecordStatus status = HabitRecordStatus.unknown,
    HabitDailyGoal? value,
  }) {
    value = value ?? 0.0;
    if (autoCompleted) {
      switch (status) {
        case HabitRecordStatus.done:
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
            case HabitDailyComplateStatus.goodjob:
              return _calcRealScoreExtra(value);
            case HabitDailyComplateStatus.ok:
            default:
              return scoreNormal;
          }
        default:
          return scoreNormal;
      }
    } else {
      switch (status) {
        case HabitRecordStatus.done:
          final completeStatus = HabitDailyRecordForm.getImp(
            type: habitType,
            value: value,
            targetValue: dailyGoal,
            extraTargetValue: dailGoalExtra,
          ).complateStatus;
          switch (completeStatus) {
            case HabitDailyComplateStatus.ok:
              return scoreNormal;
            case HabitDailyComplateStatus.goodjob:
              return _calcRealScoreExtra(value);
            case HabitDailyComplateStatus.noeffect:
            default:
              return scoreZero;
          }
        default:
          return scoreZero;
      }
    }
  }

  @override
  num calcHabitGrowCurveValue(num x) {
    return habitGrowCurve(x: x, days: targetDays, interv: _interval);
  }

  @override
  num calcHabitGrowCurveDay(num y) {
    return habitCrowCurveInverse(y: y, days: targetDays, interv: _interval);
  }

  @override
  num getNewScore(num score, num offset) {
    return math.min(math.max(score + offset, 0), 100);
  }

  @override
  num getNewDays(num days, num offset, {num targetDays = double.infinity}) {
    return math.min(math.max(days + offset, 0), targetDays);
  }
}
