// Copyright 2023 Fries_I23
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
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_daily_goal.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/pages/habit_edit/_providers/habit_form.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

final class _FakeHabitFormAccess implements HabitFormAccess {
  HabitDBCell? lastCreatedCell;
  HabitDBCell? lastUpdatedCell;
  int reminderPermissionRequests = 0;
  bool? requestReminderPermissionResult = true;

  @override
  Future<bool?> requestReminderPermission() async {
    reminderPermissionRequests += 1;
    return requestReminderPermissionResult;
  }

  @override
  Future<HabitDBCell?> saveNewHabitAndUpdateReminder(HabitDBCell cell) async {
    lastCreatedCell = cell;
    return cell;
  }

  @override
  Future<HabitDBCell?> updateExistHabitAndUpdateReminder(
    HabitDBCell cell, {
    bool withReminder = true,
  }) async {
    lastUpdatedCell = cell;
    return cell;
  }
}

void main() {
  HabitFormViewModel getMockViewModel() {
    return HabitFormViewModel();
  }

  group("HabitFormViewModel:API", () {
    test('name', () {
      final provider = getMockViewModel();
      expect(provider.name, '');
      provider.addListener(() async {
        expect(provider.name, 'test');
      });
      provider.name = "test";
      provider.dispose();
    });
    test('colorType', () {
      final provider = getMockViewModel();
      expect(provider.colorType, defaultHabitColorType);
      provider.addListener(() async {
        expect(provider.colorType, HabitColorType.cc5);
      });
      provider.colorType = HabitColorType.cc5;
    });
    test('dailyGoal', () {
      final provider = getMockViewModel();
      expect(provider.dailyGoalValue, defaultHabitDailyGoal);
      provider.addListener(() async {
        expect(provider.dailyGoalValue, 10.5);
      });
      provider.dailyGoalValue = 10.5;
    });
    test('isDailyGoalValueValid rejects positive exact minimum goal', () {
      final provider = getMockViewModel();

      provider.dailyGoalValue = minHabitDailyGoal;

      expect(provider.isDailyGoalValueValid, isFalse);
    });
    test('isDailyGoalValueValid accepts negative exact minimum goal', () {
      final provider = getMockViewModel();

      provider.habitType = HabitType.negative;
      provider.dailyGoalValue = minHabitDailyGoal;

      expect(provider.isDailyGoalValueValid, isTrue);
    });
    test('dailyGoalUnit', () {
      final provider = getMockViewModel();
      expect(provider.dailyGoalUnit, defaultHabitDailyGoalUnit);
      provider.addListener(() async {
        expect(provider.dailyGoalUnit, 'test');
      });
      provider.dailyGoalUnit = 'test';
    });
    test('dailyFrequency', () {
      final provider = getMockViewModel();
      expect(provider.frequency, HabitFrequency.daily);
      provider.addListener(() async {
        expect(
          provider.frequency,
          const HabitFrequency(type: HabitFrequencyType.monthly, freq: 10),
        );
      });
      provider.frequency = const HabitFrequency.monthly(freq: 10);
    });
    test('dailyStartDate', () {
      final provider = getMockViewModel();
      expect(
        provider.startDate == HabitStartDate.dateTime(DateTime.now()),
        true,
      );
      final newDate = HabitStartDate.dateTime(DateTime(2020, 1, 20));
      provider.addListener(() async {
        expect(provider.startDate == newDate, true);
      });
      provider.startDate = newDate;
    });
    test('dailyTargetDays', () {
      final provider = getMockViewModel();
      expect(provider.targetDays, defaultHabitTargetDays);
      provider.addListener(() async {
        expect(provider.targetDays, 300);
      });
      provider.targetDays = 300;
    });
    test('dailyDescribtion', () {
      final provider = getMockViewModel();
      expect(provider.desc, '');
      provider.addListener(() async {
        expect(provider.desc, 'test');
      });
      provider.desc = 'test';
    });
  });
  group('HabitFormViewModel:commands', () {
    test('requestReminderPermission blocks explicit denial', () async {
      final access = _FakeHabitFormAccess()
        ..requestReminderPermissionResult = false;
      final provider = HabitFormViewModel()..attachAccess(access);

      final result = await provider.requestReminderPermission();

      expect(result, isFalse);
      expect(access.reminderPermissionRequests, 1);

      provider.dispose();
    });

    test(
      'requestReminderPermission keeps nullable result permissive',
      () async {
        final access = _FakeHabitFormAccess()
          ..requestReminderPermissionResult = null;
        final provider = HabitFormViewModel()..attachAccess(access);

        final result = await provider.requestReminderPermission();

        expect(result, isTrue);
        expect(access.reminderPermissionRequests, 1);

        provider.dispose();
      },
    );

    test('saveHabit writes create path through commands', () async {
      final access = _FakeHabitFormAccess();
      final provider = HabitFormViewModel()..attachAccess(access);

      provider.name = 'New Habit';
      final saved = await provider.saveHabit();

      expect(saved, isNotNull);
      expect(access.lastCreatedCell, isNotNull);
      expect(access.lastCreatedCell?.name, 'New Habit');
      expect(access.lastUpdatedCell, isNull);

      provider.dispose();
    });

    test('saveHabit writes edit path through commands', () async {
      final access = _FakeHabitFormAccess();
      final provider = HabitFormViewModel(
        initForm: HabitForm(
          name: 'Existing Habit',
          type: HabitType.normal,
          colorType: defaultHabitColorType,
          dailyGoal: HabitDailyGoalData(type: HabitType.normal),
          frequency: HabitFrequency.daily,
          startDate: HabitStartDate.dateTime(DateTime(2020, 1, 20)),
          targetDays: defaultHabitTargetDays,
          desc: '',
          editMode: HabitDisplayEditMode.edit,
          editParams: HabitDisplayEditParams(
            uuid: '11111111-1111-4111-8111-111111111111',
            createT: DateTime(2020, 1, 20),
            modifyT: DateTime(2020, 1, 21),
          ),
        ),
      )..attachAccess(access);

      final saved = await provider.saveHabit();

      expect(saved, isNotNull);
      expect(access.lastUpdatedCell, isNotNull);
      expect(
        access.lastUpdatedCell?.uuid,
        '11111111-1111-4111-8111-111111111111',
      );
      expect(access.lastUpdatedCell?.name, 'Existing Habit');
      expect(access.lastCreatedCell, isNull);

      provider.dispose();
    });
  });
}
