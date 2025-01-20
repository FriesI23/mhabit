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

import '../../model/app_sync_server.dart';

class AppSyncSummaryTile extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final VoidCallback? onPressed;

  const AppSyncSummaryTile({
    super.key,
    required this.serverConfig,
    this.onPressed,
  });

  IconData? getSubTitleLeading(BuildContext context) =>
      switch (serverConfig?.type) {
        AppSyncServerType.webdav => MdiIcons.cloudOutline,
        AppSyncServerType.unknown => null,
        _ => Icons.warning,
      };

  IconData? getTrailing(BuildContext context) => switch (serverConfig?.type) {
        != null => Icons.edit,
        _ => Icons.add,
      };

  @override
  Widget build(BuildContext context) {
    final serverConfig = this.serverConfig;
    final trailingData = getTrailing(context);
    final subtileLeading = getSubTitleLeading(context);
    return ListTile(
      trailing: trailingData != null ? Icon(trailingData) : null,
      title: Text("Sync Server"),
      subtitle: serverConfig != null
          ? Wrap(children: [
              if (subtileLeading != null) Icon(subtileLeading),
              Text("Current: ${serverConfig.name}"),
            ])
          : Text("Not Configured."),
      onTap: onPressed,
    );
  }
}
