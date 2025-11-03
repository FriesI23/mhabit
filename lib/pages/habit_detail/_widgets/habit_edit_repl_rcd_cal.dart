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

import '../../../common/consts.dart';
import '../../../common/types.dart';
import '../../../extensions/context_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_daily_record_form.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_detail_chart.dart';
import '../../../models/habit_form.dart';
import '../../../providers/app_custom_date_format.dart';
import '../../../providers/app_sync.dart';
import '../../../providers/habit_detail.dart';
import '../../../theme/color.dart';
import '../../../widgets/widgets.dart';
import '../../common/widgets.dart';
import 'habit_heatmap.dart';

Future<void> showHabitEditReplacementRecordCalendarDialog({
  required BuildContext context,
  HabitColorType? habitColorType,
  required int firstday,
  required HabitDetailViewModel detail,
}) async {
  return showDialog(
    context: context,
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: detail),
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
  late HabitDetailViewModel _vm;

  late final ScrollController _heatmapScrollController;
  bool _showDailyGoalValue = false;

  double get cellSize => widget.cellSize ?? 36.0;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitDetailViewModel>();
    _heatmapScrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitDetailViewModel>();
    if (vm != _vm) {
      _vm = vm;
    }
  }

  void _onRecordChangeConfirmed({bool shouldSyncOnce = true}) {
    if (!mounted) return;
    // try sync once
    if (shouldSyncOnce) {
      final sync = context.maybeRead<AppSyncViewModel>();
      if (sync != null && sync.mounted) sync.delayedStartTaskOnce();
    }
  }

  void onHeatmapCellPressed(DateTime date, num? value) {
    if (!(mounted && _vm.mounted)) return;
    _vm.changeRecordStatus(HabitDate.dateTime(date)).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  void onHeatmapCellLongPressed(DateTime date, num? value) async {
    if (!(mounted && _vm.mounted)) return;
    final habitDate = HabitDate.dateTime(date);
    if (_vm.habitDetailData == null) return;
    final record = _vm.getHabitRecordData(habitDate);
    switch (record?.status) {
      case HabitRecordStatus.skip:
        _openHabitRecordResonModifierDialog(habitDate);
      default:
        _openHabitRecordCusomNumberPickerDialog(habitDate);
    }
  }

  void _openHabitRecordResonModifierDialog(HabitRecordDate date) async {
    if (!_vm.mounted) return;
    final initReason = await _vm.loadRecordReason(date) ?? '';
    final colorType = _vm.habitColorType;
    if (!mounted) return;
    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: colorType,
    );
    if (result == null || result == initReason) return;
    if (!(mounted && _vm.mounted)) return;
    _vm.changeRecordReason(date, result).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  void _openHabitRecordCusomNumberPickerDialog(HabitRecordDate date) async {
    if (!(mounted && _vm.mounted)) return;
    if (_vm.habitDetailData == null) return;
    final record = _vm.getHabitRecordData(date);
    final num orgNum = record?.value ?? -1;
    final form = (record != null && record.status == HabitRecordStatus.done)
        ? HabitDailyRecordForm.getImp(
            type: _vm.habitType!,
            value: record.value,
            targetValue: _vm.habitDailyGoal!,
            extraTargetValue: _vm.habitDailyGoalExtra,
          )
        : HabitDailyRecordForm.getImp(
            type: _vm.habitType!,
            value: _vm.habitDailyGoal!,
            targetValue: _vm.habitDailyGoal!,
            extraTargetValue: _vm.habitDailyGoalExtra,
          );
    final result = await showHabitRecordCustomNumberPickerDialog(
      context: context,
      recordForm: form,
      recordStatus: record?.status ?? HabitRecordStatus.unknown,
      recordDate: date,
      targetExtraValue: _vm.habitDailyGoalExtra,
      colorType: _vm.habitColorType,
    );

    if (result == null || result == orgNum) return;
    if (!(mounted && _vm.mounted)) return;
    _vm.changeRecordValue(date, result).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final colorData = themeData.extension<CustomColors>();

    final configvm = context.read<AppCustomDateYmdHmsConfigViewModel>();

    final valueColor = (widget.defaultColorType != null
            ? colorData?.getColor(widget.defaultColorType!)
            : null) ??
        themeData.colorScheme.primary;

    final heatmap = HeatmapCalendar<num>(
      firstDay: widget.firstday,
      controller: _heatmapScrollController,
      startDate: _vm.habitStartDate,
      endedDate: HabitDate.now(),
      withUTC: true,
      colorMap: buildHeatmapColorMap(context),
      valueColorMap: buildHeatmapValueColorMap(context),
      selectedMap: _vm.heatmapDateToColorMap,
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
        onCellPressed: onHeatmapCellPressed,
        onCellLongPressed: onHeatmapCellLongPressed,
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
            return Tooltip(
              message: DateFormat('yyyy-MM-dd').format(date),
              waitDuration: const Duration(seconds: 1),
              child: childBuilder(
                context,
                valueBuilder: (context, dateDay) {
                  Widget? valueWidget;
                  if (dateDay == null) return null;
                  if (_showDailyGoalValue) {
                    final value = status.value ?? 0;
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
        iconColor: WidgetStatePropertyAll(valueColor),
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
