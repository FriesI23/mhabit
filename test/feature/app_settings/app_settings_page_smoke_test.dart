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
import 'package:mhabit/pages/app_settings/page.dart';
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
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeAppSyncAccess extends ChangeNotifier
    implements AppSyncTriggerAccess, AppSyncStatusSource {
  @override
  bool get canStartSync => true;

  @override
  AppSyncStatusSnapshot? get syncStatus => null;

  @override
  Future<void> startSync({Duration? initWait}) async {}

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}

  @override
  void cancelSync() {}
}

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel(const []);
  await profile.init();
  return profile;
}

void main() {
  testWidgets('AppSettingPage opens without provider runtime errors', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final dbHelper = DBHelperViewModel();
    final syncAccess = _FakeAppSyncAccess();

    final customDate = AppCustomDateYmdHmsConfigViewModel()
      ..updateProfile(profile);
    final firstDay = AppFirstDayViewModel()..updateProfile(profile);
    final compactUi = AppCompactUISwitcherViewModel()..updateProfile(profile);
    final developer = AppDeveloperViewModel(global: Global());
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
          ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
          ChangeNotifierProvider<DBHelperViewModel>.value(value: dbHelper),
          ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
            value: customDate,
          ),
          ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
          ChangeNotifierProvider<AppCompactUISwitcherViewModel>.value(
            value: compactUi,
          ),
          ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
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
        child: const MaterialApp(home: AppSettingPage()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Settings'), findsOneWidget);
  });
}
