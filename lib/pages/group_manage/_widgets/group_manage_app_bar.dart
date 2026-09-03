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

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../common/widgets.dart';
import '../_providers/group_manage.dart';

const _kCommonElevation = 2.0;
const _appBarActionSlotExtent = 48.0;

enum _GroupManageAppBarAction {
  enterReorder,
  sort,
  edit,
  selectAll,
  reorder,
  delete,
}

final _enterReorderActionId = ActionId('group-manage.enter-reorder');
final _sortActionId = ActionId('group-manage.sort');
final _editActionId = ActionId('group-manage.edit');
final _selectAllActionId = ActionId('group-manage.select-all');
final _reorderActionId = ActionId('group-manage.reorder');
final _deleteActionId = ActionId('group-manage.delete');

class GroupManageSliverAppBar extends StatelessWidget {
  const GroupManageSliverAppBar({
    super.key,
    required this.onEdit,
    required this.onSortOpen,
    required this.onBatchDelete,
  });

  final ValueChanged<String> onEdit;
  final VoidCallback onSortOpen;
  final VoidCallback onBatchDelete;

  @override
  Widget build(BuildContext context) {
    final (
      selectionMode,
      selectedCount,
      hasGroups,
      effectiveSortType,
      effectiveSortDirection,
    ) = context
        .select<
          GroupManageViewModel,
          (bool, int, bool, HabitDisplayGroupType, HabitDisplaySortDirection)
        >(
          (vm) => (
            vm.selectionMode,
            vm.selectedCount,
            vm.groups.isNotEmpty,
            vm.effectiveSortType,
            vm.effectiveSortDirection,
          ),
        );
    final l10n = L10n.of(context);
    final toolbarHeight = AdaptiveStyle.of(context).appToolbarHeight;

    if (selectionMode) {
      return AdaptiveSliverAppBar(
        height: toolbarHeight,
        styles: AppBarStyles(
          material: AppBarMaterialStyle(
            floating: false,
            snap: false,
            pinned: true,
            forceElevated: true,
            scrolledUnderElevation: _kCommonElevation,
            shadowColor: Theme.of(context).colorScheme.shadow,
          ),
        ),
        leading: AdaptiveBackButton(
          type: AdaptiveBackButtonType.close,
          onPressed: () =>
              context.read<GroupManageViewModel>().exitSelectionMode(),
        ),
        title: Text(
          l10n?.groupManage_selectionAppbar_title(selectedCount) ??
              '$selectedCount selected',
        ),
        actions: [
          _buildSelectionActions(
            context: context,
            l10n: l10n,
            selectedCount: selectedCount,
            effectiveSortType: effectiveSortType,
          ),
        ],
      );
    }
    return AdaptiveSliverAppBar(
      height: toolbarHeight,
      title: Text(l10n?.groupManage_appbar_title ?? 'Manage Groups'),
      leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
      actions: [
        _buildNormalActions(
          context: context,
          l10n: l10n,
          hasGroups: hasGroups,
          effectiveSortType: effectiveSortType,
          effectiveSortDirection: effectiveSortDirection,
        ),
      ],
    );
  }

  Widget _buildNormalActions({
    required BuildContext context,
    required L10n? l10n,
    required bool hasGroups,
    required HabitDisplayGroupType effectiveSortType,
    required HabitDisplaySortDirection effectiveSortDirection,
  }) {
    final collection = ActionCollection<_GroupManageAppBarAction>(
      roots: [
        if (hasGroups)
          AdaptiveAction.action(
            id: _enterReorderActionId,
            metadata: ActionMetadata(
              label: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
              tooltip: l10n?.groupManage_reorder_tooltip ?? 'Reorder groups',
            ),
            payload: _GroupManageAppBarAction.enterReorder,
            placementPolicy: ActionPlacementPolicy(
              placement: ActionPlacement.pinned,
            ),
          ),
        AdaptiveAction.action(
          id: _sortActionId,
          metadata: ActionMetadata(
            label: l10n?.groupManage_sortTile_text ?? 'Sort Groups',
            tooltip: l10n?.groupManage_sortTile_text ?? 'Sort Groups',
          ),
          payload: _GroupManageAppBarAction.sort,
          placementPolicy: ActionPlacementPolicy(
            placement: ActionPlacement.pinned,
          ),
        ),
      ],
    );
    final sortIcon = GroupTypeSortIcon(
      groupType: effectiveSortType,
      direction: effectiveSortDirection,
    );
    return AdaptiveAppBarActions<_GroupManageAppBarAction>(
      collection: collection,
      primaryCapacity: 3 * _appBarActionSlotExtent,
      maxPrimaryActions: 2,
      onInvoke: (_, action) {
        switch (action) {
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
            break;
          case _GroupManageAppBarAction.sort:
            onSortOpen();
            break;
          case _GroupManageAppBarAction.edit ||
              _GroupManageAppBarAction.selectAll ||
              _GroupManageAppBarAction.reorder ||
              _GroupManageAppBarAction.delete:
            break;
        }
      },
      materialIconBuilder: (_, action) => switch (action.payload) {
        _GroupManageAppBarAction.enterReorder => const Icon(
          MdiIcons.sortVariant,
        ),
        _GroupManageAppBarAction.sort => sortIcon,
        _ => const SizedBox.shrink(),
      },
      appleIconBuilder: (_, action) => switch (action.payload) {
        _GroupManageAppBarAction.enterReorder => const Icon(
          CupertinoIcons.arrow_up_arrow_down,
        ),
        _GroupManageAppBarAction.sort => sortIcon,
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildSelectionActions({
    required BuildContext context,
    required L10n? l10n,
    required int selectedCount,
    required HabitDisplayGroupType effectiveSortType,
  }) {
    final editLabel = l10n?.habitDisplay_editButton_tooltip ?? 'Edit';
    final selectAllLabel = l10n?.groupManage_selectAll ?? 'Select all';
    final reorderLabel = l10n?.groupManage_reorder_tooltip ?? 'Reorder groups';
    final deleteLabel = l10n?.habitDisplay_editPopMenu_delete ?? 'Delete';
    final collection = ActionCollection<_GroupManageAppBarAction>(
      roots: [
        if (selectedCount == 1)
          _selectionAction(
            id: _editActionId,
            label: editLabel,
            payload: _GroupManageAppBarAction.edit,
            priority: 400,
          ),
        _selectionAction(
          id: _selectAllActionId,
          label: selectAllLabel,
          payload: _GroupManageAppBarAction.selectAll,
          priority: 300,
        ),
        if (effectiveSortType != HabitDisplayGroupType.manual)
          _selectionAction(
            id: _reorderActionId,
            label: reorderLabel,
            payload: _GroupManageAppBarAction.reorder,
            priority: 200,
          ),
        _selectionAction(
          id: _deleteActionId,
          label: deleteLabel,
          payload: _GroupManageAppBarAction.delete,
          priority: 100,
          isEnabled: selectedCount > 0,
        ),
      ],
    );
    final maxPrimaryActions = switch (WindowSize.of(context).width) {
      WindowSizeClass.compact => 1,
      WindowSizeClass.medium => 2,
      WindowSizeClass.expanded => 3,
      WindowSizeClass.large || WindowSizeClass.extraLarge => 4,
    };
    return AdaptiveAppBarActions<_GroupManageAppBarAction>(
      collection: collection,
      primaryCapacity: (maxPrimaryActions + 1) * _appBarActionSlotExtent,
      maxPrimaryActions: maxPrimaryActions,
      onInvoke: (_, action) {
        final vm = context.read<GroupManageViewModel>();
        switch (action) {
          case _GroupManageAppBarAction.edit:
            if (vm.selectedCount == 1) {
              onEdit(vm.selectedUUIDs.first);
            }
            break;
          case _GroupManageAppBarAction.selectAll:
            vm.selectAll();
            break;
          case _GroupManageAppBarAction.reorder:
            vm.setSortOptions(
              HabitDisplayGroupType.manual,
              HabitDisplaySortDirection.asc,
            );
            break;
          case _GroupManageAppBarAction.delete:
            onBatchDelete();
            break;
          case _GroupManageAppBarAction.enterReorder ||
              _GroupManageAppBarAction.sort:
            break;
        }
      },
      materialIconBuilder: (_, action) => Icon(switch (action.payload) {
        _GroupManageAppBarAction.edit => Icons.edit_outlined,
        _GroupManageAppBarAction.selectAll => Icons.select_all,
        _GroupManageAppBarAction.reorder => Icons.drag_indicator,
        _GroupManageAppBarAction.delete => Icons.delete_outline,
        _ => Icons.more_horiz,
      }),
      appleIconBuilder: (_, action) => Icon(switch (action.payload) {
        _GroupManageAppBarAction.edit => CupertinoIcons.pencil,
        _GroupManageAppBarAction.selectAll =>
          CupertinoIcons.checkmark_alt_circle,
        _GroupManageAppBarAction.reorder => CupertinoIcons.arrow_up_arrow_down,
        _GroupManageAppBarAction.delete => CupertinoIcons.delete,
        _ => CupertinoIcons.ellipsis,
      }),
    );
  }

  AdaptiveAction<_GroupManageAppBarAction> _selectionAction({
    required ActionId id,
    required String label,
    required _GroupManageAppBarAction payload,
    required int priority,
    bool isEnabled = true,
  }) => AdaptiveAction.action(
    id: id,
    metadata: ActionMetadata(label: label, tooltip: label),
    payload: payload,
    isEnabled: isEnabled,
    placementPolicy: ActionPlacementPolicy(
      automaticPreference: AutomaticPlacementPreference(
        retentionPriority: PrimaryRetentionPriority.custom(priority),
      ),
    ),
  );
}
