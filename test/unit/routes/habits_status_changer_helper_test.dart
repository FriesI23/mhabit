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
import 'package:mhabit/routes/helpers/habits_status_changer_helper.dart';

void main() {
  group('HabitsStatusChangerExtra', () {
    test('construct with uuidList — accessor returns it', () {
      const uuidList = ['a', 'b', 'c'];
      const extra = HabitsStatusChangerExtra(uuidList: uuidList);

      expect(extra.uuidList, uuidList);
    });

    test('construct with no arguments — uuidList is null', () {
      const extra = HabitsStatusChangerExtra();

      expect(extra.uuidList, isNull);
    });

    test('construct with null uuidList explicitly — uuidList is null', () {
      const extra = HabitsStatusChangerExtra(uuidList: null);

      expect(extra.uuidList, isNull);
    });
  });

  group('unpackHabitsStatusChanger', () {
    testWidgets('extra uuidList takes priority over query params', (
      tester,
    ) async {
      GoRouterState? capturedState;
      const uuidList = ['extra-a', 'extra-b'];
      const extra = HabitsStatusChangerExtra(uuidList: uuidList);

      final router = GoRouter(
        initialLocation: '/habits/status?habitId=qp-a&habitId=qp-b',
        initialExtra: extra,
        routes: [
          GoRoute(
            path: '/habits/status',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitsStatusChanger();
      expect(params.uuidList, uuidList);
    });

    testWidgets('falls back to queryParametersAll when extra is null', (
      tester,
    ) async {
      GoRouterState? capturedState;

      final router = GoRouter(
        initialLocation: '/habits/status?habitId=deeplink-a&habitId=deeplink-b',
        routes: [
          GoRoute(
            path: '/habits/status',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitsStatusChanger();
      expect(params.uuidList, ['deeplink-a', 'deeplink-b']);
    });

    testWidgets(
      'falls back to queryParametersAll when extra uuidList is null',
      (tester) async {
        GoRouterState? capturedState;
        const extra = HabitsStatusChangerExtra();

        final router = GoRouter(
          initialLocation: '/habits/status?habitId=qp-only',
          initialExtra: extra,
          routes: [
            GoRoute(
              path: '/habits/status',
              builder: (_, state) {
                capturedState = state;
                return const SizedBox.shrink();
              },
            ),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        final params = capturedState!.unpackHabitsStatusChanger();
        expect(params.uuidList, ['qp-only']);
      },
    );

    testWidgets('returns empty list when no source provides uuidList', (
      tester,
    ) async {
      GoRouterState? capturedState;

      final router = GoRouter(
        initialLocation: '/habits/status',
        routes: [
          GoRoute(
            path: '/habits/status',
            builder: (_, state) {
              capturedState = state;
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final params = capturedState!.unpackHabitsStatusChanger();
      expect(params.uuidList, isEmpty);
    });
  });
}
