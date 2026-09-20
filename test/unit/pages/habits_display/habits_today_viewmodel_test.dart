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
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/providers/workflow/app_event.dart';

import '../../../support/stub/habits_display_access.dart';

final class _LoadedTodayAccess extends StubHabitsDisplayAccess {
  _LoadedTodayAccess(this.habit);

  final HabitSummaryData habit;

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async =>
      (initedCollection ?? HabitSummaryDataCollection())
        ..addHabit(habit, forceAdd: true);
}

Map<AppEventPageSource, Set<AppEventFunctionSource>> _trace(
  AppEventPageSource source, [
  AppEventFunctionSource function = AppEventFunctionSource.habitChanged,
]) => {
  source: {function},
};

void main() {
  group('HabitsTodayViewModel:event', () {
    test('reloads when a habit is created', () async {
      final bus = AppEventBus();
      final vm = HabitsTodayViewModel();
      vm.updateAppEvent(bus);
      addTearDown(() {
        vm.dispose();
        bus.dispose();
      });

      vm.consumeForceReloadFlag();

      bus.push(
        const HabitDataChangedEvent(
          uuidList: ['u1'],
          changeType: HabitDataChangeType.created,
          trace: {
            AppEventPageSource.habitEdit: {AppEventFunctionSource.habitCreated},
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.consumeForceReloadFlag(), isTrue);
    });

    test(
      'reloads when RecordsChangedEvent contains today in dateList',
      () async {
        final bus = AppEventBus();
        final vm = HabitsTodayViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        final now = HabitDate.now();
        vm.consumeForceReloadFlag();

        bus.push(
          HabitRecordsChangedEvent(
            uuidList: ['u1'],
            dateList: [now],
            trace: _trace(AppEventPageSource.habitEdit),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(vm.consumeForceReloadFlag(), isTrue);
      },
    );

    test(
      'reloads deleted check-in even when today cache still has it',
      () async {
        final now = HabitDate.now();
        final habit = HabitSummaryData(
          id: 1,
          uuid: 'u1',
          type: HabitType.normal,
          name: 'Test Habit',
          desc: '',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          dailyGoal: 1,
          targetDays: 1,
          frequency: HabitFrequency.daily,
          startDate: now.subtractDays(1),
          status: HabitStatus.activated,
          sortPostion: 1,
          createTime: DateTime(2026),
        )..addRecord(HabitSummaryRecord('r1', now, HabitRecordStatus.done, 1));
        final bus = AppEventBus();
        final vm = HabitsTodayViewModel()
          ..attachAccess(_LoadedTodayAccess(habit))
          ..updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });
        await vm.loadData(listen: false);
        expect(vm.getHabit('u1')?.getRecordByDate(now), isNotNull);
        vm.consumeForceReloadFlag();

        bus.push(
          HabitRecordsChangedEvent(
            uuidList: ['u1'],
            dateList: [now],
            status: null,
            trace: _trace(AppEventPageSource.habitStatusChanger),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(vm.consumeForceReloadFlag(), isTrue);
      },
    );

    test(
      'does not reload when RecordsChangedEvent does not contain today',
      () async {
        final bus = AppEventBus();
        final vm = HabitsTodayViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        final yesterday = HabitDate.now().subtractDays(1);
        vm.consumeForceReloadFlag();

        bus.push(
          HabitRecordsChangedEvent(
            uuidList: ['u1'],
            dateList: [yesterday],
            trace: _trace(AppEventPageSource.habitEdit),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(vm.consumeForceReloadFlag(), isFalse);
      },
    );

    test(
      'ignores self-originated RecordsChangedEvent via shouldReceive',
      () async {
        final bus = AppEventBus();
        final vm = HabitsTodayViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        final now = HabitDate.now();
        vm.consumeForceReloadFlag();

        bus.push(
          HabitRecordsChangedEvent(
            uuidList: ['u1'],
            dateList: [now],
            trace: _trace(AppEventPageSource.habitToday),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(vm.consumeForceReloadFlag(), isFalse);
      },
    );
  });

  group('HabitsTodayViewModel:exhaustiveness', () {
    test('handleEvent covers all sealed subtypes', () {
      final vm = HabitsTodayViewModel();
      addTearDown(vm.dispose);

      vm.handleEvent(const ReloadDataEvent(msg: 'r'));
      vm.handleEvent(
        const HabitStatusChangedEvent(
          uuidList: ['u1'],
          status: HabitStatus.activated,
        ),
      );
      vm.handleEvent(
        HabitRecordsChangedEvent(uuidList: ['u1'], dateList: [HabitDate.now()]),
      );
      vm.handleEvent(const GroupChangedEvent(uuidList: ['g1']));
    });
  });
}
