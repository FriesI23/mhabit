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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_export.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

void main() {
  group('HabitExportData', () {
    test('round-trips customColor / customColorTinted through'
        ' fromHabitDBCell → toJson → fromJson → toHabitDBCell', () {
      const cell = HabitDBCell(
        type: 1,
        uuid: 'export-roundtrip',
        status: 1,
        name: 'Custom Habit',
        desc: '',
        color: 1,
        customColor: 0xFF336699,
        customColorTinted: 0,
        dailyGoal: 1,
        dailyGoalUnit: 'times',
        freqType: 1,
        freqCustom: '{}',
        startDate: 1,
        targetDays: 1,
        sortPosition: 1,
      );

      final exportData = HabitExportData.fromHabitDBCell(cell);
      final json = exportData.toJson();
      final roundTripped = HabitExportData.fromJson(json);
      final backToCell = roundTripped.toHabitDBCell();

      expect(backToCell.color, 1);
      expect(backToCell.customColor, 0xFF336699);
      expect(backToCell.customColorTinted, 0);

      final habitColor = HabitColor.fromRaw(
        colorType: HabitColorType.getFromDBCode(backToCell.color!)!,
        customColor: backToCell.customColor,
        customColorTinted: backToCell.customColorTinted,
      );
      expect(habitColor, isA<CustomHabitColor>());
      final custom = habitColor as CustomHabitColor;
      expect(custom.argb, 0xFF336699);
      expect(custom.tinted, false);
    });

    test(
      'round-trips built-in color without customColor/customColorTinted',
      () {
        const cell = HabitDBCell(
          type: 1,
          uuid: 'builtin-export-roundtrip',
          status: 1,
          name: 'Built-in Habit',
          desc: '',
          color: 5,
          dailyGoal: 1,
          dailyGoalUnit: 'times',
          freqType: 1,
          freqCustom: '{}',
          startDate: 1,
          targetDays: 1,
          sortPosition: 1,
        );

        final exportData = HabitExportData.fromHabitDBCell(cell);
        final json = exportData.toJson();
        final roundTripped = HabitExportData.fromJson(json);
        final backToCell = roundTripped.toHabitDBCell();

        expect(backToCell.color, 5);
        expect(backToCell.customColor, isNull);
        expect(backToCell.customColorTinted, isNull);

        final habitColor = HabitColor.fromRaw(
          colorType: HabitColorType.getFromDBCode(backToCell.color!)!,
          customColor: backToCell.customColor,
          customColorTinted: backToCell.customColorTinted,
        );
        expect(habitColor, isA<BuiltInHabitColor>());
      },
    );

    test('round-trips groupId through fromHabitDBCell → toJson →'
        ' fromJson → toHabitDBCell', () {
      const cell = HabitDBCell(
        type: 1,
        uuid: 'group-export-roundtrip',
        status: 1,
        name: 'Habit With Group',
        desc: '',
        color: 1,
        dailyGoal: 1,
        dailyGoalUnit: 'times',
        freqType: 1,
        freqCustom: '{}',
        startDate: 1,
        targetDays: 1,
        sortPosition: 1,
        groupId: 'test-group-uuid-123',
      );

      final exportData = HabitExportData.fromHabitDBCell(cell);
      final json = exportData.toJson();
      final roundTripped = HabitExportData.fromJson(json);
      final backToCell = roundTripped.toHabitDBCell();

      expect(backToCell.groupId, 'test-group-uuid-123');
    });

    test('groupId null is excluded from JSON (includeIfNull: false)', () {
      const cell = HabitDBCell(
        type: 1,
        uuid: 'no-group-export',
        status: 1,
        name: 'Habit Without Group',
        desc: '',
        color: 1,
        dailyGoal: 1,
        dailyGoalUnit: 'times',
        freqType: 1,
        freqCustom: '{}',
        startDate: 1,
        targetDays: 1,
        sortPosition: 1,
      );

      final exportData = HabitExportData.fromHabitDBCell(cell);
      final json = exportData.toJson();

      expect(json.containsKey('group_id'), isFalse);

      final roundTripped = HabitExportData.fromJson(json);
      final backToCell = roundTripped.toHabitDBCell();
      expect(backToCell.groupId, isNull);
    });

    test('deserializes group_id from raw JSON map', () {
      final json = {
        'type': 1,
        'uuid': 'from-json-group',
        'status': 1,
        'name': 'From JSON',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
        'group_id': 'imported-group-uuid',
      };

      final data = HabitExportData.fromJson(json);
      expect(data.groupId, 'imported-group-uuid');

      final cell = data.toHabitDBCell();
      expect(cell.groupId, 'imported-group-uuid');
    });

    test('deserializes without group_id as null (backward compat)', () {
      final json = {
        'type': 1,
        'uuid': 'no-group-backward',
        'status': 1,
        'name': 'Old Export',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
      };

      final data = HabitExportData.fromJson(json);
      expect(data.groupId, isNull);

      final cell = data.toHabitDBCell();
      expect(cell.groupId, isNull);
    });
  });
}
