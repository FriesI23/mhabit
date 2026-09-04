// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../_providers/group_manage.dart';
import 'group_manage_app_bar_actions.dart';

const _kCommonElevation = 2.0;

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
          GroupManageSelectionAppBarActions(
            selectedCount: selectedCount,
            effectiveSortType: effectiveSortType,
            onEdit: onEdit,
            onBatchDelete: onBatchDelete,
          ),
        ],
      );
    }
    return AdaptiveSliverAppBar(
      height: toolbarHeight,
      title: Text(l10n?.groupManage_appbar_title ?? 'Manage Groups'),
      leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
      actions: [
        GroupManageNormalAppBarActions(
          hasGroups: hasGroups,
          effectiveSortType: effectiveSortType,
          effectiveSortDirection: effectiveSortDirection,
          onSortOpen: onSortOpen,
        ),
      ],
    );
  }
}
