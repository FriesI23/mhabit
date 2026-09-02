// Copyright 2026 Fries_I23
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

import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../common/enums.dart';
import '../../../extensions/adaptive_style_extensions.dart';
import '../../../logging/helper.dart';
import '../../../models/habit_summary.dart';
import '../../../providers/app_ui/app_experimental_feature.dart';
import '../../../providers/app_ui/habits_record_scroll_behavior.dart';
import '../../../widgets/widgets.dart';
import '../../common/widgets.dart';
import '../_providers/habit_summary.dart';
import '../styles.dart';
import 'sliver_calendar_bar.dart';
import 'sliver_select_top_app_bar.dart';
import 'sliver_top_app_bar.dart';

typedef HabitDisplayContextCallback = void Function(BuildContext context);

class HabitDisplayViewAppBarCallbacks {
  const HabitDisplayViewAppBarCallbacks({
    this.onInfo,
    this.onSettings,
    this.onOpenSettings,
    this.onSelect,
  });

  final VoidCallback? onInfo;
  final VoidCallback? onSettings;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSelect;
}

class HabitDisplaySelectAppBarCallbacks {
  const HabitDisplaySelectAppBarCallbacks({
    this.onDone,
    this.onSelectAll,
    this.onEdit,
    this.onUnarchive,
    this.onArchive,
    this.onClone,
    this.onExport,
    this.onDelete,
    this.onGroupModify,
    this.onStatusModify,
  });

  final VoidCallback? onDone;
  final VoidCallback? onSelectAll;
  final VoidCallback? onEdit;
  final VoidCallback? onUnarchive;
  final VoidCallback? onArchive;
  final VoidCallback? onClone;
  final HabitDisplayContextCallback? onExport;
  final VoidCallback? onDelete;
  final VoidCallback? onGroupModify;
  final VoidCallback? onStatusModify;
}

enum _HabitDisplayAppBarMode { view, search, select }

class HabitDisplayAppBar extends StatelessWidget {
  const HabitDisplayAppBar({
    super.key,
    required this.geometry,
    required this.isCalendarExpanded,
    required this.calendarHeight,
    required this.calendarItemPadding,
    required this.calendarTrackPadding,
    required this.viewCallbacks,
    required this.selectCallbacks,
    this.toolbarHeight = AppAdaptiveStyle.materialToolbarHeight,
    this.horizonalScrollControllerGroup,
    this.searchFilterMenuController,
    this.onCalendarToggleExpandPressed,
  });

  final HabitListTileGeometry geometry;
  final bool isCalendarExpanded;
  final double toolbarHeight;
  final double calendarHeight;
  final EdgeInsetsGeometry calendarItemPadding;
  final EdgeInsets calendarTrackPadding;
  final HabitDisplayViewAppBarCallbacks viewCallbacks;
  final HabitDisplaySelectAppBarCallbacks selectCallbacks;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final MenuController? searchFilterMenuController;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;

  @override
  Widget build(BuildContext context) {
    final state = context
        .select<HabitSummaryViewModel, HabitSummaryStatusCache>(
          (vm) => vm.currentState,
        );
    final enableSearch = context.select<AppExperimentalFeatureViewModel, bool>(
      (vm) => vm.habitSearch,
    );
    final mode = state.isInEditMode
        ? _HabitDisplayAppBarMode.select
        : enableSearch
        ? _HabitDisplayAppBarMode.search
        : _HabitDisplayAppBarMode.view;
    final calendarContent = _CalendarBarContent(
      geometry: geometry,
      isCalendarExpanded: isCalendarExpanded,
      height: calendarHeight,
      itemPadding: calendarItemPadding,
      trackPadding: calendarTrackPadding,
      horizonalScrollControllerGroup: horizonalScrollControllerGroup,
      onCalendarToggleExpandPressed: onCalendarToggleExpandPressed,
    );
    appLog.build.debug(context, ex: [state], name: 'HabitDisplay.Appbar');
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialHabitDisplayAppBar(
        mode: mode,
        toolbarHeight: toolbarHeight,
        calendarHeight: calendarHeight,
        calendarContent: calendarContent,
        searchFilterMenuController: searchFilterMenuController,
        viewCallbacks: viewCallbacks,
        selectCallbacks: selectCallbacks,
      ),
      AdaptiveStyle.apple => _AppleHabitDisplayAppBar(
        mode: mode,
        calendarHeight: calendarHeight,
        calendarContent: calendarContent,
        searchFilterMenuController: searchFilterMenuController,
        viewCallbacks: viewCallbacks,
        selectCallbacks: selectCallbacks,
      ),
    };
  }
}

class _MaterialHabitDisplayAppBar extends StatelessWidget {
  const _MaterialHabitDisplayAppBar({
    required this.mode,
    required this.toolbarHeight,
    required this.calendarHeight,
    required this.calendarContent,
    required this.searchFilterMenuController,
    required this.viewCallbacks,
    required this.selectCallbacks,
  });

  final _HabitDisplayAppBarMode mode;
  final double toolbarHeight;
  final double calendarHeight;
  final Widget calendarContent;
  final MenuController? searchFilterMenuController;
  final HabitDisplayViewAppBarCallbacks viewCallbacks;
  final HabitDisplaySelectAppBarCallbacks selectCallbacks;

  @override
  Widget build(BuildContext context) {
    final appBar = switch (mode) {
      _HabitDisplayAppBarMode.view => SliverViewTopAppBar(
        height: toolbarHeight,
        onInfoButtonPressed: viewCallbacks.onInfo,
        onMenuButtonPressed: viewCallbacks.onSettings,
        onOpenSettingsPressed: viewCallbacks.onOpenSettings,
      ),
      _HabitDisplayAppBarMode.search => SliverSearchTopAppBar.material(
        searchFilterMenuController: searchFilterMenuController,
        onInfoButtonPressed: viewCallbacks.onInfo,
        onMenuButtonPressed: viewCallbacks.onSettings,
        onOpenSettingsPressed: viewCallbacks.onOpenSettings,
        onSelectButtonPressed: viewCallbacks.onSelect,
      ),
      _HabitDisplayAppBarMode.select => MaterialSliverSelectAppBar(
        height: toolbarHeight,
        onDone: selectCallbacks.onDone,
        onSelectAll: selectCallbacks.onSelectAll,
        onEdit: selectCallbacks.onEdit,
        onUnarchive: selectCallbacks.onUnarchive,
        onArchive: selectCallbacks.onArchive,
        onClone: selectCallbacks.onClone,
        onExport: selectCallbacks.onExport,
        onDelete: selectCallbacks.onDelete,
        onGroupModify: selectCallbacks.onGroupModify,
      ),
    };
    return MultiSliver(
      children: [
        SliverAnimatedSwitcher(duration: Duration.zero, child: appBar),
        _MaterialCalendarBar(
          height: calendarHeight,
          isInEditMode: mode == _HabitDisplayAppBarMode.select,
          child: calendarContent,
        ),
        const PinnedHeaderSliver(child: HabitDivider(height: 1)),
      ],
    );
  }
}

class _AppleHabitDisplayAppBar extends StatelessWidget {
  const _AppleHabitDisplayAppBar({
    required this.mode,
    required this.calendarHeight,
    required this.calendarContent,
    required this.searchFilterMenuController,
    required this.viewCallbacks,
    required this.selectCallbacks,
  });

  final _HabitDisplayAppBarMode mode;
  final double calendarHeight;
  final Widget calendarContent;
  final MenuController? searchFilterMenuController;
  final HabitDisplayViewAppBarCallbacks viewCallbacks;
  final HabitDisplaySelectAppBarCallbacks selectCallbacks;

  @override
  Widget build(BuildContext context) {
    final combinesBars = mode != _HabitDisplayAppBarMode.view;
    final appBar = switch (mode) {
      _HabitDisplayAppBarMode.view => AppleSliverViewTopAppBar(
        onSelect: viewCallbacks.onSelect,
        onInfo: viewCallbacks.onInfo,
        onSettings: viewCallbacks.onSettings,
        onOpenSettings: viewCallbacks.onOpenSettings,
      ),
      _HabitDisplayAppBarMode.search => SliverSearchTopAppBar.apple(
        searchFilterMenuController: searchFilterMenuController,
        onInfoButtonPressed: viewCallbacks.onInfo,
        onMenuButtonPressed: viewCallbacks.onSettings,
        onOpenSettingsPressed: viewCallbacks.onOpenSettings,
        onSelectButtonPressed: viewCallbacks.onSelect,
        cupertinoBottom: calendarContent,
        cupertinoBottomExtent: calendarHeight,
      ),
      _HabitDisplayAppBarMode.select => AppleSliverSelectAppBar(
        onDone: selectCallbacks.onDone,
        onSelectAll: selectCallbacks.onSelectAll,
        onEdit: selectCallbacks.onEdit,
        onUnarchive: selectCallbacks.onUnarchive,
        onArchive: selectCallbacks.onArchive,
        onClone: selectCallbacks.onClone,
        onExport: selectCallbacks.onExport,
        onDelete: selectCallbacks.onDelete,
        onGroupModify: selectCallbacks.onGroupModify,
        onStatusModify: selectCallbacks.onStatusModify,
        bottom: calendarContent,
        bottomExtent: calendarHeight,
      ),
    };
    return MultiSliver(
      children: [
        SliverAnimatedSwitcher(duration: Duration.zero, child: appBar),
        if (!combinesBars)
          _AppleCalendarBar(height: calendarHeight, child: calendarContent),
      ],
    );
  }
}

class _MaterialCalendarBar extends StatelessWidget {
  const _MaterialCalendarBar({
    required this.height,
    required this.isInEditMode,
    required this.child,
  });

  final double height;
  final bool isInEditMode;
  final Widget child;

  @override
  Widget build(BuildContext context) => WindowControlSliverAppBar(
    pinned: true,
    shadowColor: Theme.of(context).colorScheme.shadow,
    backgroundColor: isInEditMode
        ? Theme.of(context).colorScheme.surface
        : null,
    scrolledUnderElevation: isInEditMode ? 0.0 : kCommonEvalation,
    titleSpacing: 0.0,
    primary: false,
    toolbarHeight: height,
    title: child,
  );
}

class _AppleCalendarBar extends StatelessWidget {
  const _AppleCalendarBar({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
    key: const ValueKey('cupertino-calendar-bar'),
    pinned: true,
    delegate: _CalendarHeaderDelegate(
      extent: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: const WindowControlCupertinoNavigationBar(
              automaticallyImplyLeading: false,
              transitionBetweenRoutes: false,
              automaticBackgroundVisibility: true,
              backgroundColor: CupertinoColors.transparent,
              border: null,
            ),
          ),
          child,
        ],
      ),
    ),
  );
}

class _CalendarBarContent extends StatelessWidget {
  const _CalendarBarContent({
    required this.geometry,
    required this.isCalendarExpanded,
    required this.height,
    required this.itemPadding,
    required this.trackPadding,
    this.horizonalScrollControllerGroup,
    this.onCalendarToggleExpandPressed,
  });

  final HabitListTileGeometry geometry;
  final bool isCalendarExpanded;
  final double height;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsets trackPadding;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;

  @override
  Widget build(BuildContext context) {
    final state = context
        .select<HabitSummaryViewModel, HabitSummaryStatusCache>(
          (vm) => vm.currentState,
        );
    final earliestStartDate = context.select<HabitSummaryViewModel, DateTime?>(
      (vm) => vm.earliestSummaryDataStartDate?.startDate,
    );
    final scrollBehavior = context
        .select<
          HabitsRecordScrollBehaviorViewModel,
          HabitsRecordScrollBehavior
        >((vm) => vm.scrollBehavior);
    appLog.build.debug(
      context,
      ex: [state, earliestStartDate, geometry],
      name: 'HabitDisplay.calendarBar',
    );

    ScrollPhysics? buildScrollPhysics(double itemSize, double length) =>
        switch (scrollBehavior) {
          HabitsRecordScrollBehavior.page => const PageScrollPhysics(),
          _ => null,
        };

    return EnhancedSafeArea.edgeToEdgeSafe(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SliverCalendarBar(
            horizonalScrollControllerGroup: horizonalScrollControllerGroup,
            startDate: DateChangeProvider.of(context).dateTime,
            endDate: earliestStartDate,
            isExtended: isCalendarExpanded,
            geometry: geometry,
            height: height,
            itemPadding: itemPadding,
            trackPadding: trackPadding,
            onLeftBtnPressed: onCalendarToggleExpandPressed,
            scrollPhysicsBuilder: buildScrollPhysics,
          ),
          const _LoadingIndicator(),
        ],
      ),
    );
  }
}

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CalendarHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(_CalendarHeaderDelegate oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final hasLoaded = context.select<HabitSummaryViewModel, bool>(
      (vm) => vm.hasLoaded,
    );
    return AnimatedOpacity(
      opacity: hasLoaded ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: const AppSyncLoadingIndicator(),
    );
  }
}
