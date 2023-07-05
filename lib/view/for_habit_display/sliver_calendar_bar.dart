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

const double kHabitCalendarBarHeight = 64.0;
const double kHabitCalendarBarExtendedPrt = 0.85;
const double kHabitCalendarBarCollapsePrt = 0.5;
const int kHabitCalendarBarMinShowDate = 1;

class SliverCalendarBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onLeftBtnPressed;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isExtended;
  final int? collapsePrt;
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
    this.scrollPhysicsBuilder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kHabitCalendarBarHeight);

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
      : kHabitCalendarBarCollapsePrt;

  @override
  Widget build(BuildContext context) {
    Widget? expandIcon = widget.onLeftBtnPressed != null
        ? Transform.rotate(
            angle: math.pi / 2,
            child: ExpandIcon(
              onPressed: widget.onLeftBtnPressed,
              isExpanded: widget.isExtended,
            ),
          )
        : null;

    return SizedBox(
      height: kHabitCalendarBarHeight,
      child: HabitCalendarSpaceBar(
        startDate: widget.startDate,
        endDate: widget.endDate,
        sizePrt: widget.isExtended ? kHabitCalendarBarExtendedPrt : collapsePrt,
        canScroll: widget.isExtended,
        isExtended: widget.isExtended,
        mainScrollController: widget.verticalScrollController,
        listScrollController: _horizonalScrollController,
        leftButton: expandIcon,
        minItemCoun: kHabitCalendarBarMinShowDate,
        scrollPhysicsBuilder: widget.scrollPhysicsBuilder,
      ),
    );
  }
}
