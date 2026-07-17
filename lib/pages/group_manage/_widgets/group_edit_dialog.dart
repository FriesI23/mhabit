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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/rules.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_color_type.dart';
import '../../../models/habit_group.dart';
import '../../../providers/app_ui/custom_color_history.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../widgets/rules.dart';
import '../../../widgets/widgets.dart';

/// Form-only result returned by [showGroupEditDialog].
///
/// The dialog does **not** persist anything — the caller owns
/// the save + event-broadcast responsibility.
class GroupEditFormResult {
  final String name;
  final String? desc;
  final GroupIcon? icon;
  final HabitColor? color;

  const GroupEditFormResult({
    required this.name,
    this.desc,
    this.icon,
    this.color,
  });
}

/// Shows an adaptive content sheet (or dialog on wide screens) for
/// creating/editing a Group.
///
/// Returns the form values when the user taps Save, or `null` on cancel.
/// The dialog performs only validation — the caller is responsible for
/// persisting the result and broadcasting change events.
Future<GroupEditFormResult?> showGroupEditDialog({
  required BuildContext context,
  HabitGroupData? existingGroup,
  bool forceSheet = false,
  bool forceDialog = false,
}) async {
  assert(
    !(forceSheet && forceDialog),
    'forceSheet and forceDialog cannot both be true',
  );
  final isCreate = existingGroup == null;
  final l10n = L10n.of(context);
  final formKey = GlobalKey<_GroupEditFormState>();
  return showAdaptiveContentSheet<GroupEditFormResult>(
    context: context,
    showCloseButton: false,
    forceSheet: forceSheet,
    forceDialog: forceDialog,
    title: Text(
      isCreate
          ? (l10n?.groupManage_createDialog_title ?? 'Create Group')
          : (l10n?.groupManage_editDialog_title ?? 'Edit Group'),
    ),
    actionsBuilder: (context, isDialog) => isDialog
        ? [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop<GroupEditFormResult?>(null),
              child: Text(l10n?.groupManage_deleteDialog_cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => formKey.currentState?._onSave(),
              child: Text(l10n?.habitEdit_saveButton_text ?? 'Save'),
            ),
          ]
        : [
            TextButton(
              onPressed: () => formKey.currentState?._onSave(),
              child: Text(l10n?.habitEdit_saveButton_text ?? 'Save'),
            ),
          ],
    contentBuilder: (context) =>
        GroupEditForm(key: formKey, existingGroup: existingGroup),
  );
}

class GroupEditForm extends StatefulWidget {
  final HabitGroupData? existingGroup;

  const GroupEditForm({super.key, this.existingGroup});

  @override
  State<GroupEditForm> createState() => _GroupEditFormState();
}

class _GroupEditFormState extends State<GroupEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  GroupIcon? _selectedIcon;
  HabitColor? _selectedColor;

  /// Remembers the most recently picked custom color so the custom entry
  /// shows a preview even when [_selectedColor] is currently a built-in.
  HabitColor? _lastCustomColor;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingGroup;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _descCtrl = TextEditingController(text: existing?.desc ?? '');
    _selectedIcon = existing?.icon;
    _selectedColor = existing?.color;
    if (existing?.color case final CustomHabitColor c) _lastCustomColor = c;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) return;

    Navigator.of(context).pop(
      GroupEditFormResult(
        name: _nameCtrl.text.trim(),
        desc: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameCtrl,
            maxLength: groupNameRule.hardLimit,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) {
                return l10n?.groupManage_nameRequired ?? 'Name is required';
              }
              if (trimmed.length > groupNameRule.softLimit) {
                return l10n?.groupManage_nameTooLong(groupNameRule.softLimit) ??
                    'Name must be ≤ ${groupNameRule.softLimit} characters';
              }
              return null;
            },
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descCtrl,
            maxLength: groupDescRule.softLimit,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            inputFormatters: [groupDescRule.hardLimitFormatter],
            buildCounter: groupDescRule.buildSoftLimitCounter,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.length > groupDescRule.softLimit) {
                return l10n?.groupManage_descTooLong(groupDescRule.softLimit) ??
                    'Description should be ≤ ${groupDescRule.softLimit} characters';
              }
              return null;
            },
            minLines: 1,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _GroupIconPicker(
            selectedIcon: _selectedIcon,
            resolvedColor: _selectedColor != null
                ? Theme.of(context).extension<CustomColors>()?.getColor(
                    _selectedColor!,
                    brightness: Theme.of(context).brightness,
                  )
                : null,
            onSelected: (icon) => setState(() => _selectedIcon = icon),
          ),
          const SizedBox(height: 16),
          _GroupColorPicker(
            selectedColor: _selectedColor,
            lastCustomColor: _lastCustomColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
            onCustomColorTap: _openCustomColorPicker,
          ),
        ],
      ),
    );
  }

  Future<void> _openCustomColorPicker() async {
    final history = context.read<CustomColorHistoryViewModel>().history;
    final seedColor = switch (_selectedColor) {
      CustomHabitColor(argb: final v) => Color(v),
      _ => appDefaultThemeMainColor,
    };
    final seedTinted = switch (_selectedColor) {
      CustomHabitColor(tinted: final t) => t,
      _ => true,
    };

    final selected = await showDialog<HabitColor>(
      context: context,
      builder: (_) => _CustomColorPickerDialog(
        seedColor: seedColor,
        seedTinted: seedTinted,
        history: history,
      ),
    );

    if (selected != null && mounted) {
      if (selected is CustomHabitColor) {
        context.read<CustomColorHistoryViewModel>().recordUsage(selected);
      }
      setState(() {
        _selectedColor = selected;
        if (selected is CustomHabitColor) _lastCustomColor = selected;
      });
    }
  }
}

class _GroupColorPicker extends StatelessWidget {
  final HabitColor? selectedColor;
  final HabitColor? lastCustomColor;
  final ValueChanged<HabitColor?> onColorSelected;
  final VoidCallback onCustomColorTap;

  const _GroupColorPicker({
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
          'Color',
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
              final background =
                  resolvedColor ?? theme.colorScheme.outlineVariant;
              final onColor = color != null && customColors != null
                  ? customColors.getOnColor(color, brightness: theme.brightness)
                  : null;
              final tooltip = color != null
                  ? HabitColorType.getColorName(
                      (color as BuiltInHabitColor).colorType,
                      L10n.of(context),
                    )
                  : 'None';
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

class _GroupIconPicker extends StatelessWidget {
  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final ValueChanged<GroupIcon?> onSelected;

  const _GroupIconPicker({
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
          'Icon',
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
              tooltip: icon == null ? 'None' : null,
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

/// Modal content for the custom-color wheel dialog.
///
/// Pops with the selected [HabitColor] when the user confirms (OK or taps a
/// history swatch), or `null` on cancel.
class _CustomColorPickerDialog extends StatefulWidget {
  final Color seedColor;
  final bool seedTinted;
  final List<CustomHabitColor> history;

  const _CustomColorPickerDialog({
    required this.seedColor,
    required this.seedTinted,
    required this.history,
  });

  @override
  State<_CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
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
