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

HabitSummaryData _buildHabitSummaryData({
  String uuid = '11111111-1111-4111-8111-111111111111',
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
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(startDate.year, startDate.month, startDate.day),
  );
}

HabitDetailData _buildHabitDetailData() {
  final data = _buildHabitSummaryData();
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
        home: ValueListenableBuilder<int>(
          valueListenable: rebuildToken,
          builder: (context, _, child) => HabitDetailPage(
            habitUUID: habitUUID,
            color: const HabitColor.builtIn(HabitColorType.cc1),
          ),
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
}
