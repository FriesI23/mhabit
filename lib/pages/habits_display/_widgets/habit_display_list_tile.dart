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

import '../../../common/types.dart';
import '../../../extensions/colorscheme_extensions.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_summary.dart';
import '../../../theme/color.dart';
import '../../common/widgets.dart';

class HabitDisplayListTile extends StatelessWidget {
  final HabitDate? startDate;
  final HabitDate? endedData;
  final bool isExtended;
  final bool isSelected;
  final bool isInEditMode;
  final int? collapsePrt;
  final double? height;
  final bool compactVisual;
  final HabitSummaryData data;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final void Function(HabitUUID uuid)? onHabitSummaryDataPressed;
  final OnHabitSummaryPressCallback? onHabitRecordPressed;
  final OnHabitSummaryPressCallback? onHabitRecordLongPressed;
  final OnHabitSummaryPressCallback? onHabitRecordDoublePressed;

  const HabitDisplayListTile({
    super.key,
    this.startDate,
    this.endedData,
    required this.isExtended,
    required this.isSelected,
    required this.isInEditMode,
    this.collapsePrt,
    this.height,
    this.compactVisual = false,
    required this.data,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onHabitSummaryDataPressed,
    this.onHabitRecordPressed,
    this.onHabitRecordLongPressed,
    this.onHabitRecordDoublePressed,
  });

  ThemeData getThemeData(ThemeData themeData) {
    Iterable<ThemeExtension<dynamic>>? extensions;
    TextTheme? textTheme;

    Iterable<ThemeExtension<dynamic>> buildArchivedHabitThemeExtensions() {
      final color = (themeData.extension<HabitSummaryListTileColor>() ??
              const HabitSummaryListTileColor.build())
          .copyWith(
        titleColor: themeData.colorScheme.outline,
        progressCircleColor: themeData.colorScheme.outline,
      );
      final cellColor = (themeData.extension<HabitSummaryDailyStatusColor>() ??
              const HabitSummaryDailyStatusColor.build())
          .copyWith(
        autoMark: themeData.colorScheme.outline,
        skip: themeData.colorScheme.outline,
        doneAndGoodjob: themeData.colorScheme.outline,
        doneAndOk: themeData.colorScheme.outline,
      );
      final newExtensions = Map.of(themeData.extensions);
      newExtensions[color.type] = color;
      newExtensions[cellColor.type] = cellColor;
      return newExtensions.values;
    }

    TextTheme? buildHabitTitleTheme() => compactVisual
        ? themeData.textTheme.copyWith(
            bodyLarge: themeData.textTheme.bodyMedium,
          )
        : null;

    if (data.isArchived || data.isDeleted) {
      extensions = buildArchivedHabitThemeExtensions();
    }

    textTheme = buildHabitTitleTheme();

    return themeData.copyWith(
      extensions: extensions,
      textTheme: textTheme,
    );
  }

  EdgeInsets getTitlePadding() => compactVisual
      ? const EdgeInsets.fromLTRB(4, 2, 2, 4)
      : const EdgeInsets.fromLTRB(8, 4, 4, 8);

  EdgeInsets? getItemPadding() =>
      compactVisual ? const EdgeInsets.all(2.0) : const EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: getThemeData(Theme.of(context)),
      child: Builder(
        builder: (context) {
          final ThemeData themeData = Theme.of(context);
          final bgcolor = themeData.colorScheme.onSurfaceOpacity08;
          return InkWell(
            onTap: onHabitSummaryDataPressed != null
                ? () => onHabitSummaryDataPressed!(data.uuid)
                : null,
            splashColor: isSelected ? themeData.colorScheme.surface : bgcolor,
            highlightColor: Colors.transparent,
            enableFeedback: isInEditMode ? false : true,
            child: HabitSummaryListTile(
              key: ValueKey("${data.uuid}|$isSelected"),
              height: height,
              titlePadding: getTitlePadding(),
              itemPadding: getItemPadding(),
              data: data,
              startDate: startDate,
              endDate: endedData,
              isExtended: isExtended,
              isSelected: isSelected,
              selectColor: bgcolor,
              collapsePrt: collapsePrt,
              verticalScrollController: verticalScrollController,
              horizonalScrollControllerGroup: horizonalScrollControllerGroup,
              onCellPressed: onHabitRecordPressed,
              onCellLongPressed: onHabitRecordLongPressed,
              onCellDoublePressed: onHabitRecordDoublePressed,
            ),
          );
        },
      ),
    );
  }
}
