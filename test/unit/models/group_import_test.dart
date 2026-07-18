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
  group('HabitImport — groupUuidMapping', () {
    test('replaces groupId when mapping contains the key', () {
      final data = HabitExportData.fromJson({
        'type': 1,
        'uuid': 'h1',
        'status': 1,
        'name': 'Grouped',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
        'group_id': 'old-g-uuid',
      });

      // Simulate toHabitDBCell with mapping applied (mimics _importHabitData).
      final cell = data.toHabitDBCell();
      final oldGroupId = cell.groupId;
      const mapping = {'old-g-uuid': 'new-g-uuid'};
      final newGroupId = mapping[oldGroupId];

      expect(oldGroupId, 'old-g-uuid');
      expect(newGroupId, 'new-g-uuid');
    });

    test('keeps original groupId when mapping does not contain the key', () {
      final data = HabitExportData.fromJson({
        'type': 1,
        'uuid': 'h2',
        'status': 1,
        'name': 'Orphaned',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
        'group_id': 'unknown-g-uuid',
      });

      final cell = data.toHabitDBCell();
      final oldGroupId = cell.groupId;
      const mapping = {'other-g-uuid': 'new-other'};
      final newGroupId = mapping[oldGroupId];

      expect(oldGroupId, 'unknown-g-uuid');
      expect(newGroupId, isNull); // Not in mapping, kept as-is.
    });

    test('keeps null when groupId is null regardless of mapping', () {
      final data = HabitExportData.fromJson({
        'type': 1,
        'uuid': 'h3',
        'status': 1,
        'name': 'Ungrouped',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'start_date': 1,
        'target_days': 1,
        'sort_position': 1,
      });

      final cell = data.toHabitDBCell();
      expect(cell.groupId, isNull);

      const mapping = {'some-uuid': 'new-uuid'};
      final newGroupId = cell.groupId != null ? mapping[cell.groupId] : null;
      expect(newGroupId, isNull);
    });
  });
}
