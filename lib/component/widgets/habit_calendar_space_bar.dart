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

import '../../common/types.dart';
import 'data_arrow_container.dart';
import 'data_container.dart';
import 'habit_list_tile.dart';

class HabitCalendarSpaceBar extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final double sizePrt;
  final bool canScroll;
  final bool isExtended;
  final ScrollController? mainScrollController;
  final ScrollController? listScrollController;
  final Widget? leftButton;
  final int minItemCoun;
  final EdgeInsetsGeometry? itemPadding;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const HabitCalendarSpaceBar({
    super.key,
    this.startDate,
    this.endDate,
    required this.sizePrt,
    required this.canScroll,
    required this.isExtended,
    this.mainScrollController,
    this.listScrollController,
    this.leftButton,
    this.minItemCoun = 3,
    this.itemPadding,
    this.scrollPhysicsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    DateTime crtDate = startDate ?? DateTime.now();
    int? limitItemCount;

    if (endDate == null) {
      limitItemCount = null;
    } else {
      limitItemCount = math.max(crtDate.difference(endDate!).inDays, 0) + 1;
    }

    Widget? itemBuilder(BuildContext context, int index, double realHeight) {
      return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: realHeight),
        child: FittedBox(
          child: DateContainer(
            padding: itemPadding,
            date: crtDate.subtract(Duration(days: index)),
          ),
        ),
      );
    }

    Widget? buildLeftChild(Widget button) {
      return LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: constraints.maxHeight),
          child: FittedBox(child: DateArrowContainer(button: button)),
        ),
      );
    }

    return HabitListTile(
      sizePrt: sizePrt,
      canScroll: canScroll,
      mainScrollController: mainScrollController,
      listScrollController: listScrollController,
      leftChild: leftButton != null ? buildLeftChild(leftButton!) : null,
      itemCount: limitItemCount,
      itemBuilder: itemBuilder,
      minItemCoun: minItemCoun,
      scrollPhysicsBuilder: scrollPhysicsBuilder,
    );
  }
}
