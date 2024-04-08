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

import '../../common/types.dart';
import '../../extension/color_extensions.dart';
import '../../extension/custom_color_extensions.dart';
import '../../model/habit_detail_chart.dart';
import '../../provider/habit_detail.dart';
import '../../theme/color.dart';

mixin HabitHeatmapColorChooseMixin<T extends StatefulWidget> on State<T> {
  Map<HabitDailyGoal, Color> buildHeatmapColorMap(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final viewmodel = context.read<HabitDetailViewModel>();
    return {
      HabitHeatMapColorMapDefine.uncomplate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withOpacity(0.2),
      HabitHeatMapColorMapDefine.partiallyCompleted:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withOpacity(0.3),
      HabitHeatMapColorMapDefine.autoComplate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .withOpacity(0.5),
      HabitHeatMapColorMapDefine.complate:
          (colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary),
      HabitHeatMapColorMapDefine.overfulfil:
          (colorData?.getColor(viewmodel.habitColorType!) ??
                  themeData.colorScheme.primary)
              .darken(0.2),
    };
  }

  Map<HabitDailyGoal, Color> buildHeatmapValueColorMap(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();
    final viewmodel = context.read<HabitDetailViewModel>();
    return {
      HabitHeatMapColorMapDefine.uncomplate:
          colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary,
      HabitHeatMapColorMapDefine.partiallyCompleted:
          colorData?.getColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.primary,
      HabitHeatMapColorMapDefine.autoComplate:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
      HabitHeatMapColorMapDefine.complate:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
      HabitHeatMapColorMapDefine.overfulfil:
          colorData?.getOnColor(viewmodel.habitColorType!) ??
              themeData.colorScheme.onPrimary,
    };
  }
}
