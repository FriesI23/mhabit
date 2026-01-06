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

import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_form.dart';
import '../../../theme/color.dart';

class HabitDetailFAB extends StatelessWidget {
  final HabitColorType? colorType;
  final VoidCallback? onPressed;

  const HabitDetailFAB({super.key, this.colorType, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();

    Color? backgroundColor = themeData.colorScheme.secondaryContainer;
    Color? iconColor = themeData.colorScheme.onSecondaryContainer;
    backgroundColor =
        (colorType != null ? colorData?.getColorContainer(colorType!) : null) ??
        backgroundColor;
    iconColor =
        (colorType != null
            ? colorData?.getColorOnContainer(colorType!)
            : null) ??
        iconColor;
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: Icon(Icons.edit_calendar_outlined, color: iconColor),
    );
  }
}
