// Copyright 2026 Fries_I23
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

import '../../../l10n/localizations.dart';
import '../../../providers/app_ui/group_expand_timer_config.dart';

class AppSettingExpandTimerDelayTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final GroupExpandTimerSpeed speed;
  final bool isLargeScreen;
  final void Function(GroupExpandTimerSpeed speed)? onSelected;

  const AppSettingExpandTimerDelayTile({
    super.key,
    this.title,
    this.subtitle,
    required this.speed,
    this.isLargeScreen = false,
    this.onSelected,
  });

  String _labelFor(GroupExpandTimerSpeed speed, L10n? l10n) => switch (speed) {
    GroupExpandTimerSpeed.fast =>
      l10n?.appSetting_expandTimerDelay_fast ?? 'Fast',
    GroupExpandTimerSpeed.slow =>
      l10n?.appSetting_expandTimerDelay_slow ?? 'Slow',
    GroupExpandTimerSpeed.defaultSpeed =>
      l10n?.appSetting_expandTimerDelay_default ?? 'Default',
  };

  SegmentedButton<GroupExpandTimerSpeed> _buildSegmentedButton(
    BuildContext context,
  ) {
    final l10n = L10n.of(context);
    final selected = {speed};
    return SegmentedButton<GroupExpandTimerSpeed>(
      showSelectedIcon: false,
      segments: [
        for (final s in kGroupExpandTimerSpeedOptions)
          ButtonSegment<GroupExpandTimerSpeed>(
            value: s,
            label: Text(_labelFor(s, l10n)),
          ),
      ],
      selected: selected,
      onSelectionChanged: onSelected != null
          ? (value) => onSelected!(value.isNotEmpty ? value.first : speed)
          : null,
      style: const ButtonStyle(visualDensity: VisualDensity(vertical: -2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen) {
      return ListTile(
        title: title,
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (subtitle != null) ...[
              Flexible(flex: 5, child: subtitle!),
              const Spacer(flex: 1),
            ],
            _buildSegmentedButton(context),
          ],
        ),
      );
    }
    return ListTile(
      title: title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (subtitle != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(
                width: double.infinity,
              ),
              child: subtitle,
            ),
            const SizedBox(height: 8.0),
          ],
          _buildSegmentedButton(context),
        ],
      ),
    );
  }
}
