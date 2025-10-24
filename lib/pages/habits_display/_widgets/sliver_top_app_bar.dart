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

import 'package:flutter/material.dart' hide PreferredSize;
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';
import '../widgets.dart';

export 'sliver_search_top_app_bar.dart';

class SliverViewTopAppBar extends StatelessWidget {
  final double? height;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const SliverViewTopAppBar({
    super.key,
    this.height,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _ViewAppBar(
      scrolledUnderElevation: kCommonEvalation,
      height: height,
      title: L10nBuilder(
        builder: (context, l10n) =>
            l10n != null ? Text(l10n.appName) : const Text(appName),
      ),
      bottom: PreferredSize.zero,
      shawdowColor: Colors.transparent,
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
    );
  }
}

class SliverEditTopAppBar extends StatelessWidget {
  final double? height;
  final VoidCallback? onLeadingButtonPressed;
  final Widget? action;

  const SliverEditTopAppBar({
    super.key,
    this.height,
    this.onLeadingButtonPressed,
    this.action,
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
  final Color? shawdowColor;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const _ViewAppBar({
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.height,
    this.shawdowColor,
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
      shadowColor: shawdowColor,
      bottom: bottom,
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
    );
  }
}

class _EditAppBar extends StatelessWidget {
  final double? scrolledUnderElevation;
  final double? height;
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingButtonPressed;

  const _EditAppBar({
    this.scrolledUnderElevation,
    this.height,
    this.title,
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
    );
  }
}
