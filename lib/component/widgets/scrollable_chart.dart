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

// Copyright Github @TeoVogel https://github.com/TeoVogel
// see: https://github.com/imaNNeo/fl_chart/issues/71#issuecomment-1414267612

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/math.dart';

class ScrollableChart extends StatefulWidget {
  final double maxX;
  final double minX;
  final double? initMinX;
  final double scrollSpeed;
  final double scrollRefreshInterval;
  final double scrollStopCoefficient;
  final Widget Function(double minX, double maxX) builder;

  const ScrollableChart({
    super.key,
    required this.maxX,
    required this.minX,
    required this.scrollSpeed,
    this.scrollRefreshInterval = 0.1,
    this.scrollStopCoefficient = 0.2,
    this.initMinX,
    required this.builder,
  });

  @override
  State<ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<ScrollableChart>
    with SingleTickerProviderStateMixin {
  late double minX;
  late double maxX;
  late double lastMaxXValue;
  late double lastMinXValue;

  double? lastCacheMinX;
  double? lastCacheMaxX;

  late AnimationController _controller;
  late Animation<double> _animation;
  double? _animateStartDistance;
  double _lastDistance = 0;

  void _initAxis() {
    minX = widget.initMinX ?? 0.0;
    maxX = widget.maxX;
    lastMaxXValue = minX;
    lastMinXValue = maxX;
  }

  double _getAnimateRealDistance(double value) =>
      (_animateStartDistance ?? 0) * (1 - value);

  @override
  void initState() {
    super.initState();
    _initAxis();
    _controller = AnimationController(vsync: this);
    _animation = CurveTween(curve: Curves.easeIn).animate(_controller);
    _controller.addListener(() {
      final distance = _getAnimateRealDistance(_animation.value);
      _onScroll(distance);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScrollableChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAxis();
  }

  void _onScroll(double horizontalDistance, {bool refresh = true}) {
    var lastMinMaxDistance = math.max(lastMaxXValue - lastMinXValue, 0.0);

    lastCacheMinX = lastCacheMinX ?? minX;
    lastCacheMaxX = lastCacheMaxX ?? maxX;
    minX -= lastMinMaxDistance * widget.scrollSpeed * horizontalDistance;
    maxX -= lastMinMaxDistance * widget.scrollSpeed * horizontalDistance;
    if (minX < widget.minX) {
      minX = widget.minX;
      maxX = minX + lastMinMaxDistance;
    }
    if (maxX > widget.maxX) {
      maxX = widget.maxX;
      minX = maxX - lastMinMaxDistance;
    }
    if ((lastCacheMinX != null &&
            (lastCacheMinX! - minX).abs() > widget.scrollRefreshInterval) ||
        (lastCacheMaxX != null &&
            (lastCacheMaxX! - maxX).abs() > widget.scrollRefreshInterval) ||
        maxX == widget.maxX ||
        minX == widget.minX) {
      lastCacheMaxX = null;
      lastCacheMinX = null;
      if (refresh) setState(() {});
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    lastMinXValue = minX;
    lastMaxXValue = maxX;
    _lastDistance = 0;
    _controller
      ..stop()
      ..reset();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    var horizontalDistance = details.primaryDelta ?? 0;
    if (horizontalDistance == 0) return;
    _lastDistance = horizontalDistance;
    _onScroll(horizontalDistance);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _animateStartDistance = _lastDistance;

    final v0 = details.velocity.pixelsPerSecond.dx;
    final duration =
        math.sqrt(2 * (v0 * v0) / (2 * widget.scrollStopCoefficient * g) / g);
    _controller
      ..duration = Duration(milliseconds: duration.toInt())
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: widget.builder(minX, maxX),
    );
  }
}
