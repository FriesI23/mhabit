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
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/habit_group.dart';
import '../../../pages/common/_widgets/group_edit_form.dart';
import '../../../providers/app_ui/custom_color_history.dart';

/// Shows an adaptive content sheet (or dialog on wide screens) for
/// creating/editing a Group.
///
/// Returns the form values when the user taps Save, or `null` on cancel.
/// The dialog performs only validation — the caller is responsible for
/// persisting the result and broadcasting change events.
Future<GroupEditFormResult?> showGroupEditDialog({
  required BuildContext context,
  HabitGroupData? existingGroup,
}) => showAdaptiveSheet<GroupEditFormResult>(
  context: context,
  builder: (_) => AdaptiveModalNavigator<GroupEditFormResult>(
    size: const AdaptiveModalSize.constrained(),
    builder: (_) => _GroupEditDialog(existingGroup: existingGroup),
  ),
);

class _GroupEditDialog extends StatefulWidget {
  const _GroupEditDialog({this.existingGroup});

  final HabitGroupData? existingGroup;

  @override
  State<_GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<_GroupEditDialog> {
  final _formKey = GlobalKey<GroupEditFormState>();

  void _save() => _formKey.currentState?.save();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final history = context.watch<CustomColorHistoryViewModel>().history;
    final title = Text(
      widget.existingGroup == null
          ? (l10n?.groupManage_createDialog_title ?? 'Create Group')
          : (l10n?.groupManage_editDialog_title ?? 'Edit Group'),
    );
    final body = GroupEditForm(
      key: _formKey,
      existingGroup: widget.existingGroup,
      onSave: (result) => AdaptiveModalNavigator.pop(context, result),
      customColorHistory: history,
      onRecordCustomColor: (color) {
        context.read<CustomColorHistoryViewModel>().recordUsage(color);
      },
    );
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialGroupEditDialog(
        title: title,
        body: body,
        onSave: _save,
      ),
      AdaptiveStyle.apple => _AppleGroupEditDialog(
        title: title,
        body: body,
        onSave: _save,
      ),
    };
  }
}

class _MaterialGroupEditDialog extends StatelessWidget {
  const _MaterialGroupEditDialog({
    required this.title,
    required this.body,
    required this.onSave,
  });

  final Widget title;
  final Widget body;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AdaptiveModal(
    title: title,
    appBarActions: [
      TextButton(
        onPressed: onSave,
        child: Text(L10n.of(context)?.habitEdit_saveButton_text ?? 'Save'),
      ),
    ],
    body: body,
  );
}

class _AppleGroupEditDialog extends StatelessWidget {
  const _AppleGroupEditDialog({
    required this.title,
    required this.body,
    required this.onSave,
  });

  final Widget title;
  final Widget body;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => AdaptiveModal(
    title: title,
    actions: [
      CupertinoButton(
        key: const ValueKey('group-edit-save-action'),
        onPressed: onSave,
        child: Text(
          L10n.of(context)?.habitEdit_saveButton_text ?? 'Save',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
    body: body,
  );
}
