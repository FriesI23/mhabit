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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_form.dart';
import '../../../theme/color.dart';

Future<HabitColorType?> showHabitColorPickerDialog({
  required BuildContext context,
  required HabitColorType colorType,
}) async {
  return showDialog<HabitColorType>(
    context: context,
    builder: (context) => HabitColorPickerDialog(colorType),
  );
}

class HabitColorPickerDialog extends StatelessWidget {
  final HabitColorType colorType;

  const HabitColorPickerDialog(this.colorType, {super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    final l10n = L10n.of(context);

    // No `CustomColors` registered on the theme means there's nothing to
    // pick from; fall back to an empty swatch list instead of forcing one.
    final availableColors = colorData?.builtInColors ?? const [];
    final pickerColor =
        colorData?.getBuiltInColor(colorType) ?? Colors.transparent;

    return AlertDialog(
      title: l10n != null ? Text(l10n.habitEdit_colorPicker_title) : null,
      content: SingleChildScrollView(
        child: BlockPicker(
          layoutBuilder: (context, colors, child) => SizedBox(
            width: 360,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [for (Color color in colors) child(color)],
            ),
          ),
          itemBuilder: (color, isCurrentColor, changeColor) {
            final colorType = colorData?.getBuiltInColorType(color);
            final onColor = colorType != null
                ? colorData?.getBuiltInOnColor(colorType)
                : null;
            return IconButton(
              onPressed: changeColor,
              icon: isCurrentColor ? const Icon(Icons.check) : const Icon(null),
              isSelected: isCurrentColor,
              style: IconButton.styleFrom(
                foregroundColor: onColor,
                backgroundColor: color,
                disabledBackgroundColor: themeData.colorScheme.onSurface
                    .withValues(alpha: 0.12),
                hoverColor: onColor?.withValues(alpha: 0.08),
                focusColor: onColor?.withValues(alpha: 0.12),
                highlightColor: onColor?.withValues(alpha: 0.12),
              ),
            );
          },
          pickerColor: pickerColor,
          availableColors: availableColors,
          onColorChanged: (value) {
            Navigator.pop(context, colorData?.getBuiltInColorType(value));
          },
        ),
      ),
    );
  }
}
