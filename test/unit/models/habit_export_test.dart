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
  });
}
