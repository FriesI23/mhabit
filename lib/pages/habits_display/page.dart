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

import 'dart:async';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

import '../../common/consts.dart';
import '../../common/enums.dart';
import '../../common/types.dart';
import '../../extensions/async_extensions.dart';
import '../../extensions/color_extensions.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/navigator_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_date.dart';
import '../../models/habit_display.dart';
import '../../models/habit_form.dart';
import '../../models/habit_stat.dart';
import '../../models/habit_status.dart';
import "../../models/habit_summary.dart";
import '../../providers/app_compact_ui_switcher.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_theme.dart';
import '../../providers/habit_detail.dart';
import '../../providers/habit_op_config.dart';
import '../../providers/habit_summary.dart';
import '../../providers/habits_file_exporter.dart';
import '../../providers/habits_filter.dart';
import '../../providers/habits_record_scroll_behavior.dart';
import '../../providers/habits_sort.dart';
import '../../storage/db/handlers/habit.dart';
import '../../utils/xshare.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widgets.dart';
import '../app_settings/page.dart' as app_settings;
import '../common/debug.dart';
import '../common/widgets.dart';
import '../habit_detail/page.dart' as habit_detail;
import '../habit_edit/page.dart' as habit_edit;
import '../habits_status_changer/page.dart' as habits_status_changer;
import 'widgets.dart';

/// Depend Providers
/// - Required for builder:
///   - [AppThemeViewModel]
///   - [AppCompactUISwitcherViewModel]
class HabitsDisplayPage extends StatelessWidget {
  const HabitsDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageProviders(child: _Page());
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> with HabitsDisplayViewDebug, XShare {
  late final LinkedScrollControllerGroup _horizonalScrollControllerGroup;
  late final PinnedAppbarScrollController _verticalScrollController;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    final viewmodel = context.read<HabitSummaryViewModel>();
    // events
    viewmodel.scrollCalendarToStartEvent
        .listen(_resetHorizonalScrollController);
    // dispatcher
    final dispatcher = AnimatedListDiffListDispatcher<HabitSortCache>(
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
    // scroll controllers
    _horizonalScrollControllerGroup = LinkedScrollControllerGroup();
    _verticalScrollController = PinnedAppbarScrollController(
      onAppbarStatusChanged: _changeAppbarStatus,
    )..addChangeAppbarStatusListener();
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    _verticalScrollController.dispose();
    super.dispose();
  }

  FutureOr<void> _resetHorizonalScrollController(Duration? scrollDuration) {
    appLog.build.debug(context,
        ex: ["reset HorizonalScrollController", scrollDuration]);
    if (scrollDuration == Duration.zero) {
      _horizonalScrollControllerGroup.jumpTo(0);
    } else {
      return _horizonalScrollControllerGroup.animateTo(0,
          duration: scrollDuration ?? const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }
  }

  void _changeAppbarStatus(bool pinned) {
    final vm = context.maybeRead<HabitSummaryViewModel>();
    if (vm == null || !vm.mounted) return;
    pinned ? vm.pinAppbar() : vm.unpinAppbar();
  }

  Future<void> _loadHabitData() async {
    if (!mounted) return;
    final minBarShowTimeFuture = Future.delayed(kHabitListFutureLoadDuration);
    if (context.read<AppSyncViewModel>().mounted) {
      await context.read<AppSyncViewModel>().appSyncTask.processing;
    }
    if (!(mounted && context.read<HabitSummaryViewModel>().mounted)) return;
    await Future.wait([
      context.read<HabitSummaryViewModel>().loadData(inFutureBuilder: true),
      minBarShowTimeFuture,
    ]);
    if (!(mounted && context.read<HabitSummaryViewModel>().mounted)) return;
    if (context.read<HabitSummaryViewModel>().consumeClearSnackBarFlag()) {
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    }
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

  void _onRecordChangeConfirmed({bool shouldSyncOnce = true}) {
    if (!mounted) return;
    // try sync once
    if (shouldSyncOnce) {
      final sync = context.maybeRead<AppSyncViewModel>();
      if (sync != null && sync.mounted) sync.delayedStartTaskOnce();
    }
  }

  void _revertHabitsStatus(List<HabitStatusChangedRecord> recordList) async {
    HabitSummaryViewModel viewmodel;
    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    await viewmodel.revertHabitsStatus(recordList);

    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.rockReloadUIToggleSwitch();

    _onHabitStatusChangeConfirmed();
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

    if (!context.mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    final recordList = await viewmodel.archivedSelectedHabits();
    if (!context.mounted || recordList == null) return;

    _onHabitStatusChangeConfirmed();

    final archivedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(
                l10n.habitDisplay_archiveHabitsSuccSnackbarText(archivedCount))
            : const Text('Archived habits'),
      ),
      showDuration: kAppUndoDialogShowDuration,
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

    if (!context.mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    final recordList = await viewmodel.unarchivedSelectedHabits();
    if (!context.mounted || recordList == null) return;

    _onHabitStatusChangeConfirmed();

    final archivedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n
                .habitDisplay_unarchiveHabitsSuccSnackbarText(archivedCount))
            : const Text('Unarchived habits'),
      ),
      showDuration: kAppUndoDialogShowDuration,
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

    if (!context.mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    final recordList = await viewmodel.deleteSelectedHabits();
    if (!context.mounted || recordList == null) return;

    _onHabitStatusChangeConfirmed();

    final deletedCount = recordList.length;
    viewmodel = context.read<HabitSummaryViewModel>();
    final snackBar = buildSnackBarWithUndo(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_deleteHabitsSuccSnackbarText(deletedCount))
            : const Text('Delete habits'),
      ),
      showDuration: kAppUndoDialogShowDuration,
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
        if (!context.mounted) return;
        _openHabitSummarySortSelectorDialog(context);
        break;
      case HabitDisplayMainMenuDialogOpr.openSettings:
        if (!context.mounted) return;
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

    if (!context.mounted || result == null) return;
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
    HabitSummaryViewModel viewmodel;

    viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return;
    final data = viewmodel.getHabit(parentUUID);
    if (data == null) return;

    final recordUUID = data.getRecordByDate(date)?.uuid;
    if (recordUUID != null) {
      final rcd = await viewmodel.recordDBHelper.loadSingleRecord(recordUUID);
      initReason = rcd?.reason ?? '';
    }

    if (!context.mounted) return;
    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: data.colorType,
    );

    if (result == null || result == initReason || !context.mounted) return;
    context
        .read<HabitSummaryViewModel>()
        .changeRecordReason(parentUUID, date, result)
        .then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  void _openHabitRecordCusomNumberPickerDialog(
    BuildContext context,
    HabitUUID parentUUID,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    HabitSummaryViewModel viewmodel;

    viewmodel = context.read<HabitSummaryViewModel>();
    final data = viewmodel.getHabit(parentUUID);
    if (data == null) return;

    final HabitDailyGoal crtNum;
    final record = data.getRecordByDate(date);
    final orgNum = record?.value ?? -1;
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

    if (result == null || result == orgNum || !context.mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return;
    viewmodel.changeRecordValue(parentUUID, date, result).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
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

    if (!context.mounted || confirmResult == null) return;
    final filePath = await context
        .read<HabitFileExporterViewModel>()
        .exportMultiHabitsData(
          habitUUIDList,
          withRecords: confirmResult == ExporterConfirmResultType.withRecords,
        );

    if (!context.mounted || filePath == null) return;
    context.read<HabitSummaryViewModel>().exitEditMode();
    trySaveFiles([XFile(filePath)], defaultTargetPlatform,
            text: "Export Select Habits", context: context)
        .then((result) {
      context = this.context;
      if (!(result && context.mounted)) return;
      final count = habitUUIDList.length;
      final snackBar = buildSnackBarWithDismiss(
        context,
        content: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.habitDisplay_exportHabitsSuccSnackbarText(count))
              : const Text('Exported habits'),
        ),
        duration: kAppUndoDialogShowDuration,
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    });
  }

  void _openAppSettingsPage(BuildContext context) {
    app_settings.naviToAppSettingPage(
      context: context,
      summary: context.read<HabitSummaryViewModel>(),
    );
  }

  Future<void> _onRefreshIndicatorTriggered() async {
    if (!mounted) return;
    DateChangeProvider.of(context).dateTime = HabitDate.now();
    final syncvm = context.read<AppSyncViewModel>();
    if (syncvm.mounted) {
      try {
        await syncvm.startSync(initWait: kAppSyncDelayDuration2);
      } catch (e, s) {
        appLog.appsync.fatal("start sync failed",
            ex: [syncvm.appSyncTask.task], error: e, stackTrace: s);
        if (kDebugMode) Error.throwWithStackTrace(e, s);
      }
    }
  }

  Future<void> _onFABPressed(VoidCallback action) async {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    action();
  }

  void _onCreateNewHabitPageClosed(HabitDBCell result) {
    if (!mounted) return;
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
    Duration exitEditModeDuration = kEditModeChangeAnimateDuration,
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
    final dbcell =
        await viewmodel.habitDBHelper.loadHabitDetail(selectedData.uuid);

    if (!mounted || dbcell == null) return false;
    viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return false;
    final form = formBuilder(dbcell);
    if (viewmodel.isInEditMode) {
      context.read<HabitSummaryViewModel>().exitEditMode();
      await Future.delayed(exitEditModeDuration);
    }

    if (!mounted) return false;
    final result =
        await habit_edit.naviToHabitEidtPage(context: context, initForm: form);

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

  void _onAppbarExportAllActionPressed(BuildContext? context) =>
      _exportSelectedHabitsAndShared(context ?? this.context);

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
    context.read<HabitSummaryViewModel>().toggleCalendarStatus();
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
          .changeRecordStatus(puuid, date)
          .then((record) {
        if (!mounted || record == null) return;
        _onRecordChangeConfirmed();
      });
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

    final viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.canBeDragged) return false;

    if (!viewmodel.isInEditMode) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..clearSnackBars();
      viewmodel.switchToEditMode();
      final data = viewmodel.getHabitBySortId(index);
      if (data is HabitSummaryDataSortCache) {
        viewmodel.selectHabit(data.uuid, listen: false);
      }
    }

    final sortOptions = context.read<HabitsSortViewModel>();
    if (sortOptions.sortType != HabitDisplaySortType.manual) return false;

    return true;
  }

  bool _onHabitListReorderMove(int index, int dropIndex) {
    if (!mounted) return false;

    final viewmodel = context.read<HabitSummaryViewModel>();
    if (index != dropIndex && viewmodel.isInEditMode) {
      viewmodel.exitEditModeOnly();
    }
    return true;
  }

  bool _onHabitListReorderComplete(int index, int dropIndex, Object? slot) {
    if (!mounted) return false;

    final viewmodel = context.read<HabitSummaryViewModel>();
    if (index != dropIndex) {
      final task = viewmodel.onHabitReorderComplate(index, dropIndex);
      viewmodel.exitEditMode(listen: false);
      task.whenComplete(() {
        if (!mounted) return;
        final appSync = context.maybeRead<AppSyncViewModel>();
        if (appSync == null || !appSync.mounted) return;
        appSync.delayedStartTaskOnce();
      });
    } else if (!viewmodel.isInEditMode) {
      viewmodel.exitEditMode(listen: false);
    }
    return true;
  }

  void _onHabitSummaryDataPressed(HabitUUID uuid) async {
    if (!mounted) return;

    void preessedInEditMode() {
      if (!mounted) return;
      final viewmodel = context.read<HabitSummaryViewModel>();
      if (viewmodel.isHabitSelected(uuid)) {
        viewmodel.unselectHabit(uuid);
      } else {
        viewmodel.selectHabit(uuid);
      }
    }

    Future<void> pressedInViewMode() async {
      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      final result = await habit_detail.naviToHabitDetailPage(
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
          final habitName = result.habitName ?? "";
          final snackBar = buildSnackBarWithUndo(
            context,
            content: L10nBuilder(
              builder: (context, l10n) => Text(
                  l10n?.habitDisplay_deleteSingleHabitSuccSnackbarText(
                          habitName) ??
                      'Deleted: $habitName'),
            ),
            showDuration: kAppUndoDialogShowDuration,
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

  Future<bool> onWillPop() async {
    if (!mounted) return true;
    final viewmodel = context.read<HabitSummaryViewModel>();
    if (!viewmodel.mounted) return true;
    if (viewmodel.isInEditMode) {
      viewmodel.exitEditMode();
      return false;
    }
    if (viewmodel.isCalendarExpanded) {
      viewmodel.collapseCalendar();
      return false;
    }

    return true;
  }

  void _onHabitEditAppbarLeadingButtonPressed() {
    if (!mounted) return;
    final viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.exitEditMode();
  }

  ScrollPhysics? _buildScrollPhysics(double itemSize, double length) => switch (
          context.read<HabitsRecordScrollBehaviorViewModel>().scrollBehavior) {
        HabitsRecordScrollBehavior.page => const PageScrollPhysics(),
        HabitsRecordScrollBehavior.scrollable => MagnetScrollPhysics(
            itemSize: itemSize,
            metrics: FixedScrollMetrics(
              minScrollExtent: null,
              maxScrollExtent: null,
              pixels: null,
              viewportDimension: null,
              axisDirection: AxisDirection.down,
              devicePixelRatio: View.of(context).devicePixelRatio,
            )),
        _ => null
      };

  Widget _buildHabitsContentCell(BuildContext context, HabitUUID uuid) {
    return Selector<HabitSummaryViewModel,
        Tuple4<bool, UniqueKey, bool, HabitDate>>(
      selector: (context, viewmodel) => Tuple4(
        viewmodel.isCalendarExpanded,
        viewmodel.getHabitInsideVersion(uuid),
        viewmodel.isHabitSelected(uuid),
        DateChangeProvider.of(context).dateTime,
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
              return _RecordsListTile(
                uuid: uuid,
                isExtended: isExtended,
                crtDate: crtDate,
                displayPageOccupyPrt: occupyPrt,
                useCompactUI: useCompactUI,
                height: height,
                verticalScrollController: _verticalScrollController,
                horizonalScrollControllerGroup: _horizonalScrollControllerGroup,
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
    return SliverList(delegate: debugBuildSliverScrollDelegate(childCount: 0));
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
              scrolledUnderElevation: kCommonEvalation,
              title: L10nBuilder(
                builder: (context, l10n) =>
                    l10n != null ? Text(l10n.appName) : const Text(appName),
              ),
              bottom: SliverCalendarBar(
                key: const Key('habit_display_calendar_bar'),
                verticalScrollController: _verticalScrollController,
                horizonalScrollControllerGroup: _horizonalScrollControllerGroup,
                startDate: DateChangeProvider.of(context).dateTime,
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
              buttonSwitchAnimateDuration: kEditModeAppbarAnimateDuration,
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
                    callback: () => _onAppbarExportAllActionPressed(context)),
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
            duration: kEditModeAppbarAnimateDuration,
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
              scrolledUnderElevation: kCommonEvalation,
              title: buildAppbarTitle(context),
              bottom: SliverCalendarBar(
                key: const Key('habit_display_calendar_bar'),
                verticalScrollController: _verticalScrollController,
                horizonalScrollControllerGroup: _horizonalScrollControllerGroup,
                startDate: DateChangeProvider.of(context).dateTime,
                endDate: viewmodel.earliestSummaryDataStartDate?.startDate,
                isExtended: isExtended,
                collapsePrt: occupyPrt,
              ),
              actionBuilder: buildEditAppbarActions,
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
          final viewmodel = context.read<HabitSummaryViewModel>();
          appLog.build.debug(context, ex: [status], name: "$widget.Appbar");
          return SliverAnimatedSwitcher(
            duration: kEditModeChangeAnimateDuration,
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
          final viewmodel = context.read<HabitSummaryViewModel>();
          appLog.build.debug(context, ex: [value], name: "$widget.HabitList");
          return AnimatedSliverList(
            controller: viewmodel.dispatcherLinkedController,
            delegate: AnimatedSliverChildBuilderDelegate(
              (context, index, data) {
                return context
                    .read<HabitSummaryViewModel>()
                    .dispatcherLinkedBuilder(
                        context, viewmodel.lastSortedDataCache, index, data);
              },
              viewmodel.lastSortedDataCache.length,
              addAnimatedElevation: kCommonEvalation,
              morphDuration: kEditModeChangeAnimateDuration,
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
          return FutureBuilder(
            future: _loadHabitData(),
            builder: (context, snapshot) {
              // final viewmodel = context.read<HabitSummaryViewModel>();
              // appLog.load.debug("$widget.buildHabits", ex: [
              //   "Loading data",
              //   snapshot.connectionState,
              //   viewmodel.habitCount
              // ]);
              // if (kDebugMode && snapshot.isDone) {
              //   appLog.load.debug("$widget.buildHabits",
              //       ex: ["Loaded", viewmodel.debugGetDataString()]);
              // }
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
                if (!context.mounted) return;
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
      return _FAB(
        onPressed: _onFABPressed,
        onClosed: _onCreateNewHabitPageClosed,
        editModeOnPressed: _onFABPressed,
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
          builder: (context, value, child) => _EmptyImageWrapper(
            habitCount: habitCount,
            offsetHeight: -(value.item2 + kToolbarHeight),
            changedAnimateDuration: kHabitListFutureLoadDuration,
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
                    backBoardBackgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
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

    return ColorfulNavibar(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (await onWillPop() && context.mounted) {
            Navigator.of(context).popOrExit(result);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Selector<AppCompactUISwitcherViewModel, Tuple2<bool, double>>(
            selector: (context, vm) => Tuple2(vm.flag, vm.appCalendarBarHeight),
            builder: (context, value, child) => RefreshIndicator(
              notificationPredicate: (notification) {
                final context = notification.context;
                if (context == null) {
                  return defaultScrollNotificationPredicate(notification);
                }
                if (context.read<HabitSummaryViewModel>().isInEditMode) {
                  return false;
                }
                return defaultScrollNotificationPredicate(notification);
              },
              onRefresh: _onRefreshIndicatorTriggered,
              edgeOffset: kToolbarHeight +
                  value.item2 +
                  MediaQuery.paddingOf(context).top,
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              child: Stack(
                children: [
                  buildEmptyImage(context),
                  CustomScrollView(
                    physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    controller: _verticalScrollController,
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
      ),
    );
  }
}

class _EmptyImageWrapper extends StatelessWidget {
  final int habitCount;
  final double offsetHeight;
  final Duration changedAnimateDuration;
  final Widget? child;

  const _EmptyImageWrapper({
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

class _RecordsListTile extends StatelessWidget {
  final HabitUUID uuid;
  final bool isExtended;
  final HabitDate crtDate;
  final int displayPageOccupyPrt;
  final bool useCompactUI;
  final double height;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup horizonalScrollControllerGroup;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onHabitRecordPressed;
  final OnHabitSummaryPressCallback? onHabitRecordLongPressed;
  final OnHabitSummaryPressCallback? onHabitRecordDoublePressed;

  const _RecordsListTile({
    required this.uuid,
    required this.isExtended,
    required this.crtDate,
    required this.displayPageOccupyPrt,
    required this.useCompactUI,
    required this.height,
    this.verticalScrollController,
    required this.horizonalScrollControllerGroup,
    this.onHabitSummaryDataPressed,
    this.onHabitRecordPressed,
    this.onHabitRecordDoublePressed,
    this.onHabitRecordLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.read<HabitSummaryViewModel>();
    final data = viewmodel.getHabit(uuid);

    appLog.build.debug(context, ex: [isExtended, uuid, data?.name]);
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
      verticalScrollController: verticalScrollController,
      horizonalScrollControllerGroup: horizonalScrollControllerGroup,
      onHabitSummaryDataPressed: onHabitSummaryDataPressed,
      onHabitRecordPressed: onHabitRecordPressed,
      onHabitRecordLongPressed: onHabitRecordLongPressed,
      onHabitRecordDoublePressed: onHabitRecordDoublePressed,
    );
  }
}

class _FAB extends StatelessWidget {
  final void Function(VoidCallback action)? onPressed;
  final ClosedCallback<HabitDBCell>? onClosed;
  final void Function(VoidCallback action)? editModeOnPressed;

  const _FAB({
    this.onPressed,
    this.onClosed,
    this.editModeOnPressed,
  });

  Widget _buildFAB(BuildContext context,
      {required bool isAppbarPinned, required bool isInEditMode}) {
    Widget iconBuidler(BuildContext context) => AnimatedCrossFade(
        firstChild: const Icon(Icons.add),
        secondChild: const Icon(Icons.calendar_view_day_rounded),
        crossFadeState:
            isInEditMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kFABModeChangeDuration);

    Widget labelBuilder(BuildContext context) => AnimatedCrossFade(
        firstChild: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.habitDisplay_fab_text)
              : const Text('New Habit'),
        ),
        secondChild: const SizedBox(),
        crossFadeState:
            isInEditMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kFABModeChangeDuration);

    final selectedUUIDList = context
        .read<HabitSummaryViewModel>()
        .getSelectedHabitsData()
        .nonNulls
        .map((e) => e.uuid)
        .toList();
    final summary = context.read<HabitSummaryViewModel>();

    Widget pageHabitsStatusChangerBuilder(BuildContext context) {
      final page = habits_status_changer.HabitsStatusChangerPage(
        uuidList: selectedUUIDList,
      );
      if (!summary.mounted) return page;
      return Provider.value(
        value: summary.buildHabitStatusCHangerAdapter(),
        child: page,
      );
    }

    return HabitDisplayFAB<Object?>(
      closeBuilder: (context, action) {
        return ScrollingFAB.small(
          onPressed: () =>
              (isInEditMode ? editModeOnPressed : onPressed)?.call(action),
          label: labelBuilder(context),
          icon: iconBuidler(context),
          isExtended: isInEditMode ? true : isAppbarPinned,
        );
      },
      openBuilder: (context, action) => isInEditMode
          ? pageHabitsStatusChangerBuilder(context)
          : const habit_edit.HabitEditPage(showInFullscreenDialog: true),
      onClosed: (data) {
        switch (data) {
          case HabitDBCell():
            return onClosed?.call(data);
          case null:
            return;
          default:
            throw FlutterError("unhandled container close type, $data");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) =>
      Selector<HabitSummaryViewModel, Tuple3<bool, bool, int>>(
        selector: (context, viewmodel) => Tuple3(viewmodel.isAppbarPinned,
            viewmodel.isInEditMode, viewmodel.selectedHabitsCount),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => _buildFAB(context,
            isAppbarPinned: value.item1, isInEditMode: value.item2),
      );
}
