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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../common/utils.dart';
import '../../extensions/context_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/app_event.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_date.dart';
import '../../models/habit_form.dart';
import '../../models/habit_summary.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_event.dart';
import '../../providers/app_sync.dart';
import '../../providers/habit_summary.dart';
import '../../providers/habits_today.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import 'extensions.dart';
import 'widgets.dart';

class TodayTabPage extends StatefulWidget {
  final double bottomNavigationHeight;
  final ValueChanged<bool> onBottomNavVisibilityChanged;

  const TodayTabPage({
    super.key,
    this.bottomNavigationHeight = 0.0,
    required this.onBottomNavVisibilityChanged,
  });

  @override
  State<TodayTabPage> createState() => TodayTabPageState();
}

class TodayTabPageState extends State<TodayTabPage>
    with AutomaticKeepAliveClientMixin {
  late HabitsTodayViewModel _vm;
  AppSyncViewModel? _appSync;
  StreamSubscription<String>? _startSyncSub;

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

    final sync = context.read<AppSyncViewModel>();
    if (sync != _appSync) {
      _startSyncSub?.cancel();
      _appSync = sync;
      _startSyncSub = sync.appSyncTask.startSyncEvents.listen((_) {
        _refreshIndicatorKey.currentState?.show();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TodayTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottomNavigationHeight != widget.bottomNavigationHeight) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _startSyncSub?.cancel();
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
    //#region bottom placeholder
    Widget buildBottomPlaceHolder(BuildContext context) {
      return SliverToBoxAdapter(
        child: FixedPagePlaceHolder(
          minHeight: widget.bottomNavigationHeight,
        ),
      );
    }
    //#endregion

    super.build(context);
    const appbarHeight = kToolbarHeight;

    final body = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollVisibilityDispatcher.controller,
      slivers: [
        const _Appbar(toolbarHeight: appbarHeight),
        const _HabitsGroupView(),
        const _DevelopTile(),
        buildBottomPlaceHolder(context)
      ],
    );
    const image = _TodayDoneImage(
        changedAnimateDuration: Duration(milliseconds: 300),
        offsetHeight: -appbarHeight);
    final page = RefreshIndicator(
      key: _refreshIndicatorKey,
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
      child: Stack(children: [image, body]),
    );
    return page;
  }
}

class _Appbar extends StatelessWidget {
  final double toolbarHeight;

  const _Appbar({required this.toolbarHeight});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SliverAppBar(
      centerTitle: true,
      toolbarHeight: toolbarHeight,
      title: Text(l10n?.habitToday_appBar_title ?? "Today"),
      actions: const [AppThemeSwitchButton()],
      actionsPadding: kSearchAppBarActionPadding,
    );
  }
}

class _HabitsGroupView extends StatelessWidget {
  const _HabitsGroupView();

  @visibleForTesting
  Future<void> loadData(BuildContext context) async {
    if (!context.mounted) return;
    final sync = context.read<AppSyncViewModel>();
    try {
      if (sync.mounted) await sync.appSyncTask.processing;
    } catch (e, s) {
      appLog.appsync
          .error("TodayTabPage", ex: ["sync failed"], error: e, stackTrace: s);
    }
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
        builder: (context, _) => SliverPadding(
          padding: kListTileContentPadding,
          sliver: AppUiLayoutBuilder.useScreenSize(
            ignoreHeight: false,
            builder: (context, layoutType, child) => switch (layoutType) {
              UiLayoutType.l => const _HabitGrid(),
              UiLayoutType.s => const _HabitList(),
            },
          ),
        ),
      ),
    );
  }
}

class _HabitsTodayController {
  final BuildContext context;

  late final HabitsTodayViewModel _vm;
  List<HabitSortCache> _lastHabits = const [];

  VoidCallback? _onChanged;

  _HabitsTodayController(this.context);

  List<HabitSortCache> get habits => _vm.currentHabitList;
  HabitsTodayViewModel get vm => _vm;

  void init(VoidCallback onChanged) {
    _onChanged = onChanged;
    _vm = context.read<HabitsTodayViewModel>()..addListener(_handleVmChanged);
    _lastHabits = _vm.currentHabitList;
  }

  void didChangeDependencies(BuildContext context) {
    final vm = context.read<HabitsTodayViewModel>();
    if (_vm != vm) {
      _vm.removeListener(_handleVmChanged);
      _vm = vm..addListener(_handleVmChanged);
    }
  }

  void dispose() {
    _vm.removeListener(_handleVmChanged);
    _onChanged = null;
  }

  void _handleVmChanged() {
    final newList = _vm.currentHabitList;
    if (_lastHabits == newList) return;
    _lastHabits = newList;
    _onChanged?.call();
  }

  void _onRecordChangeConfirmed(HabitUUID uuid, HabitSummaryRecord record,
      {String? reason}) {
    // fire event
    context.read<AppEventViewModel>().pushHabitRecordChangeStatus(uuid, record,
        reason: reason,
        msg: "habit_today._onRecordChangeConfirmed",
        source: AppEventPageSource.habitToday);
    // try sync once
    final sync = context.maybeRead<AppSyncViewModel>();
    if (sync != null && sync.mounted) sync.delayedStartTaskOnce();
  }

  void onMain(HabitUUID uuid) {
    final habit = _vm.getHabit(uuid);
    if (habit == null) return;
    _vm.changeRecordValue(uuid, habit.dailyGoal).then((record) {
      if (record != null) _onRecordChangeConfirmed(uuid, record);
    });
  }

  void onDual(HabitUUID uuid) {
    final habit = _vm.getHabit(uuid);
    if (habit == null) return;
    _vm
        .changeRecordValue(uuid, habit.dailyGoalExtra ?? habit.dailyGoal)
        .then((record) {
      if (record != null) _onRecordChangeConfirmed(uuid, record);
    });
  }

  void onSkip(HabitUUID uuid, [String? reason]) {
    final habit = _vm.getHabit(uuid);
    if (habit == null) return;
    _vm.changeRecordStatus(uuid, reason: reason).then((record) {
      if (record != null) {
        _onRecordChangeConfirmed(uuid, record, reason: reason);
      }
    });
  }

  Future<void> onValueWith(HabitUUID uuid) async {
    final data = _vm.getHabit(uuid);
    if (data == null) return;

    final date = HabitRecordDate.now();
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

    _vm.changeRecordValue(uuid, result).then((record) {
      if (record != null) _onRecordChangeConfirmed(uuid, record);
    });
  }

  Future<void> onSkipWith(HabitUUID uuid) async {
    final data = _vm.getHabit(uuid);
    if (data == null) return;

    final date = HabitRecordDate.now();
    final initReason = await _vm.loadRecordReason(data, date) ?? '';
    if (!context.mounted) return;

    final result = await showHabitRecordReasonModifierDialog(
      context: context,
      initReason: initReason,
      recordDate: date,
      chipTextList: skipReasonChipTextList,
      colorType: data.colorType,
    );

    if (result == null || result == initReason) return;

    _vm.changeRecordStatus(uuid, reason: result).then((record) {
      if (record != null) {
        _onRecordChangeConfirmed(uuid, record, reason: result);
      }
    });
  }
}

class _HabitGrid extends StatefulWidget {
  const _HabitGrid();

  @override
  State<_HabitGrid> createState() => _HabitGridState();
}

class _HabitGridState extends State<_HabitGrid> {
  late final _HabitsTodayController _controller =
      _HabitsTodayController(context);

  @override
  void initState() {
    super.initState();
    _controller.init(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.didChangeDependencies(context);
    _controller.vm.resortData(listen: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = _controller.habits;
    final vm = _controller.vm;

    final today = DateChangeProvider.of(context).dateTime;
    final width = kHabitLargeScreenAdaptWidth.toDouble() * 0.66;
    final height = width * 0.618;
    return SliverReorderableAnimatedList<HabitSortCache>.grid(
      scrollDirection: Axis.vertical,
      items: habits,
      isSameItem: (a, b) => a.isSameItem(b),
      itemBuilder: (context, index) {
        final item = habits[index];
        if (item is HabitSummaryDataSortCache) {
          final uuid = item.uuid;
          return Selector<HabitsTodayViewModel, bool>(
            key: ValueKey(item.uuid),
            selector: (context, vm) {
              final (lastExpandUuid, lastExpandStatus) =
                  vm.getLastHabitExpandStatus(onlySucc: true);
              return uuid == lastExpandUuid && lastExpandStatus == true;
            },
            builder: (context, value, child) {
              return _HabitGridItem(
                uuid: uuid,
                date: today,
                height: height,
                selected: value,
                onExpandChanged: (value) => vm.toggleHabitExpandStatus(uuid),
                onMainPressed: () => _controller.onMain(uuid),
                buttonCallbacked: HabitTodayListCardButtonCallbacks(
                  onDualPressed: () => _controller.onDual(uuid),
                  onSkipPressed: () => _controller.onSkip(uuid),
                  onValueWithPressed: () => _controller.onValueWith(uuid),
                  onSkipWithPressed: () => _controller.onSkipWith(uuid),
                ),
              );
            },
          );
        } else {
          return SizedBox.shrink(key: ValueKey("notfound-$index"));
        }
      },
      sliverGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: width,
          mainAxisExtent: height,
          childAspectRatio: height / width),
    );
  }
}

class _HabitGridItem extends StatelessWidget {
  final HabitUUID uuid;
  final HabitDate date;
  final double? height;
  final bool selected;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onMainPressed;
  final HabitTodayListCardButtonCallbacks? buttonCallbacked;

  const _HabitGridItem(
      {required this.uuid,
      required this.date,
      this.height,
      required this.selected,
      this.onExpandChanged,
      this.onMainPressed,
      this.buttonCallbacked});

  @override
  Widget build(BuildContext context) {
    final data = context.select<HabitsTodayViewModel, HabitSummaryData?>(
        (vm) => vm.getHabit(uuid));
    if (data == null) return const SizedBox.shrink();
    final card = HabitTodayCard.grid(
        data: data,
        date: date,
        selected: selected,
        onExpandChanged: onExpandChanged,
        onMainPressed: onMainPressed,
        buttonCallbacked: buttonCallbacked);
    if (height != null) return SizedBox(height: height, child: card);
    return card;
  }
}

class _HabitList extends StatefulWidget {
  const _HabitList();

  @override
  State<_HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<_HabitList> {
  late final _HabitsTodayController _controller =
      _HabitsTodayController(context);

  @override
  void initState() {
    super.initState();
    _controller.init(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.didChangeDependencies(context);
    _controller.vm.resortData(listen: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = _controller.habits;
    final vm = _controller.vm;

    final today = DateChangeProvider.of(context).dateTime;
    return SliverReorderableAnimatedList<HabitSortCache>(
      scrollDirection: Axis.vertical,
      items: habits,
      isSameItem: (a, b) => a.isSameItem(b),
      itemBuilder: (context, index) {
        final item = habits[index];
        if (item is HabitSummaryDataSortCache) {
          final uuid = item.uuid;
          return Selector<HabitsTodayViewModel, bool>(
            key: ValueKey(uuid),
            selector: (context, vm) => vm.getHabitExpandStatus(uuid) ?? false,
            builder: (context, value, child) {
              return _HabitListItem(
                uuid: uuid,
                date: today,
                selected: value,
                onExpandChanged: (v) => vm.updateHabitExpandStatus(uuid, v),
                onMainPressed: () => _controller.onMain(uuid),
                buttonCallbacked: HabitTodayListCardButtonCallbacks(
                  onDualPressed: () => _controller.onDual(uuid),
                  onSkipPressed: () => _controller.onSkip(uuid),
                  onValueWithPressed: () => _controller.onValueWith(uuid),
                  onSkipWithPressed: () => _controller.onSkipWith(uuid),
                ),
              );
            },
          );
        }
        return SizedBox.shrink(key: ValueKey("notfound-$index"));
      },
    );
  }
}

class _HabitListItem extends StatelessWidget {
  final HabitUUID uuid;
  final HabitDate date;
  final bool selected;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onMainPressed;
  final HabitTodayListCardButtonCallbacks? buttonCallbacked;

  const _HabitListItem(
      {required this.uuid,
      required this.date,
      required this.selected,
      this.onExpandChanged,
      this.onMainPressed,
      this.buttonCallbacked});

  @override
  Widget build(BuildContext context) {
    final data = context.select<HabitsTodayViewModel, HabitSummaryData?>(
        (vm) => vm.getHabit(uuid));
    if (data == null) return const SizedBox.shrink();
    return HabitTodayCard(
      data: data,
      date: date,
      selected: selected,
      onExpandChanged: onExpandChanged,
      onMainPressed: onMainPressed,
      buttonCallbacked: buttonCallbacked,
    );
  }
}

class _TodayDoneImage extends StatefulWidget {
  final double offsetHeight;
  final Duration changedAnimateDuration;

  const _TodayDoneImage({
    this.offsetHeight = 0.0,
    required this.changedAnimateDuration,
  });

  @override
  State<_TodayDoneImage> createState() => _TodayDoneImageState();
}

class _TodayDoneImageState extends State<_TodayDoneImage> {
  Brightness? _lastBrightness;
  Color? _lastPrimary;
  late TodayDoneImageStyle _adaptedStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeData = Theme.of(context);
    final brightness = themeData.brightness;
    final primary = themeData.colorScheme.primary;

    if (_lastBrightness != brightness || _lastPrimary != primary) {
      _lastBrightness = brightness;
      _lastPrimary = primary;
      _adaptedStyle = _adaptStyle(TodayDoneImageStyle.inDefault, themeData);
    }
  }

  TodayDoneImageStyle _adaptStyle(TodayDoneImageStyle style, ThemeData theme) {
    Color blend(Color original) =>
        Color.lerp(original, theme.colorScheme.primary, 0.2)!;

    return TodayDoneImageStyle(
      laserColor: blend(style.laserColor),
      sunColor: blend(style.sunColor),
      horizonColor: blend(style.horizonColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDataLoaded =
        context.select<HabitsTodayViewModel, bool>((vm) => vm.isDataLoaded);
    final habitCount = context
        .select<HabitsTodayViewModel, int>((vm) => vm.currentHabitList.length);

    bool shouldShowImage() => isDataLoaded && habitCount <= 0;

    final image = TodayDoneImage(
      size: const Size.square(300),
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
      descChild: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.habitToday_image_desc ?? "YOU MADE IT")),
      style: _adaptedStyle,
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: constraints.copyWith(
                maxHeight:
                    math.max(constraints.maxHeight + widget.offsetHeight, 0)),
            child: AnimatedOpacity(
              opacity: shouldShowImage() ? 1.0 : 0.0,
              duration: widget.changedAnimateDuration,
              child: image,
            ),
          ),
        ),
      ),
    );
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
