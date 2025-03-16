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

class AppSyncWebDavNewServerConfirmDialog extends StatelessWidget {
  const AppSyncWebDavNewServerConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(MdiIcons.folderMultiplePlusOutline),
      title: const Text("New Location"),
      content:
          const Text("Syncing will create necessary directories and upload "
              "your local habits to the server. Do you want to proceed?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context, false),
          child: Text("cancel"),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Sync Now!"),
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
    return AlertDialog(
      icon: const Icon(MdiIcons.folderAlertOutline),
      title: const Text("Confirm Sync"),
      content:
          const Text("Configured directory isn't empty, continuing this sync "
              "will merge the server's habits with your local data. "
              "Do you want to continue?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context, false),
          child: Text("cancel"),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.errorContainer),
          onPressed: () => Navigator.pop(context, true),
          child: Text("cotinue"),
        )
      ],
    );
  }
}
