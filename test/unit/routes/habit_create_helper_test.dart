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
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/routes/helpers/habit_create_helper.dart';

void main() {
  group('HabitCreateExtra', () {
    test('construct with initForm — accessor returns it', () {
      final form = HabitForm.empty();
      final extra = HabitCreateExtra(initForm: form);

      expect(extra.initForm, same(form));
    });

    test('construct with no arguments — initForm is null', () {
      const extra = HabitCreateExtra();

      expect(extra.initForm, isNull);
    });

    test('construct with null initForm explicitly — initForm is null', () {
      const extra = HabitCreateExtra(initForm: null);

      expect(extra.initForm, isNull);
    });
  });

  group('unpackHabitCreate', () {
    testWidgets('extracts initForm from extra', (tester) async {
      GoRouterState? capturedState;
      final form = HabitForm.empty();
      final extra = HabitCreateExtra(initForm: form);

      final router = GoRouter(
        initialLocation: '/habit/create',
        initialExtra: extra,
        routes: [
          GoRoute(
            path: '/habit/create',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitCreate();
      expect(params.initForm, same(form));
    });

    testWidgets('initForm is null when extra has no initForm', (tester) async {
      GoRouterState? capturedState;

      final router = GoRouter(
        initialLocation: '/habit/create',
        initialExtra: const HabitCreateExtra(),
        routes: [
          GoRoute(
            path: '/habit/create',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitCreate();
      expect(params.initForm, isNull);
    });
  });
}
