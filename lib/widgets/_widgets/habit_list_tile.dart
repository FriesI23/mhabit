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

const kDefaultHabitListTilePadding = EdgeInsets.fromLTRB(2.0, 2.0, 6.0, 2.0);

class HabitListTile extends StatelessWidget {
  final double sizePrt;
  final bool canScroll;
  final ScrollController? mainScrollController;
  final ScrollController? listScrollController;
  final Widget? leftChild;
  final Widget? stackedChild;
  final bool stackAutoWrap;
  final int rightFlex;
  final int? itemCount;
  final int minItemCoun;
  final bool useDefaultItemCount;
  final Widget? Function(BuildContext context, int index, double realHeight)
      itemBuilder;
  final double? height;
  final double? itemHeight;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const HabitListTile({
    super.key,
    required this.sizePrt,
    required this.canScroll,
    this.mainScrollController,
    this.listScrollController,
    this.stackAutoWrap = true,
    this.stackedChild,
    this.leftChild,
    this.rightFlex = 1,
    this.itemCount,
    this.minItemCoun = 3,
    this.useDefaultItemCount = false,
    required this.itemBuilder,
    this.height,
    this.itemHeight,
    this.backgroundColor,
    this.padding,
    this.scrollPhysicsBuilder,
  }) : assert(sizePrt >= 0 && sizePrt < 1);

  static int calcLimitItemCount(
          double maxWidth, double maxHeight, double sizePrt,
          {int minCount = 1}) =>
      math.max(minCount, maxWidth * sizePrt ~/ maxHeight);

  static double calcLimitItemSize(double maxHeight, int count) =>
      maxHeight * count;

  ScrollPhysics _defaultScrollPhysicsBuilder(
      BuildContext context, itemSize, double length) {
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

  EdgeInsets get _padding => padding ?? kDefaultHabitListTilePadding;

  double? get _itemHeight {
    if (itemHeight == null) return null;
    final padding = _padding;
    return math.max(0, itemHeight! - padding.top - padding.bottom);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    Widget rightBuilder(BuildContext context, int? itemCount,
        double limitItemSize, double height) {
      const overlayPhysics = BouncingScrollPhysics();
      final physics = canScroll
          ? (scrollPhysicsBuilder ??
                  (size, length) =>
                      _defaultScrollPhysicsBuilder(context, size, length))
              .call(height, limitItemSize)
          : const NeverScrollableScrollPhysics();
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
        width: limitItemSize,
        child: ListView.builder(
          primary: false,
          controller: listScrollController,
          physics: physics != null
              ? physics.applyTo(overlayPhysics)
              : overlayPhysics,
          shrinkWrap: true,
          itemCount: itemCount,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => itemBuilder(context, index, height),
        ),
      );
    }

    Widget tileBuilder(BuildContext context, BoxConstraints constraints) {
      final height = _itemHeight ?? constraints.maxHeight;
      final int limitItemCount = calcLimitItemCount(
          constraints.maxWidth, height, sizePrt,
          minCount: minItemCoun);

      final double limitItemSize = calcLimitItemSize(height, limitItemCount);

      int? itemCount;
      if (!useDefaultItemCount) {
        if (this.itemCount != null) {
          itemCount = math.max(this.itemCount!, limitItemCount);
        } else {
          itemCount = this.itemCount;
        }
      }

      final Widget rowWidget = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: () {
          final result = <Widget>[];
          if (leftChild != null) result.add(leftChild!);
          result.add(
            Flexible(
              flex: rightFlex,
              child: rightBuilder(context, itemCount, limitItemSize, height),
            ),
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
                      ? constraints.maxWidth - limitItemSize
                      : null),
              child: stackedChild,
            ),
            rowWidget,
          ],
        );
      } else {
        return rowWidget;
      }
    }

    return Container(
      color: backgroundColor,
      height: height,
      child: Padding(
        padding: _padding,
        child: Material(
          type: MaterialType.transparency,
          color: themeData.colorScheme.surface,
          surfaceTintColor: themeData.colorScheme.surfaceTint,
          child: LayoutBuilder(
            builder: tileBuilder,
          ),
        ),
      ),
    );
  }
}
