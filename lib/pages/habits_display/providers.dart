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

import '../../providers/app_event.dart';
import '../../providers/app_first_day.dart';
import '../../providers/app_sync.dart';
import '../../providers/habit_summary.dart';
import '../../providers/habits_filter.dart';
import '../../providers/habits_manager.dart';
import '../../providers/habits_sort.dart';
import '../../providers/habits_today.dart';
import '../../reminders/notification_channel.dart';
import '../../storage/profile_provider.dart';
import '../../widgets/provider.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildPageViewModel() => [
        ChangeNotifierProvider<HabitSummaryViewModel>(
            create: (context) => HabitSummaryViewModel()),
        ViewModelProxyProvider<HabitsManager, HabitSummaryViewModel>(
            update: (context, value, previous) =>
                previous..updateHabitManager(value)),
        ViewModelProxyProvider<AppEventViewModel, HabitSummaryViewModel>(
            update: (context, value, previous) =>
                previous..updateAppEvent(value)),
        ViewModelProxyProvider<AppSyncViewModel, HabitSummaryViewModel>(
            update: (context, value, previous) =>
                previous..updateAppSync(value)),
        ViewModelProxyProvider2<HabitsSortViewModel, HabitsFilterViewModel,
                HabitSummaryViewModel>(
            update: (context, sortOptions, habitDisplayFilter, previous) =>
                previous
                  ..updateSortOptions(
                      sortOptions.sortType, sortOptions.sortDirection)
                  ..updateHabitDisplayFilter(
                      habitDisplayFilter.habitsDisplayFilter),
            post: (t, _, __, vm) => vm.resortData()),
        ViewModelProxyProvider<AppFirstDayViewModel, HabitSummaryViewModel>(
            update: (context, value, previous) =>
                previous..updateFirstday(value.firstDay),
            post: (t, value, vm) =>
                value.firstDay != vm.firstday ? vm.requestReload() : null),
        ViewModelProxyProvider<NotificationChannelData, HabitSummaryViewModel>(
            update: (context, value, previous) =>
                previous..setNotificationChannelData(value)),
      ];

  Iterable<SingleChildWidget> _buildTodayViewModel() => [
        ChangeNotifierProvider<HabitsTodayViewModel>(
            create: (context) => HabitsTodayViewModel()),
        ViewModelProxyProvider<HabitsManager, HabitsTodayViewModel>(
            update: (context, value, previous) =>
                previous..updateHabitManager(value)),
        ViewModelProxyProvider<AppEventViewModel, HabitsTodayViewModel>(
            update: (context, value, previous) =>
                previous..updateAppEvent(value)),
        ViewModelProxyProvider<AppSyncViewModel, HabitsTodayViewModel>(
            update: (context, value, previous) =>
                previous..updateAppSync(value)),
        ViewModelProxyProvider<HabitsSortViewModel, HabitsTodayViewModel>(
            update: (context, sortOptions, previous) => previous
              ..updateSortOptions(
                  sortOptions.sortType, sortOptions.sortDirection),
            post: (t, _, vm) => vm.resortData()),
        ViewModelProxyProvider<AppFirstDayViewModel, HabitsTodayViewModel>(
            update: (context, value, previous) =>
                previous..updateFirstday(value.firstDay),
            post: (t, value, vm) =>
                value.firstDay != vm.firstday ? vm.requestReload() : null),
      ];

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          ViewModelProxyProvider<ProfileViewModel, HabitsSortViewModel>(
              create: (context) => HabitsSortViewModel(),
              update: (context, profile, previous) =>
                  previous..updateProfile(profile)),
          ViewModelProxyProvider<ProfileViewModel, HabitsFilterViewModel>(
              create: (context) => HabitsFilterViewModel(),
              update: (context, profile, previous) =>
                  previous..updateProfile(profile)),
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
