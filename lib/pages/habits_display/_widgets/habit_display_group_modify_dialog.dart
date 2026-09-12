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

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/types.dart';
import '../../../extensions/async_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_summary.dart';
import '../../../pages/common/widgets.dart';
import '../../../providers/app_ui/app_caches.dart';
import '../../../providers/app_ui/custom_color_history.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/group_manager.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../widgets/provider.dart';
import '../_providers/habit_group_modify.dart';
import '../helpers.dart';
import 'habit_display_group_modify_confirm_dialog.dart';

sealed class GroupModifySelectorResult {
  const GroupModifySelectorResult();
}

final class GroupModifySelectorCancelled extends GroupModifySelectorResult {
  const GroupModifySelectorCancelled();
}

final class GroupModifySelectorRemoveGroup extends GroupModifySelectorResult {
  const GroupModifySelectorRemoveGroup();
}

final class GroupModifySelectorSelected extends GroupModifySelectorResult {
  final GroupUUID? groupId;
  final List<HabitGroupModifyItem> affectedHabits;
  final String? targetGroupName;

  const GroupModifySelectorSelected(
    this.groupId, {
    this.affectedHabits = const [],
    this.targetGroupName,
  });
}

const kGroupModifySelectorCancelled = GroupModifySelectorCancelled();
const kGroupModifySelectorRemoveGroup = GroupModifySelectorRemoveGroup();

/// Shows an adaptive content sheet (or dialog on wide screens) for selecting
/// a target group for habit batch group modification.
///
/// Uses modal-local page navigation between group selection and creation.
///
/// VM lifecycle is managed entirely in the widget tree via
/// [_GroupModifySelectorScope]: [ChangeNotifierProvider] creates the VM,
/// [ViewModelProxyProvider] wires dependencies, and disposal is automatic.
Future<GroupModifySelectorResult?> showHabitGroupModifySelector({
  required BuildContext context,
  required List<HabitSummaryData> selectedHabitsData,
}) => showAdaptiveSheet<GroupModifySelectorResult?>(
  context: context,
  // TODO(mhabit): Remove the forced Material style after the group selector
  // and its controls have Cupertino renderers.
  styleOverride: AdaptiveStyle.material,
  builder: (_) => _GroupModifySelectorScope(
    selectedData: selectedHabitsData,
    bodyBuilder: (_) => AdaptiveModalNavigator<GroupModifySelectorResult?>(
      builder: (_) => const _GroupInitLoader(child: _GroupModifySelectPage()),
    ),
  ),
);

class _GroupModifySelectPage extends StatelessWidget {
  const _GroupModifySelectPage();

  Future<void> _handleConfirm(
    BuildContext context,
    HabitGroupModifyViewModel vm,
  ) async {
    if (!vm.isTwoStep) {
      AdaptiveModalNavigator.pop<GroupModifySelectorResult?>(
        context,
        vm.selectedGroupId != null
            ? GroupModifySelectorSelected(vm.selectedGroupId!)
            : kGroupModifySelectorRemoveGroup,
      );
      return;
    }

    if (vm.sourceGroups.isNotEmpty && !vm.skipConfirm) {
      final confirmed = await showHabitGroupModifyConfirmDialog(
        context: context,
        affectedHabits: vm.affectedHabits,
        targetGroupId: vm.selectedGroupId,
        targetGroupName: vm.targetGroupName,
        sourceGroups: vm.sourceGroups,
        skipFutureEnabled: vm.skipConfirm,
        onSkipFutureChanged: vm.toggleSkipConfirm,
      );
      if (!(context.mounted && confirmed)) return;
    }

    AdaptiveModalNavigator.pop<GroupModifySelectorResult?>(
      context,
      GroupModifySelectorSelected(
        vm.selectedGroupId,
        affectedHabits: vm.affectedHabits,
        targetGroupName: vm.targetGroupName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final vm = context.watch<HabitGroupModifyViewModel>();

    return AdaptiveModal(
      title: Text(l10n?.habitDisplay_groupModifyDialog_title ?? 'Modify Group'),
      actions: [
        TextButton(
          onPressed: () =>
              AdaptiveModalNavigator.pop<GroupModifySelectorResult?>(
                context,
                kGroupModifySelectorCancelled,
              ),
          child: Text(l10n?.confirmDialog_cancel_text ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => _handleConfirm(context, vm),
          child: Text(l10n?.confirmDialog_confirm_text('confirm') ?? 'Confirm'),
        ),
      ],
      automaticallyImplyCloseButton: false,
      body: const _GroupModifySelectContent(),
    );
  }
}

class _GroupModifyCreatePage extends StatefulWidget {
  const _GroupModifyCreatePage();

  @override
  State<_GroupModifyCreatePage> createState() => _GroupModifyCreatePageState();
}

class _GroupModifyCreatePageState extends State<_GroupModifyCreatePage> {
  final _formKey = GlobalKey<GroupEditFormState>();

  Future<void> _handleSaveOnly(HabitGroupModifyViewModel vm) async {
    final result = _formKey.currentState?.buildResult();
    if (result == null) return;
    final route = ModalRoute.of(context);
    await vm.createGroup(
      name: result.name,
      desc: result.desc,
      icon: result.icon,
      color: result.color,
    );
    // A popped page remains mounted until its exit transition finishes.
    // Do not pop the selector if the user already left this page while saving.
    if (!mounted || route?.isCurrent != true) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleSaveAndApply(HabitGroupModifyViewModel vm) async {
    final result = _formKey.currentState?.buildResult();
    if (result == null) return;

    final handler = HabitGroupModifyHandler.forNewGroup(
      selectedData: vm.selectedData,
      getGroupName: vm.getGroupName,
    );
    if (!vm.skipConfirm) {
      final confirmed = await showHabitGroupModifyConfirmDialog(
        context: context,
        affectedHabits: handler.affectedHabits,
        targetGroupId: handler.targetGroupId,
        targetGroupName: result.name,
        sourceGroups: handler.sourceGroups,
        skipFutureEnabled: vm.skipConfirm,
        onSkipFutureChanged: vm.toggleSkipConfirm,
      );
      if (!(mounted && confirmed)) return;
    }

    final group = await vm.createGroup(
      name: result.name,
      desc: result.desc,
      icon: result.icon,
      color: result.color,
    );
    if (!mounted) return;
    AdaptiveModalNavigator.pop<GroupModifySelectorResult?>(
      context,
      GroupModifySelectorSelected(
        group.uuid,
        affectedHabits: handler.affectedHabits,
        targetGroupName: group.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final vm = context.watch<HabitGroupModifyViewModel>();
    final colorHistory = context.read<CustomColorHistoryViewModel>().history;

    return AdaptiveModal(
      title: Text(l10n?.groupManage_createDialog_title ?? 'Create Group'),
      actions: [
        TextButton(
          onPressed: () => _handleSaveOnly(vm),
          child: Text(l10n?.habitEdit_saveButton_text ?? 'Save'),
        ),
        FilledButton(
          onPressed: () => _handleSaveAndApply(vm),
          child: Text(
            l10n?.habitDisplay_groupModifyDialog_saveAndApply ?? 'Save & Apply',
          ),
        ),
      ],
      automaticallyImplyLeading: true,
      automaticallyImplyCloseButton: false,
      body: GroupEditForm(
        key: _formKey,
        customColorHistory: colorHistory,
        onRecordCustomColor: (color) {
          context.read<CustomColorHistoryViewModel>().recordUsage(color);
        },
      ),
    );
  }
}

/// Manages [HabitGroupModifyViewModel] lifecycle with standard Provider
/// wiring (mirrors [group_manage]'s [PageProviders]).
///
/// [ChangeNotifierProvider] creates the VM, [ViewModelProxyProvider] wires
/// [GroupManager] / [AppCachesViewModel] / [AppEventBus], and [bodyBuilder]
/// is called from inside the Provider tree via [Builder] so both
/// [contentBuilder] and [actionsBuilder] receive a context with VM access.
class _GroupModifySelectorScope extends StatelessWidget {
  final List<HabitSummaryData> selectedData;
  final WidgetBuilder bodyBuilder;

  const _GroupModifySelectorScope({
    required this.selectedData,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HabitGroupModifyViewModel>(
          create: (_) => HabitGroupModifyViewModel(selectedData: selectedData),
        ),
        ViewModelProxyProvider<GroupManager, HabitGroupModifyViewModel>(
          update: (_, gm, vm) => vm..attachGroupManager(gm),
        ),
        ViewModelProxyProvider<AppCachesViewModel, HabitGroupModifyViewModel>(
          update: (_, caches, vm) => vm..attachCaches(caches),
        ),
        ViewModelProxyProvider<AppEventBus, HabitGroupModifyViewModel>(
          update: (_, bus, vm) => vm..updateAppEvent(bus),
        ),
      ],
      child: Builder(builder: bodyBuilder),
    );
  }
}

/// Triggers the initial [HabitGroupModifyViewModel.loadGroups] via
/// [FutureBuilder], using the same [Selector] + [FutureBuilder] pattern
/// as [_PageState] in [GroupManagePage].
class _GroupInitLoader extends StatefulWidget {
  final Widget? child;

  const _GroupInitLoader({this.child});

  @override
  State<_GroupInitLoader> createState() => _GroupInitLoaderState();
}

class _GroupInitLoaderState extends State<_GroupInitLoader> {
  Future<void> loadData() async {
    if (!mounted) return;
    final vm = context.read<HabitGroupModifyViewModel>();
    if (!(mounted && vm.mounted)) return;
    if (!vm.hasLoad) {
      await vm.loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HabitGroupModifyViewModel, (bool, bool)>(
      selector: (context, vm) => (vm.hasLoad, vm.consumeForceReloadFlag()),
      shouldRebuild: (previous, next) => previous.$1 != next.$1 || next.$2,
      builder: (context, _, child) => FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.isDone) {
            return const Center(child: CircularProgressIndicator());
          }
          return child!;
        },
      ),
      child: widget.child,
    );
  }
}

class _GroupModifySelectContent extends StatelessWidget {
  const _GroupModifySelectContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HabitGroupModifyViewModel>();
    final l10n = L10n.of(context);
    return RadioGroup<GroupUUID?>(
      groupValue: vm.selectedGroupId,
      onChanged: vm.selectGroup,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vm.groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n?.habitDisplay_groupModifyDialog_emptyGroups ??
                    'No groups available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...vm.groups.map((group) => _buildGroupTile(context, group)),
          const Divider(),
          _buildRemoveGroupTile(context),
          _buildCreateGroupButton(context),
        ],
      ),
    );
  }

  Widget _buildCreateGroupButton(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      leading: const Icon(Icons.add, size: 20),
      title: Text(
        l10n?.habitDisplay_groupModifyDialog_createGroup ?? 'Create Group',
      ),
      onTap: () => Navigator.of(context).push(
        adaptiveModalPageRoute<void>(
          context: context,
          builder: (_) => const _GroupModifyCreatePage(),
        ),
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, HabitGroupData group) {
    return RadioListTile<GroupUUID?>(
      value: group.uuid,
      title: Row(
        children: [
          Icon(
            group.icon?.iconData ?? defaultGroupIcon,
            size: 20,
            color: _resolveColor(context, group.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(group.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildRemoveGroupTile(BuildContext context) {
    final l10n = L10n.of(context);
    return RadioListTile<GroupUUID?>(
      value: null,
      title: Row(
        children: [
          const Icon(Icons.clear_rounded, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n?.habitDisplay_groupModifyDialog_removeGroup ??
                  'Remove Group',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color? _resolveColor(BuildContext context, HabitColor? color) {
    if (color == null) return null;
    final customColors = Theme.of(context).extension<CustomColors>();
    if (customColors == null) return null;
    return customColors.getColor(
      color,
      brightness: Theme.of(context).brightness,
    );
  }
}
