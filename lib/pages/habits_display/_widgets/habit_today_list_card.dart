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
import '../../../l10n/localizations.dart';
import '../../../models/habit_daily_record_form.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_form.dart';
import '../../../models/habit_summary.dart';
import '../../../theme/color.dart';
import '../../../widgets/widgets.dart';
import '../widgets.dart';

class HabitTodayListCard extends StatefulWidget {
  final HabitSummaryData data;
  final bool expanded;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onMainPressed;
  final HabitTodayListCardButtonCallbacks? buttonCallbacked;

  const HabitTodayListCard(
      {super.key,
      required this.data,
      required this.expanded,
      this.onExpandChanged,
      this.onMainPressed,
      this.buttonCallbacked});

  @override
  State<HabitTodayListCard> createState() => _HabitTodayListCardState();
}

class _HabitTodayListCardState extends State<HabitTodayListCard> {
  bool? _expanded;

  bool get _effectiveExpanded => _expanded ?? widget.expanded;

  @override
  void didUpdateWidget(covariant HabitTodayListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != _effectiveExpanded) {
      setState(() {
        _expanded = null;
      });
    }
  }

  Text getKeepDaysText(int days, [L10n? l10n]) =>
      Text("Kept it up for $days days");

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    final l10n = L10n.of(context);
    final data = widget.data;
    final record = data.getRecordByDate(HabitDate.now());
    final color = colorData?.getColor(data.colorType);
    final trailing = IconButton.filled(
        onPressed: widget.onMainPressed ?? () {},
        style: IconButton.styleFrom(
            backgroundColor: colorData?.getColorContainer(data.colorType),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: color ?? Colors.transparent, width: 1), // 边框
            )),
        icon: HabitDailyStatusIcon(
          colorType: data.colorType,
          habitDailyStatus: HabitRecordStatus.done,
          habitDailyRecordForm: HabitDailyRecordForm.getImp(
              type: data.type,
              value: record?.value ?? data.dailyGoal,
              targetValue: data.dailyGoal,
              extraTargetValue: data.dailyGoalExtra),
        ));

    final body = ListTile(
      isThreeLine: true,
      title: Text(data.name),
      titleTextStyle: themeData.textTheme.titleLarge,
      trailing: trailing,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpandedSection(
            expand: _effectiveExpanded,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(data.progress.toStringAsFixed(2)),
              titleTextStyle: themeData.textTheme.titleLarge,
              subtitle: LinearProgressIndicator(value: data.progress / 100),
            ),
          ),
          SizedBox(
              width: double.infinity,
              child: getKeepDaysText(data.duringFromStartDate.inDays, l10n)),
        ],
      ),
    );

    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
    final extra = ExpandedSection(
      expand: _effectiveExpanded,
      child: Padding(
        padding: kListTileContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            ColorfulMarkdownBlock(
                data: data.desc,
                colorType: data.colorType,
                textScaler: textScaler),
            _HabitTodayListCardButtonGroup(
              data: data,
              onDualPressed: widget.buttonCallbacked?.onDualPressed,
              onSkipPressed: widget.buttonCallbacked?.onSkipPressed,
              onSkipWithPressed: widget.buttonCallbacked?.onSkipWithPressed,
              onValueWithPressed: widget.buttonCallbacked?.onValueWithPressed,
            ),
          ],
        ),
      ),
    );

    final cardBody = InkWell(
      borderRadius: kHabitTodayCardShape.borderRadius.resolve(null),
      onTap: () => setState(() {
        _expanded = !_effectiveExpanded;
        widget.onExpandChanged?.call(_effectiveExpanded);
      }),
      child: Column(
        children: [body, extra],
      ),
    );

    return _effectiveExpanded
        ? Card(child: cardBody)
        : Card.filled(child: cardBody);
  }
}

class HabitTodayListCardButtonCallbacks {
  final VoidCallback? onDualPressed;
  final VoidCallback? onSkipPressed;
  final VoidCallback? onValueWithPressed;
  final VoidCallback? onSkipWithPressed;

  const HabitTodayListCardButtonCallbacks({
    this.onDualPressed,
    this.onSkipPressed,
    this.onValueWithPressed,
    this.onSkipWithPressed,
  });
}

class _HabitTodayListCardButtonGroup extends StatelessWidget {
  final HabitSummaryData data;
  final VoidCallback? onDualPressed;
  final VoidCallback? onSkipPressed;
  final VoidCallback? onValueWithPressed;
  final VoidCallback? onSkipWithPressed;

  const _HabitTodayListCardButtonGroup({
    required this.data,
    this.onDualPressed,
    this.onSkipPressed,
    this.onValueWithPressed,
    this.onSkipWithPressed,
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;
    final extraGoal = data.dailyGoalExtra;
    final buttons = [
      if (extraGoal != null)
        TextButton(onPressed: onDualPressed, child: Text(extraGoal.toString())),
      TextButton(onPressed: onSkipPressed, child: Text("Skip")),
      TextButton(onPressed: onValueWithPressed, child: Text("Done With...")),
      TextButton(onPressed: onSkipWithPressed, child: Text("Skip With...")),
    ];

    double estimateButtonWidth(BuildContext context, Widget btn) {
      final text = (btn as TextButton).child as Text;
      final font = DefaultTextStyle.of(context).style;
      final tp = TextPainter(
        text: TextSpan(text: text.data, style: font),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width + spacing;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = buttons.fold<double>(0, (sum, btn) {
              return sum + estimateButtonWidth(context, btn) + spacing;
            }) +
            spacing;
        if (constraints.maxWidth >= minWidth) {
          return Row(
              children: List.generate(
            buttons.length * 2 - 1,
            (index) =>
                index.isEven ? buttons[index ~/ 2] : const Spacer(flex: 2),
          ));
        } else {
          return Wrap(spacing: spacing, children: buttons);
        }
      },
    );
  }
}
