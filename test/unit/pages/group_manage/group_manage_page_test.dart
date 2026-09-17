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

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoCheckbox,
        CupertinoIcons,
        CupertinoMenuAnchor;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_group_display.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/pages/group_manage/_providers/group_manage.dart';
import 'package:mhabit/pages/group_manage/page.dart';
import 'package:mhabit/pages/group_manage/widgets.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/app_ui/app_language.dart';
import 'package:mhabit/providers/app_ui/custom_color_history.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/routes/app_navigation_coordinator.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/adaptive_dialog.dart';

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
  final List<List<String>> deletions = [];
  final List<List<String>> reorders = [];

  @override
  Future<HabitGroupData?> loadGroupDataByUUID(String uuid) async {
    final matches = groups.where((group) => group.uuid == uuid);
    return matches.isEmpty
        ? null
        : HabitGroupData.fromDBQueryCell(matches.first);
  }

  @override
  Future<List<String>> fixAndSaveSortPositions(
    List<HabitGroupData> items, {
    required num increaseStep,
    required int decimalPlaces,
  }) async {
    reorders.add(items.map((item) => item.uuid).toList());
    return [];
  }

  @override
  Future<void> deleteGroups(List<String> uuids) async {
    deletions.add(List.of(uuids));
    groups.removeWhere((group) => uuids.contains(group.uuid));
  }

  @override
  Future<HabitGroupData> createGroup({
    required String name,
    String? desc,
    GroupIcon? icon,
    GroupColor? color,
  }) async {
    final cell = GroupDBCell(
      uuid: 'created-group',
      sortPosition: groups.length + 1,
      name: name,
      desc: desc,
      status: 1,
    );
    groups.add(cell);
    return HabitGroupData.fromDBQueryCell(cell);
  }

  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult(groups);
}

Future<_Fixture> _createFixture({bool empty = false}) async {
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
      desc: 'A group description that may need truncation',
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
  if (empty) groups.clear();
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
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  Brightness brightness = Brightness.light,
  Color? adaptiveSurface,
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
        ChangeNotifierProvider(create: (_) => CustomColorHistoryViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          platform: platform,
          brightness: brightness,
          extensions: [
            if (adaptiveSurface != null)
              AdaptiveListThemeData(surfaceColor: adaptiveSurface),
          ],
        ),
        builder: (context, child) => Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
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
  for (final brightness in Brightness.values) {
    for (final width in [320.0, 900.0]) {
      testWidgets(
        'Apple group surface follows section palette $brightness $width',
        (tester) async {
          final fixture = await _createFixture();
          addTearDown(fixture.dispose);
          addTearDown(tester.view.reset);
          const surface = Color(0xff7b456f);
          final vm = await _pumpPage(
            tester,
            fixture: fixture,
            platform: TargetPlatform.iOS,
            size: Size(width, 1000),
            brightness: brightness,
            adaptiveSurface: surface,
          );
          await tester.pumpAndSettle();

          expect(
            find.byType(GroupManageListItem),
            width == 320 ? findsNWidgets(2) : findsNothing,
          );
          expect(
            find.byType(GroupManageGridItem),
            width == 900 ? findsNWidgets(2) : findsNothing,
          );

          ColoredBox groupSurface() => tester.widget<ColoredBox>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('group-1')),
                  matching: find.byWidgetPredicate(
                    (widget) => widget is ColoredBox && widget.color == surface,
                  ),
                )
                .first,
          );

          expect(groupSurface().color, surface);
          expect(
            groupSurface().color,
            isNot(
              Theme.of(
                tester.element(find.byType(Scaffold)),
              ).colorScheme.surface,
            ),
          );

          vm.enterSelectionMode('group-1');
          await tester.pumpAndSettle();
          final selectedSurface = tester.widgetList<ColoredBox>(
            find.descendant(
              of: find.byKey(const ValueKey('group-1')),
              matching: find.byType(ColoredBox),
            ),
          );
          expect(selectedSurface.any((box) => box.color != surface), isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final width in [320.0, 900.0]) {
      testWidgets('group items selection menus large text $platform $width', (
        tester,
      ) async {
        final fixture = await _createFixture();
        addTearDown(fixture.dispose);
        addTearDown(tester.view.reset);
        final vm = await _pumpPage(
          tester,
          fixture: fixture,
          platform: platform,
          size: Size(width, 1100),
          textScale: 2,
          textDirection: TextDirection.rtl,
        );
        await tester.pumpAndSettle();
        final firstRow = find.byKey(const ValueKey('group-1'));
        expect(
          find.descendant(
            of: firstRow,
            matching: find.byType(
              platform == TargetPlatform.android
                  ? MenuAnchor
                  : CupertinoMenuAnchor,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: firstRow,
            matching: find.byType(
              platform == TargetPlatform.android
                  ? MaterialGroupManageItemActions
                  : AppleGroupManageItemActions,
            ),
          ),
          findsOneWidget,
        );
        if (platform == TargetPlatform.android) {
          final menu = tester.widget<MenuAnchor>(
            find.descendant(of: firstRow, matching: find.byType(MenuAnchor)),
          );
          expect(menu.animated, isTrue);
        }
        vm.enterSelectionMode('group-1');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();
        expect(vm.selectedUUIDs, containsAll(['group-1', 'group-2']));
        vm.exitSelectionMode();
        await vm.setSortOptions(
          HabitDisplayGroupType.name,
          HabitDisplaySortDirection.asc,
        );
        await tester.pumpAndSettle();
        final menuAnchor = find.descendant(
          of: firstRow,
          matching: find.byType(
            platform == TargetPlatform.android
                ? MenuAnchor
                : CupertinoMenuAnchor,
          ),
        );
        final moreIcon = find.descendant(
          of: firstRow,
          matching: find.byIcon(
            platform == TargetPlatform.android
                ? Icons.more_vert
                : CupertinoIcons.ellipsis,
          ),
        );
        final anchorRect = tester.getRect(menuAnchor);
        expect(anchorRect.contains(tester.getCenter(moreIcon)), isTrue);
        expect(anchorRect.width, lessThan(tester.getSize(firstRow).width / 2));
        await tester.tap(moreIcon);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit').hitTestable().last);
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveModal), findsOneWidget);
        await tester.tap(find.text('Cancel').hitTestable().last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('First'), buttons: kSecondaryMouseButton);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').hitTestable().last);
        await tester.pumpAndSettle();
        expect(find.text('Delete Group'), findsOneWidget);
        await tester.tap(find.text('Cancel').hitTestable().last);
        await tester.pumpAndSettle();
        expect((fixture.groupManager as _FakeGroupManager).deletions, isEmpty);
        await tester.longPress(find.text('First'));
        await tester.pumpAndSettle();
        expect(vm.selectedUUIDs, contains('group-1'));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Apple group list retains lazy construction', (tester) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.reset);
    (fixture.groupManager as _FakeGroupManager).groups.addAll([
      for (var i = 3; i <= 100; i++)
        GroupDBCell(
          uuid: 'group-$i',
          name: 'Group $i',
          status: 1,
          sortPosition: i,
        ),
    ]);
    final vm = await _pumpPage(
      tester,
      fixture: fixture,
      platform: TargetPlatform.iOS,
      size: const Size(320, 800),
    );
    await vm.setSortOptions(
      HabitDisplayGroupType.manual,
      HabitDisplaySortDirection.asc,
    );
    await tester.pumpAndSettle();
    expect(vm.groups.length, 100);
    expect(find.byIcon(CupertinoIcons.line_horizontal_3), findsNothing);
    expect(find.text('Group 100'), findsNothing);
    expect(find.byType(AdaptiveListTile).evaluate().length, lessThan(30));
    await tester.scrollUntilVisible(
      find.text('Group 100'),
      500,
      maxScrolls: 30,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    // Newly built reorderable items register a delayed entrance animation.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Group 100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Apple desktop drag handle reorders groups', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final fixture = await _createFixture();
      addTearDown(fixture.dispose);
      addTearDown(tester.view.reset);
      final vm = await _pumpPage(
        tester,
        fixture: fixture,
        platform: TargetPlatform.macOS,
        size: const Size(500, 1000),
      );
      await vm.setSortOptions(
        HabitDisplayGroupType.manual,
        HabitDisplaySortDirection.asc,
      );
      await tester.pumpAndSettle();
      final handles = find.byIcon(CupertinoIcons.line_horizontal_3);
      expect(handles, findsNWidgets(2));
      final first = tester.getCenter(handles.first);
      final second = tester.getCenter(handles.last);
      final gesture = await tester.startGesture(first);
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(second);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(vm.selectionMode, isTrue);
      expect((fixture.groupManager as _FakeGroupManager).reorders.last, [
        'group-2',
        'group-1',
      ]);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  for (final platform in [
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.android,
  ]) {
    for (final skip in [false, true]) {
      testWidgets(
        '$platform delete confirmation remembers only explicit skip $skip',
        (tester) async {
          final fixture = await _createFixture();
          addTearDown(fixture.dispose);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final vm = await _pumpPage(
            tester,
            fixture: fixture,
            platform: platform,
          );
          final manager = fixture.groupManager as _FakeGroupManager;
          Future<void> requestDelete(String uuid) async {
            vm.enterSelectionMode(uuid);
            await tester.pumpAndSettle();
            final action = _actionRoots(
              tester,
            ).singleWhere((a) => a.metadata.label == 'Delete');
            _actionsWidget(
              tester,
            ).onInvoke(tester.element(_adaptiveActions), action.payload);
            await tester.pumpAndSettle();
          }

          await requestDelete(fixture.groupUUIDs.first);
          final checkbox = find.byType(
            platform == TargetPlatform.macOS
                ? CupertinoCheckbox
                : CheckboxListTile,
          );
          if (platform != TargetPlatform.iOS) {
            await tester.tap(checkbox);
            await tester.pump();
          }
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          expect(manager.deletions, isEmpty);
          await requestDelete(fixture.groupUUIDs.first);
          expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
          if (skip && platform != TargetPlatform.iOS) {
            await tester.tap(checkbox);
            await tester.pump();
          }
          final label = platform == TargetPlatform.iOS && skip
              ? L10n.of(
                  tester.element(adaptiveDialogFinder),
                )!.confirmDialog_confirmAndSkip_text('Delete')
              : 'Delete';
          final actions = adaptiveDialogActions(tester);
          final submit = actions.firstWhere((a) => a.label == label).onPressed!;
          submit();
          submit();
          await tester.pumpAndSettle();
          expect(manager.deletions, [
            [fixture.groupUUIDs.first],
          ]);
          await requestDelete(fixture.groupUUIDs.last);
          expect(
            find.byType(AdaptiveConfirmDialog),
            skip ? findsNothing : findsOneWidget,
          );
          expect(manager.deletions.length, skip ? 2 : 1);
          if (!skip) {
            await tester.tap(find.text('Cancel'));
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }

  for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
    for (final width in [390.0, 900.0]) {
      testWidgets(
        'Apple normal actions and selection lifecycle $platform $width',
        (tester) async {
          final fixture = await _createFixture();
          addTearDown(fixture.dispose);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();

          final vm = await _pumpPage(
            tester,
            fixture: fixture,
            platform: platform,
            size: Size(width, 800),
          );
          await tester.pumpAndSettle();
          expect(find.byType(FloatingActionButton), findsNothing);
          expect(_actionRoots(tester).map((a) => a.metadata.label), [
            'Create group',
            'Reorder groups',
            'Sort Groups',
          ]);
          expect(
            _actionRoots(tester).last.placementPolicy.placement,
            ActionPlacement.automatic,
          );
          expect(find.byTooltip('Create group'), findsOneWidget);
          expect(find.bySemanticsLabel('Create group'), findsOneWidget);
          semantics.dispose();
          final create = find
              .ancestor(
                of: find.byIcon(CupertinoIcons.add),
                matching: find.byType(CupertinoButton),
              )
              .first;
          expect(tester.getSize(create).width, greaterThanOrEqualTo(44));
          expect(tester.getSize(create).height, greaterThanOrEqualTo(44));
          expect(
            tester.getCenter(create).dx,
            lessThan(
              tester
                  .getCenter(find.byIcon(CupertinoIcons.arrow_up_arrow_down))
                  .dx,
            ),
          );

          await vm.setSortOptions(
            HabitDisplayGroupType.name,
            HabitDisplaySortDirection.desc,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(CupertinoIcons.arrow_up_arrow_down));
          await tester.pumpAndSettle();
          expect(vm.selectionMode, isTrue);
          expect(vm.effectiveSortType, HabitDisplayGroupType.manual);
          expect(find.byIcon(CupertinoIcons.add), findsNothing);
          expect(find.byType(FloatingActionButton), findsNothing);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(vm.selectionMode, isFalse);
          expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
          vm.enterSelectionMode(fixture.groupUUIDs.first);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(AdaptiveBackButton));
          await tester.pumpAndSettle();
          expect(vm.selectionMode, isFalse);
          expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    testWidgets('empty page create cancel and save $platform', (tester) async {
      final fixture = await _createFixture(empty: true);
      addTearDown(fixture.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = await _pumpPage(
        tester,
        fixture: fixture,
        platform: platform,
        size: platform == TargetPlatform.macOS
            ? const Size(900, 800)
            : const Size(390, 800),
      );
      await tester.pumpAndSettle();
      final apple = platform != TargetPlatform.android;
      expect(_actionRoots(tester).map((a) => a.metadata.label), [
        if (apple) 'Create group',
        'Sort Groups',
      ]);
      Finder createButton() => apple
          ? find.byIcon(CupertinoIcons.add)
          : find.byType(FloatingActionButton);
      await tester.tap(createButton());
      await tester.pumpAndSettle();
      expect(find.text('Create Group'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(vm.groups, isEmpty);
      await tester.tap(createButton());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Created from primary action',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(vm.groups.single.name, 'Created from primary action');
      expect(find.text('Created from primary action'), findsOneWidget);
      expect(
        find.byType(FloatingActionButton),
        apple ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Apple RTL resize retains primary actions and sort overflow', (
    tester,
  ) async {
    final fixture = await _createFixture();
    addTearDown(fixture.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpPage(
      tester,
      fixture: fixture,
      platform: TargetPlatform.iOS,
      textDirection: TextDirection.rtl,
    );
    for (final size in [
      const Size(390, 800),
      const Size(900, 800),
      const Size(800, 390),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.arrow_up_arrow_down), findsOneWidget);
      expect(
        tester.getCenter(find.byIcon(CupertinoIcons.add)).dx,
        greaterThan(
          tester.getCenter(find.byIcon(CupertinoIcons.arrow_up_arrow_down)).dx,
        ),
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(
      find.descendant(
        of: _adaptiveActions,
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sort Groups'), findsOneWidget);
    await tester.tap(find.text('Sort Groups'));
    await tester.pumpAndSettle();
    expect(find.text('Sort Groups'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    final safeArea = tester.widget<SliverSafeArea>(find.byType(SliverSafeArea));
    expect(safeArea.left, isTrue);
    expect(safeArea.top, isFalse);
    expect(safeArea.right, isTrue);
    expect(safeArea.bottom, isTrue);
    expect(
      find.ancestor(
        of: find.byType(AdaptiveSliverAppBar),
        matching: find.byType(SliverSafeArea),
      ),
      findsNothing,
    );
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
    expect(
      find.descendant(
        of: _adaptiveActions,
        matching: find.byIcon(Icons.edit_outlined),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _adaptiveActions,
        matching: find.byIcon(Icons.select_all),
      ),
      findsNothing,
    );
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
    expect(
      find.descendant(
        of: _adaptiveActions,
        matching: find.byIcon(CupertinoIcons.pencil),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _adaptiveActions,
        matching: find.byIcon(CupertinoIcons.ellipsis),
      ),
      findsOneWidget,
    );
    for (final icon in [CupertinoIcons.pencil, CupertinoIcons.ellipsis]) {
      final button = find
          .ancestor(
            of: find.descendant(
              of: _adaptiveActions,
              matching: find.byIcon(icon),
            ),
            matching: find.byType(CupertinoButton),
          )
          .first;
      expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
    }
  });
}
