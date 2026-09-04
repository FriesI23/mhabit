// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BuildContext, Icons, Widget;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/app_ui/app_experimental_feature.dart';
import '../_providers/habit_summary.dart';

enum HabitDisplaySelectAction {
  selectAll,
  edit,
  unarchive,
  archive,
  clone,
  export,
  delete,
  groupModify,
}

final _selectAllId = ActionId('habits.select.select-all');
final _editId = ActionId('habits.select.edit');
final _unarchiveId = ActionId('habits.select.unarchive');
final _archiveId = ActionId('habits.select.archive');
final _cloneId = ActionId('habits.select.clone');
final _exportId = ActionId('habits.select.export');
final _deleteId = ActionId('habits.select.delete');
final _groupModifyId = ActionId('habits.select.group-modify');

final class HabitDisplaySelectAppBarCallbacks {
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
}

final class HabitDisplaySelectActionsData {
  const HabitDisplaySelectActionsData({
    required this.collection,
    required this.selectedCount,
    required this.onInvoke,
    required this.material,
    required this.apple,
  });

  final ActionCollection<HabitDisplaySelectAction> collection;
  final int selectedCount;
  final AdaptiveAppBarActionCallback<HabitDisplaySelectAction> onInvoke;
  final MaterialAppBarActionsConfig<HabitDisplaySelectAction> material;
  final CupertinoAppBarActionsConfig<HabitDisplaySelectAction> apple;
}

typedef HabitDisplaySelectActionsBuilder =
    Widget Function(BuildContext context, HabitDisplaySelectActionsData data);

class HabitDisplaySelectActions extends StatelessWidget {
  const HabitDisplaySelectActions({
    super.key,
    required this.callbacks,
    required this.includeSelectAll,
    required this.builder,
  });

  final HabitDisplaySelectAppBarCallbacks callbacks;
  final bool includeSelectAll;
  final HabitDisplaySelectActionsBuilder builder;

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
    final isLarge = WindowSize.of(context).width >= WindowSizeClass.large;
    final hasSelection = stat.selected > 0;
    final overflowOnly = ActionPlacementPolicy(
      placement: ActionPlacement.overflowOnly,
    );
    final highRetention = ActionPlacementPolicy(
      automaticPreference: AutomaticPlacementPreference(
        retentionPriority: PrimaryRetentionPriority.high,
      ),
    );
    final lowRetention = ActionPlacementPolicy(
      automaticPreference: AutomaticPlacementPreference(
        retentionPriority: PrimaryRetentionPriority.low,
      ),
    );
    final roots = <AdaptiveAction<HabitDisplaySelectAction>>[
      if (includeSelectAll)
        AdaptiveAction.action(
          id: _selectAllId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_editPopMenu_selectAll ?? 'Select All',
            tooltip: l10n?.habitDisplay_editPopMenu_selectAll ?? 'Select All',
            iconKey: _selectAllId.value,
          ),
          payload: HabitDisplaySelectAction.selectAll,
          isEnabled: callbacks.onSelectAll != null,
          placementPolicy: lowRetention,
        ),
      if (stat.selected == 1)
        AdaptiveAction.action(
          id: _editId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_editButton_tooltip ?? 'Edit',
            tooltip: l10n?.habitDisplay_editButton_tooltip ?? 'Edit',
            iconKey: _editId.value,
          ),
          payload: HabitDisplaySelectAction.edit,
          isEnabled: hasSelection && callbacks.onEdit != null,
          placementPolicy: highRetention,
        ),
      AdaptiveAction.action(
        id: _exportId,
        metadata: ActionMetadata(
          label: l10n?.habitDisplay_editPopMenu_export ?? 'Export',
          tooltip: l10n?.habitDisplay_editPopMenu_export ?? 'Export',
          iconKey: _exportId.value,
        ),
        payload: HabitDisplaySelectAction.export,
        isEnabled: hasSelection && callbacks.onExport != null,
        placementPolicy: lowRetention,
      ),
      if (stat.archived > 0)
        AdaptiveAction.action(
          id: _unarchiveId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_unarchiveButton_tooltip ?? 'Unarchive',
            tooltip: l10n?.habitDisplay_unarchiveButton_tooltip ?? 'Unarchive',
            iconKey: _unarchiveId.value,
          ),
          payload: HabitDisplaySelectAction.unarchive,
          isEnabled: hasSelection && callbacks.onUnarchive != null,
          placementPolicy: highRetention,
        ),
      if (stat.activated > 0)
        AdaptiveAction.action(
          id: _archiveId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_archiveButton_tooltip ?? 'Archive',
            tooltip: l10n?.habitDisplay_archiveButton_tooltip ?? 'Archive',
            iconKey: _archiveId.value,
          ),
          payload: HabitDisplaySelectAction.archive,
          isEnabled: hasSelection && callbacks.onArchive != null,
          placementPolicy: highRetention,
        ),
      AdaptiveAction.action(
        id: _deleteId,
        metadata: ActionMetadata(
          label: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
          tooltip: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
          iconKey: _deleteId.value,
          isDestructive: true,
        ),
        payload: HabitDisplaySelectAction.delete,
        isEnabled: hasSelection && callbacks.onDelete != null,
        placementPolicy: overflowOnly,
      ),
      if (grouping)
        AdaptiveAction.action(
          id: _groupModifyId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_editPopMenu_groupModify ?? 'Modify Group',
            tooltip:
                l10n?.habitDisplay_editPopMenu_groupModify ?? 'Modify Group',
            iconKey: _groupModifyId.value,
          ),
          payload: HabitDisplaySelectAction.groupModify,
          isEnabled: hasSelection && callbacks.onGroupModify != null,
          placementPolicy: isLarge ? null : overflowOnly,
        ),
      if (stat.selected == 1)
        AdaptiveAction.action(
          id: _cloneId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_editPopMenu_clone ?? 'Template',
            tooltip: l10n?.habitDisplay_editPopMenu_clone ?? 'Template',
            iconKey: _cloneId.value,
          ),
          payload: HabitDisplaySelectAction.clone,
          isEnabled: hasSelection && callbacks.onClone != null,
          placementPolicy: isLarge ? null : overflowOnly,
        ),
    ];
    return builder(
      context,
      HabitDisplaySelectActionsData(
        collection: ActionCollection<HabitDisplaySelectAction>(roots: roots),
        selectedCount: stat.selected,
        onInvoke: _onActionInvoked,
        material: MaterialAppBarActionsConfig(
          iconBuilder: _materialIcon,
          responsiveLayout: const MaterialAppBarResponsiveLayout(
            reservedWidth: 160,
          ),
        ),
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: _appleIcon,
          presentationForAction: _applePresentation,
        ),
      ),
    );
  }

  void _onActionInvoked(
    BuildContext anchorContext,
    HabitDisplaySelectAction action,
  ) {
    switch (action) {
      case HabitDisplaySelectAction.selectAll:
        callbacks.onSelectAll?.call();
      case HabitDisplaySelectAction.edit:
        callbacks.onEdit?.call();
      case HabitDisplaySelectAction.unarchive:
        callbacks.onUnarchive?.call();
      case HabitDisplaySelectAction.archive:
        callbacks.onArchive?.call();
      case HabitDisplaySelectAction.clone:
        callbacks.onClone?.call();
      case HabitDisplaySelectAction.export:
        callbacks.onExport?.call(anchorContext);
      case HabitDisplaySelectAction.delete:
        callbacks.onDelete?.call();
      case HabitDisplaySelectAction.groupModify:
        callbacks.onGroupModify?.call();
    }
  }

  Widget _materialIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplaySelectAction> action,
  ) => Icon(switch (action.payload) {
    HabitDisplaySelectAction.selectAll => MdiIcons.selectAll,
    HabitDisplaySelectAction.edit => Icons.edit_rounded,
    HabitDisplaySelectAction.unarchive => Icons.unarchive_rounded,
    HabitDisplaySelectAction.archive => Icons.archive_outlined,
    HabitDisplaySelectAction.clone => Icons.copy_rounded,
    HabitDisplaySelectAction.export => MdiIcons.export,
    HabitDisplaySelectAction.delete => MdiIcons.delete,
    HabitDisplaySelectAction.groupModify => MdiIcons.folderMove,
    null => Icons.more_horiz,
  });

  Widget _appleIcon(
    BuildContext context,
    AdaptiveAction<HabitDisplaySelectAction> action,
  ) => Icon(switch (action.payload) {
    HabitDisplaySelectAction.selectAll => CupertinoIcons.checkmark_alt_circle,
    HabitDisplaySelectAction.edit => CupertinoIcons.pencil,
    HabitDisplaySelectAction.unarchive => CupertinoIcons.archivebox_fill,
    HabitDisplaySelectAction.archive => CupertinoIcons.archivebox,
    HabitDisplaySelectAction.clone => CupertinoIcons.square_on_square,
    HabitDisplaySelectAction.export => CupertinoIcons.share,
    HabitDisplaySelectAction.delete => CupertinoIcons.delete,
    HabitDisplaySelectAction.groupModify => CupertinoIcons.folder,
    null => CupertinoIcons.ellipsis,
  });

  CupertinoActionPresentation _applePresentation(
    BuildContext context,
    AdaptiveAction<HabitDisplaySelectAction> action,
  ) => switch (action.payload) {
    HabitDisplaySelectAction.groupModify ||
    HabitDisplaySelectAction.clone => CupertinoActionPresentation.extended,
    _ => CupertinoActionPresentation.iconOnly,
  };
}
