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
import '../../models/habit_form.dart';
import '../../theme/color.dart';

class MonthPickerCell extends StatelessWidget {
  final int monthday;
  final Size? size;
  final TextStyle? unselectStyle;
  final TextStyle? selectedStyle;
  final bool selected;
  final HabitColorType? colorType;
  final Duration? changeDuration;
  final double elevation;
  final void Function(int monthday)? onPressed;

  const MonthPickerCell({
    super.key,
    required this.monthday,
    this.size,
    this.unselectStyle,
    this.selectedStyle,
    this.selected = false,
    this.colorType,
    this.changeDuration,
    this.elevation = 2.0,
    this.onPressed,
  }) : assert(monthday > 0 && monthday < 32);

  Color? getBackgroundColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CustomColors? colorData = theme.extension<CustomColors>();

    if (selected) {
      return (colorType != null ? colorData?.getColor(colorType!) : null) ??
          theme.colorScheme.primary;
    } else {
      return Colors.transparent;
    }
  }

  TextStyle? getTextStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CustomColors? colorData = theme.extension<CustomColors>();

    if (selected) {
      return selectedStyle ??
          theme.textTheme.labelSmall?.copyWith(
            color:
                (colorType != null
                    ? colorData?.getOnColor(colorType!)
                    : null) ??
                theme.colorScheme.onPrimary,
          );
    } else {
      return unselectStyle ??
          theme.textTheme.labelSmall?.copyWith(
            color:
                (colorType != null ? colorData?.getColor(colorType!) : null) ??
                theme.colorScheme.primary,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: changeDuration ?? const Duration(milliseconds: 200),
      child: FilledButton(
        key: ValueKey<bool>(selected),
        onPressed: onPressed != null ? () => onPressed!(monthday) : null,
        style: ElevatedButton.styleFrom(
          fixedSize: size ?? const Size.square(24.0),
          shape: const CircleBorder(),
          backgroundColor: getBackgroundColor(context),
          elevation: selected ? elevation : null,
        ),
        child: Text(monthday.toString(), style: getTextStyle(context)),
      ),
    );
  }
}
