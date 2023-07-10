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

import 'habit_form.dart';

abstract class HabitDailyRecordForm {
  final num value;
  final num targetValue;

  const HabitDailyRecordForm(this.value, this.targetValue);

  HabitType get habitType;

  HabitDailyComplateStatus get complateStatus;

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
  HabitType get habitType => HabitType.normal;

  num get targetMinValue => targetValue;

  num get targetMaxValue => targetExtraValue;

  @override
  HabitDailyComplateStatus get complateStatus {
    if (value > targetMaxValue) {
      return HabitDailyComplateStatus.tryhard;
    } else if (value < targetMinValue) {
      return HabitDailyComplateStatus.zero;
    } else if (value == targetMaxValue) {
      return HabitDailyComplateStatus.ok;
    } else {
      return HabitDailyComplateStatus.goodjob;
    }
  }
}
