// Copyright 2025 Fries_I23
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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../l10n/localizations.dart';

class AppSyncWebDavNewServerConfirmDialog extends StatelessWidget {
  const AppSyncWebDavNewServerConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AlertDialog(
      icon: const Icon(MdiIcons.folderMultiplePlusOutline),
      title: Text(l10n?.appSync_webdav_newServerConfirmDialog_titleText ??
          "New Location"),
      content: l10n != null
          ? Text(l10n.appSync_webdav_newServerConfirmDialog_subtitleText)
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context, false),
          child: Text(l10n?.confirmDialog_cancel_text ?? "cancel"),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n?.appSync_webdav_newServerConfirmDialog_confirmText ??
              "continue"),
        )
      ],
    );
  }
}

class AppSyncWebDavOldServerConfirmDialog extends StatelessWidget {
  const AppSyncWebDavOldServerConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    return AlertDialog(
      icon: const Icon(MdiIcons.folderAlertOutline),
      title: Text(l10n?.appSync_webdav_oldServerConfirmDialog_titleText ??
          "Confirm Sync"),
      content: l10n != null
          ? Text(l10n.appSync_webdav_oldServerConfirmDialog_subtitleText)
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context, false),
          child: Text(l10n?.confirmDialog_cancel_text ?? "cancel"),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.errorContainer),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n?.appSync_webdav_oldServerConfirmDialog_confirmText ??
              "continue"),
        )
      ],
    );
  }
}
