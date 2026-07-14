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

import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../common/types.dart';
import '../storage/db/handlers/habit.dart';
import 'common.dart';
import 'habit_form.dart';
import 'habit_group.dart';
import 'habit_summary.dart';

class HabitDetailData implements DirtyMarkMixin {
  final HabitSummaryData _data;
  final DateTime _modifyT;
  final String _dailyGoalUnit;
  final HabitGroupData? _groupData;

  HabitDetailData({
    required HabitSummaryData data,
    required DateTime modifyT,
    required String dailyGoalUnit,
    HabitGroupData? groupData,
  }) : _data = data,
       _modifyT = modifyT,
       _dailyGoalUnit = dailyGoalUnit,
       _groupData = groupData;

  HabitDetailData.fromDBQueryCell(HabitDBCell cell, {HabitGroupData? groupData})
    : _data = HabitSummaryData.fromDBQueryCell(cell),
      _dailyGoalUnit = cell.dailyGoalUnit!,
      _modifyT = DateTime.fromMillisecondsSinceEpoch(
        cell.modifyT! * onSecondMS,
      ),
      _groupData = groupData;

  HabitSummaryData get data => _data;

  Iterable<HabitSummaryRecord> get records => _data.records;

  Iterable<HabitRecordDate> get autoRecordsDate => _data.autoCompletedDates;

  String get name => _data.name;

  HabitType get type => _data.type;

  DateTime get createT => _data.createTime;

  DateTime get modifyT => _modifyT;

  String get dailyGoalUnit => _dailyGoalUnit;

  /// Domain-layer group data, or `null` when no group is assigned.
  HabitGroupData? get groupData => _groupData;

  @override
  Key get diryMark => _data.diryMark;

  @override
  void bumpVersion() {
    _data.bumpVersion();
  }

  @override
  String toString() {
    return "HabitDetailData(data=$data | modifyT=$modifyT)";
  }
}
