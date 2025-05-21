// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

import '../common/types.dart';
import '../common/utils.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../extension/context_extensions.dart';
import '../extension/navigator_extensions.dart';
import '../logging/helper.dart';
import '../model/custom_date_format.dart';
import '../model/habit_date.dart';
import '../model/habit_summary.dart';
import '../provider/app_compact_ui_switcher.dart';
import '../provider/app_custom_date_format.dart';
import '../provider/app_developer.dart';
import '../provider/app_sync.dart';
import '../provider/habit_status_changer.dart';
import '../provider/habit_summary.dart';
import '../utils/safe_sliver_tools.dart';
import 'common/_dialog.dart';
import 'common/_widget.dart';
import 'for_habits_status_changer/_widget.dart';

/// Depend Providers
/// - Required for builder:
///   - [AppCustomDateYmdHmsConfigViewModel]
///   - [AppCompactUISwitcherViewModel]
///   - [AppDeveloperViewModel]
/// - Required for callback:
/// - Optional:
///   - [HabitSummaryViewModel]
class PageHabitsStatusChanger extends StatelessWidget {
  final List<HabitUUID> uuidList;

  const PageHabitsStatusChanger({super.key, required this.uuidList});

  @override
  Widget build(BuildContext context) => PageProviders(
        uuidList: uuidList,
        child: const HabitsStatusChangerView(),
      );
}

class HabitsStatusChangerView extends StatefulWidget {
  const HabitsStatusChangerView({super.key});

  @override
  State<StatefulWidget> createState() => _HabitsStatusChangerView();
}

class _HabitsStatusChangerView extends State<HabitsStatusChangerView> {
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

  void _onSelectedDateChanged(HabitDate od, HabitDate nd) {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.updateSelectDate(nd);
  }

  void _onSelectedStatusChanged(
      RecordStatusChangerStatus? od, RecordStatusChangerStatus? nd) {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.updateSelectStatus(nd);
  }

  void _onConfirmButtonpressed() async {
    HabitStatusChangerViewModel vm;
    if (!mounted) return;
    vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;

    if (vm.selectDateRecords.isNotEmpty) {
      final result = (await showConfirmDialog(
            context: context,
            titleBuilder: (context) => L10nBuilder(
                builder: (context, l10n) => l10n != null
                    ? Text(l10n.batchCheckin_save_confirmDialog_title)
                    : const Text("Overwrite Existing Records")),
            subtitleBuilder: (context) => L10nBuilder(
                builder: (context, l10n) => l10n != null
                    ? Text(l10n.batchCheckin_save_confirmDialog_body)
                    : const SizedBox()),
            confirmTextBuilder: (context) => L10nBuilder(
                builder: (context, l10n) => l10n != null
                    ? Text(
                        l10n.batchCheckin_save_confirmDialog_confirmButton_text)
                    : const Text("save")),
            cancelText: L10nBuilder(
                builder: (context, l10n) => l10n != null
                    ? Text(
                        l10n.batchCheckin_save_confirmDialog_cancelButton_text)
                    : const Text("cancel")),
          )) ??
          false;
      if (!mounted || !result) return;
    }
    vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;

    final changedCount = await vm.saveSelectStatus();
    if (!mounted || changedCount <= 0) return;

    final appSync = context.maybeRead<AppSyncViewModel>();
    if (appSync != null && appSync.mounted) {
      appSync.delayedStartTaskOnce();
    }
    final summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary != null && summary.mounted) {
      summary.forHabitsStatusChanger.onHabitDataChanged();
    }

    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: L10nBuilder(
            builder: (context, l10n) => Text(
                l10n?.batchCheckin_completed_snackbar_text(changedCount) ??
                    "Changed: $changedCount")));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onResetButtonPressed() {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.resetStatusForm();
  }

  Future<void> _onClosePageButtonPressed<T>(
      {bool defaultConfirmResult = false, T? result}) async {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    final bool savedResult = vm.canSave
        ? (await showConfirmDialog(
              context: context,
              titleBuilder: (context) => L10nBuilder(
                  builder: (context, l10n) => l10n != null
                      ? Text(l10n.batchCheckin_close_confirmDialog_title)
                      : const Text("Unsaved Check-in Status")),
              subtitleBuilder: (context) => L10nBuilder(
                  builder: (context, l10n) => l10n != null
                      ? Text(l10n.batchCheckin_close_confirmDialog_body)
                      : const SizedBox()),
              confirmTextBuilder: (context) => L10nBuilder(
                  builder: (context, l10n) => l10n != null
                      ? Text(l10n
                          .batchCheckin_close_confirmDialog_confirmButton_text)
                      : const Text("exit")),
              cancelText: L10nBuilder(
                  builder: (context, l10n) => l10n != null
                      ? Text(l10n
                          .batchCheckin_close_confirmDialog_cancelButton_text)
                      : const Text("cancel")),
            ) ??
            defaultConfirmResult)
        : true;
    if (!mounted) return;

    if (savedResult) {
      dismissAllToolTips().then(
          (_) => mounted ? Navigator.of(context).popOrExit(result) : false);
    }
  }

  Widget _buildDebugInfo(BuildContext context) =>
      Consumer<HabitStatusChangerViewModel>(
        builder: (context, value, child) => ListTile(
          leading:
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          isThreeLine: true,
          title: const Text('DEBUG'),
          subtitle: Column(
            children: [
              Text(context.read<HabitStatusChangerViewModel>().toString()),
              Text(context
                  .read<HabitStatusChangerViewModel>()
                  .selectDateAllowedStatus
                  .toString()),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    Widget buildDatePickerTile(BuildContext context) =>
        Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
          selector: (context, vm) => vm.config,
          builder: (context, formatter, child) {
            return Selector<HabitStatusChangerViewModel, HabitsDataDelagate>(
              selector: (context, vm) => vm.dataDelegate,
              shouldRebuild: (previous, next) => previous != next,
              builder: (context, _, child) {
                final vm = context.read<HabitStatusChangerViewModel>();
                return DatePickerTile(
                  initDate: vm.selectDate,
                  firstDate: vm.earlistStartDate,
                  formatter: formatter,
                  onSelectDateChanged: _onSelectedDateChanged,
                );
              },
            );
          },
        );

    Widget buildStatusChangeTile(BuildContext context) =>
        Selector<HabitStatusChangerViewModel, RecordStatusChangerStatus?>(
          selector: (context, vm) => vm.selectStatus,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, _, child) {
            final vm = context.read<HabitStatusChangerViewModel>();
            return ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: RecordStatusChangeTile(
                initStatus: vm.selectStatus,
                allowedStatus: vm.selectDateAllowedStatus,
                onSelectedNewStatus: _onSelectedStatusChanged,
              ),
            );
          },
        );

    Widget buildSkipStatusReasonField(BuildContext context) {
      return Selector<HabitStatusChangerViewModel, RecordStatusChangerStatus?>(
        selector: (context, vm) => vm.selectStatus,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, selectStatus, child) {
          final vm = context.read<HabitStatusChangerViewModel>();
          return ExpandedSection(
            duration: vm.mainScrollAnimatedDuration,
            curve: vm.mainScrollAnimatedCurve,
            expand: selectStatus == RecordStatusChangerStatus.skip,
            child: RecordStatusSkipReasonTile(
                inputController: vm.skipInputController),
          );
        },
      );
    }

    Widget buildConfirmButton(BuildContext context) {
      return Selector<HabitStatusChangerViewModel, bool>(
        selector: (context, vm) => vm.canSave,
        builder: (context, canSave, child) => ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: ConfirmButton(
            enbaleConfirm: canSave,
            onConfirmPressed: _onConfirmButtonpressed,
            onResetPressed: _onResetButtonPressed,
          ),
        ),
      );
    }

    Widget buildHabitTitle(BuildContext context) {
      return Selector<HabitStatusChangerViewModel, int>(
        selector: (context, vm) => vm.dataDelegate.habitCount,
        builder: (context, habitCount, child) {
          return ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: L10nBuilder(
              builder: (context, l10n) => GroupTitleListTile(
                title: l10n != null
                    ? Text(l10n.batchCheckin_habits_groupTitle(habitCount))
                    : const Text("Selected Habits"),
              ),
            ),
          );
        },
      );
    }

    Widget buildDivider(BuildContext context) => Builder(
          builder: (context) => ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: const Divider(height: 1),
          ),
        );

    final vm = context.read<HabitStatusChangerViewModel>();
    final div = buildDivider(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onClosePageButtonPressed(
            defaultConfirmResult: true, result: result);
      },
      child: PageFramework(
        appbar: _AppBar(
          title: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.batchCheckin_appbar_title)
                : const Text("Multi Check-in"),
          ),
          bottomWidget: buildDatePickerTile(context),
          onCloseButtonPressed: _onClosePageButtonPressed,
        ),
        content: SafedMultiSliver(
          pushPinnedChildren: false,
          children: [
            SliverPinnedHeader(child: buildStatusChangeTile(context)),
            buildSkipStatusReasonField(context),
            SliverPinnedHeader(child: buildConfirmButton(context)),
          ],
        ),
        habitTitle: SliverPinnedHeader(child: buildHabitTitle(context)),
        habitsContent: const _HabitList(key: ValueKey(1)),
        debugContent: context.read<AppDeveloperViewModel>().isInDevelopMode
            ? SafedSliverList(children: [div, _buildDebugInfo(context)])
            : null,
        mainController: vm.mainScrollController,
      ),
    );
  }
}

class _HabitList extends StatefulWidget {
  const _HabitList({super.key});

  @override
  State<_HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<_HabitList> {
  late final Key identity;
  late HabitStatusChangerViewModel? viewmodel;

  @override
  void initState() {
    final viewmodel =
        this.viewmodel = context.read<HabitStatusChangerViewModel>();
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
      currentList: viewmodel.dataDelegate.habitsSortableCache.toList(),
      comparator: AnimatedListDiffListComparator<HabitSortCache>(
        sameItem: (a, b) => a.isSameItem(b),
        sameContent: (a, b) => a.isSameContent(b),
      ),
    );
    identity = UniqueKey();
    viewmodel.regDispatcher(identity, dispatcher);
    super.initState();
  }

  @override
  void dispose() {
    viewmodel?.unRegDispatcher(identity);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    viewmodel = context.maybeRead<HabitStatusChangerViewModel>();
    super.didChangeDependencies();
  }

  Widget _buildHabitsContentCell(BuildContext context, HabitUUID uuid) =>
      Selector<HabitStatusChangerViewModel,
          Tuple2<HabitSummaryData?, HabitDate>>(
        selector: (context, vm) =>
            Tuple2(vm.dataDelegate.getHabitByUUID(uuid), vm.selectDate),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          final data = value.item1;
          if (data == null) return const SizedBox();
          final selectDate = value.item2;
          return HabitSpecialDateViewedTile(data: data, date: selectDate);
        },
      );

  @override
  Widget build(BuildContext context) {
    Widget buildHabitsTileList(BuildContext context) {
      final viewmodel = this.viewmodel!;
      final dispatcher = viewmodel.getDispatcher(identity)!;
      return AnimatedSliverList(
        controller: dispatcher.controller,
        delegate: AnimatedSliverChildBuilderDelegate(
          (context, index, data) {
            final dispatcher = context
                .read<HabitStatusChangerViewModel>()
                .getDispatcher(identity)!;
            return dispatcher.builder(
                context, dispatcher.currentList, index, data);
          },
          dispatcher.currentList.length,
          addLongPressReorderable: false,
        ),
      );
    }

    return Selector<HabitStatusChangerViewModel, HabitsDataDelagate>(
      selector: (context, vm) => vm.dataDelegate,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, _, child) => FutureBuilder(
        future: context
            .read<HabitStatusChangerViewModel>()
            .loadData(inFutureBuilder: true),
        builder: (context, snapshot) {
          final viewmodel = context.read<HabitStatusChangerViewModel>();
          // appLog.load.debug("$this.buildHabits", ex: [
          //   "Loading data",
          //   snapshot.connectionState,
          //   viewmodel.dataDelegate.habitCount,
          // ]);
          // if (kDebugMode && snapshot.isDone) {
          //   appLog.load.debug("$this.buildHabits", ex: ["Loaded", viewmodel]);
          // }
          return SliverStack(
            children: [
              SliverAnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: snapshot.connectionState == ConnectionState.waiting &&
                        viewmodel.dataDelegate.habitCount == 0
                    ? 1.0
                    : 0.0,
                sliver: SliverFillRemaining(
                  key: ValueKey<ConnectionState>(snapshot.connectionState),
                  hasScrollBody: false,
                  child: const PageLoadingIndicator(),
                ),
              ),
              buildHabitsTileList(context),
            ],
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final Widget? title;
  final Widget? bottomWidget;
  final VoidCallback? onCloseButtonPressed;

  const _AppBar({this.title, this.bottomWidget, this.onCloseButtonPressed});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: PageBackButton(
        reason: PageBackReason.close,
        onPressed: onCloseButtonPressed,
      ),
      title: title,
      bottom: bottomWidget != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: bottomWidget!)
          : null,
      automaticallyImplyLeading: false,
      pinned: true,
      floating: true,
    );
  }
}
