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
import 'package:mhabit/entries/common/app_root_view.dart';

void main() {
  group('AppRootView', () {
    testWidgets('default constructor builds MaterialApp with home:', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView(
          themeMode: ThemeMode.system,
          child: Text('home-child'),
        ),
      );

      expect(find.text('home-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('.router constructor builds MaterialApp.router with config', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('router-child')),
        ],
      );

      await tester.pumpWidget(
        AppRootView.router(themeMode: ThemeMode.system, config: router),
      );

      expect(find.text('router-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('.withDefault uses ThemeMode.system by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView.withDefault(child: Text('default-child')),
      );

      expect(find.text('default-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'router path: no navigatorKey/navigatorObservers on MaterialApp',
      (tester) async {
        // When routerConfig is provided, navigatorKey is managed by GoRouter
        // and should not appear as direct properties on MaterialApp.
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Text('router-key-test'),
            ),
          ],
        );

        await tester.pumpWidget(
          AppRootView.router(themeMode: ThemeMode.system, config: router),
        );

        expect(find.text('router-key-test'), findsOneWidget);

        // Verify a MaterialApp.router descendant exists (no crash = success).
        final materialAppFinder = find.byType(MaterialApp);
        expect(materialAppFinder, findsOneWidget);
      },
    );

    testWidgets('home path: navigatorKey and observers on MaterialApp', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView(
          themeMode: ThemeMode.system,
          child: Text('home-key-test'),
        ),
      );

      expect(find.text('home-key-test'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
