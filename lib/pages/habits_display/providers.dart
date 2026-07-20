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

import '../../providers/app_ui/app_experimental_feature.dart';
import '../../providers/app_ui/app_first_day.dart';
import '../../providers/app_ui/habits_filter.dart';
import '../../providers/app_ui/habits_sort.dart';
import '../../providers/workflow/app_event.dart';
import '../../providers/workflow/app_sync.dart';
import '../../providers/workflow/group_manager.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../storage/profile_provider.dart';
import '../../widgets/provider.dart';
import '_providers/habit_summary.dart';
import '_providers/habits_grouping.dart';
import '_providers/habits_today.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildPageViewModel() => [
    ChangeNotifierProvider<HabitSummaryViewModel>(
      create: (context) => HabitSummaryViewModel(),
    ),
    ViewModelProxyProvider<GroupManager, HabitSummaryViewModel>(
      update: (context, value, previous) => previous..attachGroupManager(value),
    ),
    ViewModelProxyProvider<HabitsDisplayAccess, HabitSummaryViewModel>(
      update: (context, value, previous) => previous..attachAccess(value),
    ),
    ViewModelProxyProvider<AppEventBus, HabitSummaryViewModel>(
      update: (context, value, previous) => previous..updateAppEvent(value),
    ),
    ViewModelProxyProvider<AppSyncWorkflowAccess, HabitSummaryViewModel>(
      update: (context, value, previous) => previous..attachWorkflow(value),
    ),
    ViewModelProxyProvider2<
      HabitsSortViewModel,
      HabitsFilterViewModel,
      HabitSummaryViewModel
    >(
      update: (context, sortOptions, habitDisplayFilter, previous) => previous
        ..updateSortOptions(sortOptions.sortType, sortOptions.sortDirection)
        ..updateHabitDisplayFilter(habitDisplayFilter.habitsDisplayFilter),
      post: (t, _, _, vm) => vm.resortData(),
    ),
    ViewModelProxyProvider<HabitsGroupingViewModel, HabitSummaryViewModel>(
      update: (context, value, previous) {
        previous.updateGroupingEnabled(value.isGroupingEnabled);
        final groupType = value.groupType;
        if (groupType != null) {
          previous.updateGroupOptions(groupType, value.groupDirection);
        }
        return previous;
      },
      post: (t, _, vm) => vm.resortData(),
    ),
    ViewModelProxyProvider<AppFirstDayViewModel, HabitSummaryViewModel>(
      update: (context, value, previous) =>
          previous..updateFirstday(value.firstDay),
      post: (t, value, vm) =>
          value.firstDay != vm.firstday ? vm.requestReload() : null,
    ),
  ];

  Iterable<SingleChildWidget> _buildTodayViewModel() => [
    ChangeNotifierProvider<HabitsTodayViewModel>(
      create: (context) => HabitsTodayViewModel(),
    ),
    ViewModelProxyProvider<HabitsDisplayAccess, HabitsTodayViewModel>(
      update: (context, value, previous) => previous..attachAccess(value),
    ),
    ViewModelProxyProvider<AppEventBus, HabitsTodayViewModel>(
      update: (context, value, previous) => previous..updateAppEvent(value),
    ),
    ViewModelProxyProvider<AppSyncWorkflowAccess, HabitsTodayViewModel>(
      update: (context, value, previous) => previous..attachWorkflow(value),
    ),
    ViewModelProxyProvider<HabitsSortViewModel, HabitsTodayViewModel>(
      update: (context, sortOptions, previous) => previous
        ..updateSortOptions(sortOptions.sortType, sortOptions.sortDirection),
      post: (t, _, vm) => vm.resortData(),
    ),
    ViewModelProxyProvider<AppFirstDayViewModel, HabitsTodayViewModel>(
      update: (context, value, previous) =>
          previous..updateFirstday(value.firstDay),
      post: (t, value, vm) =>
          value.firstDay != vm.firstday ? vm.requestReload() : null,
    ),
  ];

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ViewModelProxyProvider<ProfileViewModel, HabitsSortViewModel>(
        create: (context) => HabitsSortViewModel(),
        update: (context, profile, previous) =>
            previous..updateProfile(profile),
      ),
      ViewModelProxyProvider<ProfileViewModel, HabitsFilterViewModel>(
        create: (context) => HabitsFilterViewModel(),
        update: (context, profile, previous) =>
            previous..updateProfile(profile),
      ),
      ViewModelProxyProvider<ProfileViewModel, HabitsGroupingViewModel>(
        create: (context) => HabitsGroupingViewModel(),
        update: (context, profile, previous) =>
            previous..updateProfile(profile),
      ),
      ViewModelProxyProvider<
        AppExperimentalFeatureViewModel,
        HabitsGroupingViewModel
      >(
        update: (context, experimental, previous) =>
            previous..updateExperimentalGrouping(experimental.habitGrouping),
        post: (t, _, vm) => vm.requestReload(),
      ),
      ..._buildPageViewModel(),
      ..._buildTodayViewModel(),
    ],
    builder: (context, child) {
      context.read<HabitSummaryViewModel>().loadData();
      return child!;
    },
    child: child,
  );
}
