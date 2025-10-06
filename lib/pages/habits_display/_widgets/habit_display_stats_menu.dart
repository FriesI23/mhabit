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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:named_html_color/html_color.dart';
import 'package:provider/provider.dart';

import '../../../extensions/num_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_stat.dart';
import '../../../providers/habit_summary.dart';
import '../../../theme/icon.dart';

Future<void> showHabitDisplayStatsMenuDialog({
  required BuildContext context,
  required HabitSummaryViewModel summary,
}) async {
  return showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider.value(
      value: summary,
      builder: (context, child) => Consumer<HabitSummaryViewModel>(
        builder: (context, value, child) => HabitDisplayStatsMenuDialog(
          statisticsData: value.statisticsData,
        ),
      ),
    ),
  );
}

class HabitDisplayStatsMenuDialog extends StatelessWidget {
  static const double dialogMaxWidth = 400.0;

  final HabitSummaryStatisticsData statisticsData;

  const HabitDisplayStatsMenuDialog({
    super.key,
    this.statisticsData = HabitSummaryStatisticsData.zero,
  });

  List<Widget> _buildCurrent(BuildContext context) {
    final l10n = L10n.of(context);
    final children = <Widget>[
      ListTile(
        dense: true,
        title: l10n != null
            ? Text(l10n.habitDisplay_statsMenu_statSubgroupText)
            : const Text("Current"),
        visualDensity: VisualDensity.compact,
      ),
      ListTile(
        title: l10n != null
            ? Text(l10n.habitDisplay_statsMenu_completedTileText)
            : const Text("Completed"),
        leading: const Icon(HabitProgressIcons.progress_100percent),
        trailing: Text(statisticsData.currentComplatedCount.toString()),
        visualDensity: VisualDensity.compact,
      ),
      ListTile(
        title: l10n != null
            ? Text(l10n.habitDisplay_statsMenu_inProgresTileText)
            : const Text("In Progress"),
        leading: const Icon(HabitProgressIcons.progress_50percent),
        trailing: Text(statisticsData.currentInProgressCount.toString()),
        visualDensity: VisualDensity.compact,
      ),
      ListTile(
        title: l10n != null
            ? Text(l10n.habitDisplay_statsMenu_archivedTileText)
            : const Text("Archived"),
        leading: const Icon(Icons.inventory_2_outlined),
        trailing: Text(statisticsData.currentArchivedCount.toString()),
        visualDensity: VisualDensity.compact,
      ),
    ];

    return children;
  }

  Icon? _getMostPopularityIconByIndex(int index) {
    switch (index) {
      case 0:
        return const Icon(HabitProgressIcons.numeric_1_circle_outline,
            color: HTMLColor.goldenrod);
      case 1:
        return const Icon(HabitProgressIcons.numeric_2_circle_outline,
            color: HTMLColor.gray);
      case 2:
        return const Icon(HabitProgressIcons.numeric_3_circle_outline,
            color: HTMLColor.brown);
      default:
        return null;
    }
  }

  List<Widget> _buildMostPopularity(BuildContext context) {
    final l10n = L10n.of(context);
    final viewmodel = context.read<HabitSummaryViewModel>();
    final now = HabitDate.now();
    final children = <Widget>[];

    var crtIndex = 0;
    for (var sd in statisticsData.currentPopularityData) {
      if (crtIndex > 2) break;
      final habit = viewmodel.getHabit(sd.uuid);
      if (habit == null) continue;
      final changed = sd.getLast30DaysChanged(now);
      final symbol = changed > 0
          ? "+"
          : changed < 0
              ? "-"
              : "";
      children.add(
        ListTile(
          title: Text(habit.name),
          leading: _getMostPopularityIconByIndex(crtIndex),
          trailing: Text("$symbol${changed.toStringAsFixedWithMin(2)}"),
          visualDensity: VisualDensity.compact,
        ),
      );
      crtIndex += 1;
    }

    if (children.isNotEmpty) {
      children.insert(
        0,
        ListTile(
          dense: true,
          title: l10n != null
              ? Text(l10n.habitDisplay_statsMenu_popularitySubgroupText)
              : const Text("Popularity (Last 30 days)"),
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        scrollable: true,
        contentPadding: const EdgeInsets.only(bottom: 24, top: 24),
        content: SizedBox(
          width: math.min(constraints.maxWidth, dialogMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ..._buildCurrent(context),
              ..._buildMostPopularity(context),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: const [CloseButton()],
      ),
    );
  }
}
