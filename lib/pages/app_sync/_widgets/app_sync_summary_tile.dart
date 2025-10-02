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
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../model/app_sync_server.dart';
import '../../../providers/app_sync.dart';

class AppSyncSummaryTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSyncSummaryTile({
    super.key,
    this.onPressed,
  });

  IconData getSubTitleLeading(
          BuildContext context, AppSyncServer? serverConfig) =>
      switch (serverConfig?.type) {
        AppSyncServerType.webdav => MdiIcons.cloudOutline,
        AppSyncServerType.unknown => MdiIcons.cloudQuestionOutline,
        _ => MdiIcons.cloudAlertOutline,
      };

  IconData? getTrailing(BuildContext context, AppSyncServer? serverConfig) =>
      switch (serverConfig?.type) {
        != null => Icons.edit,
        _ => Icons.add,
      };

  @override
  Widget build(BuildContext context) {
    final serverConfig = context
        .select<AppSyncViewModel, AppSyncServer?>((vm) => vm.serverConfig);
    final l10n = L10n.of(context);
    final trailingData = getTrailing(context, serverConfig);
    final subtileLeading = getSubTitleLeading(context, serverConfig);
    return ListTile(
      trailing: trailingData != null ? Icon(trailingData) : null,
      title: Text(l10n?.appSync_summaryTile_title ?? "Sync Server"),
      subtitle: serverConfig != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(subtileLeading),
                  const SizedBox(width: 4),
                  Text(l10n?.appSync_syncServerType_text(
                          serverConfig.type.name, '') ??
                      serverConfig.type.name)
                ]),
                const SizedBox(width: 4),
                Text(serverConfig.name)
              ],
            )
          : Text(l10n?.appSync_summaryTile_subtitle_text_notConfigured ??
              "Not Configured."),
      onTap: onPressed,
    );
  }
}
