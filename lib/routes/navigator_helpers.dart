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
import 'package:go_router/go_router.dart';

import '../common/types.dart';
import '../models/habit_color.dart';
import '../models/habit_display.dart';
import '../models/habit_form.dart';
import '../pages/habit_detail/page.dart' as habit_detail;
import '../pages/habits_display/providers.dart' show HabitDetailAdapter;
import '../storage/db/handlers/habit.dart';
import 'app_router.dart';
import 'helpers/group_manage_helper.dart';
import 'helpers/habit_create_helper.dart';
import 'helpers/habit_detail_helper.dart';
import 'helpers/habit_edit_helper.dart';
import 'helpers/habits_status_changer_helper.dart';

Future<HabitDBCell?> naviToHabitCreatePage({
  required BuildContext context,
  HabitForm? initForm,
}) => context.pushHabitCreate(initForm: initForm);

Future<HabitDBCell?> naviToHabitEditPage({
  required BuildContext context,
  required HabitForm initForm,
}) {
  assert(
    initForm.editMode == HabitDisplayEditMode.edit,
    'naviToHabitEditPage called with editMode=${initForm.editMode}',
  );
  return context.pushHabitEdit(
    habitId: initForm.editParams!.uuid,
    initForm: initForm,
  );
}

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
    context.pushNamed(AppRoute.settings.name);

Future<void> naviToAppAboutPage({required BuildContext context}) =>
    context.pushNamed(AppRoute.settingsAbout.name);

Future<void> naviToGroupManagePage({
  required BuildContext context,
  String? selectedGroupId,
}) => context.pushGroupManage(selectedGroupId: selectedGroupId);

Future<void> naviToAppSyncPage({required BuildContext context}) =>
    context.pushNamed(AppRoute.settingsSync.name);

Future<void> naviToNotifyConfigPage({required BuildContext context}) =>
    context.pushNamed(AppRoute.settingsNotify.name);

Future<void> naviToAppDebuggerPage({required BuildContext context}) =>
    context.pushNamed(AppRoute.debugger.name);

Future<void> naviToExperimentalFeaturesPage({required BuildContext context}) =>
    context.pushNamed(AppRoute.experimental.name);

Future<void> naviToHabitsStatusChangerPage({
  required BuildContext context,
  required List<HabitUUID> uuidList,
}) => context.pushHabitsStatusChanger(uuidList: uuidList);
