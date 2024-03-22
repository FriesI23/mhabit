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
import 'package:great_list_view/great_list_view.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/types.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../db/db_helper/habits.dart';
import '../db/db_helper/records.dart';
import '../extension/async_extensions.dart';
import '../extension/color_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../model/global.dart';
import '../model/habit_daily_record_form.dart';
import '../model/habit_date.dart';
import '../model/habit_detail_page.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_stat.dart';
import "../model/habit_summary.dart";
import '../provider/app_compact_ui_switcher.dart';
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/app_theme.dart';
import '../provider/habit_date_change.dart';
import '../provider/habit_op_config.dart';
import '../provider/habit_summary.dart';
import '../provider/habits_file_exporter.dart';
import '../provider/habits_file_importer.dart';
import '../provider/habits_filter.dart';
import '../provider/habits_record_scroll_behavior.dart';
import '../provider/habits_sort.dart';
import '../reminders/notification_channel.dart';
import '_debug.dart';
import 'common/_dialog.dart';
import 'common/_mixin.dart';
import 'common/_widget.dart';
import 'for_habit_display/_dialog.dart';
import 'for_habit_display/_widget.dart';
import 'page_app_setting.dart' as app_setting_view;
import 'page_habit_detail.dart' as habit_detail_view;
import 'page_habit_edit.dart' as habit_edit_view;

const _kCommonEvalation = 2.0;

const _kEditModeChangeAnimateDuration = Duration(milliseconds: 200);
const _kEditModeAppbarAnimateDuration = Duration(milliseconds: 200);

const _kPressFABAnimateDuration = Duration(milliseconds: 500);

const _kHabitListFutureLoadDuration = Duration(milliseconds: 300);

class PageHabitsDisplay extends StatelessWidget {
  const PageHabitsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // new
        ChangeNotifierProxyProvider<Global, HabitsSortViewModel>(
          create: (context) =>
              HabitsSortViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider<Global, HabitsFilterViewModel>(
          create: (context) =>
              HabitsFilterViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider<Global,
            HabitsRecordScrollBehaviorViewModel>(
          create: (context) => HabitsRecordScrollBehaviorViewModel(
              global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProvider<HabitSummaryViewModel>(
          create: (context) => HabitSummaryViewModel(
            verticalScrollController: ScrollController(),
            horizonalScrollControllerGroup: LinkedScrollControllerGroup(),
          ),
        ),
        // proxy
        ChangeNotifierProxyProvider2<HabitsSortViewModel, HabitsFilterViewModel,
            HabitSummaryViewModel>(
          create: (context) => context.read<HabitSummaryViewModel>(),
          update: (context, sortOptions, habitDisplayFilter, previous) {
            previous!.updateSortOptions(
                sortOptions.sortType, sortOptions.sortDirection);
            previous.updateHabitDisplayFilter(
                habitDisplayFilter.habitsDisplayFilter);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              previous.resortData();
            });
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<HabitFileImporterViewModel,
            HabitSummaryViewModel>(
          create: (context) => context.read<HabitSummaryViewModel>(),
          update: (context, value, previous) {
            if (value.consumeReloadDisplayFlag()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                previous!.rockreloadDBToggleSwich();
              });
            }
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<AppFirstDayViewModel,
            HabitSummaryViewModel>(
          create: (context) => context.read<HabitSummaryViewModel>(),
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
        ChangeNotifierProxyProvider<NotificationChannelData,
            HabitSummaryViewModel>(
          create: (context) => context.read<HabitSummaryViewModel>(),
          update: (context, value, previous) =>
              previous!..setNotificationChannelData(value),
        ),
      ],
      child: const HabitsDisplayView(),
    );
  }
}

class HabitsDisplayView extends StatefulWidget {
  const HabitsDisplayView({super.key});

  @override
  State<StatefulWidget> createState() => _HabitsDisplayView();
}

class _HabitsDisplayView extends State<HabitsDisplayView>
    with HabitsDisplayViewDebug, XShare<HabitsDisplayView> {
  VoidCallback? _onFABPressedAction;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    var viewmodel = context.read<HabitSummaryViewModel>();
    var dispatcher = AnimatedListDiffListDispatcher<HabitSortCache>(
      controller: AnimatedListController(),
      itemBuilder: (context, element, data) {
        if (data.measuring) {
          return SizedBox(
              height: context
                  .read<AppCompactUISwitcherViewModel>()
                  .appHabitDisplayListTileHeight);
        } else if (element is HabitSummaryDataSortCache) {
          return _buildHabitsContentCell(context, element.uuid);
        } else {
          return const SizedBox();
        }
      },
      currentList: viewmodel.lastSortedDataCache,
      comparator: AnimatedListDiffListComparator<HabitSortCache>(
        sameItem: (a, b) => a.isSameItem(b),
        sameContent: (a, b) => a.isSameContent(b),
      ),
    );
    viewmodel.initDispatcher(dispatcher);
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  void _revertHabitsStatus(
      List<HabitSummaryStatusChangedRecord> recordList) async {
    HabitSummaryViewModel viewmodel;
    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    await viewmodel.revertHabitsStatus(recordList);

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.rockReloadUIToggleSwitch();
  }

  void _openHabitArchiveConfirmDialog(BuildContext context) async {
    HabitSummaryViewModel viewmodel;
    final result = await showConfirmDialog(
      context: context,
      titleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_archiveHabitsConfirmDialog_title)
            : const Text('Archive Selected Habits?');
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_archiveHabitsConfirmDialog_confirm)
            : const Text('confirm');
      },
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_archiveHabitsConfirmDialog_cancel)
            : const Text('cancel');
      },
    );
    if (result == null || result == false) return;

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    var recordList = await viewmodel.archivedSelectedHabits();
    if (!mounted || recordList == null) return;

    var archivedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = BuildWidgetHelper().buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(
                l10n.habitDisplay_archiveHabitsSuccSnackbarText(archivedCount))
            : const Text('Archived habits'),
      ),
      onPressed: () => _revertHabitsStatus(recordList),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _openHabitUnArchiveConfirmDialog(BuildContext context) async {
    HabitSummaryViewModel viewmodel;

    final result = await showConfirmDialog(
      context: context,
      titleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_unarchiveHabitsConfirmDialog_title)
            : const Text('Unarchive Selected Habits?');
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_unarchiveHabitsConfirmDialog_confirm)
            : const Text('confirm');
      },
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_unarchiveHabitsConfirmDialog_cancel)
            : const Text('cancel');
      },
    );
    if (result == null || result == false) return;

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    var recordList = await viewmodel.unarchivedSelectedHabits();
    if (!mounted || recordList == null) return;

    var archivedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = BuildWidgetHelper().buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n
                .habitDisplay_unarchiveHabitsSuccSnackbarText(archivedCount))
            : const Text('Unarchived habits'),
      ),
      onPressed: () => _revertHabitsStatus(recordList),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _openHabitDeleteConfirmDialog(BuildContext context) async {
    HabitSummaryViewModel viewmodel;

    final result = await showConfirmDialog(
      context: context,
      titleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_deleteHabitsConfirmDialog_title)
            : const Text("Delete Selected Habits?");
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_deleteHabitsConfirmDialog_confirm)
            : const Text('confirm');
      },
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitDisplay_deleteHabitsConfirmDialog_cancel)
            : const Text('cancel');
      },
    );
    if (result == null || result == false) return;

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    var recordList = await viewmodel.deleteSelectedHabits();
    if (!mounted || recordList == null) return;

    var deletedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = BuildWidgetHelper().buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_deleteHabitsSuccSnackbarText(deletedCount))
            : const Text('Delete habits'),
      ),
      onPressed: () => _revertHabitsStatus(recordList),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _openHabitSummaryMenuDialog(BuildContext context) async {
    final result = await showHabitDisplayMainMenuDialog(
      context: context,
      sortType: context.read<HabitsSortViewModel>().sortType,
      sortDirection: context.read<HabitsSortViewModel>().sortDirection,
      habitFilter: context.read<HabitsFilterViewModel>(),
      appTheme: context.read<AppThemeViewModel>(),
    );

    switch (result) {
      case null:
      case HabitDisplayMainMenuDialogOpr.none:
        return;
      case HabitDisplayMainMenuDialogOpr.showSortMenu:
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        _openHabitSummarySortSelectorDialog(context);
        break;
      case HabitDisplayMainMenuDialogOpr.openSettings:
        if (!mounted) return;
        _openAppSettingsPage(context);
        break;
    }
  }

  void _openHabitSummaryStatisticsDialog(BuildContext context) {
    if (!mounted) return;
    showHabitDisplayStatsMenuDialog(
      context: context,
      summary: context.read<HabitSummaryViewModel>(),
    );
  }

  void _openHabitSummarySortSelectorDialog(BuildContext context) async {
    final result = await showHabitDisplaySortTypePickerDialog(
      context: context,
      sortType: context.read<HabitsSortViewModel>().sortType,
      sortDirection: context.read<HabitsSortViewModel>().sortDirection,
    );

    if (!mounted || result == null) return;
    context
        .read<HabitsSortViewModel>()
        .setNewSortMode(sortType: result.item1, sortDirection: result.item2);
  }

  void _openHabitRecordResonModifierDialog(
    BuildContext context,
    HabitUUID parentUUID,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    String initReason = '';
    final data = context.read<HabitSummaryViewModel>().getHabit(parentUUID);
    if (data == null) return;

    final record = data.getRecordByDate(date);
    if (record?.uuid != null) {
      initReason = (await loadSingleRecordFromDB(record!.uuid))?.reason ?? '';
    }

    if (!mounted) return;
    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: data.colorType,
    );

    if (result == null || result == initReason || !mounted) return;
    context
        .read<HabitSummaryViewModel>()
        .onLongPressChangeReason(parentUUID, date, result);
  }

  void _openHabitRecordCusomNumberPickerDialog(
    BuildContext context,
    HabitUUID parentUUID,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    HabitDailyGoal crtNum;

    var viewmodel = context.read<HabitSummaryViewModel>();
    var data = viewmodel.getHabit(parentUUID);
    if (data == null) return;

    var record = data.getRecordByDate(date);
    num orgNum = record?.value ?? -1;
    if (record != null) {
      if (record.status != HabitRecordStatus.done) return;
      crtNum = record.value;
    } else {
      crtNum = data.dailyGoal;
    }

    final result = await showHabitRecordCustomNumberPickerDialog(
      context: context,
      recordForm: HabitDailyRecordForm.getImp(
        type: data.type,
        value: crtNum,
        targetValue: data.dailyGoal,
        extraTargetValue: data.dailyGoalExtra,
      ),
      recordStatus: record?.status ?? HabitRecordStatus.unknown,
      recordDate: date,
      targetExtraValue: data.dailyGoalExtra,
      colorType: data.colorType,
    );

    if (result == null || result == orgNum || !mounted) return;
    viewmodel.onLongPressChangeRecordValue(parentUUID, date, result);
  }

  void _exportSelectedHabitsAndShared(BuildContext context) async {
    if (!mounted) return;

    final habitUUIDList = context
        .read<HabitSummaryViewModel>()
        .getExportUseSelectedHabitUUID()
        .toList();

    final confirmResult = await showExporterConfirmDialog(
      context: context,
      exportHabitsNumber: habitUUIDList.length,
      exportAll: false,
    );

    if (!mounted || confirmResult == null) return;
    final filePath = await context
        .read<HabitFileExporterViewModel>()
        .exportMultiHabitsData(
          habitUUIDList,
          withRecords: confirmResult == ExporterConfirmResultType.withRecords,
        );

    if (!mounted || filePath == null) return;
    context.read<HabitSummaryViewModel>().exitEditMode();
    //TODO: add snackbar result
    shareXFiles([XFile(filePath)],
        text: "Export Select Habits", context: context);
  }

  void _openAppSettingsPage(BuildContext context) {
    app_setting_view.naviToAppSettingPage(
        context: context,
        scrollBehavior: context.read<HabitsRecordScrollBehaviorViewModel>(),
        summary: context.read<HabitSummaryViewModel>());
  }

  Future<void> _onRefreshIndicatorTriggered() async {
    if (!mounted) return;
    HabitDateChangeProvider.of(context).dateTime = HabitDate.now();
    context.read<HabitSummaryViewModel>().rockreloadDBToggleSwich();
  }

  Future<void> _onFABPressed() async {
    if (!mounted) return;
    var viewmodel = context.read<HabitSummaryViewModel>();
    if (viewmodel.isInEditMode) {
      context.read<HabitSummaryViewModel>().exitEditMode();
      await Future.delayed(_kPressFABAnimateDuration);
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    _onFABPressedAction?.call();
  }

  void _onCreateNewHabitPageClosed(HabitDBCell? result) {
    if (result == null || !mounted) return;
    _onNewHabitCreated(result);
  }

  void _onNewHabitCreated(HabitDBCell result) async {
    HabitSummaryViewModel viewmodel;

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    final habit = HabitSummaryData.fromDBQueryCell(result);
    final addResult = viewmodel.addNewData(habit);
    if (addResult) viewmodel.rockReloadUIToggleSwitch();
  }

  Future<bool> _enterHabitEditPage({
    Duration exitEditModeDuration = _kEditModeChangeAnimateDuration,
    required HabitForm Function(HabitDBCell) formBuilder,
  }) async {
    HabitSummaryViewModel viewmodel;
    if (!mounted) return false;
    viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return false;
    final selectedData = viewmodel.getSelectedHabitsData().firstWhere(
          (element) => element != null,
          orElse: () => null,
        );

    if (selectedData == null) return false;
    final dbcell = await loadHabitDetailFromDB(selectedData.uuid);

    if (!mounted || dbcell == null) return false;
    viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return false;
    final form = formBuilder(dbcell);
    if (viewmodel.isInEditMode) {
      context.read<HabitSummaryViewModel>().exitEditMode();
      await Future.delayed(exitEditModeDuration);
    }

    if (!mounted) return false;
    final result = await habit_edit_view.naviToHabitEidtPage(
        context: context, initForm: form);

    // Edit/Create Habit involves complex state changes (such as sorting by
    // completion rate, calculating the start date of check-in data, etc.),
    // so it is necessary to reload all data from the database.
    if (result == null || !mounted) return false;
    viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.rockreloadDBToggleSwich();
    return true;
  }

  Future<void> _onAppbarEditActionPressed() async => _enterHabitEditPage(
        formBuilder: (dbCell) => HabitForm.fromHabitDBCell(
          dbCell,
          editMode: HabitDisplayEditMode.edit,
          editParams: HabitDisplayEditParams.fromDBCell(dbCell),
        ),
      );

  void _onAppbarUnArchiveActionPressed() =>
      _openHabitUnArchiveConfirmDialog(context);

  void _onAppbarArchiveActionPressed() =>
      _openHabitArchiveConfirmDialog(context);

  void _onAppbarSelectAllActionPressed() =>
      context.read<HabitSummaryViewModel>().selectAllHabit();

  void _onAppbarExportAllActionPressed() =>
      _exportSelectedHabitsAndShared(context);

  void _onAppbarDeleteActionPressed() => _openHabitDeleteConfirmDialog(context);

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

  void _onAppbarLeftButtonPressed(bool lastStatus) {
    if (!mounted) return;
    context
        .read<HabitSummaryViewModel>()
        .updateCalendarExpanedStatus(!lastStatus);
  }

  OnHabitSummaryPressCallback? _getOnHabitRecordedActionTriggeredFn(
      UserAction action) {
    void handleChangeRecordStatus(
      HabitUUID puuid,
      HabitRecordUUID? uuid,
      HabitRecordDate date,
      HabitRecordStatus crt,
    ) async {
      if (!mounted) return;

      context
          .read<HabitSummaryViewModel>()
          .onTapToChangeRecordStatus(puuid, date);
    }

    void handleOpenRecordStatusDialog(
      HabitUUID puuid,
      HabitRecordUUID? uuid,
      HabitRecordDate date,
      HabitRecordStatus crt,
    ) async {
      if (!mounted) return;

      final data = context.read<HabitSummaryViewModel>().getHabit(puuid);
      if (data == null) return;

      final record = data.getRecordByDate(date);
      switch (record?.status) {
        case HabitRecordStatus.skip:
          return _openHabitRecordResonModifierDialog(
              context, puuid, uuid, date, crt);
        default:
          return _openHabitRecordCusomNumberPickerDialog(
              context, puuid, uuid, date, crt);
      }
    }

    final opConfig = context.read<HabitRecordOpConfigViewModel>();
    if (action == opConfig.changeRecordStatus) {
      return handleChangeRecordStatus;
    } else if (action == opConfig.openRecordStatusDialog) {
      return handleOpenRecordStatusDialog;
    } else {
      return null;
    }
  }

  bool _onHabitListReorderStart(int index, double dx, double dy) {
    if (!mounted) return false;

    var viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.canBeDragged) return false;

    if (!viewmodel.isInEditMode) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..clearSnackBars();
      viewmodel.switchToEditMode();
      var data = viewmodel.getHabitBySortId(index);
      if (data is HabitSummaryDataSortCache) {
        viewmodel.selectHabit(data.uuid, listen: false);
      }
    }

    var sortOptions = context.read<HabitsSortViewModel>();
    if (sortOptions.sortType != HabitDisplaySortType.manual) return false;

    return true;
  }

  bool _onHabitListReorderMove(int index, int dropIndex) {
    if (!mounted) return false;

    var viewmodel = context.read<HabitSummaryViewModel>();
    if (index != dropIndex && viewmodel.isInEditMode) {
      viewmodel.exitEditModeOnly();
    }
    return true;
  }

  bool _onHabitListReorderComplete(int index, int dropIndex, Object? slot) {
    if (!mounted) return false;

    var viewmodel = context.read<HabitSummaryViewModel>();
    if (index != dropIndex) {
      viewmodel.onHabitReorderComplate(index, dropIndex);
      viewmodel.exitEditMode(listen: false);
    } else if (!viewmodel.isInEditMode) {
      viewmodel.exitEditMode(listen: false);
    }
    return true;
  }

  void _onHabitSummaryDataPressed(HabitUUID uuid) async {
    if (!mounted) return;

    void preessedInEditMode() {
      if (!mounted) return;
      var viewmodel = context.read<HabitSummaryViewModel>();

      if (viewmodel.isHabitSelected(uuid)) {
        viewmodel.unselectHabit(uuid);
      } else {
        viewmodel.selectHabit(uuid);
      }
    }

    Future<void> pressedInViewMode() async {
      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      final result = await habit_detail_view.naviToHabitDetailPage(
        context: context,
        habitUUID: uuid,
        colorType:
            context.read<HabitSummaryViewModel>().getHabit(uuid)?.colorType,
        summary: context.read<HabitSummaryViewModel>(),
      );

      if (result == null || !mounted) return;
      switch (result.op) {
        case DetailPageReturnOpr.unknown:
          break;
        case DetailPageReturnOpr.deleted:
          if (!mounted) break;
          final snackBar = BuildWidgetHelper().buildSnackBarWithUndo(
            context,
            content: Text('Archived habit ${result.habitName ?? ""}'),
            onPressed: () => _revertHabitsStatus(result.recordList ?? []),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
          break;
      }
    }

    if (context.read<HabitSummaryViewModel>().isInEditMode) {
      preessedInEditMode();
    } else {
      await pressedInViewMode();
    }
  }

  void _onHabitEditAppbarLeadingButtonPressed() {
    if (!mounted) return;
    var viewmodel = context.read<HabitSummaryViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewmodel.exitEditMode();
    });
  }

  ScrollPhysics? _buildScrollPhysics(double itemSize, double length) =>
      context.read<HabitsRecordScrollBehaviorViewModel>().getPhysics(
          itemSize,
          FixedScrollMetrics(
            minScrollExtent: null,
            maxScrollExtent: null,
            pixels: null,
            viewportDimension: null,
            axisDirection: AxisDirection.down,
            devicePixelRatio: View.of(context).devicePixelRatio,
          ));

  Widget _buildHabitsContentCell(BuildContext context, HabitUUID uuid) {
    return Selector<HabitSummaryViewModel,
        Tuple4<bool, UniqueKey, bool, HabitDate>>(
      selector: (context, viewmodel) => Tuple4(
        viewmodel.isCalendarExpanded,
        viewmodel.getHabitInsideVersion(uuid),
        viewmodel.isHabitSelected(uuid),
        HabitDateChangeProvider.of(context).dateTime,
      ),
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, contents, child) => Selector<AppThemeViewModel, int>(
        selector: (context, vm) => vm.displayPageOccupyPrt,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, occupyPrt, child) =>
            Selector<AppCompactUISwitcherViewModel, Tuple2<bool, double>>(
          selector: (context, vm) =>
              Tuple2(vm.flag, vm.appHabitDisplayListTileHeight),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, compactUIConf, child) => Selector<
              HabitRecordOpConfigViewModel, Tuple2<UserAction, UserAction>>(
            selector: (context, vm) =>
                Tuple2(vm.changeRecordStatus, vm.openRecordStatusDialog),
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, _, child) {
              final isExtended = contents.item1;
              final crtDate = contents.item4;
              final useCompactUI = compactUIConf.item1;
              final height = compactUIConf.item2;
              return _HabitRecordListTile(
                uuid: uuid,
                isExtended: isExtended,
                crtDate: crtDate,
                displayPageOccupyPrt: occupyPrt,
                useCompactUI: useCompactUI,
                height: height,
                onHabitSummaryDataPressed: _onHabitSummaryDataPressed,
                onHabitRecordPressed:
                    _getOnHabitRecordedActionTriggeredFn(UserAction.tap),
                onHabitRecordLongPressed:
                    _getOnHabitRecordedActionTriggeredFn(UserAction.longTap),
                onHabitRecordDoublePressed:
                    _getOnHabitRecordedActionTriggeredFn(UserAction.doubleTap),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollablePlaceHolder(BuildContext context) {
    return SliverList(
        delegate:
            DebugBuilderMethods.debugBuildSliverScrollDelegate(childCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    //#region: appbar
    Widget buildAppbarInViewMode(BuildContext context, bool isExtended) {
      return Selector<HabitsRecordScrollBehaviorViewModel,
          HabitsRecordScrollBehavior>(
        key: const ValueKey("view-app-bar"),
        selector: (context, vm) => vm.scrollBehavior,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, scrollBehavior, child) =>
            Selector<AppThemeViewModel, int>(
          selector: (context, vm) => vm.displayPageOccupyPrt,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, occupyPrt, child) {
            final viewmodel = context.read<HabitSummaryViewModel>();
            final compactvm = context.read<AppCompactUISwitcherViewModel>();
            return HabitDisplayAppBarViewMode(
              scrolledUnderElevation: _kCommonEvalation,
              title: L10nBuilder(
                builder: (context, l10n) =>
                    l10n != null ? Text(l10n.appName) : const Text(appName),
              ),
              bottom: SliverCalendarBar(
                key: const Key('habit_display_calendar_bar'),
                verticalScrollController: viewmodel.verticalScrollController,
                horizonalScrollControllerGroup:
                    viewmodel.horizonalScrollControllerGroup,
                startDate: HabitDateChangeProvider.of(context).dateTime,
                endDate: viewmodel.earliestSummaryDataStartDate?.startDate,
                isExtended: isExtended,
                collapsePrt: occupyPrt,
                height: compactvm.appCalendarBarHeight,
                itemPadding: compactvm.appCalendarBarItemPadding,
                onLeftBtnPressed: _onAppbarLeftButtonPressed,
                scrollPhysicsBuilder: _buildScrollPhysics,
              ),
              onInfoButtonPressed: () =>
                  _openHabitSummaryStatisticsDialog(context),
              onMenuButtonPressed: () => _openHabitSummaryMenuDialog(context),
            );
          },
        ),
      );
    }

    Widget buildAppbarInEditMode(BuildContext context, bool isExtended) {
      Widget buildEditAppbarActions(BuildContext context) {
        return Selector<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
          selector: (context, viewmodel) => viewmodel.selectStatistic,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, stat, child) => L10nBuilder(
            builder: (context, l10n) =>
                AppBarActions<EditModeActionItemConfig, EditModeActionItemCell>(
              buttonSwitchAnimateDuration: _kEditModeAppbarAnimateDuration,
              actionConfigs: [
                EditModeActionItemConfig.edit(
                    visible: stat.selected == 1,
                    text: l10n?.habitDisplay_editButton_tooltip ?? "Edit",
                    callback: _onAppbarEditActionPressed),
                EditModeActionItemConfig.unarchive(
                    visible: stat.archived > 0,
                    text: l10n?.habitDisplay_unarchiveButton_tooltip ??
                        "Unarchive",
                    callback: _onAppbarUnArchiveActionPressed),
                EditModeActionItemConfig.archive(
                    visible: stat.activated > 0,
                    text: l10n?.habitDisplay_archiveButton_tooltip ?? "Archive",
                    callback: _onAppbarArchiveActionPressed),
                EditModeActionItemConfig.selectall(
                    text: l10n?.habitDisplay_editPopMenu_selectAll ??
                        "Select All",
                    callback: _onAppbarSelectAllActionPressed),
                EditModeActionItemConfig.clone(
                    visible: stat.selected == 1,
                    text: l10n?.habitDisplay_editPopMenu_clone ?? "Clone",
                    callback: _onAppbarCloneActionPressed),
                EditModeActionItemConfig.exportall(
                    text: l10n?.habitDisplay_editPopMenu_export ?? "Export",
                    callback: _onAppbarExportAllActionPressed),
                EditModeActionItemConfig.delete(
                    text: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
                    callback: _onAppbarDeleteActionPressed),
              ],
            ),
          ),
        );
      }

      Widget buildAppbarTitle(BuildContext context) {
        return Selector<HabitSummaryViewModel, int>(
          selector: (context, viewmodel) => viewmodel.selectedHabitsCount,
          shouldRebuild: (previous, next) {
            if (next <= 0) return false;
            return previous != next;
          },
          builder: (context, value, child) => AnimatedSwitcher(
            duration: _kEditModeAppbarAnimateDuration,
            child: Text(value.toString()),
          ),
        );
      }

      return Selector<HabitsRecordScrollBehaviorViewModel,
          HabitsRecordScrollBehavior>(
        key: const ValueKey("edit-app-bar"),
        selector: (context, vm) => vm.scrollBehavior,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, scrollBehavior, child) =>
            Selector<AppThemeViewModel, int>(
          selector: (context, vm) => vm.displayPageOccupyPrt,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, occupyPrt, child) {
            final viewmodel = context.read<HabitSummaryViewModel>();
            return HabitDisplayAppBarEditMode(
              scrolledUnderElevation: _kCommonEvalation,
              title: buildAppbarTitle(context),
              bottom: SliverCalendarBar(
                key: const Key('habit_display_calendar_bar'),
                verticalScrollController: viewmodel.verticalScrollController,
                horizonalScrollControllerGroup:
                    viewmodel.horizonalScrollControllerGroup,
                startDate: HabitDateChangeProvider.of(context).dateTime,
                endDate: viewmodel.earliestSummaryDataStartDate?.startDate,
                isExtended: isExtended,
                collapsePrt: occupyPrt,
              ),
              actionBuilder: (context) => buildEditAppbarActions(context),
              onLeadingButtonPressed: _onHabitEditAppbarLeadingButtonPressed,
            );
          },
        ),
      );
    }

    Widget buildAppbar(BuildContext context) {
      return Selector<HabitSummaryViewModel, HabitSummaryStatusCache>(
        selector: (context, viewmodel) => viewmodel.currentState,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, status, child) {
          var viewmodel = context.read<HabitSummaryViewModel>();
          appLog.build.debug(context, ex: [status], name: "$widget.Appbar");
          return SliverAnimatedSwitcher(
            duration: _kEditModeChangeAnimateDuration,
            child: viewmodel.isInEditMode
                ? buildAppbarInEditMode(context, status.isClandarExpanded)
                : buildAppbarInViewMode(context, status.isClandarExpanded),
          );
        },
      );
    }
    //#endregion

    //#region habits list
    Widget buildHabitsContent(BuildContext context) {
      return Selector<HabitSummaryViewModel, bool>(
        selector: (context, viewmodel) => viewmodel.reloadUIToggleSwitch,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          var viewmodel = context.read<HabitSummaryViewModel>();
          appLog.build.debug(context, ex: [value], name: "$widget.HabitList");
          return AnimatedSliverList(
            controller: viewmodel.dispatcherLinkedController,
            delegate: AnimatedSliverChildBuilderDelegate(
              (context, index, data) {
                return viewmodel.dispatcherLinkedBuilder(
                    context, viewmodel.lastSortedDataCache, index, data);
              },
              viewmodel.lastSortedDataCache.length,
              addAnimatedElevation: _kCommonEvalation,
              morphDuration: _kEditModeChangeAnimateDuration,
              reorderModel: AnimatedListReorderModel(
                onReorderStart: _onHabitListReorderStart,
                onReorderMove: _onHabitListReorderMove,
                onReorderComplete: _onHabitListReorderComplete,
              ),
            ),
          );
        },
      );
    }

    Widget buildHabits(BuildContext context) {
      return Selector<HabitSummaryViewModel, bool>(
        selector: (context, viewmodel) => viewmodel.reloadDBToggleSwich,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          Future loadData() async {
            var loadedFuture = context
                .read<HabitSummaryViewModel>()
                .loadData(inFutureBuilder: true);
            await Future.delayed(_kHabitListFutureLoadDuration);
            await loadedFuture;
            if (mounted &&
                context
                    .read<HabitSummaryViewModel>()
                    .consumeClearSnackBarFlag()) {
              ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
            }
          }

          Future? getFuture() {
            final viewmodel = context.read<HabitSummaryViewModel>();
            viewmodel.dataloadingFutureCache ??= loadData();
            return viewmodel.dataloadingFutureCache;
          }

          final viewmodel = context.read<HabitSummaryViewModel>();
          return FutureBuilder(
            future: getFuture(),
            builder: (context, snapshot) {
              appLog.load.debug("$widget.buildHabits", ex: [
                "Loading data",
                snapshot.connectionState,
                viewmodel.habitCount
              ]);
              if (kDebugMode && snapshot.isDone) {
                appLog.load.debug("$widget.buildHabits",
                    ex: ["Loaded", viewmodel.debugGetDataString()]);
              }

              return SliverStack(
                children: [
                  buildHabitsContent(context),
                  HabitDisplayLoadingIndicator(
                      opacity: snapshot.isDone ? 0.0 : 1.0),
                ],
              );
            },
          );
        },
      );
    }
    //#endregion

    //#region develop button
    Widget buildDevelopSliverList(BuildContext context) {
      return Selector<AppDeveloperViewModel, bool>(
        selector: (context, vm) => vm.showDebugMenuOnDisplayView,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, displayDebugMenu, child) => SliverVisibility(
          visible: displayDebugMenu,
          sliver: EnhancedSafeArea.edgeToEdgeSafe(
            withSliver: true,
            child: HabitDisplayDevelopSliverList(
              onAddCountHabitsPressed: (count) async {
                await debugAddMultiTempHabit(context, count: count);
                if (!mounted) return;
                context.read<HabitSummaryViewModel>().rockreloadDBToggleSwich();
              },
            ),
          ),
        ),
      );
    }
    //#endregion

    //#region bottom placeholder
    Widget buildBottomPlaceHolder(BuildContext context) {
      return const SliverToBoxAdapter(
        child: FixedPagePlaceHolder(
          minHeight: kDefaultHabitSummaryListTileHeight,
        ),
      );
    }
    //#endregion

    //#region: fab
    Widget buildFAB(BuildContext context) {
      return Selector<HabitSummaryViewModel, bool>(
        selector: (context, viewmodel) => viewmodel.isAppbarPinned,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, isAppbarPinned, child) {
          return HabitDisplayFAB(
            closeBuilder: (context, action) {
              _onFABPressedAction = action;
              return ScrollingFAB.small(
                onPressed: _onFABPressed,
                label: L10nBuilder(
                  builder: (context, l10n) => l10n != null
                      ? Text(l10n.habitDisplay_fab_text)
                      : const Text('New Habit'),
                ),
                icon: const Icon(Icons.add),
                isExtended: isAppbarPinned,
              );
            },
            openBuilder: (context, action) =>
                const habit_edit_view.PageHabitEdit(
                    showInFullscreenDialog: true),
            onClosed: _onCreateNewHabitPageClosed,
          );
        },
      );
    }
    //#endregion

    //#region: empty image
    Widget buildEmptyImage(BuildContext context) {
      return Selector<HabitSummaryViewModel, int>(
        selector: (context, viewmodel) => viewmodel.lastSortedDataCache.length,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, habitCount, child) =>
            Selector<AppCompactUISwitcherViewModel, Tuple2<bool, double>>(
          selector: (context, vm) => Tuple2(vm.flag, vm.appCalendarBarHeight),
          builder: (context, value, child) => _HabitDisplayEmptyImageFrame(
            habitCount: habitCount,
            offsetHeight: -(value.item2 + kToolbarHeight),
            changedAnimateDuration: _kHabitListFutureLoadDuration,
            child: L10nBuilder(
              builder: (context, l10n) {
                final theme = Theme.of(context);
                return HabitDisplayEmptyImage(
                  size: const Size.square(300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
                  descChild: l10n != null
                      ? Text(l10n.habitDisplay_emptyImage_text_01)
                      : null,
                  style: HabitDisplayEmptyImageStyle(
                    fronBoardBackgroundColor: theme.colorScheme.surface,
                    backBoardBackgroundColor: theme.colorScheme.surfaceVariant,
                    boardStrokeColor: theme.colorScheme.outlineVariant,
                    fronBoardTopColor: theme.colorScheme.primaryContainer,
                    fronBoardFirstLineColor: theme.colorScheme.primaryContainer,
                    fronBoardOtherLineColor: theme.colorScheme.outlineVariant,
                    fronBoardSubtitleLineColor:
                        theme.colorScheme.outlineVariant.lighten(0.14),
                    backgroundCirlcColor:
                        theme.colorScheme.outlineVariant.lighten(0.16),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    //#endregion

    final viewmodel = context.read<HabitSummaryViewModel>();
    return ColorfulNavibar(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Selector<AppCompactUISwitcherViewModel, Tuple2<bool, double>>(
          selector: (context, vm) => Tuple2(vm.flag, vm.appCalendarBarHeight),
          builder: (context, value, child) => RefreshIndicator(
            onRefresh: _onRefreshIndicatorTriggered,
            edgeOffset: kToolbarHeight +
                value.item2 +
                MediaQuery.of(context).padding.top,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            child: Stack(
              children: [
                buildEmptyImage(context),
                CustomScrollView(
                  physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: viewmodel.verticalScrollController,
                  slivers: [
                    buildAppbar(context),
                    const HabitDivider(withSliver: true, height: 1),
                    EnhancedSafeArea.edgeToEdgeSafe(
                      withSliver: true,
                      child: buildHabits(context),
                    ),
                    buildDevelopSliverList(context),
                    buildBottomPlaceHolder(context),
                    if (kDebugMode) _buildScrollablePlaceHolder(context),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: buildFAB(context),
      ),
    );
  }
}

class _HabitDisplayEmptyImageFrame extends StatelessWidget {
  final int habitCount;
  final double offsetHeight;
  final Duration changedAnimateDuration;
  final Widget? child;

  const _HabitDisplayEmptyImageFrame({
    required this.habitCount,
    this.offsetHeight = 0.0,
    required this.changedAnimateDuration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: constraints.copyWith(
                maxHeight: math.max(constraints.maxHeight + offsetHeight, 0)),
            child: AnimatedOpacity(
              opacity: habitCount > 0 ? 0.0 : 1.0,
              duration: changedAnimateDuration,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitRecordListTile extends StatelessWidget {
  final HabitUUID uuid;
  final bool isExtended;
  final HabitDate crtDate;
  final int displayPageOccupyPrt;
  final bool useCompactUI;
  final double height;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onHabitRecordPressed;
  final OnHabitSummaryPressCallback? onHabitRecordLongPressed;
  final OnHabitSummaryPressCallback? onHabitRecordDoublePressed;

  const _HabitRecordListTile({
    required this.uuid,
    required this.isExtended,
    required this.crtDate,
    required this.displayPageOccupyPrt,
    required this.useCompactUI,
    required this.height,
    this.onHabitSummaryDataPressed,
    this.onHabitRecordPressed,
    this.onHabitRecordDoublePressed,
    this.onHabitRecordLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.read<HabitSummaryViewModel>();
    final data = viewmodel.getHabit(uuid);

    appLog.build.debug(context, ex: [uuid, isExtended, data]);
    if (data == null) {
      appLog.build.warn(context, ex: ["data not found", uuid]);
      return const SizedBox();
    }
    return HabitDisplayListTile(
      startDate: crtDate,
      endedData: viewmodel.earliestSummaryDataStartDate?.startDate,
      isExtended: isExtended,
      isSelected: viewmodel.isHabitSelected(uuid),
      isInEditMode: viewmodel.isInEditMode,
      collapsePrt: displayPageOccupyPrt,
      height: height,
      compactVisual: useCompactUI,
      data: data,
      verticalScrollController: viewmodel.verticalScrollController,
      horizonalScrollControllerGroup: viewmodel.horizonalScrollControllerGroup,
      onHabitSummaryDataPressed: onHabitSummaryDataPressed,
      onHabitRecordPressed: onHabitRecordPressed,
      onHabitRecordLongPressed: onHabitRecordLongPressed,
      onHabitRecordDoublePressed: onHabitRecordDoublePressed,
    );
  }
}
