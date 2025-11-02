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
import '../../extensions/color_extensions.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/navigator_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_date.dart';
import '../../models/habit_display.dart';
import '../../models/habit_form.dart';
import '../../models/habit_status.dart';
import "../../models/habit_summary.dart";
import '../../providers/app_compact_ui_switcher.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_experimental_feature.dart';
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
  late HabitSummaryViewModel _vm;

  late final LinkedScrollControllerGroup _horizonalScrollControllerGroup;
  late PinnedAppbarScrollController _verticalScrollController;
  late double _toolbarHeight;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    _vm = context.read<HabitSummaryViewModel>();
    // events
    _vm.scrollCalendarToStartEvent.listen(_resetHorizonalScrollController);
    // scroll controllers
    _horizonalScrollControllerGroup = LinkedScrollControllerGroup();
    _initVerticalScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitSummaryViewModel>();
    if (vm != _vm) {
      _vm = vm;
    }
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

  void _initVerticalScrollController() {
    final vm = context.read<AppExperimentalFeatureViewModel>();
    _toolbarHeight = vm.habitSearch ? kSearchAppBarHeight : kToolbarHeight;
    _verticalScrollController = PinnedAppbarScrollController(
      toolbarHeight: _toolbarHeight,
      onAppbarStatusChanged: _changeAppbarStatus,
    )..addChangeAppbarStatusListener();
    vm
      ..removeListener(_updateVerticalScrollController)
      ..addListener(_updateVerticalScrollController);
  }

  void _updateVerticalScrollController() {
    final oldController = _verticalScrollController;
    try {
      _initVerticalScrollController();
    } finally {
      if (oldController != _verticalScrollController) oldController.dispose();
    }
  }

  void _changeAppbarStatus(bool pinned) {
    final vm = context.maybeRead<HabitSummaryViewModel>();
    if (vm == null || !vm.mounted) return;
    pinned ? vm.pinAppbar() : vm.unpinAppbar();
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

  void _openHabitSummaryMenuDialog() async {
    if (!mounted) return;
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
        _openHabitSummarySortSelectorDialog();
        break;
      case HabitDisplayMainMenuDialogOpr.openSettings:
        if (!mounted) return;
        _openAppSettingsPage();
        break;
    }
  }

  void _openHabitSummaryStatisticsDialog() {
    if (!mounted) return;
    showHabitDisplayStatsMenuDialog(
      context: context,
      summary: context.read<HabitSummaryViewModel>(),
    );
  }

  void _openHabitSummarySortSelectorDialog() async {
    if (!mounted) return;
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
    HabitUUID parentUUID,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    if (!_vm.mounted) return;
    final data = _vm.getHabit(parentUUID);
    if (data == null) return;
    final initReason = await _vm.loadRecordReason(data, date) ?? '';
    if (!mounted) return;
    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: data.colorType,
    );

    if (result == null || result == initReason) return;
    if (!(mounted && _vm.mounted)) return;
    _vm.changeRecordReason(parentUUID, date, result).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  void _openHabitRecordCusomNumberPickerDialog(
    HabitUUID parentUUID,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    final data = _vm.getHabit(parentUUID);
    if (data == null) return;
    final crtNum = data.getEffectiveDailyValue(date);
    final record = data.getRecordByDate(date);
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

    if (result == null || result == record?.value) return;
    if (!(mounted && _vm.mounted)) return;
    _vm.changeRecordValue(parentUUID, date, result).then((record) {
      if (!mounted || record == null) return;
      _onRecordChangeConfirmed();
    });
  }

  void _openRecordStatusDialog(
    HabitUUID puuid,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    if (!(mounted && _vm.mounted)) return;

    final data = _vm.getHabit(puuid);
    if (data == null) return;

    final record = data.getRecordByDate(date);
    switch (record?.status) {
      case HabitRecordStatus.skip:
        return _openHabitRecordResonModifierDialog(puuid, uuid, date, crt);
      default:
        return _openHabitRecordCusomNumberPickerDialog(puuid, uuid, date, crt);
    }
  }

  void _changeRecordStatus(
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

  void _openAppSettingsPage() {
    if (!mounted) return;
    if (_vm.mounted) {
      _vm.exitSearchMode();
      _vm.exitEditMode();
    }
    app_settings.naviToAppSettingPage(context: context);
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
    if (!(mounted && _vm.mounted)) return false;
    final dbcell = await _vm.loadSelectedHabitDetail();
    if (dbcell == null) return false;
    if (!(mounted && _vm.mounted)) return false;
    final form = formBuilder(dbcell);
    if (_vm.isInEditMode) {
      _vm.exitEditMode();
      await Future.delayed(exitEditModeDuration);
      if (!mounted) return false;
    }

    final result =
        await habit_edit.naviToHabitEidtPage(context: context, initForm: form);

    if (result == null) return false;
    if (!(mounted && _vm.mounted)) return false;
    // Edit/Create Habit involves complex state changes (such as sorting by
    // completion rate, calculating the start date of check-in data, etc.),
    // so it is necessary to reload all data from the database.
    _vm.rockreloadDBToggleSwich();
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
    context.read<HabitSummaryViewModel>().toggleCalendarStatus();
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
        colorType: _vm.getHabit(uuid)?.colorType,
        summary: _vm,
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

    if (_vm.isInEditMode) {
      preessedInEditMode();
    } else {
      await pressedInViewMode();
    }
  }

  Future<bool> onWillPop() async {
    if (!mounted) return true;
    var count = 0;
    if (_vm.isInEditMode) {
      _vm.exitEditMode();
      count++;
    }
    if (_vm.isInSearchMode) {
      _vm.exitSearchMode();
      count++;
    }
    if (_vm.isCalendarExpanded) {
      _vm.collapseCalendar();
      count++;
    }
    return count <= 0;
  }

  void _onHabitEditAppbarLeadingButtonPressed() {
    if (!mounted) return;
    final viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.exitEditMode();
  }

  Widget _buildScrollablePlaceHolder(BuildContext context) {
    return SliverList(delegate: debugBuildSliverScrollDelegate(childCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    //#region: appbar
    Widget buildAppbar(BuildContext context) {
      return Selector<HabitSummaryViewModel, HabitSummaryStatusCache>(
        selector: (context, vm) => vm.currentState,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, state, child) {
          Widget build(BuildContext context) => state.isInEditMode
              ? SliverEditTopAppBar(
                  height: _toolbarHeight,
                  onLeadingButtonPressed:
                      _onHabitEditAppbarLeadingButtonPressed,
                  action: SliverEditTopAppBarAction(
                    onEdit: _onAppbarEditActionPressed,
                    onUnarchive: _onAppbarUnArchiveActionPressed,
                    onArchive: _onAppbarArchiveActionPressed,
                    onSelectAll: _onAppbarSelectAllActionPressed,
                    onClone: _onAppbarCloneActionPressed,
                    onExportAll: _onAppbarExportAllActionPressed,
                    onDelete: _onAppbarDeleteActionPressed,
                  ),
                )
              : Selector<AppExperimentalFeatureViewModel, bool>(
                  selector: (context, vm) => vm.habitSearch,
                  builder: (context, enableSearch, child) {
                    if (enableSearch) {
                      return SliverSearchTopAppBar(
                        height: _toolbarHeight,
                        onInfoButtonPressed: _openHabitSummaryStatisticsDialog,
                        onMenuButtonPressed: _openHabitSummaryMenuDialog,
                      );
                    }
                    return SliverViewTopAppBar(
                      height: _toolbarHeight,
                      onInfoButtonPressed: _openHabitSummaryStatisticsDialog,
                      onMenuButtonPressed: _openHabitSummaryMenuDialog,
                    );
                  },
                );

          appLog.build.debug(context, ex: [state], name: "HabitDisplay.Appbar");
          return SliverAnimatedSwitcher(
            duration: kEditModeChangeAnimateDuration,
            child: build(context),
          );
        },
      );
    }
    //#endregion

    //#region calendar bar
    Widget buildCalendarBar(BuildContext context) {
      return _CalendarBar(
        key: const ValueKey("calendar-bar"),
        verticalScrollController: _verticalScrollController,
        horizonalScrollControllerGroup: _horizonalScrollControllerGroup,
        onCalendarToggleExpandPressed: _onAppbarLeftButtonPressed,
      );
    }
    //#endregion

    //#region habits list
    Widget buildHabits(BuildContext context) {
      return EnhancedSafeArea.edgeToEdgeSafe(
        withSliver: true,
        child: _HabitList(
          horizonalScrollControllerGroup: _horizonalScrollControllerGroup,
          verticalScrollController: _verticalScrollController,
          reorderModel: AnimatedListReorderModel(
            onReorderStart: _onHabitListReorderStart,
            onReorderMove: _onHabitListReorderMove,
            onReorderComplete: _onHabitListReorderComplete,
          ),
          onHabitSummaryDataPressed: _onHabitSummaryDataPressed,
          onOpenRecordStatusDialog: _openRecordStatusDialog,
          onChangeRecordStatus: _changeRecordStatus,
        ),
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
        selector: (context, viewmodel) => viewmodel.currentHabitList.length,
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
                final summary = context.read<HabitSummaryViewModel>();
                final sync = context.read<AppSyncViewModel>();
                if (summary.isInEditMode ||
                    !(sync.enabled && sync.serverConfig != null)) {
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
                      buildCalendarBar(context),
                      const PinnedHeaderSliver(child: HabitDivider(height: 1)),
                      buildHabits(context),
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

class _HabitList extends StatefulWidget {
  final LinkedScrollControllerGroup horizonalScrollControllerGroup;
  final PinnedAppbarScrollController verticalScrollController;
  final AnimatedListBaseReorderModel? reorderModel;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onOpenRecordStatusDialog;
  final OnHabitSummaryPressCallback? onChangeRecordStatus;

  const _HabitList({
    required this.horizonalScrollControllerGroup,
    required this.verticalScrollController,
    this.reorderModel,
    this.onHabitSummaryDataPressed,
    this.onOpenRecordStatusDialog,
    this.onChangeRecordStatus,
  });

  @override
  State<_HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<_HabitList> {
  late HabitSummaryViewModel _vm;

  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;

  LinkedScrollControllerGroup get _effectiveHorizonalScrollControllerGroup =>
      widget.horizonalScrollControllerGroup;

  PinnedAppbarScrollController get _effectiveVerticalScrollController =>
      widget.verticalScrollController;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    _vm = context.read<HabitSummaryViewModel>()
      ..addListener(_onViewModelNotified);
    _dispatcher = buildDispatcher();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitSummaryViewModel>();
    if (vm != _vm) {
      _vm.removeListener(_onViewModelNotified);
      _vm = vm..addListener(_onViewModelNotified);
    }
  }

  @override
  void dispose() {
    _dispatcher.discard();
    _vm.removeListener(_onViewModelNotified);
    super.dispose();
  }

  void _onViewModelNotified() {
    _dispatcher.dispatchNewList(_vm.currentHabitList);
  }

  @visibleForTesting
  AnimatedListDiffListDispatcher<HabitSortCache> buildDispatcher() =>
      AnimatedListDiffListDispatcher<HabitSortCache>(
        controller: AnimatedListController(),
        itemBuilder: (context, element, data) {
          if (data.measuring) {
            return const _HabitListItemMeasurer();
          } else if (element is HabitSummaryDataSortCache) {
            return _HabitListItem(
              uuid: element.uuid,
              horizonalScrollControllerGroup:
                  _effectiveHorizonalScrollControllerGroup,
              verticalScrollController: _effectiveVerticalScrollController,
              onHabitSummaryDataPressed: widget.onHabitSummaryDataPressed,
              onChangeRecordStatus: widget.onChangeRecordStatus,
              onOpenRecordStatusDialog: widget.onOpenRecordStatusDialog,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
        currentList: _vm.currentHabitList,
        comparator: AnimatedListDiffListComparator<HabitSortCache>(
          sameItem: (a, b) => a.isSameItem(b),
          sameContent: (a, b) => a.isSameContent(b),
        ),
      );

  @visibleForTesting
  Future<void> loadData() async {
    if (!mounted) return;
    final minBarShowTimeFuture = Future.delayed(kHabitListFutureLoadDuration);
    final sync = context.read<AppSyncViewModel>();
    if (sync.mounted) await sync.appSyncTask.processing;
    if (!(mounted && _vm.mounted)) return;
    if (!_vm.isDataLoaded) {
      await Future.wait(
          [_vm.loadData(inFutureBuilder: true), minBarShowTimeFuture]);
      if (!(mounted && _vm.mounted)) return;
    }
    if (_vm.consumeClearSnackBarFlag()) {
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HabitSummaryViewModel, (bool, bool)>(
      selector: (context, vm) => (vm.reloadDBToggleSwich, vm.isDataLoaded),
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, _, child) => FutureBuilder(
        future: loadData(),
        builder: (context, _) => Selector<HabitSummaryViewModel, bool>(
          selector: (context, viewmodel) => viewmodel.reloadUIToggleSwitch,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, _, child) => AnimatedSliverList(
            controller: _dispatcher.controller,
            delegate: AnimatedSliverChildBuilderDelegate(
                (context, index, data) => _dispatcher.builder(
                    context, _vm.currentHabitList, index, data),
                _vm.currentHabitList.length,
                animator: kHabitContentListAnimator,
                addAnimatedElevation: kCommonEvalation,
                morphDuration: kEditModeChangeAnimateDuration,
                reorderModel: widget.reorderModel),
          ),
        ),
      ),
    );
  }
}

class _HabitListItemMeasurer extends StatelessWidget {
  const _HabitListItemMeasurer();

  @override
  Widget build(BuildContext context) {
    final height = context.select<AppCompactUISwitcherViewModel, double>(
        (vm) => vm.appHabitDisplayListTileHeight);
    return SizedBox(height: height);
  }
}

class _HabitListItemRecordCallbackResolver {
  final _HabitListItem widget;
  final UserAction changeRecordStatusAction;
  final UserAction openRecordStatusDialogAction;

  const _HabitListItemRecordCallbackResolver(
    this.widget, {
    required this.changeRecordStatusAction,
    required this.openRecordStatusDialogAction,
  });

  OnHabitSummaryPressCallback? resolve(UserAction action) =>
      (changeRecordStatusAction == action
          ? widget.onChangeRecordStatus
          : null) ??
      (openRecordStatusDialogAction == action
          ? widget.onOpenRecordStatusDialog
          : null);
}

class _HabitListItem extends StatelessWidget {
  final HabitUUID uuid;
  final LinkedScrollControllerGroup horizonalScrollControllerGroup;
  final PinnedAppbarScrollController verticalScrollController;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onOpenRecordStatusDialog;
  final OnHabitSummaryPressCallback? onChangeRecordStatus;

  const _HabitListItem({
    required this.uuid,
    required this.horizonalScrollControllerGroup,
    required this.verticalScrollController,
    this.onHabitSummaryDataPressed,
    this.onOpenRecordStatusDialog,
    this.onChangeRecordStatus,
  });

  @override
  Widget build(BuildContext context) {
    final crtDate = DateChangeProvider.of(context).dateTime;
    final (isExtended, data, endedDate, isSelected, isInEditMode, _) =
        context.select<HabitSummaryViewModel,
                (bool, HabitSummaryData?, HabitDate?, bool, bool, UniqueKey)>(
            (vm) => (
                  vm.isCalendarExpanded,
                  vm.getHabit(uuid),
                  vm.earliestSummaryDataStartDate?.startDate,
                  vm.isHabitSelected(uuid),
                  vm.isInEditMode,
                  vm.getHabitInsideVersion(uuid),
                ));
    final occupyPrt =
        context.select<AppThemeViewModel, int>((vm) => vm.displayPageOccupyPrt);
    final (useCompactUI, height) =
        context.select<AppCompactUISwitcherViewModel, (bool, double)>(
            (vm) => (vm.flag, vm.appHabitDisplayListTileHeight));
    final (changeRecordStatusAction, openRecordStatusDialogAction) =
        context.select<HabitRecordOpConfigViewModel, (UserAction, UserAction)>(
            (vm) => (vm.changeRecordStatus, vm.openRecordStatusDialog));
    final actionResolver = _HabitListItemRecordCallbackResolver(this,
        changeRecordStatusAction: changeRecordStatusAction,
        openRecordStatusDialogAction: openRecordStatusDialogAction);
    if (data == null) {
      appLog.build
          .warn(context, ex: ["data not found", uuid], name: "_HabitListItem");
      return const SizedBox.shrink();
    }
    appLog.build.debug(context, ex: ["habit", uuid], name: "_HabitListItem");
    return HabitDisplayListTile(
      startDate: crtDate,
      endedData: endedDate,
      isExtended: isExtended,
      isSelected: isSelected,
      isInEditMode: isInEditMode,
      collapsePrt: occupyPrt,
      compactVisual: useCompactUI,
      height: height,
      data: data,
      verticalScrollController: verticalScrollController,
      horizonalScrollControllerGroup: horizonalScrollControllerGroup,
      onHabitSummaryDataPressed: onHabitSummaryDataPressed,
      onHabitRecordPressed: actionResolver.resolve(UserAction.tap),
      onHabitRecordLongPressed: actionResolver.resolve(UserAction.longTap),
      onHabitRecordDoublePressed: actionResolver.resolve(UserAction.doubleTap),
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

    Widget habitsStatusChangerPageBuilder(BuildContext context) =>
        habits_status_changer.HabitsStatusChangerPage(
            uuidList: selectedUUIDList);

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
          ? habitsStatusChangerPageBuilder(context)
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

class _CalendarBar extends StatelessWidget {
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;

  const _CalendarBar({
    super.key,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onCalendarToggleExpandPressed,
  });

  @override
  Widget build(BuildContext context) {
    final state =
        context.select<HabitSummaryViewModel, HabitSummaryStatusCache>(
            (vm) => vm.currentState);
    final displayPageOccupyPrt =
        context.select<AppThemeViewModel, int>((vm) => vm.displayPageOccupyPrt);
    final earliestStartDate = context.select<HabitSummaryViewModel, DateTime?>(
        (vm) => vm.earliestSummaryDataStartDate?.startDate);
    final (appCalendarBarHeight, appCalendarBarItemPadding) =
        context.select<AppCompactUISwitcherViewModel, (double, EdgeInsets)>(
            (vm) => (vm.appCalendarBarHeight, vm.appCalendarBarItemPadding));
    final scrollBehavior = context.select<HabitsRecordScrollBehaviorViewModel,
        HabitsRecordScrollBehavior>((vm) => vm.scrollBehavior);
    appLog.build.debug(context,
        ex: [
          state,
          displayPageOccupyPrt,
          earliestStartDate,
          appCalendarBarHeight,
          appCalendarBarItemPadding
        ],
        name: "HabitDisplay.calendarBar");
    final scrolledUnderElevation = state.isInEditMode ? 0.0 : kCommonEvalation;
    final backgroundColor =
        state.isInEditMode ? Theme.of(context).colorScheme.surface : null;

    ScrollPhysics? buildScrollPhysics(double itemSize, double length) {
      return switch (scrollBehavior) {
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
    }

    return SliverAppBar(
      pinned: true,
      shadowColor: Theme.of(context).colorScheme.shadow,
      backgroundColor: backgroundColor,
      scrolledUnderElevation: scrolledUnderElevation,
      titleSpacing: 0.0,
      primary: false,
      toolbarHeight: appCalendarBarHeight,
      title: EnhancedSafeArea.edgeToEdgeSafe(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SliverCalendarBar(
              verticalScrollController: verticalScrollController,
              horizonalScrollControllerGroup: horizonalScrollControllerGroup,
              startDate: DateChangeProvider.of(context).dateTime,
              endDate: earliestStartDate,
              isExtended: state.isClandarExpanded,
              collapsePrt: displayPageOccupyPrt,
              height: appCalendarBarHeight,
              itemPadding: appCalendarBarItemPadding,
              onLeftBtnPressed: onCalendarToggleExpandPressed,
              scrollPhysicsBuilder: buildScrollPhysics,
            ),
            const _LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDataLoaded =
        context.select<HabitSummaryViewModel, bool>((vm) => vm.isDataLoaded);
    return AnimatedOpacity(
      opacity: isDataLoaded ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: const AppSyncLoadingIndicator(),
    );
  }
}
