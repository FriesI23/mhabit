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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

import '../common/types.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../extension/async_extensions.dart';
import '../extension/context_extensions.dart';
import '../logging/helper.dart';
import '../model/habit_date.dart';
import '../model/habit_summary.dart';
import '../provider/app_compact_ui_switcher.dart';
import '../provider/app_developer.dart';
import '../provider/habit_status_changer.dart';
import '../provider/habit_summary.dart';
import '../utils/safe_sliver_tools.dart';
import 'for_habits_status_changer/_widget.dart';

/// Depend Providers
/// - Required for builder:
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
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    final changedCount = await vm.saveSelectStatus();
    if (!mounted || changedCount <= 0) return;
    context
        .maybeRead<HabitSummaryViewModel>()
        ?.forHabitsStatusChanger
        .onHabitDataChanged();
    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: Text("Changed: $changedCount"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onResetButtonPressed() {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.resetStatusForm();
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
        Selector<HabitStatusChangerViewModel, HabitsDataDelagate>(
          selector: (context, vm) => vm.dataDelegate,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, _, child) {
            final vm = context.read<HabitStatusChangerViewModel>();
            return DatePickerTile(
              initDate: vm.selectDate,
              firstDate: vm.earlistStartDate,
              onSelectDateChanged: _onSelectedDateChanged,
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
              color: Theme.of(context).colorScheme.background,
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
          color: Theme.of(context).colorScheme.background,
          child: ConfirmButton(
            enbaleConfirm: canSave,
            onConfirmPressed: _onConfirmButtonpressed,
            onResetPressed: _onResetButtonPressed,
          ),
        ),
      );
    }

    Widget buildDivider(BuildContext context) => Builder(
          builder: (context) => ColoredBox(
            color: Theme.of(context).colorScheme.background,
            child: const Divider(height: 1),
          ),
        );

    final vm = context.read<HabitStatusChangerViewModel>();
    final div = buildDivider(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        controller: vm.mainScrollController,
        slivers: [
          _AppBar(title: buildDatePickerTile(context)),
          SafedMultiSliver(
            pushPinnedChildren: false,
            children: [
              SliverPinnedHeader(child: buildStatusChangeTile(context)),
              buildSkipStatusReasonField(context),
              SliverPinnedHeader(child: buildConfirmButton(context)),
            ],
          ),
          SliverPinnedHeader(child: div),
          _HabitList(),
          if (context.read<AppDeveloperViewModel>().isInDevelopMode)
            SafedSliverList(children: [div, _buildDebugInfo(context)]),
        ],
      ),
    );
  }
}

class _HabitList extends StatefulWidget {
  @override
  State<_HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<_HabitList> {
  @override
  void initState() {
    final viewmodel = context.read<HabitStatusChangerViewModel>();
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
    viewmodel.initDispatcher(dispatcher);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      final viewmodel = context.read<HabitStatusChangerViewModel>();
      return AnimatedSliverList(
        controller: viewmodel.dispatcherLinkedController,
        delegate: AnimatedSliverChildBuilderDelegate(
          (context, index, data) {
            return context
                .read<HabitStatusChangerViewModel>()
                .dispatcherLinkedBuilder(
                    context, viewmodel.lastSortedDataCache, index, data);
          },
          viewmodel.lastSortedDataCache.length,
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
          appLog.load.debug("$this.buildHabits", ex: [
            "Loading data",
            snapshot.connectionState,
            viewmodel.dataDelegate.habitCount,
          ]);
          if (kDebugMode && snapshot.isDone) {
            appLog.load.debug("$this.buildHabits", ex: ["Loaded", viewmodel]);
          }
          return buildHabitsTileList(context);
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final Widget? title;

  const _AppBar({this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      leading: const PageBackButton(reason: PageBackReason.close),
      title: title,
      automaticallyImplyLeading: false,
      pinned: true,
    );
  }
}
