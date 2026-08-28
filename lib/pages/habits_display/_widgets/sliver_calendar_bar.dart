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
import '../../../utils/app_clock.dart';
import '../../../widgets/widgets.dart';

const double kDefaultHabitCalendarBarExtendedPrt = 0.85;
const int kHabitCalendarBarMinShowDate = 1;

class SliverCalendarBar extends StatefulWidget {
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onLeftBtnPressed;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isExtended;
  final HabitListTileGeometry geometry;
  final double height;
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsets trackPadding;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const SliverCalendarBar({
    super.key,
    this.horizonalScrollControllerGroup,
    this.onLeftBtnPressed,
    this.startDate,
    this.endDate,
    required this.isExtended,
    required this.geometry,
    required this.height,
    this.itemPadding,
    this.trackPadding = kDefaultHabitListTileTrackPadding,
    this.scrollPhysicsBuilder,
  });

  @override
  State<StatefulWidget> createState() => _SliverCalendarBar();
}

class _SliverCalendarBar extends State<SliverCalendarBar> {
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

  @override
  Widget build(BuildContext context) {
    final currentDate = widget.startDate ?? AppClock().now();
    final int? itemCount = widget.endDate == null
        ? null
        : math.max(currentDate.difference(widget.endDate!).inDays, 0) + 1;
    final Widget? expandIcon = widget.onLeftBtnPressed != null
        ? _SliverClanedarBarExpandButton(
            onPressed: widget.onLeftBtnPressed,
            isExpanded: widget.isExtended,
          )
        : null;

    Widget? itemBuilder(BuildContext context, int index, double columnExtent) {
      return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: columnExtent),
        child: FittedBox(
          child: DateContainer(
            padding: widget.itemPadding,
            date: currentDate.subtract(Duration(days: index)),
          ),
        ),
      );
    }

    Widget buildLeftChild(Widget button) {
      return LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: constraints.maxHeight),
          child: FittedBox(child: DateArrowContainer(button: button)),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Padding(
        padding: widget.trackPadding,
        child: HabitListTile(
          geometry: widget.geometry,
          canScroll: widget.isExtended,
          listScrollController: _horizonalScrollController,
          leftChild: expandIcon != null ? buildLeftChild(expandIcon) : null,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          minItemCoun: kHabitCalendarBarMinShowDate,
          scrollPhysicsBuilder: widget.scrollPhysicsBuilder,
        ),
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
      child: ExpandIcon(onPressed: onPressed, isExpanded: isExpanded),
    );
  }
}
