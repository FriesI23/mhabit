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
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/providers/workflow/app_event.dart';

void main() {
  group('HabitSummaryViewModel:event', () {
    test(
      'exits edit mode on external ReloadDataEvent with exiEditMode: true',
      () async {
        final bus = AppEventBus();
        final vm = HabitSummaryViewModel();
        vm.updateAppEvent(bus);
        addTearDown(() {
          vm.dispose();
          bus.dispose();
        });

        vm.switchToEditMode(listen: false);
        expect(vm.isInEditMode, isTrue);

        bus.push(
          const ReloadDataEvent(
            exiEditMode: true,
            trace: {
              AppEventPageSource.habitDetail: {
                AppEventFunctionSource.habitChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(vm.isInEditMode, isFalse);
      },
    );

    test('ignores self-originated ReloadDataEvent via shouldReceive', () async {
      final bus = AppEventBus();
      final vm = HabitSummaryViewModel();
      vm.updateAppEvent(bus);
      addTearDown(() {
        vm.dispose();
        bus.dispose();
      });

      vm.switchToEditMode(listen: false);
      expect(vm.isInEditMode, isTrue);

      bus.push(
        const ReloadDataEvent(
          exiEditMode: true,
          trace: {
            AppEventPageSource.habitDisplay: {
              AppEventFunctionSource.habitChanged,
            },
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.isInEditMode, isTrue);
    });
  });

  group('HabitSummaryViewModel:exhaustiveness', () {
    test('handleEvent covers all sealed subtypes', () {
      final vm = HabitSummaryViewModel();
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
