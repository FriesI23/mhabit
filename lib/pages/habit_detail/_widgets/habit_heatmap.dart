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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_heatmap_calendar/simple_heatmap_calendar.dart';

import '../../../common/types.dart';
import '../../../extensions/color_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../model/habit_date.dart';
import '../../../model/habit_detail_chart.dart';
import '../../../providers/habit_detail.dart';
import '../../../theme/color.dart';

class HabitHeatmap extends StatelessWidget {
  final int firstday;
  final Widget? descDailyGoalWidget;
  final Widget? descTargetDaysWidget;
  final Widget? descRecordsNumWidget;
  final EdgeInsetsGeometry padding;
  final bool isLargeScreen;
  final HabitDate startDate;
  final HabitDate endedDate;
  final Map<num, Color>? colorMap;
  final Map<num, Color>? valueColorMap;
  final Map<DateTime, num>? selectedMap;
  final String colorTipLeftHelperText;
  final String colorTipRightHelperText;
  final Widget? Function(
    BuildContext context,
    DateTime protoDate,
    String defaultFormat,
  )? heatmapWeekLabelValueBuilder;
  final Widget? Function(
    BuildContext context,
    DateTime date,
    String defaultFormat,
  )? heatmapMonthLabelItemBuilder;
  final Widget? Function(
    BuildContext context,
    Widget Function(
      BuildContext, {
      Widget? Function(BuildContext context, int? dateDay)? valueBuilder,
    }) childBuilder,
    int columnIndex,
    int rowIndex,
    DateTime date,
  )? heatmapCellBuilder;

  const HabitHeatmap({
    super.key,
    required this.firstday,
    this.descDailyGoalWidget,
    this.descTargetDaysWidget,
    this.descRecordsNumWidget,
    this.padding = EdgeInsets.zero,
    this.isLargeScreen = false,
    required this.startDate,
    required this.endedDate,
    this.colorMap,
    this.valueColorMap,
    this.selectedMap,
    this.colorTipLeftHelperText = '',
    this.colorTipRightHelperText = '',
    this.heatmapWeekLabelValueBuilder,
    this.heatmapMonthLabelItemBuilder,
    this.heatmapCellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    final heatmap = HeatmapCalendar<num>(
      firstDay: firstday,
      startDate: startDate,
      endedDate: endedDate,
      withUTC: true,
      colorMap: colorMap,
      valueColorMap: valueColorMap,
      selectedMap: selectedMap,
      cellSize: const Size.square(14.0),
      colorTipSpaceBetweenHeatmap: 4.0,
      style: const HeatmapCalendarStyle.defaults(
        colorTipPosOffset: 16,
        monthLabelTextSizeMultiple: 4,
      ),
      layoutParameters: const HeatmapLayoutParameters.defaults(
        weekLabelPosition: CalendarWeekLabelPosition.right,
        monthLabelPosition: CalendarMonthLabelPosition.bottom,
        colorTipPosition: CalendarColorTipPosition.top,
      ),
      switchParameters: const HeatmapSwitchParameters.defaults(
        autoClipped: CalendarAutoChippedBasis.right,
      ),
      colorTipLeftHelper: Text(
        colorTipLeftHelperText,
        style: textTheme.labelSmall
            ?.copyWith(color: themeData.colorScheme.outline),
      ),
      colorTipRightHelper: Text(
        colorTipRightHelperText,
        style: textTheme.labelSmall
            ?.copyWith(color: themeData.colorScheme.outline),
      ),
      weekLabelValueBuilder: heatmapWeekLabelValueBuilder,
      monthLabelItemBuilder: heatmapMonthLabelItemBuilder,
      cellBuilder: heatmapCellBuilder,
    );

    Widget buildWithVertical(BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heatmap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (descDailyGoalWidget != null)
                Expanded(child: descDailyGoalWidget!),
              if (descTargetDaysWidget != null)
                Expanded(child: descTargetDaysWidget!),
              if (descRecordsNumWidget != null)
                Expanded(child: descRecordsNumWidget!),
            ],
          )
        ],
      );
    }

    Widget buildWithHorizontal(BuildContext context) {
      return Row(
        children: [
          Expanded(flex: 5, child: heatmap),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                if (descDailyGoalWidget != null) descDailyGoalWidget!,
                if (descTargetDaysWidget != null) descTargetDaysWidget!,
                if (descRecordsNumWidget != null) descRecordsNumWidget!,
              ],
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: padding,
      child: isLargeScreen
          ? buildWithHorizontal(context)
          : buildWithVertical(context),
    );
  }
}

mixin HabitHeatmapColorChooseMixin<T extends StatefulWidget> on State<T> {
  Map<HabitDailyGoal, Color> buildHeatmapColorMap(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final viewmodel = context.read<HabitDetailViewModel>();
    return {
      HabitHeatMapColorMapDefine.uncomplate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withValues(alpha: 0.2),
      HabitHeatMapColorMapDefine.partiallyCompleted:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withValues(alpha: 0.3),
      HabitHeatMapColorMapDefine.autoComplate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withValues(alpha: 0.5),
      HabitHeatMapColorMapDefine.complate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary),
      HabitHeatMapColorMapDefine.overfulfil:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .darken(0.2),
    };
  }

  Map<HabitDailyGoal, Color> buildHeatmapValueColorMap(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final viewmodel = context.read<HabitDetailViewModel>();
    return {
      HabitHeatMapColorMapDefine.uncomplate:
          colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary,
      HabitHeatMapColorMapDefine.partiallyCompleted:
          colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary,
      HabitHeatMapColorMapDefine.autoComplate:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
      HabitHeatMapColorMapDefine.complate:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
      HabitHeatMapColorMapDefine.overfulfil:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
    };
  }
}
