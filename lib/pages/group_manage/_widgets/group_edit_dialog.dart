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
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/habit_group.dart';
import '../../../pages/common/_widgets/group_edit_form.dart';
import '../../../providers/app_ui/custom_color_history.dart';
import '../../../widgets/widgets.dart';

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
  final formKey = GlobalKey<GroupEditFormState>();
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
              onPressed: () => formKey.currentState?.save(),
              child: Text(l10n?.habitEdit_saveButton_text ?? 'Save'),
            ),
          ]
        : [
            TextButton(
              onPressed: () => formKey.currentState?.save(),
              child: Text(l10n?.habitEdit_saveButton_text ?? 'Save'),
            ),
          ],
    contentBuilder: (context) {
      final history = context.read<CustomColorHistoryViewModel>().history;
      return GroupEditForm(
        key: formKey,
        existingGroup: existingGroup,
        customColorHistory: history,
        onRecordCustomColor: (color) {
          context.read<CustomColorHistoryViewModel>().recordUsage(color);
        },
      );
    },
  );
}
