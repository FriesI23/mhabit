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
import 'package:intl/intl.dart';

import '../../common/utils.dart';
import '../../extensions/custom_color_extensions.dart';
import '../../models/habit_form.dart';
import '../../theme/color.dart';

class WeekPickerCell extends StatelessWidget {
  final int weekday;
  final Size? size;
  final TextStyle? unselectStyle;
  final TextStyle? selectedStyle;
  final bool selected;
  final HabitColorType? colorType;
  final Duration? changeDuration;
  final double elevation;
  final void Function(int weekday)? onPressed;

  const WeekPickerCell({
    super.key,
    required this.weekday,
    this.size,
    this.unselectStyle,
    this.selectedStyle,
    this.selected = false,
    this.colorType,
    this.changeDuration,
    this.elevation = 2.0,
    this.onPressed,
  }) : assert(weekday > 0 && weekday < 8);

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
          theme.textTheme.labelMedium?.copyWith(
            color: (colorType != null
                    ? colorData?.getOnColor(colorType!)
                    : null) ??
                theme.colorScheme.onPrimary,
          );
    } else {
      return unselectStyle ??
          theme.textTheme.labelMedium?.copyWith(
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
        onPressed: onPressed != null ? () => onPressed!(weekday) : null,
        style: ElevatedButton.styleFrom(
          fixedSize: size ?? const Size.square(48.0),
          shape: const CircleBorder(),
          backgroundColor: getBackgroundColor(context),
          elevation: selected ? elevation : null,
        ),
        child: Text(
          DateFormat("EEE", Localizations.localeOf(context).toLanguageTag())
              .format(getProtoDateWithFirstDay(weekday)),
          style: getTextStyle(context),
        ),
      ),
    );
  }
}
