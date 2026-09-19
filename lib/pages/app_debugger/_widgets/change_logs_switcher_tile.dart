// Copyright 2024 Fries_I23
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../l10n/localizations.dart';

class ChangeLogsSwitcherTile extends StatelessWidget {
  const ChangeLogsSwitcherTile({
    super.key,
    required this.value,
    this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final title = l10n?.debug_collectLogTile_title ?? 'Collect logs';
    final subtitle = value
        ? l10n?.debug_collectLogTile_enable_subtitle
        : l10n?.debug_collectLogTile_disable_subtitle;
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialLogsSwitcher(
        title: title,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
      AdaptiveStyle.apple => _AppleLogsSwitcher(
        title: title,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
    };
  }
}

class _MaterialLogsSwitcher extends StatelessWidget {
  const _MaterialLogsSwitcher({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MergeSemantics(
      child: AdaptiveListTile.material(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: ExcludeFocus(
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.error,
            activeTrackColor: colors.errorContainer,
            thumbIcon: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Icon(
                      Icons.pause,
                      color: states.contains(WidgetState.disabled)
                          ? colors.onSurface.withValues(alpha: 0.38)
                          : colors.onError,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleLogsSwitcher extends StatelessWidget {
  const _AppleLogsSwitcher({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final red = CupertinoColors.systemRed.resolveFrom(context);
    return MergeSemantics(
      child: AdaptiveListTile.apple(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: ExcludeFocus(
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: red,
            thumbIcon: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Icon(
                      // CupertinoSwitch paints thumbIcon in a square without
                      // Icon's font-height normalization. Use a square-metric
                      // pause glyph so it stays centered on the native thumb.
                      Icons.pause,
                      color: states.contains(WidgetState.disabled)
                          ? CupertinoColors.tertiaryLabel.resolveFrom(context)
                          : red,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
