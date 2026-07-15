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
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_status_changer/_providers/habit_status_changer.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';

import '../../../support/stub/habits_display_access.dart';

final class _FakeHabitStatusChangerAccess extends StubHabitStatusChangerAccess {
  final HabitSummaryData seedData;

  List<HabitUUID>? lastHabitUuids;
  List<ChangeRecordStatusResult>? lastSavedRecords;

  _FakeHabitStatusChangerAccess({required this.seedData});

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    lastHabitUuids = habitUUIDs;
    final collection = initedCollection ?? HabitSummaryDataCollection();
    collection.addHabit(seedData, forceAdd: true);
    return collection;
  }

  @override
  Future<void> saveChangedHabitRecords({
    required Iterable<ChangeRecordStatusResult> records,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  }) async {
    final recordList = records.toList(growable: false);
    lastSavedRecords = recordList;

    if (beforeReminderUpdate != null) {
      final updatedHabits = <HabitUUID, HabitSummaryData>{};
      final recordsByHabit = <HabitUUID, List<ChangeRecordStatusResult>>{};
      for (final record in recordList) {
        updatedHabits[record.habit.uuid] = record.habit;
        (recordsByHabit[record.habit.uuid] ??= []).add(record);
      }
      for (final entry in updatedHabits.entries) {
        await beforeReminderUpdate(entry.value, recordsByHabit[entry.key]!);
      }
    }
  }
}

HabitSummaryData _buildHabitSummaryData({
  String uuid = '11111111-1111-4111-8111-111111111111',
}) {
  final startDate = HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: 1,
    uuid: uuid,
    type: HabitType.normal,
    name: 'Sample Habit',
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: startDate,
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

void main() {
  group('HabitStatusChangerViewModel seams', () {
    test('loads through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitStatusChangerAccess(seedData: seedData);
      final vm = HabitStatusChangerViewModel(uuidList: [seedData.uuid])
        ..attachAccess(access);

      await vm.loadData(listen: false);

      expect(vm.currentHabitCount, 1);
      expect(vm.fetchHabit(seedData.uuid)?.uuid, seedData.uuid);
      expect(access.lastHabitUuids, [seedData.uuid]);

      vm.dispose();
    });

    test('saves through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitStatusChangerAccess(seedData: seedData);
      final vm = HabitStatusChangerViewModel(uuidList: [seedData.uuid])
        ..attachAccess(access);

      await vm.loadData(listen: false);
      vm.updateSelectStatus(RecordStatusChangerStatus.ok, listen: false);

      final count = await vm.saveSelectStatus(listen: false);

      expect(count, 1);
      expect(access.lastSavedRecords, isNotNull);
      expect(access.lastSavedRecords, hasLength(1));
      expect(access.lastSavedRecords?.single.habit.uuid, seedData.uuid);

      vm.dispose();
    });
  });
}
