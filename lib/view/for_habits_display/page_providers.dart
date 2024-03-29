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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../model/global.dart';
import '../../persistent/db_helper_provider.dart';
import '../../provider/app_first_day.dart';
import '../../provider/habit_summary.dart';
import '../../provider/habits_file_importer.dart';
import '../../provider/habits_filter.dart';
import '../../provider/habits_record_scroll_behavior.dart';
import '../../provider/habits_sort.dart';
import '../../reminders/notification_channel.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildPageViewModel() sync* {
    yield ChangeNotifierProvider<HabitSummaryViewModel>(
      create: (context) => HabitSummaryViewModel(
        verticalScrollController: ScrollController(),
        horizonalScrollControllerGroup: LinkedScrollControllerGroup(),
      ),
    );

    yield ChangeNotifierProxyProvider<DBHelperViewModel, HabitSummaryViewModel>(
      create: (context) => context.read<HabitSummaryViewModel>(),
      update: (context, value, previous) => previous!..updateDBHelper(value),
    );

    yield ChangeNotifierProxyProvider2<HabitsSortViewModel,
        HabitsFilterViewModel, HabitSummaryViewModel>(
      create: (context) => context.read<HabitSummaryViewModel>(),
      update: (context, sortOptions, habitDisplayFilter, previous) {
        previous!
            .updateSortOptions(sortOptions.sortType, sortOptions.sortDirection);
        previous
            .updateHabitDisplayFilter(habitDisplayFilter.habitsDisplayFilter);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          previous.resortData();
        });
        return previous;
      },
    );

    yield ChangeNotifierProxyProvider<HabitFileImporterViewModel,
        HabitSummaryViewModel>(
      create: (context) => context.read<HabitSummaryViewModel>(),
      update: (context, value, previous) {
        if (value.consumeReloadDisplayFlag()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            previous!.rockreloadDBToggleSwich();
          });
        }
        return previous!;
      },
    );

    yield ChangeNotifierProxyProvider<AppFirstDayViewModel,
        HabitSummaryViewModel>(
      create: (context) => context.read<HabitSummaryViewModel>(),
      update: (context, value, previous) {
        if (value.firstDay != previous!.firstday) {
          previous.updateFirstday(value.firstDay);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            previous.rockreloadDBToggleSwich();
          });
        }
        return previous;
      },
    );

    yield ChangeNotifierProxyProvider<NotificationChannelData,
        HabitSummaryViewModel>(
      create: (context) => context.read<HabitSummaryViewModel>(),
      update: (context, value, previous) =>
          previous!..setNotificationChannelData(value),
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          ChangeNotifierProxyProvider<Global, HabitsSortViewModel>(
            create: (context) =>
                HabitsSortViewModel(global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ChangeNotifierProxyProvider<Global, HabitsFilterViewModel>(
            create: (context) =>
                HabitsFilterViewModel(global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ChangeNotifierProxyProvider<Global,
              HabitsRecordScrollBehaviorViewModel>(
            create: (context) => HabitsRecordScrollBehaviorViewModel(
                global: context.read<Global>()),
            update: (context, value, previous) =>
                previous!..updateGlobal(value),
          ),
          ..._buildPageViewModel(),
        ],
        child: child,
      );
}
