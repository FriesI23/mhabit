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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_daily_goal.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/routes/helpers/habit_edit_helper.dart';

HabitForm _editForm({required String uuid}) => HabitForm(
  name: 'Test Habit',
  type: HabitType.normal,
  color: const HabitColor.builtIn(defaultHabitColorType),
  dailyGoal: HabitDailyGoalData(type: HabitType.normal),
  frequency: HabitFrequency.daily,
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)),
  targetDays: defaultHabitTargetDays,
  editMode: HabitDisplayEditMode.edit,
  editParams: HabitDisplayEditParams(
    uuid: uuid,
    createT: DateTime(2026, 1, 1),
    modifyT: DateTime(2026, 6, 1),
  ),
);

void main() {
  group('HabitEditExtra', () {
    test('construct with habitId and initForm — accessors return values', () {
      const habitId = 'edit-habit-uuid';
      final form = _editForm(uuid: habitId);
      final extra = HabitEditExtra(habitId: habitId, initForm: form);

      expect(extra.habitId, habitId);
      expect(extra.initForm, same(form));
    });

    test(
      'habitId and initForm.editParams.uuid can differ (assert lives in push, not extra)',
      () {
        // The extra container itself does not enforce consistency;
        // that check lives in pushHabitEdit / unpackHabitEdit.
        const extraHabitId = 'extra-habit-uuid';
        const formHabitId = 'form-habit-uuid';
        final form = _editForm(uuid: formHabitId);
        final extra = HabitEditExtra(habitId: extraHabitId, initForm: form);

        expect(extra.habitId, extraHabitId);
        expect(extra.initForm.editParams?.uuid, formHabitId);
        expect(extra.habitId, isNot(equals(formHabitId)));
      },
    );
  });

  group('unpackHabitEdit', () {
    testWidgets('extracts habitId and initForm when query matches extra', (
      tester,
    ) async {
      GoRouterState? capturedState;
      const habitId = 'unpack-edit-uuid';
      final form = _editForm(uuid: habitId);
      final extra = HabitEditExtra(habitId: habitId, initForm: form);

      final router = GoRouter(
        initialLocation: '/habit/edit?habitId=$habitId',
        initialExtra: extra,
        routes: [
          GoRoute(
            path: '/habit/edit',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitEdit();
      expect(params.habitId, habitId);
      expect(params.initForm, same(form));
    });

    testWidgets('assert fails when query habitId differs from extra.habitId', (
      tester,
    ) async {
      GoRouterState? capturedState;
      const extraHabitId = 'extra-id';
      final form = _editForm(uuid: extraHabitId);
      final extra = HabitEditExtra(habitId: extraHabitId, initForm: form);

      final router = GoRouter(
        initialLocation: '/habit/edit?habitId=wrong-query-id',
        initialExtra: extra,
        routes: [
          GoRoute(
            path: '/habit/edit',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        () => capturedState!.unpackHabitEdit(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('pushHabitEdit', () {
    testWidgets('assert fails when initForm.editParams.uuid != habitId', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/habit/edit',
            name: AppRoute.habitEdit.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final form = _editForm(uuid: 'correct-uuid');
      final context = tester.element(find.byType(SizedBox).first);

      expect(
        () => context.pushHabitEdit(habitId: 'wrong-uuid', initForm: form),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('succeeds when uuids match (no assert)', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/habit/edit',
            name: AppRoute.habitEdit.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      const habitId = 'matching-uuid';
      final form = _editForm(uuid: habitId);
      final context = tester.element(find.byType(SizedBox).first);

      // Should not throw — navigate starts, future does not need to settle.
      expect(
        () => context.pushHabitEdit(habitId: habitId, initForm: form),
        returnsNormally,
      );
    });
  });
}
