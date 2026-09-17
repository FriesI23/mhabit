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
    show CupertinoIcons, CupertinoListTile, CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/models/group_export.dart';
import 'package:mhabit/models/habit_export.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_language_changer.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_develop_subgroup.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_reminder_tile.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_sync_failed_tile.dart';
import 'package:mhabit/pages/app_settings/page.dart';
import 'package:mhabit/pages/common/_widgets/exporter_confirm_dialog.dart';
import 'package:mhabit/providers/app_ui/app_compact_ui_switcher.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/app_ui/app_language.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/providers/app_ui/group_expand_timer_config.dart';
import 'package:mhabit/providers/app_ui/habit_op_config.dart';
import 'package:mhabit/providers/app_ui/habits_record_scroll_behavior.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_reminder.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile/handlers/app_language.dart';
import 'package:mhabit/storage/profile/handlers/display_calendar_scroll_mode.dart';
import 'package:mhabit/storage/profile/handlers/habit_grouping.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ExportAccess implements HabitExportAccess, GroupExportAccess {
  int habitLoads = 0;
  int groupLoads = 0;

  @override
  Future<Iterable<HabitExportData>> loadHabitExportData({
    List<HabitUUID>? uuidList,
    bool withRecords = true,
  }) async {
    expect(withRecords, isFalse);
    habitLoads++;
    return [];
  }

  @override
  Future<Iterable<GroupExportData>> loadGroupExportData() async {
    groupLoads++;
    return [];
  }
}

class _CompactUi extends AppCompactUISwitcherViewModel {
  bool value = false;
  int changes = 0;

  @override
  bool get flag => value;

  @override
  Future<void> setFlag(bool newFlag) async {
    value = newFlag;
    changes++;
    notifyListeners();
  }
}

final class _FakeAppSyncAccess extends ChangeNotifier
    implements AppSyncTriggerAccess, AppSyncStatusSource {
  @override
  bool get canStartSync => true;

  @override
  AppSyncStatusSnapshot? syncStatus;

  void complete(AppSyncTaskResult result) {
    syncStatus = AppSyncStatusSnapshot(
      id: 'task',
      sessionId: 'session',
      status: AppSyncTaskStatus.completed,
      startTime: null,
      endedTime: null,
      result: result,
      percentage: null,
    );
    notifyListeners();
  }

  @override
  Future<void> startSync({Duration? initWait}) async {}

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}

  @override
  void cancelSync() {}
}

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([
    AppLanguageProfileHanlder.new,
    HabitGroupingExperimentalFeature.new,
    DisplayCalendarScrollModeProfileHandler.new,
  ]);
  await profile.init();
  return profile;
}

void main() {
  testWidgets('sync failure expansion does not read the scroll offset', (
    tester,
  ) async {
    final bucket = PageStorageBucket();
    final syncAccess = _FakeAppSyncAccess()
      ..complete(const BasicAppSyncTaskResult.error(error: 'failure'));
    late BuildContext scrollStorageContext;
    addTearDown(syncAccess.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PageStorage(
          bucket: bucket,
          child: KeyedSubtree(
            key: const PageStorageKey<String>('app-settings-scroll-view'),
            child: Builder(
              builder: (context) {
                scrollStorageContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    bucket.writeState(scrollStorageContext, 240.0);

    await tester.pumpWidget(
      ListenableProvider<AppSyncStatusSource>.value(
        value: syncAccess,
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: PageStorage(
            bucket: bucket,
            child: const KeyedSubtree(
              key: PageStorageKey<String>('app-settings-scroll-view'),
              child: Scaffold(body: AppSettingSyncFailedTile()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ExpansionTile), findsOneWidget);
  });

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    testWidgets('AppSettingPage language and scroll flow on $platform', (
      tester,
    ) async {
      final profile = await _loadProfile();
      final dbHelper = DBHelperViewModel();
      final syncAccess = _FakeAppSyncAccess();

      final exportAccess = _ExportAccess();
      final customDate = AppCustomDateYmdHmsConfigViewModel()
        ..updateProfile(profile);
      final firstDay = AppFirstDayViewModel()..updateProfile(profile);
      final compactUi = _CompactUi()..updateProfile(profile);
      final developer = AppDeveloperViewModel(
        global: Global()..switchDevelopMode(false),
      );
      var developerChanges = 0;
      developer.addListener(() => developerChanges++);
      final destinations = <AppRoute>[];
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const AppSettingPage()),
          for (final route in [
            AppRoute.settingsSync,
            AppRoute.groupManage,
            AppRoute.experimental,
            AppRoute.debugger,
            AppRoute.settingsAbout,
          ])
            GoRoute(
              path: '/${route.name}',
              name: route.name,
              builder: (_, _) {
                destinations.add(route);
                return Scaffold(body: Text('Destination ${route.name}'));
              },
            ),
        ],
      );
      addTearDown(router.dispose);
      final reminderOwner = AppReminderOwner()..updateProfile(profile);
      final reminder = AppReminderViewModel()..attachAccess(reminderOwner);
      final theme = AppThemeViewModel()..updateProfile(profile);
      final language = AppLanguageViewModel()..updateProfile(profile);
      final scrollBehavior = HabitsRecordScrollBehaviorViewModel()
        ..updateProfile(profile);
      final recordOpConfig = HabitRecordOpConfigViewModel()
        ..updateProfile(profile);
      final experimentalFeature = AppExperimentalFeatureViewModel()
        ..updateProfile(profile);
      await experimentalFeature.setHabitGrouping(false);

      addTearDown(() {
        experimentalFeature.dispose();
        recordOpConfig.dispose();
        scrollBehavior.dispose();
        language.dispose();
        theme.dispose();
        reminder.dispose();
        reminderOwner.dispose();
        developer.dispose();
        compactUi.dispose();
        firstDay.dispose();
        customDate.dispose();
        syncAccess.dispose();
        dbHelper.dispose();
        profile.dispose();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<HabitExportAccess>.value(value: exportAccess),
            Provider<GroupExportAccess>.value(value: exportAccess),
            ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
            ChangeNotifierProvider<DBHelperViewModel>.value(value: dbHelper),
            ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
              value: customDate,
            ),
            ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
            ChangeNotifierProvider<AppCompactUISwitcherViewModel>.value(
              value: compactUi,
            ),
            ChangeNotifierProvider<AppDeveloperViewModel>.value(
              value: developer,
            ),
            ChangeNotifierProvider<AppReminderViewModel>.value(value: reminder),
            ChangeNotifierProvider<AppThemeViewModel>.value(value: theme),
            ChangeNotifierProvider<AppLanguageViewModel>.value(value: language),
            ChangeNotifierProvider<HabitsRecordScrollBehaviorViewModel>.value(
              value: scrollBehavior,
            ),
            ChangeNotifierProvider<HabitRecordOpConfigViewModel>.value(
              value: recordOpConfig,
            ),
            ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
              value: experimentalFeature,
            ),
            ChangeNotifierProvider<GroupExpandTimerConfigViewModel>(
              create: (_) =>
                  GroupExpandTimerConfigViewModel()..updateProfile(profile),
            ),
            ListenableProvider<AppSyncTriggerAccess>.value(value: syncAccess),
            ListenableProvider<AppSyncStatusSource>.value(value: syncAccess),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      if (platform == TargetPlatform.android) {
        expect(find.byType(WindowControlSliverAppBar), findsOneWidget);
      }
      expect(find.byType(CustomScrollView), findsOneWidget);
      final adaptiveAppBar = tester.widget<AdaptiveSliverAppBar>(
        find.byType(AdaptiveSliverAppBar),
      );
      expect(adaptiveAppBar.automaticallyImplyLeading, isFalse);
      if (platform == TargetPlatform.android) {
        final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
        expect(appBar.automaticallyImplyLeading, isFalse);
        expect(appBar.leading, isA<AdaptiveBackButton>());
        expect(appBar.title, isA<L10nBuilder>());
      }
      final safeArea = tester.widget<SliverSafeArea>(
        find.byType(SliverSafeArea),
      );
      expect(safeArea.left, isTrue);
      expect(safeArea.top, isFalse);
      expect(safeArea.right, isTrue);
      expect(safeArea.bottom, isTrue);

      final syncSection = find.byKey(const ValueKey('settings-sync'));
      expect(
        tester.widget<AdaptiveListSection>(syncSection).children,
        hasLength(2),
      );
      syncAccess.complete(
        const BasicAppSyncTaskResult.error(error: 'sync failed'),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdaptiveListSection>(syncSection).children,
        hasLength(3),
      );
      expect(find.textContaining('sync failed').hitTestable(), findsOneWidget);
      syncAccess.complete(const BasicAppSyncTaskResult.success());
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdaptiveListSection>(syncSection).children,
        hasLength(2),
      );
      final syncOption = find.byKey(const ValueKey('settings-sync-option'));
      await Scrollable.ensureVisible(
        tester.element(syncOption),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(syncOption);
      await tester.pumpAndSettle();
      expect(
        find.text('Destination ${AppRoute.settingsSync.name}'),
        findsOneWidget,
      );
      router.pop();
      await tester.pumpAndSettle();

      final groups = find.byKey(const ValueKey('settings-groups'));
      expect(groups, findsNothing);
      await experimentalFeature.setHabitGrouping(true);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.scrollUntilVisible(
        groups,
        100,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      final groupTile = find.descendant(
        of: groups,
        matching: find.byType(AdaptiveListTile),
      );
      expect(groupTile, findsOneWidget);
      expect(
        find.descendant(
          of: groupTile,
          matching: find.byIcon(
            platform == TargetPlatform.android
                ? Icons.chevron_right
                : CupertinoIcons.chevron_forward,
          ),
        ),
        findsOneWidget,
      );
      await Scrollable.ensureVisible(tester.element(groupTile), alignment: 0.5);
      await tester.pump(const Duration(milliseconds: 300));
      final groupScroll = tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            ),
          )
          .position;
      final groupOffset = groupScroll.pixels;
      await tester.tap(groupTile);
      await tester.pumpAndSettle();
      expect(
        find.text('Destination ${AppRoute.groupManage.name}'),
        findsOneWidget,
      );
      expect(destinations, [AppRoute.settingsSync, AppRoute.groupManage]);
      router.pop();
      await tester.pump(const Duration(milliseconds: 500));
      expect(groupScroll.pixels, groupOffset);
      await experimentalFeature.setHabitGrouping(false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(groups, findsNothing);

      final display = find.byKey(const ValueKey('settings-display'));
      final compact = find.descendant(
        of: display,
        matching: find.byType(
          platform == TargetPlatform.android ? Switch : CupertinoSwitch,
        ),
      );
      await tester.scrollUntilVisible(
        compact,
        150,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(compact);
      await tester.pumpAndSettle();
      expect(compactUi.flag, isTrue);
      expect(compactUi.changes, 1);
      final l10n = L10n.of(tester.element(compact))!;
      final compactTitle = find.text(
        l10n.appSetting_compactUISwitcher_titleText,
      );
      await Scrollable.ensureVisible(
        tester.element(compactTitle),
        alignment: 0.5,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(compactTitle);
      await tester.pump(const Duration(milliseconds: 300));
      expect(compactUi.flag, isFalse);
      expect(compactUi.changes, 2);

      final languageTile = find.byKey(const ValueKey('settings-language'));
      await tester.scrollUntilVisible(
        languageTile,
        200,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: languageTile,
          matching: find.byType(
            platform == TargetPlatform.android ? ListTile : CupertinoListTile,
          ),
        ),
        findsOneWidget,
      );
      if (platform != TargetPlatform.android) {
        expect(
          find.ancestor(
            of: languageTile,
            matching: find.byType(AdaptiveListSection),
          ),
          findsOneWidget,
        );
      }
      // The adaptive selector preserves selection and cancellation.
      await tester.tap(languageTile);
      await tester.pumpAndSettle();
      expect(find.byType(AppLanguageChangerDialog), findsOneWidget);
      Navigator.of(tester.element(find.byType(AppLanguageChangerDialog))).pop();
      await tester.pumpAndSettle();
      expect(language.languange, isNull);
      await tester.tap(languageTile);
      await tester.pumpAndSettle();
      final english = find.descendant(
        of: find.byType(AppLanguageChangerDialog),
        matching: find.byKey(const ValueKey('language-option-en')),
      );
      await Scrollable.ensureVisible(tester.element(english), alignment: 0.5);
      await tester.tap(english);
      await tester.pumpAndSettle();
      expect(language.languange, const Locale('en'));
      expect(
        find.descendant(of: languageTile, matching: find.text('English')),
        findsOneWidget,
      );
      await tester.tap(languageTile);
      await tester.pumpAndSettle();
      final system = find
          .descendant(
            of: find.byType(AppLanguageChangerDialog),
            matching: find.byKey(const ValueKey('language-option-system')),
          )
          .first;
      await Scrollable.ensureVisible(tester.element(system), alignment: 0.5);
      await tester.tap(system);
      await tester.pumpAndSettle();
      expect(language.languange, isNull);
      expect(tester.takeException(), isNull);

      final operation = find.byKey(const ValueKey('settings-operation'));
      final calendarByPage = find.byKey(
        const ValueKey('settings-calendar-by-page'),
      );
      await tester.scrollUntilVisible(
        calendarByPage,
        150,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<AdaptiveListSection>(operation).children.length, 3);
      final previousScrollBehavior = scrollBehavior.scrollBehavior;
      await tester.tap(
        find.descendant(
          of: calendarByPage,
          matching: find.byType(
            platform == TargetPlatform.android ? Switch : CupertinoSwitch,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollBehavior.scrollBehavior, isNot(previousScrollBehavior));
      await experimentalFeature.setHabitGrouping(true);
      await tester.pumpAndSettle();
      expect(tester.widget<AdaptiveListSection>(operation).children.length, 4);
      await experimentalFeature.setHabitGrouping(false);
      await tester.pumpAndSettle();
      expect(tester.widget<AdaptiveListSection>(operation).children.length, 3);

      final reminderSection = find.byKey(const ValueKey('settings-reminder'));
      final reminderTile = find.descendant(
        of: reminderSection,
        matching: find.byType(AppSettingReminderTile),
      );
      await tester.scrollUntilVisible(
        reminderTile,
        150,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await Scrollable.ensureVisible(
        tester.element(reminderTile),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AdaptiveListSection>(reminderSection).children,
        hasLength(2),
      );
      final beforeReminder = reminder.reminder;
      await tester.tap(
        find.descendant(
          of: reminderTile,
          matching: find.text('Daily reminder'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      Navigator.of(tester.element(find.byType(TimePickerDialog))).pop();
      await tester.pumpAndSettle();
      expect(reminder.reminder, beforeReminder);

      final backup = find.byKey(const ValueKey('settings-backup-restore'));
      await tester.scrollUntilVisible(
        backup,
        150,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      final backupTiles = find.descendant(
        of: backup,
        matching: find.byType(AdaptiveListTile),
      );
      expect(backupTiles, findsNWidgets(4));
      for (final tile in tester.widgetList<AdaptiveListTile>(backupTiles)) {
        expect(tile.trailing, isNull);
      }
      // Cancellation must stop before any export/import/reset workflow owner.
      // Those execution providers are deliberately absent from this fixture.
      for (final index in [0, 2, 3]) {
        final tile = backupTiles.at(index);
        await Scrollable.ensureVisible(tester.element(tile), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        if (index == 0) {
          expect(find.byType(ExporterConfirmDialog), findsOneWidget);
          expect(exportAccess.habitLoads, 1);
          expect(exportAccess.groupLoads, 1);
          Navigator.of(
            tester.element(find.byType(ExporterConfirmDialog)),
          ).pop();
        } else if (index == 2) {
          expect(find.text('Loop Habit Tracker'), findsOneWidget);
          Navigator.of(tester.element(find.text('Loop Habit Tracker'))).pop();
        } else {
          final cancel = L10n.of(
            tester.element(backup),
          )!.appSetting_resetConfigDialog_cancelText;
          await tester.tap(find.text(cancel).hitTestable());
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      final others = find.byKey(const ValueKey('settings-others'));
      await tester.scrollUntilVisible(
        others,
        150,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<AdaptiveListSection>(others).children, hasLength(5));
      expect(
        find.descendant(
          of: others,
          matching: find.byIcon(CupertinoIcons.chevron_forward),
        ),
        platform == TargetPlatform.android ? findsNothing : findsNWidgets(3),
      );
      final developmentTile = find.descendant(
        of: others,
        matching: find.byType(AdaptiveSwitchListTile),
      );
      await Scrollable.ensureVisible(
        tester.element(developmentTile),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: developmentTile,
          matching: find.byType(
            platform == TargetPlatform.android ? Switch : CupertinoSwitch,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(developer.isInDevelopMode, isTrue);
      expect(developerChanges, 1);
      // Scroll far enough to build the lazy Developer group, then toggle off.
      await tester.scrollUntilVisible(
        find.byType(AppSettingDevelopSubGroup),
        100,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(
        tester
            .widget<AppSettingDevelopSubGroup>(
              find.byType(AppSettingDevelopSubGroup),
            )
            .isInDevelopMode,
        isTrue,
      );
      await Scrollable.ensureVisible(
        tester.element(developmentTile),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: developmentTile, matching: find.byType(Text)).first,
      );
      await tester.pumpAndSettle();
      expect(developer.isInDevelopMode, isFalse);
      expect(developerChanges, 2);

      final othersL10n = L10n.of(tester.element(others))!;
      final clearCache = find.descendant(
        of: others,
        matching: find.text(othersL10n.appSetting_clearCache_titleText),
      );
      await Scrollable.ensureVisible(
        tester.element(clearCache),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(clearCache);
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .text(othersL10n.appSetting_clearCacheDialog_cancelText)
            .hitTestable(),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final entry in [
        (
          othersL10n.appSetting_experimentalFeatureTile_titleText,
          AppRoute.experimental,
        ),
        (othersL10n.appSetting_debugger_titleText, AppRoute.debugger),
        (othersL10n.appSetting_about_titleText, AppRoute.settingsAbout),
      ]) {
        final title = find.descendant(
          of: others,
          matching: find.text(entry.$1),
        );
        await Scrollable.ensureVisible(tester.element(title), alignment: 0.5);
        await tester.pumpAndSettle();
        final position = tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              ),
            )
            .position;
        final before = position.pixels;
        await tester.tap(title);
        await tester.pumpAndSettle();
        expect(find.text('Destination ${entry.$2.name}'), findsOneWidget);
        expect(destinations.last, entry.$2);
        router.pop();
        await tester.pumpAndSettle();
        expect(position.pixels, before);
      }
      expect(destinations, [
        AppRoute.settingsSync,
        AppRoute.groupManage,
        AppRoute.experimental,
        AppRoute.debugger,
        AppRoute.settingsAbout,
      ]);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      final offsetBeforePush = scrollable.position.pixels;
      expect(offsetBeforePush, greaterThan(0));

      final settingsContext = tester.element(find.text('Settings'));
      unawaited(
        Navigator.of(settingsContext).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Subpage')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('Subpage'))).pop();
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, offsetBeforePush);
    });
  }
}
