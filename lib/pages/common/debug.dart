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
import '../../models/habit_color.dart';
import '../../models/habit_date.dart';
import '../../models/habit_export.dart';
import '../../models/habit_form.dart';
import '../../models/habit_freq.dart';
import '../../providers/workflow/group_manager.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../storage/db/handlers/habit.dart';
import '../../utils/app_clock.dart';

const _defaultSliverScrollChildCount = 10;

SliverChildDelegate debugBuildSliverScrollDelegate({int? childCount}) {
  return SliverChildBuilderDelegate((context, index) {
    return Container(
      color: index.isOdd ? Colors.white : Colors.black12,
      height: 100.0,
      child: Center(
        child: Text('$index', textScaler: const TextScaler.linear(5)),
      ),
    );
  }, childCount: childCount ?? _defaultSliverScrollChildCount);
}

mixin HabitsDisplayViewDebug {
  static const _groupNames = ['Many', 'Medium', 'Few'];

  Future<void> debugAddMultiTempHabit(
    BuildContext context, {
    int count = 10,
    bool withGroups = false,
  }) async {
    final access = context.read<HabitImportAccess>();
    final now = AppClock().now().millisecondsSinceEpoch ~/ onSecondMS;
    final rnd = Random();
    final freq = HabitFrequency.custom().toJson();

    // Create groups if enabled
    List<String>? groupUUIDs;
    if (withGroups) {
      final groupManager = context.read<GroupManager>();
      final colorTypes = HabitColorType.values.toList(growable: false);
      final timestamp = (now * onSecondMS).toString();
      final created = await Future.wait(
        _groupNames.indexed.map(
          (entry) => groupManager.createGroup(
            name: '${entry.$2} (Dev $timestamp)',
            color: HabitColor.builtIn(colorTypes[entry.$1 % colorTypes.length]),
          ),
        ),
      );
      groupUUIDs = created.map((g) => g.uuid).toList(growable: false);
    }

    // Distribute habits across groups: many > medium > few when possible
    final manyCount = (count / 2).ceil();
    var mediumCount = ((count - manyCount) / 2).ceil();
    if (mediumCount > 1 && mediumCount == count - manyCount - mediumCount) {
      mediumCount++;
    }
    final boundaries = [manyCount, manyCount + mediumCount, count];

    final habits = <Object?>[];
    for (final i in Iterable.generate(count)) {
      final uuid = genHabitUUID();
      final meta = debugGetRandomHabitMeta(rnd);

      // Determine which group this habit belongs to
      String? groupId;
      if (withGroups && groupUUIDs != null) {
        groupId = groupUUIDs[boundaries.indexWhere((b) => i < b)];
      }

      final dbCell = HabitDBCell(
        type: HabitType.normal.dbCode,
        uuid: uuid,
        groupId: groupId,
        status: HabitStatus.activated.dbCode,
        name: meta.name,
        desc: meta.desc,
        color: HabitColorType
            .values[rnd.nextInt(HabitColorType.values.length)]
            .dbCode,
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

      habits.add(HabitExportData.fromHabitDBCell(dbCell).toJson());
    }

    await Future.wait(access.importHabitsData(habits, withRecords: false));
  }
}
