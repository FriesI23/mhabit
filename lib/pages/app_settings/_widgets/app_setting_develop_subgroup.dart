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
  Widget build(BuildContext context) {
    const adaptiveStyleOptions = [
      (value: AppAdaptiveStyleMode.automatic, label: 'Automatic'),
      (value: AppAdaptiveStyleMode.material, label: 'Material'),
      (value: AppAdaptiveStyleMode.apple, label: 'Apple'),
    ];
    final selectedStyleLabel = adaptiveStyleOptions
        .firstWhere((option) => option.value == adaptiveStyleMode)
        .label;
    const List<({TextDirection? value, String label})> textDirectionOptions = [
      (value: null, label: 'Auto'),
      (value: TextDirection.ltr, label: 'LTR'),
      (value: TextDirection.rtl, label: 'RTL'),
    ];
    final selectedTextDirectionLabel = textDirectionOptions
        .firstWhere((option) => option.value == textDirectionOverride)
        .label;

    return ExpandedSection(
      expand: isInDevelopMode,
      child: Column(
        children: [
          const GroupTitleListTile(title: Text("Developer")),
          SwitchListTile(
            title: const Text("Show debug menu"),
            value: isDisplayDebugMenuSelect,
            onChanged: onDisplayDebugMenuSelectChanged,
          ),
          ListTile(
            title: const Text('UI style'),
            trailing: MenuAnchor(
              animated: true,
              menuChildren: [
                for (final option in adaptiveStyleOptions)
                  MenuItemButton(
                    leadingIcon: Opacity(
                      opacity: option.value == adaptiveStyleMode ? 1 : 0,
                      child: const Icon(Icons.check),
                    ),
                    onPressed: onAdaptiveStyleModeChanged == null
                        ? null
                        : () => onAdaptiveStyleModeChanged!(option.value),
                    child: Text(option.label),
                  ),
              ],
              builder: (context, controller, child) => TextButton.icon(
                key: const ValueKey('developer-ui-style-control'),
                onPressed: onAdaptiveStyleModeChanged == null
                    ? null
                    : () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_drop_down),
                label: Text(selectedStyleLabel),
              ),
            ),
          ),
          ListTile(
            title: const Text('Text direction'),
            trailing: MenuAnchor(
              animated: true,
              menuChildren: [
                for (final option in textDirectionOptions)
                  MenuItemButton(
                    leadingIcon: Opacity(
                      opacity: option.value == textDirectionOverride ? 1 : 0,
                      child: const Icon(Icons.check),
                    ),
                    onPressed: onTextDirectionOverrideChanged == null
                        ? null
                        : () => onTextDirectionOverrideChanged!(option.value),
                    child: Text(option.label),
                  ),
              ],
              builder: (context, controller, child) => TextButton.icon(
                key: const ValueKey('developer-text-direction-control'),
                onPressed: onTextDirectionOverrideChanged == null
                    ? null
                    : () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_drop_down),
                label: Text(selectedTextDirectionLabel),
              ),
            ),
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
