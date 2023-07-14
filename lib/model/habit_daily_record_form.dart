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

import 'package:mhabit/common/consts.dart';

import 'habit_form.dart';

abstract class HabitDailyRecordForm {
  final num value;
  final num targetValue;

  const HabitDailyRecordForm(this.value, this.targetValue);

  HabitType get habitType;

  HabitDailyComplateStatus get complateStatus;

  bool get isValued;

  factory HabitDailyRecordForm.getImp({
    required HabitType type,
    required num value,
    required num targetValue,
    num? extraTargetValue,
  }) {
    switch (type) {
      case HabitType.unknown:
      case HabitType.normal:
        return NormalHabitDailyRecordForm(value, targetValue);
      case HabitType.negative:
        return NegativeHabitDailyRecordForm(
            value, targetValue, extraTargetValue ?? targetValue);
    }
  }

  @override
  String toString() {
    return 'HabitDailyRecordForm('
        'value=$value, targetValue=$targetValue, habitType=$habitType, '
        'complateStatus=$complateStatus, '
        'complateStatusValued=$isValued)';
  }
}

class NormalHabitDailyRecordForm extends HabitDailyRecordForm {
  const NormalHabitDailyRecordForm(super.value, super.targetValue);

  @override
  HabitType get habitType => HabitType.normal;

  @override
  HabitDailyComplateStatus get complateStatus {
    if (value > targetValue) {
      return HabitDailyComplateStatus.goodjob;
    } else if (value == targetValue) {
      return HabitDailyComplateStatus.ok;
    } else if (value > 0) {
      return HabitDailyComplateStatus.tryhard;
    } else {
      return HabitDailyComplateStatus.zero;
    }
  }

  @override
  bool get isValued {
    final status = complateStatus;
    return (status != HabitDailyComplateStatus.zero) &&
        (status != HabitDailyComplateStatus.ok);
  }

  @override
  String toString() {
    return 'NormalHabitDailyRecordForm('
        'value=$value, targetValue=$targetValue, habitType=$habitType, '
        'complateStatus=$complateStatus, '
        'complateStatusValued=$isValued)';
  }
}

class NegativeHabitDailyRecordForm extends HabitDailyRecordForm {
  final num targetExtraValue;

  const NegativeHabitDailyRecordForm(
    num value,
    num targetMinValue,
    num targetMaxValue,
  )   : targetExtraValue = targetMaxValue,
        super(value, targetMinValue);

  @override
  HabitType get habitType => HabitType.negative;

  num get targetMinValue => targetValue;

  num get targetMaxValue => targetExtraValue;

  @override
  HabitDailyComplateStatus get complateStatus {
    if (value > targetMaxValue) {
      return HabitDailyComplateStatus.tryhard;
    } else if (value == targetMaxValue) {
      return HabitDailyComplateStatus.ok;
    } else if (value >= targetMinValue) {
      return HabitDailyComplateStatus.goodjob;
    } else if (value == 0) {
      return HabitDailyComplateStatus.zero;
    } else {
      return HabitDailyComplateStatus.noeffect;
    }
  }

  @override
  bool get isValued {
    if (targetMinValue == minHabitDailyGoal) {
      if (targetMaxValue == targetMinValue) {
        return complateStatus != HabitDailyComplateStatus.ok;
      } else if (value == targetMinValue) {
        return false;
      }
    }
    final status = complateStatus;
    return (status != HabitDailyComplateStatus.zero) &&
        (status != HabitDailyComplateStatus.ok);
  }

  @override
  String toString() {
    return 'NegativeHabitDailyRecordForm('
        'value=$value, targetValue=$targetValue, targetExtraValue=$targetExtraValue, '
        'habitType=$habitType, complateStatus=$complateStatus, '
        'complateStatusValued=$isValued)';
  }
}
