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
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../component/widget.dart';
import '../../extension/custom_color_extensions.dart';
import '../../model/habit_form.dart';
import '../../model/material_localizations.dart';
import '../../provider/app_first_day.dart';
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

class HabitDatePickerDialog extends StatelessWidget {
  final DateTime date;
  final HabitColorType colorType;

  const HabitDatePickerDialog(this.date, this.colorType, {super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final DateTime now = DateTime.now();
    final firstday =
        context.select<AppFirstDayViewModel, int>((vm) => vm.firstDay);
    return Theme(
      data: themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(
          primary: colorData?.getColor(colorType),
          onPrimary: colorData?.getOnColor(colorType),
          secondaryContainer: colorData?.getColorContainer(colorType),
          onSecondaryContainer: colorData?.getColorOnContainer(colorType),
          outline: colorData?.getColor(colorType),
        ),
      ),
      child: Localizations.override(
        context: context,
        delegates: appLocalizationsDelegates
            .map((e) => e is LocalizationsDelegate<MaterialLocalizations>
                ? MaterialLocalizatiosProxy.delegateProxyOf(e,
                    overrides: {'firstDayOfWeekIndex': firstday % 7})
                : e)
            .toList(),
        child: HabitDatetimePickerDialog(
          currentDateTime: now,
          currentDate: now,
          initialDate: date,
          firstDate: DateTime.fromMillisecondsSinceEpoch(
              minHabitMillisecondsSinceEpoch),
          lastDate: DateTime.fromMillisecondsSinceEpoch(
              maxHabitMillisecondsSinceEpoch),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
        ),
      ),
    );
  }
}
