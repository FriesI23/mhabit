// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoIcons,
        CupertinoMenuDivider,
        CupertinoMenuItem,
        CupertinoNavigationBar,
        CupertinoPopupSurface,
        CupertinoSearchTextField,
        CupertinoSliverNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_stat.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

Widget _searchBarHost(
  HabitSummaryViewModel vm, {
  TargetPlatform platform = TargetPlatform.android,
  VoidCallback? onInfoButtonPressed,
  VoidCallback? onMenuButtonPressed,
  VoidCallback? onSelectButtonPressed,
}) {
  final searchBar = switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => SliverSearchTopAppBar.apple(
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
      onSelectButtonPressed: onSelectButtonPressed,
    ),
    _ => SliverSearchTopAppBar.material(
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
      onSelectButtonPressed: onSelectButtonPressed,
    ),
  };
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp(
      theme: ThemeData(platform: platform),
      restorationScopeId: 'app',
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: Scaffold(body: CustomScrollView(slivers: [searchBar])),
    ),
  );
}

Widget _viewBarHost() => const MaterialApp(
  localizationsDelegates: L10n.localizationsDelegates,
  supportedLocales: L10n.supportedLocales,
  home: Scaffold(body: CustomScrollView(slivers: [SliverViewTopAppBar()])),
);

final class _TestHabitSummaryViewModel extends HabitSummaryViewModel {
  @override
  Future<void> resortData({bool listen = true}) async {
    if (listen) notifyListeners();
  }
}

final class _SelectionHabitSummaryViewModel extends HabitSummaryViewModel {
  _SelectionHabitSummaryViewModel(this.stat);

  final HabitSummarySelectedStatistic stat;

  @override
  HabitSummarySelectedStatistic get selectStatistic => stat;
}

void main() {
  testWidgets('selection app bar stays Material on iOS', (tester) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const CustomScrollView(slivers: [SliverEditTopAppBar()]),
        ),
      ),
    );

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
  });

  testWidgets('Material selection renderer builds the Material branch', (
    tester,
  ) async {
    void onEdit() {}
    void onSelectAll() {}
    void onExport(BuildContext context) {}

    final vm = _SelectionHabitSummaryViewModel(
      HabitSummarySelectedStatistic(activated: 1),
    );
    final experimental = AppExperimentalFeatureViewModel();
    addTearDown(vm.dispose);
    addTearDown(experimental.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HabitSummaryViewModel>.value(value: vm),
          ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
            value: experimental,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: CustomScrollView(
            slivers: [
              MaterialSliverSelectAppBar(
                onEdit: onEdit,
                onSelectAll: onSelectAll,
                onExport: onExport,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoSliverSelectAppBar), findsNothing);
    final action = tester.widget<SliverEditTopAppBarAction>(
      find.byType(SliverEditTopAppBarAction),
    );
    expect(action.onEdit, same(onEdit));
    expect(action.onSelectAll, same(onSelectAll));
    expect(action.onExportAll, same(onExport));
  });

  testWidgets('Apple selection renderer fixes Select All and Done', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _SelectionHabitSummaryViewModel(
      HabitSummarySelectedStatistic(activated: 1, archived: 1),
    );
    final experimental = AppExperimentalFeatureViewModel();
    BuildContext? exportContext;
    addTearDown(vm.dispose);
    addTearDown(experimental.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HabitSummaryViewModel>.value(value: vm),
          ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
            value: experimental,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: CustomScrollView(
            slivers: [
              AppleSliverSelectAppBar(
                onDone: () {},
                onSelectAll: () {},
                onExport: (context) => exportContext = context,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoSliverSelectAppBar), findsOneWidget);
    expect(find.text('Selected 2'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);
    expect(find.byKey(const ValueKey('cupertino-select-done')), findsOneWidget);
    final appBar = tester.widget<CupertinoSliverSelectAppBar>(
      find.byType(CupertinoSliverSelectAppBar),
    );
    appBar.actions
        .firstWhere((action) => action.id == 'habit-export')
        .onPressed!();
    expect(exportContext, isNotNull);
    expect(exportContext!.mounted, isTrue);
  });

  test('Apple selection descriptors keep order and state semantics', () {
    final actions = buildAppleSelectActions(
      l10n: null,
      stat: HabitSummarySelectedStatistic(activated: 1, archived: 1),
      grouping: true,
      hasSelection: true,
      onExport: () {},
      onUnarchive: () {},
      onArchive: () {},
      onDelete: () {},
      onGroupModify: () {},
      onStatusModify: () {},
      onEdit: () {},
      onClone: () {},
    );

    expect(actions.map((action) => action.id), [
      'habit-edit',
      'habit-export',
      'habit-unarchive',
      'habit-archive',
      'habit-delete',
      'habit-group-modify',
      'habit-status-modify',
      'habit-clone',
    ]);
    expect(actions.every((action) => action.enabled), isTrue);
    expect(
      actions
          .where((action) => action.overflowBelowLarge)
          .map((action) => action.id),
      ['habit-group-modify', 'habit-clone'],
    );
    final status = actions.firstWhere(
      (action) => action.id == 'habit-status-modify',
    );
    expect(status.retentionPriority, 1000);
    expect(status.presentation, CupertinoSelectActionPresentation.iconAndLabel);
    expect(
      actions
          .where(
            (action) =>
                action.presentation ==
                CupertinoSelectActionPresentation.iconOnly,
          )
          .map((action) => action.id),
      [
        'habit-edit',
        'habit-export',
        'habit-unarchive',
        'habit-archive',
        'habit-delete',
      ],
    );

    final empty = buildAppleSelectActions(
      l10n: null,
      stat: HabitSummarySelectedStatistic(),
      grouping: true,
      hasSelection: false,
    );
    expect(
      empty
          .where((action) => action.visible)
          .every((action) => !action.enabled),
      isTrue,
    );
    expect(
      empty.firstWhere((action) => action.id == 'habit-edit').visible,
      isFalse,
    );
    expect(
      empty.firstWhere((action) => action.id == 'habit-clone').visible,
      isFalse,
    );
  });

  test('Apple selection descriptors isolate active and archived commands', () {
    void callback() {}

    List<CupertinoSelectAction> build(HabitSummarySelectedStatistic stat) =>
        buildAppleSelectActions(
          l10n: null,
          stat: stat,
          grouping: true,
          hasSelection: stat.selected > 0,
          onExport: callback,
          onUnarchive: callback,
          onArchive: callback,
          onDelete: callback,
          onGroupModify: callback,
          onStatusModify: callback,
          onEdit: callback,
          onClone: callback,
        );

    final activeOnly = build(HabitSummarySelectedStatistic(activated: 1));
    expect(
      activeOnly.firstWhere((action) => action.id == 'habit-archive').visible,
      isTrue,
    );
    expect(
      activeOnly.firstWhere((action) => action.id == 'habit-unarchive').visible,
      isFalse,
    );
    expect(
      activeOnly.firstWhere((action) => action.id == 'habit-edit').visible,
      isTrue,
    );
    expect(
      activeOnly.firstWhere((action) => action.id == 'habit-clone').visible,
      isTrue,
    );

    final archivedOnly = build(HabitSummarySelectedStatistic(archived: 2));
    expect(
      archivedOnly.firstWhere((action) => action.id == 'habit-archive').visible,
      isFalse,
    );
    expect(
      archivedOnly
          .firstWhere((action) => action.id == 'habit-unarchive')
          .visible,
      isTrue,
    );
    expect(
      archivedOnly.firstWhere((action) => action.id == 'habit-edit').visible,
      isFalse,
    );
    expect(
      archivedOnly.firstWhere((action) => action.id == 'habit-clone').visible,
      isFalse,
    );
  });

  testWidgets('Apple Search Select enters edit mode without preselection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      _searchBarHost(
        vm,
        platform: TargetPlatform.iOS,
        onSelectButtonPressed: vm.switchToEditMode,
      ),
    );

    expect(find.widgetWithText(CupertinoButton, 'Select'), findsOneWidget);
    final selectLabel = tester.widget<Text>(find.text('Select'));
    expect(selectLabel.maxLines, 1);
    expect(selectLabel.softWrap, isFalse);
    await tester.tap(find.widgetWithText(CupertinoButton, 'Select'));
    await tester.pump();
    expect(vm.isInEditMode, isTrue);
    expect(vm.selectedHabitsCount, 0);
  });

  testWidgets('Apple view app bar exposes Select without Search', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: CustomScrollView(
          slivers: [AppleSliverViewTopAppBar(onSelect: () => selected = true)],
        ),
      ),
    );

    final select = find.widgetWithText(CupertinoButton, 'Select');
    expect(select, findsOneWidget);
    await tester.tap(select);
    expect(selected, isTrue);
  });

  testWidgets('search and view app bars share the app toolbar extent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);

    await tester.pumpWidget(_searchBarHost(vm));
    var appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.toolbarHeight, AppAdaptiveStyle.materialToolbarHeight);
    expect(appBar.pinned, isTrue);
    expect(appBar.primary, isTrue);
    expect(find.byType(SearchBar), findsNothing);
    expect(find.byKey(const ValueKey('activate-search')), findsOneWidget);

    await tester.pumpWidget(_viewBarHost());
    appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.toolbarHeight, AppAdaptiveStyle.materialToolbarHeight);
  });

  testWidgets('search adapter synchronizes input and external VM exit', (
    tester,
  ) async {
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pumpAndSettle();
    expect(vm.isInSearchMode, isTrue);

    await tester.enterText(find.byType(SearchBar), 'alpha');
    await tester.pump();
    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(vm.searchOptions.keyword, 'alpha');
    expect(searchBar.controller?.text, 'alpha');
    expect(searchBar.focusNode?.hasFocus, isTrue);

    vm.exitSearchMode();
    await tester.pumpAndSettle();
    final updated = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(updated.controller?.text, isEmpty);
    expect(updated.focusNode?.hasFocus, isFalse);
  });

  testWidgets('tap outside exits only an empty changed search', (tester) async {
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'alpha');
    await tester.enterText(find.byType(SearchBar), '');
    await tester.pump();
    expect(vm.isInSearchMode, isTrue);

    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    searchBar.onTapOutside!(const PointerDownEvent());
    await tester.pump();
    expect(vm.isInSearchMode, isFalse);
  });

  testWidgets('filter-only search expands the compact search bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    expect(find.byType(SearchBar), findsNothing);
    vm.onSearchOngoingChanged(true);
    await tester.pumpAndSettle();

    expect(vm.isInSearchMode, isTrue);
    expect(vm.searchOptions.keyword, isEmpty);
    expect(vm.searchOptions.activated, isTrue);
    expect(find.byType(SearchBar), findsOneWidget);
  });

  testWidgets('breakpoint rebuild preserves controller, focus and filters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'kept');
    vm.onSearchOngoingChanged(true);
    await tester.pump();
    final before = tester.widget<SearchBar>(find.byType(SearchBar));

    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    final after = tester.widget<SearchBar>(find.byType(SearchBar));

    expect(after.controller, same(before.controller));
    expect(after.focusNode, same(before.focusNode));
    expect(after.controller?.text, 'kept');
    expect(after.focusNode?.hasFocus, isTrue);
    expect(vm.searchOptions.activated, isTrue);
  });

  testWidgets('restoration keeps controller and VM keyword consistent', (
    tester,
  ) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));
    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'restored');
    await tester.pump();

    final restorationData = await tester.getRestorationData();
    vm.exitSearchMode(listen: false);
    await tester.restoreFrom(restorationData);
    await tester.pump();

    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(searchBar.controller?.text, 'restored');
    expect(vm.searchOptions.keyword, 'restored');
  });

  testWidgets('Apple toolbar search activates and keeps the existing filter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.iOS));

    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(
      tester
          .widget<SliverPersistentHeader>(find.byType(SliverPersistentHeader))
          .pinned,
      isTrue,
    );
    expect(find.byType(SearchBar), findsNothing);
    expect(
      find.byKey(const ValueKey('activate-cupertino-search')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(vm.isInSearchMode, isFalse);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    await tester.enterText(find.byType(CupertinoSearchTextField), 'alpha');
    vm.onSearchOngoingChanged(true);
    await tester.pump();

    expect(vm.isInSearchMode, isTrue);
    expect(vm.searchOptions.keyword, 'alpha');
    expect(vm.searchOptions.activated, isTrue);
    expect(
      tester
          .widget<CupertinoSearchTextField>(
            find.byType(CupertinoSearchTextField),
          )
          .focusNode
          ?.hasFocus,
      isTrue,
    );

    await tester.tap(
      find.byKey(const ValueKey('clear-cupertino-search')).hitTestable(),
    );
    await tester.pump();
    expect(vm.searchOptions.keyword, isEmpty);
    expect(vm.searchOptions.activated, isTrue);
    expect(vm.isInSearchMode, isTrue);
  });

  testWidgets('Apple has no Cancel and external exit clears search state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.macOS));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    await tester.enterText(find.byType(CupertinoSearchTextField), 'alpha');
    vm.onSearchOngoingChanged(true);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('dismiss-cupertino-search')),
      findsNothing,
    );
    vm.exitSearchMode();
    await tester.pumpAndSettle();

    expect(vm.isInSearchMode, isFalse);
    expect(vm.searchOptions.isEmpty, isTrue);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    expect(find.byKey(const ValueKey('cupertino-search-title')), findsOne);

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(
      tester
          .widget<CupertinoSearchTextField>(
            find.byType(CupertinoSearchTextField),
          )
          .focusNode
          ?.hasFocus,
      isTrue,
    );
  });

  testWidgets('Apple promotes filter actions into adaptive actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(180, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.iOS));

    expect(find.byType(SearchFilterIcon), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchFilterBottomSheet), findsNothing);
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(find.text('Select'), findsOneWidget);
    expect(find.text('Show Filters'), findsOneWidget);
    expect(find.text('By Status'), findsNothing);
    expect(find.text('Habit Type'), findsNothing);

    await tester.tap(find.text('Show Filters'));
    await tester.pumpAndSettle();
    expect(find.text('By Status'), findsOneWidget);
    expect(find.text('Habit Type'), findsOneWidget);
    expect(find.text('Clear Filters'), findsNothing);
    expect(find.byType(CupertinoMenuDivider), findsNothing);
    expect(find.byIcon(CupertinoIcons.check_mark_circled), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.square_grid_2x2), findsOneWidget);

    await tester.tap(find.text('By Status'));
    await tester.pumpAndSettle();
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.play_circle), findsOneWidget);

    await tester.tap(find.text('Ongoing'));
    await tester.pumpAndSettle();
    expect(vm.searchOptions.activated, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
      findsOneWidget,
    );
    await tester.tap(find.text('Show Filters'));
    await tester.pumpAndSettle();
    final selectedStatusItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'By Status'),
    );
    expect((selectedStatusItem.subtitle! as Text).data, 'Ongoing');
    expect(find.text('Clear Filters'), findsOneWidget);
    expect(find.byType(CupertinoMenuDivider), findsOneWidget);

    await tester.tap(find.text('Habit Type'));
    await tester.pumpAndSettle();
    expect(find.text('Positive'), findsOneWidget);
    expect(find.text('Negative'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.plus_circle), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.minus_circle), findsOneWidget);

    await tester.tap(find.text('Negative'));
    await tester.pumpAndSettle();
    expect(vm.searchOptions.types, contains(HabitType.negative));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(tester.takeException(), isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Filters'));
    await tester.pumpAndSettle();
    final restoredStatusItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'By Status'),
    );
    final typeItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'Habit Type'),
    );
    expect((restoredStatusItem.subtitle! as Text).data, 'Ongoing');
    expect((typeItem.subtitle! as Text).data, 'Negative');
    expect(find.text('Clear Filters'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clear_circled_solid), findsOneWidget);
    expect(find.byType(CupertinoMenuDivider), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();
    expect(vm.searchOptions.isFilterEmpty, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Clear Filters'), findsNothing);
    expect(find.byIcon(CupertinoIcons.clear_circled_solid), findsNothing);
    expect(find.byType(CupertinoMenuDivider), findsNothing);
  });

  testWidgets('Apple clear filters preserves the search keyword', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel()
      ..onSeachKeywordChanged('kept')
      ..onSearchCompletedChanged(true);
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.macOS));

    await tester.tap(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
    );
    await tester.pumpAndSettle();
    expect(find.text('Clear Filters'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();
    expect(vm.searchOptions.keyword, 'kept');
    expect(vm.searchOptions.isFilterEmpty, isTrue);
  });

  testWidgets('macOS large exposes promoted filter actions directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.macOS));

    expect(find.byType(SearchFilterIcon), findsNothing);
    await tester.tap(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchFilterBottomSheet), findsNothing);
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(find.text('By Status'), findsOneWidget);
    expect(find.text('Habit Type'), findsOneWidget);
    expect(find.byType(CupertinoMenuDivider), findsNothing);

    await tester.tap(find.text('Habit Type'));
    await tester.pumpAndSettle();
    expect(find.text('Positive'), findsOneWidget);
    expect(find.text('Negative'), findsOneWidget);
  });

  testWidgets('Apple filter subtitles summarize selections in menu order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel()
      ..onSearchOngoingChanged(true)
      ..onSearchCompletedChanged(true)
      ..onSearchHabitTypeChanged(HabitType.normal, true)
      ..onSearchHabitTypeChanged(HabitType.negative, true);
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.macOS));

    await tester.tap(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
    );
    await tester.pumpAndSettle();

    final statusItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'By Status'),
    );
    final typeItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'Habit Type'),
    );
    expect((statusItem.subtitle! as Text).data, 'Ongoing, Completed');
    expect((typeItem.subtitle! as Text).data, 'Positive, Negative');
    expect(find.text('Clear Filters'), findsOneWidget);
    expect(find.byType(CupertinoMenuDivider), findsOneWidget);
  });

  testWidgets('Apple preserves title while lower-priority filters fold', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(308, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        platform: TargetPlatform.iOS,
        onInfoButtonPressed: () {},
        onMenuButtonPressed: () {},
      ),
    );

    expect(find.byType(SearchFilterIcon), findsNothing);
    expect(find.byIcon(CupertinoIcons.play_circle), findsNothing);
    expect(find.byIcon(CupertinoIcons.check_mark_circled), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('cupertino-search-title')))
          .width,
      greaterThanOrEqualTo(96),
    );
    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(find.text('Show Filters'), findsOneWidget);
  });

  testWidgets('Apple breakpoint rebuild preserves search state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.iOS));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoSearchTextField), 'kept');
    vm.onSearchOngoingChanged(true);
    await tester.pump();
    final before = tester.widget<CupertinoSearchTextField>(
      find.byType(CupertinoSearchTextField),
    );

    for (final size in const [
      Size(800, 700),
      Size(1000, 700),
      Size(500, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pump();
      final after = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      expect(after.controller, same(before.controller));
      expect(after.focusNode, same(before.focusNode));
      expect(after.controller?.text, 'kept');
      expect(after.focusNode?.hasFocus, isTrue);
      expect(vm.searchOptions.activated, isTrue);
    }
  });

  testWidgets('Apple restoration keeps controller and VM keyword consistent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.iOS));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoSearchTextField), 'restored');
    await tester.pump();

    final restorationData = await tester.getRestorationData();
    vm.exitSearchMode(listen: false);
    await tester.restoreFrom(restorationData);
    await tester.pump();

    final searchField = tester.widget<CupertinoSearchTextField>(
      find.byType(CupertinoSearchTextField),
    );
    expect(searchField.controller?.text, 'restored');
    expect(vm.searchOptions.keyword, 'restored');
  });
}
