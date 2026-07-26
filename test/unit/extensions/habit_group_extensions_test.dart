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
import 'package:mhabit/extensions/habit_group_extensions.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_group_display.dart';

HabitGroupData _g({required String uuid, num sortPosition = 9e999}) {
  return HabitGroupData(
    uuid: uuid,
    name: uuid,
    desc: '',
    sortPosition: sortPosition,
  );
}

void main() {
  group('HabitGroupSortExtension.sortedBy(manual)', () {
    test('sorts ascending by sortPosition', () {
      final groups = [
        _g(uuid: 'b', sortPosition: 3.0),
        _g(uuid: 'c', sortPosition: 1.0),
        _g(uuid: 'a', sortPosition: 2.0),
      ];

      final sorted = groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.asc,
      );

      expect(sorted[0].uuid, 'c');
      expect(sorted[1].uuid, 'a');
      expect(sorted[2].uuid, 'b');
    });

    test('desc direction is ignored for manual sort', () {
      final groups = [
        _g(uuid: 'b', sortPosition: 3.0),
        _g(uuid: 'c', sortPosition: 1.0),
        _g(uuid: 'a', sortPosition: 2.0),
      ];

      final sorted = groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.desc,
      );

      expect(sorted[0].uuid, 'c');
      expect(sorted[1].uuid, 'a');
      expect(sorted[2].uuid, 'b');
    });

    test('default sortPosition (9e999) sorts after explicit values', () {
      final groups = [
        _g(uuid: 'a', sortPosition: 5.0),
        _g(uuid: 'b'), // defaults to 9e999
        _g(uuid: 'c', sortPosition: 3.0),
      ];

      final sorted = groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.asc,
      );

      expect(sorted[0].uuid, 'c');
      expect(sorted[1].uuid, 'a');
      expect(sorted[2].uuid, 'b');
    });

    test('same sortPosition maintains relative order (stable sort)', () {
      final groups = [
        _g(uuid: 'a', sortPosition: 2.0),
        _g(uuid: 'b', sortPosition: 2.0),
        _g(uuid: 'c', sortPosition: 2.0),
      ];

      final sorted = groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.asc,
      );

      // All tie — order should be stable (input order)
      expect(sorted[0].uuid, 'a');
      expect(sorted[1].uuid, 'b');
      expect(sorted[2].uuid, 'c');
    });

    test('empty list returns empty', () {
      final groups = <HabitGroupData>[];

      final sorted = groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.asc,
      );

      expect(sorted, isEmpty);
    });

    test('original list is not mutated', () {
      final groups = [
        _g(uuid: 'b', sortPosition: 3.0),
        _g(uuid: 'a', sortPosition: 1.0),
      ];

      groups.sortedBy(
        HabitGroupOrderType.manual,
        HabitDisplaySortDirection.asc,
      );

      expect(groups[0].uuid, 'b');
      expect(groups[1].uuid, 'a');
    });
  });
}
