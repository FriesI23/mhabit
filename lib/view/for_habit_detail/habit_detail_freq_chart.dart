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

import '../../common/types.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_date.dart';
import '../../model/habit_detail_chart.dart';
import '../../widgets/widget.dart';
import 'habit_detail_chart_title.dart';

class _HabitDetailFreqChartTitle extends StatelessWidget {
  final String title;
  final HabitDetailFreqChartCombine chartCombine;
  final void Function(HabitDetailFreqChartCombine combine)? onPopMenuSelected;
  final bool showPopupMenu;

  const _HabitDetailFreqChartTitle({
    this.title = '',
    required this.chartCombine,
    this.onPopMenuSelected,
    this.showPopupMenu = true,
  });

  String getCombineString(
      BuildContext context, HabitDetailFreqChartCombine combine) {
    switch (combine) {
      case HabitDetailFreqChartCombine.monthly:
        return L10n.of(context)?.habitDetail_freqChartCombine_monthlyText ??
            "Month";
      case HabitDetailFreqChartCombine.yearly:
        return L10n.of(context)?.habitDetail_freqChartCombine_yearlyText ??
            "Year";
      case HabitDetailFreqChartCombine.weekly:
        return L10n.of(context)?.habitDetail_freqChartCombine_weeklyText ??
            "Week";
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPopupMenu(BuildContext context) {
      return PopupMenuButton<HabitDetailFreqChartCombine>(
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
        itemBuilder: (context) {
          final result = <PopupMenuEntry<HabitDetailFreqChartCombine>>[
            CheckedPopupMenuItem<HabitDetailFreqChartCombine>(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              checked: chartCombine == HabitDetailFreqChartCombine.weekly,
              value: HabitDetailFreqChartCombine.weekly,
              child: Text(
                getCombineString(context, HabitDetailFreqChartCombine.weekly),
              ),
            ),
            CheckedPopupMenuItem<HabitDetailFreqChartCombine>(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              checked: chartCombine == HabitDetailFreqChartCombine.monthly,
              value: HabitDetailFreqChartCombine.monthly,
              child: Text(
                getCombineString(context, HabitDetailFreqChartCombine.monthly),
              ),
            ),
            CheckedPopupMenuItem<HabitDetailFreqChartCombine>(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              checked: chartCombine == HabitDetailFreqChartCombine.yearly,
              value: HabitDetailFreqChartCombine.yearly,
              child: Text(
                getCombineString(context, HabitDetailFreqChartCombine.yearly),
              ),
            ),
          ];
          return result;
        },
      );
    }

    return HabitDetailChartTitle(
      title: title,
      rightChild: showPopupMenu ? buildPopupMenu(context) : null,
    );
  }
}

class _HabitDetailFreqChartSubTitle extends StatelessWidget {
  final bool isToday;
  final bool isLast;
  final HabitDetailFreqChartCombine chartCombine;
  final Widget? leftDateHelper;
  final Widget? rightDateHelper;
  final VoidCallback? onLeftButtonPressed;
  final VoidCallback? onRightButtonPressed;

  const _HabitDetailFreqChartSubTitle({
    required this.isToday,
    required this.isLast,
    required this.chartCombine,
    this.leftDateHelper,
    this.rightDateHelper,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    // NOTE: fl_chart isn't support rtl layout direction yet
    // more info see: https://github.com/imaNNeo/fl_chart/issues/129
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: isLast ? null : onLeftButtonPressed,
            icon: const Icon(Icons.keyboard_arrow_left),
            disabledColor: themeData.colorScheme.outlineVariant,
          ),
          if (leftDateHelper != null) leftDateHelper!,
          const Text(" ~ "),
          if (rightDateHelper != null) rightDateHelper!,
          IconButton(
            onPressed: isToday ? null : onRightButtonPressed,
            icon: const Icon(Icons.keyboard_arrow_right),
            disabledColor: themeData.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _HabitDetailFreqChartInSmallScreen extends StatelessWidget {
  final double titleHeight;
  final HabitDetailFreqChartCombine chartCombine;
  final bool isToday;
  final bool isLast;
  final bool isChartExpanded;
  final Widget? leftDateHelper;
  final Widget? rightDateHelper;
  final Widget? countChartWidget;
  final Widget? valueChartWidget;
  final VoidCallback? onLeftHelperButtonPressed;
  final VoidCallback? onRightHelperButtonPressed;
  final void Function(HabitDetailFreqChartCombine combine)? onPopMenuSelected;
  final ValueChanged<bool>? onExpandIconPressed;

  const _HabitDetailFreqChartInSmallScreen({
    required this.titleHeight,
    required this.chartCombine,
    required this.isToday,
    required this.isLast,
    required this.isChartExpanded,
    this.leftDateHelper,
    this.rightDateHelper,
    this.countChartWidget,
    this.valueChartWidget,
    this.onLeftHelperButtonPressed,
    this.onRightHelperButtonPressed,
    this.onPopMenuSelected,
    this.onExpandIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildCountFreqChart(BuildContext context) {
      return ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(height: titleHeight),
              child: L10nBuilder(
                builder: (context, l10n) => _HabitDetailFreqChartTitle(
                  title: l10n?.habitDetail_freqChart_freqTitle ?? "Frequency",
                  chartCombine: chartCombine,
                  onPopMenuSelected: onPopMenuSelected,
                ),
              ),
            ),
            _HabitDetailFreqChartSubTitle(
              isToday: isToday,
              isLast: isLast,
              chartCombine: chartCombine,
              leftDateHelper: leftDateHelper,
              rightDateHelper: rightDateHelper,
              onLeftButtonPressed: onLeftHelperButtonPressed,
              onRightButtonPressed: onRightHelperButtonPressed,
            ),
            if (countChartWidget != null) countChartWidget!,
          ],
        ),
      );
    }

    Widget buildValueFreqChart(BuildContext context) {
      return ExpandedSection(
        expand: isChartExpanded,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // const Divider(color: Colors.transparent),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: titleHeight),
                child: L10nBuilder(
                  builder: (context, l10n) => _HabitDetailFreqChartTitle(
                    title:
                        l10n?.habitDetail_freqChart_historyTitle ?? "History",
                    chartCombine: chartCombine,
                    showPopupMenu: false,
                  ),
                ),
              ),
              if (valueChartWidget != null) valueChartWidget!,
            ],
          ),
        ),
      );
    }

    final l10n = L10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildCountFreqChart(context),
        buildValueFreqChart(context),
        Tooltip(
          message: isChartExpanded
              ? l10n?.habitDetail_freqChart_expanded_hideTooltip
              : l10n?.habitDetail_freqChart_expanded_showTooltip,
          triggerMode: TooltipTriggerMode.longPress,
          child: ExpandIcon(
            isExpanded: isChartExpanded,
            onPressed: onExpandIconPressed,
          ),
        ),
      ],
    );
  }
}

class _HabitDetailFreqChartInLargeScreen extends StatelessWidget {
  final double titleHeight;
  final double largeScreenTwoChartBetween;
  final HabitDetailFreqChartCombine chartCombine;
  final bool isToday;
  final bool isLast;
  final Widget? leftDateHelper;
  final Widget? rightDateHelper;
  final Widget? countChartWidget;
  final Widget? valueChartWidget;
  final VoidCallback? onLeftHelperButtonPressed;
  final VoidCallback? onRightHelperButtonPressed;
  final void Function(HabitDetailFreqChartCombine combine)? onPopMenuSelected;
  final ValueChanged<bool>? onExpandIconPressed;

  const _HabitDetailFreqChartInLargeScreen({
    required this.titleHeight,
    this.largeScreenTwoChartBetween = 0,
    required this.chartCombine,
    required this.isToday,
    required this.isLast,
    this.leftDateHelper,
    this.rightDateHelper,
    this.countChartWidget,
    this.valueChartWidget,
    this.onLeftHelperButtonPressed,
    this.onRightHelperButtonPressed,
    this.onPopMenuSelected,
    this.onExpandIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildChartTitle(BuildContext context) {
      return ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: titleHeight),
        child: L10nBuilder(
          builder: (context, l10n) => _HabitDetailFreqChartTitle(
            title: l10n?.habitDetail_freqChart_combinedTitle ??
                "Frequency & History",
            chartCombine: chartCombine,
            onPopMenuSelected: onPopMenuSelected,
          ),
        ),
      );
    }

    Widget buildChartSubTitle(BuildContext context) {
      return _HabitDetailFreqChartSubTitle(
        isToday: isToday,
        isLast: isLast,
        chartCombine: chartCombine,
        leftDateHelper: leftDateHelper,
        rightDateHelper: rightDateHelper,
        onLeftButtonPressed: onLeftHelperButtonPressed,
        onRightButtonPressed: onRightHelperButtonPressed,
      );
    }

    Widget buildChart(BuildContext context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (countChartWidget != null)
            Expanded(child: ClipRect(child: countChartWidget)),
          if (valueChartWidget != null)
            Expanded(child: ClipRect(child: valueChartWidget)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildChartTitle(context),
        buildChartSubTitle(context),
        buildChart(context),
      ],
    );
  }
}

class HabitDetailFreqChart extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final double eachSize;
  final double barWidth;
  final double barSpaceBetween;
  final double allowWidth;
  final double titleHeight;
  final double largeScreenTwoChartBetween;
  final HabitDate Function(int limit) getFirstDate;
  final HabitDate Function(int limit) getLastDate;
  final HabitDate habitStartDate;
  final HabitDetailFreqChartCombine chartCombine;
  final bool isLargeScreen;
  final bool isChartExpanded;
  final List<MapEntry<HabitDate, HabitDetailFreqChartData>> Function(
      HabitDate firstDate, HabitDate lastDate, int limit) getData;
  final void Function(HabitDetailFreqChartCombine combine)? onPopMenuSelected;
  final HabitDetailFreqChartBuilder? countChartBuilder;
  final HabitDetailFreqChartBuilder? valueChartBuilder;

  final int offset;
  final Widget? Function(BuildContext context, HabitDate firstDate,
      HabitDate lastDate, bool isToday, bool isLast)? getLeftDateHelper;
  final Widget? Function(BuildContext context, HabitDate firstDate,
      HabitDate lastDate, bool isToday, bool isLast)? getRightDateHelper;
  final VoidCallback? onLeftButtonPressed;
  final VoidCallback? onRightButtonPressed;
  final ValueChanged<bool>? onExpandIconPressed;

  const HabitDetailFreqChart({
    super.key,
    required this.padding,
    required this.eachSize,
    required this.barWidth,
    required this.barSpaceBetween,
    required this.allowWidth,
    required this.titleHeight,
    required this.largeScreenTwoChartBetween,
    required this.getFirstDate,
    required this.getLastDate,
    required this.habitStartDate,
    required this.chartCombine,
    required this.isLargeScreen,
    required this.isChartExpanded,
    required this.getData,
    this.onPopMenuSelected,
    this.countChartBuilder,
    this.valueChartBuilder,
    required this.offset,
    this.getLeftDateHelper,
    this.getRightDateHelper,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
    this.onExpandIconPressed,
  });

  double get cellWidth => barWidth * 4 + barSpaceBetween * 3;

  ValueKey<String> getCountChartKey(HabitDate firstDate, HabitDate lastDate) {
    return ValueKey<String>("countChart"
        "|${firstDate.year}-${firstDate.month}-${firstDate.day}"
        "|${lastDate.year}-${lastDate.month}-${lastDate.day}"
        "|${chartCombine.index}");
  }

  ValueKey<String> getValueChartKey(HabitDate firstDate, HabitDate lastDate) {
    return ValueKey<String>("valueChart"
        "|${firstDate.year}-${firstDate.month}-${firstDate.day}"
        "|${lastDate.year}-${lastDate.month}-${lastDate.day}"
        "|${chartCombine.index}");
  }

  @override
  Widget build(BuildContext context) {
    final TextScaler textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    final eachSize = textScaler.scale(this.eachSize);
    final limit = math.max(1, allowWidth ~/ math.max(eachSize, cellWidth));
    final firstDate = getFirstDate(limit);
    final lastDate = getLastDate(limit);
    final titleHeight =
        textScaler.clamp(minScaleFactor: 1.0).scale(this.titleHeight);

    final isToday = offset == 0;
    final isLast = lastDate.isBefore(habitStartDate);
    final data = getData(firstDate, lastDate, limit);
    if (isLargeScreen) {
      return Padding(
        padding: padding,
        child: _HabitDetailFreqChartInLargeScreen(
          titleHeight: titleHeight,
          largeScreenTwoChartBetween: largeScreenTwoChartBetween,
          chartCombine: chartCombine,
          isToday: isToday,
          isLast: isLast,
          leftDateHelper: getLeftDateHelper?.call(
              context, firstDate, lastDate, isToday, isLast),
          rightDateHelper: getRightDateHelper?.call(
              context, firstDate, lastDate, isToday, isLast),
          countChartWidget: countChartBuilder?.call(
            context,
            data,
            eachSize,
            barWidth,
            barSpaceBetween,
            HabitFreqChartDisplayMethod.count,
            getCountChartKey(firstDate, lastDate),
          ),
          valueChartWidget: valueChartBuilder?.call(
            context,
            data,
            eachSize,
            barWidth,
            barSpaceBetween,
            HabitFreqChartDisplayMethod.value,
            getValueChartKey(firstDate, lastDate),
          ),
          onLeftHelperButtonPressed: onLeftButtonPressed,
          onRightHelperButtonPressed: onRightButtonPressed,
          onPopMenuSelected: onPopMenuSelected,
          onExpandIconPressed: onExpandIconPressed,
        ),
      );
    } else {
      return Padding(
        padding: padding,
        child: _HabitDetailFreqChartInSmallScreen(
          titleHeight: titleHeight,
          chartCombine: chartCombine,
          isToday: isToday,
          isLast: isLast,
          isChartExpanded: isChartExpanded,
          leftDateHelper: getLeftDateHelper?.call(
              context, firstDate, lastDate, isToday, isLast),
          rightDateHelper: getRightDateHelper?.call(
              context, firstDate, lastDate, isToday, isLast),
          countChartWidget: countChartBuilder?.call(
            context,
            data,
            eachSize,
            barWidth,
            barSpaceBetween,
            HabitFreqChartDisplayMethod.count,
            getCountChartKey(firstDate, lastDate),
          ),
          valueChartWidget: valueChartBuilder?.call(
            context,
            data,
            eachSize,
            barWidth,
            barSpaceBetween,
            HabitFreqChartDisplayMethod.value,
            getValueChartKey(firstDate, lastDate),
          ),
          onLeftHelperButtonPressed: onLeftButtonPressed,
          onRightHelperButtonPressed: onRightButtonPressed,
          onPopMenuSelected: onPopMenuSelected,
          onExpandIconPressed: onExpandIconPressed,
        ),
      );
    }
  }
}
