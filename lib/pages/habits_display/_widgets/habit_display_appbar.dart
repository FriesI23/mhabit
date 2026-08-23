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

import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../common/consts.dart';
import '../../../common/enums.dart';
import '../../../logging/helper.dart';
import '../../../models/habit_summary.dart';
import '../../../providers/app_ui/app_experimental_feature.dart';
import '../../../providers/app_ui/habits_record_scroll_behavior.dart';
import '../../../widgets/widgets.dart';
import '../../common/widgets.dart';
import '../_providers/habit_summary.dart';
import '../styles.dart';
import 'sliver_calendar_bar.dart';
import 'sliver_top_app_bar.dart';

class HabitDisplayAppBar extends StatelessWidget {
  const HabitDisplayAppBar({
    super.key,
    required this.geometry,
    required this.isCalendarExpanded,
    required this.calendarHeight,
    required this.calendarItemPadding,
    required this.calendarTrackPadding,
    this.toolbarHeight = kAppToolbarHeight,
    this.horizonalScrollControllerGroup,
    this.searchFilterMenuController,
    this.editAction,
    this.onCalendarToggleExpandPressed,
    this.onEditLeadingButtonPressed,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  final HabitListTileGeometry geometry;
  final bool isCalendarExpanded;
  final double toolbarHeight;
  final double calendarHeight;
  final EdgeInsetsGeometry calendarItemPadding;
  final EdgeInsets calendarTrackPadding;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final MenuController? searchFilterMenuController;
  final Widget? editAction;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;
  final VoidCallback? onEditLeadingButtonPressed;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  @override
  Widget build(BuildContext context) {
    final state = context
        .select<HabitSummaryViewModel, HabitSummaryStatusCache>(
          (vm) => vm.currentState,
        );
    final enableSearch = context.select<AppExperimentalFeatureViewModel, bool>(
      (vm) => vm.habitSearch,
    );
    final combinesBars =
        context.adaptiveStyle == AdaptiveStyle.apple &&
        !state.isInEditMode &&
        enableSearch;
    final calendarContent = _CalendarBarContent(
      geometry: geometry,
      isCalendarExpanded: isCalendarExpanded,
      height: calendarHeight,
      itemPadding: calendarItemPadding,
      trackPadding: calendarTrackPadding,
      horizonalScrollControllerGroup: horizonalScrollControllerGroup,
      onCalendarToggleExpandPressed: onCalendarToggleExpandPressed,
    );

    final appBar = state.isInEditMode
        ? SliverEditTopAppBar(
            height: toolbarHeight,
            onLeadingButtonPressed: onEditLeadingButtonPressed,
            action: editAction,
          )
        : enableSearch
        ? SliverSearchTopAppBar(
            searchFilterMenuController: searchFilterMenuController,
            onInfoButtonPressed: onInfoButtonPressed,
            onMenuButtonPressed: onMenuButtonPressed,
            cupertinoBottom: combinesBars ? calendarContent : null,
            cupertinoBottomExtent: combinesBars ? calendarHeight : 0.0,
          )
        : SliverViewTopAppBar(
            height: toolbarHeight,
            onInfoButtonPressed: onInfoButtonPressed,
            onMenuButtonPressed: onMenuButtonPressed,
          );

    appLog.build.debug(context, ex: [state], name: 'HabitDisplay.Appbar');
    return MultiSliver(
      children: [
        SliverAnimatedSwitcher(
          duration: kEditModeChangeAnimateDuration,
          child: appBar,
        ),
        if (!combinesBars)
          _CalendarBar(
            height: calendarHeight,
            isInEditMode: state.isInEditMode,
            child: calendarContent,
          ),
        if (context.adaptiveStyle == AdaptiveStyle.material)
          const PinnedHeaderSliver(child: HabitDivider(height: 1)),
      ],
    );
  }
}

class _CalendarBar extends StatelessWidget {
  const _CalendarBar({
    required this.height,
    required this.isInEditMode,
    required this.child,
  });

  final double height;
  final bool isInEditMode;
  final Widget child;

  @override
  Widget build(BuildContext context) => switch (context.adaptiveStyle) {
    AdaptiveStyle.material => SliverAppBar(
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
    ),
    AdaptiveStyle.apple => SliverPersistentHeader(
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
              child: const CupertinoNavigationBar(
                automaticallyImplyLeading: false,
                transitionBetweenRoutes: false,
                border: null,
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  };
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
