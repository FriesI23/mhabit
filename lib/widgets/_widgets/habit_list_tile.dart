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
import 'scroll_physics.dart' show MagnetScrollPhysics;

const kDefaultHabitListTileTrackPadding = EdgeInsets.fromLTRB(
  2.0,
  0.0,
  6.0,
  0.0,
);

@immutable
class HabitListTileGeometry {
  final double columnExtent;
  final double viewportFraction;

  const HabitListTileGeometry({
    required this.columnExtent,
    required this.viewportFraction,
  }) : assert(columnExtent > 0),
       assert(viewportFraction >= 0 && viewportFraction < 1);

  const HabitListTileGeometry.fromExpansionState({
    required double columnExtent,
    required bool isExpanded,
    required double collapsedViewportFraction,
    required double expandedViewportFraction,
  }) : this(
         columnExtent: columnExtent,
         viewportFraction: isExpanded
             ? expandedViewportFraction
             : collapsedViewportFraction,
       );

  int computeColumnCount(double availableWidth, {int minCount = 1}) {
    assert(minCount >= 1);
    return math.max(
      minCount,
      availableWidth * viewportFraction ~/ columnExtent,
    );
  }

  double computeViewportExtent(double availableWidth, {int minCount = 1}) =>
      columnExtent * computeColumnCount(availableWidth, minCount: minCount);
}

class HabitListTile extends StatelessWidget {
  final HabitListTileGeometry geometry;
  final bool canScroll;
  final ScrollController? listScrollController;
  final Widget? leftChild;
  final Widget? stackedChild;
  final bool stackAutoWrap;
  final int? itemCount;
  final int minItemCoun;
  final Widget? Function(BuildContext context, int index, double columnExtent)
  itemBuilder;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const HabitListTile({
    super.key,
    required this.geometry,
    required this.canScroll,
    this.listScrollController,
    this.stackAutoWrap = true,
    this.stackedChild,
    this.leftChild,
    this.itemCount,
    this.minItemCoun = 3,
    required this.itemBuilder,
    this.scrollPhysicsBuilder,
  });

  ScrollPhysics _defaultScrollPhysicsBuilder(
    BuildContext context,
    double itemSize,
    double viewportExtent,
  ) {
    return MagnetScrollPhysics(
      itemSize: itemSize,
      metrics: FixedScrollMetrics(
        minScrollExtent: null,
        maxScrollExtent: null,
        pixels: null,
        viewportDimension: null,
        axisDirection: AxisDirection.down,
        devicePixelRatio: View.of(context).devicePixelRatio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    Widget rightBuilder(
      BuildContext context,
      int? itemCount,
      double viewportExtent,
    ) {
      const overlayPhysics = BouncingScrollPhysics();
      final physics = canScroll
          ? (scrollPhysicsBuilder ??
                    (size, viewportExtent) => _defaultScrollPhysicsBuilder(
                      context,
                      size,
                      viewportExtent,
                    ))
                .call(geometry.columnExtent, viewportExtent)
          : const NeverScrollableScrollPhysics();
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
        width: viewportExtent,
        child: ListView.builder(
          primary: false,
          controller: listScrollController,
          physics: physics != null
              ? physics.applyTo(overlayPhysics)
              : overlayPhysics,
          shrinkWrap: true,
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) =>
              itemBuilder(context, index, geometry.columnExtent),
        ),
      );
    }

    Widget tileBuilder(BuildContext context, BoxConstraints constraints) {
      final int limitItemCount = geometry.computeColumnCount(
        constraints.maxWidth,
        minCount: minItemCoun,
      );
      final double viewportExtent = geometry.computeViewportExtent(
        constraints.maxWidth,
        minCount: minItemCoun,
      );

      final int? itemCount = this.itemCount != null
          ? math.max(this.itemCount!, limitItemCount)
          : null;

      final Widget rowWidget = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: () {
          final result = <Widget>[];
          if (leftChild != null) result.add(leftChild!);
          result.add(
            Flexible(child: rightBuilder(context, itemCount, viewportExtent)),
          );

          return result;
        }(),
      );

      if (stackedChild != null) {
        return Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                width: stackAutoWrap
                    ? constraints.maxWidth - viewportExtent
                    : null,
              ),
              child: stackedChild,
            ),
            rowWidget,
          ],
        );
      } else {
        return rowWidget;
      }
    }

    return Material(
      type: MaterialType.transparency,
      color: themeData.colorScheme.surface,
      surfaceTintColor: themeData.colorScheme.surfaceTint,
      child: LayoutBuilder(builder: tileBuilder),
    );
  }
}
