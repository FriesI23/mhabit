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

import '../../../common/types.dart';
import '../../../l10n/localizations.dart';
import '../../common/widgets.dart';
import '../helpers.dart';

/// Pushes a confirmation page before executing batch group modification.
///
/// The page dynamically adapts its content based on the types of changes:
/// - Pure new group assignment (all habits were uncategorized).
/// - Mixed changes (some habits change group, some are new, some removed).
/// - Pure removal (all habits are being uncategorized).
///
/// Returns `true` when the user confirms, `false` on cancel.
///
/// Idempotency is guaranteed by the caller: only habits with actual group
/// changes are submitted, so the confirm button is always enabled.
///
/// [skipFutureEnabled] controls the initial state of the "don't show again"
/// checkbox. [onSkipFutureChanged] is called only after confirmation.
Future<bool> pushHabitGroupModifyConfirmPage({
  required BuildContext context,
  required List<HabitGroupModifyItem> affectedHabits,
  required GroupUUID? targetGroupId,
  required String? targetGroupName,
  required Map<GroupUUID, List<HabitGroupModifyItem>> sourceGroups,
  required bool skipFutureEnabled,
  required ValueChanged<bool> onSkipFutureChanged,
}) async {
  final l10n = L10n.of(context);

  var addCount = 0;
  var changeCount = 0;
  var removeCount = 0;

  for (final h in affectedHabits) {
    if (h.oldGroupId == null && targetGroupId != null) {
      addCount++;
    } else if (h.oldGroupId != null &&
        targetGroupId != null &&
        h.oldGroupId != targetGroupId) {
      changeCount++;
    } else if (h.oldGroupId != null && targetGroupId == null) {
      removeCount++;
    }
  }

  final isMixed = changeCount > 0 || removeCount > 0;
  final title = targetGroupId == null || isMixed
      ? (l10n?.habitDisplay_groupModifyConfirm_titleMixed ?? 'Confirm Change')
      : (l10n?.habitDisplay_groupModifyConfirm_titleNew ?? 'Move to Group');

  final skipFuture = await Navigator.of(context).push<bool>(
    adaptiveModalPageRoute<bool>(
      context: context,
      builder: (_) => _HabitGroupModifyConfirmPage(
        title: title,
        affectedHabits: affectedHabits,
        addCount: addCount,
        changeCount: changeCount,
        removeCount: removeCount,
        sourceGroups: sourceGroups,
        targetGroupId: targetGroupId,
        targetGroupName: targetGroupName,
        isMixed: isMixed,
        skipFutureEnabled: skipFutureEnabled,
      ),
    ),
  );

  if (skipFuture != null) onSkipFutureChanged(skipFuture);

  return skipFuture != null;
}

class _HabitGroupModifyConfirmPage extends StatefulWidget {
  const _HabitGroupModifyConfirmPage({
    required this.title,
    required this.affectedHabits,
    required this.addCount,
    required this.changeCount,
    required this.removeCount,
    required this.sourceGroups,
    required this.targetGroupId,
    required this.targetGroupName,
    required this.isMixed,
    required this.skipFutureEnabled,
  });

  final String title;
  final List<HabitGroupModifyItem> affectedHabits;
  final int addCount;
  final int changeCount;
  final int removeCount;
  final Map<GroupUUID, List<HabitGroupModifyItem>> sourceGroups;
  final GroupUUID? targetGroupId;
  final String? targetGroupName;
  final bool isMixed;
  final bool skipFutureEnabled;

  @override
  State<_HabitGroupModifyConfirmPage> createState() =>
      _HabitGroupModifyConfirmPageState();
}

class _HabitGroupModifyConfirmPageState
    extends State<_HabitGroupModifyConfirmPage> {
  late bool _skipFuture;

  @override
  void initState() {
    super.initState();
    _skipFuture = widget.skipFutureEnabled;
  }

  void _confirm() => Navigator.of(context).pop(_skipFuture);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveModal.slivers(
      title: Text(widget.title),
      confirmAction: AdaptiveModalConfirmAction(
        label: l10n?.confirmDialog_confirm_text('confirm') ?? 'Confirm',
        onPressed: _confirm,
      ),
      automaticallyImplyLeading: true,
      automaticallyImplyCloseButton: false,
      slivers: [
        HabitGroupModifyConfirmContent(
          affectedHabits: widget.affectedHabits,
          addCount: widget.addCount,
          changeCount: widget.changeCount,
          removeCount: widget.removeCount,
          sourceGroups: widget.sourceGroups,
          targetGroupId: widget.targetGroupId,
          targetGroupName: widget.targetGroupName,
          isMixed: widget.isMixed,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: AdaptiveListSection(
            padding: EdgeInsets.zero,
            children: [
              AdaptiveSwitchListTile(
                title: Text(l10n?.common_dontShowAgain ?? "Don't show again"),
                value: _skipFuture,
                onChanged: (value) => setState(() => _skipFuture = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sliver content sharing the modal scroll viewport with its preview tree.
class HabitGroupModifyConfirmContent extends StatelessWidget {
  final List<HabitGroupModifyItem> affectedHabits;
  final int addCount;
  final int changeCount;
  final int removeCount;
  final Map<GroupUUID, List<HabitGroupModifyItem>> sourceGroups;
  final GroupUUID? targetGroupId;
  final String? targetGroupName;
  final bool isMixed;

  const HabitGroupModifyConfirmContent({
    super.key,
    required this.affectedHabits,
    required this.addCount,
    required this.changeCount,
    required this.removeCount,
    required this.sourceGroups,
    this.targetGroupId,
    this.targetGroupName,
    required this.isMixed,
  });

  @override
  Widget build(BuildContext context) {
    final sourceNames = sourceGroups.values
        .map((habits) => habits.first.oldGroupName)
        .nonNulls
        .toList();
    final visibleNames = sourceNames.take(3).join(', ');
    final noChanges = addCount == 0 && changeCount == 0 && removeCount == 0;

    return SliverMainAxisGroup(
      slivers: [
        if (noChanges)
          SliverToBoxAdapter(child: _buildNoChangesMessage(context))
        else ...[
          SliverToBoxAdapter(
            child: _StatSection(
              addCount: addCount,
              changeCount: changeCount,
              removeCount: removeCount,
              targetGroupId: targetGroupId,
              targetGroupName: targetGroupName,
              sourceNames: visibleNames,
              remainingGroupCount: sourceNames.skip(3).length,
              totalGroupCount: sourceNames.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          _buildGroupPreview(context),
        ],
      ],
    );
  }

  Widget _buildNoChangesMessage(BuildContext context) {
    final l10n = L10n.of(context);
    return Text(
      l10n?.habitDisplay_groupModifyDialog_alreadyInGroup ??
          'Selected habits are already in this group',
    );
  }

  Widget _buildGroupPreview(BuildContext context) {
    final l10n = L10n.of(context);
    final groups = <GroupUUID?, List<HabitGroupModifyItem>>{};
    for (final habit in affectedHabits) {
      groups.putIfAbsent(habit.oldGroupId, () => []).add(habit);
    }
    return SliverHabitGroupTree(
      treeKey: const ValueKey('group-modify-preview-tree'),
      expansionToggleKey: const ValueKey('group-modify-preview-toggle'),
      root: HabitGroupTreeEntry(
        id: 'group-modify-preview',
        title: Text(
          l10n?.habitDisplay_groupModifyConfirm_previewTitle ?? 'Preview',
        ),
      ),
      groups: [
        for (final (index, entry) in groups.entries.indexed)
          HabitGroupTreeEntry(
            id: entry.key == null
                ? 'group-modify-preview-ungrouped'
                : 'group-modify-preview-group-${entry.key}',
            title: Text(
              '${entry.value.first.oldGroupName ?? (entry.key == null ? (l10n?.habitEdit_groupPicker_noGroup ?? 'No Group') : '#${index + 1}')} (${entry.value.length})',
            ),
            color: entry.value.first.oldGroupColor,
            icon: entry.value.first.oldGroupIcon,
            isUngrouped: entry.key == null,
            children: [
              for (final habit in entry.value)
                HabitGroupTreeEntry(
                  id: 'group-modify-preview-habit-${habit.uuid}',
                  title: Text(habit.name),
                  color: habit.color,
                ),
            ],
          ),
      ],
    );
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({
    required this.addCount,
    required this.changeCount,
    required this.removeCount,
    this.targetGroupId,
    this.targetGroupName,
    required this.sourceNames,
    required this.remainingGroupCount,
    required this.totalGroupCount,
  });

  final int addCount;
  final int changeCount;
  final int removeCount;
  final GroupUUID? targetGroupId;
  final String? targetGroupName;
  final String sourceNames;
  final int remainingGroupCount;
  final int totalGroupCount;

  bool get _hasChangesToGroup => changeCount > 0 && targetGroupId != null;
  bool get _hasAdditionsToGroup => addCount > 0 && targetGroupId != null;
  bool get _hasRemovals => removeCount > 0;
  bool get _isPureAddition =>
      addCount > 0 &&
      changeCount == 0 &&
      removeCount == 0 &&
      targetGroupId != null;
  bool get _isPureRemoval =>
      removeCount > 0 && changeCount == 0 && addCount == 0;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasChangesToGroup)
          _buildStatLine(
            l10n?.habitDisplay_groupModifyConfirm_bodyChangeStat(
                  changeCount,
                  sourceNames,
                  targetGroupName ?? '',
                  remainingGroupCount,
                  totalGroupCount,
                ) ??
                '',
          ),
        if (_hasAdditionsToGroup)
          _buildStatLine(
            l10n?.habitDisplay_groupModifyConfirm_bodyAddStat(
                  addCount,
                  targetGroupName ?? '',
                ) ??
                '',
          ),
        if (_hasRemovals)
          _buildStatLine(
            l10n?.habitDisplay_groupModifyConfirm_bodyRemoveStat(removeCount) ??
                '',
          ),
        if (_isPureAddition)
          _buildStatLine(
            l10n?.habitDisplay_groupModifyConfirm_bodyNewGroup(
                  targetGroupName ?? '',
                ) ??
                '',
          ),
        if (_isPureRemoval)
          _buildStatLine(
            l10n?.habitDisplay_groupModifyConfirm_bodyRemoveGroup ?? '',
          ),
      ],
    );
  }

  Widget _buildStatLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }
}
