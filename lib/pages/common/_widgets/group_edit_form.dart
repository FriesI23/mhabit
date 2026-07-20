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
import '../../../l10n/localizations.dart';
import '../../../models/custom_date_format.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_group.dart';
import '../../../providers/app_ui/app_custom_date_format.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../theme/icon.dart';
import '../../../widgets/rules.dart';
import '../../../widgets/widgets.dart';
import '../../habit_detail/_widgets/habit_other_info_tile.dart';

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
            decoration: InputDecoration(
              labelText: l10n?.groupManage_name_label ?? 'Name',
            ),
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
            decoration: InputDecoration(
              labelText: l10n?.groupManage_desc_label ?? 'Description',
            ),
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
          GroupIconPicker(
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
          GroupColorPicker(
            selectedColor: _selectedColor,
            lastCustomColor: _lastCustomColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
            onCustomColorTap: _openCustomColorPicker,
          ),
          if (widget.existingGroup != null) ...[
            const SizedBox(height: 12),
            const HabitDivider(),
            _ReadOnlyGroupInfo(group: widget.existingGroup!),
          ],
        ],
      ),
    );
  }

  Future<void> _openCustomColorPicker() async {
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
      builder: (_) => GroupCustomColorPickerDialog(
        seedColor: seedColor,
        seedTinted: seedTinted,
        history: widget.customColorHistory,
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (createT != null)
              HabitOtherInfoTile(
                title: Text(
                  l10n?.groupManage_createDateTile_title ?? 'Created',
                ),
                subTitle: Text(fmt.format(createT)),
                leading: const Icon(HabitCalIcons.calendarcreate),
              ),
            if (modifyT != null)
              HabitOtherInfoTile(
                title: Text(
                  l10n?.groupManage_modifyDateTile_title ?? 'Modified',
                ),
                subTitle: Text(fmt.format(modifyT)),
                leading: const Icon(HabitCalIcons.calendarmodify),
              ),
          ],
        );
      },
    );
  }
}
