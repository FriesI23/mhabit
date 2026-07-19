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

import '../../../common/types.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../widgets/widgets.dart';
import '../helpers.dart';

/// Shows a confirmation dialog before executing batch group modification.
///
/// The dialog dynamically adapts its content based on the types of changes:
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
/// checkbox. [onSkipFutureChanged] is called when the checkbox is toggled.
Future<bool> showHabitGroupModifyConfirmDialog({
  required BuildContext context,
  required List<HabitGroupModifyItem> affectedHabits,
  required GroupUUID? targetGroupId,
  required String? targetGroupName,
  required Map<String?, List<HabitGroupModifyItem>> sourceGroups,
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

  // Track skip value locally; only persist on confirm.
  var skipValue = skipFutureEnabled;

  final result = await showConfirmDialog(
    context: context,
    title: Text(title),
    subtitleBuilder: (context) => HabitGroupModifyConfirmContent(
      affectedHabits: affectedHabits,
      addCount: addCount,
      changeCount: changeCount,
      removeCount: removeCount,
      sourceGroups: sourceGroups,
      targetGroupId: targetGroupId,
      targetGroupName: targetGroupName,
      isMixed: isMixed,
    ),
    confirmTextBuilder: (context) {
      final l10n = L10n.of(context);
      return Text(l10n?.confirmDialog_confirm_text('confirm') ?? 'Confirm');
    },
    cancelTextBuilder: (context) {
      final l10n = L10n.of(context);
      return Text(l10n?.confirmDialog_cancel_text ?? 'Cancel');
    },
    skipOnConfirm: true,
    skipInitiallyEnabled: skipFutureEnabled,
    onSkipChanged: (v) {
      skipValue = v;
    },
  );

  if (result == true) {
    onSkipFutureChanged(skipValue);
  }

  return result ?? false;
}

class HabitGroupModifyConfirmContent extends StatelessWidget {
  final List<HabitGroupModifyItem> affectedHabits;
  final int addCount;
  final int changeCount;
  final int removeCount;
  final Map<String?, List<HabitGroupModifyItem>> sourceGroups;
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
    final brightness = Theme.of(context).brightness;
    final noChanges = addCount == 0 && changeCount == 0 && removeCount == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (noChanges)
          _buildNoChangesMessage(context)
        else ...[
          _StatSection(
            addCount: addCount,
            changeCount: changeCount,
            removeCount: removeCount,
            targetGroupId: targetGroupId,
            targetGroupName: targetGroupName,
            sourceNames: sourceGroups.keys.nonNulls.join(', '),
          ),
          const SizedBox(height: 8),
          _buildSourceGroupLists(context, brightness),
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

  Widget _buildSourceGroupLists(BuildContext context, Brightness brightness) {
    final entries = sourceGroups.entries.toList();
    if (entries.isEmpty) {
      return _buildHabitChipList(context, affectedHabits, brightness);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in entries) ...[
              if (entry.key != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Text(
                    entry.key!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              _buildHabitChipList(
                context,
                entry.value,
                brightness,
                indent: entry.key != null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHabitChipList(
    BuildContext context,
    List<HabitGroupModifyItem> habits,
    Brightness brightness, {
    bool indent = false,
  }) {
    final names = habits.map((h) => h.name).toList();
    final colors = <Color?>[];
    for (final h in habits) {
      if (h.color != null) {
        final customColors = Theme.of(context).extension<CustomColors>();
        colors.add(customColors?.getColor(h.color!, brightness: brightness));
      } else {
        colors.add(null);
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: indent ? 12 : 0),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: [
          for (final (i, name) in names.indexed)
            Text(
              name,
              style: colors[i] != null ? TextStyle(color: colors[i]) : null,
            ),
        ],
      ),
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
  });

  final int addCount;
  final int changeCount;
  final int removeCount;
  final GroupUUID? targetGroupId;
  final String? targetGroupName;
  final String sourceNames;

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
