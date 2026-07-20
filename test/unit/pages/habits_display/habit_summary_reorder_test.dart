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
import 'package:mhabit/common/types.dart';
import 'package:mhabit/extensions/iterable_extensions.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

import '../../../support/stub/habits_display_access.dart';

final class _ReorderTestAccess extends StubHabitsDisplayAccess {
  final List<HabitSummaryData> _seed;
  final reminderRepairParamsList = <HabitReminderRepairParams>[];

  List<HabitSummaryData>? lastSortedHabits;
  num? lastIncreaseStep;
  int? lastDecimalPlaces;

  _ReorderTestAccess(Iterable<HabitSummaryData> seed)
    : _seed = List.unmodifiable(seed);

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final coll = initedCollection ?? HabitSummaryDataCollection();
    for (final h in _seed) {
      coll.addHabit(h, forceAdd: true);
    }
    return coll;
  }

  @override
  Future<String?> loadHabitRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) async => '';

  @override
  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid) async => null;

  @override
  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) async {
    lastSortedHabits = List.of(habits, growable: false);
    lastIncreaseStep = increaseStep;
    lastDecimalPlaces = decimalPlaces;
    final posList = habits
        .map((h) => h.sortPostion)
        .makeUniqueAndIncreasing(
          increaseStep,
          isSorted: false,
          decimalPlaces: decimalPlaces,
        );
    for (var i = 0; i < habits.length; i++) {
      habits[i].sortPostion = posList[i];
    }
    return habits.map((h) => h.uuid).toList();
  }

  @override
  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  }) async {
    reminderRepairParamsList.add(params);
  }

  List<HabitUUID>? lastGroupIdsUuids;
  List<String?>? lastGroupIdsValues;

  @override
  Future<void> updateHabitGroupIds(
    List<HabitUUID> uuids,
    List<String?> groupIds,
  ) async {
    lastGroupIdsUuids = uuids;
    lastGroupIdsValues = groupIds;
    for (var i = 0; i < uuids.length; i++) {
      final data = _seed.where((h) => h.uuid == uuids[i]).firstOrNull;
      if (data != null) data.groupId = groupIds[i];
    }
  }
}

final class _ReorderTestGroupManager extends GroupManager {
  final List<GroupDBCell> _groups;

  _ReorderTestGroupManager(this._groups);

  @override
  Future<List<GroupDBCell>> loadAllActiveGroups() async => _groups;
}

base class _ThrowingSortAccess extends _ReorderTestAccess {
  _ThrowingSortAccess(super.seed);

  @override
  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) async => throw Exception('sort write failed');
}

base class _ThrowingGroupAccess extends _ReorderTestAccess {
  _ThrowingGroupAccess(super.seed);

  @override
  Future<void> updateHabitGroupIds(
    List<HabitUUID> uuids,
    List<String?> groupIds,
  ) async => throw Exception('group write failed');
}

HabitSummaryData _h({
  required int id,
  required String uuid,
  required num sortPostion,
  String? groupId,
  String? name,
}) {
  return HabitSummaryData(
    id: id,
    uuid: uuid,
    type: HabitType.normal,
    name: name ?? 'H$id',
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: HabitDate.now().subtractDays(1),
    status: HabitStatus.activated,
    sortPostion: sortPostion,
    createTime: DateTime.now(),
    groupId: groupId,
  );
}

GroupDBCell _g({required String uuid, required String name}) {
  return GroupDBCell(uuid: uuid, name: name, status: GroupStatus.active.code);
}

List<HabitUUID> _habitUuids(HabitSummaryViewModel vm) => vm.currentHabitList
    .whereType<HabitSummaryDataSortCache>()
    .map((e) => e.uuid)
    .toList();

List<num> _habitSortPositions(HabitSummaryViewModel vm) => vm.currentHabitList
    .whereType<HabitSummaryDataSortCache>()
    .map((e) => e.data?.sortPostion ?? -1)
    .toList();

void main() {
  group('HabitSummary reorder', () {
    // ── flat reorder ─────────────────────────────────────────────
    //  before: [a(pos=1), b(pos=2), c(pos=3)]
    //  op:     move a(idx=0) after c(drop=2)
    //  after:  [b, c, a]
    test('flat reorder moves item in currentHabitList', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 1);
      final b = _h(id: 2, uuid: 'b', sortPostion: 2);
      final c = _h(id: 3, uuid: 'c', sortPostion: 3);
      final access = _ReorderTestAccess([a, b, c]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(_ReorderTestGroupManager([]));

      await vm.loadData(listen: false);
      vm.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
      vm.resortData();

      // before
      expect(_habitUuids(vm), ['a', 'b', 'c']);

      // op: move a(idx=0) → drop=2
      await vm.onHabitReorderComplate(0, 2);

      // after
      expect(_habitUuids(vm), ['b', 'c', 'a']);
      expect(access.lastSortedHabits!.map((h) => h.uuid), ['b', 'c', 'a']);

      vm.dispose();
    });

    // ── grouped reorder ──────────────────────────────────────────
    //  before(flat):  [a(pos=1), b(pos=2), c(pos=3)]
    //  before(group): [H(G1), a, b, H(G2), c]
    //  op:            drag b(idx=2) before a(drop=1)
    //  after(flat):   [b, a, c]   a.pos=2  b.pos=1  c.pos=3(不变)
    //  after(group):  [H(G1), b, a, H(G2), c]
    test(
      'grouped reorder within a group is stable and only affects that group',
      () async {
        final a = _h(id: 1, uuid: 'a', sortPostion: 1, groupId: 'g1');
        final b = _h(id: 2, uuid: 'b', sortPostion: 2, groupId: 'g1');
        final c = _h(id: 3, uuid: 'c', sortPostion: 3, groupId: 'g2');
        final access = _ReorderTestAccess([a, b, c]);
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(
            _ReorderTestGroupManager([
              _g(uuid: 'g1', name: 'G1'),
              _g(uuid: 'g2', name: 'G2'),
            ]),
          );

        await vm.loadData(listen: false);
        vm.updateGroupingEnabled(true);
        vm.resortData();

        // before: [H(G1), a(pos=1), b(pos=2), H(G2), c(pos=3)]
        expect(_habitUuids(vm), ['a', 'b', 'c']);

        // op: drag b(idx=2) before a(drop=1)
        await vm.onHabitReorderComplate(2, 1);

        // after: [H(G1), b(pos=1), a(pos=2), H(G2), c(pos=3)]
        expect(_habitUuids(vm), ['b', 'a', 'c']);
        expect(a.sortPostion, 2);
        expect(b.sortPostion, 1);
        expect(c.sortPostion, 3); // G2 untouched

        vm.dispose();
      },
    );

    // ── toggle ────────────────────────────────────────────────────
    //  before(ungroup):  [d(pos=0), b(pos=1), a(pos=3), c(pos=5)]
    //  after(group):     [H(G1), b, a, H(G2), c, H(null), d]
    //                     flat = [b, a, c, d]  (sort by header position)
    //  after(ungroup):   [d, b, a, c]          (original order restored)
    test('ungroup ↔ group toggle preserves flat order', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 3, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 1, groupId: 'g1');
      final c = _h(id: 3, uuid: 'c', sortPostion: 5, groupId: 'g2');
      final d = _h(id: 4, uuid: 'd', sortPostion: 0); // uncategorized
      final access = _ReorderTestAccess([a, b, c, d]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([
            _g(uuid: 'g1', name: 'G1'),
            _g(uuid: 'g2', name: 'G2'),
          ]),
        );

      await vm.loadData(listen: false);

      // before(ungroup): [d(pos=0), b(pos=1), a(pos=3), c(pos=5)]
      vm.resortData();
      expect(_habitUuids(vm), ['d', 'b', 'a', 'c']);

      // after(group): [H(G1), b, a, H(G2), c, H(null), d]
      vm.updateGroupingEnabled(true);
      vm.resortData();
      expect(_habitUuids(vm), ['b', 'a', 'c', 'd']);

      // after(ungroup): [d, b, a, c]
      vm.updateGroupingEnabled(false);
      vm.resortData();
      expect(_habitUuids(vm), ['d', 'b', 'a', 'c']);

      vm.dispose();
    });

    // ── same result ungrouped vs grouped ─────────────────────────
    //  before(ungroup):  [a(pos=1), b(pos=2), c(pos=3)]
    //  op(ungroup):      drag b before a → [b, a, c]  pos=[1,2,3]
    //  before(group):    [H(G1), a(pos=1), b(pos=2), H(null), c(pos=3)]
    //  op(group):        drag b(idx=2) before a(drop=1) → [H(G1), b, a, ...]
    //                    flat=[b, a, c]  pos=[1,2,3]
    //  assert: same flat order + same sortPositions
    test(
      'group reorder produces same flat order as ungrouped reorder',
      () async {
        final a = _h(id: 1, uuid: 'a', sortPostion: 1, groupId: 'g1');
        final b = _h(id: 2, uuid: 'b', sortPostion: 2, groupId: 'g1');
        final c = _h(id: 3, uuid: 'c', sortPostion: 3);

        // --- ungrouped ---
        final access1 = _ReorderTestAccess([a, b, c]);
        final vm1 = HabitSummaryViewModel()
          ..attachAccess(access1)
          ..attachGroupManager(_ReorderTestGroupManager([]));
        await vm1.loadData(listen: false);
        vm1.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
        vm1.resortData();
        // before: [a, b, c]
        // op:     drag b before a
        await vm1.onHabitReorderComplate(1, 0);
        final ungroupedUuids = _habitUuids(vm1);
        final ungroupedPos = _habitSortPositions(vm1);
        vm1.dispose();
        // after: [b, a, c]  pos=[1,2,3]

        // --- grouped ---
        final a2 = _h(id: 1, uuid: 'a', sortPostion: 1, groupId: 'g1');
        final b2 = _h(id: 2, uuid: 'b', sortPostion: 2, groupId: 'g1');
        final c2 = _h(id: 3, uuid: 'c', sortPostion: 3);
        final access2 = _ReorderTestAccess([a2, b2, c2]);
        final vm2 = HabitSummaryViewModel()
          ..attachAccess(access2)
          ..attachGroupManager(
            _ReorderTestGroupManager([_g(uuid: 'g1', name: 'G1')]),
          );
        await vm2.loadData(listen: false);
        vm2.updateGroupingEnabled(true);
        vm2.resortData();
        // before: [H(G1), a, b, H(null), c]
        // op:     drag b(idx=2) before a(drop=1)
        await vm2.onHabitReorderComplate(2, 1);
        final groupedUuids = _habitUuids(vm2);
        final groupedPos = _habitSortPositions(vm2);
        vm2.dispose();
        // after: [H(G1), b, a, H(null), c]  flat=[b,a,c]  pos=[1,2,3]

        // same flat order
        expect(groupedUuids, ungroupedUuids);
        expect(groupedUuids, ['b', 'a', 'c']);
        // same sortPositions
        expect(groupedPos, ungroupedPos);
        // c untouched in both
        expect(c.sortPostion, 3);
        expect(c2.sortPostion, 3);
        // only G1 habits passed to fixAndSaveSortPositions
        expect(
          access2.lastSortedHabits!.map((h) => h.uuid),
          unorderedEquals(['a', 'b']),
        );
      },
    );

    // ── no cross-group leak ─────────────────────────────────────
    //  before(group): [H(G1), a(pos=1), b(pos=2), H(G2), c(pos=3), H(null), d(pos=4)]
    //  op:            drag b(idx=2) before a(drop=1)
    //  after(group):  G1: a.pos/b.pos multiset {1,2} preserved (value swap)
    //                 G2: c.pos=3 unchanged
    //                 uncat: d.pos=4 unchanged
    //  assert:        fixAndSaveSortPositions only receives [a, b]
    test('group reorder does not leak into adjacent group', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 1, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 2, groupId: 'g1');
      final c = _h(id: 3, uuid: 'c', sortPostion: 3, groupId: 'g2');
      final d = _h(id: 4, uuid: 'd', sortPostion: 4);
      final access = _ReorderTestAccess([a, b, c, d]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([
            _g(uuid: 'g1', name: 'G1'),
            _g(uuid: 'g2', name: 'G2'),
          ]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), a(pos=1), b(pos=2), H(G2), c(pos=3), H(null), d(pos=4)]
      // op:     drag b(idx=2) before a(drop=1)
      await vm.onHabitReorderComplate(2, 1);
      // after:  [H(G1), b(pos=1), a(pos=2), H(G2), c(pos=3), H(null), d(pos=4)]

      // G1: multiset {1,2} preserved, values swapped
      expect(a.sortPostion, 2);
      expect(b.sortPostion, 1);
      // G2 + uncat: unchanged
      expect(c.sortPostion, 3);
      expect(d.sortPostion, 4);
      // only G1 habits passed to fixAndSaveSortPositions
      expect(
        access.lastSortedHabits!.map((h) => h.uuid),
        unorderedEquals(['a', 'b']),
      );

      vm.dispose();
    });

    // ── groupId preserved ──────────────────────────────────────
    //  before(ungroup): [a(g1,pos=1), b(pos=2)]
    //  op:              drag b before a
    //  after:           [b, a]  a.groupId='g1' preserved
    test('reorder in non-grouped mode does not affect group state', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 1, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 2);
      final access = _ReorderTestAccess([a, b]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(_ReorderTestGroupManager([]));

      await vm.loadData(listen: false);
      vm.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
      vm.resortData();

      // before: [a(g1,pos=1), b(pos=2)]
      // op:     drag b before a
      await vm.onHabitReorderComplate(1, 0);
      // after:  [b, a(g1)]

      expect(_habitUuids(vm), ['b', 'a']);
      expect(a.sortPostion, greaterThan(0));
      expect(b.sortPostion, greaterThan(0));
      expect(a.groupId, 'g1');

      vm.dispose();
    });

    // ── absolute boundary reorder ──────────────────────────────
    //  before:        [a(pos=10), b(pos=20)]
    //  scene A (top): drag b(idx=1) to top(drop=0)
    //                 → [b, a]  b.pos < a.pos && b.pos > 0
    //  scene B (bot): after reset, drag a(idx=0) below b(drop=2)
    //                 → [b, a]  a.pos > b.pos
    test('absolute boundary reorder at top / bottom edges', () async {
      // ── Scene A: drag b before a ──
      final a1 = _h(id: 1, uuid: 'a', sortPostion: 10);
      final b1 = _h(id: 2, uuid: 'b', sortPostion: 20);
      final access1 = _ReorderTestAccess([a1, b1]);
      final vm1 = HabitSummaryViewModel()
        ..attachAccess(access1)
        ..attachGroupManager(_ReorderTestGroupManager([]));
      await vm1.loadData(listen: false);
      vm1.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
      vm1.resortData();
      // before: [a(10), b(20)]
      // op:     drag b(idx=1) → top(drop=0)
      await vm1.onHabitReorderComplate(1, 0);
      // after:  [b, a]  b.pos < a.pos  &&  b.pos > 0
      expect(_habitUuids(vm1), ['b', 'a']);
      expect(b1.sortPostion, lessThan(a1.sortPostion));
      expect(b1.sortPostion, greaterThan(0));
      vm1.dispose();

      // ── Scene B: drag a below b ──
      final a2 = _h(id: 1, uuid: 'a', sortPostion: 10);
      final b2 = _h(id: 2, uuid: 'b', sortPostion: 20);
      final access2 = _ReorderTestAccess([a2, b2]);
      final vm2 = HabitSummaryViewModel()
        ..attachAccess(access2)
        ..attachGroupManager(_ReorderTestGroupManager([]));
      await vm2.loadData(listen: false);
      vm2.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
      vm2.resortData();
      // before: [a(10), b(20)]
      // op:     drag a(idx=0) → after last(drop=2)
      await vm2.onHabitReorderComplate(0, 2);
      // after:  [b, a]  a.pos > b.pos
      expect(_habitUuids(vm2), ['b', 'a']);
      expect(a2.sortPostion, greaterThan(b2.sortPostion));
      vm2.dispose();
    });

    // ── sortPosition multiset ──────────────────────────────────
    //  before(group): [H(G1), a(pos=10), b(pos=20), H(G2), c(pos=30)]
    //  op:            drag b(idx=2) before a(drop=1)
    //  after(group):  G1 multiset {10,20} preserved
    //                 a.pos=20  b.pos=10  (swapped)
    //                 G2: c.pos=30 unchanged
    test('reorder preserves sortPosition multiset within group', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g1');
      final c = _h(id: 3, uuid: 'c', sortPostion: 30, groupId: 'g2');
      final access = _ReorderTestAccess([a, b, c]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([
            _g(uuid: 'g1', name: 'G1'),
            _g(uuid: 'g2', name: 'G2'),
          ]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), a(pos=10), b(pos=20), H(G2), c(pos=30)]
      final group1PosBefore = [a.sortPostion, b.sortPostion]..sort();

      // op: drag b(idx=2) before a(drop=1)
      await vm.onHabitReorderComplate(2, 1);
      // after: [H(G1), b(pos=10), a(pos=20), H(G2), c(pos=30)]

      final group1PosAfter = [a.sortPostion, b.sortPostion]..sort();

      // G1 multiset {10,20} preserved
      expect(group1PosAfter, group1PosBefore);
      // values swapped
      expect(a.sortPostion, 20);
      expect(b.sortPostion, 10);
      // G2 untouched
      expect(c.sortPostion, 30);

      vm.dispose();
    });

    // ── cross-group reorder (range-based, no groupUUID needed) ──
    //  before(group): [H(G1), a(pos=10), H(G2), b(pos=20), c(pos=30)]
    //  op:            drag a(idx=1) down to after c(drop=4)
    //  range:         [1, 4] → a, H(G2), b, c → habits: [a, b, c]
    //  after:         [H(G1), H(G2), b(pos=10), c(pos=20), a(pos=30)]
    test('cross-group reorder via range handles both groups', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g2');
      final c = _h(id: 3, uuid: 'c', sortPostion: 30, groupId: 'g2');
      final access = _ReorderTestAccess([a, b, c]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([
            _g(uuid: 'g1', name: 'G1'),
            _g(uuid: 'g2', name: 'G2'),
          ]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), a(pos=10), H(G2), b(pos=20), c(pos=30)]
      expect(_habitUuids(vm), ['a', 'b', 'c']);

      // op: drag a(idx=1) → after c(drop=4)
      await vm.onHabitReorderComplate(1, 4);

      // after(flat): [b(pos=10), c(pos=20), a(pos=30)]
      expect(_habitUuids(vm), ['b', 'c', 'a']);
      expect(b.sortPostion, 10);
      expect(c.sortPostion, 20);
      expect(a.sortPostion, 30);

      // range-based: only [a, b, c] passed (not just one group)
      expect(
        access.lastSortedHabits!.map((h) => h.uuid),
        unorderedEquals(['a', 'b', 'c']),
      );

      vm.dispose();
    });

    // ── ungrouped reorder ignores range and uses all habits ─────
    test('ungrouped reorder reassigns all habits (ignores range)', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10);
      final b = _h(id: 2, uuid: 'b', sortPostion: 20);
      final c = _h(id: 3, uuid: 'c', sortPostion: 30);
      final access = _ReorderTestAccess([a, b, c]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(_ReorderTestGroupManager([]));

      await vm.loadData(listen: false);
      vm.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
      vm.resortData();

      await vm.onHabitReorderComplate(2, 1);

      expect(
        access.lastSortedHabits!.map((h) => h.uuid),
        unorderedEquals(['a', 'b', 'c']),
      );

      vm.dispose();
    });

    // ── cross-group onCrossGroupHabitMove ───────────────────────
    test(
      'cross-group move scopes fixAndSaveSortPositions to target group',
      () async {
        final a = _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1');
        final b = _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g2');
        final c = _h(id: 3, uuid: 'c', sortPostion: 30, groupId: 'g2');
        final access = _ReorderTestAccess([a, b, c]);
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(
            _ReorderTestGroupManager([
              _g(uuid: 'g1', name: 'G1'),
              _g(uuid: 'g2', name: 'G2'),
            ]),
          );

        await vm.loadData(listen: false);
        vm.updateGroupingEnabled(true);
        vm.resortData();

        // before: [H(G1), a(pos=10), H(G2), b(pos=20), c(pos=30)]
        // drag a(idx=1) between b and c in G2 → drop=3
        // after removeAt(1): [H(G1), H(G2), b@1, c@2]
        // insert at 3 (between b and c)

        await vm.onCrossGroupHabitMove(1, 3, 'g2');
        expect(access.lastGroupIdsUuids, ['a']);
        expect(access.lastGroupIdsValues, ['g2']);
        expect(a.groupId, 'g2');

        // fixAndSaveSortPositions scoped to target group only
        expect(
          access.lastSortedHabits!.map((h) => h.uuid),
          unorderedEquals(['b', 'c', 'a']),
        );

        // G1's a got reassigned into G2's multiset {10,20,30}
        // b, c sortPositions may shift (within-group reorder semantics)
        final g2Positions = [a.sortPostion, b.sortPostion, c.sortPostion]
          ..sort();
        expect(g2Positions, [10, 20, 30]);

        vm.dispose();
      },
    );

    test('cross-group move to uncategorized sets groupId to null', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 20); // uncategorized
      final access = _ReorderTestAccess([a, b]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([_g(uuid: 'g1', name: 'G1')]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), a(pos=10), H(null), b(pos=20)]
      // drag a(idx=1) to end of uncategorized → drop=3
      // after removeAt(1): [H(G1), H(null)@1, b@2]
      // insert at 3 (after b)

      await vm.onCrossGroupHabitMove(1, 3, null);
      expect(a.groupId, null);

      vm.dispose();
    });

    test('cross-group move from uncategorized into a named group', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10); // uncategorized
      final b = _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g1');
      final access = _ReorderTestAccess([a, b]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([_g(uuid: 'g1', name: 'G1')]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), b(pos=20), H(null), a(pos=10)]
      // drag a(idx=3) before b → drop=1
      // after removeAt(3): [H(G1), b@1, H(null)@1]
      // insert at 1 (before b)

      await vm.onCrossGroupHabitMove(3, 1, 'g1');
      expect(a.groupId, 'g1');

      // G1 multiset {10,20} preserved
      final g1Positions = [a.sortPostion, b.sortPostion]..sort();
      expect(g1Positions, [10, 20]);

      vm.dispose();
    });

    test('cross-group move leaves source group habits untouched', () async {
      final a = _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1');
      final b = _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g1');
      final c = _h(id: 3, uuid: 'c', sortPostion: 5, groupId: 'g2');
      final access = _ReorderTestAccess([a, b, c]);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(
          _ReorderTestGroupManager([
            _g(uuid: 'g1', name: 'G1'),
            _g(uuid: 'g2', name: 'G2'),
          ]),
        );

      await vm.loadData(listen: false);
      vm.updateGroupingEnabled(true);
      vm.resortData();

      // before: [H(G1), a(pos=10), b(pos=20), H(G2), c(pos=5)]
      // drag b(idx=2) before c(idx=3) → drop to G2

      await vm.onCrossGroupHabitMove(2, 3, 'g2');
      expect(a.sortPostion, closeTo(10.0, 0.001));
      expect(a.groupId, 'g1');

      // G2: b + c were both included in fixAndSaveSortPositions
      // multiset {5, 20} preserved
      final g2Positions = [b.sortPostion, c.sortPostion]..sort();
      expect(g2Positions, [5, 20]);
      expect(b.groupId, 'g2');

      vm.dispose();
    });

    // ── error propagation ──────────────────────────────────────
    // Verifies that DB-write failures in onHabitReorderComplate /
    // onCrossGroupHabitMove are thrown (not silently swallowed),
    // so callers can handle them (e.g. requestReload + SnackBar).
    //
    // The in-memory mutation happens before DB writes; even on
    // failure the list order and groupId have already changed.
    // This is the existing behavior — the fix that prevents
    // silent inconsistency lives in finishReorder at the widget
    // layer (then/catchError).

    test(
      'onHabitReorderComplate propagates error on DB write failure',
      () async {
        final access = _ThrowingSortAccess([
          _h(id: 1, uuid: 'a', sortPostion: 1),
          _h(id: 2, uuid: 'b', sortPostion: 2),
          _h(id: 3, uuid: 'c', sortPostion: 3),
        ]);
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(_ReorderTestGroupManager([]));

        await vm.loadData(listen: false);
        vm.updateHabitDisplayFilter(const HabitsDisplayFilter.withDefault());
        vm.resortData();

        // before: [a, b, c]
        expect(_habitUuids(vm), ['a', 'b', 'c']);

        await expectLater(
          vm.onHabitReorderComplate(0, 2),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('sort write failed'),
            ),
          ),
        );

        // Memory already mutated despite DB failure (existing behavior).
        expect(_habitUuids(vm), ['b', 'c', 'a']);

        vm.dispose();
      },
    );

    test(
      'onCrossGroupHabitMove propagates error on sort write failure',
      () async {
        final access = _ThrowingSortAccess([
          _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1'),
          _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g2'),
          _h(id: 3, uuid: 'c', sortPostion: 30, groupId: 'g2'),
        ]);
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(
            _ReorderTestGroupManager([
              _g(uuid: 'g1', name: 'G1'),
              _g(uuid: 'g2', name: 'G2'),
            ]),
          );

        await vm.loadData(listen: false);
        vm.updateGroupingEnabled(true);
        vm.resortData();

        // before: [H(G1), a(g1), H(G2), b(g2), c(g2)]
        expect(_habitUuids(vm), ['a', 'b', 'c']);

        await expectLater(
          vm.onCrossGroupHabitMove(1, 3, 'g2'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('sort write failed'),
            ),
          ),
        );

        // Memory mutated: a moved in the list, groupId unchanged
        // (updateHabitGroupIds never reached).
        expect(_habitUuids(vm), containsAllInOrder(['b', 'a', 'c']));

        vm.dispose();
      },
    );

    test(
      'onCrossGroupHabitMove propagates error on group write failure',
      () async {
        final access = _ThrowingGroupAccess([
          _h(id: 1, uuid: 'a', sortPostion: 10, groupId: 'g1'),
          _h(id: 2, uuid: 'b', sortPostion: 20, groupId: 'g2'),
          _h(id: 3, uuid: 'c', sortPostion: 30, groupId: 'g2'),
        ]);
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(
            _ReorderTestGroupManager([
              _g(uuid: 'g1', name: 'G1'),
              _g(uuid: 'g2', name: 'G2'),
            ]),
          );

        await vm.loadData(listen: false);
        vm.updateGroupingEnabled(true);
        vm.resortData();

        await expectLater(
          vm.onCrossGroupHabitMove(1, 3, 'g2'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('group write failed'),
            ),
          ),
        );

        vm.dispose();
      },
    );
  });
}
