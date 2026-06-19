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
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/db_helper_provider.dart';

void main() {
  group("HabitDBCell", () {
    const habit1 = HabitDBCell(
      id: 1,
      type: 1,
      createT: 0,
      modifyT: 0,
      uuid: '',
      status: 0,
      name: 'name',
      desc: 'desc',
      color: 1,
      dailyGoal: 1.2,
      dailyGoalUnit: 'dailyGoalUnit',
      freqType: 2,
      freqCustom: "freqCustom",
      startDate: 123,
      targetDays: 1,
      remindCustom: "remindCustasdam",
      remindQuestion: "remindQuestion",
      sortPosition: 2,
    );
    const habit2 = HabitDBCell(
      name: 'name',
      desc: 'desc',
      color: 1,
      dailyGoal: 1.2,
      dailyGoalUnit: 'dailyGoalUnit',
      freqType: 2,
      freqCustom: "freqCustom",
      startDate: 123,
      targetDays: 1,
      remindCustom: "remindCustasdam",
      remindQuestion: "remindQuestion",
      sortPosition: 2,
    );
    test("Constructor::fromMap", () {
      final data = {
        "id_": 1,
        "uuid": "31db76a6-da84-4eca-abc4-a419b4920a11",
        "name": "0 overleisured",
        "color": 0,
        "daily_goal": 1.0,
        "target_days": 100,
        "freq_type": 3,
        "freq_custom": "[1, 1]",
        "start_date": 19404,
        "status": 1,
        "sort_position": 1.0,
        "create_t": 1677550818,
      };
      HabitDBCell.fromJson(data);
    });
    test("toMap", () {
      final result1 = habit1.toJson();
      expect(result1[HabitDBCellKey.type], 1);
      expect(result1[HabitDBCellKey.id], 1);
      final result2 = habit2.toJson();
      expect(result2[HabitDBCellKey.name], 'name');
      expect(result2.containsKey(HabitDBCellKey.id), false);
    });
    test('toString', () {
      expect(habit1.toString().startsWith("HabitDB"), true);
    });
  });

  group('HabitDBHelper — customColorTinted round-trip', () {
    // Regression test for a bug where `loadHabitDetail` and
    // `loadHabitAboutDataCollection` explicitly enumerate DB columns to
    // query, and `custom_color_tinted` was added to the table/model but
    // never added to either list — so a saved `tinted: false` value was
    // silently dropped on read and always came back as the "missing"
    // default (tinted-on), even though the write itself was correct.
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('loadHabitDetail and loadHabitAboutDataCollection both return '
        'a saved customColorTinted value', () async {
      final helper = DBHelperViewModel();
      addTearDown(helper.dispose);
      await helper.init();

      final dbHelper = HabitDBHelper(helper.local);
      const habit = HabitDBCell(
        type: 1,
        uuid: 'custom-color-tinted-roundtrip',
        status: 1,
        name: 'name',
        desc: 'desc',
        color: 1,
        customColor: 0xFF112233,
        customColorTinted: 0,
        dailyGoal: 1,
        dailyGoalUnit: 'times',
        freqType: 1,
        freqCustom: '{}',
        startDate: 1,
        targetDays: 1,
        sortPosition: 1,
      );

      await dbHelper.insertNewHabit(habit);

      final detail = await dbHelper.loadHabitDetail(habit.uuid!);
      expect(detail, isNotNull);
      expect(detail!.customColorTinted, 0);

      final collection = await dbHelper.loadHabitAboutDataCollection();
      final loaded = collection.firstWhere((e) => e.uuid == habit.uuid);
      expect(loaded.customColorTinted, 0);
    });
  });
}
