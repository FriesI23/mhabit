// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../../extension/custom_color_extensions.dart';
import '../../../logging/helper.dart';
import '../../../model/habit_date.dart';
import '../../../model/habit_summary.dart';
import '../../../theme/color.dart';
import '../../common/widgets.dart';

class HabitSpecialDateViewedTile extends StatelessWidget {
  final HabitSummaryData data;
  final HabitDate date;

  const HabitSpecialDateViewedTile({
    super.key,
    required this.data,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context, ex: [date, data.uuid, data.name]);
    return HabitSummaryListTile(
      data: data,
      startDate: date,
      endDate: date,
      collapsePrt: 30,
      isExtended: false,
      cellBuilder: (context, cell, date) {
        if (date != this.date || date.isBefore(data.startDate)) return cell;
        final themeData = Theme.of(context);
        final colorData = themeData.extension<CustomColors>();
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: colorData?.getColorContainer(data.colorType) ??
                      themeData.colorScheme.primaryContainer,
                  width: 6.0),
            ),
          ),
          child: cell,
        );
      },
    );
  }
}
