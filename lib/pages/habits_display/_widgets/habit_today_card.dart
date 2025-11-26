// Copyright 2025 Fries_I23
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

import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_summary.dart';
import '../../../theme/color.dart';
import 'habit_today_list_card.dart';

const kHabitTodayCardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)));

class HabitTodayCard extends StatelessWidget {
  final HabitSummaryData data;
  final bool selected;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onMainPressed;
  final HabitTodayListCardButtonCallbacks? buttonCallbacked;

  final bool _isGridView;

  const HabitTodayCard({
    super.key,
    required this.data,
    this.selected = false,
    this.onExpandChanged,
    this.onMainPressed,
    this.buttonCallbacked,
  }) : _isGridView = false;

  const HabitTodayCard.grid({
    super.key,
    required this.data,
    this.selected = false,
    this.onExpandChanged,
    this.onMainPressed,
    this.buttonCallbacked,
  }) : _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    return Theme(
      data: themeData.copyWith(
          colorScheme: themeData.colorScheme
              .copyWith(primary: colorData?.getColor(data.colorType))),
      child: HabitTodayListCard(
          data: data,
          expanded: selected,
          canScroll: _isGridView,
          showProgessInfo: _isGridView,
          showDescInfo: _isGridView,
          onExpandChanged: onExpandChanged,
          onMainPressed: onMainPressed,
          buttonCallbacked: buttonCallbacked),
    );
  }
}
