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

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../common/types.dart';
import '../../common/utils.dart';
import '../../extensions/navigator_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/custom_date_format.dart';
import '../../models/habit_date.dart';
import '../../models/habit_summary.dart';
import '../../providers/app_ui/app_compact_ui_switcher.dart';
import '../../providers/app_ui/app_custom_date_format.dart';
import '../../providers/app_ui/app_developer.dart';
import '../../utils/safe_sliver_tools.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import '_providers/habit_status_changer.dart';
import 'widgets.dart';

/// Depend Providers
/// - Required for builder:
///   - [AppCustomDateYmdHmsConfigViewModel]
///   - [AppCompactUISwitcherViewModel]
///   - [AppDeveloperViewModel]
/// - Required for callback:
/// - Optional:
///   - [AppSyncTriggerAccess]
class HabitsStatusChangerPage extends StatelessWidget {
  final List<HabitUUID> uuidList;

  const HabitsStatusChangerPage({super.key, required this.uuidList});

  @override
  Widget build(BuildContext context) =>
      PageProviders(uuidList: uuidList, child: const _Page());
}

class _Page extends StatefulWidget {
  static const Duration mainScrollAnimatedDuration = Duration(
    milliseconds: 300,
  );
  static const Curve mainScrollAnimatedCurve = Curves.fastOutSlowIn;

  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> {
  late HabitStatusChangerViewModel _vm;

  late final ScrollController _mainScrollController;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
    _vm = context.read<HabitStatusChangerViewModel>();
    _mainScrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitStatusChangerViewModel>();
    if (vm != _vm) {
      _vm = vm;
    }
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    _mainScrollController.dispose();
    super.dispose();
  }

  void _onSelectedDateChanged(HabitDate od, HabitDate nd) {
    if (!(mounted && _vm.mounted)) return;
    _vm.updateSelectDate(nd);
  }

  void _onSelectedStatusChanged(
    RecordStatusChangerStatus? od,
    RecordStatusChangerStatus? nd,
  ) {
    if (!(mounted && _vm.mounted)) return;
    _vm.updateSelectStatus(
      nd,
      onStatusChanged: (status) {
        if (status == RecordStatusChangerStatus.skip) {
          _mainScrollController.animateTo(
            0,
            duration: _Page.mainScrollAnimatedDuration,
            curve: _Page.mainScrollAnimatedCurve,
          );
        }
      },
    );
  }

  void _onConfirmButtonpressed() async {
    if (!(mounted && _vm.mounted)) return;
    if (_vm.selectDateRecords.isNotEmpty) {
      final l10n = L10n.of(context);
      final result =
          (await showAdaptiveConfirmDialog(
            context: context,
            title: Text(
              l10n?.batchCheckin_save_confirmDialog_title ??
                  'Overwrite Existing Records',
            ),
            content: l10n != null
                ? Text(l10n.batchCheckin_save_confirmDialog_body)
                : const SizedBox(),
            confirmLabel:
                l10n?.batchCheckin_save_confirmDialog_confirmButton_text ??
                'save',
            cancelLabel:
                l10n?.batchCheckin_save_confirmDialog_cancelButton_text ??
                'cancel',
            isDestructiveAction: true,
          )) ??
          false;
      if (!(mounted && _vm.mounted && result)) return;
    }

    final changedCount = await _vm.saveSelectStatus();
    if (!mounted || changedCount <= 0) return;

    final snackBar = buildSnackBarWithDismiss(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => Text(
          l10n?.batchCheckin_completed_snackbar_text(changedCount) ??
              "Changed: $changedCount",
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onDeleteButtonPressed() async {
    if (!(mounted && _vm.mounted) || _vm.deletableRecordCount == 0) return;
    final deleteCount = _vm.deletableRecordCount;
    final l10n = L10n.of(context);
    final selectedDate = context
        .read<AppCustomDateYmdHmsConfigViewModel>()
        .config
        .getYMDBatchCheckinFormatter(l10n?.localeName)
        .format(_vm.selectDate);
    final confirmed = await showAdaptiveConfirmDialog(
      context: context,
      title: Text(
        l10n?.habitRecord_deleteConfirmDialog_title(deleteCount) ??
            'Delete $deleteCount check-ins?',
      ),
      content: Text(selectedDate),
      confirmLabel:
          l10n?.habitRecord_delete_buttonText(deleteCount) ??
          'Delete check-ins',
      cancelLabel:
          l10n?.batchCheckin_save_confirmDialog_cancelButton_text ?? 'Cancel',
      isDestructiveAction: true,
    );
    if (!(mounted && _vm.mounted && confirmed == true)) return;
    await _vm.deleteSelectDateRecords();
  }

  void _onResetButtonPressed() {
    if (!(mounted && _vm.mounted)) return;
    _vm.resetStatusForm();
  }

  Future<void> _onClosePageButtonPressed<T>({
    bool defaultConfirmResult = false,
    T? result,
  }) async {
    if (!(mounted && _vm.mounted)) return;
    final pageRoute = ModalRoute.of(context);
    final l10n = L10n.of(context);
    final savedResult = _vm.canSave
        ? (await showAdaptiveConfirmDialog(
                context: context,
                title: Text(
                  l10n?.batchCheckin_close_confirmDialog_title ??
                      'Unsaved Check-in Status',
                ),
                content: l10n != null
                    ? Text(l10n.batchCheckin_close_confirmDialog_body)
                    : const SizedBox(),
                confirmLabel:
                    l10n?.batchCheckin_close_confirmDialog_confirmButton_text ??
                    'exit',
                cancelLabel:
                    l10n?.batchCheckin_close_confirmDialog_cancelButton_text ??
                    'cancel',
              ) ??
              defaultConfirmResult)
        : true;
    if (!mounted) return;

    if (savedResult) {
      dismissAllToolTips().then(
        (_) => mounted && pageRoute?.isCurrent == true
            ? Navigator.of(context).popOrExit(result)
            : false,
      );
    }
  }

  Widget _buildDebugInfo(BuildContext context) =>
      Consumer<HabitStatusChangerViewModel>(
        builder: (context, value, child) => ListTile(
          leading: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          isThreeLine: true,
          title: const Text('DEBUG'),
          subtitle: Column(
            children: [
              Text(_vm.toString()),
              Text(_vm.selectDateAllowedStatus.toString()),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context);

    Widget buildDatePickerTile(
      BuildContext context,
    ) => Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
      selector: (context, vm) => vm.config,
      builder: (context, formatter, child) {
        return Selector<HabitStatusChangerViewModel, (HabitDate, HabitDate)>(
          selector: (context, vm) => (vm.selectDate, vm.earlistStartDate),
          builder: (context, dates, child) {
            return DatePickerTile(
              initDate: dates.$1,
              firstDate: dates.$2,
              formatter: formatter,
              onSelectDateChanged: _onSelectedDateChanged,
            );
          },
        );
      },
    );

    Widget buildStatusChangeTile(BuildContext context) =>
        Selector<
          HabitStatusChangerViewModel,
          (RecordStatusChangerStatus?, Set<RecordStatusChangerStatus>)
        >(
          selector: (context, vm) =>
              (vm.selectStatus, vm.selectDateAllowedStatus),
          shouldRebuild: (previous, next) =>
              previous.$1 != next.$1 || !setEquals(previous.$2, next.$2),
          builder: (context, selection, child) {
            return Material(
              color: Theme.of(context).colorScheme.surface,
              child: RecordStatusChangeTile(
                initStatus: selection.$1,
                allowedStatus: selection.$2,
                onSelectedNewStatus: _onSelectedStatusChanged,
              ),
            );
          },
        );

    Widget buildConfirmButton(BuildContext context) {
      return Selector<HabitStatusChangerViewModel, bool>(
        selector: (context, vm) => vm.canSave,
        builder: (context, canSave, child) => Material(
          color: Theme.of(context).colorScheme.surface,
          child: ConfirmButton(
            enbaleConfirm: canSave,
            onConfirmPressed: _onConfirmButtonpressed,
            onResetPressed: _onResetButtonPressed,
          ),
        ),
      );
    }

    Widget buildDeleteAction(BuildContext context) =>
        Selector<HabitStatusChangerViewModel, int>(
          selector: (context, vm) => vm.deletableRecordCount,
          builder: (context, deleteCount, child) => AdaptiveIconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip:
                L10n.of(context)?.habitRecord_delete_buttonText(deleteCount) ??
                'Delete check-ins',
            onPressed: deleteCount > 0 ? _onDeleteButtonPressed : null,
          ),
        );

    Widget buildHabitTitle(BuildContext context) {
      return Selector<HabitStatusChangerViewModel, int>(
        selector: (context, vm) => vm.currentHabitCount,
        builder: (context, habitCount, child) {
          return Material(
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

    final div = buildDivider(context);
    return PopScopeConsumer<HabitStatusChangerViewModel>(
      onCannotPop: (ctx, vm, result) =>
          _onClosePageButtonPressed(defaultConfirmResult: true, result: result),
      child: PageScaffold(
        appbar: HabitStatusChangerAppbar(
          title: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.batchCheckin_appbar_title)
                : const Text("Multi Check-in"),
          ),
          bottomWidget: buildDatePickerTile(context),
          trailing: buildDeleteAction(context),
          onCloseButtonPressed: _onClosePageButtonPressed,
        ),
        content: SafedMultiSliver(
          pushPinnedChildren: false,
          children: [
            SliverPinnedHeader(child: buildStatusChangeTile(context)),
            const _SkipStatusReasonField(),
            SliverPinnedHeader(child: buildConfirmButton(context)),
          ],
        ),
        habitTitle: SliverPinnedHeader(child: buildHabitTitle(context)),
        habitsContent: const _HabitList(key: ValueKey(1)),
        debugContent: Selector<AppDeveloperViewModel, bool>(
          selector: (context, vm) => vm.isInDevelopMode,
          builder: (context, isInDevelopMode, child) => isInDevelopMode
              ? SafedSliverList(children: [div, _buildDebugInfo(context)])
              : const SliverToBoxAdapter(),
        ),
        mainController: _mainScrollController,
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
  late HabitStatusChangerViewModel _vm;

  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitStatusChangerViewModel>()
      ..addListener(_onViewModelNotified);
    _dispatcher = buildDispatcher();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitStatusChangerViewModel>();
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
            return _HabitListItem(uuid: element.uuid);
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
  Future loadData() async {
    if (!(mounted && _vm.mounted)) return;
    if (!_vm.hasLoad) await _vm.loadData();
  }

  void _onRetryPressed() {
    if (!(mounted && _vm.mounted)) return;
    _vm.requestReloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HabitStatusChangerViewModel, bool>(
      selector: (context, vm) => vm.hasLoad,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, _, child) => FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: LoadErrorPlaceholder(onRetry: _onRetryPressed),
            );
          }

          return SliverStack(
            children: [
              SliverAnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity:
                    snapshot.connectionState == ConnectionState.waiting &&
                        _vm.currentHabitCount == 0
                    ? 1.0
                    : 0.0,
                sliver: SliverFillRemaining(
                  key: ValueKey<ConnectionState>(snapshot.connectionState),
                  hasScrollBody: false,
                  child: const PageLoadingIndicator(),
                ),
              ),
              AnimatedSliverList(
                controller: _dispatcher.controller,
                delegate: AnimatedSliverChildBuilderDelegate(
                  (context, index, data) => _dispatcher.builder(
                    context,
                    _dispatcher.currentList,
                    index,
                    data,
                  ),
                  _dispatcher.currentList.length,
                  addLongPressReorderable: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HabitListItemMeasurer extends StatelessWidget {
  const _HabitListItemMeasurer();

  @override
  Widget build(BuildContext context) {
    final height = context.select<AppCompactUISwitcherViewModel, double>(
      (vm) => vm.appHabitDisplayListTileHeight,
    );
    return SizedBox(height: height);
  }
}

class _HabitListItem extends StatelessWidget {
  final HabitUUID uuid;

  const _HabitListItem({required this.uuid});

  @override
  Widget build(BuildContext context) {
    final (data, selectDate) = context
        .select<HabitStatusChangerViewModel, (HabitSummaryData?, HabitDate)>(
          (vm) => (vm.fetchHabit(uuid), vm.selectDate),
        );
    if (data == null) return const SizedBox.shrink();
    return HabitSpecialDateViewedTile(data: data, date: selectDate);
  }
}

class _SkipStatusReasonField extends StatelessWidget {
  const _SkipStatusReasonField();

  @override
  Widget build(BuildContext context) {
    final selectStatus = context
        .select<HabitStatusChangerViewModel, RecordStatusChangerStatus?>(
          (vm) => vm.selectStatus,
        );
    return ExpandedSection(
      duration: _Page.mainScrollAnimatedDuration,
      curve: _Page.mainScrollAnimatedCurve,
      expand: selectStatus == RecordStatusChangerStatus.skip,
      child: SingleTextFormInputField<HabitStatusChangerViewModel>(
        valueBuilder: (vm) => vm.skipReason,
        builder: (context, controller, child) => RecordStatusSkipReasonTile(
          inputController: controller,
          onChanged: (value) {
            final vm = context.read<HabitStatusChangerViewModel>();
            if (!vm.mounted) return;
            vm.skipReason = value;
          },
        ),
      ),
    );
  }
}
