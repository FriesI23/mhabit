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

import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoButtonSize,
        CupertinoIcons,
        CupertinoMenuDivider,
        CupertinoMenuItem,
        CupertinoNavigationBar,
        CupertinoPopupSurface,
        CupertinoSearchTextField,
        CupertinoSliverNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_display.dart';
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
  VoidCallback? onOpenSettingsPressed,
  VoidCallback? onSelectButtonPressed,
  bool? showSelectAction,
  bool compact = false,
  Locale? locale,
  HabitDisplayConfig config = const HabitDisplayConfig(),
  HabitDisplayOptionsCallbacks callbacks = const HabitDisplayOptionsCallbacks(),
}) {
  final searchBar = switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => SliverSearchTopAppBar.apple(
      onInfoButtonPressed: onInfoButtonPressed,
      onOpenSettingsPressed: onOpenSettingsPressed,
      onSelectButtonPressed: onSelectButtonPressed,
      showSelectAction: showSelectAction,
      config: config,
      callbacks: callbacks,
    ),
    _ => SliverSearchTopAppBar.material(
      onInfoButtonPressed: onInfoButtonPressed,
      onOpenSettingsPressed: onOpenSettingsPressed,
      onSelectButtonPressed: onSelectButtonPressed,
      showSelectAction: showSelectAction,
      config: config,
      callbacks: callbacks,
    ),
  };
  return ChangeNotifierProvider.value(
    value: vm,
    child: MaterialApp(
      theme: ThemeData(platform: platform),
      locale: locale,
      restorationScopeId: 'app',
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: AdaptiveNavScope(
        form: compact
            ? NavigationShellForm.compact
            : NavigationShellForm.expandedSide,
        barHeight: compact ? 80 : 0,
        navHeight: compact ? 80 : 0,
        child: Scaffold(body: CustomScrollView(slivers: [searchBar])),
      ),
    ),
  );
}

Widget _viewBarHost({
  TargetPlatform platform = TargetPlatform.android,
  Locale? locale,
  bool? showSelectAction,
  VoidCallback? onInfo,
  VoidCallback? onOpenSettings,
  VoidCallback? onSelect,
  bool compact = false,
  HabitDisplayConfig config = const HabitDisplayConfig(),
  HabitDisplayOptionsCallbacks callbacks = const HabitDisplayOptionsCallbacks(),
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  locale: locale,
  localizationsDelegates: L10n.localizationsDelegates,
  supportedLocales: L10n.supportedLocales,
  home: AdaptiveNavScope(
    form: compact
        ? NavigationShellForm.compact
        : NavigationShellForm.expandedSide,
    barHeight: compact ? 80 : 0,
    navHeight: compact ? 80 : 0,
    child: Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverViewTopAppBar(
            showSelectAction: showSelectAction,
            config: HabitDisplayViewAppBarConfig(
              onInfo: onInfo,
              onOpenSettings: onOpenSettings,
              onSelect: onSelect,
              config: config,
              callbacks: callbacks,
            ),
          ),
        ],
      ),
    ),
  ),
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
  Finder adaptiveActions() => find.byWidgetPredicate(
    (widget) => widget is AdaptiveAppBarActions,
    description: 'AdaptiveAppBarActions with any payload type',
  );

  Iterable<Object?> actionPayloads(WidgetTester tester) => tester
      .widget<AdaptiveAppBarActions>(adaptiveActions())
      .collection
      .roots
      .map((action) => action.payload);

  const localizedActionLabels =
      <(Locale, String, String, String, String, String)>[
        (
          Locale('en'),
          'Display Filter',
          'Statistics',
          'In Progress',
          'Archived',
          'Completed',
        ),
        (Locale('zh'), '显示筛选', '统计', '进行中', '已归档', '已完成'),
        (
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          '顯示篩選條件',
          '統計',
          '進行中',
          '已封存',
          '已完成',
        ),
      ];

  for (final entry in localizedActionLabels) {
    testWidgets('display actions localize for ${entry.$1}', (tester) async {
      await tester.pumpWidget(
        _viewBarHost(
          locale: entry.$1,
          onInfo: () {},
          callbacks: HabitDisplayOptionsCallbacks(
            onDisplayFilterChanged: (_) {},
          ),
        ),
      );

      final roots = tester
          .widget<AdaptiveAppBarActions>(adaptiveActions())
          .collection
          .roots;
      expect(
        roots
            .firstWhere((item) => item.id == habitDisplayFilterActionId)
            .metadata
            .label,
        entry.$2,
      );
      expect(
        roots
            .firstWhere((item) => item.id.value == 'habits.view.statistics')
            .metadata
            .label,
        entry.$3,
      );
      final l10n = L10n.of(tester.element(adaptiveActions()))!;
      expect(l10n.habitDisplay_displayFilter_inProgress, entry.$4);
      expect(l10n.habitDisplay_displayFilter_archived, entry.$5);
      expect(l10n.habitDisplay_displayFilter_completed, entry.$6);
    });

    testWidgets('search actions localize for ${entry.$1}', (tester) async {
      final vm = HabitSummaryViewModel();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        _searchBarHost(
          vm,
          locale: entry.$1,
          onInfoButtonPressed: () {},
          callbacks: HabitDisplayOptionsCallbacks(
            onDisplayFilterChanged: (_) {},
          ),
        ),
      );

      final roots = tester
          .widget<AdaptiveAppBarActions>(adaptiveActions())
          .collection
          .roots;
      expect(
        roots
            .firstWhere((item) => item.id == habitDisplayFilterActionId)
            .metadata
            .label,
        entry.$2,
      );
      expect(
        roots
            .firstWhere((item) => item.id.value == 'habits.search.statistics')
            .metadata
            .label,
        entry.$3,
      );
    });
  }

  testWidgets('display options preserve responsive action contracts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _viewBarHost(
        onInfo: () {},
        config: const HabitDisplayConfig(groupingVisible: true),
        callbacks: HabitDisplayOptionsCallbacks(
          onSortTypeSelected: (_) {},
          onSortDirectionToggled: () {},
          onGroupTypeSelected: (_) {},
          onGroupDirectionToggled: () {},
          onDisplayFilterChanged: (_) {},
          onThemeToggled: () {},
        ),
      ),
    );
    var actions = tester.widget<AdaptiveAppBarActions>(adaptiveActions());
    var collection = actions.collection;
    expect(actions.primaryCapacity, 144);
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplaySortActionId)
          .payload,
      isNull,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplaySortActionId)
          .children,
      isNotEmpty,
    );
    for (final id in [
      habitDisplaySortActionId,
      habitDisplayGroupActionId,
      habitDisplayFilterActionId,
    ]) {
      final action = collection.roots.firstWhere((item) => item.id == id);
      expect(action.hasMenu, isTrue);
      expect(action.payload, isNull);
    }
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplaySortActionId)
          .placementPolicy
          .placement,
      ActionPlacement.automatic,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayFilterActionId)
          .placementPolicy
          .placement,
      ActionPlacement.automatic,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayGroupActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id.value == 'habits.view.statistics')
          .placementPolicy
          .placement,
      ActionPlacement.automatic,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayThemeActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );

    tester.view.physicalSize = const Size(700, 800);
    await tester.pumpAndSettle();
    actions = tester.widget<AdaptiveAppBarActions>(adaptiveActions());
    expect(actions.maxPrimaryActions, 2);
    expect(actions.primaryCapacity, 144);

    tester.view.physicalSize = const Size(390, 800);
    await tester.pumpAndSettle();
    actions = tester.widget<AdaptiveAppBarActions>(adaptiveActions());
    collection = actions.collection;
    expect(actions.maxPrimaryActions, 2);
    expect(actions.primaryCapacity, 144);
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplaySortActionId)
          .children,
      isNotEmpty,
    );
    for (final id in [habitDisplaySortActionId, habitDisplayFilterActionId]) {
      expect(
        collection.roots
            .firstWhere((a) => a.id == id)
            .placementPolicy
            .placement,
        ActionPlacement.automatic,
      );
    }
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayGroupActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );
  });

  testWidgets('Apple pins Filter above Select and keeps Settings before it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _viewBarHost(
        platform: TargetPlatform.iOS,
        compact: true,
        showSelectAction: true,
        onSelect: () {},
        onOpenSettings: () {},
        callbacks: HabitDisplayOptionsCallbacks(onDisplayFilterChanged: (_) {}),
      ),
    );

    final viewRoots = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    expect(
      viewRoots
          .map((action) => action.id.value)
          .toList()
          .sublist(viewRoots.length - 2),
      ['habits.view.open-settings', habitDisplayFilterActionId.value],
    );
    expect(
      viewRoots
          .singleWhere(
            (action) => action.payload is HabitDisplayViewSelectAction,
          )
          .placementPolicy
          .automaticPreference
          ?.retentionPriority,
      PrimaryRetentionPriority.normal,
    );
    expect(
      viewRoots
          .singleWhere((action) => action.id == habitDisplayFilterActionId)
          .placementPolicy
          .placement,
      ActionPlacement.pinned,
    );

    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        platform: TargetPlatform.iOS,
        compact: true,
        showSelectAction: true,
        onSelectButtonPressed: () {},
        onOpenSettingsPressed: () {},
      ),
    );

    final searchRoots = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    expect(
      searchRoots
          .map((action) => action.id.value)
          .toList()
          .sublist(searchRoots.length - 2),
      ['habits.search.open-settings', habitDisplaySearchFilterActionId.value],
    );
    expect(
      searchRoots
          .singleWhere(
            (action) => action.payload is HabitDisplaySearchSelectAction,
          )
          .placementPolicy
          .automaticPreference
          ?.retentionPriority,
      PrimaryRetentionPriority.normal,
    );
    expect(
      searchRoots
          .singleWhere(
            (action) => action.id == habitDisplaySearchFilterActionId,
          )
          .placementPolicy
          .placement,
      ActionPlacement.pinned,
    );
  });

  testWidgets('Material keeps Settings as the final action', (tester) async {
    await tester.pumpWidget(
      _viewBarHost(
        platform: TargetPlatform.windows,
        compact: true,
        onOpenSettings: () {},
        callbacks: HabitDisplayOptionsCallbacks(onDisplayFilterChanged: (_) {}),
      ),
    );
    final viewRoots = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    expect(viewRoots.last.id.value, 'habits.view.open-settings');

    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        platform: TargetPlatform.windows,
        compact: true,
        onOpenSettingsPressed: () {},
      ),
    );
    final searchRoots = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    expect(searchRoots.last.id.value, 'habits.search.open-settings');
  });

  testWidgets('search display options are overflow-only and grouping gated', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        config: const HabitDisplayConfig(groupingVisible: false),
        callbacks: HabitDisplayOptionsCallbacks(
          onSortTypeSelected: (_) {},
          onGroupTypeSelected: (_) {},
          onDisplayFilterChanged: (_) {},
        ),
      ),
    );
    final roots = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    expect(roots.any((a) => a.id == habitDisplayGroupActionId), isFalse);
    expect(
      roots
          .firstWhere((a) => a.id == habitDisplaySortActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );
    expect(
      roots
          .firstWhere((a) => a.id == habitDisplayFilterActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );

    await tester.pumpWidget(
      _searchBarHost(
        vm,
        config: const HabitDisplayConfig(groupingVisible: true),
        callbacks: HabitDisplayOptionsCallbacks(
          onSortTypeSelected: (_) {},
          onGroupTypeSelected: (_) {},
          onDisplayFilterChanged: (_) {},
          onThemeToggled: () {},
        ),
      ),
    );
    var collection = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection;
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayGroupActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );

    tester.view.physicalSize = const Size(700, 800);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialSliverSearchBar>(find.byType(MaterialSliverSearchBar))
          .preferredActionCapacity,
      144,
    );
    expect(
      tester.widget<AdaptiveAppBarActions>(adaptiveActions()).maxPrimaryActions,
      2,
    );

    tester.view.physicalSize = const Size(900, 800);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialSliverSearchBar>(find.byType(MaterialSliverSearchBar))
          .preferredActionCapacity,
      144,
    );
    expect(
      tester.widget<AdaptiveAppBarActions>(adaptiveActions()).maxPrimaryActions,
      2,
    );
    collection = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection;
    for (final id in [habitDisplaySortActionId, habitDisplayFilterActionId]) {
      expect(
        collection.roots
            .firstWhere((a) => a.id == id)
            .placementPolicy
            .placement,
        ActionPlacement.automatic,
      );
    }
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayGroupActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );
    expect(
      collection.roots
          .firstWhere((a) => a.id == habitDisplayThemeActionId)
          .placementPolicy
          .placement,
      ActionPlacement.overflowOnly,
    );
  });

  testWidgets('display filter rejects disabling the final enabled item', (
    tester,
  ) async {
    const onlyInProgress = HabitsDisplayFilter(
      allowInProgressHabits: true,
      allowArchivedHabits: false,
      allowCompleteHabits: false,
    );
    await tester.pumpWidget(
      _viewBarHost(
        config: const HabitDisplayConfig(displayFilter: onlyInProgress),
        callbacks: HabitDisplayOptionsCallbacks(onDisplayFilterChanged: (_) {}),
      ),
    );
    final filterAction = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots
        .firstWhere((a) => a.id == habitDisplayFilterActionId);
    expect(filterAction.children, isEmpty);
    expect(
      const ToggleHabitDisplayFilter(
        HabitDisplayFilterTarget.inProgress,
      ).applyTo(onlyInProgress),
      isNull,
    );

    final allSelected = const ToggleHabitDisplayFilter(
      HabitDisplayFilterTarget.archived,
    ).applyTo(HabitsDisplayFilter.allTrue);
    expect(allSelected, isNotNull);
    expect(allSelected!.allowArchivedHabits, isFalse);
    expect(allSelected.allowInProgressHabits, isTrue);
    expect(allSelected.allowCompleteHabits, isTrue);
  });

  testWidgets('display filter uses status-list and checkmark visuals', (
    tester,
  ) async {
    const config = HabitDisplayConfig(
      groupingVisible: true,
      displayFilter: HabitsDisplayFilter(
        allowInProgressHabits: true,
        allowArchivedHabits: false,
        allowCompleteHabits: true,
      ),
    );
    await tester.pumpWidget(
      _viewBarHost(
        config: config,
        callbacks: HabitDisplayOptionsCallbacks(
          onGroupTypeSelected: (_) {},
          onDisplayFilterChanged: (_) {},
        ),
      ),
    );
    final appBarActions = tester
        .widget<AdaptiveAppBarActions<HabitDisplayViewAction>>(
          adaptiveActions(),
        );
    final context = tester.element(adaptiveActions());
    final filterAction = appBarActions.collection.roots.firstWhere(
      (action) => action.id == habitDisplayFilterActionId,
    );
    final groupAction = appBarActions.collection.roots.firstWhere(
      (action) => action.id == habitDisplayGroupActionId,
    );
    expect(
      (appBarActions.material!.iconBuilder!(context, filterAction) as Icon)
          .icon,
      Icons.checklist_rounded,
    );
    expect(
      (appBarActions.apple!.iconBuilder!(context, filterAction) as Icon).icon,
      CupertinoIcons.list_bullet,
    );
    expect(
      (appBarActions.material!.iconBuilder!(context, groupAction) as Icon).icon,
      Icons.folder_copy_outlined,
    );
    expect(
      (appBarActions.apple!.iconBuilder!(context, groupAction) as Icon).icon,
      CupertinoIcons.folder,
    );
  });

  testWidgets('Material display filter uses a persistent checkbox submenu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    HabitsDisplayFilter? changedFilter;

    await tester.pumpWidget(
      _viewBarHost(
        platform: TargetPlatform.windows,
        showSelectAction: true,
        onSelect: () {},
        onInfo: () {},
        config: const HabitDisplayConfig(
          displayFilter: HabitsDisplayFilter(
            allowInProgressHabits: false,
            allowArchivedHabits: false,
            allowCompleteHabits: true,
          ),
        ),
        callbacks: HabitDisplayOptionsCallbacks(
          onDisplayFilterChanged: (value) => changedFilter = value,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display Filter'));
    await tester.pumpAndSettle();

    final checkboxes = tester.widgetList<CheckboxMenuButton>(
      find.byType(CheckboxMenuButton),
    );
    expect(checkboxes, hasLength(3));
    expect(checkboxes.every((item) => !item.closeOnActivate), isTrue);
    expect(checkboxes.map((item) => item.value), [false, false, true]);
    expect(checkboxes.last.onChanged, isNull);

    await tester.tap(find.text('Archived'));
    await tester.pump();

    expect(
      changedFilter,
      const HabitsDisplayFilter(
        allowInProgressHabits: false,
        allowArchivedHabits: true,
        allowCompleteHabits: true,
      ),
    );
    expect(find.text('Archived'), findsOneWidget);
    expect(find.byType(CheckboxMenuButton), findsNWidgets(3));
  });

  testWidgets('Cupertino display filter uses a persistent checkmark submenu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    HabitsDisplayFilter? changedFilter;
    var currentFilter = const HabitsDisplayFilter(
      allowInProgressHabits: false,
      allowArchivedHabits: false,
      allowCompleteHabits: true,
    );

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setHostState) => MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: CustomScrollView(
            slivers: [
              AppleSliverViewTopAppBar(
                showSelectAction: true,
                config: HabitDisplayViewAppBarConfig(
                  onSelect: () {},
                  onInfo: () {},
                  config: HabitDisplayConfig(displayFilter: currentFilter),
                  callbacks: HabitDisplayOptionsCallbacks(
                    onDisplayFilterChanged: (value) {
                      changedFilter = value;
                      setHostState(() => currentFilter = value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final actions = tester.widget<AdaptiveAppBarActions>(adaptiveActions());
    final filterAction = actions.collection.roots.firstWhere(
      (action) => action.id == habitDisplayFilterActionId,
    );
    expect(filterAction.children, isEmpty);

    final filterIcon = find.byIcon(CupertinoIcons.list_bullet);
    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon);
    } else {
      await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display Filter'));
    }
    await tester.pumpAndSettle();

    final items = tester.widgetList<CupertinoMenuItem>(
      find.byType(CupertinoMenuItem),
    );
    expect(items, hasLength(3));
    expect(items.every((item) => !item.requestCloseOnActivate), isTrue);
    expect(items.last.onPressed, isNull);
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);

    await tester.tap(find.text('Archived'));
    await tester.pump();

    expect(
      changedFilter,
      const HabitsDisplayFilter(
        allowInProgressHabits: false,
        allowArchivedHabits: true,
        allowCompleteHabits: true,
      ),
    );
    expect(find.text('Archived'), findsOneWidget);
    expect(find.byType(CupertinoMenuItem), findsNWidgets(3));
    expect(find.byIcon(CupertinoIcons.check_mark), findsNWidgets(2));

    await tester.tap(find.text('Completed'));
    await tester.pump();

    final archivedItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'Archived'),
    );
    expect(archivedItem.onPressed, isNull);
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
  });

  testWidgets('Select entry defaults by platform and accepts an override', (
    tester,
  ) async {
    await tester.pumpWidget(
      _viewBarHost(platform: TargetPlatform.android, onSelect: () {}),
    );
    expect(
      actionPayloads(tester),
      isNot(contains(const HabitDisplayViewSelectAction())),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _viewBarHost(platform: TargetPlatform.windows, onSelect: () {}),
    );
    expect(
      actionPayloads(tester),
      contains(const HabitDisplayViewSelectAction()),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _viewBarHost(
        platform: TargetPlatform.android,
        showSelectAction: true,
        onSelect: () {},
      ),
    );
    expect(
      actionPayloads(tester),
      contains(const HabitDisplayViewSelectAction()),
    );

    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_searchBarHost(vm, onSelectButtonPressed: () {}));
    expect(
      tester
          .widget<AdaptiveAppBarActions>(adaptiveActions())
          .collection
          .roots
          .map((action) => action.id.value),
      isNot(contains('habits.search.select')),
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _searchBarHost(vm, showSelectAction: true, onSelectButtonPressed: () {}),
    );
    expect(
      tester
          .widget<AdaptiveAppBarActions>(adaptiveActions())
          .collection
          .roots
          .map((action) => action.id.value),
      contains('habits.search.select'),
    );
  });

  testWidgets('compact view app bar exposes direct Settings entry', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: AdaptiveNavScope(
          form: NavigationShellForm.compact,
          barHeight: 80,
          navHeight: 80,
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverViewTopAppBar(
                  config: HabitDisplayViewAppBarConfig(
                    onOpenSettings: () => opened = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final action = find.byKey(const ValueKey('open-settings-action'));
    expect(action, findsOneWidget);
    await tester.tap(action);
    expect(opened, isTrue);
    expect(adaptiveActions(), findsOneWidget);
  });

  testWidgets('compact search app bar exposes direct Settings entry', (
    tester,
  ) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    var opened = false;
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        compact: true,
        onOpenSettingsPressed: () => opened = true,
      ),
    );

    final action = find.byKey(const ValueKey('open-settings-action'));
    expect(action, findsOneWidget);
    await tester.tap(action);
    expect(opened, isTrue);
    expect(adaptiveActions(), findsOneWidget);
  });

  testWidgets('view and search statistics actions use defined metadata', (
    tester,
  ) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        locale: const Locale('zh'),
        onInfoButtonPressed: () {},
      ),
    );
    final searchActions = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    final searchSummary = searchActions.singleWhere(
      (action) => action.id.value == 'habits.search.statistics',
    );
    expect(searchSummary.metadata.label, '统计');
    expect(searchSummary.metadata.tooltip, isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverViewTopAppBar(
                config: HabitDisplayViewAppBarConfig(onInfo: () {}),
              ),
            ],
          ),
        ),
      ),
    );
    final viewActions = tester
        .widget<AdaptiveAppBarActions>(adaptiveActions())
        .collection
        .roots;
    final viewSummary = viewActions.singleWhere(
      (action) => action.id.value == 'habits.view.statistics',
    );
    expect(viewSummary.metadata.label, '统计');
    expect(viewSummary.metadata.tooltip, isNull);
  });

  testWidgets('Material keeps Select and Statistics in the two primary slots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final callbacks = HabitDisplayOptionsCallbacks(
      onSortTypeSelected: (_) {},
      onDisplayFilterChanged: (_) {},
      onThemeToggled: () {},
    );

    await tester.pumpWidget(
      _viewBarHost(
        platform: TargetPlatform.windows,
        showSelectAction: true,
        onSelect: () {},
        onInfo: () {},
        callbacks: callbacks,
      ),
    );

    expect(find.byIcon(Icons.select_all), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _searchBarHost(
        vm,
        platform: TargetPlatform.windows,
        showSelectAction: true,
        onSelectButtonPressed: () {},
        onInfoButtonPressed: () {},
        callbacks: callbacks,
      ),
    );

    expect(find.byIcon(Icons.select_all), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('Material selection renderer builds the Material branch', (
    tester,
  ) async {
    void onEdit() {}
    void onArchive() {}
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
                callbacks: HabitDisplaySelectAppBarCallbacks(
                  onEdit: onEdit,
                  onArchive: onArchive,
                  onSelectAll: onSelectAll,
                  onExport: onExport,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoSliverSelectAppBar), findsNothing);
    expect(adaptiveActions(), findsOneWidget);
    final action = tester.widget<AdaptiveAppBarActions>(adaptiveActions());
    expect(action.collection.roots.length, greaterThanOrEqualTo(3));
    final renderer = tester.widget<MaterialAdaptiveActions>(
      find.byType(MaterialAdaptiveActions<HabitDisplaySelectAction>),
    );
    expect(renderer.primaryCapacity, action.collection.roots.length * 48.0);
    expect(action.maxPrimaryActions, isNull);
    expect(find.byIcon(MdiIcons.selectAll), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(MdiIcons.export), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
  });

  testWidgets(
    'Material selection folds Select All and Export before common actions',
    (tester) async {
      tester.view.physicalSize = const Size(304, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
            theme: ThemeData(platform: TargetPlatform.windows),
            home: CustomScrollView(
              slivers: [
                MaterialSliverSelectAppBar(
                  callbacks: HabitDisplaySelectAppBarCallbacks(
                    onSelectAll: () {},
                    onEdit: () {},
                    onExport: (_) {},
                    onArchive: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      expect(find.byIcon(MdiIcons.selectAll), findsNothing);
      expect(find.byIcon(MdiIcons.export), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    },
  );

  testWidgets('narrow Material selection shrinks actions to one More slot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _SelectionHabitSummaryViewModel(
      HabitSummarySelectedStatistic(activated: 1, archived: 1),
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
          theme: ThemeData(platform: TargetPlatform.windows),
          home: CustomScrollView(
            slivers: [
              MaterialSliverSelectAppBar(
                callbacks: HabitDisplaySelectAppBarCallbacks(
                  onDone: () {},
                  onSelectAll: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final actions = tester.widget<MaterialAdaptiveActions>(
      find.byType(MaterialAdaptiveActions<HabitDisplaySelectAction>),
    );
    expect(actions.primaryCapacity, 48);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large Material selection promotes useful secondary actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
          theme: ThemeData(platform: TargetPlatform.windows),
          home: CustomScrollView(
            slivers: [
              MaterialSliverSelectAppBar(
                callbacks: HabitDisplaySelectAppBarCallbacks(
                  onEdit: () {},
                  onArchive: () {},
                  onGroupModify: () {},
                  onClone: () {},
                  onExport: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    expect(find.byIcon(MdiIcons.folderMove), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
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
                callbacks: HabitDisplaySelectAppBarCallbacks(
                  onDone: () {},
                  onSelectAll: () {},
                  onExport: (context) => exportContext = context,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final selectBar = find.byWidgetPredicate(
      (widget) => widget is CupertinoSliverSelectAppBar,
    );
    expect(selectBar, findsOneWidget);
    expect(find.text('Selected 2'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);
    expect(find.byKey(const ValueKey('cupertino-select-done')), findsOneWidget);
    final host = tester.widget<AdaptiveAppBarActions<HabitDisplaySelectAction>>(
      adaptiveActions(),
    );
    final exportAction = host.collection.roots.firstWhere(
      (action) => action.id.value == 'habits.select.export',
    );
    host.onInvoke(
      exportContext ?? tester.element(selectBar),
      exportAction.payload!,
    );
    expect(exportContext, isNotNull);
    expect(exportContext!.mounted, isTrue);
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

    final select = find.widgetWithText(CupertinoButton, 'Select');
    expect(select, findsOneWidget);
    final button = tester.widget<CupertinoButton>(select);
    expect(button.sizeStyle, CupertinoButtonSize.small);
    expect(button.padding, isNull);
    expect(button.minimumSize, isNull);
    final selectLabel = tester.widget<Text>(find.text('Select'));
    expect(selectLabel.maxLines, 1);
    expect(selectLabel.softWrap, isFalse);
    await tester.tap(select);
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
          slivers: [
            AppleSliverViewTopAppBar(
              config: HabitDisplayViewAppBarConfig(
                onSelect: () => selected = true,
              ),
            ),
          ],
        ),
      ),
    );

    final select = find.widgetWithText(CupertinoButton, 'Select');
    expect(select, findsOneWidget);
    final button = tester.widget<CupertinoButton>(select);
    expect(button.sizeStyle, CupertinoButtonSize.small);
    expect(button.padding, isNull);
    expect(button.minimumSize, isNull);
    await tester.tap(select);
    expect(selected, isTrue);
  });

  testWidgets('Apple habits Select keeps its localized intrinsic label width', (
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
        onSelectButtonPressed: () {},
      ),
    );
    var select = find.widgetWithText(CupertinoButton, 'Select');
    expect(select, findsOneWidget);
    expect(tester.getSize(select).width, greaterThan(44));
    expect(
      find.descendant(of: select, matching: find.byType(FittedBox)),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        locale: const Locale('fr'),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: CustomScrollView(
          slivers: [
            AppleSliverViewTopAppBar(
              config: HabitDisplayViewAppBarConfig(onSelect: () {}),
            ),
          ],
        ),
      ),
    );
    select = find.widgetWithText(CupertinoButton, 'Sélectionner');
    expect(select, findsOneWidget);
    expect(tester.getSize(select).width, greaterThan(44));
    expect(
      find.descendant(of: select, matching: find.byType(FittedBox)),
      findsNothing,
    );
    final label = tester.widget<Text>(find.text('Sélectionner'));
    expect(label.maxLines, 1);
    expect(label.softWrap, isFalse);
    expect(tester.takeException(), isNull);
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

    final expandedWidth = tester
        .getSize(find.byKey(const ValueKey('expandable-search-region')))
        .width;
    vm.exitSearchMode();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final collapsingWidth = tester
        .getSize(find.byKey(const ValueKey('expandable-search-region')))
        .width;
    expect(collapsingWidth, greaterThan(48));
    expect(collapsingWidth, lessThan(expandedWidth));
    await tester.pumpAndSettle();
    expect(find.byType(SearchBar), findsNothing);
    expect(tester.takeException(), isNull);
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
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm, platform: TargetPlatform.iOS));

    expect(find.byType(SearchFilterIcon), findsNothing);
    expect(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle),
      findsOneWidget,
    );
    await tester.tap(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchFilterBottomSheet), findsNothing);
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
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

    expect(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
      findsOneWidget,
    );
    await tester.tap(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
    );
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
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle_fill),
    );
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
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle),
    );
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

  testWidgets('Apple preserves title while lower-priority actions fold', (
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
      ),
    );

    expect(find.byType(SearchFilterIcon), findsNothing);
    expect(find.byIcon(CupertinoIcons.play_circle), findsNothing);
    expect(find.byIcon(CupertinoIcons.check_mark_circled), findsNothing);
    expect(
      find.byIcon(CupertinoIcons.line_horizontal_3_decrease_circle),
      findsOneWidget,
    );
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
    expect(find.text('Show Filters'), findsNothing);
    expect(find.text('Select'), findsOneWidget);
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
