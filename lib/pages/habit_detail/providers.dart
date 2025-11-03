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

import '../../providers/app_first_day.dart';
import '../../providers/habit_detail.dart';
import '../../providers/habit_detail_freqchart.dart';
import '../../providers/habit_detail_scorechart.dart';
import '../../providers/habits_manager.dart';
import '../../reminders/notification_channel.dart';
import '../../storage/db_helper_provider.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  Iterable<SingleChildWidget> _buildPageViewModel() => [
        ChangeNotifierProvider<HabitDetailViewModel>(
          create: (context) => HabitDetailViewModel(),
        ),
        ChangeNotifierProxyProvider<DBHelperViewModel, HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) =>
              previous!..updateDBHelper(value),
        ),
        ChangeNotifierProxyProvider<HabitsManager, HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) =>
              previous!..updateHabitManager(value),
        ),
        ChangeNotifierProxyProvider<AppFirstDayViewModel, HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) {
            if (value.firstDay != previous!.firstday) {
              previous.updateFirstday(value.firstDay);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                previous.requestReload();
              });
            }
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<NotificationChannelData,
            HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) =>
              previous!..setNotificationChannelData(value),
        ),
      ];

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          ..._buildPageViewModel(),
          ChangeNotifierProxyProvider<HabitDetailViewModel,
              HabitDetailFreqChartViewModel>(
            create: (context) => HabitDetailFreqChartViewModel(),
            update: (context, value, previous) {
              final version = value.getInsideVersion();
              if (previous == null || !previous.isInited) {
                return (previous ?? HabitDetailFreqChartViewModel())
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.freqChartCombine,
                    iter: value.getRecordFreqChartDatas().entries,
                    isFreqChartExpanded: false,
                    offset: 0,
                    firstday: value.firstday,
                  );
              } else if (previous.chartCombine != value.freqChartCombine) {
                return HabitDetailFreqChartViewModel()
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.freqChartCombine,
                    iter: value.getRecordFreqChartDatas().entries,
                    isFreqChartExpanded: previous.isChartExpanded,
                    offset: 0,
                    firstday: value.firstday,
                  );
              } else if (previous.parentVersion != version) {
                return HabitDetailFreqChartViewModel()
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.freqChartCombine,
                    iter: value.getRecordFreqChartDatas().entries,
                    isFreqChartExpanded: previous.isChartExpanded,
                    offset: previous.offset,
                    firstday: value.firstday,
                  );
              } else {
                return previous;
              }
            },
          ),
          ChangeNotifierProxyProvider<HabitDetailViewModel,
              HabitDetailScoreChartViewModel>(
            create: (context) => HabitDetailScoreChartViewModel(),
            update: (context, value, previous) {
              final version = value.getInsideVersion();
              if (previous == null || !previous.isInited) {
                return (previous ?? HabitDetailScoreChartViewModel())
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.scoreChartCombine,
                    iter: value.getRecordScoreChartDatas().entries,
                    firstday: value.firstday,
                  );
              } else if (previous.chartCombine != value.scoreChartCombine) {
                return HabitDetailScoreChartViewModel()
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.scoreChartCombine,
                    iter: value.getRecordScoreChartDatas().entries,
                    firstday: value.firstday,
                  );
              } else if (previous.parentVersion != version) {
                return HabitDetailScoreChartViewModel()
                  ..initState(
                    parentVersion: version,
                    chartCombine: value.scoreChartCombine,
                    iter: value.getRecordScoreChartDatas().entries,
                    firstday: value.firstday,
                  );
              } else {
                return previous;
              }
            },
          ),
        ],
        child: child,
      );
}
