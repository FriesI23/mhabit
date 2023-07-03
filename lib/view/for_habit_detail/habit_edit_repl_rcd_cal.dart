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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_heatmap_calendar/simple_heatmap_calendar.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../component/widget.dart';
import '../../db/db_helper/records.dart';
import '../../extension/custom_color_extensions.dart';
import '../../model/habit_date.dart';
import '../../model/habit_detail_chart.dart';
import '../../model/habit_form.dart';
import '../../provider/app_custom_date_format.dart';
import '../../provider/habit_detail.dart';
import '../../provider/habit_summary.dart';
import '../../theme/color.dart';
import '../common/_dialog.dart';
import '_mixin.dart';

Future<void> showHabitEditReplacementRecordCalendarDialog({
  required BuildContext context,
  HabitColorType? habitColorType,
  required int firstday,
  required HabitDetailViewModel detail,
  required HabitSummaryViewModel summary,
}) async {
  return showDialog(
    context: context,
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: detail),
        ChangeNotifierProvider.value(value: summary),
      ],
      child: HabitEditReplacementRecordCalendarDialog(
        defaultColorType: habitColorType,
        firstday: firstday,
      ),
    ),
  );
}

class HabitEditReplacementRecordCalendarDialog extends StatefulWidget {
  final double? cellSize;
  final HabitColorType? defaultColorType;
  final int firstday;
  const HabitEditReplacementRecordCalendarDialog({
    super.key,
    this.cellSize,
    this.defaultColorType,
    required this.firstday,
  });

  @override
  State<StatefulWidget> createState() =>
      _HabitEditReplacementRecordCalendarDialog();
}

class _HabitEditReplacementRecordCalendarDialog
    extends State<HabitEditReplacementRecordCalendarDialog>
    with HabitHeatmapColorChooseMixin {
  late final ScrollController _heatmapScrollController;
  bool _showDailyGoalValue = false;

  double get cellSize => widget.cellSize ?? 36.0;

  @override
  void initState() {
    super.initState();
    _heatmapScrollController = ScrollController();
  }

  void onHeatmapCellPressed(DateTime date, num? value) async {
    if (!mounted) return;
    var viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted) return;
    await viewmodel.onTapToChangeRecordStatus(HabitDate.dateTime(date));
  }

  void onHeatmapCellLongPressed(DateTime date, num? value) async {
    final habitDate = HabitDate.dateTime(date);

    if (!mounted) return;
    final viewmodel = context.read<HabitDetailViewModel>();

    if (!viewmodel.mounted || viewmodel.habitDetailData == null) return;
    final record = viewmodel.getHabitRecordData(habitDate);
    switch (record?.status) {
      case HabitRecordStatus.skip:
        _openHabitRecordResonModifierDialog(context, habitDate);
        break;
      default:
        _openHabitRecordCusomNumberPickerDialog(context, habitDate);
        break;
    }
  }

  void _openHabitRecordResonModifierDialog(
      BuildContext context, HabitRecordDate date) async {
    String initReason = '';

    if (!mounted) return;
    final viewmodel = context.read<HabitDetailViewModel>();

    if (!viewmodel.mounted || viewmodel.habitDetailData == null) return;
    final record = viewmodel.getHabitRecordData(date);

    if (record?.uuid != null) {
      initReason = (await loadSingleRecordFromDB(record!.uuid))?.reason ?? '';
    }

    if (!mounted) return;
    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: viewmodel.habitColorType,
    );

    if (result == null || result == initReason || !mounted) return;
    viewmodel.onLongPressChangeReason(date, result);
  }

  void _openHabitRecordCusomNumberPickerDialog(
      BuildContext context, HabitRecordDate date) async {
    late final HabitDailyRecordForm form;

    if (!mounted) return;
    final viewmodel = context.read<HabitDetailViewModel>();

    if (!viewmodel.mounted || viewmodel.habitDetailData == null) return;
    final record = viewmodel.getHabitRecordData(date);
    num orgNum = record?.value ?? -1;
    if (record != null && record.status == HabitRecordStatus.done) {
      form = HabitDailyRecordForm(record.value, viewmodel.habitDailyGoal!);
    } else {
      form = HabitDailyRecordForm(
          viewmodel.habitDailyGoal!, viewmodel.habitDailyGoal!);
    }

    final result = await showHabitRecordCustomNumberPickerDialog(
      context: context,
      recordForm: form,
      recordStatus: record?.status ?? HabitRecordStatus.unknown,
      recordDate: date,
      targetExtraValue: viewmodel.habitDailyGoalExtra,
      colorType: viewmodel.habitColorType,
    );

    if (result == null || result == orgNum || !mounted || !viewmodel.mounted) {
      return;
    }
    viewmodel.onLongPressChangeRecordValue(date, result);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final colorData = themeData.extension<CustomColors>();

    final configvm = context.read<AppCustomDateYmdHmsConfigViewModel>();
    final viewmodel = context.read<HabitDetailViewModel>();

    final valueColor = (widget.defaultColorType != null
            ? colorData?.getColor(widget.defaultColorType!)
            : null) ??
        themeData.colorScheme.primary;

    final heatmap = HeatmapCalendar<num>(
      firstDay: widget.firstday,
      controller: _heatmapScrollController,
      startDate: viewmodel.habitStartDate,
      endedDate: HabitDate.now(),
      colorMap: buildHeatmapColorMap(context),
      valueColorMap: buildHeatmapValueColorMap(context),
      selectedMap: viewmodel.heatmapDateToColorMap,
      cellSize: Size.square(cellSize),
      cellSpaceBetween: 4.0,
      weekLabalCellSize: Size(40.0, cellSize),
      style: HeatmapCalendarStyle.defaults(
        cellRadius: const BorderRadius.all(Radius.circular(8.0)),
        cellValueColor: valueColor,
      ),
      layoutParameters: const HeatmapLayoutParameters.defaults(
        weekLabelPosition: CalendarWeekLabelPosition.right,
        monthLabelPosition: CalendarMonthLabelPosition.bottom,
      ),
      switchParameters: const HeatmapSwitchParameters.defaults(
        showCellText: true,
      ),
      callbackModel: HeatmapCallbackModel(
        onCellPressed: (date, value) => onHeatmapCellPressed(date, value),
        onCellLongPressed: (date, value) =>
            onHeatmapCellLongPressed(date, value),
      ),
      weekLabelValueBuilder: (context, protoDate, defaultFormat) {
        return FittedBox(
          child: L10nBuilder(
            builder: (context, l10n) => Text(
              DateFormat('ccc', l10n?.localeName).format(protoDate),
              style: TextStyle(color: themeData.colorScheme.outlineVariant),
            ),
          ),
        );
      },
      monthLabelItemBuilder: (context, date, defaultFormat) {
        return L10nBuilder(
          builder: (context, l10n) => Text(
            configvm.config
                .getYMFormatterForHeatmapCal(l10n?.localeName)
                .format(date),
            style: textTheme.labelLarge
                ?.copyWith(color: themeData.colorScheme.outline),
          ),
        );
      },
      cellBuilder: (context, childBuilder, columnIndex, rowIndex, date) {
        return Selector<HabitDetailViewModel, HabitHeatmapCellStatus>(
          selector: (context, vm) =>
              vm.getHabitHeatmapCellStatus(HabitDate.dateTime(date)),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, status, _) {
            // DebugLog.rebuild("HabitEditRecordByHeatmapCalendarDialog:: "
            //     "heatmap cell $date $value");
            return Tooltip(
              message: DateFormat('yyyy-MM-dd').format(date),
              waitDuration: const Duration(seconds: 1),
              child: childBuilder(
                context,
                valueBuilder: (context, dateDay) {
                  Widget? valueWidget;
                  if (dateDay == null) return null;
                  if (_showDailyGoalValue) {
                    var value = status.value ?? 0;
                    switch (status.status) {
                      case HabitRecordStatus.done:
                        valueWidget = FittedBox(
                          key: const ValueKey<int>(1),
                          fit: BoxFit.scaleDown,
                          child: Text(NumberFormat.compact().format(value)),
                        );
                        break;
                      case HabitRecordStatus.skip:
                        valueWidget =
                            Icon(Icons.remove_outlined, color: valueColor);
                        break;
                      default:
                        break;
                    }
                  } else {
                    valueWidget = FittedBox(
                      key: const ValueKey<int>(2),
                      fit: BoxFit.scaleDown,
                      child: Text(DateFormat('dd').format(date)),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: valueWidget,
                  );
                },
              ),
            );
          },
        );
      },
    );

    final segmentedButton = SegmentedButton<bool>(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        iconColor: MaterialStatePropertyAll(valueColor),
      ),
      segments: [
        ButtonSegment<bool>(
          value: false,
          label: L10nBuilder(
            builder: (context, l10n) => Text(
              l10n?.habitDetail_editHeatmapCal_dateButtonText ?? "Date",
              style: TextStyle(
                  color: _showDailyGoalValue != false ? valueColor : null),
            ),
          ),
          icon: const Icon(Icons.calendar_today_outlined),
        ),
        ButtonSegment<bool>(
          value: true,
          label: L10nBuilder(
            builder: (context, l10n) => Text(
              l10n?.habitDetail_editHeatmapCal_valueButtonText ?? "Value",
              style: TextStyle(
                  color: _showDailyGoalValue != true ? valueColor : null),
            ),
          ),
          icon: const Icon(Icons.pending_actions_outlined),
        ),
      ],
      selected: {_showDailyGoalValue},
      onSelectionChanged: (value) => setState(() {
        _showDailyGoalValue = value.first;
      }),
    );

    final scrollToStartButton = L10nBuilder(
      builder: (context, l10n) => IconButton(
        tooltip: l10n?.habitDetail_editHeatmapCal_backToToday_tooltipText ??
            "back to today",
        icon: const Icon(Icons.event_repeat_outlined),
        visualDensity: VisualDensity.compact,
        onPressed: () {
          _heatmapScrollController.animateTo(0,
              duration: const Duration(seconds: 1), curve: Curves.easeOutQuart);
        },
      ),
    );

    return AlertDialog(
      scrollable: true,
      // insetPadding:
      //     const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heatmap,
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                scrollToStartButton,
                segmentedButton,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
