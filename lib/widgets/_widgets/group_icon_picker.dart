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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

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
    final content = switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialGroupIconPicker(
        selectedIcon: selectedIcon,
        resolvedColor: resolvedColor,
        onSelected: onSelected,
      ),
      AdaptiveStyle.apple => _AppleGroupIconPicker(
        selectedIcon: selectedIcon,
        resolvedColor: resolvedColor,
        onSelected: onSelected,
      ),
    };
    return AdaptiveListSection(
      header: Text(L10n.of(context)?.groupManage_icon_label ?? 'Icon'),
      padding: const EdgeInsetsDirectional.only(top: 24, bottom: 8),
      children: [content],
    );
  }
}

class _MaterialGroupIconPicker extends StatelessWidget {
  const _MaterialGroupIconPicker({
    required this.selectedIcon,
    required this.resolvedColor,
    required this.onSelected,
  });

  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final ValueChanged<GroupIcon?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icons = <GroupIcon?>[null, ...GroupIcon.values];
    final defaultColor = theme.colorScheme.onSurfaceVariant;
    final effectiveTint = resolvedColor ?? defaultColor;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.center,
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
    );
  }
}

class _AppleGroupIconPicker extends StatelessWidget {
  const _AppleGroupIconPicker({
    required this.selectedIcon,
    required this.resolvedColor,
    required this.onSelected,
  });

  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final ValueChanged<GroupIcon?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final icons = <GroupIcon?>[null, ...GroupIcon.values];
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final primary = theme.primaryColor;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final icon in icons)
            _AppleGroupIconButton(
              icon: icon,
              selected: icon == selectedIcon,
              color: resolvedColor ?? secondary,
              selectionColor: primary,
              onPressed: () => onSelected(icon),
            ),
        ],
      ),
    );
  }
}

class _AppleGroupIconButton extends StatelessWidget {
  const _AppleGroupIconButton({
    required this.icon,
    required this.selected,
    required this.color,
    required this.selectionColor,
    required this.onPressed,
  });

  final GroupIcon? icon;
  final bool selected;
  final Color color;
  final Color selectionColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? selectionColor.withValues(alpha: 0.15)
            : CupertinoColors.tertiarySystemFill.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: selectionColor, width: 2) : null,
      ),
      child: SizedBox.square(
        dimension: 44,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Icon(
            icon?.iconData ?? CupertinoIcons.nosign,
            color: selected ? selectionColor : color,
          ),
        ),
      ),
    );
    return icon == null
        ? Tooltip(
            message: L10n.of(context)?.groupManage_icon_none ?? 'None',
            child: button,
          )
        : button;
  }
}
