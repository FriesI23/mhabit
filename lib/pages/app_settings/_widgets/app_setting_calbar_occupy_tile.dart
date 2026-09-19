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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import "../../../l10n/localizations.dart";

class AppSettingCalbarOccupyTile extends StatelessWidget {
  static const splitLen = 5;

  final int currentPercentage;
  final int normalPercentage;
  final int lessPercentage;
  final int morePercentage;
  final ValueChanged<int> onSelectionChanged;

  const AppSettingCalbarOccupyTile({
    super.key,
    required this.lessPercentage,
    required this.morePercentage,
    required this.normalPercentage,
    required this.currentPercentage,
    required this.onSelectionChanged,
  });

  String _getLabel([L10n? l10n, int? percentage]) {
    final current = percentage ?? currentPercentage;
    final val = (current - normalPercentage).abs() ~/ splitLen;
    if (val == 0) {
      return l10n != null
          ? l10n.appSetting_collapsed_calendar_bararea_defaultText
          : "0";
    } else if (current > normalPercentage) {
      return "+$val";
    } else {
      return "-$val";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final title =
        l10n?.appSetting_collapsed_calendar_bararea_titleText ??
        'Collapsed calendar bar area';
    final subtitle = l10n?.appSetting_collapsed_calendar_bararea_subtitleText;
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialCalendarOccupancyTile(
        title: title,
        subtitle: subtitle,
        current: currentPercentage,
        normal: normalPercentage,
        min: lessPercentage,
        max: morePercentage,
        labelForValue: (value) => _getLabel(l10n, value),
        onChanged: onSelectionChanged,
      ),
      AdaptiveStyle.apple => _AppleCalendarOccupancyTile(
        title: title,
        subtitle: subtitle,
        current: currentPercentage,
        min: lessPercentage,
        max: morePercentage,
        labelForValue: (value) => _getLabel(l10n, value),
        onChanged: onSelectionChanged,
      ),
    };
  }
}

class _MaterialCalendarOccupancyTile extends StatelessWidget {
  const _MaterialCalendarOccupancyTile({
    required this.title,
    this.subtitle,
    required this.current,
    required this.normal,
    required this.min,
    required this.max,
    required this.labelForValue,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final int current;
  final int normal;
  final int min;
  final int max;
  final String Function(int) labelForValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AdaptiveListTile.material(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) Text(subtitle!),
          Slider(
            value: current.toDouble(),
            secondaryTrackValue: normal.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ AppSettingCalbarOccupyTile.splitLen,
            label: labelForValue(current),
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ],
      ),
    );
  }
}

class _AppleCalendarOccupancyTile extends StatelessWidget {
  const _AppleCalendarOccupancyTile({
    required this.title,
    this.subtitle,
    required this.current,
    required this.min,
    required this.max,
    required this.labelForValue,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final int current;
  final int min;
  final int max;
  final String Function(int) labelForValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const step = AppSettingCalbarOccupyTile.splitLen;
    return AdaptiveListTile.apple(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) Text(subtitle!),
          Text(labelForValue(current)),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              key: const ValueKey('calendar-occupancy-control'),
              label: title,
              slider: true,
              excludeSemantics: true,
              value: labelForValue(current),
              increasedValue: current < max
                  ? labelForValue(current + step)
                  : null,
              decreasedValue: current > min
                  ? labelForValue(current - step)
                  : null,
              onIncrease: current < max
                  ? () => onChanged(current + step)
                  : null,
              onDecrease: current > min
                  ? () => onChanged(current - step)
                  : null,
              child: CupertinoSlider(
                value: current.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min) ~/ step,
                onChanged: (value) => onChanged(value.round()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
