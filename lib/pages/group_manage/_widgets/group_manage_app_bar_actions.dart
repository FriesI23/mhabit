// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../../widgets/app_bar_action_budget.dart';
import '../../common/widgets.dart';
import '../_providers/group_manage.dart';

enum _GroupManageAppBarAction {
  create,
  enterReorder,
  sort,
  edit,
  selectAll,
  reorder,
  delete,
}

final _createActionId = ActionId('group-manage.create');
final _enterReorderActionId = ActionId('group-manage.enter-reorder');
final _sortActionId = ActionId('group-manage.sort');
final _editActionId = ActionId('group-manage.edit');
final _selectAllActionId = ActionId('group-manage.select-all');
final _reorderActionId = ActionId('group-manage.reorder');
final _deleteActionId = ActionId('group-manage.delete');

class GroupManageNormalAppBarActions extends StatelessWidget {
  const GroupManageNormalAppBarActions({
    super.key,
    required this.onCreate,
    required this.hasGroups,
    required this.effectiveSortType,
    required this.effectiveSortDirection,
    required this.onSortOpen,
  });

  final VoidCallback onCreate;
  final bool hasGroups;
  final HabitDisplayGroupType effectiveSortType;
  final HabitDisplaySortDirection effectiveSortDirection;
  final VoidCallback onSortOpen;

  void _onInvoke(BuildContext context, _GroupManageAppBarAction action) {
    switch (action) {
      case _GroupManageAppBarAction.create:
        onCreate();
      case _GroupManageAppBarAction.enterReorder:
        final vm = context.read<GroupManageViewModel>();
        if (vm.effectiveSortType != HabitDisplayGroupType.manual) {
          vm.setSortOptions(
            HabitDisplayGroupType.manual,
            HabitDisplaySortDirection.asc,
          );
        }
        if (!vm.selectionMode) {
          vm.enterSelectionModeWithoutNotification();
        }
      case _GroupManageAppBarAction.sort:
        onSortOpen();
      case _GroupManageAppBarAction.edit ||
          _GroupManageAppBarAction.selectAll ||
          _GroupManageAppBarAction.reorder ||
          _GroupManageAppBarAction.delete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortIcon = GroupTypeSortIcon(
      groupType: effectiveSortType,
      direction: effectiveSortDirection,
    );
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialGroupManageNormalAppBarActions(
        hasGroups: hasGroups,
        onInvoke: _onInvoke,
        sortIcon: sortIcon,
      ),
      AdaptiveStyle.apple => _AppleGroupManageNormalAppBarActions(
        hasGroups: hasGroups,
        onInvoke: _onInvoke,
        sortIcon: sortIcon,
      ),
    };
  }
}

class GroupManageSelectionAppBarActions extends StatelessWidget {
  const GroupManageSelectionAppBarActions({
    super.key,
    required this.selectedCount,
    required this.effectiveSortType,
    required this.onEdit,
    required this.onBatchDelete,
  });

  final int selectedCount;
  final HabitDisplayGroupType effectiveSortType;
  final ValueChanged<String> onEdit;
  final VoidCallback onBatchDelete;

  void _onInvoke(BuildContext context, _GroupManageAppBarAction action) {
    final vm = context.read<GroupManageViewModel>();
    switch (action) {
      case _GroupManageAppBarAction.edit:
        if (vm.selectedCount == 1) onEdit(vm.selectedUUIDs.first);
      case _GroupManageAppBarAction.selectAll:
        vm.selectAll();
      case _GroupManageAppBarAction.reorder:
        vm.setSortOptions(
          HabitDisplayGroupType.manual,
          HabitDisplaySortDirection.asc,
        );
      case _GroupManageAppBarAction.delete:
        onBatchDelete();
      case _GroupManageAppBarAction.create ||
          _GroupManageAppBarAction.enterReorder ||
          _GroupManageAppBarAction.sort:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxPrimaryActions = switch (WindowSize.of(context).width) {
      WindowSizeClass.compact => 1,
      WindowSizeClass.medium => 2,
      WindowSizeClass.expanded => 3,
      WindowSizeClass.large || WindowSizeClass.extraLarge => 4,
    };
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialGroupManageSelectionAppBarActions(
        selectedCount: selectedCount,
        effectiveSortType: effectiveSortType,
        onInvoke: _onInvoke,
        maxPrimaryActions: maxPrimaryActions,
      ),
      AdaptiveStyle.apple => _AppleGroupManageSelectionAppBarActions(
        selectedCount: selectedCount,
        effectiveSortType: effectiveSortType,
        onInvoke: _onInvoke,
        maxPrimaryActions: maxPrimaryActions,
      ),
    };
  }
}

class _MaterialGroupManageNormalAppBarActions extends StatelessWidget {
  const _MaterialGroupManageNormalAppBarActions({
    required this.hasGroups,
    required this.onInvoke,
    required this.sortIcon,
  });

  final bool hasGroups;
  final AdaptiveAppBarActionCallback<_GroupManageAppBarAction> onInvoke;
  final Widget sortIcon;

  @override
  Widget build(BuildContext context) {
    final budget = AppBarActionBudget.slots(
      maxPrimaryActions: 2,
      reserveOverflow: true,
    );
    return AdaptiveAppBarActions<_GroupManageAppBarAction>.material(
      collection: _buildMaterialNormalActions(L10n.of(context), hasGroups),
      primaryCapacity: budget.primaryCapacity,
      maxPrimaryActions: budget.maxPrimaryActions,
      onInvoke: onInvoke,
      material: MaterialAppBarActionsConfig(
        iconBuilder: (_, action) => switch (action.payload) {
          _GroupManageAppBarAction.enterReorder => const Icon(
            MdiIcons.sortVariant,
          ),
          _GroupManageAppBarAction.sort => sortIcon,
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _AppleGroupManageNormalAppBarActions extends StatelessWidget {
  const _AppleGroupManageNormalAppBarActions({
    required this.hasGroups,
    required this.onInvoke,
    required this.sortIcon,
  });

  final bool hasGroups;
  final AdaptiveAppBarActionCallback<_GroupManageAppBarAction> onInvoke;
  final Widget sortIcon;

  @override
  Widget build(BuildContext context) {
    final budget = AppBarActionBudget.slots(
      maxPrimaryActions: 2,
      reserveOverflow: true,
    );
    return AdaptiveAppBarActions<_GroupManageAppBarAction>.apple(
      collection: _buildAppleNormalActions(L10n.of(context), hasGroups),
      primaryCapacity: budget.primaryCapacity,
      maxPrimaryActions: budget.maxPrimaryActions,
      onInvoke: onInvoke,
      apple: CupertinoAppBarActionsConfig(
        iconBuilder: (_, action) => switch (action.payload) {
          _GroupManageAppBarAction.create => const Icon(CupertinoIcons.add),
          _GroupManageAppBarAction.enterReorder => const Icon(
            CupertinoIcons.arrow_up_arrow_down,
          ),
          _GroupManageAppBarAction.sort => sortIcon,
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _MaterialGroupManageSelectionAppBarActions extends StatelessWidget {
  const _MaterialGroupManageSelectionAppBarActions({
    required this.selectedCount,
    required this.effectiveSortType,
    required this.onInvoke,
    required this.maxPrimaryActions,
  });

  final int selectedCount;
  final HabitDisplayGroupType effectiveSortType;
  final AdaptiveAppBarActionCallback<_GroupManageAppBarAction> onInvoke;
  final int maxPrimaryActions;

  @override
  Widget build(BuildContext context) {
    final budget = AppBarActionBudget.slots(
      maxPrimaryActions: maxPrimaryActions,
      reserveOverflow: true,
    );
    return AdaptiveAppBarActions<_GroupManageAppBarAction>.material(
      collection: _buildSelectionActions(
        L10n.of(context),
        selectedCount,
        effectiveSortType,
      ),
      primaryCapacity: budget.primaryCapacity,
      maxPrimaryActions: budget.maxPrimaryActions,
      onInvoke: onInvoke,
      material: MaterialAppBarActionsConfig(
        iconBuilder: (_, action) => Icon(switch (action.payload) {
          _GroupManageAppBarAction.edit => Icons.edit_outlined,
          _GroupManageAppBarAction.selectAll => Icons.select_all,
          _GroupManageAppBarAction.reorder => Icons.drag_indicator,
          _GroupManageAppBarAction.delete => Icons.delete_outline,
          _ => Icons.more_horiz,
        }),
      ),
    );
  }
}

class _AppleGroupManageSelectionAppBarActions extends StatelessWidget {
  const _AppleGroupManageSelectionAppBarActions({
    required this.selectedCount,
    required this.effectiveSortType,
    required this.onInvoke,
    required this.maxPrimaryActions,
  });

  final int selectedCount;
  final HabitDisplayGroupType effectiveSortType;
  final AdaptiveAppBarActionCallback<_GroupManageAppBarAction> onInvoke;
  final int maxPrimaryActions;

  @override
  Widget build(BuildContext context) {
    final budget = AppBarActionBudget.slots(
      maxPrimaryActions: maxPrimaryActions,
      reserveOverflow: true,
    );
    return AdaptiveAppBarActions<_GroupManageAppBarAction>.apple(
      collection: _buildSelectionActions(
        L10n.of(context),
        selectedCount,
        effectiveSortType,
      ),
      primaryCapacity: budget.primaryCapacity,
      maxPrimaryActions: budget.maxPrimaryActions,
      onInvoke: onInvoke,
      apple: CupertinoAppBarActionsConfig(
        iconBuilder: (_, action) => Icon(switch (action.payload) {
          _GroupManageAppBarAction.edit => CupertinoIcons.pencil,
          _GroupManageAppBarAction.selectAll =>
            CupertinoIcons.checkmark_alt_circle,
          _GroupManageAppBarAction.reorder =>
            CupertinoIcons.arrow_up_arrow_down,
          _GroupManageAppBarAction.delete => CupertinoIcons.delete,
          _ => CupertinoIcons.ellipsis,
        }),
      ),
    );
  }
}

ActionCollection<_GroupManageAppBarAction> _buildMaterialNormalActions(
  L10n? l10n,
  bool hasGroups,
) => ActionCollection(
  roots: [
    if (hasGroups) _buildEnterReorderAction(l10n),
    _buildSortAction(l10n),
  ],
);

ActionCollection<_GroupManageAppBarAction> _buildAppleNormalActions(
  L10n? l10n,
  bool hasGroups,
) => ActionCollection(
  roots: [
    AdaptiveAction.action(
      id: _createActionId,
      metadata: ActionMetadata(
        label: l10n?.groupManage_createButton_tooltip ?? 'Create group',
        tooltip: l10n?.groupManage_createButton_tooltip ?? 'Create group',
      ),
      payload: _GroupManageAppBarAction.create,
    ),
    if (hasGroups) _buildEnterReorderAction(l10n),
    _buildSortAction(l10n),
  ],
);

AdaptiveAction<_GroupManageAppBarAction> _buildEnterReorderAction(L10n? l10n) =>
    AdaptiveAction.action(
      id: _enterReorderActionId,
      metadata: ActionMetadata(
        label: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
        tooltip: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
      ),
      payload: _GroupManageAppBarAction.enterReorder,
      placementPolicy: ActionPlacementPolicy(placement: ActionPlacement.pinned),
    );

AdaptiveAction<_GroupManageAppBarAction> _buildSortAction(L10n? l10n) =>
    AdaptiveAction.action(
      id: _sortActionId,
      metadata: ActionMetadata(
        label: l10n?.groupManage_sortTile_text ?? 'Sort Groups',
        tooltip: l10n?.groupManage_sortTile_text ?? 'Sort Groups',
      ),
      payload: _GroupManageAppBarAction.sort,
    );

ActionCollection<_GroupManageAppBarAction> _buildSelectionActions(
  L10n? l10n,
  int selectedCount,
  HabitDisplayGroupType effectiveSortType,
) {
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
  return ActionCollection<_GroupManageAppBarAction>(
    roots: [
      if (selectedCount == 1)
        AdaptiveAction.action(
          id: _editActionId,
          metadata: ActionMetadata(
            label: l10n?.habitDisplay_editButton_tooltip ?? 'Edit',
            tooltip: l10n?.habitDisplay_editButton_tooltip ?? 'Edit',
          ),
          payload: _GroupManageAppBarAction.edit,
          placementPolicy: highRetention,
        ),
      AdaptiveAction.action(
        id: _selectAllActionId,
        metadata: ActionMetadata(
          label: l10n?.groupManage_selectAll ?? 'Select all',
          tooltip: l10n?.groupManage_selectAll ?? 'Select all',
        ),
        payload: _GroupManageAppBarAction.selectAll,
      ),
      if (effectiveSortType != HabitDisplayGroupType.manual)
        AdaptiveAction.action(
          id: _reorderActionId,
          metadata: ActionMetadata(
            label: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
            tooltip: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
          ),
          payload: _GroupManageAppBarAction.reorder,
        ),
      AdaptiveAction.action(
        id: _deleteActionId,
        metadata: ActionMetadata(
          label: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
          tooltip: l10n?.habitDisplay_editPopMenu_delete ?? 'Delete',
        ),
        payload: _GroupManageAppBarAction.delete,
        isEnabled: selectedCount > 0,
        placementPolicy: lowRetention,
      ),
    ],
  );
}
