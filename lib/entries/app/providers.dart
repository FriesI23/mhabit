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

import '../../providers/app_ui/app_caches.dart';
import '../../providers/app_ui/app_compact_ui_switcher.dart';
import '../../providers/app_ui/app_custom_date_format.dart';
import '../../providers/app_ui/app_debugger.dart';
import '../../providers/app_ui/app_developer.dart';
import '../../providers/app_ui/app_experimental_feature.dart';
import '../../providers/app_ui/app_first_day.dart';
import '../../providers/app_ui/app_language.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../providers/app_ui/app_theme.dart';
import '../../providers/app_ui/custom_color_history.dart';
import '../../providers/app_ui/group_expand_timer_config.dart';
import '../../providers/app_ui/habit_op_config.dart';
import '../../providers/app_ui/habits_record_scroll_behavior.dart';
import '../../providers/support/animation_scale_sync.dart';
import '../../providers/support/global.dart';
import '../../providers/workflow/app_event.dart';
import '../../providers/workflow/app_notify_config.dart';
import '../../providers/workflow/app_reminder.dart';
import '../../providers/workflow/app_sync.dart';
import '../../providers/workflow/group_manager.dart';
import '../../providers/workflow/habits_file_exporter.dart';
import '../../providers/workflow/habits_file_importer.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../providers/workflow/thirdparty_file_importer.dart';
import '../../reminders/notification_channel.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/profile_provider.dart';
import '../../widgets/provider.dart';

class AppProviders extends SingleChildStatelessWidget {
  const AppProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildCommonAppProviders() => [
    Provider<Global>(create: (context) => Global()),
    Provider<NotificationChannelData>(
      create: (context) => NotificationChannelData(),
    ),
    ChangeNotifierProvider<AppEventBus>(create: (context) => AppEventBus()),
    ChangeNotifierProvider<AnimationScaleSync>(
      lazy: false,
      create: (context) => AnimationScaleSync.create(),
    ),
  ];

  Iterable<SingleChildWidget> _buildReminderWorkflowSupportProviders() => [
    ViewModelProxyProvider<ProfileViewModel, AppNotifyConfigAccess>(
      // Config needs to be synced with Notification Service.
      lazy: false,
      create: (context) => AppNotifyConfigAccess(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
  ];

  Iterable<SingleChildWidget> _buildHabitsAppProviders() => [
    ProxyProvider3<
      DBHelperViewModel,
      NotificationChannelData,
      AppNotifyConfigAccess,
      HabitsManager
    >(
      create: (context) => HabitsManager(),
      update: (context, db, channel, notifyConfig, previous) =>
          (previous ?? HabitsManager())
            ..attachNotifyConfig(notifyConfig)
            ..updateDBHelper(db)
            ..setNotificationChannelData(channel),
    ),
    ProxyProvider<HabitsManager, HabitsDisplayAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<HabitsManager, HabitDetailAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<HabitsManager, HabitFormAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<HabitsManager, HabitStatusChangerAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<HabitsManager, HabitExportAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<HabitsManager, HabitImportAccess>(
      update: (context, value, previous) => value,
    ),
  ];

  Iterable<SingleChildWidget> _buildGroupAppProviders() => [
    ProxyProvider<DBHelperViewModel, GroupManager>(
      create: (context) => GroupManager(),
      update: (context, db, previous) =>
          (previous ?? GroupManager())..updateDBHelper(db),
    ),
    ProxyProvider<GroupManager, GroupExportAccess>(
      update: (context, value, previous) => value,
    ),
    ProxyProvider<GroupManager, GroupImportAccess>(
      update: (context, value, previous) => value,
    ),
  ];

  Iterable<SingleChildWidget> _buildAppSyncProviders() => [
    ViewModelProxyProvider3<
      ProfileViewModel,
      DBHelperViewModel,
      NotificationChannelData,
      AppSyncOwner
    >(
      create: (context) => AppSyncOwner(),
      update: (context, profile, helper, channel, previous) => previous
        ..updateProfile(profile)
        ..updateDBHelper(helper)
        ..setNotificationChannelData(channel),
    ),
    ListenableProxyProvider<AppSyncOwner, AppSyncSettingsAccess>(
      create: (context) => context.read<AppSyncOwner>(),
      update: (context, value, previous) => value,
    ),
    ListenableProxyProvider<AppSyncOwner, AppSyncWorkflowAccess>(
      create: (context) => context.read<AppSyncOwner>(),
      update: (context, value, previous) => value,
    ),
    ListenableProxyProvider<AppSyncWorkflowAccess, AppSyncTriggerAccess>(
      create: (context) => context.read<AppSyncWorkflowAccess>(),
      update: (context, value, previous) => value,
    ),
    ListenableProxyProvider<AppSyncWorkflowAccess, AppSyncStatusSource>(
      create: (context) => context.read<AppSyncWorkflowAccess>(),
      update: (context, value, previous) => value,
    ),
  ];

  Iterable<SingleChildWidget> _buildRootAdjacentSupportProviders() => [
    ViewModelProxyProvider<Global, AppDeveloperViewModel>(
      create: (context) =>
          AppDeveloperViewModel(global: context.read<Global>()),
      update: (context, value, previous) => previous..updateGlobal(value),
    ),
    ViewModelProxyProvider<HabitExportAccess, HabitFileExportRunner>(
      create: (context) => HabitFileExportRunner(),
      update: (context, value, previous) => previous..attachAccess(value),
    ),
    ViewModelProxyProvider<GroupExportAccess, HabitFileExportRunner>(
      update: (context, value, previous) => previous..attachGroupAccess(value),
    ),
    ViewModelProxyProvider<HabitImportAccess, HabitFileImportRunner>(
      create: (context) => HabitFileImportRunner(),
      update: (context, value, previous) => previous..attachAccess(value),
    ),
    ViewModelProxyProvider<GroupImportAccess, HabitFileImportRunner>(
      update: (context, value, previous) => previous..attachGroupAccess(value),
    ),
    ChangeNotifierProvider<ThirdPartyImportOwner>(
      create: (context) => ThirdPartyImportOwner(),
    ),
  ];

  Iterable<SingleChildWidget> _buildProfileBackedAppProviders() => [
    ViewModelProxyProvider2<
      ProfileViewModel,
      NotificationChannelData,
      AppDebuggerViewModel
    >(
      lazy: false,
      create: (context) => AppDebuggerViewModel(),
      update: (context, profile, channel, previous) => previous
        ..setNotificationChannelData(channel)
        ..updateProfile(profile),
    ),
    ProxyProvider<ProfileViewModel, AppCachesViewModel>(
      create: (context) => AppCachesViewModel(),
      update: (context, profile, previous) =>
          (previous ?? AppCachesViewModel())..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppExperimentalFeatureViewModel>(
      create: (context) => AppExperimentalFeatureViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppLanguageViewModel>(
      create: (context) => AppLanguageViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppLaunchEntryViewModel>(
      create: (context) => AppLaunchEntryViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppThemeViewModel>(
      create: (context) => AppThemeViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppCompactUISwitcherViewModel>(
      create: (context) => AppCompactUISwitcherViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, AppFirstDayViewModel>(
      create: (context) => AppFirstDayViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, CustomColorHistoryViewModel>(
      create: (context) => CustomColorHistoryViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<
      ProfileViewModel,
      AppCustomDateYmdHmsConfigViewModel
    >(
      create: (context) => AppCustomDateYmdHmsConfigViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, HabitRecordOpConfigViewModel>(
      create: (context) => HabitRecordOpConfigViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider<ProfileViewModel, GroupExpandTimerConfigViewModel>(
      create: (context) => GroupExpandTimerConfigViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
    ViewModelProxyProvider3<
      ProfileViewModel,
      NotificationChannelData,
      AppNotifyConfigAccess,
      AppReminderOwner
    >(
      lazy: false,
      create: (context) => AppReminderOwner(),
      update: (context, profile, channel, notifyConfig, previous) => previous
        ..attachNotifyConfig(notifyConfig)
        ..setNotificationChannelData(channel)
        ..updateProfile(profile),
    ),
    ListenableProxyProvider<AppReminderOwner, AppReminderAccess>(
      create: (context) => context.read<AppReminderOwner>(),
      update: (context, value, previous) => value,
    ),
    ViewModelProxyProvider<AppReminderAccess, AppReminderViewModel>(
      create: (context) => AppReminderViewModel(),
      update: (context, access, previous) => previous..attachAccess(access),
    ),
    ViewModelProxyProvider<
      ProfileViewModel,
      HabitsRecordScrollBehaviorViewModel
    >(
      create: (context) => HabitsRecordScrollBehaviorViewModel(),
      update: (context, profile, previous) => previous..updateProfile(profile),
    ),
  ];

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ..._buildCommonAppProviders(),
      ..._buildReminderWorkflowSupportProviders(),
      ..._buildHabitsAppProviders(),
      ..._buildGroupAppProviders(),
      ..._buildProfileBackedAppProviders(),
      ..._buildAppSyncProviders(),
      ..._buildRootAdjacentSupportProviders(),
    ],
    child: child,
  );
}
