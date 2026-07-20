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

import '../../extensions/group_icon_extensions.dart';
import '../../l10n/localizations.dart';
import '../../models/habit_group.dart';

/// A horizontal wrap of tappable icon buttons for selecting a [GroupIcon].
///
/// Callers control the current selection and tint via [selectedIcon] and
/// [resolvedColor]; [onSelected] fires when the user taps an icon.
/// Pass `null` to [selectedIcon] to render the "no icon" placeholder as
/// selected.
class GroupIconPicker extends StatelessWidget {
  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final ValueChanged<GroupIcon?> onSelected;

  const GroupIconPicker({
    super.key,
    required this.selectedIcon,
    required this.resolvedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icons = <GroupIcon?>[null, ...GroupIcon.values];
    final defaultColor = theme.colorScheme.onSurfaceVariant;
    final effectiveTint = resolvedColor ?? defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          L10n.of(context)?.groupManage_icon_label ?? 'Icon',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            final isSelected = icon == selectedIcon;
            return IconButton(
              onPressed: () => onSelected(icon),
              icon: Icon(icon?.iconData ?? Icons.block),
              isSelected: isSelected,
              tooltip: icon == null
                  ? (L10n.of(context)?.groupManage_icon_none ?? 'None')
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                foregroundColor: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : effectiveTint,
                fixedSize: const Size.square(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide(color: theme.colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
