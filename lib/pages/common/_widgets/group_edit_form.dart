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
import 'package:flutter/services.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/rules.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/custom_date_format.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_group.dart';
import '../../../providers/app_ui/app_custom_date_format.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../theme/icon.dart';
import '../../../widgets/rules.dart';
import '../../../widgets/widgets.dart';

/// Form-only result returned by [GroupEditForm].
///
/// The form does **not** persist anything — the caller owns
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

/// A reusable form widget for creating or editing a Group.
///
/// Handles name/description validation ([groupNameRule], [groupDescRule]),
/// icon selection via [GroupIconPicker], and colour selection via
/// [GroupColorPicker] + [GroupCustomColorPickerDialog].
///
/// Callers provide [customColorHistory] and [onRecordCustomColor] so that
/// the form does not depend on any app-level provider.
///
/// When [onSave] is provided, [GroupEditFormState.save] calls it with the
/// form result instead of popping the navigator.  When [onSave] is `null`
/// (the default), [save] pops the navigator with [GroupEditFormResult].
class GroupEditForm extends StatefulWidget {
  final HabitGroupData? existingGroup;

  /// Previously used custom colours shown as quick-select swatches in the
  /// custom-colour dialog.
  final List<CustomHabitColor> customColorHistory;

  /// Called when the user picks a [CustomHabitColor] so the caller can
  /// persist it to history.
  final void Function(CustomHabitColor color)? onRecordCustomColor;

  /// When provided, [GroupEditFormState.save] delegates to this callback
  /// instead of popping the navigator.
  final void Function(GroupEditFormResult result)? onSave;

  const GroupEditForm({
    super.key,
    this.existingGroup,
    this.customColorHistory = const [],
    this.onRecordCustomColor,
    this.onSave,
  });

  @override
  State<GroupEditForm> createState() => GroupEditFormState();
}

class GroupEditFormState extends State<GroupEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  GroupIcon? _selectedIcon;
  HabitColor? _selectedColor;

  /// Remembers the most recently picked custom colour so the custom entry
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

  /// Validates the form and either calls [GroupEditForm.onSave] (when
  /// provided) or pops the navigator with [GroupEditFormResult].
  void save() {
    final result = buildResult();
    if (result == null) return;

    final onSave = widget.onSave;
    if (onSave != null) {
      onSave(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  /// Validates without side effects.  Returns `true` when the form is valid.
  bool validate() {
    final state = _formKey.currentState;
    return state != null && state.validate();
  }

  /// Builds the form result without popping.  Returns `null` when the form
  /// is not valid.
  GroupEditFormResult? buildResult() {
    if (!validate()) return null;
    return GroupEditFormResult(
      name: _nameCtrl.text.trim(),
      desc: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
    );
  }

  String? _validateName(String? value) {
    final l10n = L10n.of(context);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n?.groupManage_nameRequired ?? 'Name is required';
    }
    if (trimmed.length > groupNameRule.softLimit) {
      return l10n?.groupManage_nameTooLong(groupNameRule.softLimit) ??
          'Name must be ≤ ${groupNameRule.softLimit} characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final l10n = L10n.of(context);
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > groupDescRule.softLimit) {
      return l10n?.groupManage_descTooLong(groupDescRule.softLimit) ??
          'Description should be ≤ ${groupDescRule.softLimit} characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => _MaterialGroupEditForm(
          nameController: _nameCtrl,
          descriptionController: _descCtrl,
          nameValidator: _validateName,
          descriptionValidator: _validateDescription,
          selectedIcon: _selectedIcon,
          resolvedColor: _resolvedSelectedColor(context),
          selectedColor: _selectedColor,
          lastCustomColor: _lastCustomColor,
          existingGroup: widget.existingGroup,
          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
          onColorSelected: (color) => setState(() => _selectedColor = color),
          onCustomColorTap: _openCustomColorPicker,
        ),
        AdaptiveStyle.apple => _AppleGroupEditForm(
          nameController: _nameCtrl,
          descriptionController: _descCtrl,
          nameValidator: _validateName,
          descriptionValidator: _validateDescription,
          selectedIcon: _selectedIcon,
          resolvedColor: _resolvedSelectedColor(context),
          selectedColor: _selectedColor,
          lastCustomColor: _lastCustomColor,
          existingGroup: widget.existingGroup,
          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
          onColorSelected: (color) => setState(() => _selectedColor = color),
          onCustomColorTap: _openCustomColorPicker,
        ),
      },
    );
  }

  Color? _resolvedSelectedColor(BuildContext context) => _selectedColor != null
      ? Theme.of(context).extension<CustomColors>()?.getColor(
          _selectedColor!,
          brightness: Theme.of(context).brightness,
        )
      : null;

  Future<void> _openCustomColorPicker() async {
    final seedColor = switch (_selectedColor) {
      CustomHabitColor(argb: final v) => Color(v),
      _ => appDefaultThemeMainColor,
    };
    final seedTinted = switch (_selectedColor) {
      CustomHabitColor(tinted: final t) => t,
      _ => true,
    };

    final selected = await Navigator.of(context).push<HabitColor>(
      adaptiveModalPageRoute<HabitColor>(
        context: context,
        builder: (_) => GroupCustomColorPickerDialog(
          seedColor: seedColor,
          seedTinted: seedTinted,
          history: widget.customColorHistory,
        ),
      ),
    );

    if (selected != null && mounted) {
      if (selected is CustomHabitColor) {
        widget.onRecordCustomColor?.call(selected);
      }
      setState(() {
        _selectedColor = selected;
        if (selected is CustomHabitColor) _lastCustomColor = selected;
      });
    }
  }
}

class _MaterialGroupEditForm extends StatelessWidget {
  const _MaterialGroupEditForm({
    required this.nameController,
    required this.descriptionController,
    required this.nameValidator,
    required this.descriptionValidator,
    required this.selectedIcon,
    required this.resolvedColor,
    required this.selectedColor,
    required this.lastCustomColor,
    required this.existingGroup,
    required this.onIconSelected,
    required this.onColorSelected,
    required this.onCustomColorTap,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FormFieldValidator<String> nameValidator;
  final FormFieldValidator<String> descriptionValidator;
  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final HabitColor? selectedColor;
  final HabitColor? lastCustomColor;
  final HabitGroupData? existingGroup;
  final ValueChanged<GroupIcon?> onIconSelected;
  final ValueChanged<HabitColor?> onColorSelected;
  final VoidCallback onCustomColorTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: nameController,
          maxLength: groupNameRule.hardLimit,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          decoration: InputDecoration(
            labelText: l10n?.groupManage_name_label ?? 'Name',
          ),
          validator: nameValidator,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLength: groupDescRule.softLimit,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          inputFormatters: [groupDescRule.hardLimitFormatter],
          buildCounter: groupDescRule.buildSoftLimitCounter,
          decoration: InputDecoration(
            labelText: l10n?.groupManage_desc_label ?? 'Description',
          ),
          validator: descriptionValidator,
          minLines: 1,
          maxLines: 2,
        ),
        GroupIconPicker(
          selectedIcon: selectedIcon,
          resolvedColor: resolvedColor,
          onSelected: onIconSelected,
        ),
        GroupColorPicker(
          selectedColor: selectedColor,
          lastCustomColor: lastCustomColor,
          onColorSelected: onColorSelected,
          onCustomColorTap: onCustomColorTap,
        ),
        if (existingGroup != null) ...[
          const SizedBox(height: 12),
          const HabitDivider(),
          _ReadOnlyGroupInfo(group: existingGroup!),
        ],
      ],
    );
  }
}

class _AppleGroupEditForm extends StatelessWidget {
  const _AppleGroupEditForm({
    required this.nameController,
    required this.descriptionController,
    required this.nameValidator,
    required this.descriptionValidator,
    required this.selectedIcon,
    required this.resolvedColor,
    required this.selectedColor,
    required this.lastCustomColor,
    required this.existingGroup,
    required this.onIconSelected,
    required this.onColorSelected,
    required this.onCustomColorTap,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FormFieldValidator<String> nameValidator;
  final FormFieldValidator<String> descriptionValidator;
  final GroupIcon? selectedIcon;
  final Color? resolvedColor;
  final HabitColor? selectedColor;
  final HabitColor? lastCustomColor;
  final HabitGroupData? existingGroup;
  final ValueChanged<GroupIcon?> onIconSelected;
  final ValueChanged<HabitColor?> onColorSelected;
  final VoidCallback onCustomColorTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AppleTextFormField(
          key: const ValueKey('group-edit-name-field'),
          label: l10n?.groupManage_name_label ?? 'Name',
          controller: nameController,
          inputFormatters: [groupNameRule.hardLimitFormatter],
          maxLength: groupNameRule.hardLimit,
          validator: nameValidator,
          autofocus: true,
          emphasized: true,
        ),
        const SizedBox(height: 16),
        _AppleTextFormField(
          key: const ValueKey('group-edit-description-field'),
          label: l10n?.groupManage_desc_label ?? 'Description',
          controller: descriptionController,
          inputFormatters: [groupDescRule.hardLimitFormatter],
          validator: descriptionValidator,
          minLines: 1,
          maxLines: 2,
        ),
        GroupIconPicker(
          selectedIcon: selectedIcon,
          resolvedColor: resolvedColor,
          onSelected: onIconSelected,
        ),
        GroupColorPicker(
          selectedColor: selectedColor,
          lastCustomColor: lastCustomColor,
          onColorSelected: onColorSelected,
          onCustomColorTap: onCustomColorTap,
        ),
        if (existingGroup != null) ...[
          const SizedBox(height: 16),
          _ReadOnlyGroupInfo(group: existingGroup!),
        ],
      ],
    );
  }
}

class _AppleTextFormField extends StatelessWidget {
  const _AppleTextFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.inputFormatters,
    required this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.emphasized = false,
  });

  final String label;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldValidator<String> validator;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool autofocus;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final textStyle = theme.textTheme.textStyle;
    final separatorColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    ).withValues(alpha: 0.35);
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoTextField(
            controller: controller,
            placeholder: label,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines,
            autofocus: autofocus,
            clearButtonMode: OverlayVisibilityMode.editing,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            style: emphasized
                ? textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600)
                : textStyle,
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemFill,
                context,
              ),
              border: Border.all(color: separatorColor, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            onChanged: field.didChange,
          ),
          if (field.errorText case final error?) ...[
            const SizedBox(height: 6),
            Text(
              error,
              style: theme.textTheme.textStyle.copyWith(
                fontSize: 13,
                color: CupertinoColors.destructiveRed.resolveFrom(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Read-only info section shown below the editable fields when editing an
/// existing group (hidden during creation).
///
/// Displays [HabitGroupData.createT] and [HabitGroupData.modifyT] using the
/// same tile + icon style as the habit detail [_OtherInfo] section.
class _ReadOnlyGroupInfo extends StatelessWidget {
  final HabitGroupData group;

  const _ReadOnlyGroupInfo({required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final localeName = l10n?.localeName;
    final createT = group.createT;
    final modifyT = group.modifyT;

    if (createT == null && modifyT == null) return const SizedBox.shrink();

    return Selector<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
      selector: (_, vm) => vm.config,
      builder: (context, config, _) {
        final fmt = config.getFormatter(localeName);
        final rows = [
          if (createT != null)
            (
              l10n?.groupManage_createDateTile_title ?? 'Created',
              fmt.format(createT),
              HabitCalIcons.calendarcreate,
            ),
          if (modifyT != null)
            (
              l10n?.groupManage_modifyDateTile_title ?? 'Modified',
              fmt.format(modifyT),
              HabitCalIcons.calendarmodify,
            ),
        ];
        return AdaptiveListSection(
          hasLeading: true,
          padding: const EdgeInsetsDirectional.only(top: 24, bottom: 8),
          children: [
            for (final row in rows)
              AdaptiveListTile(
                leading: Icon(row.$3),
                title: Text(row.$1),
                subtitle: Text(row.$2),
              ),
          ],
        );
      },
    );
  }
}
