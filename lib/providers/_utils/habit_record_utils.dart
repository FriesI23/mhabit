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

import 'package:tuple/tuple.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_form.dart';
import '../../models/habit_summary.dart';

class ChangeRecordStatusHelper {
  final HabitSummaryData data;
  final HabitRecordDate date;

  const ChangeRecordStatusHelper({
    required this.date,
    required this.data,
  });

  Tuple3<HabitSummaryRecord, HabitSummaryRecord, bool>? getNewRecordOnTap() {
    final HabitSummaryRecord orgRecord;
    final HabitSummaryRecord record;
    final bool isNew;

    if (data.containsRecordDate(date)) {
      orgRecord = data.getRecordByDate(date)!;
      isNew = false;
    } else {
      orgRecord = HabitSummaryRecord.generate(date, parentUUID: data.uuid);
      isNew = true;
    }

    // status changed: unknown -> (done(ok), done(zero), skip)
    // status changed(with valued): unknown -> (done(value), skip)
    final habitRecordForm = HabitDailyRecordForm.getImp(
      type: data.type,
      value: orgRecord.value,
      targetValue: data.dailyGoal,
      extraTargetValue: data.dailyGoalExtra,
    );
    final completeStatus = habitRecordForm.complateStatus;
    final valued = habitRecordForm.isValued;
    switch (orgRecord.status) {
      case HabitRecordStatus.unknown:
      case HabitRecordStatus.skip:
        record = orgRecord.copyWith(
            status: HabitRecordStatus.done,
            value: valued ? orgRecord.value : data.habitOkValue);
        break;
      case HabitRecordStatus.done:
        if (valued) {
          record = orgRecord.copyWith(status: HabitRecordStatus.skip);
        } else {
          if (completeStatus == HabitDailyComplateStatus.ok &&
              orgRecord.value != minHabitDailyGoal) {
            record = orgRecord.copyWith(value: minHabitDailyGoal);
          } else {
            record = orgRecord.copyWith(status: HabitRecordStatus.skip);
          }
        }
        break;
    }

    return Tuple3(orgRecord, record, isNew);
  }

  Tuple3<HabitSummaryRecord, HabitSummaryRecord, bool>? getNewRecordOnLongTap(
      HabitDailyGoal newValue) {
    final HabitSummaryRecord orgRecord;
    final HabitSummaryRecord record;
    final bool isNew;

    if (data.containsRecordDate(date)) {
      orgRecord = data.getRecordByDate(date)!;
      isNew = false;
    } else {
      orgRecord = HabitSummaryRecord.generate(date, parentUUID: data.uuid);
      isNew = true;
    }

    newValue =
        math.max(math.min(newValue, maxHabitdailyGoal), minHabitDailyGoal);
    record =
        orgRecord.copyWith(value: newValue, status: HabitRecordStatus.done);

    return Tuple3(orgRecord, record, isNew);
  }
}
