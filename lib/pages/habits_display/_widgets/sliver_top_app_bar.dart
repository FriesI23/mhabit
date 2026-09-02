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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/app_ui/app_experimental_feature.dart';
import '../../../widgets/widgets.dart';
import '../_providers/habit_summary.dart';
import '../widgets.dart';

export 'sliver_search_top_app_bar.dart';

class SliverViewTopAppBar extends StatelessWidget {
  final double? height;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;
  final VoidCallback? onOpenSettingsPressed;

  const SliverViewTopAppBar({
    super.key,
    this.height = AppAdaptiveStyle.materialToolbarHeight,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.onOpenSettingsPressed,
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
      onOpenSettingsPressed: onOpenSettingsPressed,
    );
  }
}

class SliverEditTopAppBar extends StatelessWidget {
  final double? height;
  final VoidCallback? onLeadingButtonPressed;
  final Widget? action;

  const SliverEditTopAppBar({
    super.key,
    this.height = AppAdaptiveStyle.materialToolbarHeight,
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
  final void Function(BuildContext context)? onExportAll;
  final VoidCallback? onDelete;
  final VoidCallback? onGroupModify;

  const SliverEditTopAppBarAction({
    super.key,
    this.onEdit,
    this.onUnarchive,
    this.onArchive,
    this.onSelectAll,
    this.onClone,
    this.onExportAll,
    this.onDelete,
    this.onGroupModify,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final stat = context
        .select<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
          (vm) => vm.selectStatistic,
        );
    final habitGrouping = context.select<AppExperimentalFeatureViewModel, bool>(
      (vm) => vm.habitGrouping,
    );
    final onExportAll = this.onExportAll;
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
          callback: onExportAll != null ? () => onExportAll(context) : null,
        ),
        EditModeActionItemConfig.delete(
          text: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
          callback: onDelete,
        ),
        if (habitGrouping)
          EditModeActionItemConfig.groupModify(
            text: l10n?.habitDisplay_editPopMenu_groupModify ?? 'Modify Group',
            callback: onGroupModify,
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
  final VoidCallback? onOpenSettingsPressed;

  const _ViewAppBar({
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.height,
    this.shawdowColor,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.onOpenSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveSliverAppBar(
      height: height,
      styles: AppBarStyles(
        material: AppBarMaterialStyle(
          scrolledUnderElevation: scrolledUnderElevation,
          shadowColor: shawdowColor,
          bottom: bottom,
        ),
      ),
      title: title ?? const SizedBox.shrink(),
      leading: IconButton(
        onPressed: onInfoButtonPressed,
        icon: const Icon(Icons.article_outlined),
      ),
      actions: [
        IconButton(
          onPressed: onMenuButtonPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.habitDisplay_settingButton_tooltip,
        ),
        if (AdaptiveNavScope.maybeOf(context)?.form ==
            NavigationShellForm.compact)
          IconButton(
            key: const ValueKey('open-settings-action'),
            onPressed: onOpenSettingsPressed,
            icon: const Icon(Icons.settings),
            tooltip: l10n?.appSetting_appbar_titleText ?? 'Settings',
          ),
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
    return AdaptiveSliverAppBar.material(
      height: height,
      styles: AppBarStyles(
        material: AppBarMaterialStyle(
          floating: false,
          snap: false,
          pinned: true,
          forceElevated: true,
          centerTitle: false,
          scrolledUnderElevation: scrolledUnderElevation,
          shadowColor: Theme.of(context).colorScheme.shadow,
        ),
      ),
      title: title ?? const SizedBox.shrink(),
      leading: PageBackButton(
        reason: PageBackReason.close,
        onPressed: onLeadingButtonPressed,
      ),
      actions: actions ?? const [],
    );
  }
}
