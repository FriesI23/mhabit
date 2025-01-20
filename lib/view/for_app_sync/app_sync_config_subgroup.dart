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

import '../../component/widget.dart';
import '../../model/app_sync_server.dart';
import '_widget.dart';

class AppSyncConfigSubgroup extends StatelessWidget {
  final bool enabled;
  final AppSyncServer? serverConfig;

  const AppSyncConfigSubgroup({
    super.key,
    required this.enabled,
    required this.serverConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandedSection(
      expand: enabled,
      child: Column(
        children: [
          AppSyncSummaryTile(serverConfig: serverConfig),
        ],
      ),
    );
  }
}
