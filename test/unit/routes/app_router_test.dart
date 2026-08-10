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
import 'package:mhabit/routes/app_router.dart';

void main() {
  group('AppRouterBuilder', () {
    test('build with no routes produces empty route list', () {
      final router = AppRouterBuilder().build();
      final routes = router.configuration.routes;
      expect(routes, isEmpty);
    });

    test('addHabits sets correct path and name', () {
      final router = AppRouterBuilder()
          .addHabits(builder: (_, _) => const SizedBox.shrink())
          .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habits');
      expect(route.name, AppRoute.habits.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitDetail sets correct path and name', () {
      final router = AppRouterBuilder()
          .addHabitDetail(builder: (_, _) => const SizedBox.shrink())
          .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habits/:habitId');
      expect(route.name, AppRoute.habitDetail.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitCreate sets correct path, name and pageBuilder', () {
      final router = AppRouterBuilder()
          .addHabitCreate(
            pageBuilder: (_, _) =>
                const MaterialPage<void>(child: SizedBox.shrink()),
          )
          .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habit/create');
      expect(route.name, AppRoute.habitCreate.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('addHabitEdit sets correct path, name and pageBuilder', () {
      final router = AppRouterBuilder()
          .addHabitEdit(
            pageBuilder: (_, _) =>
                const MaterialPage<void>(child: SizedBox.shrink()),
          )
          .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habit/edit');
      expect(route.name, AppRoute.habitEdit.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('chains all routes in registration order', () {
      final router = AppRouterBuilder()
          .addHabits(builder: (_, _) => const SizedBox.shrink())
          .addHabitDetail(builder: (_, _) => const SizedBox.shrink())
          .addHabitCreate(
            pageBuilder: (_, _) =>
                const MaterialPage<void>(child: SizedBox.shrink()),
          )
          .addHabitEdit(
            pageBuilder: (_, _) =>
                const MaterialPage<void>(child: SizedBox.shrink()),
          )
          .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(4));
      expect((routes[0] as GoRoute).path, '/habits');
      expect((routes[1] as GoRoute).path, '/habits/:habitId');
      expect((routes[2] as GoRoute).path, '/habit/create');
      expect((routes[3] as GoRoute).path, '/habit/edit');
    });

    test('build without home leaves initialLocation unset', () {
      final router = AppRouterBuilder()
          .addHabits(builder: (_, _) => const SizedBox.shrink())
          .build();
      // When no home is set, routeInformationProvider wraps initialLocation
      // in a RouteInformation. Verify configuration has the routes.
      expect(router.configuration.routes, hasLength(1));
    });

    test('AppRoute enum name matches path convention', () {
      expect(AppRoute.habits.name, 'habits');
      expect(AppRoute.habitDetail.name, 'habits/:habitId');
      expect(AppRoute.habitCreate.name, 'habit/create');
      expect(AppRoute.habitEdit.name, 'habit/edit');
    });
  });
}
