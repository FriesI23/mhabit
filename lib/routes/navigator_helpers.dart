// Copyright 2026 Fries_I23
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

import '../common/types.dart';
import '../models/habit_color.dart';
import '../models/habit_form.dart';
import '../pages/app_about/page.dart' as app_about;
import '../pages/app_debugger/page.dart' as app_debugger;
import '../pages/app_notify_config/page.dart' as app_notify_config;
import '../pages/app_settings/page.dart' as app_settings;
import '../pages/app_sync/page.dart' as app_sync;
import '../pages/expermental_features/page.dart' as exp_feature;
import '../pages/group_manage/page.dart' as group_manage;
import '../pages/habit_detail/page.dart' as habit_detail;
import '../pages/habit_edit/page.dart' as habit_edit;
import '../pages/habits_display/providers.dart' show HabitDetailAdapter;
import '../pages/habits_status_changer/page.dart' as habits_status_changer;
import '../storage/db/handlers/habit.dart';
import 'helpers/habit_detail_helper.dart';

Future<HabitDBCell?> naviToHabitEidtPage({
  required BuildContext context,
  required HabitForm initForm,
  bool? naviWithFullscreenDialog,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: naviWithFullscreenDialog ?? true,
    builder: (context) => habit_edit.HabitEditPage(
      initForm: initForm,
      showInFullscreenDialog: false,
    ),
  ),
);

Future<habit_detail.DetailPageReturn?> naviToHabitDetailPage({
  required BuildContext context,
  required HabitUUID habitUUID,
  HabitColor? color,
  HabitDetailAdapter? adapter,
}) => context.pushHabitDetail(
  habitUUID: habitUUID,
  color: color,
  adapter: adapter,
);

Future<void> naviToAppSettingPage({required BuildContext context}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const app_settings.AppSettingPage(),
      ),
    );

Future<void> naviToAppAboutPage({required BuildContext context}) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const app_about.AppAboutPage()),
    );

Future<void> naviToGroupManagePage({
  required BuildContext context,
  String? initialGroupUUID,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) =>
        group_manage.GroupManagePage(initialGroupUUID: initialGroupUUID),
  ),
);

Future<void> naviToAppSyncPage({required BuildContext context}) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (context) => const app_sync.AppSyncPage()));

Future<void> naviToNotifyConfigPage({required BuildContext context}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const app_notify_config.AppNotifyConfigPage(),
      ),
    );

Future<void> naviToAppDebuggerPage({required BuildContext context}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const app_debugger.AppDebuggerPage(),
        settings: const RouteSettings(
          name: app_debugger.AppDebuggerPage.routerName,
        ),
      ),
    );

Future<void> naviToExperimentalFeaturesPage({required BuildContext context}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const exp_feature.ExpermentalFeaturesPage(),
      ),
    );

Future<void> naviToHabitsStatusChangerPage({
  required BuildContext context,
  required List<HabitUUID> uuidList,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) =>
        habits_status_changer.HabitsStatusChangerPage(uuidList: uuidList),
  ),
);
