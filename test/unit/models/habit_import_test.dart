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
import 'package:mhabit/models/habit_export.dart';

void main() {
  group('HabitImport — groupId preservation', () {
    test('HabitExportData.fromJson with group_id preserves it in'
        ' toHabitDBCell', () {
      final json = {
        'type': 1,
        'uuid': 'import-g1',
        'status': 1,
        'name': 'Grouped Habit',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
        'group_id': 'group-uuid-abc',
      };

      final data = HabitExportData.fromJson(json);
      expect(data.groupId, 'group-uuid-abc');

      final cell = data.toHabitDBCell();
      expect(cell.groupId, 'group-uuid-abc');
      expect(cell.name, 'Grouped Habit');
    });

    test('HabitExportData.fromJson without group_id produces null groupId', () {
      final json = {
        'type': 1,
        'uuid': 'import-no-group',
        'status': 1,
        'name': 'Ungrouped Habit',
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
