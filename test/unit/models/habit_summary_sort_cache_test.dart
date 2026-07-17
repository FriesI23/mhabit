// Copyright 2026 Fries_I23
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';

HabitSummaryData _habit({
  required String uuid,
  String name = 'test',
  String? groupId,
}) {
  return HabitSummaryData(
    id: uuid.hashCode,
    uuid: uuid,
    type: HabitType.normal,
    name: name,
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: HabitDate(2026, 1, 1),
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(2026, 1, 1),
    groupId: groupId,
  );
}

void main() {
  group('HabitSummaryDataSortCache', () {
    test('isSameItem returns true for same uuid', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      final b = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      expect(a.isSameItem(b), isTrue);
    });

    test('isSameItem returns false for different uuid', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      final b = HabitSummaryDataSortCache(data: _habit(uuid: 'b'));
      expect(a.isSameItem(b), isFalse);
    });

    test('isSameItem returns false for different type', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      final header = GroupHeaderSortCache(
        groupUUID: 'g1',
        name: 'Group',
        count: 1,
      );
      expect(a.isSameItem(header), isFalse);
    });

    test('isSameItem returns false for null', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      expect(a.isSameItem(null), isFalse);
    });

    test('isSameContent returns true for same uuid', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      final b = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      expect(a.isSameContent(b), isTrue);
    });

    test('isSameContent returns true for different uuid (existing impl)', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      final b = HabitSummaryDataSortCache(data: _habit(uuid: 'b'));
      expect(a.isSameContent(b), isTrue); // existing impl returns true
    });

    test('isSameContent returns false for null', () {
      final a = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      expect(a.isSameContent(null), isFalse);
    });

    test('uuid getter returns data.uuid', () {
      final cache = HabitSummaryDataSortCache(data: _habit(uuid: 'abc'));
      expect(cache.uuid, equals('abc'));
    });
  });

  group('GroupHeaderSortCache', () {
    test('isSameItem returns true for same groupUUID', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      final b = GroupHeaderSortCache(groupUUID: 'g1', name: 'B', count: 2);
      expect(a.isSameItem(b), isTrue);
    });

    test('isSameItem returns false for different groupUUID', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      final b = GroupHeaderSortCache(groupUUID: 'g2', name: 'B', count: 2);
      expect(a.isSameItem(b), isFalse);
    });

    test('isSameItem returns false for null groupUUID', () {
      final a = GroupHeaderSortCache(groupUUID: null, name: '', count: 0);
      final b = GroupHeaderSortCache(groupUUID: null, name: '', count: 0);
      expect(a.isSameItem(b), isTrue);
    });

    test('isSameItem returns false for different type', () {
      final header = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      final habit = HabitSummaryDataSortCache(data: _habit(uuid: 'a'));
      expect(header.isSameItem(habit), isFalse);
    });

    test('isSameItem returns false for null', () {
      final header = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      expect(header.isSameItem(null), isFalse);
    });

    test('isSameContent returns true when fields match', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      final b = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      expect(a.isSameContent(b), isTrue);
    });

    test('isSameContent returns false when name differs', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      final b = GroupHeaderSortCache(groupUUID: 'g1', name: 'B', count: 3);
      expect(a.isSameContent(b), isFalse);
    });

    test('isSameContent returns false when count differs', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      final b = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 5);
      expect(a.isSameContent(b), isFalse);
    });

    test('isSameContent returns false for null', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      expect(a.isSameContent(null), isFalse);
    });

    test('count is mutable', () {
      final header = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 1);
      header.count = 5;
      expect(header.count, equals(5));
    });

    test('isSameContent returns false when icon differs', () {
      final a = GroupHeaderSortCache(
        groupUUID: 'g1',
        name: 'A',
        count: 3,
        icon: GroupIcon.folder,
      );
      final b = GroupHeaderSortCache(
        groupUUID: 'g1',
        name: 'A',
        count: 3,
        icon: GroupIcon.star,
      );
      expect(a.isSameContent(b), isFalse);
    });

    test('isSameContent returns false when color differs', () {
      final a = GroupHeaderSortCache(
        groupUUID: 'g1',
        name: 'A',
        count: 3,
        color: const HabitColor.builtIn(HabitColorType.cc1),
      );
      final b = GroupHeaderSortCache(
        groupUUID: 'g1',
        name: 'A',
        count: 3,
        color: const HabitColor.builtIn(HabitColorType.cc2),
      );
      expect(a.isSameContent(b), isFalse);
    });

    test('isSameContent returns true when icon and color both null', () {
      final a = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      final b = GroupHeaderSortCache(groupUUID: 'g1', name: 'A', count: 3);
      expect(a.isSameContent(b), isTrue);
    });
  });
}
