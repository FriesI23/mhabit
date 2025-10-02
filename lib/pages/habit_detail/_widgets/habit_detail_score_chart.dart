// Copyright 2023 Fries_I23
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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/types.dart';
import '../../../l10n/localizations.dart';
import '../../../model/habit_date.dart';
import '../../../model/habit_detail_chart.dart';
import 'habit_detail_chart_title.dart';

class _HabitDetailScoreChartTitle extends StatelessWidget {
  final String title;
  final HabitDetailScoreChartCombine chartCombine;
  final void Function(HabitDetailScoreChartCombine combine)? onPopMenuSelected;

  const _HabitDetailScoreChartTitle({
    this.title = '',
    required this.chartCombine,
    this.onPopMenuSelected,
  });

  String getCombineString(
      BuildContext context, HabitDetailScoreChartCombine combine) {
    switch (combine) {
      case HabitDetailScoreChartCombine.monthly:
        return L10n.of(context)?.habitDetail_scoreChartCombine_monthlyText ??
            "Month";
      case HabitDetailScoreChartCombine.yearly:
        return L10n.of(context)?.habitDetail_scoreChartCombine_yearlyText ??
            "Year";
      case HabitDetailScoreChartCombine.weekly:
        return L10n.of(context)?.habitDetail_scoreChartCombine_weeklyText ??
            "Week";
      case HabitDetailScoreChartCombine.daily:
        return L10n.of(context)?.habitDetail_scoreChartCombine_dailyText ??
            "Day";
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPopupMenu(BuildContext context) {
      return PopupMenuButton<HabitDetailScoreChartCombine>(
        icon: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(children: [
            Text(getCombineString(context, chartCombine)),
            const Icon(Icons.arrow_drop_down),
          ]),
        ),
        padding: EdgeInsets.zero,
        initialValue: chartCombine,
        onSelected: onPopMenuSelected,
        itemBuilder: (context) =>
            <PopupMenuEntry<HabitDetailScoreChartCombine>>[
          CheckedPopupMenuItem<HabitDetailScoreChartCombine>(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            checked: chartCombine == HabitDetailScoreChartCombine.daily,
            value: HabitDetailScoreChartCombine.daily,
            child: Text(
              getCombineString(context, HabitDetailScoreChartCombine.daily),
            ),
          ),
          CheckedPopupMenuItem<HabitDetailScoreChartCombine>(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            checked: chartCombine == HabitDetailScoreChartCombine.weekly,
            value: HabitDetailScoreChartCombine.weekly,
            child: Text(
              getCombineString(context, HabitDetailScoreChartCombine.weekly),
            ),
          ),
          CheckedPopupMenuItem<HabitDetailScoreChartCombine>(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            checked: chartCombine == HabitDetailScoreChartCombine.monthly,
            value: HabitDetailScoreChartCombine.monthly,
            child: Text(
              getCombineString(context, HabitDetailScoreChartCombine.monthly),
            ),
          ),
          CheckedPopupMenuItem<HabitDetailScoreChartCombine>(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            checked: chartCombine == HabitDetailScoreChartCombine.yearly,
            value: HabitDetailScoreChartCombine.yearly,
            child: Text(
              getCombineString(context, HabitDetailScoreChartCombine.yearly),
            ),
          ),
        ],
      );
    }

    return HabitDetailChartTitle(
      title: title,
      rightChild: buildPopupMenu(context),
    );
  }
}

class HabitDetailScoreChart extends StatelessWidget {
  final String? titleText;
  final EdgeInsetsGeometry padding;
  final double eachSize;
  final double allowWidth;
  final double titleHeight;
  final HabitDate Function(int limit) getFirstDate;
  final HabitDate Function(int limit) getLastDate;
  final HabitDate startDate;
  final HabitDetailScoreChartCombine chartCombine;
  final List<MapEntry<HabitDate, HabitDetailScoreChartDate>> Function(
      HabitDate firstDate, HabitDate lastDate) getData;
  final void Function(HabitDetailScoreChartCombine combine)? onPopMenuSelected;
  final HabitDetailScoreChartBuilder? chartBuilder;

  const HabitDetailScoreChart({
    super.key,
    this.titleText,
    this.padding = EdgeInsets.zero,
    required this.eachSize,
    required this.allowWidth,
    required this.titleHeight,
    required this.getFirstDate,
    required this.getLastDate,
    required this.startDate,
    required this.chartCombine,
    required this.getData,
    this.onPopMenuSelected,
    this.chartBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final TextScaler textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    final eachSize = textScaler.scale(this.eachSize);
    final limit = math.max(1, allowWidth ~/ eachSize);
    final titleHeight =
        textScaler.clamp(minScaleFactor: 1.0).scale(this.titleHeight);

    final firstDate = getFirstDate(limit);
    var lastDate = getLastDate(limit);
    lastDate = lastDate.isBefore(startDate) ? lastDate : startDate;

    final chartKey = ValueKey<String>("scoreChart"
        "|${firstDate.year}-${firstDate.month}-${firstDate.day}"
        "|${lastDate.year}-${lastDate.month}-${lastDate.day}"
        "|${chartCombine.index}");

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: titleHeight),
            child: _HabitDetailScoreChartTitle(
              title: titleText ?? l10n?.habitDetail_scoreChart_title ?? '',
              chartCombine: chartCombine,
              onPopMenuSelected: onPopMenuSelected,
            ),
          ),
          if (chartBuilder != null) const SizedBox(height: 20),
          if (chartBuilder != null)
            chartBuilder!(
              context,
              getData(firstDate, lastDate),
              eachSize,
              limit,
              chartKey,
            ),
        ],
      ),
    );
  }
}
