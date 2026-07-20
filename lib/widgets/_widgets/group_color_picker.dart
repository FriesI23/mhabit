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

import '../../extensions/custom_color_extensions.dart';
import '../../l10n/localizations.dart';
import '../../models/habit_color.dart';
import '../../models/habit_color_type.dart';
import '../../theme/color.dart' show CustomColors;
import 'color_swatch_button.dart';
import 'habit_color_wheel_editor.dart';

/// A horizontal wrap of built-in color swatches plus a custom-color entry.
///
/// [onCustomColorTap] is called when the user taps the custom-color entry;
/// the caller should open a dialog (typically [GroupCustomColorPickerDialog])
/// and call [onColorSelected] with the result.
///
/// [lastCustomColor] provides a preview colour for the custom entry when
/// [selectedColor] is not itself a [CustomHabitColor].
class GroupColorPicker extends StatelessWidget {
  final HabitColor? selectedColor;
  final HabitColor? lastCustomColor;
  final ValueChanged<HabitColor?> onColorSelected;
  final VoidCallback onCustomColorTap;

  const GroupColorPicker({
    super.key,
    required this.selectedColor,
    required this.lastCustomColor,
    required this.onColorSelected,
    required this.onCustomColorTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();
    final builtInColors = <HabitColor?>[
      null, // "No color"
      ...HabitColorType.values.map(HabitColor.builtIn),
    ];

    final customColorSelected =
        selectedColor != null && selectedColor is CustomHabitColor;
    final effectiveCustomColor = customColorSelected
        ? selectedColor!
        : lastCustomColor;

    Widget buildCustomEntry() {
      final effective = effectiveCustomColor;
      final resolvedColor = effective != null && customColors != null
          ? customColors.getColor(effective, brightness: theme.brightness)
          : null;
      final onColor = effective != null && customColors != null
          ? customColors.getOnColor(effective, brightness: theme.brightness)
          : null;
      final gradientFrom = effective is CustomHabitColor
          ? Color(effective.argb)
          : null;
      final iconColor = onColor ?? theme.colorScheme.onSurfaceVariant;
      final background =
          resolvedColor ?? theme.colorScheme.surfaceContainerHighest;
      return Stack(
        alignment: Alignment.center,
        children: [
          ColorSwatchButton(
            background: background,
            onColor: iconColor,
            gradientFrom: gradientFrom,
            selected: customColorSelected,
            onTap: onCustomColorTap,
            size: 32,
          ),
          IgnorePointer(
            child: Icon(
              customColorSelected ? Icons.edit : Icons.add,
              size: 18,
              color: iconColor,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          L10n.of(context)?.groupManage_color_label ?? 'Color',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...builtInColors.map((color) {
              final isSelected = color == selectedColor;
              final resolvedColor = color != null && customColors != null
                  ? customColors.getColor(color, brightness: theme.brightness)
                  : null;
              final background = color != null
                  ? (resolvedColor ?? theme.colorScheme.outlineVariant)
                  : theme.colorScheme.primary;
              final onColor = color != null && customColors != null
                  ? customColors.getOnColor(color, brightness: theme.brightness)
                  : null;
              final tooltip = color != null
                  ? HabitColorType.getColorName(
                      (color as BuiltInHabitColor).colorType,
                      L10n.of(context),
                    )
                  : (L10n.of(context)?.groupManage_color_none ?? 'None');
              return ColorSwatchButton(
                background: background,
                onColor: onColor ?? theme.colorScheme.onSurfaceVariant,
                selected: isSelected,
                onTap: () => onColorSelected(color),
                tooltip: tooltip,
              );
            }),
            buildCustomEntry(),
          ],
        ),
      ],
    );
  }
}

/// Modal dialog for picking a custom [HabitColor] via a colour wheel.
///
/// Accepts [history] — a list of previously used custom colours shown as
/// quick-select swatches.  Pops with the selected [HabitColor] when the
/// user taps OK or a history swatch, or `null` on cancel.
class GroupCustomColorPickerDialog extends StatefulWidget {
  final Color seedColor;
  final bool seedTinted;
  final List<CustomHabitColor> history;

  const GroupCustomColorPickerDialog({
    super.key,
    required this.seedColor,
    required this.seedTinted,
    required this.history,
  });

  @override
  State<GroupCustomColorPickerDialog> createState() =>
      _GroupCustomColorPickerDialogState();
}

class _GroupCustomColorPickerDialogState
    extends State<GroupCustomColorPickerDialog> {
  HabitColor? _draft;

  void _commit(HabitColor color) => Navigator.of(context).pop(color);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>();

    return AlertDialog(
      title: l10n != null ? Text(l10n.habitEdit_colorPicker_title) : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HabitColorWheelEditor(
              initialColor: widget.seedColor,
              initialTinted: widget.seedTinted,
              onChanged: (color) => setState(() => _draft = color),
            ),
            if (widget.history.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.habitEdit_colorPicker_historySectionLabel ?? 'Recent',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.history.map((entry) {
                  final resolved =
                      customColors?.getColor(
                        entry,
                        brightness: theme.brightness,
                      ) ??
                      Color(entry.argb);
                  final onColor = customColors?.getOnColor(
                    entry,
                    brightness: theme.brightness,
                  );
                  return ColorSwatchButton(
                    background: resolved,
                    onColor: onColor,
                    gradientFrom: entry.tinted ? Color(entry.argb) : null,
                    onTap: () => _commit(entry),
                    size: 32,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n?.habitEdit_colorPicker_cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_draft),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
