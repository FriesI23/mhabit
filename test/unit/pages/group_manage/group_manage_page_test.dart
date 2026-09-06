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

import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_group_display.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/pages/group_manage/_providers/group_manage.dart';
import 'package:mhabit/pages/group_manage/page.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/app_ui/app_language.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/routes/app_navigation_coordinator.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder get _adaptiveActions => find.byWidgetPredicate(
  (widget) => widget is AdaptiveAppBarActions,
  description: 'Group Manage adaptive app-bar actions',
);

final class _Fixture {
  _Fixture({
    required this.profile,
    required this.experimental,
    required this.language,
    required this.developer,
    required this.eventBus,
    required this.groupManager,
    required this.groupUUIDs,
    required this.navigationCoordinator,
  });

  final ProfileViewModel profile;
  final AppExperimentalFeatureViewModel experimental;
  final AppLanguageViewModel language;
  final AppDeveloperViewModel developer;
  final AppEventBus eventBus;
  final GroupManager groupManager;
  final List<String> groupUUIDs;
  final AppNavigationCoordinator navigationCoordinator;

  void dispose() {
    navigationCoordinator.dispose();
    eventBus.dispose();
    developer.dispose();
    language.dispose();
    experimental.dispose();
    profile.dispose();
  }
}

final class _FakeGroupManager extends GroupManager {
  _FakeGroupManager(this.groups);

  final List<GroupDBCell> groups;

  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult(groups);
}

Future<_Fixture> _createFixture() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([DisplayGroupModeProfileHandler.new]);
  await profile.init();
  final experimental = AppExperimentalFeatureViewModel()
    ..updateProfile(profile);
  final language = AppLanguageViewModel()..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global(), profile: profile);
  final eventBus = AppEventBus();
  final groups = [
    const GroupDBCell(
      uuid: 'group-1',
      name: 'First',
      status: 1,
      sortPosition: 1,
    ),
    const GroupDBCell(
      uuid: 'group-2',
      name: 'Second',
      status: 1,
      sortPosition: 2,
    ),
  ];
  final groupManager = _FakeGroupManager(groups);
  return _Fixture(
    profile: profile,
    experimental: experimental,
    language: language,
    developer: developer,
    eventBus: eventBus,
    groupManager: groupManager,
    groupUUIDs: groups.map((group) => group.uuid!).toList(),
    navigationCoordinator: AppNavigationCoordinator(
      branchObservers: const [],
      appFlowObserver: AdaptiveBranchRouteObserver(),
      appChromeNavigatorKey: GlobalKey<NavigatorState>(),
      initialIndex: 0,
    ),
  );
}

Future<GroupManageViewModel> _pumpPage(
  WidgetTester tester, {
  required _Fixture fixture,
  TargetPlatform platform = TargetPlatform.android,
  Size size = const Size(500, 800),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: fixture.profile),
        ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
          value: fixture.experimental,
        ),
        ChangeNotifierProvider<AppLanguageViewModel>.value(
          value: fixture.language,
        ),
        ChangeNotifierProvider<AppDeveloperViewModel>.value(
          value: fixture.developer,
        ),
        ChangeNotifierProvider<AppEventBus>.value(value: fixture.eventBus),
        ChangeNotifierProvider<AppNavigationCoordinator>.value(
          value: fixture.navigationCoordinator,
        ),
        Provider<GroupManager>.value(value: fixture.groupManager),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: const GroupManagePage(),
      ),
    ),
  );
  await tester.pump();
  final vm = tester
      .element(find.byType(AdaptiveSliverAppBar))
      .read<GroupManageViewModel>();
  for (var attempt = 0; attempt < 20 && !vm.hasLoaded; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(vm.hasLoaded, isTrue);
  await tester.pump();
  return vm;
}

dynamic _actionsWidget(WidgetTester tester) =>
    tester.widget<Widget>(_adaptiveActions);

List<dynamic> _actionRoots(WidgetTester tester) =>
    List<dynamic>.from(_actionsWidget(tester).collection.roots as Iterable);

void main() {
  testWidgets('normal mode uses adaptive chrome and enters reorder mode', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(tester, fixture: fixture);

    expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
    expect(find.byType(WindowControlSliverAppBar), findsOneWidget);
    expect(_adaptiveActions, findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    final normalBar = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    expect(normalBar.floating, isTrue);
    expect(normalBar.snap, isTrue);
    expect(normalBar.pinned, isTrue);
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
    expect(_actionsWidget(tester).maxPrimaryActions, 2);
    expect(_actionRoots(tester).map((action) => action.metadata.label), [
      'Reorder groups',
      'Sort Groups',
    ]);

    await tester.tap(find.byIcon(MdiIcons.sortVariant));
    await tester.pump(const Duration(milliseconds: 300));

    expect(vm.selectionMode, isTrue);
    expect(vm.effectiveSortType, HabitDisplayGroupType.manual);
    final selectionBar = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    expect(selectionBar.floating, isFalse);
    expect(selectionBar.snap, isFalse);
    expect(selectionBar.pinned, isTrue);
    expect(selectionBar.forceElevated, isTrue);
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.close,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
      isNull,
    );

    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pump(const Duration(milliseconds: 300));
    expect(vm.selectionMode, isFalse);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('sort icon follows direction-only changes', (tester) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(tester, fixture: fixture);
    final nextDirection = switch (vm.effectiveSortDirection) {
      HabitDisplaySortDirection.asc => HabitDisplaySortDirection.desc,
      HabitDisplaySortDirection.desc => HabitDisplaySortDirection.asc,
    };

    await vm.setSortOptions(vm.effectiveSortType, nextDirection);
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widget<GroupTypeSortIcon>(find.byType(GroupTypeSortIcon))
          .direction,
      nextDirection,
    );
  });

  testWidgets('compact selection prioritizes Edit then Select all', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(tester, fixture: fixture);

    vm.enterSelectionMode(fixture.groupUUIDs.first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(_actionsWidget(tester).maxPrimaryActions, 1);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.select_all), findsNothing);
    expect(_actionRoots(tester).map((action) => action.metadata.label), [
      'Edit',
      'Select all',
      'Reorder groups',
      'Delete',
    ]);

    final selectAllAction = _actionRoots(
      tester,
    ).singleWhere((action) => action.metadata.label == 'Select all');
    _actionsWidget(
      tester,
    ).onInvoke(tester.element(_adaptiveActions), selectAllAction.payload);
    await tester.pump(const Duration(milliseconds: 300));

    expect(vm.selectedCount, fixture.groupUUIDs.length);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.select_all), findsOneWidget);
  });

  testWidgets('selection capacity follows Material width classes', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(tester, fixture: fixture);
    vm.enterSelectionMode(fixture.groupUUIDs.first);
    await tester.pump(const Duration(milliseconds: 300));

    for (final (width, expected) in [
      (500.0, 1),
      (700.0, 2),
      (900.0, 3),
      (1300.0, 4),
      (1700.0, 4),
    ]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_actionsWidget(tester).maxPrimaryActions, expected);
    }
  });

  testWidgets('zero-selection Delete remains present and disabled', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(tester, fixture: fixture);
    vm.enterSelectionModeWithoutNotification();
    await tester.pump(const Duration(milliseconds: 300));

    final deleteAction = _actionRoots(
      tester,
    ).singleWhere((action) => action.metadata.label == 'Delete');
    expect(vm.selectedCount, 0);
    expect(deleteAction.isEnabled, isFalse);
  });

  testWidgets('Apple selection uses native controls with 44 point targets', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = await _pumpPage(
      tester,
      fixture: fixture,
      platform: TargetPlatform.iOS,
    );
    vm.enterSelectionMode(fixture.groupUUIDs.first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
    expect(find.byType(WindowControlSliverAppBar), findsNothing);
    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
    for (final icon in [CupertinoIcons.pencil, CupertinoIcons.ellipsis]) {
      final button = find
          .ancestor(
            of: find.byIcon(icon),
            matching: find.byType(CupertinoButton),
          )
          .first;
      expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
    }
  });
}
