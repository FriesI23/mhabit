// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

HabitDBCell _buildCell({
  required String uuid,
  int colorCode = 1,
  int? customColor,
  int? customColorTinted,
  int typeCode = 1,
  int statusCode = 1,
  String name = 'Test Habit',
  String desc = '',
  num dailyGoal = 1,
  String dailyGoalUnit = 'times',
  int freqType = 1,
  String? freqCustom,
  int startDate = 20000,
  int targetDays = 30,
  num sortPos = 1,
  int createT = 100000,
  int modifyT = 100001,
}) {
  return HabitDBCell(
    id: uuid.hashCode,
    type: typeCode,
    createT: createT,
    modifyT: modifyT,
    uuid: uuid,
    status: statusCode,
    name: name,
    desc: desc,
    color: colorCode,
    customColor: customColor,
    customColorTinted: customColorTinted,
    dailyGoal: dailyGoal,
    dailyGoalUnit: dailyGoalUnit,
    freqType: freqType,
    freqCustom: freqCustom ?? jsonEncode(HabitFrequency.daily.toJson()['args']),
    startDate: startDate,
    targetDays: targetDays,
    sortPosition: sortPos,
  );
}

void main() {
  group('HabitSummaryData.fromDBQueryCell — color resolution', () {
    test('customColor null produces BuiltInHabitColor', () {
      final cell = _buildCell(uuid: 'test-uuid-001', colorCode: 5);
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.color, const HabitColor.builtIn(HabitColorType.cc5));
      expect(data.color.dbCustomColor, isNull);
    });

    test('customColor non-null produces CustomHabitColor', () {
      final cell = _buildCell(
        uuid: 'test-uuid-002',
        colorCode: 1,
        customColor: 0xFFAABBCC,
      );
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.color, const CustomHabitColor(0xFFAABBCC));
      expect(data.color.dbCustomColor, 0xFFAABBCC);
      // dbColorType returns cc1 placeholder for custom colors
      expect(data.color.dbColorType, HabitColorType.cc1);
    });

    test('customColorTinted 0 produces tinted: false', () {
      final cell = _buildCell(
        uuid: 'test-uuid-002b',
        colorCode: 1,
        customColor: 0xFFAABBCC,
        customColorTinted: 0,
      );
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.color, const CustomHabitColor(0xFFAABBCC, tinted: false));
    });

    test('customColorTinted null defaults to tinted: true', () {
      final cell = _buildCell(
        uuid: 'test-uuid-002c',
        colorCode: 1,
        customColor: 0xFFAABBCC,
      );
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.color, const CustomHabitColor(0xFFAABBCC, tinted: true));
    });

    test('customColor non-null with different colorCode still custom', () {
      // Even if colorCode says cc5, customColor being non-null wins.
      final cell = _buildCell(
        uuid: 'test-uuid-003',
        colorCode: 5,
        customColor: 0xFFDDEEFF,
      );
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.color, const CustomHabitColor(0xFFDDEEFF));
      expect(data.color, isNot(const HabitColor.builtIn(HabitColorType.cc5)));
    });

    test('fromDBQueryCell roundtrip — built-in color', () {
      final cell = _buildCell(
        uuid: 'test-uuid-004',
        colorCode: 3,
        name: 'Built-in Habit',
      );
      final data = HabitSummaryData.fromDBQueryCell(cell);

      expect(data.name, 'Built-in Habit');
      expect(data.uuid, 'test-uuid-004');
      expect(data.color, const HabitColor.builtIn(HabitColorType.cc3));
    });
  });

  group('HabitForm.fromHabitDBCell — color resolution', () {
    final editParams = HabitDisplayEditParams(
      uuid: 'edit-uuid-001',
      createT: DateTime(2026, 1, 1),
      modifyT: DateTime(2026, 1, 2),
    );

    test('customColor null produces BuiltInHabitColor', () {
      final cell = _buildCell(uuid: 'edit-uuid-001', colorCode: 7);
      final form = HabitForm.fromHabitDBCell(
        cell,
        editMode: HabitDisplayEditMode.edit,
        editParams: editParams,
      );

      expect(form.color, const HabitColor.builtIn(HabitColorType.cc7));
      expect(form.color.dbCustomColor, isNull);
    });

    test('customColor non-null produces CustomHabitColor', () {
      final cell = _buildCell(
        uuid: 'edit-uuid-002',
        colorCode: 1,
        customColor: 0xFF112233,
      );
      final form = HabitForm.fromHabitDBCell(
        cell,
        editMode: HabitDisplayEditMode.edit,
        editParams: editParams,
      );

      expect(form.color, const CustomHabitColor(0xFF112233));
      expect(form.color.dbCustomColor, 0xFF112233);
      expect(form.color.dbColorType, HabitColorType.cc1);
    });

    test('customColor non-null overrides colorCode', () {
      final cell = _buildCell(
        uuid: 'edit-uuid-003',
        colorCode: 10,
        customColor: 0xFF998877,
      );
      final form = HabitForm.fromHabitDBCell(
        cell,
        editMode: HabitDisplayEditMode.edit,
        editParams: editParams,
      );

      expect(form.color, const CustomHabitColor(0xFF998877));
      expect(form.color, isNot(const HabitColor.builtIn(HabitColorType.cc10)));
    });
  });
}
