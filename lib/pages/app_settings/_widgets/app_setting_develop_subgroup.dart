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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../models/app_adaptive_style_mode.dart';
import '../../../widgets/widgets.dart';

class AppSettingDevelopSubGroup extends StatelessWidget {
  final bool isInDevelopMode;
  final bool isDisplayDebugMenuSelect;
  final AppAdaptiveStyleMode adaptiveStyleMode;
  final TextDirection? textDirectionOverride;
  final ValueChanged<bool>? onDisplayDebugMenuSelectChanged;
  final ValueChanged<AppAdaptiveStyleMode>? onAdaptiveStyleModeChanged;
  final ValueChanged<TextDirection?>? onTextDirectionOverrideChanged;
  final void Function(BuildContext context)? onExportDBTilePressed;
  final void Function(BuildContext context)? onClearDBTilePressed;

  const AppSettingDevelopSubGroup({
    super.key,
    this.isInDevelopMode = false,
    this.isDisplayDebugMenuSelect = false,
    this.adaptiveStyleMode = AppAdaptiveStyleMode.automatic,
    this.textDirectionOverride,
    this.onDisplayDebugMenuSelectChanged,
    this.onAdaptiveStyleModeChanged,
    this.onTextDirectionOverrideChanged,
    this.onExportDBTilePressed,
    this.onClearDBTilePressed,
  });

  @override
  Widget build(BuildContext context) => ExpandedSection(
    expand: isInDevelopMode,
    child: AdaptiveListSection(
      key: const ValueKey('settings-developer'),
      header: const Text('Developer'),
      children: [
        AdaptiveSwitchListTile(
          key: const ValueKey('developer-debug-menu'),
          title: const Text('Show debug menu'),
          value: isDisplayDebugMenuSelect,
          onChanged: onDisplayDebugMenuSelectChanged,
        ),
        _DeveloperChoiceTile<AppAdaptiveStyleMode>(
          title: 'UI style',
          controlKey: const ValueKey('developer-ui-style-control'),
          value: adaptiveStyleMode,
          labels: const {
            AppAdaptiveStyleMode.automatic: 'Automatic',
            AppAdaptiveStyleMode.material: 'Material',
            AppAdaptiveStyleMode.apple: 'Apple',
          },
          onChanged: onAdaptiveStyleModeChanged,
        ),
        _DeveloperChoiceTile<_DeveloperTextDirection>(
          title: 'Text direction',
          controlKey: const ValueKey('developer-text-direction-control'),
          value: switch (textDirectionOverride) {
            null => _DeveloperTextDirection.automatic,
            TextDirection.ltr => _DeveloperTextDirection.ltr,
            TextDirection.rtl => _DeveloperTextDirection.rtl,
          },
          labels: const {
            _DeveloperTextDirection.automatic: 'Auto',
            _DeveloperTextDirection.ltr: 'LTR',
            _DeveloperTextDirection.rtl: 'RTL',
          },
          onChanged: onTextDirectionOverrideChanged == null
              ? null
              : (value) => onTextDirectionOverrideChanged!(switch (value) {
                  _DeveloperTextDirection.ltr => TextDirection.ltr,
                  _DeveloperTextDirection.rtl => TextDirection.rtl,
                  _DeveloperTextDirection.automatic => null,
                }),
        ),
        Builder(
          builder: (context) => AdaptiveListTile(
            key: const ValueKey('developer-export-db'),
            title: const Text('Export DataBase'),
            onTap: onExportDBTilePressed == null
                ? null
                : () => onExportDBTilePressed!(context),
          ),
        ),
        Builder(
          builder: (context) => AdaptiveListTile(
            key: const ValueKey('developer-clear-db'),
            title: const Text('Clear DataBase'),
            onTap: onClearDBTilePressed == null
                ? null
                : () => onClearDBTilePressed!(context),
          ),
        ),
      ],
    ),
  );
}

enum _DeveloperTextDirection { automatic, ltr, rtl }

class _DeveloperChoiceTile<T extends Object> extends StatelessWidget {
  const _DeveloperChoiceTile({
    required this.title,
    required this.controlKey,
    required this.value,
    required this.labels,
    required this.onChanged,
  });
  final String title;
  final Key controlKey;
  final T value;
  final Map<T, String> labels;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => WindowSizeClassLayoutBuilder(
    builder: (context, windowSize, child) => AdaptiveChoiceListTile<T>(
      title: Text(title),
      controlKey: controlKey,
      value: value,
      labels: labels,
      onChanged: onChanged,
      config: AdaptiveChoiceListTileConfig.choice(
        segmented: windowSize.width >= WindowSizeClass.medium
            ? AdaptiveChoiceLayout.responsive
            : AdaptiveChoiceLayout.stacked,
      ),
    ),
  );
}
