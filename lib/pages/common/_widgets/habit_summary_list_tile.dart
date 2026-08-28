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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../../common/types.dart';
import '../../../extensions/colorscheme_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_daily_record_form.dart';
import '../../../models/habit_form.dart';
import '../../../models/habit_summary.dart';
import '../../../theme/color.dart';
import '../../../utils/app_clock.dart';
import '../../../widgets/widgets.dart';

const kDefaultHabitSummaryListTileHeight = 64.0;
const kMaxHabitSummaryListTileTextScale = 1.3;
const int kHabitSummaryListTilMinShowDate = 1;

class HabitSummaryListTile extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? canScroll;
  final bool isExtended;
  final bool isSelected;
  final Color? selectColor;
  final HabitSummaryData data;
  final double? _height;
  final EdgeInsets? _titlePadding;
  final EdgeInsets? itemPadding;
  final EdgeInsets trackPadding;
  final HabitListTileGeometry geometry;
  final Widget Function(
    BuildContext context,
    Widget cell,
    HabitRecordDate date,
  )?
  cellBuilder;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final OnHabitSummaryPressCallback? onCellPressed;
  final OnHabitSummaryPressCallback? onCellLongPressed;
  final OnHabitSummaryPressCallback? onCellDoublePressed;

  const HabitSummaryListTile({
    super.key,
    this.startDate,
    this.endDate,
    this.canScroll,
    required this.isExtended,
    this.isSelected = false,
    this.selectColor,
    required this.data,
    this._height,
    this._titlePadding,
    this.itemPadding,
    this.trackPadding = kDefaultHabitListTileTrackPadding,
    required this.geometry,
    this.cellBuilder,
    this.scrollPhysicsBuilder,
    this.horizonalScrollControllerGroup,
    this.onCellPressed,
    this.onCellLongPressed,
    this.onCellDoublePressed,
  });

  @override
  State<StatefulWidget> createState() => _HabitSummaryListTile();
}

class _HabitSummaryListTile extends State<HabitSummaryListTile> {
  late final ScrollController? _horizonalScrollController;

  @override
  void initState() {
    super.initState();
    _horizonalScrollController = widget.horizonalScrollControllerGroup
        ?.addAndGet();
  }

  @override
  void dispose() {
    _horizonalScrollController?.dispose();
    super.dispose();
  }

  EdgeInsets get titlePadding => widget._titlePadding != null
      ? widget._titlePadding!
      : const EdgeInsets.fromLTRB(8, 4, 4, 8);

  double get height => widget._height != null
      ? widget._height!
      : kDefaultHabitSummaryListTileHeight;

  HabitSummaryData get data => widget.data;

  TextScaler getTextScaler(BuildContext context) => MediaQuery.textScalerOf(
    context,
  ).clamp(maxScaleFactor: kMaxHabitSummaryListTileTextScale);

  Widget _buildProgressCircle(
    BuildContext context, {
    Color? color,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: HabitProgressIndicator(
        value: data.progress.toDouble() / 100,
        color: color,
        backgroundColor: backgroundColor,
        strokeWidth: getTextScaler(context).scale(6.0),
        isComplated: data.isComplated,
        isArchived: data.isArchived,
        isDeleted: data.isDeleted,
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context, {
    Color? color,
    required TextStyle textStyle,
    required bool isExtended,
  }) {
    return Flexible(
      child: Padding(
        padding: titlePadding,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isExtended ? 0.2 : 1.0,
          child: Text(
            data.name,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: false,
            textScaler: getTextScaler(context),
          ),
        ),
      ),
    );
  }

  Widget? _buildCellItem(
    BuildContext context,
    int index,
    double columnExtent,
    DateTime crtDate,
  ) {
    final showDate = HabitRecordDate.dateTime(
      crtDate.subtract(Duration(days: index)),
    );
    final record = data.getRecordByDate(showDate);
    final isAutoComplated = data.isRecordAutoComplated(showDate);

    final recordCell = HabitDailyStatusContainer(
      date: showDate,
      padding: widget.itemPadding,
      color: data.color,
      habitDailyRecordForm: HabitDailyRecordForm.getImp(
        type: data.type,
        value: record != null ? record.value : 0.0,
        targetValue: data.dailyGoal,
        extraTargetValue: data.dailyGoalExtra,
      ),
      habitDailyStatus: record != null
          ? record.status
          : HabitRecordStatus.unknown,
      onPressed: widget.onCellPressed != null
          ? (date, crt) =>
                widget.onCellPressed!(data.uuid, record?.uuid, date, crt)
          : null,
      onLongPressed: widget.onCellLongPressed != null
          ? (date, crt) =>
                widget.onCellLongPressed!(data.uuid, record?.uuid, date, crt)
          : null,
      onDoublePressed: widget.onCellDoublePressed != null
          ? (date, crt) =>
                widget.onCellDoublePressed!(data.uuid, record?.uuid, date, crt)
          : null,
      enabled: showDate >= data.startDate,
      isAutoComplated: isAutoComplated,
    );

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: columnExtent),
      child: FittedBox(
        child: widget.cellBuilder != null
            ? widget.cellBuilder!(context, recordCell, showDate)
            : recordCell,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final HabitSummaryListTileColor? themeColor = themeData
        .extension<HabitSummaryListTileColor>();
    final HabitSummaryListTileColor defaultThemeColor =
        _getDefaultListTileColor(themeData);
    final TextTheme textTheme = themeData.textTheme;

    final DateTime crtDate = widget.startDate ?? AppClock().now();
    final int? limitItemCount = widget.endDate == null
        ? null
        : math.max(crtDate.difference(widget.endDate!).inDays, 0) + 1;

    Widget? leftPartBuilder() {
      return LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: height),
          child: const SizedBox(),
        ),
      );
    }

    Widget? titlePartBuilder(bool isExtended) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _buildProgressCircle(
              context,
              color:
                  themeColor?.progressCircleColor ??
                  defaultThemeColor.progressCircleColor,
              backgroundColor:
                  themeColor?.progressCircleBGColor ??
                  defaultThemeColor.progressCircleBGColor,
            ),
            _buildTitle(
              context,
              isExtended: isExtended,
              color: themeColor?.titleColor ?? defaultThemeColor.titleColor,
              textStyle: textTheme.bodyLarge!.copyWith(
                color: themeColor?.titleColor ?? defaultThemeColor.titleColor,
                decoration: data.isDeleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      );
    }

    final backgroundColor = widget.isSelected
        ? widget.selectColor ??
              themeColor?.selectedColor ??
              defaultThemeColor.selectedColor
        : null;
    final track = Padding(
      padding: widget.trackPadding,
      child: HabitListTile(
        leftChild: leftPartBuilder(),
        stackedChild: titlePartBuilder(widget.isExtended),
        geometry: widget.geometry,
        stackAutoWrap: !widget.isExtended,
        canScroll: widget.canScroll ?? widget.isExtended,
        listScrollController: _horizonalScrollController,
        itemCount: limitItemCount,
        itemBuilder: (context, index, columnExtent) =>
            _buildCellItem(context, index, columnExtent, crtDate),
        minItemCoun: kHabitSummaryListTilMinShowDate,
        scrollPhysicsBuilder: widget.scrollPhysicsBuilder,
      ),
    );
    return SizedBox(
      height: getTextScaler(context).scale(height),
      child: backgroundColor == null
          ? track
          : ColoredBox(color: backgroundColor, child: track),
    );
  }

  HabitSummaryListTileColor _getDefaultListTileColor(ThemeData themeData) {
    final CustomColors? colorData = themeData.extension<CustomColors>();
    return HabitSummaryListTileColor(
      titleColor: colorData?.getColor(
        data.color,
        brightness: themeData.brightness,
      ),
      progressCircleColor: colorData?.getColor(
        data.color,
        brightness: themeData.brightness,
      ),
      progressCircleBGColor: themeData.colorScheme.outlineOpacity16,
      selectedColor: themeData.colorScheme.onSurfaceOpacity08,
    );
  }
}
