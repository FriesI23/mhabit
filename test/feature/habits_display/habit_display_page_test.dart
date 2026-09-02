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

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoMenuItem,
        CupertinoNavigationBar,
        CupertinoPopupSurface,
        CupertinoSliverNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/pages/habits_display/navigation_chrome.dart';
import 'package:mhabit/pages/habits_display/page.dart';
import 'package:mhabit/pages/habits_display/page_habits.dart';
import 'package:mhabit/pages/habits_display/page_today.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';
import 'package:mhabit/providers/app_ui/app_compact_ui_switcher.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/app_ui/app_language.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/providers/app_ui/habit_op_config.dart';
import 'package:mhabit/providers/app_ui/habits_filter.dart';
import 'package:mhabit/providers/app_ui/habits_record_scroll_behavior.dart';
import 'package:mhabit/providers/app_ui/habits_sort.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/routes/helpers/habits_status_changer_helper.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliver_tools/sliver_tools.dart' show SliverAnimatedSwitcher;

import '../../support/stub/app_sync.dart';
import '../../support/stub/habits_display_access.dart';

void _ignoreHabitDBCell(HabitDBCell _) {}

class _TestHabitDisplayNavigationChrome
    implements HabitDisplayNavigationChrome {
  VoidCallback? _primaryAction;
  final contextualChromeSuppressed = ValueNotifier(false);

  void invokePrimaryAction() => _primaryAction?.call();

  void dispose() => contextualChromeSuppressed.dispose();

  @override
  void registerPrimaryAction(VoidCallback action) {
    _primaryAction = action;
  }

  @override
  void unregisterPrimaryAction(VoidCallback action) {
    if (identical(_primaryAction, action)) _primaryAction = null;
  }

  @override
  void setContextualChromeSuppressed(bool suppressed) {
    contextualChromeSuppressed.value = suppressed;
  }
}

final class _FailingHabitsDisplayAccess extends StubHabitsDisplayAccess {
  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async => throw StateError('load failed');
}

final class _PendingHabitsDisplayAccess extends StubHabitsDisplayAccess {
  final Completer<HabitSummaryDataCollection> _loadCompleter = Completer();

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) => _loadCompleter.future;

  void completeLoad() {
    if (_loadCompleter.isCompleted) return;
    _loadCompleter.complete(HabitSummaryDataCollection());
  }
}

final class _FakeAppSyncWorkflowAccess extends StubAppSyncWorkflowAccess {}

final class _RecordingNavigatorObserver extends NavigatorObserver {
  int habitCreatePushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == AppRoute.habitCreate.name) {
      habitCreatePushes += 1;
    }
  }
}

final class _FakeGroupManager extends GroupManager {
  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult([]);
}

final class _LoadedHabitsDisplayAccess extends StubHabitsDisplayAccess {
  final int habitCount;

  _LoadedHabitsDisplayAccess({this.habitCount = 1});

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final collection = initedCollection ?? HabitSummaryDataCollection();
    for (var i = 0; i < habitCount; i++) {
      collection.addHabit(_buildHabitSummaryData(i), forceAdd: true);
    }
    return collection;
  }
}

final class _TestAppCompactUISwitcherViewModel
    extends AppCompactUISwitcherViewModel {
  final bool useCompactUi;

  _TestAppCompactUISwitcherViewModel({required this.useCompactUi});

  @override
  bool get flag => useCompactUi;
}

HabitSummaryData _buildHabitSummaryData(int index) {
  final startDate = HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: index + 1,
    uuid: '11111111-1111-4111-8111-${(index + 1).toString().padLeft(12, '0')}',
    type: HabitType.normal,
    name: 'Geometry regression habit $index',
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: startDate,
    status: HabitStatus.activated,
    sortPostion: index + 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel(const []);
  await profile.init();
  return profile;
}

Future<void> _pumpTodayTabPage(
  WidgetTester tester, {
  required ProfileViewModel profile,
  required HabitsDisplayAccess access,
  required AppSyncWorkflowAccess sync,
  TargetPlatform platform = TargetPlatform.android,
  bool useAdaptiveShell = false,
}) async {
  final customDate = AppCustomDateYmdHmsConfigViewModel()
    ..updateProfile(profile);
  final firstDay = AppFirstDayViewModel()..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global());
  final theme = AppThemeViewModel()..updateProfile(profile);
  final vm = HabitsTodayViewModel()..attachAccess(access);

  addTearDown(() {
    vm.dispose();
    theme.dispose();
    developer.dispose();
    firstDay.dispose();
    customDate.dispose();
  });

  final page = useAdaptiveShell
      ? AdaptiveNavigationShell(
          selectedIndex: 1,
          destinations: const [
            AdaptiveNavigationDestination(
              label: 'Habits',
              icons: NavigationDestinationIcons(
                material: Icon(Icons.list),
                materialSelected: Icon(Icons.list),
                apple: Icon(Icons.list),
                appleSelected: Icon(Icons.list),
              ),
            ),
            AdaptiveNavigationDestination(
              label: 'Today',
              icons: NavigationDestinationIcons(
                material: Icon(Icons.calendar_today),
                materialSelected: Icon(Icons.calendar_today),
                apple: Icon(Icons.calendar_today),
                appleSelected: Icon(Icons.calendar_today),
              ),
            ),
          ],
          onDestinationSelected: (_) {},
          child: Builder(
            builder: (context) => Scaffold(
              body: TodayTabPage(
                bottomNavigationHeight: AdaptiveNavScope.of(context).navHeight,
              ),
            ),
          ),
        )
      : const Scaffold(body: TodayTabPage());

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
        ChangeNotifierProvider<HabitsTodayViewModel>.value(value: vm),
        ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
          value: customDate,
        ),
        ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
        ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
        ChangeNotifierProvider<AppThemeViewModel>.value(value: theme),
        ListenableProvider<AppSyncTriggerAccess>.value(value: sync),
        ListenableProvider<AppSyncStatusSource>.value(value: sync),
        ListenableProvider<AppSyncWorkflowAccess>.value(value: sync),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: page,
      ),
    ),
  );
}

Future<HabitSummaryViewModel> _pumpHabitsTabPage(
  WidgetTester tester, {
  required ProfileViewModel profile,
  required HabitsDisplayAccess access,
  required AppSyncWorkflowAccess sync,
  bool useCompactUi = false,
  bool useBranchPage = false,
  bool useAdaptiveShell = false,
  bool provideOuterHabitSummary = true,
  TargetPlatform platform = TargetPlatform.android,
  Widget Function(Widget home)? appBuilder,
}) async {
  final customDate = AppCustomDateYmdHmsConfigViewModel()
    ..updateProfile(profile);
  final firstDay = AppFirstDayViewModel()..updateProfile(profile);
  final compactUi = _TestAppCompactUISwitcherViewModel(
    useCompactUi: useCompactUi,
  )..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global());
  final experimental = AppExperimentalFeatureViewModel()
    ..updateProfile(profile);
  final language = AppLanguageViewModel()..updateProfile(profile);
  final theme = AppThemeViewModel()..updateProfile(profile);
  final scrollBehavior = HabitsRecordScrollBehaviorViewModel()
    ..updateProfile(profile);
  final recordOpConfig = HabitRecordOpConfigViewModel()..updateProfile(profile);
  final sort = HabitsSortViewModel()..updateProfile(profile);
  final filter = HabitsFilterViewModel()..updateProfile(profile);
  final appEvent = AppEventBus();
  final groupManager = _FakeGroupManager();
  final vm = HabitSummaryViewModel()
    ..attachAccess(access)
    ..attachGroupManager(groupManager);
  final navigationChrome = _TestHabitDisplayNavigationChrome();

  addTearDown(() {
    vm.dispose();
    navigationChrome.dispose();
    appEvent.dispose();
    filter.dispose();
    sort.dispose();
    recordOpConfig.dispose();
    scrollBehavior.dispose();
    theme.dispose();
    language.dispose();
    experimental.dispose();
    developer.dispose();
    compactUi.dispose();
    firstDay.dispose();
    customDate.dispose();
  });

  final home = useAdaptiveShell
      ? ListenableBuilder(
          listenable: navigationChrome.contextualChromeSuppressed,
          builder: (context, child) => AdaptiveNavigationShell(
            selectedIndex: 0,
            contextualChromeSuppressed:
                navigationChrome.contextualChromeSuppressed.value,
            applePrimaryAction:
                navigationChrome.contextualChromeSuppressed.value
                ? null
                : CupertinoNavigationPrimaryAction(
                    label: 'New Habit',
                    icon: const Icon(Icons.add),
                    onPressed: navigationChrome.invokePrimaryAction,
                  ),
            destinations: const [
              AdaptiveNavigationDestination(
                label: 'Habits',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.list),
                  materialSelected: Icon(Icons.list),
                  apple: Icon(Icons.list),
                  appleSelected: Icon(Icons.list),
                ),
              ),
              AdaptiveNavigationDestination(
                label: 'Today',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.calendar_today),
                  materialSelected: Icon(Icons.calendar_today),
                  apple: Icon(Icons.calendar_today),
                  appleSelected: Icon(Icons.calendar_today),
                ),
              ),
            ],
            onDestinationSelected: (_) {},
            child: const HabitsPage(),
          ),
        )
      : useBranchPage
      ? const AdaptiveNavScope(barHeight: 0, navHeight: 0, child: HabitsPage())
      : const Scaffold(body: HabitsTabPage(onHabitCreated: _ignoreHabitDBCell));
  final app =
      appBuilder?.call(home) ??
      MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: home,
      );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<HabitDisplayNavigationChrome>.value(value: navigationChrome),
        ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
        if (provideOuterHabitSummary)
          ChangeNotifierProvider<HabitSummaryViewModel>.value(value: vm),
        ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
          value: customDate,
        ),
        ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
        ChangeNotifierProvider<AppCompactUISwitcherViewModel>.value(
          value: compactUi,
        ),
        ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
        ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
          value: experimental,
        ),
        ChangeNotifierProvider<AppLanguageViewModel>.value(value: language),
        ChangeNotifierProvider<AppThemeViewModel>.value(value: theme),
        ChangeNotifierProvider<HabitsRecordScrollBehaviorViewModel>.value(
          value: scrollBehavior,
        ),
        ChangeNotifierProvider<HabitRecordOpConfigViewModel>.value(
          value: recordOpConfig,
        ),
        ChangeNotifierProvider<HabitsSortViewModel>.value(value: sort),
        ChangeNotifierProvider<HabitsFilterViewModel>.value(value: filter),
        ChangeNotifierProvider<AppEventBus>.value(value: appEvent),
        Provider<GroupManager>.value(value: groupManager),
        Provider<HabitsDisplayAccess>.value(value: access),
        ListenableProvider<AppSyncTriggerAccess>.value(value: sync),
        ListenableProvider<AppSyncStatusSource>.value(value: sync),
        ListenableProvider<AppSyncWorkflowAccess>.value(value: sync),
      ],
      child: ChangelogBanner(child: app),
    ),
  );
  if (!(useBranchPage || useAdaptiveShell)) return vm;
  return tester
      .element(find.byType(HabitsTabPage))
      .read<HabitSummaryViewModel>();
}

Future<void> _fastDirectDrag(
  WidgetTester tester,
  Finder finder, {
  required double direction,
}) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  await gesture.moveBy(
    Offset(0, 48 * direction),
    timeStamp: const Duration(milliseconds: 16),
  );
  await tester.pump();
  await gesture.moveBy(
    Offset(0, 96 * direction),
    timeStamp: const Duration(milliseconds: 32),
  );
  await gesture.cancel(timeStamp: const Duration(milliseconds: 48));
}

void main() {
  testWidgets('created habit updates the page-owned summary provider', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _PendingHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });
    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useBranchPage: true,
      provideOuterHabitSummary: false,
    );

    const uuid = '11111111-1111-4111-8111-999999999999';
    const created = HabitDBCell(
      id: 999,
      type: 1,
      createT: 100000,
      modifyT: 100000,
      uuid: uuid,
      status: 1,
      name: 'Created habit',
      desc: '',
      color: 1,
      dailyGoal: 1,
      dailyGoalUnit: 'times',
      freqType: 3,
      freqCustom: '[1, 1]',
      startDate: 20000,
      targetDays: 30,
      sortPosition: 999,
    );

    expect(
      () => tester
          .widget<HabitsTabPage>(find.byType(HabitsTabPage))
          .onHabitCreated(created),
      returnsNormally,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(vm.getHabit(uuid)?.name, 'Created habit');

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpWidget(const SizedBox.shrink());
    access.completeLoad();
    await tester.pump();
  });

  group('Display page load errors', () {
    testWidgets('TodayTabPage shows error placeholder on load error', (
      tester,
    ) async {
      final profile = await _loadProfile();
      final access = _FailingHabitsDisplayAccess();
      final sync = _FakeAppSyncWorkflowAccess();

      addTearDown(() {
        sync.dispose();
        profile.dispose();
      });

      await _pumpTodayTabPage(
        tester,
        profile: profile,
        access: access,
        sync: sync,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(NotFoundImage), findsOneWidget);
    });

    testWidgets('HabitsTabPage shows error placeholder on load error', (
      tester,
    ) async {
      final profile = await _loadProfile();
      final access = _FailingHabitsDisplayAccess();
      final sync = _FakeAppSyncWorkflowAccess();

      addTearDown(() {
        sync.dispose();
        profile.dispose();
      });

      await _pumpHabitsTabPage(
        tester,
        profile: profile,
        access: access,
        sync: sync,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(NotFoundImage), findsOneWidget);
    });
  });

  testWidgets('Today uses a Cupertino large title and adaptive icon button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpTodayTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      platform: TargetPlatform.iOS,
    );

    expect(find.byType(AppThemeSwitchButton), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppThemeSwitchButton),
        matching: find.byType(AdaptiveIconButton),
      ),
      findsOneWidget,
    );
    final todayBar = tester.widget<CupertinoSliverNavigationBar>(
      find.byType(CupertinoSliverNavigationBar),
    );
    expect(todayBar.largeTitle, isA<Text>());
    expect((todayBar.largeTitle! as Text).data, 'Today');
    expect(todayBar.middle, isNull);
    expect(
      find.descendant(
        of: find.byType(AppThemeSwitchButton),
        matching: find.byType(CupertinoButton),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Today medium uses the fixed native blurred toolbar surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(700, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpTodayTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      platform: TargetPlatform.iOS,
    );

    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    final navigationBar = tester.widget<CupertinoNavigationBar>(
      find.byType(CupertinoNavigationBar),
    );
    expect(navigationBar.enableBackgroundFilterBlur, isTrue);
    expect(navigationBar.automaticBackgroundVisibility, isTrue);
    expect(navigationBar.backgroundColor?.a, 0.0);
    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.delegate.minExtent, 44);
    expect(header.delegate.maxExtent, 44);
  });

  testWidgets('framework dismiss intent does not collide with page shortcuts', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });
    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useBranchPage: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.enterText(find.byType(SearchBar), 'escape');
    await tester.pump();
    expect(vm.isInSearchMode, isTrue);
    final editableContext = tester.element(find.byType(EditableText));

    expect(
      () =>
          Actions.invoke<DismissIntent>(editableContext, const DismissIntent()),
      returnsNormally,
    );
    await tester.pump();
    expect(vm.isInSearchMode, isTrue);
    expect(vm.searchOptions.keyword, 'escape');
    expect(tester.takeException(), isNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(vm.isInSearchMode, isFalse);
    expect(vm.searchOptions, const HabitDisplaySearchOptions.empty());
    expect(tester.takeException(), isNull);
  });

  testWidgets('back keeps a non-empty search while dismissing the keyboard', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });
    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useBranchPage: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(SearchBar), 'kept');
    vm.expandCalendar();
    await tester.pump();
    var searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(searchBar.focusNode?.hasFocus, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pump();

    searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(searchBar.focusNode?.hasFocus, isFalse);
    expect(vm.isInSearchMode, isTrue);
    expect(vm.isCalendarExpanded, isTrue);
    expect(vm.searchOptions.keyword, 'kept');

    tester.view.resetViewInsets();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(vm.isInSearchMode, isFalse);
    expect(vm.isCalendarExpanded, isFalse);
    expect(vm.searchOptions, const HabitDisplaySearchOptions.empty());
  });

  testWidgets('escape closes filter menu before clearing active filters', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });
    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useBranchPage: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    vm.onSearchOngoingChanged(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final filter = find.byType(SearchFilterPopupMenuButton);
    expect(filter, findsOneWidget);
    await tester.tap(
      find.descendant(of: filter, matching: find.byType(IconButton)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CheckboxListTile), findsWidgets);
    final filterController = tester
        .widget<SearchFilterPopupMenuButton>(filter)
        .controller!;
    expect(filterController.isOpen, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(filterController.isOpen, isFalse);
    expect(vm.isInSearchMode, isTrue);
    expect(vm.searchOptions.activated, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(vm.isInSearchMode, isFalse);
    expect(vm.searchOptions, const HabitDisplaySearchOptions.empty());
  });

  testWidgets('habit rows follow calendar expand and collapse geometry', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();

    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 600));

    expect(vm.hasLoaded, isTrue);
    expect(vm.currentHabitList, isNotEmpty);
    final calendar = find.byType(SliverCalendarBar);
    final calendarList = find.descendant(
      of: calendar,
      matching: find.byType(ListView),
    );
    final displayRow = find.byType(HabitDisplayListTile);
    final row = find.byType(HabitSummaryListTile);
    final rowList = find.descendant(of: row, matching: find.byType(ListView));
    final rowTrack = find.ancestor(
      of: rowList,
      matching: find.byType(AnimatedContainer),
    );
    expect(row, findsOneWidget);
    expect(displayRow, findsOneWidget);
    expect(rowTrack, findsOneWidget);
    expect(tester.getSize(calendarList).height, 48);
    expect(tester.getSize(rowList).height, 64);
    final calendarGeometry = tester
        .widget<SliverCalendarBar>(calendar)
        .geometry;
    final rowGeometry = tester
        .widget<HabitDisplayListTile>(displayRow)
        .geometry;
    expect(rowGeometry.columnExtent, calendarGeometry.columnExtent);
    expect(rowGeometry.viewportFraction, calendarGeometry.viewportFraction);
    final collapsedWidth = tester.getSize(rowTrack).width;
    expect(
      tester.widget<HabitSummaryListTile>(row).geometry.viewportFraction,
      0.5,
    );

    vm.expandCalendar();
    await tester.pump();
    expect(
      tester.widget<HabitSummaryListTile>(row).geometry.viewportFraction,
      0.85,
    );
    expect(
      tester.widget<HabitDisplayListTile>(displayRow).geometry.columnExtent,
      tester.widget<SliverCalendarBar>(calendar).geometry.columnExtent,
    );
    expect(
      tester.widget<HabitDisplayListTile>(displayRow).geometry.viewportFraction,
      tester.widget<SliverCalendarBar>(calendar).geometry.viewportFraction,
    );
    await tester.pump(const Duration(milliseconds: 300));
    final expandedWidth = tester.getSize(rowTrack).width;

    vm.collapseCalendar();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(expandedWidth, greaterThan(collapsedWidth));
    expect(tester.getSize(rowTrack).width, collapsedWidth);
  });

  testWidgets('calendar uses pinned regular header geometry', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess(habitCount: 20);
    final sync = _FakeAppSyncWorkflowAccess();

    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 600));

    final calendar = find.byType(SliverCalendarBar);
    expect(calendar, findsOneWidget);
    expect(
      find.ancestor(of: calendar, matching: find.byType(SliverAppBar)),
      findsOneWidget,
    );
    expect(tester.getSize(calendar).height, 48);
    expect(
      tester.widget<SliverCalendarBar>(calendar).geometry.columnExtent,
      60,
    );
    expect(
      tester.widget<SliverCalendarBar>(calendar).itemPadding,
      const EdgeInsets.symmetric(horizontal: 8),
    );
    expect(
      tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).edgeOffset,
      AppAdaptiveStyle.materialToolbarHeight + 48,
    );

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar).last);
    expect(appBar.toolbarHeight, 48);
    expect(appBar.pinned, isTrue);
    expect(appBar.primary, isFalse);
    expect(appBar.backgroundColor, isNull);
    expect(appBar.scrolledUnderElevation, kCommonEvalation);
    final pinnedTop = tester.getTopLeft(calendar).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(pinnedTop, AppAdaptiveStyle.materialToolbarHeight);
    expect(tester.getTopLeft(calendar).dy, 0);
  });

  testWidgets('Apple appbar and calendar share one pinned glass surface', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final calendar = find.byType(SliverCalendarBar);
    final calendarBar = find.byKey(const ValueKey('cupertino-calendar-bar'));
    expect(calendarBar, findsNothing);
    final searchHeaderFinder = find.byKey(
      const ValueKey('cupertino-sliver-search-bar'),
    );
    final searchHeader = tester.widget<SliverPersistentHeader>(
      searchHeaderFinder,
    );
    expect(searchHeader.pinned, isTrue);
    expect(searchHeader.delegate.minExtent, 92);
    expect(searchHeader.delegate.maxExtent, 92);
    expect(
      find.ancestor(of: calendar, matching: find.byType(SliverAppBar)),
      findsNothing,
    );
    expect(
      find.descendant(
        of: searchHeaderFinder,
        matching: find.byType(CupertinoNavigationBar),
      ),
      findsOneWidget,
    );
    final habitsNavigationBar = tester.widget<CupertinoNavigationBar>(
      find.descendant(
        of: searchHeaderFinder,
        matching: find.byType(CupertinoNavigationBar),
      ),
    );
    expect(habitsNavigationBar.enableBackgroundFilterBlur, isTrue);
    expect(habitsNavigationBar.automaticBackgroundVisibility, isTrue);
    expect(habitsNavigationBar.backgroundColor?.a, 0.0);
    expect(
      tester
          .widgetList<BackdropFilter>(
            find.descendant(
              of: searchHeaderFinder,
              matching: find.byType(BackdropFilter),
            ),
          )
          .where((filter) => filter.enabled),
      hasLength(1),
    );
    expect(find.byType(PinnedHeaderSliver), findsNothing);
  });

  testWidgets('Apple compact bar minimizes and restores with page scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess(habitCount: 12);
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('cupertino-navigation-expanded')),
      findsOneWidget,
    );
    final compactPrimaryAction = find.byKey(
      const ValueKey('cupertino-primary-action-surface'),
    );
    expect(compactPrimaryAction, findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-slot')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-placeholder')),
      findsNothing,
    );
    expect(tester.getSize(compactPrimaryAction), const Size.square(50));
    expect(find.byType(ScrollingFAB), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('cupertino-navigation-destination-0')),
    );
    await tester.pump();
    expect(compactPrimaryAction, findsOneWidget);

    await _fastDirectDrag(tester, find.byType(CustomScrollView), direction: -1);
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('cupertino-navigation-minimized')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(compactPrimaryAction), const Size.square(44));

    await _fastDirectDrag(tester, find.byType(CustomScrollView), direction: 1);
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('cupertino-navigation-expanded')),
      findsOneWidget,
    );
  });

  testWidgets('Apple Today bar minimizes and restores with page scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess(habitCount: 12);
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpTodayTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      platform: TargetPlatform.iOS,
      useAdaptiveShell: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('cupertino-navigation-expanded')),
      findsOneWidget,
    );

    await _fastDirectDrag(tester, find.byType(CustomScrollView), direction: -1);
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.byKey(const ValueKey('cupertino-navigation-minimized')),
      findsOneWidget,
    );

    await _fastDirectDrag(tester, find.byType(CustomScrollView), direction: 1);
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.byKey(const ValueKey('cupertino-navigation-expanded')),
      findsOneWidget,
    );
  });

  testWidgets('Apple compact selection swaps FAB for the contextual toolbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final appBarSwitcher = tester.widget<SliverAnimatedSwitcher>(
      find.descendant(
        of: find.byType(HabitDisplayAppBar),
        matching: find.byType(SliverAnimatedSwitcher),
      ),
    );
    expect(appBarSwitcher.duration, Duration.zero);
    expect(
      find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsNothing);
    expect(vm.selectedHabitsCount, 0);
    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.widgetWithText(CupertinoMenuItem, 'Select'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(vm.isInEditMode, isTrue);
    expect(vm.selectedHabitsCount, 0);
    expect(find.byType(CupertinoSliverSelectAppBar), findsOneWidget);
    expect(find.byKey(const ValueKey('cupertino-calendar-bar')), findsNothing);
    final selectHeader = tester.widget<SliverPersistentHeader>(
      find.descendant(
        of: find.byType(CupertinoSliverSelectAppBar),
        matching: find.byType(SliverPersistentHeader),
      ),
    );
    expect(selectHeader.delegate.minExtent, 92);
    expect(selectHeader.delegate.maxExtent, 92);
    expect(
      tester
          .widgetList<BackdropFilter>(
            find.descendant(
              of: find.byType(CupertinoSliverSelectAppBar),
              matching: find.byType(BackdropFilter),
            ),
          )
          .where((filter) => filter.enabled),
      isEmpty,
    );
    expect(find.byType(CupertinoSelectBottomToolbar), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height, 0);
    expect(find.byType(ScrollingFAB), findsNothing);
    final placeholder = tester.widget<FixedPagePlaceHolder>(
      find.byType(FixedPagePlaceHolder).last,
    );
    expect(
      placeholder.minHeight,
      tester.getSize(find.byType(CupertinoSelectBottomToolbar)).height,
    );
    expect(placeholder.fixedButtonNaviHeight, isFalse);

    tester.view.physicalSize = const Size(700, 800);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.physicalSize = const Size(390, 800);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height, 0);
    expect(find.byType(CupertinoSelectBottomToolbar), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cupertino-select-done')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(vm.isInEditMode, isFalse);
    expect(find.byType(CupertinoSelectBottomToolbar), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsOneWidget,
    );
    expect(find.byType(ScrollingFAB), findsNothing);
  });

  testWidgets('Apple contextual chrome follows a runtime style round trip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    final style = ValueNotifier(AdaptiveStyle.apple);
    addTearDown(() {
      style.dispose();
      sync.dispose();
      profile.dispose();
    });

    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.iOS,
      appBuilder: (home) => MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: ValueListenableBuilder<AdaptiveStyle>(
          valueListenable: style,
          child: home,
          builder: (context, value, child) =>
              AdaptiveStyleScope(override: value, child: child!),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    style.value = AdaptiveStyle.material;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    style.value = AdaptiveStyle.apple;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    vm.switchToEditMode();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoSelectBottomToolbar), findsOneWidget);
  });

  testWidgets('Apple medium keeps FAB placement with the Cupertino action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final compactButton = find.byKey(
      const ValueKey('cupertino-primary-action-surface'),
    );
    final compactButtonElement = tester.element(compactButton);
    final compactBottomRight = tester.getBottomRight(compactButton);
    final compactTrailingMargin = 390 - compactBottomRight.dx;
    final compactBottomMargin = 800 - compactBottomRight.dy;

    tester.view.physicalSize = const Size(700, 800);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
      findsOneWidget,
    );
    expect(compactButton, findsOneWidget);
    expect(tester.element(compactButton), same(compactButtonElement));
    expect(find.byType(ScrollingFAB), findsNothing);
    expect(tester.getSize(compactButton), const Size.square(50));
    final mediumBottomRight = tester.getBottomRight(compactButton);
    expect(700 - mediumBottomRight.dx, closeTo(compactTrailingMargin, 0.01));
    expect(800 - mediumBottomRight.dy, closeTo(compactBottomMargin, 0.01));
  });

  testWidgets('Apple medium primary action pushes once and restores on pop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(700, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();
    final observer = _RecordingNavigatorObserver();
    late final GoRouter router;
    addTearDown(() {
      router.dispose();
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.iOS,
      appBuilder: (home) {
        router = GoRouter(
          observers: [observer],
          routes: [
            GoRoute(path: '/', builder: (_, _) => home),
            GoRoute(
              path: '/habit/create',
              name: AppRoute.habitCreate.name,
              builder: (_, _) => const Scaffold(body: Text('Create route')),
            ),
          ],
        );
        return MaterialApp.router(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          routerConfig: router,
        );
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
    );
    await tester.tap(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Create route'), findsOneWidget);
    expect(observer.habitCreatePushes, 1);

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsOneWidget,
    );
  });

  testWidgets('Apple Status Modify routes the selected habit UUIDs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess(habitCount: 2);
    final sync = _FakeAppSyncWorkflowAccess();
    List<HabitUUID>? routedUuids;
    late final GoRouter router;
    addTearDown(() {
      router.dispose();
      sync.dispose();
      profile.dispose();
    });

    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useBranchPage: true,
      platform: TargetPlatform.iOS,
      appBuilder: (home) {
        router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => home),
            GoRoute(
              path: '/habits/status',
              name: AppRoute.habitsStatus.name,
              builder: (_, state) {
                routedUuids = state.unpackHabitsStatusChanger().uuidList;
                return const Scaffold(body: Text('Status route'));
              },
            ),
          ],
        );
        return MaterialApp.router(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          routerConfig: router,
        );
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    vm.switchToEditMode();
    vm.selectHabit(_buildHabitSummaryData(0).uuid, listen: false);
    vm.selectHabit(_buildHabitSummaryData(1).uuid);
    await tester.pump();
    final toolbar = tester.widget<CupertinoSelectBottomToolbar>(
      find.byType(CupertinoSelectBottomToolbar),
    );
    toolbar.actions
        .firstWhere((action) => action.id == 'habit-status-modify')
        .onPressed!();
    await tester.pumpAndSettle();

    expect(routedUuids, [
      _buildHabitSummaryData(0).uuid,
      _buildHabitSummaryData(1).uuid,
    ]);
  });

  testWidgets('Material Status Modify routes the selected habit UUIDs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess(habitCount: 2);
    final sync = _FakeAppSyncWorkflowAccess();
    List<HabitUUID>? routedUuids;
    late final GoRouter router;
    addTearDown(() {
      router.dispose();
      sync.dispose();
      profile.dispose();
    });

    final vm = await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useAdaptiveShell: true,
      platform: TargetPlatform.android,
      appBuilder: (home) {
        router = GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => home),
            GoRoute(
              path: '/habits/status',
              name: AppRoute.habitsStatus.name,
              builder: (_, state) {
                routedUuids = state.unpackHabitsStatusChanger().uuidList;
                return const Scaffold(body: Text('Status route'));
              },
            ),
          ],
        );
        return MaterialApp.router(
          theme: ThemeData(platform: TargetPlatform.android),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          routerConfig: router,
        );
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final fabSwitcher = find.descendant(
      of: find.byType(ScrollingFAB),
      matching: find.byType(AnimatedSwitcher),
    );
    expect(fabSwitcher, findsOneWidget);
    final fabSwitcherElement = tester.element(fabSwitcher);

    vm.switchToEditMode();
    vm.selectHabit(_buildHabitSummaryData(0).uuid, listen: false);
    vm.selectHabit(_buildHabitSummaryData(1).uuid);
    await tester.pump();
    expect(tester.element(fabSwitcher), same(fabSwitcherElement));
    expect(
      tester
          .widgetList<AnimatedCrossFade>(
            find.descendant(
              of: find.byType(ScrollingFAB),
              matching: find.byType(AnimatedCrossFade),
            ),
          )
          .map((crossFade) => crossFade.crossFadeState),
      contains(CrossFadeState.showSecond),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester
          .widgetList<FadeTransition>(
            find.descendant(
              of: fabSwitcher,
              matching: find.byType(FadeTransition),
            ),
          )
          .map((transition) => transition.opacity.value),
      contains(inExclusiveRange(0, 1)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height, 0);
    expect(find.byType(NavigationBar).hitTestable(), findsNothing);
    expect(find.byType(FloatingActionButton).hitTestable(), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton).hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(routedUuids, [
      _buildHabitSummaryData(0).uuid,
      _buildHabitSummaryData(1).uuid,
    ]);
  });

  testWidgets('calendar uses compact header geometry', (tester) async {
    final profile = await _loadProfile();
    final access = _LoadedHabitsDisplayAccess();
    final sync = _FakeAppSyncWorkflowAccess();

    addTearDown(() {
      sync.dispose();
      profile.dispose();
    });

    await _pumpHabitsTabPage(
      tester,
      profile: profile,
      access: access,
      sync: sync,
      useCompactUi: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final calendar = find.byType(SliverCalendarBar);
    final calendarList = find.descendant(
      of: calendar,
      matching: find.byType(ListView),
    );
    expect(tester.getSize(calendar).height, 44);
    expect(tester.getSize(calendarList).height, 44);
    expect(
      tester.widget<SliverCalendarBar>(calendar).geometry.columnExtent,
      44,
    );
    expect(
      tester.widget<SliverCalendarBar>(calendar).itemPadding,
      const EdgeInsets.symmetric(horizontal: 4),
    );
    expect(
      tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).edgeOffset,
      AppAdaptiveStyle.materialToolbarHeight + 44,
    );
  });
}
