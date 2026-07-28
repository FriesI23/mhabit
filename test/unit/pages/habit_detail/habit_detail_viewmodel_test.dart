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

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_detail.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habit_detail/_providers/habit_detail.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

import '../../../support/stub/habits_display_access.dart';

final class _FakeHabitDetailAccess extends StubHabitDetailAccess {
  final HabitDetailData seedData;
  final String recordReason = 'detail-record-reason';
  final reminderRepairParamsList = <HabitReminderRepairParams>[];
  int loadDetailDataCallCount = 0;

  HabitUUID? lastLoadedUuid;
  HabitUUID? lastDetailUuid;
  HabitSummaryData? lastReasonData;
  HabitRecordDate? lastReasonDate;
  ChangeHabitStatusAction? lastStatusAction;
  ChangeRecordStatusAction<HabitDate>? lastRecordPreAction;

  _FakeHabitDetailAccess({required this.seedData});

  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) async {
    loadDetailDataCallCount += 1;
    lastLoadedUuid = uuid;
    return seedData;
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
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) {
    throw UnimplementedError();
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
  }) async => const [];

  @override
  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  }) {
    reminderRepairParamsList.add(params);
    return Future.value();
  }
}

HabitSummaryData _buildHabitSummaryData({
  String uuid = '11111111-1111-4111-8111-111111111111',
  HabitStatus status = HabitStatus.activated,
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
    status: status,
    sortPostion: 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

HabitDetailData _buildHabitDetailData() {
  final data = _buildHabitSummaryData();
  return HabitDetailData(
    data: data,
    modifyT: DateTime.utc(2026, 1, 1),
    dailyGoalUnit: 'times',
  );
}

void main() {
  group('HabitDetailViewModel seams', () {
    test('loads and reads through detail queries', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final vm = HabitDetailViewModel()..attachAccess(access);

      await vm.loadData(detailData.data.uuid, listen: false);

      expect(access.lastLoadedUuid, detailData.data.uuid);
      expect(access.reminderRepairParamsList, hasLength(1));
      expect(
        access.reminderRepairParamsList.single,
        HabitReminderRepairParams.loadedHabit(detailData.data),
      );

      final reason = await vm.loadRecordReason(HabitDate.now());
      expect(reason, access.recordReason);
      expect(access.lastReasonData?.uuid, detailData.data.uuid);

      final detail = await vm.loadCurrentHabitDetail();
      expect(access.lastDetailUuid, detailData.data.uuid);
      expect(detail?.uuid, detailData.data.uuid);

      vm.dispose();
    });

    test('writes through display commands', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final vm = HabitDetailViewModel()..attachAccess(access);

      await vm.loadData(detailData.data.uuid, listen: false);

      final recordResult = await vm.changeRecordStatus(
        HabitDate.now(),
        listen: false,
      );
      expect(recordResult, isNotNull);
      expect(access.lastRecordPreAction, isNotNull);

      final statusResult = await vm.onConfirmToArchiveHabit(listen: false);
      expect(statusResult, isNotNull);
      expect(access.lastStatusAction, isNotNull);

      vm.dispose();
    });

    test('requestReload allows a fresh detail load cycle', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final vm = HabitDetailViewModel()..attachAccess(access);

      await vm.loadData(detailData.data.uuid, listen: false);

      expect(access.loadDetailDataCallCount, 1);
      expect(vm.hasLoad, isTrue);

      vm.requestReload();

      expect(vm.hasLoad, isFalse);
      expect(vm.consumeForceReloadFlag(), isTrue);
      expect(vm.consumeForceReloadFlag(), isFalse);

      await vm.loadData(detailData.data.uuid, listen: false);

      expect(access.loadDetailDataCallCount, 2);
      expect(vm.hasLoad, isTrue);

      vm.dispose();
    });
  });

  group('HabitDetailViewModel event push', () {
    test(
      'onEditCompleted pushes HabitDataChangedEvent via AppEventSubscriptions',
      () async {
        final detailData = _buildHabitDetailData();
        final access = _FakeHabitDetailAccess(seedData: detailData);
        final bus = AppEventBus();
        final vm = HabitDetailViewModel()
          ..attachAccess(access)
          ..updateAppEvent(bus);
        final events = <HabitDataChangedEvent>[];
        bus.on<HabitDataChangedEvent>().listen(events.add);

        await vm.loadData(detailData.data.uuid, listen: false);
        vm.onEditCompleted();

        await Future<void>.delayed(Duration.zero);
        expect(
          events.length,
          1,
          reason: 'onEditCompleted should push one HabitDataChangedEvent',
        );
        final event = events.single;
        expect(
          event.isInTrace(
            AppEventPageSource.habitDetail,
            AppEventFunctionSource.habitChanged,
          ),
          isTrue,
          reason: 'trace must include habitDetail.habitChanged',
        );
        expect(event.uuidList, [detailData.data.uuid]);
        expect(event.changeType, HabitDataChangeType.updated);
        vm.dispose();
        bus.dispose();
      },
    );

    test(
      'onEditRecordCompleted pushes HabitDataChangedEvent via AppEventSubscriptions',
      () async {
        final detailData = _buildHabitDetailData();
        final access = _FakeHabitDetailAccess(seedData: detailData);
        final bus = AppEventBus();
        final vm = HabitDetailViewModel()
          ..attachAccess(access)
          ..updateAppEvent(bus);
        final events = <HabitDataChangedEvent>[];
        bus.on<HabitDataChangedEvent>().listen(events.add);

        await vm.loadData(detailData.data.uuid, listen: false);
        vm.onEditRecordCompleted();

        await Future<void>.delayed(Duration.zero);
        expect(
          events.length,
          1,
          reason: 'onEditRecordCompleted should push one HabitDataChangedEvent',
        );
        final event = events.single;
        expect(
          event.isInTrace(
            AppEventPageSource.habitDetail,
            AppEventFunctionSource.recordChanged,
          ),
          isTrue,
          reason: 'trace must include habitDetail.recordChanged',
        );
        expect(event.uuidList, [detailData.data.uuid]);
        expect(event.changeType, HabitDataChangeType.updated);
        vm.dispose();
        bus.dispose();
      },
    );

    test('onCalendarRecordChanged pushes HabitRecordsChangedEvent', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final bus = AppEventBus();
      final vm = HabitDetailViewModel()
        ..attachAccess(access)
        ..updateAppEvent(bus);
      final events = <HabitRecordsChangedEvent>[];
      bus.on<HabitRecordsChangedEvent>().listen(events.add);

      await vm.loadData(detailData.data.uuid, listen: false);
      final date = HabitDate.now();
      vm.onCalendarRecordChanged(
        uuid: detailData.data.uuid,
        date: date,
        status: HabitRecordStatus.done,
        reason: 'test-reason',
      );

      await Future<void>.delayed(Duration.zero);
      expect(events.length, 1);
      final event = events.single;
      expect(event.uuidList, [detailData.data.uuid]);
      expect(event.dateList, [date]);
      expect(event.status, HabitRecordStatus.done);
      expect(event.reason, 'test-reason');
      vm.dispose();
      bus.dispose();
    });

    test('onConfirmToArchiveHabit pushes HabitStatusChangedEvent '
        'via AppEventSubscriptions', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final bus = AppEventBus();
      final vm = HabitDetailViewModel()
        ..attachAccess(access)
        ..updateAppEvent(bus);
      final events = <HabitStatusChangedEvent>[];
      bus.on<HabitStatusChangedEvent>().listen(events.add);

      await vm.loadData(detailData.data.uuid, listen: false);

      // Ensure habit is not deleted (would return null early).
      final result = await vm.onConfirmToArchiveHabit(listen: false);

      await Future<void>.delayed(Duration.zero);
      expect(result, isNotNull);
      expect(
        result!.newStatus,
        HabitStatus.archived,
        reason: 'handler must archive the habit',
      );
      expect(events.length, 1);
      final event = events.single;
      expect(event.uuidList, [detailData.data.uuid]);
      expect(event.status, HabitStatus.archived);
      vm.dispose();
      bus.dispose();
    });

    test('onConfirmToUnarchiveHabit pushes HabitStatusChangedEvent '
        'via AppEventSubscriptions', () async {
      // Build data in archived state so unarchive has an effect.
      final summary = _buildHabitSummaryData(status: HabitStatus.archived);
      final detailData = HabitDetailData(
        data: summary,
        modifyT: DateTime.utc(2026, 1, 1),
        dailyGoalUnit: 'times',
      );
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final bus = AppEventBus();
      final vm = HabitDetailViewModel()
        ..attachAccess(access)
        ..updateAppEvent(bus);
      final events = <HabitStatusChangedEvent>[];
      bus.on<HabitStatusChangedEvent>().listen(events.add);

      await vm.loadData(detailData.data.uuid, listen: false);

      // Ensure habit is not deleted (would return null early).
      final result = await vm.onConfirmToUnarchiveHabit(listen: false);

      await Future<void>.delayed(Duration.zero);
      expect(result, isNotNull);
      expect(
        result!.newStatus,
        HabitStatus.activated,
        reason: 'handler must activate the habit',
      );
      expect(events.length, 1);
      final event = events.single;
      expect(event.uuidList, [detailData.data.uuid]);
      expect(event.status, HabitStatus.activated);
      vm.dispose();
      bus.dispose();
    });

    test('onConfirmToDeleteHabit pushes HabitStatusChangedEvent '
        'via AppEventSubscriptions', () async {
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final bus = AppEventBus();
      final vm = HabitDetailViewModel()
        ..attachAccess(access)
        ..updateAppEvent(bus);
      final events = <HabitStatusChangedEvent>[];
      bus.on<HabitStatusChangedEvent>().listen(events.add);

      await vm.loadData(detailData.data.uuid, listen: false);

      // Ensure habit is not already deleted (would return null early).
      final result = await vm.onConfirmToDeleteHabit(listen: false);

      await Future<void>.delayed(Duration.zero);
      expect(result, isNotNull);
      expect(
        result!.newStatus,
        HabitStatus.deleted,
        reason: 'handler must mark the habit as deleted',
      );
      expect(events.length, 1);
      final event = events.single;
      expect(event.uuidList, [detailData.data.uuid]);
      expect(event.status, HabitStatus.deleted);
      vm.dispose();
      bus.dispose();
    });
    test('shouldReceive excludes self-originated events', () {
      final vm = HabitDetailViewModel();

      expect(
        vm.shouldReceive(
          const ReloadDataEvent(
            msg: 'from-habitDetail',
            trace: {
              AppEventPageSource.habitDetail: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        ),
        isFalse,
        reason: 'should exclude events traced to habitDetail',
      );

      expect(
        vm.shouldReceive(
          const GroupChangedEvent(
            uuidList: ['g1'],
            trace: {
              AppEventPageSource.groupManage: {
                AppEventFunctionSource.groupChanged,
              },
            },
          ),
        ),
        isTrue,
        reason: 'should accept events from other sources',
      );
      vm.dispose();
    });

    test('handleEvent covers all sealed subtypes (no throw)', () {
      final vm = HabitDetailViewModel();

      // All four sealed subtypes must be accepted without error.
      vm.handleEvent(const ReloadDataEvent(msg: 'a'));
      vm.handleEvent(
        const HabitStatusChangedEvent(
          uuidList: ['u1'],
          status: HabitStatus.archived,
        ),
      );
      vm.handleEvent(
        HabitRecordsChangedEvent(
          uuidList: ['u1'],
          dateList: [HabitRecordDate.now()],
        ),
      );
      vm.handleEvent(const GroupChangedEvent(uuidList: ['g1']));

      // Should not throw.
      vm.dispose();
    });
  });
}
