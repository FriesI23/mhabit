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

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../extensions/colorscheme_extensions.dart';
import '../../extensions/custom_color_extensions.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_form.dart';
import '../../theme/color.dart';

const kDefaultHabitDailyStatusContainerIconSize = 28.0;

class HabitDailyStatusContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final HabitRecordDate date;
  final HabitColorType colorType;
  final HabitRecordStatus habitDailyStatus;
  final HabitDailyRecordForm habitDailyRecordForm;
  final void Function(HabitRecordDate date, HabitRecordStatus crt)? onPressed;
  final void Function(HabitRecordDate date, HabitRecordStatus crt)?
  onLongPressed;
  final void Function(HabitRecordDate date, HabitRecordStatus crt)?
  onDoublePressed;
  final bool enabled;
  final bool isAutoComplated;

  const HabitDailyStatusContainer({
    super.key,
    this.width,
    this.height,
    this.iconSize,
    this.padding,
    required this.date,
    this.colorType = HabitColorType.cc1,
    required this.habitDailyStatus,
    required this.habitDailyRecordForm,
    this.onPressed,
    this.onLongPressed,
    this.onDoublePressed,
    this.enabled = true,
    this.isAutoComplated = false,
  });

  double getIconSize() => iconSize ?? kDefaultHabitDailyStatusContainerIconSize;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    return Ink(
      padding: padding ?? const EdgeInsets.all(8.0),
      height: height,
      width: width,
      child: InkWell(
        onTap: enabled && onPressed != null
            ? () => onPressed!(date, habitDailyStatus)
            : null,
        onLongPress: enabled && onLongPressed != null
            ? () => onLongPressed!(date, habitDailyStatus)
            : null,
        onDoubleTap: enabled && onDoublePressed != null
            ? () => onDoublePressed!(date, habitDailyStatus)
            : null,
        customBorder: const CircleBorder(),
        excludeFromSemantics: true,
        child: IconButton(
          iconSize: getIconSize(),
          icon: HabitDailyStatusIcon(
            habitDailyStatus: habitDailyStatus,
            habitDailyRecordForm: habitDailyRecordForm,
            colorType: colorType,
            isAutoComplated: isAutoComplated,
          ),
          onPressed: null,
        ),
      ),
    );
  }
}

class HabitDailyStatusIcon extends StatelessWidget {
  final HabitRecordStatus habitDailyStatus;
  final HabitDailyRecordForm habitDailyRecordForm;
  final HabitColorType colorType;
  final bool isAutoComplated;

  const HabitDailyStatusIcon({
    super.key,
    required this.habitDailyStatus,
    required this.habitDailyRecordForm,
    required this.colorType,
    this.isAutoComplated = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listTileColor = theme.extension<HabitSummaryListTileColor>();
    final globalColor = theme.extension<HabitSummaryDailyStatusColor>();
    final defaultColor = _getDefaultDailyStatusColor(theme);

    Widget withAutoMarkStatus() => Icon(
      kRecordAutoMarkStatusIcon,
      color:
          listTileColor?.dailyStatusTheme?.autoMark ??
          globalColor?.autoMark ??
          defaultColor.autoMark,
    );

    Widget withUnknownStatus() => Icon(
      kRecordUnknownStatusIcon,
      color:
          listTileColor?.dailyStatusTheme?.unknown ??
          globalColor?.unknown ??
          defaultColor.unknown,
    );

    Widget withSkipStatus() => Icon(
      kRecordSkipStatusIcon,
      color:
          listTileColor?.dailyStatusTheme?.skip ??
          globalColor?.skip ??
          defaultColor.skip,
    );

    Widget withDoneAndOkStatus() => Icon(
      kRecordDoneStatusIcon,
      color:
          listTileColor?.dailyStatusTheme?.doneAndOk ??
          globalColor?.doneAndOk ??
          defaultColor.doneAndOk,
    );

    Widget withDoneAndZeroStatus() => Icon(
      kRecordZeroStatusIcon,
      color:
          listTileColor?.dailyStatusTheme?.doneAndZero ??
          globalColor?.doneAndZero ??
          defaultColor.doneAndZero,
    );

    Widget withDoneAndGoodjobStatus() => Text(
      NumberFormat.compact(
        locale: Localizations.localeOf(context).toLanguageTag(),
      ).format(habitDailyRecordForm.value),
      style: TextStyle(
        color:
            listTileColor?.dailyStatusTheme?.doneAndGoodjob ??
            globalColor?.doneAndGoodjob ??
            defaultColor.doneAndGoodjob,
      ),
    );

    Widget withDoneAndTryhardStatus() => Text(
      NumberFormat.compact(
        locale: Localizations.localeOf(context).toLanguageTag(),
      ).format(habitDailyRecordForm.value),
      style: TextStyle(
        color:
            listTileColor?.dailyStatusTheme?.doneAndTryhard ??
            globalColor?.doneAndTryhard ??
            defaultColor.doneAndTryhard,
      ),
    );

    switch (habitDailyStatus) {
      case HabitRecordStatus.unknown:
        return isAutoComplated ? withAutoMarkStatus() : withUnknownStatus();
      case HabitRecordStatus.skip:
        return withSkipStatus();
      case HabitRecordStatus.done:
        switch (habitDailyRecordForm.complateStatus) {
          case HabitDailyComplateStatus.ok:
            return withDoneAndOkStatus();
          case HabitDailyComplateStatus.goodjob:
            return withDoneAndGoodjobStatus();
          case HabitDailyComplateStatus.tryhard:
          case HabitDailyComplateStatus.noeffect:
            return withDoneAndTryhardStatus();
          case HabitDailyComplateStatus.zero:
            return isAutoComplated
                ? withAutoMarkStatus()
                : withDoneAndZeroStatus();
        }
    }
  }

  HabitSummaryDailyStatusColor _getDefaultDailyStatusColor(
    ThemeData themeData,
  ) {
    final CustomColors? colorData = themeData.extension<CustomColors>();
    return HabitSummaryDailyStatusColor(
      autoMark: colorData?.getColor(colorType),
      unknown: themeData.colorScheme.outlineOpacity48,
      skip: colorData?.getColor(colorType),
      doneAndOk: colorData?.getColor(colorType),
      doneAndZero: themeData.colorScheme.outlineOpacity64,
      doneAndGoodjob: colorData?.getColor(colorType),
      doneAndTryhard: themeData.colorScheme.outline,
    );
  }
}
