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
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/pages/group_manage/_providers/group_manage.dart';
import 'package:mhabit/pages/habit_edit/_providers/habit_form.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/providers/workflow/app_event.dart';

class _SpyGroupManageViewModel extends GroupManageViewModel {
  int handleEventCallCount = 0;

  @override
  void handleEvent(AppEvent event) {
    handleEventCallCount++;
    super.handleEvent(event);
  }
}

class _SpyHabitFormViewModel extends HabitFormViewModel {
  int handleEventCallCount = 0;

  @override
  void handleEvent(AppEvent event) {
    handleEventCallCount++;
    super.handleEvent(event);
  }
}

class _SpyHabitSummaryViewModel extends HabitSummaryViewModel {
  int handleEventCallCount = 0;

  @override
  void handleEvent(AppEvent event) {
    handleEventCallCount++;
    super.handleEvent(event);
  }
}

class _SpyHabitsTodayViewModel extends HabitsTodayViewModel {
  int handleEventCallCount = 0;

  @override
  void handleEvent(AppEvent event) {
    handleEventCallCount++;
    super.handleEvent(event);
  }
}

void main() {
  group('Self-exclusion (shouldReceive) — all AppEventSubscriber VMs', () {
    test(
      'GroupManageViewModel: handleEvent not called for self event',
      () async {
        final bus = AppEventBus();
        final vm = _SpyGroupManageViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        bus.push(
          const GroupChangedEvent(
            groupUUID: 'g1',
            trace: {
              AppEventPageSource.groupManage: {
                AppEventFunctionSource.groupChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, 0);

        bus.push(
          const GroupChangedEvent(
            groupUUID: 'g2',
            trace: {
              AppEventPageSource.habitDisplay: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, greaterThan(0));
      },
    );

    test('HabitFormViewModel: handleEvent not called for self event', () async {
      final bus = AppEventBus();
      final vm = _SpyHabitFormViewModel();
      vm.updateAppEvent(bus);
      addTearDown(() {
        vm.dispose();
        bus.dispose();
      });

      bus.push(
        const GroupChangedEvent(
          groupUUID: 'g1',
          trace: {
            AppEventPageSource.habitEdit: {AppEventFunctionSource.groupChanged},
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(vm.handleEventCallCount, 0);

      bus.push(
        const GroupChangedEvent(
          groupUUID: 'g2',
          trace: {
            AppEventPageSource.habitDisplay: {
              AppEventFunctionSource.habitChanged,
            },
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(vm.handleEventCallCount, greaterThan(0));
    });

    test(
      'HabitSummaryViewModel: handleEvent not called for self event',
      () async {
        final bus = AppEventBus();
        final vm = _SpyHabitSummaryViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        bus.push(
          const ReloadDataEvent(
            msg: 'self',
            trace: {
              AppEventPageSource.habitDisplay: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, 0);

        bus.push(
          const ReloadDataEvent(
            msg: 'external',
            trace: {
              AppEventPageSource.habitDetail: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, greaterThan(0));
      },
    );

    test(
      'HabitsTodayViewModel: handleEvent not called for self event',
      () async {
        final bus = AppEventBus();
        final vm = _SpyHabitsTodayViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        bus.push(
          const ReloadDataEvent(
            msg: 'self',
            trace: {
              AppEventPageSource.habitToday: {
                AppEventFunctionSource.recordChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, 0);

        bus.push(
          const ReloadDataEvent(
            msg: 'external',
            trace: {
              AppEventPageSource.habitEdit: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(vm.handleEventCallCount, greaterThan(0));
      },
    );
  });
}
