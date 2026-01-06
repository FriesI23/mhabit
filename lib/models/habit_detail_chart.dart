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
import 'package:quiver/core.dart';

import '../common/types.dart';
import 'habit_form.dart';

enum HabitDetailFreqChartCombine { weekly, monthly, yearly }

enum HabitDetailScoreChartCombine { daily, weekly, monthly, yearly }

class HabitHeatMapColorMapDefine {
  static num uncomplate = 0;
  static num partiallyCompleted = 1;
  static num autoComplate = 2;
  static num complate = 3;
  static num overfulfil = 4;
}

class HabitHeatmapCellStatus {
  final HabitRecordStatus? status;
  final bool? isAutoComplete;
  final HabitDailyGoal? value;

  const HabitHeatmapCellStatus({this.status, this.isAutoComplete, this.value});

  @override
  bool operator ==(Object other) {
    if (other is! HabitHeatmapCellStatus) return false;
    return status == other.status &&
        isAutoComplete == other.isAutoComplete &&
        value == other.value;
  }

  @override
  int get hashCode => hash3(status, isAutoComplete, value);

  @override
  String toString() {
    return "HabitHeatmapCellStatus($status, $value, autoComp=$isAutoComplete)";
  }
}

class HabitDetailFreqChartData {
  int _partiallyCompleted;
  int _autoComplate;
  int _complate;
  int _overfulfil;
  num _partiallyCompletedTotalValue;
  num _autoComplateTotalValue;
  num _complateTotalValue;
  num _overfulfilTotalValue;

  HabitDetailFreqChartData({
    int partiallyCompleted = 0,
    int autoComplate = 0,
    int complate = 0,
    int overfulfil = 0,
    num partiallyCompletedTotalValue = 0,
    num autoComplateTotalValue = 0,
    num complateTotalValue = 0,
    num overfulfilTotalValue = 0,
  }) : _partiallyCompleted = partiallyCompleted,
       _autoComplate = autoComplate,
       _complate = complate,
       _overfulfil = overfulfil,
       _partiallyCompletedTotalValue = partiallyCompletedTotalValue,
       _autoComplateTotalValue = autoComplateTotalValue,
       _complateTotalValue = complateTotalValue,
       _overfulfilTotalValue = overfulfilTotalValue,
       assert(
         partiallyCompleted >= 0 &&
             autoComplate >= 0 &&
             complate >= 0 &&
             overfulfil >= 0,
       );

  int get partiallyCompleted => _partiallyCompleted;

  set partiallyCompleted(int value) {
    if (kDebugMode) assert(value >= 0);
    _partiallyCompleted = math.max(0, value);
  }

  int get autoComplate => _autoComplate;

  set autoComplate(int value) {
    if (kDebugMode) assert(value >= 0);
    _autoComplate = math.max(0, value);
  }

  int get complate => _complate;

  set complate(int value) {
    if (kDebugMode) assert(value >= 0);
    _complate = math.max(0, value);
  }

  int get overfulfil => _overfulfil;

  set overfulfil(int value) {
    if (kDebugMode) assert(value >= 0);
    _overfulfil = math.max(0, value);
  }

  num get partiallyCompletedTotalValue => _partiallyCompletedTotalValue;

  set partiallyCompletedTotalValue(num value) {
    if (kDebugMode) assert(value >= 0);
    _partiallyCompletedTotalValue = value;
  }

  num get autoComplateTotalValue => _autoComplateTotalValue;

  set autoComplateTotalValue(num value) {
    if (kDebugMode) assert(value >= 0);
    _autoComplateTotalValue = value;
  }

  num get complateTotalValue => _complateTotalValue;

  set complateTotalValue(num value) {
    if (kDebugMode) assert(value >= 0);
    _complateTotalValue = value;
  }

  num get overfulfilTotalValue => _overfulfilTotalValue;

  set overfulfilTotalValue(num value) {
    if (kDebugMode) assert(value >= 0);
    _overfulfilTotalValue = value;
  }

  void increasedOnly({
    int partiallyCompleted = 0,
    int autoComplate = 0,
    int complate = 0,
    int overfulfil = 0,
    num partiallyCompletedTotalValue = 0,
    num autoComplateTotalValue = 0,
    num complateTotalValue = 0,
    num overfulfilTotalValue = 0,
  }) {
    if (kDebugMode) {
      assert(partiallyCompleted >= 0);
      assert(autoComplate >= 0);
      assert(complate >= 0);
      assert(overfulfil >= 0);
    }

    if (partiallyCompleted > 0) {
      this.partiallyCompleted += partiallyCompleted;
    }
    if (autoComplate > 0) {
      this.autoComplate += autoComplate;
    }
    if (complate > 0) {
      this.complate += complate;
    }
    if (overfulfil > 0) {
      this.overfulfil += overfulfil;
    }
    if (partiallyCompletedTotalValue != 0) {
      this.partiallyCompletedTotalValue += partiallyCompletedTotalValue;
    }
    if (autoComplateTotalValue != 0) {
      this.autoComplateTotalValue += autoComplateTotalValue;
    }
    if (complateTotalValue != 0) {
      this.complateTotalValue += complateTotalValue;
    }
    if (overfulfilTotalValue != 0) {
      this.overfulfilTotalValue += overfulfilTotalValue;
    }
  }

  @override
  String toString() =>
      'HabitDetailFreqChartData('
      'pavo=$_partiallyCompleted|$_autoComplate|$_complate|$_overfulfil,'
      'pv=$_partiallyCompletedTotalValue,'
      'av=$_autoComplateTotalValue,'
      'cv=$_complateTotalValue,'
      'ov=$_overfulfilTotalValue)';
}

class HabitDetailScoreChartDate {
  num totalScore;
  int count;

  HabitDetailScoreChartDate({this.totalScore = 0.0, this.count = 0});

  num get avgScore => count == 0 ? totalScore : totalScore / count;

  void addScore(num score) {
    totalScore += score;
    count += 1;
  }

  @override
  String toString() =>
      'HabitDetailScoreChartDate(ts=$totalScore,c=$count,avs=$avgScore)';
}
