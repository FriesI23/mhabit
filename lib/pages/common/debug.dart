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

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../common/debug.dart';
import '../../common/utils.dart';
import '../../models/habit_date.dart';
import '../../models/habit_form.dart';
import '../../models/habit_freq.dart';
import '../../storage/db/handlers/habit.dart';
import '../../storage/db_helper_provider.dart';

const _defaultSliverScrollChildCount = 10;

SliverChildDelegate debugBuildSliverScrollDelegate({int? childCount}) {
  return SliverChildBuilderDelegate(
    (context, index) {
      return Container(
        color: index.isOdd ? Colors.white : Colors.black12,
        height: 100.0,
        child: Center(
          child: Text('$index', textScaler: const TextScaler.linear(5)),
        ),
      );
    },
    childCount: childCount ?? _defaultSliverScrollChildCount,
  );
}

mixin HabitsDisplayViewDebug {
  Future<void> debugAddMultiTempHabit(BuildContext context,
      {int count = 10}) async {
    final dbHelper = context.read<DBHelperViewModel>();
    if (!dbHelper.mounted) return;

    final tasks = <Future>[];
    final now = DateTime.now().millisecondsSinceEpoch ~/ onSecondMS;
    final rnd = Random();
    final freq = HabitFrequency.custom().toJson();
    for (var i = 0; i < count; i++) {
      final uuid = genHabitUUID();
      final meta = debugGetRandomHabitMeta(rnd);
      final dbCell = HabitDBCell(
        type: HabitType.normal.dbCode,
        uuid: uuid,
        status: HabitStatus.activated.dbCode,
        name: meta.name,
        desc: meta.desc,
        color: HabitColorType
            .values[rnd.nextInt(HabitColorType.values.length)].dbCode,
        dailyGoal: meta.goal,
        dailyGoalUnit: meta.goalUnit,
        freqType: freq["type"],
        freqCustom: jsonEncode(freq["args"]),
        startDate: HabitDate.now().epochDay - rnd.nextInt(365),
        targetDays: 21 + rnd.nextInt(200),
        sortPosition: double.infinity,
        // remindCustom: jsonEncode(HabitReminder.dailyMidnight.toJson()),
        // remindQuestion: "Remind Question: tttt",
        createT: now,
        modifyT: now,
      );

      tasks.add(HabitDBHelper(dbHelper.local).insertNewHabit(dbCell));
    }

    await Future.wait(tasks);
  }
}
