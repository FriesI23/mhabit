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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../common/types.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../model/habit_date.dart';
import '../../model/habit_summary.dart';
import '../../theme/color.dart';
import 'habit_summary_list_tile.dart';

const kHabitDisplayListTileHeight = kHabitSummaryListTileHeight;

class HabitDisplayListTile extends StatelessWidget {
  final HabitDate? startDate;
  final HabitDate? endedData;
  final bool isExtended;
  final bool isSelected;
  final bool isInEditMode;
  final HabitSummaryData data;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onHabitRecordPressed;
  final OnHabitSummaryPressCallback? onHabitRecordLongPressed;

  const HabitDisplayListTile({
    super.key,
    this.startDate,
    this.endedData,
    required this.isExtended,
    required this.isSelected,
    required this.isInEditMode,
    required this.data,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onHabitSummaryDataPressed,
    this.onHabitRecordPressed,
    this.onHabitRecordLongPressed,
  });

  ThemeData getThemeData(ThemeData themeData) {
    var color = themeData.extension<HabitSummaryListTileColor>();
    if (data.isArchived) {
      var newColor = color != null
          ? color.copyWith(
              titleColor: themeData.colorScheme.outline,
              progressCircleColor: themeData.colorScheme.outline,
            )
          : HabitSummaryListTileColor.build(
              titleColor: themeData.colorScheme.outline,
              progressCircleColor: themeData.colorScheme.outline,
            );
      var cellColor = themeData.extension<HabitSummaryDailyStatusColor>();
      var newCellColor = cellColor != null
          ? cellColor.copyWith(
              autoMark: themeData.colorScheme.outline,
              skip: themeData.colorScheme.outline,
              doneAndGoodjob: themeData.colorScheme.outline,
              doneAndOk: themeData.colorScheme.outline,
            )
          : HabitSummaryDailyStatusColor.build(
              autoMark: themeData.colorScheme.outline,
              skip: themeData.colorScheme.outline,
              doneAndGoodjob: themeData.colorScheme.outline,
              doneAndOk: themeData.colorScheme.outline,
            );
      var newExtensions = Map.of(themeData.extensions);
      newExtensions[newColor.type] = newColor;
      newExtensions[newCellColor.type] = newCellColor;
      return themeData.copyWith(extensions: newExtensions.values);
    }
    return themeData;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: getThemeData(Theme.of(context)),
      child: Builder(
        builder: (context) {
          ThemeData themeData = Theme.of(context);
          var bgcolor = themeData.colorScheme.onSurfaceOpacity08;
          return InkWell(
            onTap: onHabitSummaryDataPressed != null
                ? () => onHabitSummaryDataPressed!(data.uuid)
                : null,
            splashColor: isSelected ? themeData.colorScheme.surface : bgcolor,
            highlightColor: Colors.transparent,
            enableFeedback: isInEditMode ? false : true,
            child: HabitSummaryListTile(
              key: ValueKey("${data.uuid}|$isSelected"),
              height: kHabitDisplayListTileHeight,
              data: data,
              startDate: startDate,
              endDate: endedData,
              isExtended: isExtended,
              isSelected: isSelected,
              selectColor: bgcolor,
              verticalScrollController: verticalScrollController,
              horizonalScrollControllerGroup: horizonalScrollControllerGroup,
              onCellPressed: onHabitRecordPressed,
              onCellLongPressed: onHabitRecordLongPressed,
            ),
          );
        },
      ),
    );
  }
}
