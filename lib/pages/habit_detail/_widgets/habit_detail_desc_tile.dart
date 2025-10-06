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
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../providers/habit_detail.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';
import 'habit_detail_chart_title.dart';
import 'habit_detail_tile_list.dart';

class HabitDetailDescTile extends StatelessWidget {
  const HabitDetailDescTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final viewmodel = context.read<HabitDetailViewModel>();
    final TextScaler textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
    final descMinHeight = textScaler.scale(kHabitDetailFreqChartTitleHeight);

    return HabitDetailTileList(
      title: HabitDetailChartTitle(
          title: l10n?.habitDetail_descSubgroup_title ?? "Desc"),
      contentChildren: [
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: descMinHeight, minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ColorfulMarkdownBlock(
              data: viewmodel.habitDesc,
              colorType: viewmodel.habitColorType,
              textScaler: textScaler,
            ),
          ),
        ),
      ],
    );
  }
}
