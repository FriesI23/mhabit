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
import 'package:great_list_view/great_list_view.dart';
import 'package:provider/provider.dart';

import '../../common/types.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/habit_date.dart';
import '../../models/habit_summary.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_sync.dart';
import '../../providers/habits_today.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import 'widgets.dart';

class TodayTabPage extends StatefulWidget {
  final ValueChanged<bool> onBottomNavVisibilityChanged;

  const TodayTabPage({
    super.key,
    required this.onBottomNavVisibilityChanged,
  });

  @override
  State<TodayTabPage> createState() => TodayTabPageState();
}

class TodayTabPageState extends State<TodayTabPage>
    with AutomaticKeepAliveClientMixin {
  late HabitsTodayViewModel _vm;

  late final double _toolbarHeight;

  late final VerticalScrollVisibilityDispatcher _scrollVisibilityDispatcher;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitsTodayViewModel>();
    _toolbarHeight = kToolbarHeight;
    _scrollVisibilityDispatcher = VerticalScrollVisibilityDispatcher(
      toolbarHeight: _toolbarHeight,
      onVisibilityChanged: widget.onBottomNavVisibilityChanged,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitsTodayViewModel>();
    if (vm != _vm) {
      _vm = vm;
    }
  }

  @override
  void dispose() {
    _scrollVisibilityDispatcher.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefreshIndicatorTriggered() async {
    if (!mounted) return;
    DateChangeProvider.of(context).dateTime = HabitDate.now();
    final syncvm = context.read<AppSyncViewModel>();
    if (syncvm.mounted) {
      try {
        await syncvm.startSync(initWait: kAppSyncDelayDuration2);
        await syncvm.appSyncTask.processing;
      } catch (e, s) {
        appLog.appsync.fatal("start sync failed",
            ex: [syncvm.appSyncTask.task], error: e, stackTrace: s);
        if (kDebugMode) Error.throwWithStackTrace(e, s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = CustomScrollView(
      controller: _scrollVisibilityDispatcher.controller,
      slivers: [
        _Appbar(),
        _HabitsGroupView(),
        _DevelopTile(),
      ],
    );
    final page = RefreshIndicator(
      notificationPredicate: (notification) {
        final context = notification.context;
        if (context == null) {
          return defaultScrollNotificationPredicate(notification);
        }
        final sync = context.read<AppSyncViewModel>();
        if (!(sync.enabled && sync.serverConfig != null)) {
          return false;
        }
        return defaultScrollNotificationPredicate(notification);
      },
      onRefresh: _onRefreshIndicatorTriggered,
      edgeOffset: kToolbarHeight + MediaQuery.paddingOf(context).top,
      child: body,
    );
    return page;
  }
}

class _Appbar extends StatelessWidget {
  const _Appbar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      title: Text("Today"),
    );
  }
}

class _HabitsGroupView extends StatelessWidget {
  const _HabitsGroupView();

  @visibleForTesting
  Future<void> loadData(BuildContext context) async {
    if (!context.mounted) return;
    final sync = context.read<AppSyncViewModel>();
    if (sync.mounted) await sync.appSyncTask.processing;
    if (!context.mounted) return;
    final vm = context.read<HabitsTodayViewModel>();
    if (!vm.mounted || vm.isDataLoading) return;
    await vm.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HabitsTodayViewModel, bool>(
      selector: (context, vm) => vm.isDataLoading,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, _, child) => FutureBuilder(
        future: loadData(context),
        builder: (context, _) => const _HabitList(),
      ),
    );
  }
}

class _HabitList extends StatefulWidget {
  const _HabitList();

  @override
  State<_HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<_HabitList> {
  late HabitsTodayViewModel _vm;

  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitsTodayViewModel>()
      ..addListener(_onViewModelNotified);
    _dispatcher = buildDispatcher();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitsTodayViewModel>();
    if (_vm != vm) {
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
            return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedSliverList(
      controller: _dispatcher.controller,
      delegate: AnimatedSliverChildBuilderDelegate(
        (context, index, data) =>
            _dispatcher.builder(context, _vm.currentHabitList, index, data),
        _vm.currentHabitList.length,
        animator: kHabitContentListAnimator,
        addAnimatedElevation: kCommonEvalation,
        morphDuration: kEditModeChangeAnimateDuration,
      ),
    );
  }
}

class _HabitListItem extends StatelessWidget {
  final HabitUUID uuid;

  const _HabitListItem({required this.uuid});

  @override
  Widget build(BuildContext context) {
    final data = context.select<HabitsTodayViewModel, HabitSummaryData?>(
        (vm) => vm.getHabit(uuid));
    return Padding(
        padding: kListTileContentPadding,
        child: HabitTodayCard(testData: data));
  }
}

class _DevelopTile extends StatelessWidget {
  const _DevelopTile();

  @override
  Widget build(BuildContext context) {
    final displayDebugMenu = context
        .select<AppDeveloperViewModel, bool>((vm) => vm.displayDebugMenu);
    final vm = context.watch<HabitsTodayViewModel>();
    final body = SliverToBoxAdapter(
      child: ExpansionTile(
        title: Text(L10n.of(context)?.habitDisplay_debug_debugSubgroup_title ??
            'Developer'),
        children: [
          ListTile(
            title: const Text("Debug Info"),
            subtitle: Text(vm.toDebugString()),
            leading: const Icon(Icons.warning),
            iconColor: Colors.red,
            isThreeLine: true,
          )
        ],
      ),
    );
    return SliverVisibility(
      visible: displayDebugMenu,
      sliver: EnhancedSafeArea.edgeToEdgeSafe(
        withSliver: true,
        child: body,
      ),
    );
  }
}
