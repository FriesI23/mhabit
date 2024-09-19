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
import 'package:flutter/material.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/model/habit_form.dart';
import 'package:mhabit/model/habit_freq.dart';
import 'package:mhabit/model/habit_summary.dart';

void main() {
  // cusomFreqPerformanceTest(
  //     preRecordNum: 365 * 5, dataNum: 100, days: 7, freq: 3);
  // sinplePerformanceTest(preRecordNum: 365 * 10, days: 99, freq: 2);
  // functionTest();
}

void cusomFreqPerformanceTest(
    {int preRecordNum = 365, dataNum = 1, days = 99, freq = 3}) {
  final rng = Random();
  var crtDate = HabitStartDate(2022, 1, 1);
  final dataList = <HabitSummaryData>[];
  for (var i = 1; i <= dataNum; i++) {
    final data = HabitSummaryData(
      id: i,
      uuid: 'h$i',
      type: HabitType.normal,
      name: 'test_$i',
      desc: '',
      colorType: HabitColorType.cc1,
      dailyGoal: 10.0,
      targetDays: 1000,
      frequency: HabitFrequency.custom(freq: freq, days: days),
      startDate: crtDate,
      status: HabitStatus.activated,
      sortPostion: 1.0,
      createTime: DateTime.now(),
    );
    dataList.add(data);
  }

  for (var data in dataList) {
    for (var i = 0; i < preRecordNum; i++) {
      final nextDayOffset = rng.nextInt(2);
      crtDate = crtDate.addDays(nextDayOffset);
      data.addRecord(HabitSummaryRecord.generate(
        crtDate,
        status: HabitRecordStatus.done,
        value: rng.nextInt(20),
      ));
    }
  }

  final dl = <int>[];
  final Stopwatch stopwatch = Stopwatch();
  for (var data in dataList) {
    stopwatch.start();
    data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
    stopwatch.stop();
    final count = stopwatch.elapsed;
    debugPrint('data $data recalc executed in $count ms');
    dl.add(count.inMicroseconds);
    final sortedData =
        data.debugGetAutoMarkedRecordsCopy().sorted((a, b) => a.compareTo(b));
    debugPrint('dateCount: ${sortedData.length}');
    debugPrint('--------------------------------------------');
    stopwatch.reset();
  }
  debugPrint('all: $dl');
  debugPrint('total: ${dl.sum} ns, ${dl.sum / 1000} ms');
}

void sinplePerformanceTest({int preRecordNum = 365, days = 99, freq = 3}) {
  final rng = Random();
  var crtDate = HabitStartDate(2022, 1, 1);
  final data = HabitSummaryData(
    id: 1,
    uuid: 'hsingle',
    type: HabitType.normal,
    name: 'test_single',
    desc: '',
    colorType: HabitColorType.cc1,
    dailyGoal: 10.0,
    targetDays: 1000,
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

  final dl = <int>[];
  final Stopwatch stopwatch = Stopwatch();
  stopwatch.start();
  data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
  stopwatch.stop();
  final count = stopwatch.elapsed;
  debugPrint('data $data recalc executed in $count ms');
  dl.add(count.inMicroseconds);
  final sortedData =
      data.debugGetAutoMarkedRecordsCopy().sorted((a, b) => a.compareTo(b));
  debugPrint('dateCount: ${sortedData.length}');
  debugPrint('--------------------------------------------');
  stopwatch.reset();
  debugPrint('all: $dl');
  debugPrint('total: ${dl.sum} ns, ${dl.sum / 1000} ms');
}

void functionTest() {
  debugPrint("debug::habit reocrd auto mark");
  final data = HabitSummaryData(
    id: 1,
    uuid: 'h1',
    type: HabitType.normal,
    name: 'test',
    desc: '',
    colorType: HabitColorType.cc1,
    dailyGoal: 10.0,
    targetDays: 1000,
    frequency: HabitFrequency.custom(freq: 1, days: 99),
    startDate: HabitStartDate(2022, 1, 1),
    status: HabitStatus.activated,
    sortPostion: 1.0,
    createTime: DateTime.now(),
  );
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 4),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 5),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 6),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 8),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 16),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 17),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 18),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2022, 1, 22),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));

  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2023, 1, 1),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2024, 1, 1),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));
  data.addRecord(HabitSummaryRecord.generate(
    HabitStartDate(2025, 1, 1),
    status: HabitRecordStatus.done,
    value: 10.0,
  ));

  final Stopwatch stopwatch = Stopwatch()..start();
  data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
  stopwatch.stop();
  debugPrint('executed in ${stopwatch.elapsed.inMilliseconds} ms');
  debugPrint('totalCount:${data.debugGetAutoMarkedRecordsCopy().length}');
}
