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
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/routes/helpers/habit_detail_helper.dart';

void main() {
  group('HabitDetailExtra', () {
    test(
      'construct with color only — accessors return color, adapter null',
      () {
        const color = HabitColor.builtIn(HabitColorType.cc1);
        const extra = HabitDetailExtra(color: color);

        expect(extra.color, color);
        expect(extra.adapter, isNull);
      },
    );

    test('construct with no arguments — all fields null', () {
      const extra = HabitDetailExtra();

      expect(extra.color, isNull);
      expect(extra.adapter, isNull);
    });

    test('construct with same color — accessor returns same value', () {
      const color = HabitColor.builtIn(HabitColorType.cc5);
      const extra = HabitDetailExtra(color: color);

      expect(extra.color, const HabitColor.builtIn(HabitColorType.cc5));
    });

    test('null color stays null', () {
      const extra = HabitDetailExtra(color: null);

      expect(extra.color, isNull);
    });
  });

  group('unpackHabitDetail', () {
    testWidgets('extracts path parameter and extra correctly', (tester) async {
      GoRouterState? capturedState;
      const extra = HabitDetailExtra(
        color: HabitColor.builtIn(HabitColorType.cc3),
      );

      final router = GoRouter(
        initialLocation: '/habits/test-habit-id',
        initialExtra: extra,
        routes: [
          GoRoute(
            path: '/habits/:habitId',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitDetail();
      expect(params.habitUUID, 'test-habit-id');
      expect(params.color, const HabitColor.builtIn(HabitColorType.cc3));
      expect(params.adapter, isNull);
    });

    testWidgets('returns defaults when extra is null (deep-link compat)', (
      tester,
    ) async {
      GoRouterState? capturedState;

      final router = GoRouter(
        initialLocation: '/habits/test-id',
        routes: [
          GoRoute(
            path: '/habits/:habitId',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitDetail();
      expect(params.habitUUID, 'test-id');
      expect(params.color, isNull);
      expect(params.adapter, isNull);
    });

    testWidgets(
      'returns defaults when extra is wrong type (deep-link compat)',
      (tester) async {
        GoRouterState? capturedState;

        final router = GoRouter(
          initialLocation: '/habits/test-id',
          initialExtra: 'wrong-type',
          routes: [
            GoRoute(
              path: '/habits/:habitId',
              builder: (_, state) {
                capturedState = state;
                return const SizedBox.shrink();
              },
            ),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        final params = capturedState!.unpackHabitDetail();
        expect(params.habitUUID, 'test-id');
        expect(params.color, isNull);
        expect(params.adapter, isNull);
      },
    );
  });
}
