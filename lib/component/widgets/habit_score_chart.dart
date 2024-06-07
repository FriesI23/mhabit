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

import '../../common/math.dart';
import '../../common/types.dart';
import '../../common/utils.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../model/habit_date.dart';
import '../../model/habit_detail_chart.dart';
import 'l10n_builder.dart';
import 'scrollable_chart.dart';

const kHabitScoreChartEachSize = 42.0;

class HabitScoreChart extends StatelessWidget {
  final double height;
  final double eachSize;
  final int? limit;
  final TextStyle? bottomTipsTextStyle;
  final TextStyle? leftTipsTextStyle;
  final double leftTipsSpace;
  final HabitDetailScoreChartCombine combine;
  final Map<HabitDailyGoal, Color> colorMap;
  final List<MapEntry<HabitDate, HabitDetailScoreChartDate>> data;

  HabitScoreChart({
    super.key,
    required this.height,
    this.eachSize = kHabitScoreChartEachSize,
    this.limit,
    this.bottomTipsTextStyle,
    this.leftTipsTextStyle,
    this.leftTipsSpace = 4.0,
    required this.combine,
    required this.colorMap,
    required this.data,
  })  : assert(colorMap.containsKey(HabitHeatMapColorMapDefine.complate)),
        assert(leftTipsSpace >= 0);

  Color get mainColor => colorMap[HabitHeatMapColorMapDefine.complate]!;

  Size get protoLeftWidgetSize => calcTextSize('100', leftTipsTextStyle);

  LineChartBarData _buildLineChartBarData(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    LineChartBarData result;

    final spots = <FlSpot>[];
    data.forEachIndexed((i, e) {
      final record = e.value, index = data.length - i - 1;
      spots.add(FlSpot(index.toDouble(), record.avgScore.toDouble()));
    });
    result = LineChartBarData(
      color: mainColor,
      spots: spots,
      barWidth: 2.0,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: theme.colorScheme.background,
            strokeWidth: 2,
            strokeColor: mainColor,
          );
        },
      ),
    );
    return result;
  }

  TouchedSpotIndicatorData? _buildTouchedSpotData(
      BuildContext context, LineChartBarData barData, int spotIndexes) {
    final ThemeData theme = Theme.of(context);

    return TouchedSpotIndicatorData(
      const FlLine(color: Colors.transparent),
      FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: theme.colorScheme.background,
            strokeWidth: 2,
            strokeColor: mainColor,
          );
        },
      ),
    );
  }

  Widget _buildBottomTitleCell(
      BuildContext context, HabitDate date, double value) {
    Widget buildFirstTitle({L10n? l10n}) {
      switch (combine) {
        case HabitDetailScoreChartCombine.daily:
        case HabitDetailScoreChartCombine.weekly:
          return Text(
            DateFormat('dd', l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          );
        case HabitDetailScoreChartCombine.monthly:
          return Text(
            DateFormat("MMM", l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          );
        case HabitDetailScoreChartCombine.yearly:
          return Text(
            DateFormat('yyyy', l10n?.localeName).format(date),
            style: bottomTipsTextStyle,
          );
      }
    }

    Widget buildSeconadTitle({L10n? l10n}) {
      switch (combine) {
        case HabitDetailScoreChartCombine.daily:
          if (value == 0 || (date.month == 1 && date.day == 1)) {
            return Text(
              DateFormat('y', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            );
          } else if (date.day == 1) {
            return Text(
              DateFormat('MMM', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            );
          } else {
            return const SizedBox();
          }
        case HabitDetailScoreChartCombine.weekly:
          if (value == 0 || date.isFirstWeekOfYear) {
            return Text(
              DateFormat('y', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            );
          } else if (date.isFirstWeekOfMonth) {
            return Text(
              DateFormat('MMM', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            );
          } else {
            return const SizedBox();
          }
        case HabitDetailScoreChartCombine.monthly:
          if (value == 0 || date.month == 1) {
            return Text(
              DateFormat('y', l10n?.localeName).format(date),
              style: bottomTipsTextStyle,
            );
          } else {
            return const SizedBox();
          }
        case HabitDetailScoreChartCombine.yearly:
          return const SizedBox();
      }
    }

    return Center(
      child: L10nBuilder(
        builder: (context, l10n) => Column(
          children: [
            Expanded(child: buildFirstTitle(l10n: l10n)),
            Expanded(child: buildSeconadTitle(l10n: l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTitle(BuildContext context, double value, TitleMeta meta) {
    final index = math.max(0, data.length - math.max(0, value) - 1).ceil();
    final date = data[index].key;
    if (value > 0 && meta.min == value) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: _buildBottomTitleCell(context, date, 0),
      );
    }

    if (!isInteger(value)) {
      return const SizedBox();
    }

    if (meta.min > 0 && value < 1 + meta.min) {
      return Opacity(
        opacity: math.pow(value - meta.min, 2).toDouble(),
        child: SideTitleWidget(
          axisSide: meta.axisSide,
          child: _buildBottomTitleCell(context, date, value),
        ),
      );
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: _buildBottomTitleCell(context, date, value),
    );
  }

  Widget _buildRightTitle(double value, TitleMeta meta) {
    if (value < 0 || value > 100) return const SizedBox();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: leftTipsSpace,
      child: Text(
        value.toInt().toString(),
        style: leftTipsTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  FlLine _buildHorizontalLine(double value) {
    Color? color = Colors.transparent;
    switch (value.toInt()) {
      case 20:
        color = colorMap[HabitHeatMapColorMapDefine.uncomplate];
        break;
      case 40:
        color = colorMap[HabitHeatMapColorMapDefine.partiallyCompleted];
        break;
      case 60:
        color = colorMap[HabitHeatMapColorMapDefine.autoComplate];
        break;
      case 80:
        color = colorMap[HabitHeatMapColorMapDefine.complate];
        break;
      case 100:
        color = colorMap[HabitHeatMapColorMapDefine.overfulfil];
        break;
    }

    return FlLine(
      color: color ?? mainColor,
      strokeWidth: 0.4,
      dashArray: [8, 4],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextScaler textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    appLog.build.debug(context);
    final double maxX = (data.length - 1).toDouble();
    final double initMinX =
        limit != null ? maxX * math.max((1 - limit! / data.length), 0) : 0;

    final titlesData = FlTitlesData(
      topTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _buildRightTitle,
          reservedSize:
              textScaler.scale(protoLeftWidgetSize.width) + leftTipsSpace,
          interval: 20,
        ),
      ),
      rightTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) =>
              _buildBottomTitle(context, value, meta),
          reservedSize: eachSize,
        ),
      ),
    );

    final lineTouchData = LineTouchData(
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
          .map(
              (spotIndex) => _buildTouchedSpotData(context, barData, spotIndex))
          .toList(),
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 10,
        showOnTopOfTheChartBoxArea: true,
        getTooltipItems: (touchedSpots) {
          final sp = touchedSpots[0];
          final result = LineTooltipItem(
            sp.y.toStringAsFixed(2),
            TextStyle(
              color: sp.bar.gradient?.colors[0] ?? sp.bar.color,
            ),
          );
          return [result];
        },
      ),
    );

    final gridData = FlGridData(
      show: true,
      drawVerticalLine: false,
      drawHorizontalLine: true,
      horizontalInterval: 20,
      getDrawingHorizontalLine: _buildHorizontalLine,
    );

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => ScrollableChart(
          maxX: maxX + 0.2,
          minX: -0.2,
          initMinX: initMinX,
          scrollSpeed: 1.0 / constraints.maxWidth,
          scrollRefreshInterval: 0.0,
          builder: (minX, maxX) {
            return LineChart(
              LineChartData(
                maxX: maxX,
                minX: minX,
                maxY: 110,
                minY: -10,
                titlesData: titlesData,
                lineBarsData: [_buildLineChartBarData(context)],
                lineTouchData: lineTouchData,
                clipData: const FlClipData.all(),
                borderData: FlBorderData(show: false),
                gridData: gridData,
              ),
              duration: Duration.zero,
            );
          },
        ),
      ),
    );
  }
}
