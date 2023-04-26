// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../common/enums.dart';
import '../../component/widget.dart';
import 'app_setting_log_level_tile.dart';

class AppSettingDevelopSubGroup extends StatelessWidget {
  final bool isInDevelopMode;
  final bool isDisplayDebugMenuSelect;
  final LogLevel logLevel;
  final ValueChanged<bool>? onDisplayDebugMenuSelectChanged;
  final ValueChanged<LogLevel>? onLogLevelChanged;
  final void Function(BuildContext context)? onExportDBTilePressed;
  final void Function(BuildContext context)? onClearDBTilePressed;

  const AppSettingDevelopSubGroup({
    super.key,
    this.isInDevelopMode = false,
    this.isDisplayDebugMenuSelect = false,
    required this.logLevel,
    this.onDisplayDebugMenuSelectChanged,
    this.onLogLevelChanged,
    this.onExportDBTilePressed,
    this.onClearDBTilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandedSection(
      expand: isInDevelopMode,
      child: Column(
        children: [
          const GroupTitleListTile(title: Text("Debug")),
          AppSettingLogLevelTile(
            crtLevel: logLevel,
            onSelected: onLogLevelChanged,
          ),
          SwitchListTile(
            title: const Text("Show debug menu"),
            value: isDisplayDebugMenuSelect,
            onChanged: onDisplayDebugMenuSelectChanged,
          ),
          Builder(
            builder: (context) => ListTile(
              title: const Text("Export DataBase"),
              onTap: onExportDBTilePressed != null
                  ? () => onExportDBTilePressed!(context)
                  : null,
            ),
          ),
          Builder(
            builder: (context) => ListTile(
              title: const Text("Clear DataBase"),
              onTap: onClearDBTilePressed != null
                  ? () => onClearDBTilePressed!(context)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
