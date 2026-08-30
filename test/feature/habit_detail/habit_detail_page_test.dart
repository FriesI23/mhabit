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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_detail.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habit_detail/page.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/stub/habits_display_access.dart';

final class _FakeHabitDetailAccess extends StubHabitDetailAccess {
  final HabitDetailData seedData;
  int failLoadDetailDataCount;
  int loadDetailDataCallCount = 0;

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
}

final class _PendingHabitDetailAccess extends StubHabitDetailAccess {
  final Completer<HabitDetailData?> _completer = Completer();

  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) =>
      _completer.future;
}

HabitSummaryData _buildHabitSummaryData({
  String uuid = '11111111-1111-4111-8111-111111111111',
  HabitStatus status = HabitStatus.activated,
}) {
  final startDate = HabitDate.now().subtractDays(1);
  return HabitSummaryData(
    id: 1,
    uuid: uuid,
    type: HabitType.normal,
    name: 'Sample Habit',
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
}) {
  final data = _buildHabitSummaryData(status: status);
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
}) async {
  final customDate = AppCustomDateYmdHmsConfigViewModel()
    ..updateProfile(profile);
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
        theme: platform == null ? null : ThemeData(platform: platform),
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
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
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
    final archive = find.byIcon(CupertinoIcons.archivebox);
    final more = find.byIcon(CupertinoIcons.ellipsis);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.delegate.minExtent, AppAdaptiveStyle.appleToolbarHeight);
    expect(header.delegate.maxExtent, AppAdaptiveStyle.appleToolbarHeight);
    expect(edit, findsOneWidget);
    expect(archive, findsOneWidget);
    expect(more, findsOneWidget);
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

    await tester.tap(archive);
    await tester.pumpAndSettle();
    expect(find.text('Archive Habit?'), findsOneWidget);
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
    expect(find.byIcon(CupertinoIcons.square_on_square), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.share_up), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.delete), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);

    tester.view.physicalSize = const Size(700, 800);
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.archivebox), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.square_on_square), findsNothing);
    expect(find.byIcon(CupertinoIcons.share_up), findsNothing);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
  });
}
