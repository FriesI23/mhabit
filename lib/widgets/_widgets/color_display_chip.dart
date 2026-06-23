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

import '../../extensions/custom_color_extensions.dart';
import '../../l10n/localizations.dart';
import '../../models/habit_color.dart';
import '../../models/habit_form.dart';
import '../../theme/color.dart';

/// The effective display name for a habit color: the localized built-in
/// name for [BuiltInHabitColor], or the localized "Custom" string for
/// [CustomHabitColor]. Custom colors never show a per-color name.
String getEffectiveColorName(HabitColor color, L10n? l10n) => switch (color) {
  BuiltInHabitColor(colorType: final t) => HabitColorType.getColorName(t, l10n),
  CustomHabitColor() => l10n?.common_habitColorType_custom ?? "Custom",
};

class ColorDisplayChip extends StatelessWidget {
  final HabitColor color;

  const ColorDisplayChip(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final CustomColors? colorData = Theme.of(context).extension<CustomColors>();
    final resolvedColor = colorData?.getColor(
      color,
      brightness: Theme.of(context).brightness,
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            decoration: BoxDecoration(
              color: resolvedColor,
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            getEffectiveColorName(color, L10n.of(context)),
            style: TextStyle(color: resolvedColor),
          ),
        ],
      ),
    );
  }
}
