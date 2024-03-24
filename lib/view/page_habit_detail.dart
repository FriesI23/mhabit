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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../extension/custom_color_extensions.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../component/animation.dart';
import '../component/widget.dart';
import '../db/db_helper/habits.dart';
import '../extension/async_extensions.dart';
import '../extension/color_extensions.dart';
import '../extension/context_extensions.dart';
import '../extension/num_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../model/custom_date_format.dart';
import '../model/habit_date.dart';
import '../model/habit_detail_chart.dart';
import '../model/habit_detail_page.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../provider/app_custom_date_format.dart';
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/habit_detail.dart';
import '../provider/habit_detail_freqchart.dart';
import '../provider/habit_detail_scorechart.dart';
import '../provider/habit_summary.dart';
import '../provider/habits_file_exporter.dart';
import '../reminders/notification_channel.dart';
import '../theme/color.dart';
import '../theme/icon.dart';
import '_debug.dart';
import 'common/_dialog.dart';
import 'common/_mixin.dart';
import 'common/_widget.dart';
import 'for_habit_detail/_dialog.dart';
import 'for_habit_detail/_mixin.dart';
import 'for_habit_detail/_widget.dart';
import 'page_habit_edit.dart' as habit_edit_view;

const kHabitDetailLoadingCircleIndicatorSize = 64.0;
const kHabitDetailFreqChartHeight = 240.0;
const kHabitDetailFreqChartTitleHeight = 48.0;

const _kHabitDetailFutureLoadDuration = Duration(milliseconds: 300);

const kHabitDetailWidgetPadding = EdgeInsets.symmetric(horizontal: 16.0);

const _largeScreenTwoChartBetween = 16.0;

const _div = HabitDivider();

Future<DetailPageReturn?> naviToHabitDetailPage({
  required BuildContext context,
  required HabitUUID habitUUID,
  HabitColorType? colorType,
  HabitSummaryViewModel? summary,
}) async {
  return Navigator.of(context).push<DetailPageReturn>(
    MaterialPageRoute(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: summary),
        ],
        child: PageHabitDetail(habitUUID: habitUUID, colorType: colorType),
      ),
    ),
  );
}

class PageHabitDetail extends StatelessWidget {
  final HabitUUID habitUUID;
  final HabitColorType? colorType;

  const PageHabitDetail({super.key, required this.habitUUID, this.colorType});

  @override
  Widget build(BuildContext context) {
    assert(context.maybeRead<HabitFileExporterViewModel>() != null);
    assert(context.maybeRead<AppFirstDayViewModel>() != null);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitDetailViewModel>(
          create: (context) => HabitDetailViewModel(),
        ),
        ChangeNotifierProxyProvider<AppFirstDayViewModel, HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) {
            if (value.firstDay != previous!.firstday) {
              previous.updateFirstday(value.firstDay);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                previous.rockreloadDBToggleSwich();
              });
            }
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<HabitDetailViewModel,
            HabitDetailFreqChartViewModel>(
          create: (context) => HabitDetailFreqChartViewModel(),
          update: (context, value, previous) {
            var version = value.getInsideVersion();
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
            var version = value.getInsideVersion();
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
        ChangeNotifierProxyProvider<NotificationChannelData,
            HabitDetailViewModel>(
          create: (context) => context.read<HabitDetailViewModel>(),
          update: (context, value, previous) =>
              previous!..setNotificationChannelData(value),
        ),
      ],
      child: HabitDetailView(habitUUID: habitUUID, colorType: colorType),
    );
  }
}

class HabitDetailView extends StatefulWidget {
  final HabitUUID habitUUID;
  final HabitColorType? colorType;

  const HabitDetailView({super.key, required this.habitUUID, this.colorType});

  @override
  State<StatefulWidget> createState() => _HabitDetailView();
}

class _HabitDetailView extends State<HabitDetailView>
    with
        HabitHeatmapColorChooseMixin<HabitDetailView>,
        XShare<HabitDetailView> {
  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  Future<bool> _enterHabitEditPage({
    required HabitForm Function(HabitDBCell) formBuilder,
  }) async {
    HabitDetailViewModel viewmodel;
    final dbcell = await loadHabitDetailFromDB(widget.habitUUID);

    if (!mounted || dbcell == null) return false;
    viewmodel = context.read<HabitDetailViewModel>();
    final form = formBuilder(dbcell);

    final result = await habit_edit_view.naviToHabitEidtPage(
        context: context, initForm: form);

    if (result == null || !mounted) return false;
    viewmodel = context.read<HabitDetailViewModel>();
    viewmodel.rockreloadDBToggleSwich();
    final summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary != null && summary.mounted) {
      summary.updateCalendarExpanedStatus(false, listen: false);
      summary.rockreloadDBToggleSwich();
    }
    return true;
  }

  void _onAppbarEditActionPressed() async => _enterHabitEditPage(
        formBuilder: (dbCell) => HabitForm.fromHabitDBCell(
          dbCell,
          editMode: HabitDisplayEditMode.edit,
          editParams: HabitDisplayEditParams.fromDBCell(dbCell),
        ),
      );

  void _onAppbarCloneActionPressed() => _enterHabitEditPage(
        formBuilder: (dbCell) => HabitForm.fromHabitDBCell(
          dbCell.copyWith(
            name: '',
            desc: '',
            startDate: HabitStartDate.now().epochDay,
          ),
          editMode: HabitDisplayEditMode.create,
        ),
      );

  void _openRetryButtonPressed() {
    if (!mounted) return;
    context.read<HabitDetailViewModel>().rockreloadDBToggleSwich();
  }

  void _openEditDialog() async {
    HabitDetailViewModel viewmodel;

    if (!mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (viewmodel.habitDetailData == null) return;
    var oldVersion = viewmodel.getInsideVersion();
    await showHabitEditReplacementRecordCalendarDialog(
      context: context,
      habitColorType: viewmodel.habitColorType,
      firstday: viewmodel.firstday,
      detail: viewmodel,
    );

    if (!mounted) return;
    final summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary == null ||
        !summary.mounted ||
        viewmodel.getInsideVersion() == oldVersion) return;
    summary.rockreloadDBToggleSwich();
  }

  Future<bool?> _openHabitOpConfirmDialog(
      BuildContext context, Widget title) async {
    return showConfirmDialog(
      context: context,
      title: title,
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDetail_confirmDialog_cancel)
            : const Text('cancel');
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDetail_confirmDialog_confirm)
            : const Text('confirm');
      },
    );
  }

  void _openHabitArchiveConfirmDialog() async {
    HabitSummaryViewModel? summary;
    HabitDetailViewModel viewmodel;

    var result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_archiveConfirmDialog_titleText)
            : const Text("Archive Habit?"),
      ),
    );

    if (result == null || result == false || !mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted || viewmodel.habitUUID == null) return;
    summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary == null || !summary.mounted) {
      await viewmodel.onConfirmToArchiveHabit();
      return;
    }

    // use summary method in default
    await summary.forHabitDetail.onConfirmToArchiveHabit(viewmodel.habitUUID!);

    if (!mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted) return;
    viewmodel.rockreloadDBToggleSwich();
  }

  void _openHabitUnarchiveConfirmDialog() async {
    HabitSummaryViewModel? summary;
    HabitDetailViewModel viewmodel;

    final result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_unarchiveConfirmDialog_titleText)
            : const Text("Unarchive Habit?"),
      ),
    );

    if (result == null || result == false || !mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted || viewmodel.habitUUID == null) return;
    summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary == null || !summary.mounted) {
      await viewmodel.onConfirmToUnarchiveHabit();
      return;
    }

    // use summary method in default
    await summary.forHabitDetail
        .onConfirmToUnarchiveHabit(viewmodel.habitUUID!);

    if (!mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted) return;
    viewmodel.rockreloadDBToggleSwich();
  }

  void _openHabitDeleteConfirmDialog() async {
    HabitSummaryViewModel? summary;
    HabitDetailViewModel viewmodel;

    var result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_deleteConfirmDialog_titleText)
            : const Text("Delete Habit?"),
      ),
    );

    if (result == null || result == false || !mounted) return;
    viewmodel = context.read<HabitDetailViewModel>();
    if (!viewmodel.mounted || viewmodel.habitUUID == null) return;
    summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary == null || !summary.mounted) {
      final change = await viewmodel.onConfirmToDeleteHabit();
      return Navigator.pop(
        context,
        DetailPageReturn(
          op: DetailPageReturnOpr.deleted,
          habitName: viewmodel.habitName,
          recordList: change != null ? [change] : null,
        ),
      );
    }

    // use summary method in default
    return Navigator.pop(
      context,
      DetailPageReturn(
        op: DetailPageReturnOpr.deleted,
        habitName: viewmodel.habitName,
        recordList: await summary.forHabitDetail
            .onConfirmToDeleteHabit(viewmodel.habitUUID!),
      ),
    );
  }

  void _exportHabitAndShared(BuildContext context) async {
    HabitFileExporterViewModel fileExporter;

    if (!mounted) return;
    final confirmResult = await showExporterConfirmDialog(
      context: context,
      exportAll: false,
    );

    if (!mounted || confirmResult == null) return;
    fileExporter = context.read<HabitFileExporterViewModel>();
    final filePath = await fileExporter.exportHabitData(
      widget.habitUUID,
      withRecords: confirmResult == ExporterConfirmResultType.withRecords,
    );
    if (!mounted || filePath == null) return;
    //TODO: add snackbar result
    shareXFiles([XFile(filePath)], text: "Export Habit", context: context);
  }

  Widget _buildDebugInfo(BuildContext context) {
    assert(kDebugMode);
    return Builder(
      builder: (context) {
        var viewmodel = context.read<HabitDetailViewModel>();
        return ListTile(
          leading:
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          isThreeLine: true,
          title: const Text('DEBUG'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("name: ${viewmodel.habitName}"),
              Text("uuid: ${viewmodel.habitUUID}"),
              Text("createT: ${viewmodel.debugGetData()?.createT}"),
              Text("modifyT: ${viewmodel.debugGetData()?.modifyT}"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollablePlaceHolder(BuildContext context) {
    assert(kDebugMode);
    return SliverList(
      delegate:
          DebugBuilderMethods.debugBuildSliverScrollDelegate(childCount: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    Widget buildAppbar(BuildContext context) {
      Widget buildAppbarAction(
          BuildContext context, HabitColorType? colorType) {
        return Selector<HabitDetailViewModel, bool>(
          selector: (context, viewmodel) => viewmodel.isHabitArchived,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, isArchived, child) {
            final themeData = Theme.of(context);
            final colorData = themeData.extension<CustomColors>();
            final l10n = L10n.of(context);
            final color = colorType != null
                ? colorData?.getColor(colorType)
                : Colors.transparent;
            return AppBarActions<DetailAppbarActionItemConfig,
                DetailAppbarActionItemCell>(
              popupMenuButtonIcon: Icon(Icons.adaptive.more, color: color),
              actionConfigs: [
                DetailAppbarActionItemConfig.edit(
                    text: l10n?.habitDetail_editButton_tooltip ?? "Edit Habit",
                    color: color,
                    callback: _onAppbarEditActionPressed),
                DetailAppbarActionItemConfig.unarchive(
                    visible: isArchived,
                    text:
                        l10n?.habitDetail_editPopMenu_unarchive ?? "Unarchive",
                    callback: () => _openHabitUnarchiveConfirmDialog()),
                DetailAppbarActionItemConfig.archive(
                    visible: !isArchived,
                    text: l10n?.habitDetail_editPopMenu_archive ?? "Archive",
                    callback: () => _openHabitArchiveConfirmDialog()),
                DetailAppbarActionItemConfig.clone(
                    text: l10n?.habitDetail_editPopMenu_clone ?? "Clone",
                    callback: _onAppbarCloneActionPressed),
                DetailAppbarActionItemConfig.export(
                    text: l10n?.habitDetail_editPopMenu_export ?? "Export",
                    callback: () => _exportHabitAndShared(context)),
                DetailAppbarActionItemConfig.delete(
                    text: l10n?.habitDetail_editPopMenu_delete ?? "Delete",
                    callback: () => _openHabitDeleteConfirmDialog()),
              ],
            );
          },
        );
      }

      return Selector<HabitDetailViewModel, HabitColorType?>(
        selector: (context, viewmodel) => viewmodel.habitColorType,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, colorType, child) {
          return HabitDetailAppBar(
            colorType: colorType,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Selector<HabitDetailViewModel, String>(
                selector: (context, viewmodel) => viewmodel.habitName,
                shouldRebuild: (previous, next) => previous != next,
                builder: (context, title, child) => Text(title),
              ),
            ),
            actionBuilder: (context) => buildAppbarAction(context, colorType),
          );
        },
      );
    }

    Widget builSummaryTile(BuildContext context) {
      return Selector<HabitDetailViewModel, UniqueKey>(
        selector: (context, vm) => vm.getInsideVersion(),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, _, child) {
          final viewmodel = context.read<HabitDetailViewModel>();
          final durningDays = viewmodel.duringFromStartDate.inDays;
          appLog.build.debug(context,
              ex: [viewmodel.habitProgress], name: "$widget.SummaryList");
          return L10nBuilder(
            builder: (context, l10n) => HabitDetailSummaryTile(
              habitProgress: viewmodel.habitProgress,
              colorType: viewmodel.habitColorType,
              isHabitCompleted: viewmodel.isHabitCompleted,
              isHabitArchived: viewmodel.isHabitArchived,
              title: l10n != null
                  ? Text(l10n.habitDetail_summary_title)
                  : const Text("Summary"),
              subtitle: l10n != null
                  ? Text(durningDays >= 0
                      ? l10n.habitDetail_summary_body(
                          viewmodel.habitProgress.toStringAsFixed(2),
                          durningDays)
                      : l10n.habitDetail_summary_preBody(durningDays.abs()))
                  : null,
            ),
          );
        },
      );
    }

    Widget buildHeatmap(BuildContext context) {
      final viewmodel = context.read<HabitDetailViewModel>();

      final localeString = Localizations.localeOf(context).toLanguageTag();
      final endedDate = HabitDate.now();
      var startDate = endedDate.subtract(const Duration(days: 365 * 10));
      if (viewmodel.habitStartDate.isBefore(startDate)) {
        startDate = viewmodel.habitStartDate;
      }

      Widget buildHabitDescCellTile(BuildContext context, L10n? l10n) {
        final unit = viewmodel.habitDailyGoalUnit;
        final isUnitExist = unit != null && unit.isNotEmpty;

        TextSpan? getTooltipRichText(BuildContext context) {
          if (isUnitExist) return null;
          return TextSpan(
            text: l10n?.habitDetail_descDailyGoal_unitText(''),
            children: [
              TextSpan(
                text: l10n?.habitDetail_descDailyGoal_unitEmptyText,
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          );
        }

        return HabitDescCellTile(
          titleText: l10n?.habitDetail_descDailyGoal_titleText(
                  viewmodel.habitType?.dbCode ?? 0) ??
              "Goal",
          subtitleText: viewmodel.habitOkValue?.toSimpleString() ?? '',
          tooltipText: isUnitExist
              ? l10n?.habitDetail_descDailyGoal_unitText(unit)
              : null,
          tooltipRichText: getTooltipRichText(context),
        );
      }

      Widget buildDescTargetDaysTile(BuildContext context, L10n? l10n) {
        return HabitDescCellTile(
          titleText: l10n?.habitDetail_descTargetDays_titleText(
                  viewmodel.habitType?.dbCode ?? 0) ??
              "Days",
          subtitleText: "${viewmodel.habitTargetDays!}"
              "${l10n?.habitDetail_descTargetDays_unitText ?? ''}",
        );
      }

      Widget buildDescRecordsNumTile(BuildContext context, L10n? l10n) {
        return Selector<HabitDetailViewModel, UniqueKey>(
          selector: (context, viewmodel) => viewmodel.getInsideVersion(),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) => HabitDescCellTile(
            titleText: L10n.of(context)?.habitDetail_descRecordsNum_titleText ??
                'Records',
            subtitleText: "${viewmodel.habitRecordsTotalNum}",
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen =
              constraints.maxWidth > kHabitLargeScreenAdaptWidth;
          final l10n = L10n.of(context);
          return HabitHeatmap(
            firstday: viewmodel.firstday,
            descDailyGoalWidget: buildHabitDescCellTile(context, l10n),
            descTargetDaysWidget: buildDescTargetDaysTile(context, l10n),
            descRecordsNumWidget: buildDescRecordsNumTile(context, l10n),
            padding: kHabitDetailWidgetPadding.copyWith(top: 16.0),
            isLargeScreen: isLargeScreen,
            startDate: startDate,
            endedDate: endedDate,
            colorMap: buildHeatmapColorMap(context),
            valueColorMap: buildHeatmapValueColorMap(context),
            selectedMap: viewmodel.heatmapDateToColorMap,
            colorTipLeftHelperText: l10n?.habitDetail_heatmap_leftHelpText(
                    viewmodel.habitType?.dbCode ?? 0) ??
                "",
            colorTipRightHelperText: l10n?.habitDetail_heatmap_rightHelpText(
                    viewmodel.habitType?.dbCode ?? 0) ??
                "",
            heatmapWeekLabelValueBuilder: (context, protoDate, defaultFormat) {
              ThemeData themeData = Theme.of(context);
              return FittedBox(
                child: Text(
                  DateFormat(defaultFormat, localeString).format(protoDate),
                  style: TextStyle(color: themeData.colorScheme.outlineVariant),
                ),
              );
            },
            heatmapMonthLabelItemBuilder: (context, date, defaultFormat) {
              ThemeData themeData = Theme.of(context);
              TextTheme textTheme = themeData.textTheme;
              return Text(
                DateFormat(defaultFormat, localeString).format(date),
                style: textTheme.labelSmall
                    ?.copyWith(color: themeData.colorScheme.outline),
              );
            },
            heatmapCellBuilder:
                (context, childBuilder, columnIndex, rowIndex, date) {
              return Selector<HabitDetailViewModel, HabitHeatmapCellStatus>(
                selector: (context, vm) =>
                    vm.getHabitHeatmapCellStatus(HabitDate.dateTime(date)),
                shouldRebuild: (previous, next) => previous != next,
                builder: (context, value, _) => childBuilder(context),
              );
            },
          );
        },
      );
    }

    Widget buildScoreChartTile(BuildContext context) {
      Widget buildChart(
        BuildContext context,
        List<MapEntry<HabitDate, HabitDetailScoreChartDate>> data,
        double eachSize,
        int? limit,
        ValueKey<String>? chartKey,
      ) {
        ThemeData themeData = Theme.of(context);
        TextTheme textTheme = themeData.textTheme;

        var chartvm = context.read<HabitDetailScoreChartViewModel>();
        var direction = chartvm.consumeCachedAnimateDirection();
        var chart = HabitScoreChart(
          key: chartKey,
          height: kHabitDetailFreqChartHeight,
          eachSize: eachSize,
          limit: limit,
          combine: chartvm.chartCombine,
          bottomTipsTextStyle: textTheme.labelSmall
              ?.copyWith(color: themeData.colorScheme.outline),
          leftTipsTextStyle: textTheme.labelSmall
              ?.copyWith(color: themeData.colorScheme.outline),
          colorMap: buildHeatmapColorMap(context),
          data: data,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: direction != null
              ? (Widget child, Animation<double> animation) => SlideTransitionX(
                    direction: direction,
                    position: animation,
                    child: child,
                  )
              : AnimatedSwitcher.defaultTransitionBuilder,
          child: chart,
        );
      }

      return Consumer<HabitDetailScoreChartViewModel>(
        builder: (context, chartvm, child) => LayoutBuilder(
          builder: (context, constraints) {
            final double textScaleFactor =
                math.min(MediaQuery.textScaleFactorOf(context), 1.3);
            var now = HabitDate.now();
            return HabitDetailScoreChart(
              padding: kHabitDetailWidgetPadding,
              eachSize: 48.0,
              allowWidth: constraints.maxWidth,
              titleHeight: kHabitDetailFreqChartTitleHeight *
                  math.max(1.0, textScaleFactor),
              getFirstDate: (limit) =>
                  chartvm.getCurrentChartFirstDate(now, limit),
              getLastDate: (limit) =>
                  chartvm.getCurrentChartLastDate(now, limit),
              startDate: getProtoDateByScoreChartCombine(
                context.read<HabitDetailViewModel>().habitStartDate,
                chartvm.chartCombine,
                context.read<AppFirstDayViewModel>().firstDay,
              ),
              getData: (firstDate, lastDate) =>
                  chartvm.getCurrentOffsetChartData(
                initDate: now,
                firstDate: firstDate,
                lastDate: lastDate,
              ),
              chartCombine: chartvm.chartCombine,
              onPopMenuSelected: (combine) {
                if (!mounted) return;
                final viewmodel = context.read<HabitDetailViewModel>();
                if (!viewmodel.mounted) return;
                viewmodel.scoreChartCombine = combine;
              },
              chartBuilder: buildChart,
            );
          },
        ),
      );
    }

    Widget buildFreqChartTile(BuildContext context) {
      Widget buildChart(
        BuildContext context,
        List<MapEntry<HabitDate, HabitDetailFreqChartData>> data, {
        required double eachSize,
        required double barWidth,
        required double barSpaceBetween,
        required HabitFreqChartDisplayMethod displayMethod,
        AxisDirection? animatedDirection,
        ValueKey<String>? chartKey,
      }) {
        ThemeData themeData = Theme.of(context);
        TextTheme textTheme = themeData.textTheme;

        var chartvm = context.read<HabitDetailFreqChartViewModel>();
        var chart = HabitFreqChart(
          key: chartKey,
          height: kHabitDetailFreqChartHeight,
          eachSize: eachSize,
          barWidth: barWidth,
          colorMap: buildHeatmapColorMap(context),
          combine: chartvm.chartCombine,
          bottomTipsTextStyle: textTheme.labelSmall
              ?.copyWith(color: themeData.colorScheme.outline),
          data: data,
          displayMethod: displayMethod,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: animatedDirection != null
              ? (Widget child, Animation<double> animation) => SlideTransitionX(
                    direction: animatedDirection,
                    position: animation,
                    child: child,
                  )
              : AnimatedSwitcher.defaultTransitionBuilder,
          child: chart,
        );
      }

      return Consumer2<HabitDetailFreqChartViewModel,
          AppCustomDateYmdHmsConfigViewModel>(
        builder: (context, chartvm, configvm, child) => LayoutBuilder(
          builder: (context, constraints) {
            final double textScaleFactor =
                math.min(MediaQuery.textScaleFactorOf(context), 1.3);

            var viewmodel = context.read<HabitDetailViewModel>();
            var now = HabitDate.now();

            bool isLargeScreen =
                constraints.maxWidth > kHabitLargeScreenAdaptWidth;
            var animatedDirection = chartvm.consumeCachedAnimateDirection();

            return HabitDetailFreqChart(
              padding: kHabitDetailWidgetPadding,
              eachSize: 48.0,
              barWidth: 14.0,
              barSpaceBetween: 2.0,
              allowWidth: isLargeScreen
                  ? (constraints.maxWidth - _largeScreenTwoChartBetween) / 2
                  : constraints.maxWidth,
              titleHeight: kHabitDetailFreqChartTitleHeight *
                  math.max(1.0, textScaleFactor),
              largeScreenTwoChartBetween: _largeScreenTwoChartBetween,
              getFirstDate: (limit) =>
                  chartvm.getCurrentChartFirstDate(now, limit),
              getLastDate: (limit) =>
                  chartvm.getCurrentChartLastDate(now, limit),
              habitStartDate: viewmodel.habitStartDate,
              chartCombine: chartvm.chartCombine,
              isLargeScreen: isLargeScreen,
              isChartExpanded: chartvm.isChartExpanded,
              getData: (firstDate, lastDate, limit) =>
                  chartvm.getCurrentOffsetChartData(
                limit: limit,
                initDate: now,
                firstDate: firstDate,
                lastDate: lastDate,
              ),
              onPopMenuSelected: (combine) {
                if (!mounted) return;
                var viewmodel = context.read<HabitDetailViewModel>();
                if (!viewmodel.mounted) return;
                viewmodel.freqChartCombine = combine;
              },
              countChartBuilder: (context, data, eachSize, barWidth,
                      barSpaceBetween, displayMethod, chartKey) =>
                  buildChart(
                context,
                data,
                eachSize: eachSize,
                barWidth: barWidth,
                barSpaceBetween: barSpaceBetween,
                chartKey: chartKey,
                displayMethod: displayMethod,
                animatedDirection: animatedDirection,
              ),
              valueChartBuilder: (context, data, eachSize, barWidth,
                      barSpaceBetween, displayMethod, chartKey) =>
                  buildChart(
                context,
                data,
                eachSize: eachSize,
                barWidth: barWidth,
                barSpaceBetween: barSpaceBetween,
                chartKey: chartKey,
                displayMethod: displayMethod,
                animatedDirection: animatedDirection,
              ),
              offset: chartvm.offset,
              getLeftDateHelper:
                  (context, firstDate, lastDate, isToday, isLast) {
                final l10n = L10n.of(context);
                switch (chartvm.chartCombine) {
                  case HabitDetailFreqChartCombine.monthly:
                    return Text(configvm.config
                        .getYMFormatterForFreqChart(l10n?.localeName)
                        .format(lastDate));
                  case HabitDetailFreqChartCombine.yearly:
                    return Text(configvm.config
                        .getYFormatterForFreqChart(l10n?.localeName)
                        .format(lastDate));
                  case HabitDetailFreqChartCombine.weekly:
                    return Text(configvm.config
                        .getYMDFormatterForFreqChart(l10n?.localeName)
                        .format(lastDate));
                }
              },
              getRightDateHelper:
                  (context, firstDate, lastDate, isToday, isLast) {
                final l10n = L10n.of(context);
                if (isToday) {
                  return l10n != null
                      ? Text(l10n.habitDetail_freqChartNaviBar_nowText)
                      : const Text("Now");
                }
                switch (chartvm.chartCombine) {
                  case HabitDetailFreqChartCombine.monthly:
                    return Text(configvm.config
                        .getYMFormatterForFreqChart(l10n?.localeName)
                        .format(firstDate));
                  case HabitDetailFreqChartCombine.yearly:
                    return Text(configvm.config
                        .getYFormatterForFreqChart(l10n?.localeName)
                        .format(firstDate));
                  case HabitDetailFreqChartCombine.weekly:
                    return Text(configvm.config
                        .getYMDFormatterForFreqChart(l10n?.localeName)
                        .format(firstDate));
                }
              },
              onLeftButtonPressed: () {
                if (!mounted) return;
                context.read<HabitDetailFreqChartViewModel>().offset += 1;
              },
              onRightButtonPressed: () {
                if (!mounted) return;
                context.read<HabitDetailFreqChartViewModel>().offset -= 1;
              },
              onExpandIconPressed: (value) {
                if (!mounted) return;
                context.read<HabitDetailFreqChartViewModel>().isChartExpanded =
                    !value;
              },
            );
          },
        ),
      );
    }

    Widget buildDescInfo(BuildContext conetxt) {
      return const _HabitDescTileList();
    }

    Widget buildOtherInfo(BuildContext context) {
      return const _HabitDetailOtherTileList();
    }

    Widget buildFAB(BuildContext context) {
      return Selector<HabitDetailViewModel, HabitColorType?>(
        selector: (context, viewmodel) => viewmodel.habitColorType,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, habitColorType, child) => HabitDetailFAB(
          colorType: habitColorType ?? widget.colorType,
          onPressed: () => _openEditDialog(),
        ),
      );
    }

    Widget buildBody(BuildContext context) {
      return Selector<HabitDetailViewModel, bool>(
        selector: (context, viewmodel) => viewmodel.reloadDBToggleSwich,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, _, child) {
          var viewmodel = context.read<HabitDetailViewModel>();

          Future<HabitDetailLoadDataResult> loadData() async {
            var loadedFuture =
                viewmodel.loadData(widget.habitUUID, inFutureBuilder: true);
            await Future.delayed(_kHabitDetailFutureLoadDuration);
            return await loadedFuture;
          }

          Future<HabitDetailLoadDataResult>? getFuture() {
            viewmodel.dataloadingFutureCache ??= loadData();
            return viewmodel.dataloadingFutureCache;
          }

          return FutureBuilder(
            future: getFuture(),
            builder: (context, snapshot) {
              appLog.load.debug("$widget.buildBody",
                  ex: ["Loading detail data", snapshot.connectionState]);

              if (kDebugMode && snapshot.isDone) {
                appLog.load.debug("$widget.buildBody",
                    ex: ["Loaded", viewmodel.debugGetDataString()]);
              }

              Widget switcherWidget;

              if (snapshot.inProgress) {
                switcherWidget = SliverFillRemaining(
                  key: ValueKey<ConnectionState>(snapshot.connectionState),
                  hasScrollBody: false,
                  child: HabitDetailLoadingIndicator(
                    size: const Size.square(
                        kHabitDetailLoadingCircleIndicatorSize),
                    colorType: viewmodel.habitColorType,
                  ),
                );
              } else if (snapshot.isDone &&
                  snapshot.data == HabitDetailLoadDataResult.habitMissing) {
                switcherWidget = SliverFillRemaining(
                  hasScrollBody: false,
                  child: L10nBuilder(
                    builder: (context, l10n) {
                      final theme = Theme.of(context);
                      return NotFoundImage(
                        size: const Size.square(300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 50),
                        style: NotFoundImageStyle.inDefault.copyWith(
                          backBoardBackgroundColor:
                              theme.colorScheme.outlineVariant.lighten(0.16),
                          backBoardPaperColor:
                              theme.colorScheme.primaryContainer,
                          fronBoardPaperColor:
                              theme.colorScheme.primary.lighten(0.16),
                          fronBoardPaperShadowColor:
                              theme.colorScheme.outlineVariant,
                          magnifierHandleColor:
                              theme.colorScheme.errorContainer,
                          magnifierStrokeColor:
                              theme.colorScheme.errorContainer,
                        ),
                        descChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (l10n != null)
                              Text(l10n.habitDetail_notFoundText),
                            TextButton(
                              onPressed: _openRetryButtonPressed,
                              child: l10n != null
                                  ? Text(l10n.habitDetail_notFoundRetryText)
                                  : const Text("Try Again"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                switcherWidget = SliverList(
                  delegate: SliverChildListDelegate([
                    builSummaryTile(context),
                    buildHeatmap(context),
                    _div,
                    buildScoreChartTile(context),
                    _div,
                    buildFreqChartTile(context),
                    if (context
                        .read<HabitDetailViewModel>()
                        .habitDesc
                        .isNotEmpty) ...[
                      _div,
                      buildDescInfo(context),
                    ],
                    _div,
                    buildOtherInfo(context),
                    if (context
                        .read<AppDeveloperViewModel>()
                        .isInDevelopMode) ...[
                      _div,
                      _buildDebugInfo(context),
                    ],
                    const FixedPagePlaceHolder(),
                  ]),
                );
              }

              return SliverAnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: switcherWidget,
              );
            },
          );
        },
      );
    }

    return ColorfulNavibar(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            buildAppbar(context),
            EnhancedSafeArea.edgeToEdgeSafe(
              withSliver: true,
              child: buildBody(context),
            ),
            if (kDebugMode) _buildScrollablePlaceHolder(context),
          ],
        ),
        floatingActionButton: buildFAB(context),
      ),
    );
  }
}

class _HabitDetailTileListFramework extends StatelessWidget {
  final Widget? title;
  final List<Widget>? contentChildren;

  const _HabitDetailTileListFramework({
    this.title,
    this.contentChildren,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 1.3);
    final titleHeight =
        kHabitDetailFreqChartTitleHeight * math.max(1.0, textScaleFactor);

    return Padding(
      padding: kHabitDetailWidgetPadding,
      child: Column(
        children: [
          if (title != null)
            ConstrainedBox(
              constraints: BoxConstraints.tightFor(height: titleHeight),
              child: title,
            ),
          ...?contentChildren,
        ],
      ),
    );
  }
}

class _HabitDescTileList extends StatelessWidget {
  const _HabitDescTileList();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final viewmodel = context.read<HabitDetailViewModel>();
    final textScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 1.3);
    final descMinHeight =
        kHabitDetailFreqChartTitleHeight * math.max(1.0, textScaleFactor);

    return _HabitDetailTileListFramework(
      title: HabitDetailChartTitle(
          title: l10n?.habitDetail_descSubgroup_title ?? "Desc"),
      contentChildren: [
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: descMinHeight, minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ThematicMarkdownBody(
              data: viewmodel.habitDesc,
              colorType: viewmodel.habitColorType,
              textScaleFactor: textScaleFactor,
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitDetailOtherTileList extends StatelessWidget {
  const _HabitDetailOtherTileList();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final viewmodel = context.read<HabitDetailViewModel>();

    return _HabitDetailTileListFramework(
      title: HabitDetailChartTitle(
          title: l10n?.habitDetail_otherSubgroup_title ?? "Others"),
      contentChildren: [
        if (viewmodel.habitType != null)
          HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_habitType_title)
                : const Text("Habit Type"),
            subTitle: Text(viewmodel.habitType!.getTypeName(l10n)),
            leading: Icon(viewmodel.habitType!.getIcon()),
          ),
        // reminder
        if (viewmodel.habitDetailData?.data.reminder != null)
          HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_reminderTile_title)
                : const Text("Reminder"),
            subTitle: Text(viewmodel.habitDetailData?.data.reminder
                    ?.getReminderTypeHelperText(l10n) ??
                ''),
            leading: const Icon(Icons.notifications_outlined),
          ),
        // frequency
        if (viewmodel.habitDetailData != null)
          HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_freqTile_title)
                : const Text("Frequency"),
            subTitle: Text(l10n != null
                ? viewmodel.habitDetailData!.data.frequency.toLocalString(l10n)
                : viewmodel.habitDetailData!.data.frequency.toString()),
            leading: const Icon(Icons.repeat_outlined),
          ),
        // start date
        Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
          selector: (context, vm) => vm.config,
          builder: (context, config, child) => HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_startDateTile_title)
                : const Text("Start Date"),
            subTitle: Text(config
                .getYMDFormatter(l10n?.localeName)
                .format(viewmodel.habitStartDate)),
            leading: const Icon(Icons.schedule_outlined),
          ),
        ),
        // create date
        if (viewmodel.habitDetailData != null)
          Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
            selector: (context, vm) => vm.config,
            builder: (context, config, child) => HabitOtherInfoTile(
              title: l10n != null
                  ? Text(l10n.habitDetail_createDateTile_title)
                  : const Text("Created"),
              subTitle: Text(config
                  .getFormatter(l10n?.localeName)
                  .format(viewmodel.habitDetailData!.createT)),
              leading: const Icon(HabitCalIcons.calendar_create),
            ),
          ),
        // modified date
        if (viewmodel.habitDetailData != null)
          Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
            selector: (context, vm) => vm.config,
            builder: (context, config, child) => HabitOtherInfoTile(
              title: l10n != null
                  ? Text(l10n.habitDetail_modifyDateTile_title)
                  : const Text("Modified"),
              subTitle: Text(config
                  .getFormatter(l10n?.localeName)
                  .format(viewmodel.habitDetailData!.modifyT)),
              leading: const Icon(HabitCalIcons.calendar_modify),
              padding: const EdgeInsets.only(bottom: 6.0),
            ),
          ),
      ],
    );
  }
}
