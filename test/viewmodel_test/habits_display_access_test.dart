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
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

final class _FakeHabitsDisplayAccess implements HabitsDisplayAccess {
  final HabitSummaryData seedData;
  final String recordReason = 'record-reason';
  final reminderUpdates = <HabitSummaryData>[];

  HabitUUID? lastDetailUuid;
  HabitSummaryData? lastReasonData;
  HabitRecordDate? lastReasonDate;
  ChangeHabitStatusAction? lastStatusAction;
  ChangeRecordStatusAction<HabitDate>? lastRecordPreAction;
  List<HabitSummaryData>? lastSortedHabits;
  num? lastIncreaseStep;
  int? lastDecimalPlaces;

  _FakeHabitsDisplayAccess({required this.seedData});

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final collection = initedCollection ?? HabitSummaryDataCollection();
    collection.addNewHabit(seedData, forceAdd: true);
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
  Future<void> updateHabitReminder(HabitSummaryData data) {
    reminderUpdates.add(data);
    return Future.value();
  }
}

final class _FakeAppSyncWorkflowAccess implements AppSyncWorkflowAccess {
  final _controller = StreamController<String>.broadcast(sync: true);

  @override
  bool get canStartSync => true;

  @override
  Stream<AppSyncNeedConfirmEvent> get confirmEvents => const Stream.empty();

  @override
  Future? get syncProcessing => null;

  @override
  AppSyncStatusSnapshot? get syncStatus => null;

  @override
  Stream<String> get startSyncEvents => _controller.stream;

  @override
  void onL10nUpdate(L10n? l10n) {}

  @override
  void addListener(void Function() listener) {}

  @override
  void cancelSync() {}

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}

  void emit(String id) {
    _controller.add(id);
  }

  Future<void> close() => _controller.close();

  @override
  void removeListener(void Function() listener) {}

  @override
  Future<void> startSync({Duration? initWait}) async {}
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
    colorType: HabitColorType.cc1,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Habits display access', () {
    test('HabitSummaryViewModel loads and reads through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitSummaryViewModel()..attachAccess(access);

      await vm.loadData(listen: false);

      expect(vm.habitCount, 1);
      expect(vm.currentHabitList, isNotEmpty);
      expect(access.reminderUpdates.single.uuid, seedData.uuid);

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
      expect(access.reminderUpdates.single.uuid, seedData.uuid);

      final loadedHabit = vm.getHabit(seedData.uuid);
      expect(loadedHabit, isNotNull);

      final reason = await vm.loadRecordReason(loadedHabit!, HabitDate.now());
      expect(reason, 'record-reason');
      expect(access.lastReasonData?.uuid, seedData.uuid);

      vm.dispose();
    });

    test('HabitSummaryViewModel writes through access', () async {
      final seedData = _buildHabitSummaryData();
      final access = _FakeHabitsDisplayAccess(seedData: seedData);
      final vm = HabitSummaryViewModel()..attachAccess(access);

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
      'HabitSummaryViewModel reloads through sync start event source',
      () async {
        final seedData = _buildHabitSummaryData();
        final access = _FakeHabitsDisplayAccess(seedData: seedData);
        final appSync = _FakeAppSyncWorkflowAccess();
        final vm = HabitSummaryViewModel()
          ..attachAccess(access)
          ..attachWorkflow(appSync);

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
        ..attachAccess(access)
        ..updateAppEvent(appEvent);

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
