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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../extensions/async_extensions.dart';
import '../../extensions/color_extensions.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/custom_color_extensions.dart';
import '../../extensions/num_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/app_event.dart';
import '../../models/custom_date_format.dart';
import '../../models/habit_date.dart';
import '../../models/habit_detail_chart.dart';
import '../../models/habit_display.dart';
import '../../models/habit_form.dart';
import '../../models/habit_status.dart';
import '../../providers/app_custom_date_format.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_event.dart';
import '../../providers/app_first_day.dart';
import '../../providers/app_sync.dart';
import '../../providers/habit_detail.dart';
import '../../providers/habit_detail_freqchart.dart';
import '../../providers/habit_detail_scorechart.dart';
import '../../providers/habit_summary.dart' as habit_summary;
import '../../providers/habits_file_exporter.dart';
import '../../providers/utils.dart';
import '../../storage/db/handlers/habit.dart';
import '../../theme/color.dart';
import '../../theme/icon.dart';
import '../../utils/xshare.dart';
import '../../widgets/animations.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widgets.dart';
import '../common/debug.dart';
import '../common/widgets.dart';
import '../habit_edit/page.dart' as habit_edit;
import 'widgets.dart';

const _largeScreenTwoChartBetween = 16.0;

Future<DetailPageReturn?> naviToHabitDetailPage({
  required BuildContext context,
  required HabitUUID habitUUID,
  HabitColorType? colorType,
  habit_summary.HabitSummaryViewModel? summary,
}) async {
  return Navigator.of(context).push<DetailPageReturn>(
    MaterialPageRoute(
      builder: (context) => Provider.value(
        value: summary?.buildHabitDetailAdapter(),
        child: HabitDetailPage(habitUUID: habitUUID, colorType: colorType),
      ),
    ),
  );
}

extension _AppEventViewModelExtension on AppEventViewModel {
  void pushHabitChangeStatus(HabitStatusChangedRecord result, {String? msg}) {
    push(
      HabitStatusChangedEvent(
        msg: msg,
        uuidList: [result.habitUUID],
        status: result.newStatus,
        trace: {
          AppEventPageSource.habitDetail: const {
            AppEventFunctionSource.habitChanged,
          },
        },
      ),
    );
  }
}

/// Depend Providers
/// - Required for builder:
///   - [AppFirstDayViewModel]
/// - Required for callback:
///   - [HabitFileExporterViewModel]
/// - Optional:
///   - [habit_summary.HabitDetailAdapter]
class HabitDetailPage extends StatelessWidget {
  final HabitUUID habitUUID;
  final HabitColorType? colorType;

  const HabitDetailPage({super.key, required this.habitUUID, this.colorType});

  @override
  Widget build(BuildContext context) {
    return PageProviders(
      child: _Page(habitUUID: habitUUID, colorType: colorType),
    );
  }
}

class _Page extends StatefulWidget {
  final HabitUUID habitUUID;
  final HabitColorType? colorType;

  const _Page({required this.habitUUID, this.colorType});

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page>
    with HabitHeatmapColorChooseMixin<_Page>, XShare {
  late HabitDetailViewModel _vm;
  habit_summary.HabitDetailAdapter? _summary;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    _vm = context.read<HabitDetailViewModel>();
    _summary = context.maybeRead<habit_summary.HabitDetailAdapter>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitDetailViewModel>();
    if (_vm != vm) {
      _vm = vm;
    }
    final summary = context.maybeRead<habit_summary.HabitDetailAdapter>();
    if (_summary != summary) {
      _summary = summary;
    }
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  Future<bool> _enterHabitEditPage({
    required HabitForm Function(HabitDBCell) formBuilder,
  }) async {
    if (!(mounted && _vm.mounted)) return false;
    final dbcell = await _vm.loadCurrentHabitDetail();
    if (dbcell == null || !mounted) return false;
    final form = formBuilder(dbcell);
    final result = await habit_edit.naviToHabitEidtPage(
      context: context,
      initForm: form,
    );
    if (result == null) return false;
    if (!(mounted && _vm.mounted)) return false;
    _vm.requestReload();
    if (_summary?.mounted != true) {
      context.read<AppEventViewModel>().push(
        const ReloadDataEvent(
          msg: "habit_detail._enterHabitEditPage",
          trace: {
            AppEventPageSource.habitDetail: {
              AppEventFunctionSource.habitChanged,
            },
          },
        ),
      );
    } else {
      _summary!.onHabitDataChanged();
      if (mounted && form.editMode == HabitDisplayEditMode.create) {
        Navigator.maybePop(context).then((popResult) {
          if (!popResult) appLog.navi.info("habit_detail", ex: ["didn't pop"]);
        });
      }
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
    if (!(mounted && _vm.mounted)) return;
    _vm.requestReload();
  }

  void _openEditDialog() async {
    if (!(mounted && _vm.mounted)) return;
    if (_vm.habitDetailData == null) return;
    final oldVersion = _vm.getInsideVersion();

    await showHabitEditReplacementRecordCalendarDialog(
      context: context,
      habitColorType: _vm.habitColorType,
      firstday: _vm.firstday,
      detail: _vm,
    );

    if (!(mounted && _vm.mounted)) return;
    if (_vm.getInsideVersion() == oldVersion) return;
    if (_summary?.mounted != true) {
      context.read<AppEventViewModel>().push(
        const ReloadDataEvent(
          msg: "habit_detail._openEditDialog",
          trace: {
            AppEventPageSource.habitDetail: {
              AppEventFunctionSource.recordChanged,
            },
          },
        ),
      );
    } else {
      _summary!.onHabitDataChanged();
    }
  }

  Future<bool?> _openHabitOpConfirmDialog(
    BuildContext context,
    Widget title,
  ) async {
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

  void _onHabitStatusChangeConfirmed({bool shouldSyncOnce = true}) {
    if (!mounted) return;
    // try sync once
    if (shouldSyncOnce) {
      final sync = context.maybeRead<AppSyncViewModel>();
      if (sync != null && sync.mounted) {
        sync.delayedStartTaskOnce(delay: kAppUndoDialogShowDuration * 2);
      }
    }
  }

  void _openHabitArchiveConfirmDialog() async {
    final result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_archiveConfirmDialog_titleText)
            : const Text("Archive Habit?"),
      ),
    );
    if (result == null || result == false || !mounted) return;
    if (_summary?.mounted != true) {
      final result = await _vm.onConfirmToArchiveHabit();
      if (result == null || !mounted) return;
      context.read<AppEventViewModel>().pushHabitChangeStatus(
        result,
        msg: "habit_detail._openHabitArchiveConfirmDialog",
      );
    } else {
      final habitUUID = _vm.habitUUID;
      if (habitUUID == null) return;
      await _summary!.onConfirmToArchiveHabit(habitUUID).whenComplete(() {
        if (!(mounted && _vm.mounted)) return;
        _vm.requestReload();
      });
    }

    _onHabitStatusChangeConfirmed();
  }

  void _openHabitUnarchiveConfirmDialog() async {
    final result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_unarchiveConfirmDialog_titleText)
            : const Text("Unarchive Habit?"),
      ),
    );
    if (result == null || result == false || !mounted) return;
    if (_summary?.mounted != true) {
      final result = await _vm.onConfirmToUnarchiveHabit();
      if (result == null || !mounted) return;
      context.read<AppEventViewModel>().pushHabitChangeStatus(
        result,
        msg: "habit_detail._openHabitUnarchiveConfirmDialog",
      );
    } else {
      final habitUUID = _vm.habitUUID;
      if (habitUUID == null) return;
      await _summary!.onConfirmToUnarchiveHabit(habitUUID).whenComplete(() {
        if (!(mounted && _vm.mounted)) return;
        _vm.requestReload();
      });
    }

    _onHabitStatusChangeConfirmed();
  }

  void _openHabitDeleteConfirmDialog() async {
    final result = await _openHabitOpConfirmDialog(
      context,
      L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDetail_deleteConfirmDialog_titleText)
            : const Text("Delete Habit?"),
      ),
    );
    if (result == null || result == false || !mounted) return;

    Future<HabitStatusChangedRecord?> exec() async {
      if (_summary?.mounted != true) {
        final changedRecord = await _vm.onConfirmToDeleteHabit();
        if (changedRecord == null || !mounted) return null;
        context.read<AppEventViewModel>().pushHabitChangeStatus(
          changedRecord,
          msg: "habit_detail._openHabitDeleteConfirmDialog",
        );
        return changedRecord;
      } else {
        final habitUUID = _vm.habitUUID;
        if (habitUUID == null) return null;
        return _summary!.onConfirmToDeleteHabit(habitUUID);
      }
    }

    final changedRecord = await exec();
    if (!(mounted && _vm.mounted)) return;
    Navigator.pop(
      context,
      DetailPageReturn(
        op: DetailPageReturnOpr.deleted,
        habitName: _vm.habitName,
        recordList: changedRecord != null ? [changedRecord] : null,
      ),
    );

    _onHabitStatusChangeConfirmed();
  }

  void _exportHabitAndShared(BuildContext context) async {
    HabitFileExporterViewModel fileExporter;

    if (!context.mounted) return;
    final confirmResult = await showExporterConfirmDialog(
      context: context,
      exportAll: false,
    );

    if (!context.mounted || confirmResult == null) return;
    fileExporter = context.read<HabitFileExporterViewModel>();
    final filePath = await fileExporter.exportHabitData(
      widget.habitUUID,
      withRecords: confirmResult == ExporterConfirmResultType.withRecords,
    );
    if (!context.mounted || filePath == null) return;
    trySaveFiles(
      [XFile(filePath)],
      defaultTargetPlatform,
      context: context,
      text: 'Export Habit',
    ).then((result) {
      context = this.context;
      if (!(result && context.mounted)) return;
      final snackBar = buildSnackBarWithDismiss(
        context,
        content: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.habitDisplay_exportHabitsSuccSnackbarText(1))
              : const Text('Exported habits'),
        ),
        duration: kAppUndoDialogShowDuration,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    });
  }

  Widget _buildDebugInfo(BuildContext context) {
    assert(kDebugMode);
    return Builder(
      builder: (context) {
        final viewmodel = context.read<HabitDetailViewModel>();
        return ListTile(
          leading: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
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
    return SliverList(delegate: debugBuildSliverScrollDelegate(childCount: 0));
  }

  @visibleForTesting
  Future<void> loadData() async {
    if (!mounted) return;
    final minBarShowTimeFuture = Future.delayed(kHabitDetailFutureLoadDuration);
    if (!_vm.isDataLoading) {
      await Future.wait([_vm.loadData(widget.habitUUID), minBarShowTimeFuture]);
    }
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    Widget buildAppbar(BuildContext context) {
      Widget buildAppbarAction(
        BuildContext context,
        HabitColorType? colorType,
      ) {
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
            return AppBarActions<
              DetailAppbarActionItemConfig,
              DetailAppbarActionItemCell
            >(
              popupMenuButtonIcon: Icon(Icons.adaptive.more, color: color),
              actionConfigs: [
                DetailAppbarActionItemConfig.edit(
                  text: l10n?.habitDetail_editButton_tooltip ?? "Edit Habit",
                  color: color,
                  callback: _onAppbarEditActionPressed,
                ),
                DetailAppbarActionItemConfig.unarchive(
                  visible: isArchived,
                  text: l10n?.habitDetail_editPopMenu_unarchive ?? "Unarchive",
                  callback: _openHabitUnarchiveConfirmDialog,
                ),
                DetailAppbarActionItemConfig.archive(
                  visible: !isArchived,
                  text: l10n?.habitDetail_editPopMenu_archive ?? "Archive",
                  callback: _openHabitArchiveConfirmDialog,
                ),
                DetailAppbarActionItemConfig.clone(
                  text: l10n?.habitDetail_editPopMenu_clone ?? "Clone",
                  callback: _onAppbarCloneActionPressed,
                ),
                DetailAppbarActionItemConfig.export(
                  text: l10n?.habitDetail_editPopMenu_export ?? "Export",
                  callback: () => _exportHabitAndShared(context),
                ),
                DetailAppbarActionItemConfig.delete(
                  text: l10n?.habitDetail_editPopMenu_delete ?? "Delete",
                  callback: _openHabitDeleteConfirmDialog,
                ),
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
      return Selector<HabitDetailViewModel, Key>(
        selector: (context, vm) => vm.getInsideVersion(),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, _, child) {
          final viewmodel = context.read<HabitDetailViewModel>();
          final durningDays = viewmodel.duringFromStartDate.inDays;
          appLog.build.debug(
            context,
            ex: [viewmodel.habitProgress],
            name: "$widget.SummaryList",
          );
          return L10nBuilder(
            builder: (context, l10n) => HabitDetailSummaryTile(
              habitProgress: viewmodel.habitProgress,
              colorType: viewmodel.habitColorType,
              isHabitCompleted: viewmodel.isHabitCompleted,
              isHabitArchived: viewmodel.isHabitArchived,
              isHabitDeleted: viewmodel.isHabitDeleted,
              title: l10n != null
                  ? Text(l10n.habitDetail_summary_title)
                  : const Text("Summary"),
              subtitle: l10n != null
                  ? Text(
                      durningDays >= 0
                          ? l10n.habitDetail_summary_body(
                              viewmodel.habitProgress.toStringAsFixed(2),
                              durningDays,
                            )
                          : l10n.habitDetail_summary_preBody(durningDays.abs()),
                    )
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
              ),
            ],
          );
        }

        return HabitDescCellTile(
          titleText:
              l10n?.habitDetail_descDailyGoal_titleText(
                viewmodel.habitType?.dbCode ?? 0,
              ) ??
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
          titleText:
              l10n?.habitDetail_descTargetDays_titleText(
                viewmodel.habitType?.dbCode ?? 0,
              ) ??
              "Days",
          subtitleText:
              "${viewmodel.habitTargetDays!}"
              "${l10n?.habitDetail_descTargetDays_unitText ?? ''}",
        );
      }

      Widget buildDescRecordsNumTile(BuildContext context, L10n? l10n) {
        return Selector<HabitDetailViewModel, Key>(
          selector: (context, viewmodel) => viewmodel.getInsideVersion(),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) => HabitDescCellTile(
            titleText:
                L10n.of(context)?.habitDetail_descRecordsNum_titleText ??
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
            colorTipLeftHelperText:
                l10n?.habitDetail_heatmap_leftHelpText(
                  viewmodel.habitType?.dbCode ?? 0,
                ) ??
                "",
            colorTipRightHelperText:
                l10n?.habitDetail_heatmap_rightHelpText(
                  viewmodel.habitType?.dbCode ?? 0,
                ) ??
                "",
            heatmapWeekLabelValueBuilder: (context, protoDate, defaultFormat) {
              final ThemeData themeData = Theme.of(context);
              return FittedBox(
                child: Text(
                  DateFormat(defaultFormat, localeString).format(protoDate),
                  style: TextStyle(color: themeData.colorScheme.outlineVariant),
                ),
              );
            },
            heatmapMonthLabelItemBuilder: (context, date, defaultFormat) {
              final ThemeData themeData = Theme.of(context);
              final TextTheme textTheme = themeData.textTheme;
              return Text(
                DateFormat(defaultFormat, localeString).format(date),
                style: textTheme.labelSmall?.copyWith(
                  color: themeData.colorScheme.outline,
                ),
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
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;

        final chartvm = context.read<HabitDetailScoreChartViewModel>();
        final direction = chartvm.consumeCachedAnimateDirection();
        final chart = HabitScoreChart(
          key: chartKey,
          height: kHabitDetailFreqChartHeight,
          eachSize: eachSize,
          limit: limit,
          combine: chartvm.chartCombine,
          bottomTipsTextStyle: textTheme.labelSmall?.copyWith(
            color: themeData.colorScheme.outline,
          ),
          leftTipsTextStyle: textTheme.labelSmall?.copyWith(
            color: themeData.colorScheme.outline,
          ),
          colorMap: buildHeatmapColorMap(context),
          data: data,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: direction != null
              ? (child, animation) => SlideTransitionX(
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
            final now = HabitDate.now();
            return HabitDetailScoreChart(
              padding: kHabitDetailWidgetPadding,
              eachSize: 48.0,
              allowWidth: constraints.maxWidth,
              titleHeight: MediaQuery.textScalerOf(context)
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)
                  .scale(kHabitDetailFreqChartTitleHeight),
              getFirstDate: (limit) =>
                  chartvm.getCurrentChartFirstDate(now, limit),
              getLastDate: (limit) =>
                  chartvm.getCurrentChartLastDate(now, limit),
              startDate: scoreChartHelp.getProtoDate(
                context.read<HabitDetailViewModel>().habitStartDate,
                context.read<AppFirstDayViewModel>().firstDay,
                chartvm.chartCombine,
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
                viewmodel.updateScoreChartCombine(combine);
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
        final ThemeData themeData = Theme.of(context);
        final TextTheme textTheme = themeData.textTheme;

        final chartvm = context.read<HabitDetailFreqChartViewModel>();
        final chart = HabitFreqChart(
          key: chartKey,
          height: kHabitDetailFreqChartHeight,
          eachSize: eachSize,
          barWidth: barWidth,
          colorMap: buildHeatmapColorMap(context),
          combine: chartvm.chartCombine,
          bottomTipsTextStyle: textTheme.labelSmall?.copyWith(
            color: themeData.colorScheme.outline,
          ),
          data: data,
          displayMethod: displayMethod,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: animatedDirection != null
              ? (child, animation) => SlideTransitionX(
                  direction: animatedDirection,
                  position: animation,
                  child: child,
                )
              : AnimatedSwitcher.defaultTransitionBuilder,
          child: chart,
        );
      }

      return Consumer2<
        HabitDetailFreqChartViewModel,
        AppCustomDateYmdHmsConfigViewModel
      >(
        builder: (context, chartvm, configvm, child) => LayoutBuilder(
          builder: (context, constraints) {
            final viewmodel = context.read<HabitDetailViewModel>();
            final now = HabitDate.now();

            final isLargeScreen =
                constraints.maxWidth > kHabitLargeScreenAdaptWidth;
            final animatedDirection = chartvm.consumeCachedAnimateDirection();

            return HabitDetailFreqChart(
              padding: kHabitDetailWidgetPadding,
              eachSize: 48.0,
              barWidth: 14.0,
              barSpaceBetween: 2.0,
              allowWidth: isLargeScreen
                  ? (constraints.maxWidth - _largeScreenTwoChartBetween) / 2
                  : constraints.maxWidth,
              titleHeight: MediaQuery.textScalerOf(context)
                  .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)
                  .scale(kHabitDetailFreqChartTitleHeight),
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
                final viewmodel = context.read<HabitDetailViewModel>();
                if (!viewmodel.mounted) return;
                viewmodel.updateFreqChartCombine(combine);
              },
              countChartBuilder:
                  (
                    context,
                    data,
                    eachSize,
                    barWidth,
                    barSpaceBetween,
                    displayMethod,
                    chartKey,
                  ) => buildChart(
                    context,
                    data,
                    eachSize: eachSize,
                    barWidth: barWidth,
                    barSpaceBetween: barSpaceBetween,
                    chartKey: chartKey,
                    displayMethod: displayMethod,
                    animatedDirection: animatedDirection,
                  ),
              valueChartBuilder:
                  (
                    context,
                    data,
                    eachSize,
                    barWidth,
                    barSpaceBetween,
                    displayMethod,
                    chartKey,
                  ) => buildChart(
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
                        return Text(
                          configvm.config
                              .getYMFormatterForFreqChart(l10n?.localeName)
                              .format(lastDate),
                        );
                      case HabitDetailFreqChartCombine.yearly:
                        return Text(
                          configvm.config
                              .getYFormatterForFreqChart(l10n?.localeName)
                              .format(lastDate),
                        );
                      case HabitDetailFreqChartCombine.weekly:
                        return Text(
                          configvm.config
                              .getYMDFormatterForFreqChart(l10n?.localeName)
                              .format(lastDate),
                        );
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
                        return Text(
                          configvm.config
                              .getYMFormatterForFreqChart(l10n?.localeName)
                              .format(firstDate),
                        );
                      case HabitDetailFreqChartCombine.yearly:
                        return Text(
                          configvm.config
                              .getYFormatterForFreqChart(l10n?.localeName)
                              .format(firstDate),
                        );
                      case HabitDetailFreqChartCombine.weekly:
                        return Text(
                          configvm.config
                              .getYMDFormatterForFreqChart(l10n?.localeName)
                              .format(firstDate),
                        );
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
      return const HabitDetailDescTile();
    }

    Widget buildOtherInfo(BuildContext context) {
      return const _OtherInfo();
    }

    Widget buildFAB(BuildContext context) {
      return Selector<HabitDetailViewModel, HabitColorType?>(
        selector: (context, viewmodel) => viewmodel.habitColorType,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, habitColorType, child) => HabitDetailFAB(
          colorType: habitColorType ?? widget.colorType,
          onPressed: _openEditDialog,
        ),
      );
    }

    Widget buildBody(BuildContext context) {
      return Selector<HabitDetailViewModel, bool>(
        selector: (context, viewmodel) => viewmodel.isDataLoading,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, _, child) {
          return FutureBuilder(
            future: loadData(),
            builder: (context, snapshot) {
              final viewmodel = context.read<HabitDetailViewModel>();
              // appLog.load.debug("$widget.buildBody",
              //     ex: ["Loading detail data", snapshot.connectionState]);

              // if (kDebugMode && snapshot.isDone) {
              //   appLog.load.debug("$widget.buildBody",
              //       ex: ["Loaded", viewmodel.debugGetDataString()]);
              // }

              final Widget switcherWidget;

              if (snapshot.inProgress) {
                switcherWidget = SliverFillRemaining(
                  key: ValueKey<ConnectionState>(snapshot.connectionState),
                  hasScrollBody: false,
                  child: PageLoadingIndicator(
                    size: const Size.square(
                      kHabitDetailLoadingCircleIndicatorSize,
                    ),
                    colorType: viewmodel.habitColorType,
                  ),
                );
              } else if (snapshot.hasError) {
                switcherWidget = SliverFillRemaining(
                  hasScrollBody: false,
                  child: L10nBuilder(
                    builder: (context, l10n) {
                      final theme = Theme.of(context);
                      return NotFoundImage(
                        size: const Size.square(300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 50,
                        ),
                        style: NotFoundImageStyle.inDefault.copyWith(
                          backBoardBackgroundColor: theme
                              .colorScheme
                              .outlineVariant
                              .lighten(0.16),
                          backBoardPaperColor:
                              theme.colorScheme.primaryContainer,
                          fronBoardPaperColor: theme.colorScheme.primary
                              .lighten(0.16),
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
                    kHabitDivider,
                    buildScoreChartTile(context),
                    kHabitDivider,
                    buildFreqChartTile(context),
                    if (context
                        .read<HabitDetailViewModel>()
                        .habitDesc
                        .isNotEmpty) ...[
                      kHabitDivider,
                      buildDescInfo(context),
                    ],
                    kHabitDivider,
                    buildOtherInfo(context),
                    if (context
                        .read<AppDeveloperViewModel>()
                        .isInDevelopMode) ...[
                      kHabitDivider,
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

class _OtherInfo extends StatelessWidget {
  const _OtherInfo();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final viewmodel = context.read<HabitDetailViewModel>();

    return HabitDetailTileList(
      title: HabitDetailChartTitle(
        title: l10n?.habitDetail_otherSubgroup_title ?? "Others",
      ),
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
            subTitle: Text(
              viewmodel.habitDetailData?.data.reminder
                      ?.getReminderTypeHelperText(l10n) ??
                  '',
            ),
            leading: const Icon(Icons.notifications_outlined),
          ),
        // frequency
        if (viewmodel.habitDetailData != null)
          HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_freqTile_title)
                : const Text("Frequency"),
            subTitle: Text(
              l10n != null
                  ? viewmodel.habitDetailData!.data.frequency.toLocalString(
                      l10n,
                    )
                  : viewmodel.habitDetailData!.data.frequency.toString(),
            ),
            leading: const Icon(Icons.repeat_outlined),
          ),
        // start date
        Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
          selector: (context, vm) => vm.config,
          builder: (context, config, child) => HabitOtherInfoTile(
            title: l10n != null
                ? Text(l10n.habitDetail_startDateTile_title)
                : const Text("Start Date"),
            subTitle: Text(
              config
                  .getYMDFormatter(l10n?.localeName)
                  .format(viewmodel.habitStartDate),
            ),
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
              subTitle: Text(
                config
                    .getFormatter(l10n?.localeName)
                    .format(viewmodel.habitDetailData!.createT),
              ),
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
              subTitle: Text(
                config
                    .getFormatter(l10n?.localeName)
                    .format(viewmodel.habitDetailData!.modifyT),
              ),
              leading: const Icon(HabitCalIcons.calendar_modify),
              padding: const EdgeInsets.only(bottom: 6.0),
            ),
          ),
      ],
    );
  }
}
