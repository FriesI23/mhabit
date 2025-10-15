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

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeExtension;

@immutable
class HabitSummaryListTileColor
    extends ThemeExtension<HabitSummaryListTileColor> {
  final Color? titleColor;
  final Color? progressCircleColor;
  final Color? progressCircleBGColor;
  final Color? selectedColor;
  final HabitSummaryDailyStatusColor? dailyStatusTheme;

  const HabitSummaryListTileColor({
    required this.titleColor,
    required this.progressCircleColor,
    required this.progressCircleBGColor,
    required this.selectedColor,
    this.dailyStatusTheme,
  });

  const HabitSummaryListTileColor.build({
    this.titleColor,
    this.progressCircleColor,
    this.progressCircleBGColor,
    this.selectedColor,
    this.dailyStatusTheme,
  });

  @override
  HabitSummaryListTileColor copyWith({
    Color? titleColor,
    Color? progressCircleColor,
    Color? progressCircleBGColor,
    Color? selectedColor,
    HabitSummaryDailyStatusColor? dailyStatusTheme,
  }) {
    return HabitSummaryListTileColor(
      titleColor: titleColor,
      progressCircleColor: progressCircleColor,
      progressCircleBGColor: progressCircleBGColor,
      selectedColor: selectedColor,
      dailyStatusTheme: dailyStatusTheme,
    );
  }

  @override
  HabitSummaryListTileColor lerp(
      covariant ThemeExtension<HabitSummaryListTileColor>? other, double t) {
    if (other is! HabitSummaryListTileColor) return this;
    return HabitSummaryListTileColor(
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      progressCircleColor:
          Color.lerp(progressCircleColor, other.progressCircleColor, t),
      progressCircleBGColor:
          Color.lerp(progressCircleBGColor, other.progressCircleBGColor, t),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
      dailyStatusTheme: dailyStatusTheme?.lerp(other.dailyStatusTheme, t),
    );
  }
}

class HabitSummaryDailyStatusColor
    extends ThemeExtension<HabitSummaryDailyStatusColor> {
  final Color? autoMark;
  final Color? unknown;
  final Color? skip;
  final Color? doneAndOk;
  final Color? doneAndZero;
  final Color? doneAndGoodjob;
  final Color? doneAndTryhard;

  const HabitSummaryDailyStatusColor({
    required this.autoMark,
    required this.unknown,
    required this.skip,
    required this.doneAndOk,
    required this.doneAndZero,
    required this.doneAndGoodjob,
    required this.doneAndTryhard,
  });

  const HabitSummaryDailyStatusColor.build({
    this.autoMark,
    this.unknown,
    this.skip,
    this.doneAndOk,
    this.doneAndZero,
    this.doneAndGoodjob,
    this.doneAndTryhard,
  });

  @override
  HabitSummaryDailyStatusColor copyWith({
    Color? autoMark,
    Color? unknown,
    Color? skip,
    Color? doneAndOk,
    Color? doneAndZero,
    Color? doneAndGoodjob,
    Color? doneAndTryhard,
  }) {
    return HabitSummaryDailyStatusColor(
      autoMark: autoMark,
      unknown: unknown,
      skip: skip,
      doneAndOk: doneAndOk,
      doneAndZero: doneAndZero,
      doneAndGoodjob: doneAndGoodjob,
      doneAndTryhard: doneAndTryhard,
    );
  }

  @override
  HabitSummaryDailyStatusColor lerp(
      covariant ThemeExtension<HabitSummaryDailyStatusColor>? other, double t) {
    if (other is! HabitSummaryDailyStatusColor) return this;
    return HabitSummaryDailyStatusColor(
      autoMark: Color.lerp(autoMark, other.autoMark, t),
      unknown: Color.lerp(unknown, other.unknown, t),
      skip: Color.lerp(skip, other.skip, t),
      doneAndOk: Color.lerp(doneAndOk, other.doneAndOk, t),
      doneAndZero: Color.lerp(doneAndZero, other.doneAndZero, t),
      doneAndGoodjob: Color.lerp(doneAndGoodjob, other.doneAndGoodjob, t),
      doneAndTryhard: Color.lerp(doneAndTryhard, other.doneAndTryhard, t),
    );
  }
}
