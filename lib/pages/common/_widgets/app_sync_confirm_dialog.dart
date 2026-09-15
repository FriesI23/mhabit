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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';

class AppSyncWebDavNewServerConfirmDialog extends StatelessWidget {
  const AppSyncWebDavNewServerConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveConfirmDialog(
      icon: const Icon(MdiIcons.folderMultiplePlusOutline),
      title: Text(
        l10n?.appSync_webdav_newServerConfirmDialog_titleText ?? "New Location",
      ),
      content: l10n != null
          ? Text(l10n.appSync_webdav_newServerConfirmDialog_subtitleText)
          : null,
      cancelLabel: l10n?.confirmDialog_cancel_text ?? 'cancel',
      confirmLabel:
          l10n?.appSync_webdav_newServerConfirmDialog_confirmText ?? 'continue',
    );
  }
}

class AppSyncWebDavOldServerConfirmDialog extends StatelessWidget {
  const AppSyncWebDavOldServerConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveConfirmDialog(
      icon: const Icon(MdiIcons.folderAlertOutline),
      title: Text(
        l10n?.appSync_webdav_oldServerConfirmDialog_titleText ?? "Confirm Sync",
      ),
      content: l10n != null
          ? Text(l10n.appSync_webdav_oldServerConfirmDialog_subtitleText)
          : null,
      cancelLabel: l10n?.confirmDialog_cancel_text ?? 'cancel',
      confirmLabel:
          l10n?.appSync_webdav_oldServerConfirmDialog_confirmText ?? 'continue',
      isDestructiveAction: true,
    );
  }
}
