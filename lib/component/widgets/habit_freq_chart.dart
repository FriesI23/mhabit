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

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/types.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../model/habit_date.dart';
import '../../model/habit_detail_chart.dart';

const kHabitFreqChartBarWidth = 16.0;
const kHabitFreqChartEachSize = 42.0;
const kHabitFreqChartTopRadius =
    BorderRadius.vertical(top: Radius.circular(2.0));

enum HabitFreqChartDisplayMethod { count, value }

class HabitFreqChart extends StatelessWidget {
  final double height;
  final double eachSize;
  final double barWidth;
  final double barSpaceBetween;
  final bool showTipsTop;
  final TextStyle? bottomTipsTextStyle;
  final Map<HabitDailyGoal, Color> colorMap;
  final HabitDetailFreqChartCombine combine;
  final List<MapEntry<HabitDate, HabitDetailFreqChartData>> data;
  final HabitFreqChartDisplayMethod displayMethod;

  const HabitFreqChart({
    super.key,
    required this.height,
    this.eachSize = kHabitFreqChartEachSize,
    this.barWidth = kHabitFreqChartBarWidth,
    this.barSpaceBetween = 1.0,
    this.showTipsTop = true,
    this.bottomTipsTextStyle,
    required this.colorMap,
    required this.combine,
    required this.data,
    this.displayMethod = HabitFreqChartDisplayMethod.count,
  });

  double get rightTitleWidth => eachSize / 2;

  double get rightTitleInterval {
    switch (combine) {
      case HabitDetailFreqChartCombine.monthly:
        return 6;
      case HabitDetailFreqChartCombine.yearly:
        return 50;
      case HabitDetailFreqChartCombine.weekly:
        return 2;
    }
  }

  List<BarChartGroupData> _buildBarGroupListWithCount() {
    final result = <BarChartGroupData>[];
    data.forEachIndexed((i, e) {
      final record = e.value, index = data.length - i - 1;

      final barRods = <BarChartRodData>[
        if (record.overfulfil > 0)
          BarChartRodData(
            toY: record.overfulfil.toDouble(),
            color: colorMap[HabitHeatMapColorMapDefine.overfulfil],
            width: barWidth,
            borderRadius: kHabitFreqChartTopRadius,
          ),
        if (record.complate > 0)
          BarChartRodData(
            toY: record.complate.toDouble(),
            color: colorMap[HabitHeatMapColorMapDefine.complate],
            width: barWidth,
            borderRadius: kHabitFreqChartTopRadius,
          ),
        if (record.autoComplate > 0)
          BarChartRodData(
            toY: record.autoComplate.toDouble(),
            color: colorMap[HabitHeatMapColorMapDefine.autoComplate],
            width: barWidth,
            borderRadius: kHabitFreqChartTopRadius,
          ),
        if (record.partiallyCompleted > 0)
          BarChartRodData(
            toY: record.partiallyCompleted.toDouble(),
            color: colorMap[HabitHeatMapColorMapDefine.partiallyCompleted],
            width: barWidth,
            borderRadius: kHabitFreqChartTopRadius,
          ),
      ];

      final lastLength = math.max(0, barWidth * 4 - barWidth * barRods.length);
      if (lastLength > 0) {
        final lastRodData = BarChartRodData(toY: 0.0, width: lastLength / 2);
        barRods.insert(0, lastRodData);
        barRods.add(lastRodData);
      }

      final cell = BarChartGroupData(
        x: index,
        barRods: barRods,
        barsSpace: barSpaceBetween,
        showingTooltipIndicators: showTipsTop
            ? List.generate(barRods.length, (index) => index)
            : null,
      );
      result.add(cell);
    });

    return List.from(result.reversed);
  }

  List<BarChartGroupData> _buildBarGroupListWithValue() {
    final result = <BarChartGroupData>[];
    data.forEachIndexed((i, e) {
      final record = e.value, index = data.length - i - 1;

      final includeList = [];
      var currentHeight = 0.0;
      includeList.add({
        'fromY': currentHeight,
        'toY': currentHeight + record.partiallyCompletedTotalValue,
        'color': colorMap[HabitHeatMapColorMapDefine.partiallyCompleted],
      });
      currentHeight += record.partiallyCompletedTotalValue;
      includeList.add({
        'fromY': currentHeight,
        'toY': currentHeight + record.autoComplateTotalValue,
        'color': colorMap[HabitHeatMapColorMapDefine.complate],
      });
      currentHeight += record.autoComplateTotalValue;
      includeList.add({
        'fromY': currentHeight,
        'toY': currentHeight + record.complateTotalValue,
        'color': colorMap[HabitHeatMapColorMapDefine.complate],
      });
      currentHeight += record.complateTotalValue;
      includeList.add({
        'fromY': currentHeight,
        'toY': currentHeight + record.overfulfilTotalValue,
        'color': colorMap[HabitHeatMapColorMapDefine.overfulfil],
      });
      currentHeight += record.overfulfilTotalValue;

      final barRods = <BarChartRodData>[];
      includeList.forEachIndexed((index, element) {
        final radius = index == includeList.length - 1
            ? kHabitFreqChartTopRadius
            : BorderRadius.zero;
        final rodData = BarChartRodData(
          fromY: element["fromY"],
          toY: element["toY"],
          color: element["color"],
          width: barWidth,
          borderRadius: radius,
        );
        barRods.add(rodData);
      });

      final cell = BarChartGroupData(
        x: index,
        groupVertically: true,
        barRods: barRods,
        showingTooltipIndicators: [showTipsTop ? includeList.length - 1 : -1],
      );
      result.add(cell);
    });

    return List.from(result.reversed);
  }

  Widget _buildBottomTitleCell(
      BuildContext context, HabitDate date, double value) {
    List<Widget> children;
    final l10n = L10n.of(context);
    switch (combine) {
      case HabitDetailFreqChartCombine.monthly:
        children = [
          Text(
            DateFormat("MMM", l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          ),
          if (date.month == 1 || value == 0)
            Text(
              DateFormat('y', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            ),
        ];
        break;
      case HabitDetailFreqChartCombine.yearly:
        children = [
          Text(
            DateFormat('yyyy', l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          ),
        ];
        break;
      case HabitDetailFreqChartCombine.weekly:
        children = [
          Text(
            DateFormat('dd', l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          ),
        ];
        if (value == 0 || date.isFirstWeekOfYear) {
          children.add(
            Text(DateFormat('y', l10n?.localeName).format(date),
                style: bottomTipsTextStyle),
          );
        } else if (date.isFirstWeekOfMonth) {
          children.add(
            Text(DateFormat('MMM', l10n?.localeName).format(date),
                style: bottomTipsTextStyle),
          );
        }
        break;
    }

    return Center(
      child: Column(children: children.map((e) => Expanded(child: e)).toList()),
    );
  }

  Widget _buildBottomTitle(BuildContext context, double value, TitleMeta meta) {
    final index = math.max(0, data.length - value - 1).toInt();
    final date = data[index].key;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: _buildBottomTitleCell(context, date, value),
    );
  }

  Widget _buildRightTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: TextStyle(fontSize: rightTitleWidth - 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> dataList;
    bool showVerticalLine;

    switch (displayMethod) {
      case HabitFreqChartDisplayMethod.count:
        dataList = _buildBarGroupListWithCount();
        showVerticalLine = true;
        break;
      case HabitFreqChartDisplayMethod.value:
        dataList = _buildBarGroupListWithValue();
        showVerticalLine = false;
        break;
    }

    appLog.build.debug(context);
    return Column(
      children: [
        const SizedBox(height: 30),
        SizedBox(
          height: height - 30,
          child: BarChart(
            swapAnimationDuration: Duration.zero,
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: !showTipsTop,
                    reservedSize: eachSize / 2,
                    getTitlesWidget: _buildRightTitle,
                    interval: rightTitleInterval,
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameSize: eachSize,
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) =>
                        _buildBottomTitle(context, value, meta),
                    reservedSize: eachSize,
                  ),
                ),
              ),
              barGroups: dataList,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 2,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final value = rod.toY.round();
                    if (value == 0) return null;
                    return BarTooltipItem(
                      NumberFormat.compact().format(value),
                      TextStyle(
                          color: colorMap[HabitHeatMapColorMapDefine.complate]),
                    );
                  },
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: showVerticalLine,
                horizontalInterval: rightTitleInterval,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
