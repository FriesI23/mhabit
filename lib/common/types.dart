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

import 'package:flutter/material.dart';

import '../model/habit_date.dart';
import '../model/habit_detail_chart.dart';
import '../model/habit_form.dart';
import '../widgets/widget.dart';

typedef DBID = int;

typedef JsonMap = Map<String, dynamic>;

typedef HabitUUID = String;
typedef HabitRecordUUID = String;
typedef HabitDailyGoal = num;
typedef HabitSortPostion = num;
typedef HabitRecordDate = HabitDate;
typedef HabitStartDate = HabitDate;

typedef HabitExportJsonData = String;

typedef OnScoreChangeCallback = void Function(
    HabitDate fromDate, HabitDate toDate, num fromScore, num toScore);

typedef HabitDetailScoreChartBuilder = Widget Function(
  BuildContext context,
  List<MapEntry<HabitDate, HabitDetailScoreChartDate>> data,
  double eachSize,
  int? limit,
  ValueKey<String>? chartKey,
);

typedef HabitDetailFreqChartBuilder = Widget Function(
  BuildContext context,
  List<MapEntry<HabitDate, HabitDetailFreqChartData>> data,
  double eachSize,
  double barWidth,
  double barSpaceBetween,
  HabitFreqChartDisplayMethod displayMethod,
  ValueKey<String>? chartKey,
);

typedef OnHabitSummaryPressCallback = void Function(
  HabitUUID parentUUID,
  HabitRecordUUID? uuid,
  HabitRecordDate date,
  HabitRecordStatus crt,
);

typedef HabitListTilePhysicsBuilder = ScrollPhysics? Function(
    double itemSize, double length);
