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

  void calculate({
    void Function(num score)? onTotalScoreCalculated,
    OnScoreChangeCallback? onScoreChanged,
  }) {
    num crtScore = 0.0;
    num crtDays = 0.0;
    num lastScore = crtScore;

    HabitRecordDate crtDate = startDate;
    final endDate = this.endDate ?? HabitRecordDate.dateTime(DateTime.now());

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
