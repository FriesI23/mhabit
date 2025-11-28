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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  final bool canScroll;
  final bool? showProgessInfo;
  final bool? showDescInfo;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onMainPressed;
  final HabitTodayListCardButtonCallbacks? buttonCallbacked;

  const HabitTodayListCard(
      {super.key,
      required this.data,
      required this.expanded,
      required this.canScroll,
      this.showProgessInfo,
      this.showDescInfo,
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
      trailing: const Icon(null),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpandedSection(
            expand: _effectiveExpanded || widget.showProgessInfo == true,
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

    final bottomButtons = _HabitTodayListCardButtonGroup(
      data: data,
      onDualPressed: widget.buttonCallbacked?.onDualPressed,
      onSkipPressed: widget.buttonCallbacked?.onSkipPressed,
      onSkipWithPressed: widget.buttonCallbacked?.onSkipWithPressed,
      onValueWithPressed: widget.buttonCallbacked?.onValueWithPressed,
    );

    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
    final extra = ExpandedSection(
      expand: _effectiveExpanded || widget.showDescInfo == true,
      child: Padding(
        padding: kListTileContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            ColorfulMarkdownBlock(
                data: data.desc,
                selectable: false,
                colorType: data.colorType,
                textScaler: textScaler),
            if (!widget.canScroll) bottomButtons,
          ],
        ),
      ),
    );

    Widget buildListCardBody() => Column(children: [body, extra]);

    Widget buildScrollableListCardBody() => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [body, extra]),
              ),
            ),
            ExpandedSection(
                expand: _effectiveExpanded, child: bottomButtons), // 固定在底部
          ],
        );

    final cardBodyContent =
        widget.canScroll ? buildScrollableListCardBody() : buildListCardBody();

    final cardBody = InkWell(
      borderRadius: kHabitTodayCardShape.borderRadius.resolve(null),
      onTap: () => setState(() {
        _expanded = !_effectiveExpanded;
        widget.onExpandChanged?.call(_effectiveExpanded);
      }),
      child: Stack(
        children: [
          cardBodyContent,
          Positioned(right: 16, top: 12, child: trailing),
        ],
      ),
    );

    return _effectiveExpanded
        ? Card(elevation: 3.0, child: cardBody)
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
    const spacing = 4.0;
    final extraGoal = data.dailyGoalExtra;
    final l10n = L10n.of(context);

    final buttons = <Widget>[
      if (extraGoal != null)
        TextButton(onPressed: onDualPressed, child: Text(extraGoal.toString())),
      TextButton(
          onPressed: onSkipPressed, child: const Icon(MdiIcons.minusThick)),
      TextButton.icon(
          onPressed: onValueWithPressed,
          icon: const Icon(MdiIcons.checkboxMarkedOutline),
          label: Text(l10n?.habitToday_card_donePlusButton_label ?? "Done +")),
      TextButton.icon(
          onPressed: onSkipWithPressed,
          icon: const Icon(MdiIcons.minusBoxOutline),
          label: Text(l10n?.habitToday_card_skipPlusButton_label ?? "Skip +")),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          buttons.length * 2 - 1,
          (index) => index.isEven
              ? buttons[index ~/ 2]
              : const SizedBox(width: spacing),
        ),
      ),
    );
  }
}
