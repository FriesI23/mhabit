// Copyright 2025 Fries_I23
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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/enums.dart';
import '../../../common/types.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/app_compact_ui_switcher.dart';
import '../../../providers/app_theme.dart';
import '../../../providers/habit_summary.dart';
import '../../../providers/habits_record_scroll_behavior.dart';
import '../../../widgets/widgets.dart';
import '../widgets.dart';

export 'sliver_search_top_app_bar.dart';

class SliverTopAppBarContainer {
  final HabitsRecordScrollBehavior scrollBehavior;
  final int displayPageOccupyPrt;
  final DateTime? earliestStartDate;

  const SliverTopAppBarContainer({
    required this.scrollBehavior,
    required this.displayPageOccupyPrt,
    this.earliestStartDate,
  });
}

class SliverTopAppBarWrapper extends StatelessWidget {
  final ValueWidgetBuilder<SliverTopAppBarContainer> builder;
  final Widget? child;

  const SliverTopAppBarWrapper({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    final scrollBehavior = context.select<HabitsRecordScrollBehaviorViewModel,
        HabitsRecordScrollBehavior>((vm) => vm.scrollBehavior);
    final displayPageOccupyPrt =
        context.select<AppThemeViewModel, int>((vm) => vm.displayPageOccupyPrt);
    final earliestStartDate = context.select<HabitSummaryViewModel, DateTime?>(
        (vm) => vm.earliestSummaryDataStartDate?.startDate);
    return builder(
        context,
        SliverTopAppBarContainer(
          displayPageOccupyPrt: displayPageOccupyPrt,
          scrollBehavior: scrollBehavior,
          earliestStartDate: earliestStartDate,
        ),
        child);
  }
}

class SliverViewTopAppBar extends StatelessWidget {
  final bool isClandarExpanded;
  final DateTime? endDate;
  final double? height;
  final int? collapsePrt;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const SliverViewTopAppBar({
    super.key,
    this.endDate,
    this.isClandarExpanded = false,
    this.height,
    this.collapsePrt,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onCalendarToggleExpandPressed,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.scrollPhysicsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final (appCalendarBarHeight, appCalendarBarItemPadding) =
        context.select<AppCompactUISwitcherViewModel, (double, EdgeInsets)>(
            (vm) => (vm.appCalendarBarHeight, vm.appCalendarBarItemPadding));
    return _ViewAppBar(
      scrolledUnderElevation: kCommonEvalation,
      height: height,
      title: L10nBuilder(
        builder: (context, l10n) =>
            l10n != null ? Text(l10n.appName) : const Text(appName),
      ),
      bottom: SliverCalendarBar(
        key: const Key('calendar-bar'),
        verticalScrollController: verticalScrollController,
        horizonalScrollControllerGroup: horizonalScrollControllerGroup,
        startDate: DateChangeProvider.of(context).dateTime,
        endDate: endDate,
        isExtended: isClandarExpanded,
        collapsePrt: collapsePrt,
        height: appCalendarBarHeight,
        itemPadding: appCalendarBarItemPadding,
        onLeftBtnPressed: onCalendarToggleExpandPressed,
        scrollPhysicsBuilder: scrollPhysicsBuilder,
      ),
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
    );
  }
}

class SliverEditTopAppBar extends StatelessWidget {
  final bool isClandarExpanded;
  final DateTime? endDate;
  final double? height;
  final int? collapsePrt;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final VoidCallback? onLeadingButtonPressed;
  final Widget? action;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const SliverEditTopAppBar({
    super.key,
    this.endDate,
    this.height,
    this.collapsePrt,
    this.isClandarExpanded = false,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onLeadingButtonPressed,
    this.action,
    this.scrollPhysicsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildAppbarTitle(BuildContext context) {
      return Selector<HabitSummaryViewModel, int>(
        selector: (context, vm) => vm.selectedHabitsCount,
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

    final action = this.action;
    return _EditAppBar(
      scrolledUnderElevation: kCommonEvalation,
      height: height,
      title: buildAppbarTitle(context),
      bottom: SliverCalendarBar(
        key: const Key('calendar-bar'),
        verticalScrollController: verticalScrollController,
        horizonalScrollControllerGroup: horizonalScrollControllerGroup,
        startDate: DateChangeProvider.of(context).dateTime,
        endDate: endDate,
        isExtended: isClandarExpanded,
        collapsePrt: collapsePrt,
      ),
      actions: action != null ? [action] : null,
      onLeadingButtonPressed: onLeadingButtonPressed,
    );
  }
}

class SliverEditTopAppBarAction extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onUnarchive;
  final VoidCallback? onArchive;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClone;
  final VoidCallback? onExportAll;
  final VoidCallback? onDelete;

  const SliverEditTopAppBarAction({
    super.key,
    this.onEdit,
    this.onUnarchive,
    this.onArchive,
    this.onSelectAll,
    this.onClone,
    this.onExportAll,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final stat =
        context.select<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
            (vm) => vm.selectStatistic);
    return AppBarActions<EditModeActionItemConfig, EditModeActionItemCell>(
      buttonSwitchAnimateDuration: kEditModeAppbarAnimateDuration,
      actionConfigs: [
        EditModeActionItemConfig.edit(
          visible: stat.selected == 1,
          text: l10n?.habitDisplay_editButton_tooltip ?? "Edit",
          callback: onEdit,
        ),
        EditModeActionItemConfig.unarchive(
          visible: stat.archived > 0,
          text: l10n?.habitDisplay_unarchiveButton_tooltip ?? "Unarchive",
          callback: onUnarchive,
        ),
        EditModeActionItemConfig.archive(
          visible: stat.activated > 0,
          text: l10n?.habitDisplay_archiveButton_tooltip ?? "Archive",
          callback: onArchive,
        ),
        EditModeActionItemConfig.selectall(
          text: l10n?.habitDisplay_editPopMenu_selectAll ?? "Select All",
          callback: onSelectAll,
        ),
        EditModeActionItemConfig.clone(
          visible: stat.selected == 1,
          text: l10n?.habitDisplay_editPopMenu_clone ?? "Clone",
          callback: onClone,
        ),
        EditModeActionItemConfig.exportall(
          text: l10n?.habitDisplay_editPopMenu_export ?? "Export",
          callback: onExportAll,
        ),
        EditModeActionItemConfig.delete(
          text: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
          callback: onDelete,
        ),
      ],
    );
  }
}

class _ViewAppBar extends StatelessWidget {
  final double? scrolledUnderElevation;
  final Widget? title;
  final PreferredSizeWidget? bottom;
  final double? height;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const _ViewAppBar({
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.height,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: true,
      toolbarHeight: height ?? kToolbarHeight,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: Theme.of(context).colorScheme.shadow,
      title: title,
      leading: IconButton(
        onPressed: onInfoButtonPressed,
        icon: const Icon(Icons.article_outlined),
      ),
      actions: [
        IconButton(
          onPressed: onMenuButtonPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.habitDisplay_settingButton_tooltip,
        )
      ],
      bottom: bottom,
    );
  }
}

class _EditAppBar extends StatelessWidget {
  final double? scrolledUnderElevation;
  final double? height;
  final Widget? title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final VoidCallback? onLeadingButtonPressed;

  const _EditAppBar({
    this.scrolledUnderElevation,
    this.height,
    this.title,
    this.bottom,
    this.actions,
    this.onLeadingButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      forceElevated: true,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: Theme.of(context).colorScheme.shadow,
      toolbarHeight: height ?? kToolbarHeight,
      title: title,
      centerTitle: false,
      leading: PageBackButton(
        reason: PageBackReason.close,
        onPressed: onLeadingButtonPressed,
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
