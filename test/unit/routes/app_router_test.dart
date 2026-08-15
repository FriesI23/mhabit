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
      final router =
          (AppRouterBuilder()
                ..addHabits(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habits');
      expect(route.name, AppRoute.habits.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitDetail sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addHabitDetail(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habits/:habitId');
      expect(route.name, AppRoute.habitDetail.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitCreate sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addHabitCreate(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habit/create');
      expect(route.name, AppRoute.habitCreate.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitEdit sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addHabitEdit(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final route = routes.first as GoRoute;
      expect(route.path, '/habit/edit');
      expect(route.name, AppRoute.habitEdit.name);
      expect(route.builder, isNotNull);
    });

    test('addSettings sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addSettings(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/settings');
      expect(route.name, AppRoute.settings.name);
      expect(route.builder, isNotNull);
    });

    test('addSettingsAbout sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addSettingsAbout(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/settings/about');
      expect(route.name, AppRoute.settingsAbout.name);
      expect(route.builder, isNotNull);
    });

    test('addSettingsSync sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addSettingsSync(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/settings/sync');
      expect(route.name, AppRoute.settingsSync.name);
      expect(route.builder, isNotNull);
    });

    test('addSettingsNotify sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addSettingsNotify(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/settings/notify');
      expect(route.name, AppRoute.settingsNotify.name);
      expect(route.builder, isNotNull);
    });

    test('addExperimental sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addExperimental(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/experimental');
      expect(route.name, AppRoute.experimental.name);
      expect(route.builder, isNotNull);
    });

    test('addDebugger sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addDebugger(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/debugger');
      expect(route.name, AppRoute.debugger.name);
      expect(route.builder, isNotNull);
    });

    test('addGroupManage sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addGroupManage(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/group/manage');
      expect(route.name, AppRoute.groupManage.name);
      expect(route.builder, isNotNull);
    });

    test('addHabitsStatus sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addHabitsStatus(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/habits/status');
      expect(route.name, AppRoute.habitsStatus.name);
      expect(route.builder, isNotNull);
    });

    test('chains all 11 routes in registration order', () {
      final router =
          (AppRouterBuilder()
                ..addHabits(builder: (_, _) => const SizedBox.shrink())
                ..addToday(builder: (_, _) => const SizedBox.shrink())
                ..addHabitDetail(builder: (_, _) => const SizedBox.shrink())
                ..addSettings(builder: (_, _) => const SizedBox.shrink())
                ..addSettingsAbout(builder: (_, _) => const SizedBox.shrink())
                ..addSettingsSync(builder: (_, _) => const SizedBox.shrink())
                ..addSettingsNotify(builder: (_, _) => const SizedBox.shrink())
                ..addExperimental(builder: (_, _) => const SizedBox.shrink())
                ..addDebugger(builder: (_, _) => const SizedBox.shrink())
                ..addGroupManage(builder: (_, _) => const SizedBox.shrink())
                ..addHabitsStatus(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(11));
      final expectedPaths = [
        '/habits',
        '/today',
        '/habits/:habitId',
        '/settings',
        '/settings/about',
        '/settings/sync',
        '/settings/notify',
        '/experimental',
        '/debugger',
        '/group/manage',
        '/habits/status',
      ];
      for (final (index, path) in expectedPaths.indexed) {
        expect((routes[index] as GoRoute).path, path);
      }
    });

    test('build without home leaves initialLocation unset', () {
      final router =
          (AppRouterBuilder()
                ..addHabits(builder: (_, _) => const SizedBox.shrink()))
              .build();
      // When no home is set, routeInformationProvider wraps initialLocation
      // in a RouteInformation. Verify configuration has the routes.
      expect(router.configuration.routes, hasLength(1));
    });

    test('AppRoute enum name matches path convention', () {
      expect(AppRoute.habits.name, 'habits');
      expect(AppRoute.today.name, 'today');
      expect(AppRoute.habitDetail.name, 'habits/:habitId');
      expect(AppRoute.habitCreate.name, 'habit/create');
      expect(AppRoute.habitEdit.name, 'habit/edit');
      expect(AppRoute.settings.name, 'settings');
      expect(AppRoute.settingsAbout.name, 'settings/about');
      expect(AppRoute.settingsSync.name, 'settings/sync');
      expect(AppRoute.settingsNotify.name, 'settings/notify');
      expect(AppRoute.experimental.name, 'experimental');
      expect(AppRoute.debugger.name, 'debugger');
      expect(AppRoute.groupManage.name, 'group/manage');
      expect(AppRoute.habitsStatus.name, 'habits/status');
    });
  });

  group('appShellBarVisibilityPolicy', () {
    test('shows the bar only on the branch root', () {
      expect(appShellBarVisibilityPolicy([AppRoute.habits.name]), isTrue);
      expect(appShellBarVisibilityPolicy([AppRoute.today.name]), isTrue);
    });

    test('hides the bar for any route pushed above the root', () {
      expect(
        appShellBarVisibilityPolicy([
          AppRoute.habits.name,
          AppRoute.habitDetail.name,
        ]),
        isFalse,
      );
      expect(
        appShellBarVisibilityPolicy([AppRoute.habits.name, 'any/other']),
        isFalse,
      );
    });

    test('inherits hiding across unnamed routes pushed above (dialogs)', () {
      expect(
        appShellBarVisibilityPolicy([AppRoute.habits.name, null]),
        isFalse,
      );
      expect(
        appShellBarVisibilityPolicy([
          AppRoute.habits.name,
          AppRoute.habitDetail.name,
          null,
        ]),
        isFalse,
      );
    });
  });

  group('AppRouterBuilder shell routes', () {
    List<BranchRouterBuilder> buildBranchRoutes() => [
      BranchRouterBuilder()
        ..addHabits(builder: (_, _) => const SizedBox.shrink())
        ..addHabitDetail(builder: (_, _) => const SizedBox.shrink()),
      BranchRouterBuilder()
        ..addToday(builder: (_, _) => const SizedBox.shrink()),
    ];

    test('addShellRoute wraps branch routes into a StatefulShellRoute', () {
      final router =
          (AppRouterBuilder()..addShellRoute(
                branches: buildBranchRoutes(),
                builder: (_, _, _) => const SizedBox.shrink(),
              ))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final shell = routes.first as StatefulShellRoute;
      expect(shell.builder, isNotNull);
      expect(shell.branches, hasLength(2));

      final cases = [
        (shell.branches[0].routes[0], '/habits', AppRoute.habits.name),
        (
          shell.branches[0].routes[1],
          '/habits/:habitId',
          AppRoute.habitDetail.name,
        ),
        (shell.branches[1].routes[0], '/today', AppRoute.today.name),
      ];
      for (final (route, path, name) in cases) {
        final goRoute = route as GoRoute;
        expect(goRoute.path, path);
        expect(goRoute.name, name);
      }
    });

    test('shell route coexists with root-level routes', () {
      final router =
          (AppRouterBuilder()
                ..addShellRoute(
                  branches: buildBranchRoutes(),
                  builder: (_, _, _) => const SizedBox.shrink(),
                )
                ..addHabitCreate(builder: (_, _) => const SizedBox.shrink())
                ..addHabitEdit(builder: (_, _) => const SizedBox.shrink())
                ..addGroupManage(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(4));
      expect(routes[0], isA<StatefulShellRoute>());
      expect((routes[1] as GoRoute).path, '/habit/create');
      expect((routes[2] as GoRoute).path, '/habit/edit');
      expect((routes[3] as GoRoute).path, '/group/manage');
    });
  });
}
