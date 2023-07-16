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

import '../../common/types.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../extension/custom_color_extensions.dart';
import '../../model/habit_daily_record_form.dart';
import '../../model/habit_form.dart';
import '../../theme/color.dart';

class HabitDailyStatusContainer extends StatelessWidget {
  final double? width;
  final double? height;
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

  const HabitDailyStatusContainer(
      {super.key,
      this.width,
      this.height,
      this.padding,
      required this.date,
      this.colorType = HabitColorType.cc1,
      required this.habitDailyStatus,
      required this.habitDailyRecordForm,
      this.onPressed,
      this.onLongPressed,
      this.onDoublePressed,
      this.enabled = true,
      this.isAutoComplated = false});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    var habitListTileColor = themeData.extension<HabitSummaryListTileColor>();
    var globalColor = themeData.extension<HabitSummaryDailyStatusColor>();
    var defaultColor = _getDefaultDailyStatusColor(themeData);

    Widget withAutoMarkStatus() {
      return Icon(
        Icons.done_outline,
        color: habitListTileColor?.dailyStatusTheme?.autoMark ??
            globalColor?.autoMark ??
            defaultColor.autoMark,
      );
    }

    Widget withUnknownStatus() {
      return Icon(
        Icons.question_mark_outlined,
        color: habitListTileColor?.dailyStatusTheme?.unknown ??
            globalColor?.unknown ??
            defaultColor.unknown,
      );
    }

    Widget withSkipStatus() {
      return Icon(
        Icons.remove_outlined,
        color: habitListTileColor?.dailyStatusTheme?.skip ??
            globalColor?.skip ??
            defaultColor.skip,
      );
    }

    Widget withDoneAndOkStatus() {
      return Icon(
        Icons.check_outlined,
        color: habitListTileColor?.dailyStatusTheme?.doneAndOk ??
            globalColor?.doneAndOk ??
            defaultColor.doneAndOk,
      );
    }

    Widget withDoneAndZeroStatus() {
      return Icon(
        Icons.close_sharp,
        color: habitListTileColor?.dailyStatusTheme?.doneAndZero ??
            globalColor?.doneAndZero ??
            defaultColor.doneAndZero,
      );
    }

    Widget withDoneAndGoodjobStatus() {
      return Text(
        NumberFormat.compact(
                locale: Localizations.localeOf(context).toLanguageTag())
            .format(habitDailyRecordForm.value),
        style: TextStyle(
          color: habitListTileColor?.dailyStatusTheme?.doneAndGoodjob ??
              globalColor?.doneAndGoodjob ??
              defaultColor.doneAndGoodjob,
        ),
      );
    }

    Widget withDoneAndTryhardStatus() {
      return Text(
        NumberFormat.compact(
                locale: Localizations.localeOf(context).toLanguageTag())
            .format(habitDailyRecordForm.value),
        style: TextStyle(
          color: habitListTileColor?.dailyStatusTheme?.doneAndTryhard ??
              globalColor?.doneAndTryhard ??
              defaultColor.doneAndTryhard,
        ),
      );
    }

    Widget getButtonContent() {
      if (!enabled) {
        return const SizedBox();
      }
      switch (habitDailyStatus) {
        case HabitRecordStatus.unknown:
          if (isAutoComplated) {
            return withAutoMarkStatus();
          } else {
            return withUnknownStatus();
          }
        case HabitRecordStatus.skip:
          return withSkipStatus();
        case HabitRecordStatus.done:
          switch (habitDailyRecordForm.complateStatus) {
            case HabitDailyComplateStatus.ok:
              return withDoneAndOkStatus();
            case HabitDailyComplateStatus.goodjob:
              return withDoneAndGoodjobStatus();
            case HabitDailyComplateStatus.noeffect:
            case HabitDailyComplateStatus.tryhard:
              return withDoneAndTryhardStatus();
            case HabitDailyComplateStatus.zero:
              if (isAutoComplated) {
                return withAutoMarkStatus();
              } else {
                return withDoneAndZeroStatus();
              }
            default:
              return const SizedBox();
          }
      }
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      height: height,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onLongPress: enabled && onLongPressed != null
                ? () => onLongPressed!(date, habitDailyStatus)
                : null,
            onDoubleTap: enabled && onDoublePressed != null
                ? () => onDoublePressed!(date, habitDailyStatus)
                : null,
            child: IconButton(
              onPressed: enabled && onPressed != null
                  ? () => onPressed!(date, habitDailyStatus)
                  : null,
              icon: getButtonContent(),
            ),
          ),
        ],
      ),
    );
  }

  HabitSummaryDailyStatusColor _getDefaultDailyStatusColor(
      ThemeData themeData) {
    CustomColors? colorData = themeData.extension<CustomColors>();
    return HabitSummaryDailyStatusColor(
      autoMark: colorData?.getColor(colorType),
      unknown: themeData.colorScheme.outlineOpacity16,
      skip: colorData?.getColor(colorType),
      doneAndOk: colorData?.getColor(colorType),
      doneAndZero: themeData.colorScheme.outlineOpacity16,
      doneAndGoodjob: colorData?.getColor(colorType),
      doneAndTryhard: themeData.colorScheme.outline,
    );
  }
}
