// Copyright 2024 Fries_I23
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

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../persistent/db_helper_provider.dart';
import '../../persistent/profile_provider.dart';
import '../../providers/app_caches.dart';
import '../../providers/app_compact_ui_switcher.dart';
import '../../providers/app_custom_date_format.dart';
import '../../providers/app_debugger.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_first_day.dart';
import '../../providers/app_language.dart';
import '../../providers/app_notify_config.dart';
import '../../providers/app_reminder.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_theme.dart';
import '../../providers/global.dart';
import '../../providers/habit_op_config.dart';
import '../../providers/habits_file_exporter.dart';
import '../../providers/habits_file_importer.dart';
import '../../reminders/notification_channel.dart';

class AppProviders extends SingleChildStatelessWidget {
  const AppProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildHabitExportModel() => [
        ChangeNotifierProvider<HabitFileExporterViewModel>(
          create: (context) => HabitFileExporterViewModel(),
        ),
        ChangeNotifierProxyProvider<DBHelperViewModel,
            HabitFileExporterViewModel>(
          create: (context) => context.read<HabitFileExporterViewModel>(),
          update: (context, value, previous) =>
              previous!..updateDBHelper(value),
        ),
      ];

  Iterable<SingleChildWidget> _buildHabitImportModel() => [
        ChangeNotifierProvider<HabitFileImporterViewModel>(
          create: (context) => HabitFileImporterViewModel(),
        ),
        ChangeNotifierProxyProvider<DBHelperViewModel,
            HabitFileImporterViewModel>(
          create: (context) => context.read<HabitFileImporterViewModel>(),
          update: (context, value, previous) =>
              previous!..updateDBHelper(value),
        ),
      ];

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          Provider<Global>(
            create: (context) => Global(),
          ),
          Provider<NotificationChannelData>(
            create: (context) => NotificationChannelData(),
          ),
          ChangeNotifierProxyProvider2<ProfileViewModel,
              NotificationChannelData, AppDebuggerViewModel>(
            lazy: false,
            create: (context) => AppDebuggerViewModel(),
            update: (context, profile, channel, previous) => previous!
              ..setNotificationChannelData(channel)
              ..updateProfile(profile),
          ),
          ProxyProvider<ProfileViewModel, AppCachesViewModel>(
            create: (context) => AppCachesViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel, AppLanguageViewModel>(
            create: (context) => AppLanguageViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel, AppThemeViewModel>(
            create: (context) => AppThemeViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel,
              AppCompactUISwitcherViewModel>(
            create: (context) => AppCompactUISwitcherViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel, AppFirstDayViewModel>(
            create: (context) => AppFirstDayViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel,
              AppCustomDateYmdHmsConfigViewModel>(
            create: (context) => AppCustomDateYmdHmsConfigViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel,
              AppNotifyConfigViewModel>(
            // Config needs to be synced with Notification Service.
            lazy: false,
            create: (context) => AppNotifyConfigViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider3<ProfileViewModel, DBHelperViewModel,
              NotificationChannelData, AppSyncViewModel>(
            create: (context) => AppSyncViewModel(),
            update: (context, profile, helper, channel, previous) => previous!
              ..updateProfile(profile)
              ..updateDBHelper(helper)
              ..setNotificationChannelData(channel),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel,
              HabitRecordOpConfigViewModel>(
            create: (context) => HabitRecordOpConfigViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider2<ProfileViewModel,
              NotificationChannelData, AppReminderViewModel>(
            lazy: false,
            create: (context) => AppReminderViewModel(),
            update: (context, profile, channel, previous) => previous!
              ..setNotificationChannelData(channel)
              ..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider<Global, AppDeveloperViewModel>(
            create: (context) =>
                AppDeveloperViewModel(global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ..._buildHabitExportModel(),
          ..._buildHabitImportModel(),
        ],
        child: child,
      );
}
