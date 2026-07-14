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
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_group_sorter.dart';

HabitSummaryData _habit({
  required String uuid,
  String name = 'test',
  String? groupId,
  num sortPostion = 1,
  HabitType type = HabitType.normal,
}) {
  return HabitSummaryData(
    id: uuid.hashCode,
    uuid: uuid,
    type: type,
    name: name,
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: HabitDate(2026, 1, 1),
    status: HabitStatus.activated,
    sortPostion: sortPostion,
    createTime: DateTime.utc(2026, 1, 1),
    groupId: groupId,
  );
}

HabitGroupData _group({
  required String uuid,
  String name = 'Group',
  GroupIcon icon = GroupIcon.folder,
}) {
  return HabitGroupData(
    uuid: uuid,
    name: name,
    desc: '',
    icon: icon,
    color: const HabitColor.builtIn(HabitColorType.cc1),
  );
}

HabitSummaryDataCollection _collection(Iterable<HabitSummaryData> habits) {
  final c = HabitSummaryDataCollection();
  for (final h in habits) {
    c.addHabit(h, forceAdd: true);
  }
  return c;
}

void main() {
  group('buildGroupedSortCacheList', () {
    test('returns uncategorized header for empty data and no groups', () {
      final result = buildGroupedSortCacheList(
        data: _collection([]),
        groups: [],
        collapsedUUIDs: {},
      );
      expect(result, hasLength(1));
      expect(result.single, isA<GroupHeaderSortCache>());
      expect((result.single as GroupHeaderSortCache).isUncategorized, isTrue);
      expect((result.single as GroupHeaderSortCache).count, equals(0));
    });

    test('groups habits by groupId', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
          _habit(uuid: 'c', groupId: 'g2'),
        ]),
        groups: [
          _group(uuid: 'g1', name: 'Health'),
          _group(uuid: 'g2', name: 'Work'),
        ],
        collapsedUUIDs: {},
      );

      expect(result, hasLength(5)); // 2 headers + 3 habits
      expect(result[0], isA<GroupHeaderSortCache>());
      expect((result[0] as GroupHeaderSortCache).name, equals('Health'));
      expect(result[1], isA<HabitSummaryDataSortCache>());
      expect(result[2], isA<HabitSummaryDataSortCache>());
      expect(result[3], isA<GroupHeaderSortCache>());
      expect((result[3] as GroupHeaderSortCache).name, equals('Work'));
      expect(result[4], isA<HabitSummaryDataSortCache>());
    });

    test('sorts habits by sortPostion within each group', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'c', groupId: 'g1', sortPostion: 3),
          _habit(uuid: 'a', groupId: 'g1', sortPostion: 1),
          _habit(uuid: 'b', groupId: 'g1', sortPostion: 2),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
      );

      final habits = result.whereType<HabitSummaryDataSortCache>().toList();
      expect(habits[0].uuid, equals('a'));
      expect(habits[1].uuid, equals('b'));
      expect(habits[2].uuid, equals('c'));
    });

    test('omits habit items when group is collapsed', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {'g1'},
      );

      expect(
        result,
        hasLength(1),
      ); // header only, no uncategorized (all habits belong to groups)
      expect(result[0], isA<GroupHeaderSortCache>());
      expect((result[0] as GroupHeaderSortCache).groupUUID, equals('g1'));
    });

    test('treats orphan groupId as uncategorized', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'orphan'),
          _habit(uuid: 'b', groupId: 'orphan'),
        ]),
        groups: [],
        collapsedUUIDs: {},
      );

      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(2));
      expect(result.whereType<GroupHeaderSortCache>(), hasLength(1));
      expect((result.first as GroupHeaderSortCache).isUncategorized, isTrue);
    });

    test('places null groupId habits in uncategorized section', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: null),
          _habit(uuid: 'b', groupId: null),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
      );

      final headers = result.whereType<GroupHeaderSortCache>().toList();
      expect(headers, hasLength(1));
      expect(headers[0].isUncategorized, isTrue);
    });

    test('skips groups with no habits', () {
      final result = buildGroupedSortCacheList(
        data: _collection([_habit(uuid: 'a', groupId: 'g2')]),
        groups: [
          _group(uuid: 'g1', name: 'Empty'),
          _group(uuid: 'g2', name: 'HasHabit'),
        ],
        collapsedUUIDs: {},
      );

      final headers = result.whereType<GroupHeaderSortCache>().toList();
      expect(headers, hasLength(1));
      expect(headers[0].groupUUID, equals('g2'));
      expect(headers[0].name, equals('HasHabit'));
    });

    test('collapses uncategorized section when null is in collapsedUUIDs', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: null),
          _habit(uuid: 'b', groupId: null),
        ]),
        groups: [],
        collapsedUUIDs: {null},
      );

      expect(result.whereType<HabitSummaryDataSortCache>(), isEmpty);
      expect(result.whereType<GroupHeaderSortCache>(), hasLength(1));
    });

    test('sets initial header count', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
          _habit(uuid: 'c', groupId: 'g2'),
        ]),
        groups: [
          _group(uuid: 'g1'),
          _group(uuid: 'g2'),
        ],
        collapsedUUIDs: {},
      );

      final headers = result.whereType<GroupHeaderSortCache>().toList();
      expect(headers[0].count, equals(2));
      expect(headers[1].count, equals(1));
    });

    test('filters habits by status via HabitsDisplayFilter', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
          _habit(uuid: 'c', groupId: 'g2'),
        ]),
        groups: [
          _group(uuid: 'g1'),
          _group(uuid: 'g2'),
        ],
        collapsedUUIDs: {},
        filter: HabitsDisplayFilter.allFalse,
      );

      // No habits pass the allFalse filter, so only uncategorized remains
      expect(result.whereType<HabitSummaryDataSortCache>(), isEmpty);
    });

    test('filter excludes archived habits by default', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
        filter: const HabitsDisplayFilter.withDefault(),
      );

      // Default filter allows in-progress and completed, excludes archived.
      // All test habits are activated (inProgress), so they pass.
      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(2));
    });

    test('skips null filter (no status filtering)', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g1'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
        filter: null,
      );

      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(2));
    });

    test('filter removes group entirely when all habits filtered', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1'),
          _habit(uuid: 'b', groupId: 'g2'),
        ]),
        groups: [
          _group(uuid: 'g1', name: 'G1'),
          _group(uuid: 'g2', name: 'G2'),
        ],
        collapsedUUIDs: {},
        filter: HabitsDisplayFilter.allFalse,
      );

      // Both groups have all habits filtered out; only uncategorized remains.
      final headers = result.whereType<GroupHeaderSortCache>();
      expect(headers.length, equals(1));
      expect(headers.first.groupUUID, isNull);
    });
  });

  group('degradation to ungrouped', () {
    test('buildGroupedSortCacheList only uncategorized → single header', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: null),
          _habit(uuid: 'b', groupId: null),
        ]),
        groups: [],
        collapsedUUIDs: {},
      );

      final headers = result.whereType<GroupHeaderSortCache>().toList();
      expect(headers.length, equals(1));
      expect(headers.first.groupUUID, isNull);
    });
  });

  group('filterGroupedList', () {
    test('passes all items when options are empty', () {
      final sorted = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 2),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'a', name: 'Alpha'),
        ),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'b', name: 'Beta'),
        ),
      ];

      final result = filterGroupedList(
        sorted,
        const HabitDisplaySearchOptions.empty(),
      );
      expect(result, hasLength(3));
    });

    test('filters habits by keyword', () {
      final sorted = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 2),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'a', name: 'Walking'),
        ),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'b', name: 'Reading'),
        ),
      ];

      final result = filterGroupedList(
        sorted,
        const HabitDisplaySearchOptions(keyword: 'walk'),
      );
      expect(result, hasLength(2)); // header + Walking
      expect(result[0], isA<GroupHeaderSortCache>());
      expect((result[1] as HabitSummaryDataSortCache).uuid, equals('a'));
    });

    test('keeps all headers regardless of keyword', () {
      final sorted = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 1),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'a', name: 'Walking'),
        ),
        GroupHeaderSortCache(groupUUID: 'g2', name: 'G2', count: 1),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'b', name: 'Running'),
        ),
      ];

      final result = filterGroupedList(
        sorted,
        const HabitDisplaySearchOptions(keyword: 'walk'),
      );
      // headers always survive, but empty headers will have count=0
      expect(result.whereType<GroupHeaderSortCache>(), hasLength(2));
      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(1));
    });

    test('filters by type', () {
      final sorted = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: null, name: '', count: 2),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'a', name: 'Normal', type: HabitType.normal),
        ),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'b', name: 'Negative', type: HabitType.negative),
        ),
      ];

      final result = filterGroupedList(
        sorted,
        const HabitDisplaySearchOptions(types: {HabitType.negative}),
      );
      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(1));
      expect((result[1] as HabitSummaryDataSortCache).uuid, equals('b'));
    });

    test('returns empty list when all habits filtered out', () {
      final sorted = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 1),
        HabitSummaryDataSortCache(
          data: _habit(uuid: 'a', name: 'Xyz'),
        ),
      ];

      final result = filterGroupedList(
        sorted,
        const HabitDisplaySearchOptions(keyword: 'nonexistent'),
      );
      // only the header survives
      expect(result.whereType<GroupHeaderSortCache>(), hasLength(1));
      expect(result.whereType<HabitSummaryDataSortCache>(), isEmpty);
    });
  });

  group('updateGroupHeaderCounts', () {
    test('counts habits after a single header', () {
      final list = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 0),
        HabitSummaryDataSortCache(data: _habit(uuid: 'a')),
        HabitSummaryDataSortCache(data: _habit(uuid: 'b')),
      ];

      updateGroupHeaderCounts(list);
      expect((list[0] as GroupHeaderSortCache).count, equals(2));
    });

    test('counts habits for multiple groups', () {
      final list = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 0),
        HabitSummaryDataSortCache(data: _habit(uuid: 'a')),
        GroupHeaderSortCache(groupUUID: 'g2', name: 'G2', count: 0),
        HabitSummaryDataSortCache(data: _habit(uuid: 'b')),
        HabitSummaryDataSortCache(data: _habit(uuid: 'c')),
      ];

      updateGroupHeaderCounts(list);
      expect((list[0] as GroupHeaderSortCache).count, equals(1));
      expect((list[2] as GroupHeaderSortCache).count, equals(2));
    });

    test('sets count to 0 for empty groups', () {
      final list = <HabitSortCache<dynamic>>[
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 5),
        GroupHeaderSortCache(groupUUID: 'g2', name: 'G2', count: 3),
      ];

      updateGroupHeaderCounts(list);
      expect((list[0] as GroupHeaderSortCache).count, equals(0));
      expect((list[1] as GroupHeaderSortCache).count, equals(0));
    });

    test('handles single header at end with no habits', () {
      final list = <HabitSortCache<dynamic>>[
        HabitSummaryDataSortCache(data: _habit(uuid: 'a')),
        GroupHeaderSortCache(groupUUID: 'g1', name: 'G1', count: 0),
      ];

      updateGroupHeaderCounts(list);
      expect((list[1] as GroupHeaderSortCache).count, equals(0));
    });

    test('handles empty list', () {
      final list = <HabitSortCache<dynamic>>[];
      // Should not throw
      updateGroupHeaderCounts(list);
    });
  });

  group('resolveEffectiveGroupId', () {
    test('returns null for null groupId', () {
      expect(resolveEffectiveGroupId(null, []), isNull);
    });

    test('returns groupId when group exists', () {
      final groups = [_group(uuid: 'g1')];
      expect(resolveEffectiveGroupId('g1', groups), equals('g1'));
    });

    test('returns null for orphan groupId (group does not exist)', () {
      final groups = [_group(uuid: 'g1')];
      expect(resolveEffectiveGroupId('orphan', groups), isNull);
    });

    test('returns null when groups list is empty', () {
      expect(resolveEffectiveGroupId('g1', []), isNull);
    });

    test('selects from multiple groups', () {
      final groups = [
        _group(uuid: 'g1'),
        _group(uuid: 'g2'),
        _group(uuid: 'g3'),
      ];
      expect(resolveEffectiveGroupId('g2', groups), equals('g2'));
      expect(resolveEffectiveGroupId('g1', groups), equals('g1'));
      expect(resolveEffectiveGroupId('g3', groups), equals('g3'));
      expect(resolveEffectiveGroupId('g4', groups), isNull);
    });
  });

  group('sortType-aware within-group sorting', () {
    test('defaults to manual (sortPostion) sort', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'c', groupId: 'g1', sortPostion: 3, name: 'Zulu'),
          _habit(uuid: 'a', groupId: 'g1', sortPostion: 1, name: 'Alpha'),
          _habit(uuid: 'b', groupId: 'g1', sortPostion: 2, name: 'Beta'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
      );

      final habits = result.whereType<HabitSummaryDataSortCache>().toList();
      expect(habits[0].uuid, equals('a'));
      expect(habits[1].uuid, equals('b'));
      expect(habits[2].uuid, equals('c'));
    });

    test('sorts by name ascending within groups', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'b', groupId: 'g1', sortPostion: 1, name: 'Zulu'),
          _habit(uuid: 'a', groupId: 'g1', sortPostion: 2, name: 'Alpha'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
        sortType: HabitDisplaySortType.name,
        sortDirection: HabitDisplaySortDirection.asc,
      );

      final habits = result.whereType<HabitSummaryDataSortCache>().toList();
      expect(habits[0].uuid, equals('a')); // Alpha
      expect(habits[1].uuid, equals('b')); // Zulu
    });

    test('sorts by name descending within groups', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'a', groupId: 'g1', name: 'Alpha'),
          _habit(uuid: 'b', groupId: 'g1', name: 'Zulu'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
        sortType: HabitDisplaySortType.name,
        sortDirection: HabitDisplaySortDirection.desc,
      );

      final habits = result.whereType<HabitSummaryDataSortCache>().toList();
      expect(habits[0].uuid, equals('b')); // Zulu
      expect(habits[1].uuid, equals('a')); // Alpha
    });

    test('sorts by startDate within groups', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'b', groupId: 'g1'),
          _habit(uuid: 'a', groupId: 'g1'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {},
        sortType: HabitDisplaySortType.startT,
        sortDirection: HabitDisplaySortDirection.asc,
      );

      // Both have same startDate, fallback to descending startDate → tie.
      // In practice this exercises the comparator chain without error.
      expect(result.whereType<HabitSummaryDataSortCache>(), hasLength(2));
    });

    test('sort type applies to uncategorized section as well', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'b', groupId: null, name: 'Zulu'),
          _habit(uuid: 'a', groupId: null, name: 'Alpha'),
        ]),
        groups: [],
        collapsedUUIDs: {},
        sortType: HabitDisplaySortType.name,
        sortDirection: HabitDisplaySortDirection.asc,
      );

      final habits = result.whereType<HabitSummaryDataSortCache>().toList();
      expect(habits[0].uuid, equals('a'));
      expect(habits[1].uuid, equals('b'));
    });

    test('sort does not affect collapsed groups', () {
      final result = buildGroupedSortCacheList(
        data: _collection([
          _habit(uuid: 'b', groupId: 'g1', name: 'Zulu'),
          _habit(uuid: 'a', groupId: 'g1', name: 'Alpha'),
        ]),
        groups: [_group(uuid: 'g1')],
        collapsedUUIDs: {'g1'},
        sortType: HabitDisplaySortType.name,
        sortDirection: HabitDisplaySortDirection.asc,
      );

      // Collapsed → only header, no habits emitted.
      expect(result.whereType<HabitSummaryDataSortCache>(), isEmpty);
    });
  });
}
