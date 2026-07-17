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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../models/habit_display.dart';
import '../../models/habit_group_display.dart';
import '../../providers/app_ui/app_developer.dart';
import '../../widgets/widgets.dart';
import '_providers/group_manage.dart';
import '_widgets/group_edit_dialog.dart';
import '_widgets/group_manage_grid.dart';
import '_widgets/group_manage_list.dart';
import 'providers.dart';

Future<void> naviToGroupManagePage({required BuildContext context}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (context) => const GroupManagePage()),
  );
}

class GroupManagePage extends StatelessWidget {
  const GroupManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageProviders(child: _Page());
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

const _kCommonEvalation = 2.0;

/// Debug-only: forces the group edit/create dialog to open as a bottom sheet
/// or a dialog, regardless of screen size. [defaultMode] follows the normal
/// adaptive heuristics.
enum GroupEditForceMode { defaultMode, forceSheet, forceDialog }

class _PageState extends State<_Page> {
  ScaffoldMessengerState? _snackbarMessenger;
  GroupEditForceMode _debugForceEditMode = GroupEditForceMode.defaultMode;

  @visibleForTesting
  Future<void> loadData() async {
    if (!mounted) return;
    final vm = context.read<GroupManageViewModel>();
    if (!(mounted && vm.mounted)) return;
    if (!vm.hasLoad) {
      await vm.loadGroups(listen: false);
    }
  }

  Future<void> _openSortSelector() async {
    final vm = context.read<GroupManageViewModel>();
    final result = await showDialog<SortMenuOption>(
      context: context,
      builder: (context) => _GroupSortPickerDialog(
        sortType: vm.effectiveSortType,
        sortDirection: vm.effectiveSortDirection,
      ),
    );
    if (result != null && mounted) {
      vm.setSortOptions(result.$1, result.$2);
    }
  }

  Future<void> _openCreateDialog() async {
    final vm = context.read<GroupManageViewModel>();
    final result = await showGroupEditDialog(
      context: context,
      forceSheet: _debugForceEditMode == GroupEditForceMode.forceSheet,
      forceDialog: _debugForceEditMode == GroupEditForceMode.forceDialog,
    );
    if (result == null || !mounted) return;
    await vm.createGroup(
      name: result.name,
      desc: result.desc,
      icon: result.icon,
      color: result.color,
    );
  }

  Future<void> _openEditDialog(String uuid) async {
    final vm = context.read<GroupManageViewModel>();
    final data = await vm.loadGroupDataByUUID(uuid);
    if (data == null || !mounted) return;

    final result = await showGroupEditDialog(
      context: context,
      existingGroup: data,
      forceSheet: _debugForceEditMode == GroupEditForceMode.forceSheet,
      forceDialog: _debugForceEditMode == GroupEditForceMode.forceDialog,
    );
    if (result == null || !mounted) return;
    await vm.updateGroup(
      uuid: uuid,
      name: result.name,
      desc: result.desc,
      icon: result.icon,
      color: result.color,
    );
  }

  Future<void> _onSingleDelete(String uuid) async {
    final vm = context.read<GroupManageViewModel>();
    final confirmed = await _confirmDelete(
      context: context,
      isBatch: false,
      count: 1,
    );
    if (!confirmed || !mounted) return;
    await vm.deleteSingleGroup(uuid);
    if (mounted) _showDeleteUndoSnackBar(context);
  }

  Future<void> _onBatchDelete() async {
    final vm = context.read<GroupManageViewModel>();
    final confirmed = await _confirmDelete(
      context: context,
      isBatch: true,
      count: vm.selectedCount,
    );
    if (!confirmed || !mounted) return;
    await vm.deleteSelectedGroups();
    if (mounted) _showDeleteUndoSnackBar(context);
  }

  Future<bool> _confirmDelete({
    required BuildContext context,
    required bool isBatch,
    required int count,
  }) async {
    final l10n = L10n.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.groupManage_deleteDialog_title ?? 'Delete Group'),
        content: Text(
          l10n?.groupManage_deleteDialog_content ??
              'Associated habits will become uncategorized and this cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.groupManage_deleteDialog_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.groupManage_deleteDialog_confirm ?? 'Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showDeleteUndoSnackBar(BuildContext context) {
    final l10n = L10n.of(context);
    final snackBar = SnackBar(
      content: Text(l10n?.groupManage_deleted_snackbarText ?? 'Group deleted'),
      action: SnackBarAction(
        label: l10n?.groupManage_undo_snackbarAction ?? 'Undo',
        onPressed: () {
          if (!mounted) return;
          context.read<GroupManageViewModel>().undoLastDelete();
        },
      ),
      duration: kAppUndoDialogShowDuration,
    );
    _snackbarMessenger = ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _snackbarMessenger?.hideCurrentSnackBar();
    super.dispose();
  }

  void _onGroupTap(String uuid) {
    final vm = context.read<GroupManageViewModel>();
    if (vm.selectionMode) {
      vm.toggleSelection(uuid);
    } else {
      _openEditDialog(uuid);
    }
  }

  void _onGroupLongPress(String uuid) {
    final vm = context.read<GroupManageViewModel>();
    if (!vm.selectionMode) {
      vm.enterSelectionMode(uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulNavibar(
      child: Scaffold(
        body: Selector<GroupManageViewModel, (bool, bool)>(
          selector: (context, vm) => (vm.hasLoad, vm.consumeForceReloadFlag()),
          shouldRebuild: (previous, next) => previous.$1 != next.$1 || next.$2,
          builder: (context, _, child) => FutureBuilder(
            future: loadData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              final vm = context.watch<GroupManageViewModel>();
              // Show spinner only on first load before any data is cached;
              // on subsequent reloads, always render from cached state.
              if (!vm.hasLoaded && !vm.hasLoad) {
                return const Center(child: CircularProgressIndicator());
              }
              return EnhancedSafeArea.edgeToEdgeSafe(
                child: _buildContent(context, vm),
              );
            },
          ),
        ),
        floatingActionButton: _buildFab(context),
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    final selectionMode = context.select<GroupManageViewModel, bool>(
      (vm) => vm.selectionMode,
    );
    if (selectionMode) return null;
    return FloatingActionButton(
      onPressed: _openCreateDialog,
      child: const Icon(Icons.add),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final vm = context.watch<GroupManageViewModel>();
    final l10n = L10n.of(context);
    if (vm.selectionMode) {
      return SliverAppBar(
        pinned: true,
        forceElevated: true,
        scrolledUnderElevation: _kCommonEvalation,
        shadowColor: Theme.of(context).colorScheme.shadow,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: vm.exitSelectionMode,
        ),
        title: Text(
          l10n?.groupManage_selectionAppbar_title(vm.selectedCount) ??
              '${vm.selectedCount} selected',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: vm.selectedCount > 0 ? _onBatchDelete : null,
          ),
        ],
      );
    }
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      title: Text(l10n?.groupManage_appbar_title ?? 'Manage Groups'),
      leading: const PageBackButton(reason: PageBackReason.back),
      actions: [
        IconButton(icon: const Icon(Icons.sort), onPressed: _openSortSelector),
      ],
    );
  }

  Widget _buildContent(BuildContext context, GroupManageViewModel vm) {
    // Only show empty state after data has actually loaded; before that
    // (first visit) the FutureBuilder already shows a spinner.
    if (vm.hasLoaded && vm.groups.isEmpty) {
      return _buildEmptyState(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kHabitLargeScreenAdaptWidth;
        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            if (isWide)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: GroupManageGrid(
                  groups: vm.groups,
                  selectedUUIDs: vm.selectedUUIDs,
                  selectionMode: vm.selectionMode,
                  onTap: _onGroupTap,
                  onLongPress: _onGroupLongPress,
                  onEdit: _openEditDialog,
                  onDelete: _onSingleDelete,
                ),
              )
            else
              GroupManageList(
                groups: vm.groups,
                selectedUUIDs: vm.selectedUUIDs,
                selectionMode: vm.selectionMode,
                onTap: _onGroupTap,
                onLongPress: _onGroupLongPress,
                onEdit: _openEditDialog,
                onDelete: _onSingleDelete,
              ),
            if (kDebugMode)
              SliverToBoxAdapter(child: _buildDevelopMenu(context)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = L10n.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.groupManage_emptyState_text ?? 'No groups yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopMenu(BuildContext context) {
    return Selector<AppDeveloperViewModel, bool>(
      selector: (context, vm) => vm.showDebugMenuOnDisplayView,
      builder: (context, showMenu, child) {
        if (!showMenu) return const SizedBox.shrink();
        return _GroupManageDevelopMenu(
          mode: _debugForceEditMode,
          onChanged: (mode) => setState(() => _debugForceEditMode = mode),
        );
      },
    );
  }
}

class _GroupManageDevelopMenu extends StatelessWidget {
  final GroupEditForceMode mode;
  final ValueChanged<GroupEditForceMode> onChanged;

  const _GroupManageDevelopMenu({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return EnhancedSafeArea.edgeToEdgeSafe(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 72),
        child: ListTile(
          title: const Text('Edit dialog'),
          trailing: DropdownButton<GroupEditForceMode>(
            value: mode,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            items: const [
              DropdownMenuItem(
                value: GroupEditForceMode.defaultMode,
                child: Text('Default'),
              ),
              DropdownMenuItem(
                value: GroupEditForceMode.forceSheet,
                child: Text('Sheet'),
              ),
              DropdownMenuItem(
                value: GroupEditForceMode.forceDialog,
                child: Text('Dialog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SortMenuOption = (HabitDisplayGroupType, HabitDisplaySortDirection);

class _GroupSortPickerDialog extends StatefulWidget {
  final SortMenuOption initSortOption;

  const _GroupSortPickerDialog({
    required HabitDisplayGroupType sortType,
    required HabitDisplaySortDirection sortDirection,
  }) : initSortOption = (sortType, sortDirection);

  @override
  State<_GroupSortPickerDialog> createState() => _GroupSortPickerDialogState();
}

class _GroupSortPickerDialogState extends State<_GroupSortPickerDialog> {
  late SortMenuOption _crtSortOption;

  @override
  void initState() {
    super.initState();
    _crtSortOption = widget.initSortOption;
  }

  void _onRadioTapChanged(HabitDisplayGroupType? value) {
    if (value == null) return;
    setState(() {
      _crtSortOption = (value, _crtSortOption.$2);
    });
  }

  HabitDisplayGroupType get crtSortType => _crtSortOption.$1;
  HabitDisplaySortDirection get crtSortDirection => _crtSortOption.$2;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(l10n?.groupManage_sortTile_text ?? 'Sort Groups'),
      contentPadding: const EdgeInsets.only(bottom: 24, top: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<HabitDisplayGroupType>(
            groupValue: crtSortType,
            onChanged: _onRadioTapChanged,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final sortType in GroupManageViewModel.supportedSortTypes)
                  RadioListTile<HabitDisplayGroupType>(
                    title: Text(_sortTypeLabel(sortType, l10n)),
                    secondary: Icon(_sortTypeIcon(sortType)),
                    value: sortType,
                  ),
              ],
            ),
          ),
          const Divider(),
          CheckboxListTile(
            title: Text(l10n?.habitDisplay_sort_reverseText ?? 'Reverse'),
            value: crtSortDirection == HabitDisplaySortDirection.desc,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                _crtSortOption = (
                  crtSortType,
                  value == true
                      ? HabitDisplaySortDirection.desc
                      : HabitDisplaySortDirection.asc,
                );
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.habitDisplay_sortTypeDialog_cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _crtSortOption),
          child: Text(l10n?.habitDisplay_sortTypeDialog_confirm ?? 'Confirm'),
        ),
      ],
    );
  }

  String _sortTypeLabel(HabitDisplayGroupType type, L10n? l10n) {
    return switch (type) {
      HabitDisplayGroupType.name => 'Name',
      HabitDisplayGroupType.colorType => 'Color',
      HabitDisplayGroupType.createDate => 'Created date',
    };
  }

  IconData _sortTypeIcon(HabitDisplayGroupType type) {
    return switch (type) {
      HabitDisplayGroupType.name => Icons.sort_by_alpha,
      HabitDisplayGroupType.colorType => Icons.palette_outlined,
      HabitDisplayGroupType.createDate => Icons.calendar_today,
    };
  }
}
