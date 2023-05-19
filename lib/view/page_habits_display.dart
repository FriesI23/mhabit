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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/logging.dart';
import '../common/types.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../db/db_helper/habits.dart';
import '../db/db_helper/records.dart';
import '../extension/async_extensions.dart';
import '../extension/color_extensions.dart';
import '../l10n/localizations.dart';
import '../model/global.dart';
import '../model/habit_date.dart';
import '../model/habit_detail_page.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_stat.dart';
import "../model/habit_summary.dart";
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/app_theme.dart';
import '../provider/habit_date_change.dart';
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

const double _kCommonEvalation = 2.0;

const _kEditModeChangeAnimateDuration = Duration(milliseconds: 200);
const _kEditModeAppbarAnimateDuration = Duration(milliseconds: 200);

const _kPressFABAnimateDuration = Duration(milliseconds: 500);

const _kHabitListFutureLoadDuration = Duration(milliseconds: 300);

enum _EditModePopupItemEnum {
  delete,
  exportAll,
  selectAll,
}

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
    super.initState();
    var viewmodel = context.read<HabitSummaryViewModel>();
    var dispatcher = AnimatedListDiffListDispatcher<HabitSortCache>(
      controller: AnimatedListController(),
      itemBuilder: (context, element, data) {
        if (data.measuring) {
          return const SizedBox(height: kHabitSummaryListTileHeight);
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
      recordForm: HabitDailyRecordForm(crtNum, data.dailyGoal),
      recordStatus: record?.status ?? HabitRecordStatus.unknown,
      recordDate: date,
    );

    if (result == null || result == orgNum || !mounted) return;
    viewmodel.onLongPressChangeRecordValue(parentUUID, date, result);
  }

  void _exportSelectedHabitsAndShared(BuildContext context) async {
    if (!mounted) return;

    final habitUUID = context
        .read<HabitSummaryViewModel>()
        .getExportUseSelectedHabitUUID()
        .toList();
    final filePath = await context
        .read<HabitFileExporterViewModel>()
        .exportMultiHabitsData(habitUUID);

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

  Future<void> _onAppbarEditActionPressed() async {
    HabitSummaryViewModel viewmodel;
    if (!mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    var selectedData = viewmodel.getSelectedHabitsData().firstWhere(
          (element) => element != null,
          orElse: () => null,
        );

    if (selectedData == null) return;
    var dbcell = await loadHabitDetailFromDB(selectedData.uuid);

    if (!mounted || dbcell == null) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    var form = HabitForm.fromHabitDBCell(
      dbcell,
      editMode: HabitDisplayEditMode.edit,
      editParams: HabitDisplayEditParams(
        uuid: dbcell.uuid!,
        createT:
            DateTime.fromMillisecondsSinceEpoch(dbcell.createT! * onSecondMS),
        modifyT:
            DateTime.fromMillisecondsSinceEpoch(dbcell.modifyT! * onSecondMS),
      ),
    );
    if (viewmodel.isInEditMode) {
      context.read<HabitSummaryViewModel>().exitEditMode();
      await Future.delayed(_kEditModeChangeAnimateDuration);
    }

    if (!mounted) return;
    final result = await habit_edit_view.naviToHabitEidtPage(
        context: context, initForm: form);

    // Editing Habit involves complex state changes (such as sorting by
    // completion rate, calculating the start date of check-in data, etc.),
    // so it is necessary to reload all data from the database.
    if (result == null || !mounted) return;
    viewmodel = context.read<HabitSummaryViewModel>();
    viewmodel.rockreloadDBToggleSwich();
  }

  void _onAppbarLeftButtonPressed(bool lastStatus) {
    if (!mounted) return;
    context
        .read<HabitSummaryViewModel>()
        .updateCalendarExpanedStatus(!lastStatus);
  }

  void _onHabitRecordPressed(
    HabitUUID puuid,
    HabitRecordUUID? uuid,
    HabitRecordDate date,
    HabitRecordStatus crt,
  ) async {
    if (!mounted) return;
    await context
        .read<HabitSummaryViewModel>()
        .onTapToChangeRecordStatus(puuid, date);
  }

  void _onHabitRecordLongPressed(
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
        _openHabitRecordResonModifierDialog(context, puuid, uuid, date, crt);
        break;
      default:
        _openHabitRecordCusomNumberPickerDialog(
            context, puuid, uuid, date, crt);
        break;
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
      builder: (context, value, child) {
        final isExtended = value.item1;
        final crtDate = value.item4;
        final viewmodel = context.read<HabitSummaryViewModel>();
        final data = viewmodel.getHabit(uuid);

        DebugLog.rebuild("HabitSummaryListTile:: $value | "
            "id=${data?.id}, uuid=${data?.uuid}, sort=${data?.sortPostion}, "
            "remind[${data?.reminderQuest?.length ?? -1}]=${data?.reminder}");
        if (data == null) {
          WarnLog.rebuild("HabitSummaryListTile:: data not found: $uuid");
          return const SizedBox();
        }
        return HabitDisplayListTile(
          startDate: crtDate,
          endedData: viewmodel.earliestSummaryDataStartDate?.startDate,
          isExtended: isExtended,
          isSelected: viewmodel.isHabitSelected(uuid),
          isInEditMode: viewmodel.isInEditMode,
          data: data,
          verticalScrollController: viewmodel.verticalScrollController,
          horizonalScrollControllerGroup:
              viewmodel.horizonalScrollControllerGroup,
          onHabitSummaryDataPressed: _onHabitSummaryDataPressed,
          onHabitRecordPressed: _onHabitRecordPressed,
          onHabitRecordLongPressed: _onHabitRecordLongPressed,
        );
      },
    );
  }

  Widget _buildScrollablePlaceHolder(BuildContext context) {
    return SliverList(
        delegate:
            DebugBuilderMethods.debugBuildSliverScrollDelegate(childCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    DebugLog.rebuild("HabitsDisplayView:: $hashCode");

    //#region: appbar
    Widget buildAppbarInViewMode(BuildContext context, bool isExtended) {
      return Selector<HabitsRecordScrollBehaviorViewModel,
          HabitsRecordScrollBehavior>(
        key: const ValueKey("view-app-bar"),
        selector: (context, vm) => vm.scrollBehavior,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, scrollBehavior, child) {
          final viewmodel = context.read<HabitSummaryViewModel>();
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
              onLeftBtnPressed: _onAppbarLeftButtonPressed,
              scrollPhysicsBuilder: (itemSize, length) => context
                  .read<HabitsRecordScrollBehaviorViewModel>()
                  .getPhysics(itemSize),
            ),
            onInfoButtonPressed: () =>
                _openHabitSummaryStatisticsDialog(context),
            onMenuButtonPressed: () => _openHabitSummaryMenuDialog(context),
          );
        },
      );
    }

    Widget buildAppbarInEditMode(BuildContext context, bool isExtended) {
      Widget buildEditAppbarActions(BuildContext context) {
        return Selector<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
          selector: (context, viewmodel) => viewmodel.selectStatistic,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, stat, child) => Row(
            children: [
              L10nBuilder(
                builder: (context, l10n) => AnimatedSwitcher(
                  duration: _kEditModeAppbarAnimateDuration,
                  switchInCurve: Curves.easeInQuart,
                  child: stat.selected == 1
                      ? IconButton(
                          onPressed: _onAppbarEditActionPressed,
                          icon: const Icon(Icons.edit_rounded),
                          tooltip: l10n?.habitDisplay_editButton_tooltip ??
                              "Edit Habit",
                        )
                      : const SizedBox(),
                ),
              ),
              L10nBuilder(
                builder: (context, l10n) => AnimatedSwitcher(
                  duration: _kEditModeAppbarAnimateDuration,
                  switchInCurve: Curves.easeInQuart,
                  child: stat.archived > 0
                      ? IconButton(
                          onPressed: () =>
                              _openHabitUnArchiveConfirmDialog(context),
                          icon: const Icon(Icons.unarchive_rounded),
                          tooltip: l10n?.habitDisplay_unarchiveButton_tooltip ??
                              "Unarchive",
                        )
                      : const SizedBox(),
                ),
              ),
              L10nBuilder(
                builder: (context, l10n) => AnimatedSwitcher(
                  duration: _kEditModeAppbarAnimateDuration,
                  switchInCurve: Curves.easeInQuart,
                  child: stat.activated > 0
                      ? IconButton(
                          onPressed: () =>
                              _openHabitArchiveConfirmDialog(context),
                          icon: const Icon(Icons.archive_outlined),
                          tooltip: l10n?.habitDisplay_archiveButton_tooltip ??
                              "Archive",
                        )
                      : const SizedBox(),
                ),
              ),
              PopupMenuButton<_EditModePopupItemEnum>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  switch (value) {
                    case _EditModePopupItemEnum.delete:
                      _openHabitDeleteConfirmDialog(context);
                      break;
                    case _EditModePopupItemEnum.selectAll:
                      context.read<HabitSummaryViewModel>().selectAllHabit();
                      break;
                    case _EditModePopupItemEnum.exportAll:
                      _exportSelectedHabitsAndShared(context);
                      break;
                  }
                },
                itemBuilder: (context) {
                  final l10n = L10n.of(context);
                  return <PopupMenuItem<_EditModePopupItemEnum>>[
                    PopupMenuItem<_EditModePopupItemEnum>(
                      value: _EditModePopupItemEnum.selectAll,
                      child: ListTile(
                        title: l10n != null
                            ? Text(l10n.habitDisplay_editPopMenu_selectAll)
                            : const Text("Select All"),
                        leading: const Icon(Icons.select_all_outlined),
                      ),
                    ),
                    PopupMenuItem<_EditModePopupItemEnum>(
                      value: _EditModePopupItemEnum.exportAll,
                      child: ListTile(
                        title: l10n != null
                            ? Text(l10n.habitDisplay_editPopMenu_export)
                            : const Text("Export"),
                        leading: const Icon(MdiIcons.export),
                      ),
                    ),
                    PopupMenuItem<_EditModePopupItemEnum>(
                      value: _EditModePopupItemEnum.delete,
                      child: ListTile(
                        title: l10n != null
                            ? Text(l10n.habitDisplay_editPopMenu_delete)
                            : const Text("Delete"),
                        leading: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ];
                },
              ),
            ],
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
        builder: (context, scrollBehavior, child) {
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
            ),
            actionBuilder: (context) => buildEditAppbarActions(context),
            onLeadingButtonPressed: _onHabitEditAppbarLeadingButtonPressed,
          );
        },
      );
    }

    Widget buildAppbar(BuildContext context) {
      return Selector<HabitSummaryViewModel, HabitSummaryStatusCache>(
        selector: (context, viewmodel) => viewmodel.currentState,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, status, child) {
          var viewmodel = context.read<HabitSummaryViewModel>();
          DebugLog.rebuild("Appbar:: $status");
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
          DebugLog.rebuild("HabitSummaryList:: ... $value");
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
              DebugLog.load("------ "
                  "Load data ${snapshot.connectionState}, "
                  "${viewmodel.habitCount}");
              if (kDebugMode && snapshot.isDone) {
                DebugLog.load(viewmodel.debugGetDataString());
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
      return const SliverToBoxAdapter(child: FixedPagePlaceHolder());
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
        builder: (context, habitCount, child) => _HabitDisplayEmptyImageFrame(
          habitCount: habitCount,
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
      );
    }
    //#endregion

    var viewmodel = context.read<HabitSummaryViewModel>();
    return ColorfulNavibar(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: RefreshIndicator(
          onRefresh: _onRefreshIndicatorTriggered,
          edgeOffset: kToolbarHeight + kHabitCalendarBarHeight + 20.0,
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
        floatingActionButton: buildFAB(context),
      ),
    );
  }
}

class _HabitDisplayEmptyImageFrame extends StatelessWidget {
  final int habitCount;
  final Duration changedAnimateDuration;
  final Widget? child;

  const _HabitDisplayEmptyImageFrame({
    required this.habitCount,
    required this.changedAnimateDuration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = kHabitCalendarBarHeight + kToolbarHeight;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: constraints.copyWith(
                maxHeight: math.max(constraints.maxHeight - barHeight, 0)),
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
