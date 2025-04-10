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

import '../../common/types.dart';
import '../habit_date.dart';
import '../habit_form.dart';
import '../habit_summary.dart';
import 'score.dart';

class HabitScoreCalculator {
  static const num kMinScore = 0.0;
  static const num kMaxScore = 100.0;

  final HabitScore _habitScore;
  final HabitStartDate _startDate;
  final HabitRecordDate? _endDate;
  final Iterable<HabitDate> _iterable;
  final bool Function(HabitDate date) _isAutoComplated;
  final HabitSummaryRecord? Function(HabitDate date) _getHabitRecord;

  HabitScoreCalculator({
    required HabitScore habitScore,
    required HabitDate startDate,
    HabitDate? endDate,
    required Iterable<HabitDate> iterable,
    required bool Function(HabitDate) isAutoComplated,
    required HabitSummaryRecord? Function(HabitDate) getHabitRecord,
  })  : _getHabitRecord = getHabitRecord,
        _isAutoComplated = isAutoComplated,
        _iterable = iterable,
        _endDate = endDate,
        _startDate = startDate,
        _habitScore = habitScore;

  Iterable<HabitDate> get _dateIter => _iterable;

  num calcEachScoreBetweenRecordDate(
      HabitDate crtDate, HabitDate lastDate, num lastScore) {
    final duringDays = math.max(0, crtDate.epochDay - lastDate.epochDay);
    return _habitScore.getNewScore(
        lastScore, duringDays * _habitScore.calcDecreasedPrt());
  }

  num calcScoreAfterLastRecordToEnd(
      HabitDate crtDate, HabitDate endDate, num lastScore) {
    final lastDuringDays = math.max(0, endDate.epochDay - crtDate.epochDay + 1);
    return _habitScore.getNewScore(
        lastScore, lastDuringDays * _habitScore.calcDecreasedPrt());
  }

  num calcIncreaseDaysBetweenRecordDate({
    HabitSummaryRecord? record,
    required bool isAutoCompleted,
  }) {
    if (record != null) {
      return _habitScore.calcIncreasedDay(
        autoCompleted: isAutoCompleted,
        status: record.status,
        value: record.value,
      );
    } else {
      return _habitScore.calcIncreasedDay(
        autoCompleted: isAutoCompleted,
      );
    }
  }

  num calcDecreasePrtBetweenRecordDate({
    HabitSummaryRecord? record,
    required bool isAutoCompleted,
  }) {
    if (record != null) {
      return _habitScore.calcDecreasedPrt(
        autoCompleted: isAutoCompleted,
        status: record.status,
        value: record.value,
      );
    } else {
      return _habitScore.calcDecreasedPrt(
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
    // performs the calculation of the habit score and triggers regr events
    num crtScore = kMinScore;
    num crtDays = 0.0;
    num lastScore = crtScore;

    HabitRecordDate crtDate = _startDate;
    final endDate = _endDate ?? HabitRecordDate.dateTime(DateTime.now());

    for (var date in _dateIter) {
      if (date > endDate) break;
      if (crtDate > date) continue;

      // step 1: Calc new score between two record dates
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

      crtDays = _habitScore.calcHabitGrowCurveDay(crtScore);
      crtDate = date.addDays(1);

      // step 2.1: Calc params for score adjustment based on record
      final autoComplated = _isAutoComplated(date);
      final record = _getHabitRecord(date);
      final increaseDays = calcIncreaseDaysBetweenRecordDate(
          record: record, isAutoCompleted: autoComplated);
      final decreasePrt = calcDecreasePrtBetweenRecordDate(
          record: record, isAutoCompleted: autoComplated);
      // step 2.2: Update current score with calculated decrease percentage
      lastScore = crtScore;
      crtScore = _habitScore.getNewScore(crtScore, decreasePrt);
      if (triggerScoreChangedEvent(
        fromDate: date,
        fromScore: lastScore,
        toScore: crtScore,
        onScoreChanged: onScoreChanged,
        onTotalScoreCalculated: onTotalScoreCalculated,
      )) return;

      crtDays = _habitScore.calcHabitGrowCurveDay(crtScore);
      // step 2.3:  Update current score with calculated increase days
      crtDays = _habitScore.getNewDays(crtDays, increaseDays);
      lastScore = crtScore;
      crtScore = _habitScore.calcHabitGrowCurveValue(crtDays);
      if (triggerScoreChangedEvent(
        fromDate: date,
        fromScore: lastScore,
        toScore: crtScore,
        onScoreChanged: onScoreChanged,
        onTotalScoreCalculated: onTotalScoreCalculated,
      )) return;
    }

    // step 4: Calc score from last recorded date to the end
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

class ArchivedHabitScoreCalculator extends HabitScoreCalculator {
  static const _lastSkipStatus = [
    HabitRecordStatus.skip,
    HabitRecordStatus.unknown,
  ];
  late final Iterable<HabitDate> _archivedDateIter;

  ArchivedHabitScoreCalculator(
      {required super.habitScore,
      required super.startDate,
      super.endDate,
      required super.iterable,
      required super.isAutoComplated,
      required super.getHabitRecord}) {
    _initArchivedDateIter();
  }

  void _initArchivedDateIter() {
    final tmpList = List<HabitDate>.of(_iterable);
    for (var i = tmpList.length - 1; i >= 0; i--) {
      final date = tmpList[i];
      if (_isAutoComplated(date)) break;
      final record = _getHabitRecord(date);
      if (!_lastSkipStatus.contains(record?.status)) break;
      tmpList.removeLast();
    }
    _archivedDateIter = tmpList;
  }

  @override
  Iterable<HabitDate> get _dateIter => _archivedDateIter;

  @override
  num calcScoreAfterLastRecordToEnd(
      HabitDate crtDate, HabitDate endDate, num lastScore) {
    return lastScore;
  }
}
