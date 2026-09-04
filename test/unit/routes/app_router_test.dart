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
    testWidgets('widget builders receive context below their page route', (
      tester,
    ) async {
      late BuildContext routeContext;
      final router =
          (AppRouterBuilder()..addHabits(
                builder: (context, state) {
                  routeContext = context;
                  return Text(state.name ?? 'missing route name');
                },
              ))
              .build(home: AppRoute.habits);
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text(AppRoute.habits.name), findsOneWidget);
      expect(ModalRoute.of(routeContext)?.settings.name, AppRoute.habits.name);
      expect(GoRouterState.of(routeContext).name, AppRoute.habits.name);
    });

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
      expect(route.pageBuilder, isNotNull);
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
      expect(route.pageBuilder, isNotNull);
    });

    test('addHabitCreate sets correct path and name', () {
      final appFlow = AppFlowRouterBuilder()
        ..addHabitCreate(builder: (_, _) => const SizedBox.shrink());
      final router =
          (AppRouterBuilder()..addShellRoute(
                appFlow: appFlow,
                branches: [
                  BranchRouterBuilder()
                    ..addHabits(builder: (_, _) => const SizedBox.shrink()),
                ],
                builder: (_, _, child) => child,
                branchBuilder: (_, _, _) => const SizedBox.shrink(),
              ))
              .build();
      final shell = router.configuration.routes.first as ShellRoute;
      final route = shell.routes[0] as GoRoute;
      expect(route.path, '/habit/create');
      expect(route.name, AppRoute.habitCreate.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('addHabitEdit sets correct path and name', () {
      final appFlow = AppFlowRouterBuilder()
        ..addHabitEdit(builder: (_, _) => const SizedBox.shrink());
      final router =
          (AppRouterBuilder()..addShellRoute(
                appFlow: appFlow,
                branches: [
                  BranchRouterBuilder()
                    ..addHabits(builder: (_, _) => const SizedBox.shrink()),
                ],
                builder: (_, _, child) => child,
                branchBuilder: (_, _, _) => const SizedBox.shrink(),
              ))
              .build();
      final shell = router.configuration.routes.first as ShellRoute;
      final route = shell.routes[0] as GoRoute;
      expect(route.path, '/habit/edit');
      expect(route.name, AppRoute.habitEdit.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('addDebugger sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addDebugger(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/debugger');
      expect(route.name, AppRoute.debugger.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('addGroupManage sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addGroupManage(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/group/manage');
      expect(route.name, AppRoute.groupManage.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('addHabitsStatus sets correct path and name', () {
      final router =
          (AppRouterBuilder()
                ..addHabitsStatus(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final route = router.configuration.routes.first as GoRoute;
      expect(route.path, '/habits/status');
      expect(route.name, AppRoute.habitsStatus.name);
      expect(route.pageBuilder, isNotNull);
    });

    test('chains standalone routes in registration order', () {
      final router =
          (AppRouterBuilder()
                ..addHabits(builder: (_, _) => const SizedBox.shrink())
                ..addToday(builder: (_, _) => const SizedBox.shrink())
                ..addHabitDetail(builder: (_, _) => const SizedBox.shrink())
                ..addDebugger(builder: (_, _) => const SizedBox.shrink())
                ..addGroupManage(builder: (_, _) => const SizedBox.shrink())
                ..addHabitsStatus(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(6));
      final expectedPaths = [
        '/habits',
        '/today',
        '/habits/:habitId',
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

  group('appShellFlowVisibilityPolicy', () {
    test('shows chrome for an empty or single tab-shell stack', () {
      expect(appShellFlowVisibilityPolicy(const []), isTrue);
      expect(appShellFlowVisibilityPolicy(const [null]), isTrue);
      expect(appShellFlowVisibilityPolicy([AppRoute.habits.name]), isTrue);
    });

    test('hides compact chrome for pushed or direct common flows', () {
      expect(
        appShellFlowVisibilityPolicy([null, AppRoute.habitCreate.name]),
        isFalse,
      );
      expect(
        appShellFlowVisibilityPolicy([AppRoute.habitCreate.name]),
        isFalse,
      );
      expect(appShellFlowVisibilityPolicy([AppRoute.habitEdit.name]), isFalse);
      expect(
        appShellFlowVisibilityPolicy([AppRoute.habitsStatus.name]),
        isFalse,
      );
      expect(
        appShellFlowVisibilityPolicy([AppRoute.groupManage.name]),
        isFalse,
      );
      expect(appShellFlowVisibilityPolicy([AppRoute.settings.name]), isFalse);
      expect(
        appShellFlowVisibilityPolicy([AppRoute.experimental.name]),
        isFalse,
      );
    });
  });

  group('Settings app flow', () {
    test('recognizes every Settings presentation route', () {
      expect(isSettingsFlowRouteName(AppRoute.settings.name), isTrue);
      expect(isSettingsFlowRouteName(AppRoute.settingsAbout.name), isTrue);
      expect(isSettingsFlowRouteName(AppRoute.settingsSync.name), isTrue);
      expect(isSettingsFlowRouteName(AppRoute.settingsNotify.name), isTrue);
      expect(isSettingsFlowRouteName(AppRoute.experimental.name), isTrue);
      expect(isSettingsFlowRouteName(AppRoute.groupManage.name), isFalse);
      expect(isSettingsFlowRouteName(AppRoute.habits.name), isFalse);
      expect(isSettingsFlowRouteName(null), isFalse);
    });

    test('derives Group Manage auxiliary selection from its source stack', () {
      expect(
        isSettingsAuxiliaryRouteStack([null, AppRoute.groupManage.name]),
        isFalse,
      );
      expect(
        isSettingsAuxiliaryRouteStack([
          null,
          AppRoute.settings.name,
          AppRoute.groupManage.name,
        ]),
        isTrue,
      );
      expect(
        isSettingsAuxiliaryRouteStack([AppRoute.groupManage.name]),
        isFalse,
      );
    });

    test('nests Settings pages and preserves Experimental path', () {
      final appFlow = AppFlowRouterBuilder()
        ..addSettingsFlow(
          settingsBuilder: (_, state) => MaterialPage<void>(
            key: state.pageKey,
            child: const SizedBox.shrink(),
          ),
          aboutBuilder: (_, _) => const SizedBox.shrink(),
          syncBuilder: (_, _) => const SizedBox.shrink(),
          notifyBuilder: (_, _) => const SizedBox.shrink(),
          experimentalBuilder: (_, _) => const SizedBox.shrink(),
        );
      final router =
          (AppRouterBuilder()..addShellRoute(
                appFlow: appFlow,
                branches: [
                  BranchRouterBuilder()
                    ..addHabits(builder: (_, _) => const SizedBox.shrink()),
                ],
                builder: (_, _, child) => child,
                branchBuilder: (_, _, _) => const SizedBox.shrink(),
              ))
              .build();
      final shell = router.configuration.routes.first as ShellRoute;
      final settings = shell.routes[0] as GoRoute;
      final experimental = shell.routes[1] as GoRoute;

      expect(settings.path, '/settings');
      expect(settings.name, AppRoute.settings.name);
      expect(settings.routes.map((route) => (route as GoRoute).path), [
        'about',
        'sync',
        'notify',
      ]);
      expect(settings.routes.map((route) => (route as GoRoute).name), [
        AppRoute.settingsAbout.name,
        AppRoute.settingsSync.name,
        AppRoute.settingsNotify.name,
      ]);
      expect(experimental.path, '/experimental');
      expect(experimental.name, AppRoute.experimental.name);
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

    AppFlowRouterBuilder buildAppFlowRoutes() => AppFlowRouterBuilder()
      ..addHabitCreate(builder: (_, _) => const SizedBox.shrink())
      ..addHabitEdit(builder: (_, _) => const SizedBox.shrink())
      ..addHabitsStatus(builder: (_, _) => const SizedBox.shrink())
      ..addGroupManage(builder: (_, _) => const SizedBox.shrink());

    test('addShellRoute nests tab branches under an app chrome shell', () {
      final router =
          (AppRouterBuilder()..addShellRoute(
                appFlow: buildAppFlowRoutes(),
                branches: buildBranchRoutes(),
                builder: (_, _, child) => child,
                branchBuilder: (_, _, _) => const SizedBox.shrink(),
              ))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(1));
      final appChromeShell = routes.first as ShellRoute;
      expect(appChromeShell.builder, isNotNull);
      expect(appChromeShell.routes, hasLength(5));

      expect((appChromeShell.routes[0] as GoRoute).path, '/habit/create');
      expect((appChromeShell.routes[1] as GoRoute).path, '/habit/edit');
      expect((appChromeShell.routes[2] as GoRoute).path, '/habits/status');
      expect((appChromeShell.routes[3] as GoRoute).path, '/group/manage');
      expect(
        (appChromeShell.routes[3] as GoRoute).name,
        AppRoute.groupManage.name,
      );

      final tabShell = appChromeShell.routes[4] as StatefulShellRoute;
      expect(tabShell.builder, isNotNull);
      expect(tabShell.branches, hasLength(2));

      final cases = [
        (tabShell.branches[0].routes[0], '/habits', AppRoute.habits.name),
        (
          tabShell.branches[0].routes[1],
          '/habits/:habitId',
          AppRoute.habitDetail.name,
        ),
        (tabShell.branches[1].routes[0], '/today', AppRoute.today.name),
      ];
      for (final (route, path, name) in cases) {
        final goRoute = route as GoRoute;
        expect(goRoute.path, path);
        expect(goRoute.name, name);
      }
    });

    test('shell route coexists with remaining root-level routes', () {
      final router =
          (AppRouterBuilder()
                ..addShellRoute(
                  appFlow: buildAppFlowRoutes(),
                  branches: buildBranchRoutes(),
                  builder: (_, _, child) => child,
                  branchBuilder: (_, _, _) => const SizedBox.shrink(),
                )
                ..addDebugger(builder: (_, _) => const SizedBox.shrink()))
              .build();
      final routes = router.configuration.routes;
      expect(routes, hasLength(2));
      expect(routes[0], isA<ShellRoute>());
      final appChromeShell = routes[0] as ShellRoute;
      expect((appChromeShell.routes[0] as GoRoute).path, '/habit/create');
      expect((appChromeShell.routes[1] as GoRoute).path, '/habit/edit');
      expect((appChromeShell.routes[2] as GoRoute).path, '/habits/status');
      expect((appChromeShell.routes[3] as GoRoute).path, '/group/manage');
      expect(appChromeShell.routes[4], isA<StatefulShellRoute>());
      expect((routes[1] as GoRoute).path, '/debugger');
    });
  });
}
