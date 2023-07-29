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

import '../../common/types.dart';
import '../../component/widget.dart';

const double kDefaultHabitCalendarBarHeight = 64.0;
const double kDefaultHabitCalendarBarExtendedPrt = 0.85;
const double kDefaultHabitCalendarBarCollapsePrt = 0.5;
const int kHabitCalendarBarMinShowDate = 1;

class SliverCalendarBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onLeftBtnPressed;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isExtended;
  final int? collapsePrt;
  final double? _height;
  final EdgeInsetsGeometry? itemPadding;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const SliverCalendarBar({
    super.key,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onLeftBtnPressed,
    this.startDate,
    this.endDate,
    required this.isExtended,
    this.collapsePrt,
    double? height,
    this.itemPadding,
    this.scrollPhysicsBuilder,
  }) : _height = height;

  double get height => _height ?? kDefaultHabitCalendarBarHeight;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<StatefulWidget> createState() => _SliverCalendarBar();
}

class _SliverCalendarBar extends State<SliverCalendarBar> {
  late final ScrollController? _horizonalScrollController;

  @override
  void initState() {
    super.initState();
    _horizonalScrollController = widget.horizonalScrollControllerGroup != null
        ? widget.horizonalScrollControllerGroup!.addAndGet()
        : null;
  }

  @override
  void dispose() {
    _horizonalScrollController?.dispose();
    super.dispose();
  }

  double get collapsePrt => widget.collapsePrt != null
      ? widget.collapsePrt! / 100
      : kDefaultHabitCalendarBarCollapsePrt;

  @override
  Widget build(BuildContext context) {
    Widget? expandIcon = widget.onLeftBtnPressed != null
        ? _SliverClanedarBarExpandButton(
            onPressed: widget.onLeftBtnPressed,
            isExpanded: widget.isExtended,
          )
        : null;

    return SizedBox(
      height: widget.height,
      child: HabitCalendarSpaceBar(
        startDate: widget.startDate,
        endDate: widget.endDate,
        sizePrt: widget.isExtended
            ? kDefaultHabitCalendarBarExtendedPrt
            : collapsePrt,
        canScroll: widget.isExtended,
        isExtended: widget.isExtended,
        mainScrollController: widget.verticalScrollController,
        listScrollController: _horizonalScrollController,
        leftButton: expandIcon,
        minItemCoun: kHabitCalendarBarMinShowDate,
        itemPadding: widget.itemPadding,
        scrollPhysicsBuilder: widget.scrollPhysicsBuilder,
      ),
    );
  }
}

class _SliverClanedarBarExpandButton extends StatelessWidget {
  final ValueChanged<bool>? onPressed;
  final bool isExpanded;

  const _SliverClanedarBarExpandButton({
    required this.isExpanded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Transform.rotate(
      angle: isRTL ? -math.pi / 2 : math.pi / 2,
      child: ExpandIcon(
        onPressed: onPressed,
        isExpanded: isExpanded,
      ),
    );
  }
}
