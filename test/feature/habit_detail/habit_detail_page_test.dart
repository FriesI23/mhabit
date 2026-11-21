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

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/custom_date_format.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_detail.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_reminder.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/common/_widgets/habit_record_number_picker.dart';
import 'package:mhabit/pages/habit_detail/_providers/habit_detail.dart';
import 'package:mhabit/pages/habit_detail/page.dart';
import 'package:mhabit/pages/habit_detail/widgets.dart'
    show
        HabitDetailAppBarAction,
        HabitDetailFreqChart,
        HabitEditReplacementRecordCalendarDialog,
        HabitHeatmap;
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit/utils/app_clock.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_heatmap_calendar/simple_heatmap_calendar.dart';

import '../../support/adaptive_dialog.dart';
import '../../support/stub/habits_display_access.dart';

final class _FakeHabitDetailAccess extends StubHabitDetailAccess {
  final HabitDetailData seedData;
  int failLoadDetailDataCount;
  int loadDetailDataCallCount = 0;
  int statusChangeCalls = 0;
  final List<HabitStatus> requestedStatuses = [];
  final List<ChangeRecordStatusResult> recordChanges = [];
  Completer<Iterable<ChangeHabitStatusResult>>? statusChangeCompleter;

  @override
  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  }) async {
    statusChangeCalls++;
    requestedStatuses.add(action.status);
    return statusChangeCompleter == null
        ? []
        : await statusChangeCompleter!.future;
  }

  _FakeHabitDetailAccess({
    required this.seedData,
    this.failLoadDetailDataCount = 0,
  });

  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) async {
    loadDetailDataCallCount += 1;
    if (failLoadDetailDataCount > 0) {
      failLoadDetailDataCount -= 1;
      throw StateError('load failed');
    }
    return seedData;
  }

  @override
  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
      List<ChangeRecordStatusResult> results,
    )?
    postActionBuilder,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  }) async {
    final initial = preAction.resolve();
    final results = postActionBuilder?.call(initial).resolve() ?? initial;
    recordChanges.addAll(results);
    await beforeReminderUpdate?.call(seedData.data, results);
    for (final result in results) {
      await extraResolver?.call(result);
    }
    return results;
  }
}

final class _CustomDateFormat extends AppCustomDateYmdHmsConfigViewModel {
  _CustomDateFormat(this.config);

  @override
  final CustomDateYmdHmsConfig config;
}

final class _PendingHabitDetailAccess extends StubHabitDetailAccess {
  final Completer<HabitDetailData?> _completer = Completer();

  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) =>
      _completer.future;
}

final class _DeferredReloadHabitDetailAccess extends StubHabitDetailAccess {
  _DeferredReloadHabitDetailAccess({required this.initialData});

  final HabitDetailData initialData;
  final Completer<HabitDetailData?> reloadCompleter = Completer();
  final Completer<HabitDetailData?> retryCompleter = Completer();
  int loadDetailDataCallCount = 0;

  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) {
    loadDetailDataCallCount += 1;
    return switch (loadDetailDataCallCount) {
      1 => Future.value(initialData),
      2 => reloadCompleter.future,
      _ => retryCompleter.future,
    };
  }
}

HabitSummaryData _buildHabitSummaryData({
  String uuid = '11111111-1111-4111-8111-111111111111',
  HabitStatus status = HabitStatus.activated,
  String name = 'Sample Habit',
}) {
  final startDate = HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: 1,
    uuid: uuid,
    type: HabitType.normal,
    name: name,
    desc: 'Detail regression fixture',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: startDate,
    status: status,
    sortPostion: 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

HabitDetailData _buildHabitDetailData({
  HabitStatus status = HabitStatus.activated,
  String name = 'Sample Habit',
}) {
  final data = _buildHabitSummaryData(status: status, name: name);
  return HabitDetailData(
    data: data,
    modifyT: DateTime.utc(2026, 1, 1),
    dailyGoalUnit: 'times',
  );
}

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel(const []);
  await profile.init();
  return profile;
}

Future<void> _pumpHabitDetailPage(
  WidgetTester tester, {
  required ProfileViewModel profile,
  required HabitDetailAccess access,
  required ValueNotifier<int> rebuildToken,
  required HabitUUID habitUUID,
  bool wrapWithAdaptiveShell = false,
  TargetPlatform? platform,
  bool withAppLocalizations = false,
  Locale? locale,
  CustomDateYmdHmsConfig? dateConfig,
}) async {
  final customDate = dateConfig == null
      ? AppCustomDateYmdHmsConfigViewModel()
      : _CustomDateFormat(dateConfig);
  customDate.updateProfile(profile);
  final firstDay = AppFirstDayViewModel()..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global());
  final appEvent = AppEventBus();

  addTearDown(() {
    appEvent.dispose();
    developer.dispose();
    firstDay.dispose();
    customDate.dispose();
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
        Provider<HabitDetailAccess>.value(value: access),
        ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
          value: customDate,
        ),
        ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
        ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
        ChangeNotifierProvider<AppEventBus>.value(value: appEvent),
      ],
      child: MaterialApp(
        locale: locale,
        theme: ThemeData(platform: platform, extensions: [lightCustomColors]),
        localizationsDelegates: withAppLocalizations
            ? appLocalizationsDelegates
            : null,
        supportedLocales: withAppLocalizations
            ? L10n.supportedLocales
            : const [Locale('en', 'US')],
        home: ValueListenableBuilder<int>(
          valueListenable: rebuildToken,
          builder: (context, _, child) {
            final page = HabitDetailPage(
              habitUUID: habitUUID,
              color: const HabitColor.builtIn(HabitColorType.cc1),
            );
            if (!wrapWithAdaptiveShell) return page;
            return AdaptiveNavigationShell(
              selectedIndex: 0,
              compactRouteVisible: false,
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.home_outlined),
                    materialSelected: Icon(Icons.home_outlined),
                    apple: Icon(Icons.home_outlined),
                    appleSelected: Icon(Icons.home_outlined),
                  ),
                ),
                AdaptiveNavigationDestination(
                  label: 'Today',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.calendar_today_outlined),
                    materialSelected: Icon(Icons.calendar_today_outlined),
                    apple: Icon(Icons.calendar_today_outlined),
                    appleSelected: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
              onDestinationSelected: (_) {},
              child: page,
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  for (final (locale, month) in [
    (const Locale('en'), 1),
    (const Locale('zh'), 2),
  ]) {
    testWidgets('detail Heatmap consumes localized label text $locale', (
      tester,
    ) async {
      await initializeDateFormatting();
      final oldClock = AppClock().clock;
      AppClock().setClock(Clock(() => DateTime.utc(2026, month, 10)));
      addTearDown(() => AppClock().setClock(oldClock));
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final profile = await _loadProfile();
      final detail = _buildHabitDetailData();
      final rebuild = ValueNotifier(0);
      addTearDown(() {
        rebuild.dispose();
        profile.dispose();
      });
      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: _FakeHabitDetailAccess(seedData: detail),
        rebuildToken: rebuild,
        habitUUID: detail.data.uuid,
        withAppLocalizations: true,
        locale: locale,
      );
      await tester.pumpAndSettle();
      final heatmap = find.byType(HabitHeatmap);
      await tester.ensureVisible(heatmap);
      await tester.pumpAndSettle();
      final monthLabels = find.descendant(
        of: heatmap,
        matching: find.byType(MonthLabelItem),
      );
      expect(monthLabels, findsWidgets);
      for (final element in monthLabels.evaluate()) {
        final item = element.widget as MonthLabelItem;
        final expected = DateFormat(
          item.date.month == DateTime.january ? 'yMMM' : 'MMM',
          locale.toString(),
        ).format(item.date);
        expect(
          find.descendant(
            of: find.byWidget(item),
            matching: find.text(expected),
          ),
          findsOneWidget,
        );
      }
      final weekLabels = find.descendant(
        of: heatmap,
        matching: find.byType(WeekLabelItem),
      );
      expect(weekLabels, findsNWidgets(7));
      for (final element in weekLabels.evaluate()) {
        final item = element.widget as WeekLabelItem;
        final expected = DateFormat(
          'ccccc',
          locale.toString(),
        ).format(item.date);
        expect(
          find.descendant(
            of: find.byWidget(item),
            matching: find.text(expected),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    testWidgets('detail content responds to viewport height on $platform', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final profile = await _loadProfile();
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final rebuildToken = ValueNotifier(0);
      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });
      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: detailData.data.uuid,
        platform: platform,
        wrapWithAdaptiveShell: true,
        withAppLocalizations: true,
      );
      await tester.pumpAndSettle();
      for (final height in [700.0, 400.0, 700.0]) {
        tester.view.physicalSize = Size(1000, height);
        final scrollable = find
            .descendant(
              of: find.descendant(
                of: find.byType(HabitDetailPage),
                matching: find.byType(CustomScrollView),
              ),
              matching: find.byType(Scrollable),
            )
            .first;
        tester.state<ScrollableState>(scrollable).position.jumpTo(0);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<HabitHeatmap>(find.byType(HabitHeatmap))
              .useSideBySideLayout,
          height >= 480,
        );
        // Sliver children are built lazily: bring the frequency chart into
        // view before checking its local layout classification.
        final chart = find.byType(HabitDetailFreqChart);
        final position = tester.state<ScrollableState>(scrollable).position;
        for (var step = 0; step < 20 && chart.evaluate().isEmpty; step++) {
          position.jumpTo(
            (position.pixels + 200).clamp(0, position.maxScrollExtent),
          );
          await tester.pumpAndSettle();
        }
        expect(chart, findsOneWidget, reason: 'viewport height $height');
        expect(
          tester.widget<HabitDetailFreqChart>(chart).useSideBySideLayout,
          height >= 480,
        );
        expect(access.loadDetailDataCallCount, 1);
        expect(tester.takeException(), isNull);
      }
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final op in ['Unarchive', 'Delete']) {
      for (final outcome in ['cancel', 'confirm', 'covered']) {
        testWidgets(
          '$platform detail $op $outcome uses adaptive confirmation',
          (tester) async {
            final profile = await _loadProfile();
            final detail = _buildHabitDetailData(status: HabitStatus.archived);
            final access = _FakeHabitDetailAccess(seedData: detail);
            final rebuild = ValueNotifier(0);
            addTearDown(() {
              rebuild.dispose();
              profile.dispose();
            });
            await _pumpHabitDetailPage(
              tester,
              profile: profile,
              access: access,
              rebuildToken: rebuild,
              habitUUID: detail.data.uuid,
              platform: platform,
            );
            await tester.pumpAndSettle();
            final navigator = Navigator.of(
              tester.element(find.byType(HabitDetailPage)),
            );
            DetailPageReturn? pageResult;
            navigator
                .push<DetailPageReturn>(
                  MaterialPageRoute(
                    builder: (_) =>
                        HabitDetailPage(habitUUID: detail.data.uuid),
                  ),
                )
                .then((result) => pageResult = result);
            await tester.pumpAndSettle();
            if (op == 'Unarchive' && platform == TargetPlatform.android) {
              await tester.tap(find.byIcon(Icons.unarchive_rounded));
            } else {
              await tester.tap(
                find.byIcon(
                  platform == TargetPlatform.iOS
                      ? CupertinoIcons.ellipsis
                      : Icons.more_vert,
                ),
              );
              await tester.pumpAndSettle();
              await tester.tap(find.text(op));
            }
            await tester.pumpAndSettle();
            expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
            expect(
              find.byType(
                platform == TargetPlatform.iOS
                    ? CupertinoAlertDialog
                    : AlertDialog,
              ),
              findsOneWidget,
            );
            final action = adaptiveDialogActions(tester).last;
            expect(action.isDestructiveAction, op == 'Delete');
            expect(action.isDefaultAction, op != 'Delete');
            if (outcome == 'cancel') {
              await tester.tap(find.text('cancel'));
            } else {
              access.statusChangeCompleter = Completer();
              action.onPressed!();
              action.onPressed!();
              await tester.pumpAndSettle();
              expect(access.requestedStatuses, [
                op == 'Delete' ? HabitStatus.deleted : HabitStatus.activated,
              ]);
              if (outcome == 'covered') {
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Other page')),
                  ),
                );
                await tester.pumpAndSettle();
              }
              access.statusChangeCompleter!.complete([]);
            }
            await tester.pumpAndSettle();
            expect(access.statusChangeCalls, outcome == 'cancel' ? 0 : 1);
            if (op == 'Delete' && outcome == 'confirm') {
              expect(pageResult?.op, DetailPageReturnOpr.deleted);
              expect(pageResult?.habitName, detail.data.name);
            } else {
              expect(pageResult, isNull);
            }
            if (outcome == 'covered') {
              expect(find.text('Other page'), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final dismiss in ['cancel', 'barrier', 'confirm', 'removed']) {
    testWidgets(
      'archive confirmation $dismiss respects lifecycle and single confirmation submission',
      (tester) async {
        final profile = await _loadProfile();
        final detail = _buildHabitDetailData();
        final access = _FakeHabitDetailAccess(seedData: detail);
        final rebuild = ValueNotifier(0);
        addTearDown(() {
          rebuild.dispose();
          profile.dispose();
        });
        await _pumpHabitDetailPage(
          tester,
          profile: profile,
          access: access,
          rebuildToken: rebuild,
          habitUUID: detail.data.uuid,
        );
        await tester.pumpAndSettle();
        final button = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.archive_outlined),
            matching: find.byType(IconButton),
          ),
        );
        final open = button.onPressed!;
        open();
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
        final dialogContext = tester.element(
          find.byType(AdaptiveConfirmDialog),
        );
        final navigator = Navigator.of(dialogContext);
        final submit = adaptiveDialogActions(tester).last.onPressed!;
        switch (dismiss) {
          case 'cancel':
            await tester.tap(find.text('cancel'));
          case 'barrier':
            await tester.tapAt(const Offset(5, 5));
          case 'confirm':
            access.statusChangeCompleter = Completer();
            submit();
            submit();
            await tester.pumpAndSettle();
            expect(access.statusChangeCalls, 1);
            open();
            await tester.pumpAndSettle();
            expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
            await tester.tap(find.text('cancel'));
            await tester.pumpAndSettle();
            expect(access.statusChangeCalls, 1);
            access.statusChangeCompleter!.complete([]);
          case 'removed':
            final pageRoute = ModalRoute.of(
              tester.element(find.byType(HabitDetailPage)),
            )!;
            navigator.removeRoute(pageRoute);
            await tester.pumpAndSettle();
            submit();
        }
        await tester.pumpAndSettle();
        expect(access.statusChangeCalls, dismiss == 'confirm' ? 1 : 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final field in ['description', 'frequency']) {
    testWidgets('retained detail updates $field after edit reload', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final profile = await _loadProfile();
      final initialData = _buildHabitDetailData();
      final updatedData = HabitDetailData(
        data: _buildHabitSummaryData(),
        modifyT: DateTime.utc(2026, 2, 2),
        dailyGoalUnit: 'times',
      );
      updatedData.data
        ..desc = 'Updated description'
        ..color = const HabitColor.builtIn(HabitColorType.cc2)
        ..startDate = initialData.data.startDate.subtractDays(7)
        ..reminder = HabitReminder.dailyMidnight
        ..frequency = const HabitFrequency.weekly(freq: 3);
      final access = _DeferredReloadHabitDetailAccess(initialData: initialData);
      final rebuildToken = ValueNotifier(0);
      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });
      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: initialData.data.uuid,
      );
      await tester.pumpAndSettle();
      final markdown = find.byType(ColorfulMarkdownBlock);
      expect(markdown, findsOneWidget);
      final retainedElement = tester.element(markdown);
      expect(find.text(initialData.data.frequency.toString()), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      final vm = tester
          .element(find.text('Sample Habit').first)
          .read<HabitDetailViewModel>();
      vm.onEditCompleted();
      await tester.pump();
      expect(tester.element(markdown), same(retainedElement));
      access.reloadCompleter.complete(updatedData);
      await tester.pumpAndSettle();
      if (field == 'description') {
        expect(
          tester.widget<ColorfulMarkdownBlock>(markdown).data,
          updatedData.data.desc,
        );
        expect(
          tester.widget<ColorfulMarkdownBlock>(markdown).color,
          updatedData.data.color,
        );
      } else {
        expect(
          find.text(updatedData.data.frequency.toString()),
          findsOneWidget,
        );
        expect(find.text(initialData.data.frequency.toString()), findsNothing);
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
        final config = tester
            .element(markdown)
            .read<AppCustomDateYmdHmsConfigViewModel>()
            .config;
        expect(
          find.text(
            config.getYMDFormatter(null).format(updatedData.data.startDate),
          ),
          findsOneWidget,
        );
        expect(
          find.text(config.getFormatter(null).format(updatedData.modifyT)),
          findsOneWidget,
        );
      }
      expect(tester.element(markdown), same(retainedElement));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'HabitDetailPage keeps a settled load stable across parent rebuilds',
    (tester) async {
      final profile = await _loadProfile();
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final rebuildToken = ValueNotifier(0);

      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });

      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: detailData.data.uuid,
      );

      expect(find.byType(PageLoadingIndicator), findsOneWidget);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));

      expect(access.loadDetailDataCallCount, 1);
      expect(find.text('Sample Habit'), findsOneWidget);
      expect(find.byType(PageLoadingIndicator), findsNothing);

      rebuildToken.value += 1;
      await tester.pump();

      expect(access.loadDetailDataCallCount, 1);
      expect(find.byType(PageLoadingIndicator), findsNothing);
    },
  );

  testWidgets('HabitDetailPage keeps existing content during reload', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final initialData = _buildHabitDetailData();
    final access = _DeferredReloadHabitDetailAccess(initialData: initialData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: initialData.data.uuid,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    final detailContext = tester.element(find.text('Sample Habit').first);
    detailContext.read<HabitDetailViewModel>().requestReload();
    await tester.pump();

    expect(access.loadDetailDataCallCount, 2);
    expect(find.byType(PageLoadingIndicator), findsNothing);
    expect(find.text('Sample Habit'), findsOneWidget);

    access.reloadCompleter.complete(
      _buildHabitDetailData(name: 'Updated Habit'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageLoadingIndicator), findsNothing);
    expect(find.text('Updated Habit'), findsOneWidget);
  });

  testWidgets('HabitDetailPage exposes reload failure and retries fresh data', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final initialData = _buildHabitDetailData();
    final access = _DeferredReloadHabitDetailAccess(initialData: initialData);
    final rebuildToken = ValueNotifier(0);
    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });
    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: initialData.data.uuid,
    );
    await tester.pumpAndSettle();
    final vm = tester
        .element(find.text('Sample Habit').first)
        .read<HabitDetailViewModel>();
    vm.onEditCompleted();
    await tester.pump();
    expect(access.loadDetailDataCallCount, 2);
    expect(find.byType(HabitHeatmap), findsOneWidget);
    access.reloadCompleter.completeError(StateError('reload failed'));
    await tester.pumpAndSettle();
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.byType(HabitHeatmap), findsNothing);

    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(access.loadDetailDataCallCount, 3);
    expect(find.text('Try Again'), findsNothing);
    expect(find.byType(HabitHeatmap), findsOneWidget);
    access.retryCompleter.complete(
      _buildHabitDetailData(name: 'Updated Habit'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Updated Habit'), findsOneWidget);
    expect(find.byType(HabitHeatmap), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'HabitDetailPage retries with a fresh load future after an error',
    (tester) async {
      final profile = await _loadProfile();
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(
        seedData: detailData,
        failLoadDetailDataCount: 1,
      );
      final rebuildToken = ValueNotifier(0);

      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });

      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: detailData.data.uuid,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));

      expect(access.loadDetailDataCallCount, 1);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(access.loadDetailDataCallCount, 2);

      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Sample Habit'), findsOneWidget);
      expect(find.text('Try Again'), findsNothing);
    },
  );

  testWidgets(
    'HabitDetailPage updates its FAB inset after portrait to landscape',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final profile = await _loadProfile();
      final detailData = _buildHabitDetailData();
      final access = _PendingHabitDetailAccess();
      final rebuildToken = ValueNotifier(0);

      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });

      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: detailData.data.uuid,
        wrapWithAdaptiveShell: true,
      );
      await tester.pump(const Duration(milliseconds: 300));

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(800 - tester.getBottomRight(fab).dy, kFloatingActionButtonMargin);

      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(400 - tester.getBottomRight(fab).dy, kFloatingActionButtonMargin);
    },
  );

  testWidgets('HabitDetailPage action menu keeps order and archive callback', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.toolbarHeight, AppAdaptiveStyle.materialToolbarHeight);
    final edit = find.byIcon(Icons.edit_rounded);
    final archive = find.byIcon(Icons.archive_outlined);
    final more = find.byIcon(Icons.more_vert);
    expect(find.byIcon(CupertinoIcons.calendar_badge_plus), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(edit, findsOneWidget);
    expect(archive, findsOneWidget);
    expect(tester.widget<Icon>(edit).color, lightCustomColors.cc1);
    expect(tester.widget<Icon>(archive).color, lightCustomColors.cc1);
    expect(tester.widget<Icon>(more).color, lightCustomColors.cc1);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(of: edit, matching: find.byType(IconButton)),
          )
          .iconSize,
      24,
    );
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(of: more, matching: find.byType(IconButton)),
          )
          .iconSize,
      24,
    );
    await tester.tap(more);
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsNothing);
    expect(find.text('Unarchive'), findsNothing);
    expect(find.text('Clone'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Archive Habit?'), findsOneWidget);
    expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
  });

  testWidgets('HabitDetailPage substitutes unarchive without other changes', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData(status: HabitStatus.archived);
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(Icons.unarchive_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Unarchive'), findsNothing);
    expect(find.text('Archive'), findsNothing);
    expect(find.text('Clone'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.unarchive_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
  });

  testWidgets('HabitDetailPage Apple actions keep 44pt targets and callbacks', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    final edit = find.byIcon(CupertinoIcons.pencil);
    final recordCalendar = find.byIcon(CupertinoIcons.calendar_badge_plus);
    final archive = find.byIcon(CupertinoIcons.archivebox);
    final more = find.byIcon(CupertinoIcons.ellipsis);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.delegate.minExtent, AppAdaptiveStyle.appleToolbarHeight);
    expect(header.delegate.maxExtent, AppAdaptiveStyle.appleToolbarHeight);
    expect(recordCalendar, findsOneWidget);
    expect(edit, findsOneWidget);
    expect(archive, findsNothing);
    expect(more, findsOneWidget);
    expect(tester.widget<Icon>(edit).color, lightCustomColors.cc1);
    expect(tester.widget<Icon>(more).color, lightCustomColors.cc1);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Check in'), findsOneWidget);
    final checkInContext = tester.element(find.text('Check in'));
    expect(
      DefaultTextStyle.of(checkInContext).style.color,
      CupertinoDynamicColor.resolve(CupertinoColors.label, checkInContext),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Check in' &&
            widget.properties.tooltip == 'Open check-in calendar',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: recordCalendar,
                  matching: find.byType(CupertinoButton),
                )
                .first,
          )
          .height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(of: edit, matching: find.byType(CupertinoButton))
                .first,
          )
          .height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(of: more, matching: find.byType(CupertinoButton))
                .first,
          )
          .height,
      greaterThanOrEqualTo(44),
    );

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(recordCalendar));
    await tester.pumpAndSettle();
    expect(find.text('Open check-in calendar'), findsOneWidget);
    await pointer.removePointer();
    await tester.pumpAndSettle();

    await tester.tap(recordCalendar);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(more);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Archive Habit?'), findsOneWidget);
    expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
  });

  testWidgets('HabitDetailPage Apple compact pins record and edit actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      wrapWithAdaptiveShell: true,
      platform: TargetPlatform.iOS,
      withAppLocalizations: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(CupertinoIcons.calendar_badge_plus), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    expect(find.text('Check in'), findsNothing);
    final appBar = tester.widget<CupertinoSliverNavigationBar>(
      find.byType(CupertinoSliverNavigationBar),
    );
    expect(appBar.largeTitle, isNotNull);
    expect(appBar.middle, isNull);
    expect(find.byIcon(CupertinoIcons.archivebox), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets(
    'HabitDetailPage Apple collapsed Sidebar keeps actions outside the capsule',
    (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final profile = await _loadProfile();
      final detailData = _buildHabitDetailData();
      final access = _FakeHabitDetailAccess(seedData: detailData);
      final rebuildToken = ValueNotifier(0);

      addTearDown(() {
        rebuildToken.dispose();
        profile.dispose();
      });

      await _pumpHabitDetailPage(
        tester,
        profile: profile,
        access: access,
        rebuildToken: rebuildToken,
        habitUUID: detailData.data.uuid,
        wrapWithAdaptiveShell: true,
        platform: TargetPlatform.iOS,
        withAppLocalizations: true,
      );
      await tester.pumpAndSettle();

      final capsule = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-capsule'),
      );
      final actions = find.byType(
        AdaptiveAppBarActions<HabitDetailAppBarAction>,
      );
      expect(capsule, findsOneWidget);
      expect(actions, findsOneWidget);
      expect(
        tester
            .widget<AdaptiveAppBarActions<HabitDetailAppBarAction>>(actions)
            .maxPrimaryActions,
        isNull,
      );
      expect(
        tester.getTopLeft(actions).dx,
        greaterThanOrEqualTo(tester.getTopRight(capsule).dx),
      );
      expect(find.byIcon(CupertinoIcons.calendar_badge_plus), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('HabitDetailPage Material compact uses a medium title', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      platform: TargetPlatform.android,
      withAppLocalizations: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.text('Sample Habit'), findsNWidgets(2));
  });

  testWidgets('HabitDetailPage overview heatmap opens the check-in dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      withAppLocalizations: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    final heatmap = find.descendant(
      of: find.byType(HabitHeatmap),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.behavior == HitTestBehavior.opaque &&
            widget.onTap != null,
      ),
    );
    expect(heatmap, findsOneWidget);
    await tester.ensureVisible(heatmap);
    await tester.pumpAndSettle();

    final dailyGoal = find.text('Goal');
    expect(dailyGoal, findsOneWidget);
    await tester.ensureVisible(dailyGoal);
    await tester.pumpAndSettle();
    await tester.tap(dailyGoal);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await tester.ensureVisible(heatmap);
    await tester.pumpAndSettle();
    await tester.tap(heatmap);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('record Heatmap keeps configured labels and cell editing', (
    tester,
  ) async {
    await initializeDateFormatting();
    final oldClock = AppClock().clock;
    AppClock().setClock(Clock(() => DateTime.utc(2026, 1, 24)));
    addTearDown(() => AppClock().setClock(oldClock));
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detail = _buildHabitDetailData();
    detail.data.startDate = HabitDate(2026, 1, 1);
    final access = _FakeHabitDetailAccess(seedData: detail);
    final rebuild = ValueNotifier(0);
    addTearDown(() {
      rebuild.dispose();
      profile.dispose();
    });
    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuild,
      habitUUID: detail.data.uuid,
      withAppLocalizations: true,
      locale: const Locale('zh'),
      dateConfig: const CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.dayMonthYear,
        splitChar: DateSplitCharEnum.dash,
        twelveHoursOn: false,
        useSystemFormat: false,
        useLeadingZero: true,
        applyHeatmapCal: true,
      ),
    );
    await tester.pumpAndSettle();
    final heatmap = find.descendant(
      of: find.byType(HabitHeatmap),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onTap != null,
      ),
    );
    await tester.ensureVisible(heatmap);
    await tester.pumpAndSettle();
    await tester.tap(heatmap);
    await tester.pumpAndSettle();
    final editor = find.byType(HabitEditReplacementRecordCalendarDialog);
    expect(editor, findsOneWidget);
    expect(
      find.descendant(of: editor, matching: find.text('01-2026')),
      findsOneWidget,
    );
    final weekLabels = find.descendant(
      of: editor,
      matching: find.byType(WeekLabelItem),
    );
    expect(weekLabels, findsNWidgets(7));
    for (final element in weekLabels.evaluate()) {
      final item = element.widget as WeekLabelItem;
      expect(
        find.descendant(
          of: find.byWidget(item),
          matching: find.text(DateFormat('ccc', 'zh').format(item.date)),
        ),
        findsOneWidget,
      );
    }
    final cell = find.descendant(
      of: editor,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is HeatmapCellItem<num> &&
            widget.date.year == 2026 &&
            widget.date.month == 1 &&
            widget.date.day == 24,
      ),
    );
    expect(cell, findsOneWidget);
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(access.recordChanges, hasLength(1));
    expect(access.recordChanges.single.date, HabitDate(2026, 1, 24));
    expect(access.recordChanges.single.date.isUtc, isTrue);
    expect(detail.data.getRecordByDate(HabitDate(2026, 1, 24))?.value, 1);

    await tester.longPress(cell);
    await tester.pumpAndSettle();
    expect(find.byType(HabitRecordCustomNumberPickerDialog), findsOneWidget);
    final input = find.descendant(
      of: find.byType(HabitRecordCustomNumberPickerDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(input, '2');
    final l10n = L10n.of(tester.element(input))!;
    await tester.tap(find.text(l10n.habitDetail_changeGoal_saveText));
    await tester.pumpAndSettle();
    expect(access.recordChanges, hasLength(2));
    expect(detail.data.getRecordByDate(HabitDate(2026, 1, 24))?.value, 2);
    expect(find.byType(HabitRecordCustomNumberPickerDialog), findsNothing);
    expect(editor, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HabitDetailPage charts tolerate rapid resize key re-entry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      platform: TargetPlatform.iOS,
      withAppLocalizations: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    for (final width in [500.0, 1000.0, 500.0, 1000.0]) {
      tester.view.physicalSize = Size(width, 2000);
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('HabitDetailPage Apple actions collapse by retention priority', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = await _loadProfile();
    final detailData = _buildHabitDetailData();
    final access = _FakeHabitDetailAccess(seedData: detailData);
    final rebuildToken = ValueNotifier(0);

    addTearDown(() {
      rebuildToken.dispose();
      profile.dispose();
    });

    await _pumpHabitDetailPage(
      tester,
      profile: profile,
      access: access,
      rebuildToken: rebuildToken,
      habitUUID: detailData.data.uuid,
      platform: TargetPlatform.iOS,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.archivebox), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.square_on_square), findsNothing);
    expect(find.byIcon(CupertinoIcons.share_up), findsNothing);
    expect(find.byIcon(CupertinoIcons.delete), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);

    tester.view.physicalSize = const Size(700, 800);
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.archivebox), findsNothing);
    expect(find.byIcon(CupertinoIcons.square_on_square), findsNothing);
    expect(find.byIcon(CupertinoIcons.share_up), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
  });
}
