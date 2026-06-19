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
import '../../models/habit_color.dart';
import '../../theme/color.dart';

class ThemeWithCustomColors extends StatelessWidget {
  final HabitColor? color;
  final bool overwritePrimaryColor;
  final bool overwriteOnPrimaryColor;
  final bool overwritePrimaryContainerColor;
  final bool overwriteOnPrimaryContainerColor;
  final Widget child;

  const ThemeWithCustomColors({
    super.key,
    this.color,
    this.overwritePrimaryColor = true,
    this.overwriteOnPrimaryColor = true,
    this.overwritePrimaryContainerColor = true,
    this.overwriteOnPrimaryContainerColor = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();

    return Theme(
      data: themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(
          primary: color != null && overwritePrimaryColor
              ? colorData?.getColor(color!, brightness: themeData.brightness)
              : null,
          onPrimary: color != null && overwriteOnPrimaryColor
              ? colorData?.getOnColor(color!, brightness: themeData.brightness)
              : null,
          primaryContainer: color != null && overwritePrimaryContainerColor
              ? colorData?.getColorContainer(
                  color!,
                  brightness: themeData.brightness,
                )
              : null,
          onPrimaryContainer: color != null && overwriteOnPrimaryContainerColor
              ? colorData?.getColorOnContainer(
                  color!,
                  brightness: themeData.brightness,
                )
              : null,
        ),
      ),
      child: child,
    );
  }
}
