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

import '../../common/types.dart';
import '../habit_date.dart';
import '../habit_summary.dart';
import 'score.dart';

class HabitScoreCalculator {
  static const num kMinScore = 0.0;
  static const num kMaxScore = 100.0;

  final HabitScore habitScore;
  final HabitStartDate startDate;
  final HabitRecordDate? endDate;
  final Iterable<HabitDate> iterable;
  final bool Function(HabitDate date) isAutoComplated;
  final HabitSummaryRecord? Function(HabitDate date) getHabitRecord;

  HabitScoreCalculator({
    required this.habitScore,
    required this.startDate,
    this.endDate,
    required this.iterable,
    required this.isAutoComplated,
    required this.getHabitRecord,
  });

  num calcEachScoreBetweenRecordDate(
      HabitDate crtDate, HabitDate lastDate, num lastScore) {
    final duringDays = crtDate.epochDay - lastDate.epochDay;
    return habitScore.getNewScore(
        lastScore, duringDays * habitScore.calcDecreasedPrt());
  }

  num calcScoreAfterLastRecordToEnd(
      HabitDate crtDate, HabitDate endDate, num lastScore) {
    final lastDuringDays = endDate.epochDay - crtDate.epochDay + 1;
    return habitScore.getNewScore(
        lastScore, lastDuringDays * habitScore.calcDecreasedPrt());
  }

  num calcIncreaseDaysBetweenRecordDate({
    HabitSummaryRecord? record,
    required bool isAutoCompleted,
  }) {
    if (record != null) {
      return habitScore.calcIncreasedDay(
        autoCompleted: isAutoCompleted,
        status: record.status,
        value: record.value,
      );
    } else {
      return habitScore.calcIncreasedDay(
        autoCompleted: isAutoCompleted,
      );
    }
  }

  num calcDecreasePrtBetweenRecordDate({
    HabitSummaryRecord? record,
    required bool isAutoCompleted,
  }) {
    if (record != null) {
      return habitScore.calcDecreasedPrt(
        autoCompleted: isAutoCompleted,
        status: record.status,
        value: record.value,
      );
    } else {
      return habitScore.calcDecreasedPrt(
        autoCompleted: isAutoCompleted,
      );
    }
  }

  bool triggerScoreChangedEvent({
    required HabitDate fromDate,
    required num fromScore,
    HabitDate? toDate,
    required num toScore,
    OnScoreChangeCallback? onScoreChanged,
    void Function(num score)? onTotalScoreCalculated,
  }) {
    toDate = toDate ?? fromDate;
    if (fromScore != toScore) {
      onScoreChanged?.call(fromDate, toDate, fromScore, toScore);
    }
    if (toScore > kMaxScore) {
      onTotalScoreCalculated?.call(toScore);
      return true;
    }
    return false;
  }

  void calculate({
    void Function(num score)? onTotalScoreCalculated,
    OnScoreChangeCallback? onScoreChanged,
  }) {
    num crtScore = kMinScore;
    num crtDays = 0.0;
    num lastScore = crtScore;

    HabitRecordDate crtDate = startDate;
    final endDate = this.endDate ?? HabitRecordDate.dateTime(DateTime.now());

    for (var date in iterable) {
      if (date > endDate) break;
      if (crtDate > date) continue;

      lastScore = crtScore;
      crtScore = calcEachScoreBetweenRecordDate(date, crtDate, crtScore);
      if (triggerScoreChangedEvent(
        fromDate: crtDate,
        fromScore: lastScore,
        toDate: date,
        toScore: crtScore,
        onScoreChanged: onScoreChanged,
        onTotalScoreCalculated: onTotalScoreCalculated,
      )) return;

      crtDays = habitScore.calcHabitGrowCurveDay(crtScore);
      crtDate = date.addDays(1);

      final autoComplated = isAutoComplated(date);
      final record = getHabitRecord(date);
      final increaseDays = calcIncreaseDaysBetweenRecordDate(
          record: record, isAutoCompleted: autoComplated);
      final decreasePrt = calcDecreasePrtBetweenRecordDate(
          record: record, isAutoCompleted: autoComplated);

      lastScore = crtScore;
      crtScore = habitScore.getNewScore(crtScore, decreasePrt);
      if (triggerScoreChangedEvent(
        fromDate: date,
        fromScore: lastScore,
        toScore: crtScore,
        onScoreChanged: onScoreChanged,
        onTotalScoreCalculated: onTotalScoreCalculated,
      )) return;

      crtDays = habitScore.calcHabitGrowCurveDay(crtScore);

      crtDays = habitScore.getNewDays(crtDays, increaseDays);
      lastScore = crtScore;
      crtScore = habitScore.calcHabitGrowCurveValue(crtDays);
      if (triggerScoreChangedEvent(
        fromDate: date,
        fromScore: lastScore,
        toScore: crtScore,
        onScoreChanged: onScoreChanged,
        onTotalScoreCalculated: onTotalScoreCalculated,
      )) return;
    }

    lastScore = crtScore;
    crtScore = calcScoreAfterLastRecordToEnd(crtDate, endDate, crtScore);
    if (triggerScoreChangedEvent(
      fromDate: crtDate.subtractDays(1),
      fromScore: lastScore,
      toDate: endDate,
      toScore: crtScore,
      onScoreChanged: onScoreChanged,
      onTotalScoreCalculated: onTotalScoreCalculated,
    )) {
      return;
    } else {
      onTotalScoreCalculated?.call(crtScore);
    }
  }
}
