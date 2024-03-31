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

import '../../l10n/localizations.dart';
import '../../model/global.dart';
import '../../persistent/db_helper_provider.dart';
import '../../persistent/profile_provider.dart';
import '../../provider/app_compact_ui_switcher.dart';
import '../../provider/app_custom_date_format.dart';
import '../../provider/app_developer.dart';
import '../../provider/app_first_day.dart';
import '../../provider/app_reminder.dart';
import '../../provider/app_theme.dart';
import '../../provider/habit_op_config.dart';
import '../../provider/habits_file_exporter.dart';
import '../../provider/habits_file_importer.dart';
import '../../reminders/notification_channel.dart';

class AppProviders extends SingleChildStatelessWidget {
  const AppProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildHabitExportModel() sync* {
    yield ChangeNotifierProvider<HabitFileExporterViewModel>(
      create: (context) => HabitFileExporterViewModel(),
    );
    yield ChangeNotifierProxyProvider<DBHelperViewModel,
        HabitFileExporterViewModel>(
      create: (context) => context.read<HabitFileExporterViewModel>(),
      update: (context, value, previous) => previous!..updateDBHelper(value),
    );
  }

  Iterable<SingleChildWidget> _buildHabitImportModel() sync* {
    yield ChangeNotifierProvider<HabitFileImporterViewModel>(
      create: (context) => HabitFileImporterViewModel(),
    );
    yield ChangeNotifierProxyProvider<DBHelperViewModel,
        HabitFileImporterViewModel>(
      create: (context) => context.read<HabitFileImporterViewModel>(),
      update: (context, value, previous) => previous!..updateDBHelper(value),
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          Provider<Global>(
            create: (context) => Global(),
          ),
          ChangeNotifierProvider<NotificationChannelData>(
            create: (context) => NotificationChannelData(),
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
          ChangeNotifierProxyProvider<Global, AppFirstDayViewModel>(
            create: (context) =>
                AppFirstDayViewModel(global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ChangeNotifierProxyProvider<Global,
              AppCustomDateYmdHmsConfigViewModel>(
            create: (context) => AppCustomDateYmdHmsConfigViewModel(
                global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ChangeNotifierProxyProvider<ProfileViewModel,
              HabitRecordOpConfigViewModel>(
            create: (context) => HabitRecordOpConfigViewModel(),
            update: (context, profile, previous) =>
                previous!..updateProfile(profile),
          ),
          ChangeNotifierProxyProvider2<Global, NotificationChannelData,
              AppReminderViewModel>(
            lazy: false,
            create: (context) =>
                AppReminderViewModel(global: context.read<Global>()),
            update: (context, global, channel, previous) => previous!
              ..updateGlobal(global)
              ..setNotificationChannelData(channel, l10n: L10n.of(context)),
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
