// Copyright 2026 Fries_I23
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/app_ui/app_experimental_feature.dart';
import '../_providers/habit_summary.dart';
import 'sliver_top_app_bar.dart';

class AppleSliverViewTopAppBar extends StatelessWidget {
  const AppleSliverViewTopAppBar({
    super.key,
    this.onSelect,
    this.onInfo,
    this.onSettings,
  });

  final VoidCallback? onSelect;
  final VoidCallback? onInfo;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final compact = WindowSize.of(context).width == WindowSizeClass.compact;
    final selectLabel = l10n?.habitDisplay_selectButton_label ?? 'Select';
    final settingsLabel =
        l10n?.habitDisplay_settingButton_tooltip ?? 'Settings';
    return CupertinoSliverSelectAppBar.view(
      title: Text(l10n?.appName ?? appName),
      actions: [
        CupertinoSelectAction(
          id: 'habit-select',
          label: selectLabel,
          icon: const Icon(CupertinoIcons.checkmark_alt_circle),
          onPressed: onSelect,
          enabled: onSelect != null,
          overflowOnly: compact,
          retentionPriority: 100,
          primaryBuilder: (context, _) => CupertinoButton(
            key: const ValueKey('habit-select-primary'),
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: onSelect,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(selectLabel, maxLines: 1, softWrap: false),
            ),
          ),
        ),
        CupertinoSelectAction(
          id: 'habit-statistics',
          label: 'Statistics',
          icon: const Icon(Icons.article_outlined),
          onPressed: onInfo,
          enabled: onInfo != null,
          retentionPriority: 25,
        ),
        CupertinoSelectAction(
          id: 'habit-settings',
          label: settingsLabel,
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettings,
          enabled: onSettings != null,
          retentionPriority: 50,
        ),
      ],
    );
  }
}

class MaterialSliverSelectAppBar extends StatelessWidget {
  const MaterialSliverSelectAppBar({
    super.key,
    this.height = AppAdaptiveStyle.materialToolbarHeight,
    this.onDone,
    this.onSelectAll,
    this.onEdit,
    this.onUnarchive,
    this.onArchive,
    this.onClone,
    this.onExport,
    this.onDelete,
    this.onGroupModify,
  });

  final double height;
  final VoidCallback? onDone;
  final VoidCallback? onSelectAll;
  final VoidCallback? onEdit;
  final VoidCallback? onUnarchive;
  final VoidCallback? onArchive;
  final VoidCallback? onClone;
  final void Function(BuildContext context)? onExport;
  final VoidCallback? onDelete;
  final VoidCallback? onGroupModify;

  @override
  Widget build(BuildContext context) => SliverEditTopAppBar(
    height: height,
    onLeadingButtonPressed: onDone,
    action: SliverEditTopAppBarAction(
      onEdit: onEdit,
      onUnarchive: onUnarchive,
      onArchive: onArchive,
      onSelectAll: onSelectAll,
      onClone: onClone,
      onExportAll: onExport,
      onDelete: onDelete,
      onGroupModify: onGroupModify,
    ),
  );
}

class AppleSliverSelectAppBar extends StatelessWidget {
  const AppleSliverSelectAppBar({
    super.key,
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
  final void Function(BuildContext context)? onExport;
  final VoidCallback? onDelete;
  final VoidCallback? onGroupModify;
  final VoidCallback? onStatusModify;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final stat = context
        .select<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
          (vm) => vm.selectStatistic,
        );
    final grouping = context.select<AppExperimentalFeatureViewModel, bool>(
      (vm) => vm.habitGrouping,
    );
    final hasSelection = stat.selected > 0;
    final onExport = this.onExport;
    return CupertinoSliverSelectAppBar(
      title: Text(
        l10n?.habitDisplay_selectedHabits_title(stat.selected) ??
            'Selected ${stat.selected}',
      ),
      selectAllLabel: l10n?.habitDisplay_editPopMenu_selectAll ?? 'Select All',
      doneLabel: l10n?.habitDisplay_doneButton_label ?? 'Done',
      onSelectAll: onSelectAll,
      onDone: onDone,
      actions: buildAppleSelectActions(
        l10n: l10n,
        stat: stat,
        grouping: grouping,
        onExport: onExport != null ? () => onExport(context) : null,
        onUnarchive: onUnarchive,
        onArchive: onArchive,
        onDelete: onDelete,
        onGroupModify: onGroupModify,
        onStatusModify: onStatusModify,
        onEdit: onEdit,
        onClone: onClone,
        hasSelection: hasSelection,
      ),
    );
  }
}

List<CupertinoSelectAction> buildAppleSelectActions({
  required L10n? l10n,
  required HabitSummarySelectedStatistic stat,
  required bool grouping,
  required bool hasSelection,
  VoidCallback? onExport,
  VoidCallback? onUnarchive,
  VoidCallback? onArchive,
  VoidCallback? onDelete,
  VoidCallback? onGroupModify,
  VoidCallback? onStatusModify,
  VoidCallback? onEdit,
  VoidCallback? onClone,
}) => [
  CupertinoSelectAction(
    id: 'habit-edit',
    label: l10n?.habitDisplay_editButton_tooltip ?? 'Edit',
    icon: const Icon(CupertinoIcons.pencil),
    onPressed: onEdit,
    visible: stat.selected == 1,
    enabled: hasSelection && onEdit != null,
  ),
  CupertinoSelectAction(
    id: 'habit-export',
    label: l10n?.habitDisplay_editPopMenu_export ?? 'Export',
    icon: const Icon(CupertinoIcons.share),
    onPressed: onExport,
    enabled: hasSelection && onExport != null,
  ),
  CupertinoSelectAction(
    id: 'habit-unarchive',
    label: l10n?.habitDisplay_unarchiveButton_tooltip ?? 'Unarchive',
    icon: const Icon(CupertinoIcons.archivebox_fill),
    onPressed: onUnarchive,
    visible: stat.archived > 0,
    enabled: hasSelection && onUnarchive != null,
  ),
  CupertinoSelectAction(
    id: 'habit-archive',
    label: l10n?.habitDisplay_archiveButton_tooltip ?? 'Archive',
    icon: const Icon(CupertinoIcons.archivebox),
    onPressed: onArchive,
    visible: stat.activated > 0,
    enabled: hasSelection && onArchive != null,
  ),
  CupertinoSelectAction(
    id: 'habit-delete',
    label: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
    icon: const Icon(CupertinoIcons.delete),
    onPressed: onDelete,
    enabled: hasSelection && onDelete != null,
    destructive: true,
  ),
  CupertinoSelectAction(
    id: 'habit-group-modify',
    label: l10n?.habitDisplay_editPopMenu_groupModify ?? 'Modify Group',
    icon: const Icon(CupertinoIcons.folder),
    onPressed: onGroupModify,
    visible: grouping,
    enabled: hasSelection && onGroupModify != null,
    overflowBelowLarge: true,
    presentation: CupertinoSelectActionPresentation.iconAndLabel,
  ),
  CupertinoSelectAction(
    id: 'habit-status-modify',
    label: l10n?.batchCheckin_appbar_title ?? 'Batch Check-in',
    icon: const Icon(CupertinoIcons.square_list),
    onPressed: onStatusModify,
    enabled: hasSelection && onStatusModify != null,
    retentionPriority: 1000,
    presentation: CupertinoSelectActionPresentation.iconAndLabel,
  ),
  CupertinoSelectAction(
    id: 'habit-clone',
    label: l10n?.habitDisplay_editPopMenu_clone ?? 'Template',
    icon: const Icon(CupertinoIcons.square_on_square),
    onPressed: onClone,
    visible: stat.selected == 1,
    enabled: hasSelection && onClone != null,
    overflowBelowLarge: true,
    presentation: CupertinoSelectActionPresentation.iconAndLabel,
  ),
];

class HabitCupertinoSelectBottomToolbar extends StatelessWidget {
  const HabitCupertinoSelectBottomToolbar({
    super.key,
    this.onExport,
    this.onUnarchive,
    this.onArchive,
    this.onDelete,
    this.onGroupModify,
    this.onStatusModify,
    this.onEdit,
    this.onClone,
  });

  final void Function(BuildContext context)? onExport;
  final VoidCallback? onUnarchive;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onGroupModify;
  final VoidCallback? onStatusModify;
  final VoidCallback? onEdit;
  final VoidCallback? onClone;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final stat = context
        .select<HabitSummaryViewModel, HabitSummarySelectedStatistic>(
          (vm) => vm.selectStatistic,
        );
    final grouping = context.select<AppExperimentalFeatureViewModel, bool>(
      (vm) => vm.habitGrouping,
    );
    final onExport = this.onExport;
    return CupertinoSelectBottomToolbar(
      actions: buildAppleSelectActions(
        l10n: l10n,
        stat: stat,
        grouping: grouping,
        hasSelection: stat.selected > 0,
        onExport: onExport != null ? () => onExport(context) : null,
        onUnarchive: onUnarchive,
        onArchive: onArchive,
        onDelete: onDelete,
        onGroupModify: onGroupModify,
        onStatusModify: onStatusModify,
        onEdit: onEdit,
        onClone: onClone,
      ),
    );
  }
}
