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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

import '../../../support/stub/app_sync.dart';
import '../../../support/stub/habits_display_access.dart';

final class _FakeHabitsDisplayAccess extends StubHabitsDisplayAccess {
  final HabitSummaryData seedData;
  final List<HabitSummaryData> extraSeedData;
  final String recordReason = 'record-reason';
  final reminderRepairParamsList = <HabitReminderRepairParams>[];

  HabitUUID? lastDetailUuid;
  HabitSummaryData? lastReasonData;
  HabitRecordDate? lastReasonDate;
  ChangeHabitStatusAction? lastStatusAction;
  ChangeRecordStatusAction<HabitDate>? lastRecordPreAction;
  List<HabitSummaryData>? lastSortedHabits;
  num? lastIncreaseStep;
  int? lastDecimalPlaces;
  List<String>? lastHabitsColumns;

  _FakeHabitsDisplayAccess({
    required this.seedData,
    this.extraSeedData = const [],
  });

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    lastHabitsColumns = habitsColmns;
    final collection = initedCollection ?? HabitSummaryDataCollection();
    collection.addHabit(seedData, forceAdd: true);
    for (final habit in extraSeedData) {
      collection.addHabit(habit, forceAdd: true);
    }
    return collection;
  }

  @override
  Future<String?> loadHabitRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) async {
    lastReasonData = data;
    lastReasonDate = date;
    return recordReason;
  }

  @override
  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid) async {
    lastDetailUuid = uuid;
    return HabitDBCell(uuid: uuid, name: 'detail');
  }

  @override
  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  }) async {
    lastStatusAction = action;
    final results = action.resolve();
    if (extraResolver != null) {
      for (final result in results) {
        await extraResolver(result);
      }
    }
    return results;
  }

  @override
  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
      List<ChangeRecordStatusResult> results,
    )?
    postActionBuilder,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  }) async {
    lastRecordPreAction = preAction;
    final preResults = preAction.resolve();
    final results = postActionBuilder?.call(preResults).resolve() ?? preResults;
    if (beforeReminderUpdate != null) {
      final updatedHabits = <HabitUUID, HabitSummaryData>{};
      final recordsByHabit = <HabitUUID, List<ChangeRecordStatusResult>>{};
      for (final result in results) {
        updatedHabits[result.habit.uuid] = result.habit;
        (recordsByHabit[result.habit.uuid] ??= []).add(result);
      }
      for (final entry in updatedHabits.entries) {
        await beforeReminderUpdate(entry.value, recordsByHabit[entry.key]!);
      }
    }
    if (extraResolver != null) {
      for (final result in results) {
        await extraResolver(result);
      }
    }
    return results;
  }

  @override
  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) async {
    lastSortedHabits = List.of(habits, growable: false);
    lastIncreaseStep = increaseStep;
    lastDecimalPlaces = decimalPlaces;
    return habits.map((habit) => habit.uuid).toList(growable: false);
  }

  @override
  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  }) {
    reminderRepairParamsList.add(params);
    return Future.value();
  }
}

final class _FakeAppSyncWorkflowAccess extends StubAppSyncWorkflowAccess {
  final _controller = StreamController<String>.broadcast(sync: true);

  @override
  Stream<String> get startSyncEvents => _controller.stream;

  void emit(String id) {
    _controller.add(id);
  }

  Future<void> close() => _controller.close();
}

final class _StubGroupManager extends GroupManager {
  @override
  Future<List<GroupDBCell>> loadAllActiveGroups() async => [];
}

HabitSummaryData _buildHabitSummaryData({
  int id = 1,
  String uuid = '11111111-1111-4111-8111-111111111111',
  String name = 'Sample Habit',
  HabitStatus status = HabitStatus.activated,
  HabitDate? startDate,
}) {
  final effectiveStartDate = startDate ?? HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: id,
    uuid: uuid,
    type: HabitType.normal,
    name: name,
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: effectiveStartDate,
    status: status,
    sortPostion: 1,
    createTime: DateTime.utc(
      effectiveStartDate.year,
      effectiveStartDate.month,
      effectiveStartDate.day,
    ),
  );
}

Iterable<HabitUUID> _currentHabitUuids(HabitSummaryViewModel vm) => vm
    .currentHabitList
    .whereType<HabitSummaryDataSortCache>()
    .map((e) => e.uuid);

void main() {
  group('Habits display access', () {
    test('HabitSummaryViewModel loads and reads through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(_StubGroupManager());

      await vm.loadData(listen: false);

      expect(vm.habitCount, 1);
      expect(vm.currentHabitList, isNotEmpty);
      expect(access.reminderRepairParamsList, hasLength(1));
      expect(
        access.reminderRepairParamsList.single,
        HabitReminderRepairParams.loadedHabits([seedData]),
      );

      final loadedHabit = vm.getHabit(seedData.uuid);
      expect(loadedHabit, isNotNull);

      final reason = await vm.loadRecordReason(loadedHabit!, HabitDate.now());
      expect(reason, 'record-reason');
      expect(access.lastReasonData?.uuid, seedData.uuid);

      vm.selectHabit(seedData.uuid, listen: false);
      final detail = await vm.loadSelectedHabitDetail();

      expect(access.lastDetailUuid, seedData.uuid);
      expect(detail?.uuid, seedData.uuid);

      vm.dispose();
    });

    test('HabitsTodayViewModel loads and reads through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitsTodayViewModel()..attachAccess(access);

      await vm.loadData(listen: false);

      expect(vm.currentHabitList, isNotEmpty);
      expect(access.reminderRepairParamsList, hasLength(1));
      expect(
        access.reminderRepairParamsList.single,
        HabitReminderRepairParams.loadedHabits([seedData]),
      );

      final loadedHabit = vm.getHabit(seedData.uuid);
      expect(loadedHabit, isNotNull);

      final reason = await vm.loadRecordReason(loadedHabit!, HabitDate.now());
      expect(reason, 'record-reason');
      expect(access.lastReasonData?.uuid, seedData.uuid);

      vm.dispose();
    });

    test(
      'HabitsTodayViewModel loadData requests customColor / customColorTinted'
      ' columns',
      () async {
        final seedData = _buildHabitSummaryData();
        final access = _FakeHabitsDisplayAccess(seedData: seedData);
        final vm = HabitsTodayViewModel()..attachAccess(access);

        await vm.loadData(listen: false);

        expect(access.lastHabitsColumns, isNotNull);
        expect(
          access.lastHabitsColumns,
          containsAll([
            HabitDBCellKey.customColor,
            HabitDBCellKey.customColorTinted,
          ]),
        );

        vm.dispose();
      },
    );

    test('HabitSummaryViewModel writes through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitSummaryViewModel()
        ..attachAccess(access)
        ..attachGroupManager(_StubGroupManager());

      await vm.loadData(listen: false);

      final result = await vm.changeRecordStatus(
        seedData.uuid,
        HabitDate.now(),
        listen: false,
      );

      expect(result, isNotNull);
      expect(access.lastRecordPreAction, isNotNull);

      vm.dispose();
    });

    test(
      'HabitSummaryViewModel applies sort filter and keyword search',
      () async {
        final seedData = _buildHabitSummaryData(
          id: 1,
          uuid: '33333333-3333-4333-8333-333333333333',
          name: 'Zulu Habit',
        );
        final access = _FakeHabitsDisplayAccess(
          seedData: seedData,
          extraSeedData: [
            _buildHabitSummaryData(
              id: 2,
              uuid: '11111111-1111-4111-8111-111111111111',
              name: 'Alpha Habit',
            ),
            _buildHabitSummaryData(
              id: 3,
              uuid: '22222222-2222-4222-8222-222222222222',
              name: 'Bravo Habit',
              status: HabitStatus.archived,
            ),
          ],
        );
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachGroupManager(_StubGroupManager());

        await vm.loadData(listen: false);

        vm.updateSortOptions(
          HabitDisplaySortType.name,
          HabitDisplaySortDirection.asc,
        );
        vm.resortData(listen: false);

        expect(_currentHabitUuids(vm), [
          '11111111-1111-4111-8111-111111111111',
          '33333333-3333-4333-8333-333333333333',
        ]);

        vm.updateHabitDisplayFilter(HabitsDisplayFilter.allTrue);
        vm.resortData(listen: false);

        expect(_currentHabitUuids(vm), [
          '11111111-1111-4111-8111-111111111111',
          '22222222-2222-4222-8222-222222222222',
          '33333333-3333-4333-8333-333333333333',
        ]);

        vm.onSeachKeywordChanged('Zulu', listen: false);

        expect(_currentHabitUuids(vm), [
          '33333333-3333-4333-8333-333333333333',
        ]);

        vm.dispose();
      },
    );

    test(
      'HabitSummaryViewModel reloads through sync start event source',
      () async {
        final seedData = _buildHabitSummaryData();
        final access = _FakeHabitsDisplayAccess(seedData: seedData);
        final appSync = _FakeAppSyncWorkflowAccess();
        final vm = HabitSummaryViewModel()
          ..attachWorkflow(appSync)
          ..attachAccess(access)
          ..attachGroupManager(_StubGroupManager());

        await vm.loadData(listen: false);
        appSync.emit('sync-1');

        expect(vm.consumeForceReloadFlag(), isTrue);
        expect(vm.consumeClearSnackBarFlag(), isFalse);

        vm.dispose();
        await appSync.close();
      },
    );

    test('HabitSummaryViewModel reloads through app event bus', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final appEvent = AppEventBus();
      final vm = HabitSummaryViewModel()
        ..updateAppEvent(appEvent)
        ..attachAccess(access)
        ..attachGroupManager(_StubGroupManager());

      await vm.loadData(listen: false);
      appEvent.push(const ReloadDataEvent(clearSnackBar: true));
      await Future<void>.delayed(Duration.zero);

      expect(vm.consumeForceReloadFlag(), isTrue);
      expect(vm.consumeClearSnackBarFlag(), isTrue);

      vm.dispose();
      appEvent.dispose();
    });

    test('HabitsTodayViewModel writes through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitsTodayViewModel()..attachAccess(access);

      await vm.loadData(listen: false);

      final result = await vm.changeRecordStatus(seedData.uuid, listen: false);

      expect(result, isNotNull);
      expect(access.lastRecordPreAction, isNotNull);

      vm.dispose();
    });

    test('HabitsTodayViewModel applies today predicate and sort', () async {
      final checkedInToday =
          _buildHabitSummaryData(
            id: 4,
            uuid: '44444444-4444-4444-8444-444444444444',
            name: 'Done Today Habit',
          )..addRecord(
            HabitSummaryRecord.generate(
              HabitDate.now(),
              status: HabitRecordStatus.done,
              value: 1,
              parentUUID: '44444444-4444-4444-8444-444444444444',
            ),
          );
      final access = _FakeHabitsDisplayAccess(
        seedData: _buildHabitSummaryData(
          id: 1,
          uuid: '33333333-3333-4333-8333-333333333333',
          name: 'Zulu Habit',
        ),
        extraSeedData: [
          _buildHabitSummaryData(
            id: 2,
            uuid: '11111111-1111-4111-8111-111111111111',
            name: 'Alpha Habit',
          ),
          _buildHabitSummaryData(
            id: 3,
            uuid: '22222222-2222-4222-8222-222222222222',
            name: 'Archived Habit',
            status: HabitStatus.archived,
          ),
          _buildHabitSummaryData(
            id: 5,
            uuid: '55555555-5555-4555-8555-555555555555',
            name: 'Future Habit',
            startDate: HabitDate.now().addDays(1),
          ),
          checkedInToday,
        ],
      );
      final vm = HabitsTodayViewModel()..attachAccess(access);

      await vm.loadData(listen: false);

      vm.updateSortOptions(
        HabitDisplaySortType.name,
        HabitDisplaySortDirection.asc,
      );
      vm.resortData(listen: false);

      expect(
        vm.currentHabitList.whereType<HabitSummaryDataSortCache>().map(
          (e) => e.uuid,
        ),
        [
          '11111111-1111-4111-8111-111111111111',
          '33333333-3333-4333-8333-333333333333',
        ],
      );

      vm.dispose();
    });

    test(
      'HabitsTodayViewModel reloads through sync start event source',
      () async {
        final seedData = _buildHabitSummaryData();
        final access = _FakeHabitsDisplayAccess(seedData: seedData);
        final appSync = _FakeAppSyncWorkflowAccess();
        final vm = HabitsTodayViewModel()
          ..attachAccess(access)
          ..attachWorkflow(appSync);

        await vm.loadData(listen: false);
        appSync.emit('sync-1');

        expect(vm.consumeForceReloadFlag(), isTrue);

        vm.dispose();
        await appSync.close();
      },
    );

    test('HabitsTodayViewModel reloads through app event bus', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final appEvent = AppEventBus();
      final vm = HabitsTodayViewModel()
        ..attachAccess(access)
        ..updateAppEvent(appEvent);

      await vm.loadData(listen: false);
      appEvent.push(const ReloadDataEvent());
      await Future<void>.delayed(Duration.zero);

      expect(vm.consumeForceReloadFlag(), isTrue);

      vm.dispose();
      appEvent.dispose();
    });
  });
}
