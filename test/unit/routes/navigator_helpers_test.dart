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
import 'package:mhabit/routes/app_navigation_coordinator.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/routes/navigator_helpers.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

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
  group('naviTo* (go_router wrappers)', () {
    testWidgets('naviToHabitEditPage assert fails when editMode != edit', (
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

      final context = tester.element(find.byType(SizedBox).first);
      final createForm = HabitForm.empty(); // editMode defaults to create

      expect(
        () => naviToHabitEditPage(context: context, initForm: createForm),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('naviToHabitEditPage delegates to pushHabitEdit on success', (
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

      const habitId = 'navi-edit-uuid';
      final form = _editForm(uuid: habitId);
      final context = tester.element(find.byType(SizedBox).first);

      // Should not throw — navigation starts.
      expect(
        () => naviToHabitEditPage(context: context, initForm: form),
        returnsNormally,
      );
    });

    testWidgets('naviToHabitCreatePage delegates to pushHabitCreate', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/habit/create',
            name: AppRoute.habitCreate.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final context = tester.element(find.byType(SizedBox).first);

      expect(() => naviToHabitCreatePage(context: context), returnsNormally);
    });

    testWidgets('naviToHabitDetailPage delegates to pushHabitDetail', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/habits/:habitId',
            name: AppRoute.habitDetail.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      const habitUUID = 'navi-detail-uuid';
      final context = tester.element(find.byType(SizedBox).first);

      expect(
        () => naviToHabitDetailPage(context: context, habitUUID: habitUUID),
        returnsNormally,
      );
    });

    testWidgets('naviToAppSettingPage delegates to the app-flow coordinator', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(
            path: '/settings',
            name: AppRoute.settings.name,
            builder: (_, _) => const Text('settings'),
          ),
        ],
      );
      final coordinator = AppNavigationCoordinator(
        branchObservers: const [],
        appFlowObserver: AdaptiveBranchRouteObserver(),
        appChromeNavigatorKey: navigatorKey,
        initialIndex: 0,
      );
      addTearDown(coordinator.dispose);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) =>
              ChangeNotifierProvider<AppNavigationCoordinator>.value(
                value: coordinator,
                child: child!,
              ),
        ),
      );

      final navigation = naviToAppSettingPage(
        context: tester.element(find.text('home')),
      );
      await tester.pumpAndSettle();
      await navigation;

      expect(find.text('settings'), findsOneWidget);
    });

    testWidgets('naviToAppAboutPage delegates to pushNamed', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/settings/about',
            name: AppRoute.settingsAbout.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(() => naviToAppAboutPage(context: context), returnsNormally);
    });

    testWidgets('naviToAppSyncPage delegates to pushNamed', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/settings/sync',
            name: AppRoute.settingsSync.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(() => naviToAppSyncPage(context: context), returnsNormally);
    });

    testWidgets('naviToNotifyConfigPage delegates to pushNamed', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/settings/notify',
            name: AppRoute.settingsNotify.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(() => naviToNotifyConfigPage(context: context), returnsNormally);
    });

    testWidgets('naviToExperimentalFeaturesPage delegates to pushNamed', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/experimental',
            name: AppRoute.experimental.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(
        () => naviToExperimentalFeaturesPage(context: context),
        returnsNormally,
      );
    });

    testWidgets('naviToAppDebuggerPage delegates to pushNamed', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/debugger',
            name: AppRoute.debugger.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(() => naviToAppDebuggerPage(context: context), returnsNormally);
    });

    testWidgets('naviToGroupManagePage delegates with selectedGroupId', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/group/manage',
            name: AppRoute.groupManage.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(
        () => naviToGroupManagePage(context: context, selectedGroupId: 'grp-1'),
        returnsNormally,
      );
    });

    testWidgets('naviToHabitsStatusChangerPage delegates with uuidList', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
          GoRoute(
            path: '/habits/status',
            name: AppRoute.habitsStatus.name,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final context = tester.element(find.byType(SizedBox).first);
      expect(
        () => naviToHabitsStatusChangerPage(
          context: context,
          uuidList: const ['a', 'b'],
        ),
        returnsNormally,
      );
    });
  });
}
