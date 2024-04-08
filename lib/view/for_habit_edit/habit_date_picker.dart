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

import '../../common/consts.dart';
import '../../component/widget.dart';
import '../../extension/custom_color_extensions.dart';
import '../../model/habit_form.dart';
import '../../theme/color.dart';

Future<DateTime?> showHabitDatePickerDialog({
  required BuildContext context,
  required DateTime date,
  required HabitColorType colorType,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => HabitDatePickerDialog(date, colorType),
  );
}

class HabitDatePickerDialog extends StatefulWidget {
  final DateTime date;
  final HabitColorType colorType;

  const HabitDatePickerDialog(this.date, this.colorType, {super.key});

  @override
  State<StatefulWidget> createState() => _HabitDatePickerDialogView();
}

class _HabitDatePickerDialogView extends State<HabitDatePickerDialog> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final DateTime now = DateTime.now();
    return Theme(
      data: themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(
          primary: colorData?.getColor(widget.colorType),
          onPrimary: colorData?.getOnColor(widget.colorType),
          secondaryContainer: colorData?.getColorContainer(widget.colorType),
          onSecondaryContainer:
              colorData?.getColorOnContainer(widget.colorType),
          outline: colorData?.getColor(widget.colorType),
        ),
      ),
      child: HabitDatetimePickerDialog(
        currentDateTime: now,
        currentDate: now,
        initialDate: widget.date,
        firstDate:
            DateTime.fromMillisecondsSinceEpoch(minHabitMillisecondsSinceEpoch),
        lastDate:
            DateTime.fromMillisecondsSinceEpoch(maxHabitMillisecondsSinceEpoch),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      ),
    );
  }
}
