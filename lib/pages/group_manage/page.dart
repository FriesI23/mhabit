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

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/habit_display.dart';
import '../../models/habit_group.dart';
import '../../models/habit_group_display.dart';
import '../../providers/app_ui/app_developer.dart';
import '../../routes/app_navigation_coordinator.dart';
import '../../widgets/widgets.dart';
import '../habits_display/_widgets/habit_display_group_type_picker.dart';
import '_providers/group_manage.dart';
import 'providers.dart';
import 'widgets.dart';

class GroupManagePage extends StatelessWidget {
  final String? initialGroupUUID;

  const GroupManagePage({super.key, this.initialGroupUUID});

  @override
  Widget build(BuildContext context) {
    return PageProviders(
      initialGroupUUID: initialGroupUUID,
      child: const _Page(),
    );
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

/// Debug-only: forces the group edit/create dialog to open as a bottom sheet
/// or a dialog, regardless of screen size. [defaultMode] follows the normal
/// adaptive heuristics.
enum GroupEditForceMode { defaultMode, forceSheet, forceDialog }

class _PageState extends State<_Page> {
  ScaffoldMessengerState? _snackbarMessenger;
  GroupEditForceMode _debugForceEditMode = GroupEditForceMode.defaultMode;
  bool _skipDeleteConfirm = false;

  @visibleForTesting
  Future<void> loadData() async {
    if (!mounted) return;
    final vm = context.read<GroupManageViewModel>();
    if (!(mounted && vm.mounted)) return;
    if (!vm.hasLoad) {
      await vm.loadGroups();
    }
  }

  Future<void> _openSortSelector() async {
    final vm = context.read<GroupManageViewModel>();
    final result = await showHabitDisplayGroupTypePickerDialog(
      context: context,
      groupType: vm.effectiveSortType,
      groupDirection: vm.effectiveSortDirection,
      title: L10n.of(context)?.groupManage_sortTile_text ?? 'Sort Groups',
      filter: GroupTypePickerFilter.hidden(
        showNone: false,
        hiddenTypes: {HabitDisplayGroupType.habitCount},
      ),
    );
    if (result != null && result.$1 != null && mounted) {
      await vm.setSortOptions(
        result.$1!,
        result.$2 ?? HabitDisplaySortDirection.asc,
      );
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
    final confirmed = await _confirmDelete(context: context, count: 1);
    if (!confirmed || !mounted) return;
    await vm.deleteSingleGroup(uuid);
    if (mounted) {
      _showDeleteUndoSnackBar(context);
    }
  }

  Future<void> _onBatchDelete() async {
    final vm = context.read<GroupManageViewModel>();
    final confirmed = await _confirmDelete(
      context: context,
      count: vm.selectedCount,
    );
    if (!confirmed || !mounted) return;
    await vm.deleteSelectedGroups();
    if (mounted) {
      _showDeleteUndoSnackBar(context);
    }
  }

  Future<bool> _confirmDelete({
    required BuildContext context,
    required int count,
  }) async {
    if (_skipDeleteConfirm) return true;

    final l10n = L10n.of(context);
    final result = await showConfirmDialog(
      context: context,
      title: Text(l10n?.groupManage_deleteDialog_title ?? 'Delete Group'),
      subtitle: Text(
        l10n?.groupManage_deleteDialog_content(count) ??
            'Habits in this group will become uncategorized.',
      ),
      cancelText: Text(l10n?.groupManage_deleteDialog_cancel ?? 'Cancel'),
      confirmText: Text(l10n?.groupManage_deleteDialog_confirm ?? 'Delete'),
      skipOnConfirm: true,
      skipInitiallyEnabled: _skipDeleteConfirm,
      onSkipChanged: (v) => _skipDeleteConfirm = v,
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
          final vm = context.read<GroupManageViewModel>();
          vm.undoLastDelete();
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

  @override
  Widget build(BuildContext context) {
    final child = ColorfulNavibar(
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
              return EnhancedSafeArea.edgeToEdgeSafe(
                child: _GroupManageBody(
                  onEdit: _openEditDialog,
                  onDelete: _onSingleDelete,
                  onSortOpen: _openSortSelector,
                  onBatchDelete: _onBatchDelete,
                  debugMenuBuilder: _buildDevelopMenu,
                ),
              );
            },
          ),
        ),
        floatingActionButton: _buildFab(context),
      ),
    );
    return _GroupManagePopScope(child: child);
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

class _GroupManagePopScope extends StatelessWidget {
  const _GroupManagePopScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Selector2<
      GroupManageViewModel,
      AppNavigationCoordinator,
      (bool, bool)
    >(
      selector: (_, vm, coordinator) =>
          (vm.canPop, coordinator.destinationSwitchInProgress),
      child: child,
      builder: (context, navigation, child) {
        final (canPop, destinationSwitchInProgress) = navigation;
        return PopScope<void>(
          canPop: canPop || destinationSwitchInProgress,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context.read<GroupManageViewModel>().exitSelectionMode();
            }
          },
          child: child!,
        );
      },
    );
  }
}

class _GroupManageBody extends StatelessWidget {
  const _GroupManageBody({
    required this.onEdit,
    required this.onDelete,
    required this.onSortOpen,
    required this.onBatchDelete,
    required this.debugMenuBuilder,
  });

  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;
  final VoidCallback onSortOpen;
  final VoidCallback onBatchDelete;
  final WidgetBuilder debugMenuBuilder;

  @override
  Widget build(BuildContext context) {
    final (hasLoaded, groupsEmpty) = context
        .select<GroupManageViewModel, (bool, bool)>(
          (vm) => (vm.hasLoaded, vm.groups.isEmpty),
        );

    if (!hasLoaded && groupsEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return WindowSizeClassLayoutBuilder(
      builder: (context, windowSize, child) => CustomScrollView(
        slivers: [
          GroupManageSliverAppBar(
            onEdit: onEdit,
            onSortOpen: onSortOpen,
            onBatchDelete: onBatchDelete,
          ),
          if (groupsEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _GroupManageEmptyState(),
            )
          else ...[
            _GroupManageContent(
              widthClass: windowSize.width,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            if (kDebugMode)
              SliverToBoxAdapter(child: debugMenuBuilder(context)),
          ],
        ],
      ),
    );
  }
}

class _GroupManageEmptyState extends StatelessWidget {
  const _GroupManageEmptyState();

  @override
  Widget build(BuildContext context) {
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
}

class _GroupManageContent extends StatelessWidget {
  const _GroupManageContent({
    required this.widthClass,
    required this.onEdit,
    required this.onDelete,
  });

  final WindowSizeClass widthClass;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    // selectedCount is the watch trigger (int changes -> new record -> rebuild).
    // selectedUUIDs is obtained via read; no separate subscription is needed.
    final (groups, selectionMode, _) = context
        .select<GroupManageViewModel, (List<HabitGroupData>, bool, int)>(
          (vm) => (vm.groups, vm.selectionMode, vm.selectedCount),
        );
    final selectedUUIDs = context.read<GroupManageViewModel>().selectedUUIDs;
    final selectedCount = selectedUUIDs.length;

    void onTap(String uuid) {
      final vm = context.read<GroupManageViewModel>();
      if (vm.selectionMode) {
        vm.toggleSelection(uuid);
      } else {
        onEdit(uuid);
      }
    }

    return widthClass >= WindowSizeClass.medium
        ? SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: GroupManageGrid(
              groups: groups,
              selectedUUIDs: selectedUUIDs,
              selectionMode: selectionMode,
              selectedCount: selectedCount,
              onTap: onTap,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          )
        : GroupManageList(
            groups: groups,
            selectedUUIDs: selectedUUIDs,
            selectionMode: selectionMode,
            selectedCount: selectedCount,
            onTap: onTap,
            onEdit: onEdit,
            onDelete: onDelete,
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
