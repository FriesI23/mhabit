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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_today.dart';
import 'package:mhabit/pages/habits_display/page_habits.dart';
import 'package:mhabit/pages/habits_display/page_today.dart';
import 'package:mhabit/providers/app_ui/app_compact_ui_switcher.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
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
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/stub/app_sync.dart';
import '../../support/stub/habits_display_access.dart';

final class _FailingHabitsDisplayAccess extends StubHabitsDisplayAccess {
  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async => throw StateError('load failed');
}

final class _FakeAppSyncWorkflowAccess extends StubAppSyncWorkflowAccess {}

final class _FakeGroupManager extends GroupManager {
  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult([]);
}

final class _LoadedHabitsDisplayAccess extends StubHabitsDisplayAccess {
  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final collection = initedCollection ?? HabitSummaryDataCollection();
    collection.addHabit(_buildHabitSummaryData(), forceAdd: true);
    return collection;
  }
}

HabitSummaryData _buildHabitSummaryData() {
  final startDate = HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: 1,
    uuid: '11111111-1111-4111-8111-111111111111',
    type: HabitType.normal,
    name: 'Geometry regression habit',
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: startDate,
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

void _ignoreBool(bool _) {}

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
      child: const MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(
          body: TodayTabPage(onBottomNavVisibilityChanged: _ignoreBool),
        ),
      ),
    ),
  );
}

Future<HabitSummaryViewModel> _pumpHabitsTabPage(
  WidgetTester tester, {
  required ProfileViewModel profile,
  required HabitsDisplayAccess access,
  required AppSyncWorkflowAccess sync,
}) async {
  final customDate = AppCustomDateYmdHmsConfigViewModel()
    ..updateProfile(profile);
  final firstDay = AppFirstDayViewModel()..updateProfile(profile);
  final compactUi = AppCompactUISwitcherViewModel()..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global());
  final experimental = AppExperimentalFeatureViewModel()
    ..updateProfile(profile);
  final theme = AppThemeViewModel()..updateProfile(profile);
  final scrollBehavior = HabitsRecordScrollBehaviorViewModel()
    ..updateProfile(profile);
  final recordOpConfig = HabitRecordOpConfigViewModel()..updateProfile(profile);
  final sort = HabitsSortViewModel()..updateProfile(profile);
  final filter = HabitsFilterViewModel()..updateProfile(profile);
  final appEvent = AppEventBus();
  final vm = HabitSummaryViewModel()
    ..attachAccess(access)
    ..attachGroupManager(_FakeGroupManager());

  addTearDown(() {
    vm.dispose();
    appEvent.dispose();
    filter.dispose();
    sort.dispose();
    recordOpConfig.dispose();
    scrollBehavior.dispose();
    theme.dispose();
    experimental.dispose();
    developer.dispose();
    compactUi.dispose();
    firstDay.dispose();
    customDate.dispose();
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
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
        ListenableProvider<AppSyncTriggerAccess>.value(value: sync),
        ListenableProvider<AppSyncStatusSource>.value(value: sync),
        ListenableProvider<AppSyncWorkflowAccess>.value(value: sync),
      ],
      child: const ChangelogBanner(
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Scaffold(
            body: HabitsTabPage(onBottomNavVisibilityChanged: _ignoreBool),
          ),
        ),
      ),
    ),
  );
  return vm;
}

void main() {
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
    final row = find.byType(HabitSummaryListTile);
    final rowList = find.descendant(of: row, matching: find.byType(ListView));
    final rowTrack = find.ancestor(
      of: rowList,
      matching: find.byType(AnimatedContainer),
    );
    expect(row, findsOneWidget);
    expect(rowTrack, findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 300));
    final expandedWidth = tester.getSize(rowTrack).width;

    vm.collapseCalendar();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(expandedWidth, greaterThan(collapsedWidth));
    expect(tester.getSize(rowTrack).width, collapsedWidth);
  });
}
