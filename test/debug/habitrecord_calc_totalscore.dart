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

import 'package:flutter/foundation.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/model/habit_form.dart';
import 'package:mhabit/model/habit_freq.dart';
import 'package:mhabit/model/habit_summary.dart';

void main() {
  sinplePerformanceTest(preRecordNum: 365, days: 7, freq: 3);
}

void sinplePerformanceTest({int preRecordNum = 365, days = 5, freq = 3}) {
  final rng = Random();
  final starDate = HabitStartDate(2022, 1, 1);
  var crtDate = starDate;
  final data = HabitSummaryData(
    id: 1,
    uuid: 'hsingle',
    type: HabitType.normal,
    name: 'test_single',
    desc: '',
    colorType: HabitColorType.cc1,
    dailyGoal: 15.0,
    targetDays: 100,
    frequency: HabitFrequency.custom(freq: freq, days: days),
    startDate: crtDate,
    status: HabitStatus.activated,
    sortPostion: 1.0,
    createTime: DateTime.now(),
  );

  for (var i = 0; i < preRecordNum; i++) {
    crtDate = crtDate.addDays(1);
    data.addRecord(HabitSummaryRecord.generate(
      crtDate,
      status: HabitRecordStatus.done,
      value: rng.nextInt(20),
    ));
  }

  final Stopwatch stopwatch = Stopwatch();
  data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
  stopwatch.start();
  final r = data.debugCalcTotalScore(endDate: starDate.addDays(preRecordNum));
  stopwatch.stop();
  debugPrint('run in: ${stopwatch.elapsed.inMilliseconds} ms, r=$r');
}
