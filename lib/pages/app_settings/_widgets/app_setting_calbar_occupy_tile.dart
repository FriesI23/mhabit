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

  String _getLabel([L10n? l10n]) {
    final val = (currentPercentage - normalPercentage).abs() ~/ splitLen;
    if (val == 0) {
      return l10n != null
          ? l10n.appSetting_collapsed_calendar_bararea_defaultText
          : "0";
    } else if (currentPercentage > normalPercentage) {
      return "+$val";
    } else {
      return "-$val";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      isThreeLine: true,
      title: l10n != null
          ? Text(l10n.appSetting_collapsed_calendar_bararea_titleText)
          : const Text("Collapsed calendar bar area"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (l10n != null)
            Text(l10n.appSetting_collapsed_calendar_bararea_subtitleText),
          Slider(
            value: currentPercentage.toDouble(),
            secondaryTrackValue: normalPercentage.toDouble(),
            max: morePercentage.toDouble(),
            min: lessPercentage.toDouble(),
            divisions: (morePercentage - lessPercentage) ~/ splitLen,
            label: _getLabel(l10n),
            onChanged: (value) {
              onSelectionChanged(value.toInt());
            },
          ),
        ],
      ),
    );
  }
}
