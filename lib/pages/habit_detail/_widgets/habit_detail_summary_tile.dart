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

import '../../../extensions/colorscheme_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_color.dart';
import '../../../theme/color.dart';
import '../../../widgets/widgets.dart';

class HabitDetailSummaryTile extends StatelessWidget {
  final num habitProgress;
  final HabitColor? color;
  final bool isHabitCompleted;
  final bool isHabitArchived;
  final bool isHabitDeleted;
  final Widget? title;
  final Widget? subtitle;

  const HabitDetailSummaryTile({
    super.key,
    required this.habitProgress,
    this.color,
    required this.isHabitCompleted,
    this.isHabitArchived = false,
    this.isHabitDeleted = false,
    this.title,
    this.subtitle,
  }) : assert(!(isHabitArchived && isHabitDeleted));

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: HabitProgressIndicator(
          value: habitProgress / 100,
          color: color != null
              ? colorData?.getColor(color!, brightness: themeData.brightness)
              : Colors.transparent,
          backgroundColor: themeData.colorScheme.outlineOpacity16,
          strokeWidth: 6,
          isComplated: isHabitCompleted,
          isArchived: isHabitArchived,
          isDeleted: isHabitDeleted,
          showComplatedIcon: false,
        ),
      ),
      title: title,
      subtitle: subtitle,
    );
  }
}
