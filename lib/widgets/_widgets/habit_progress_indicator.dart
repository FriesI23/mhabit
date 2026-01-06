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

import 'package:animated_check/animated_check.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HabitProgressIndicator extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;
  final Duration duration;
  final bool isComplated;
  final bool showComplatedIcon;
  final bool isArchived;
  final bool showArchivedIcon;
  final bool isDeleted;
  final bool showDeletedIcon;

  const HabitProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.duration = const Duration(milliseconds: 300),
    this.isComplated = false,
    this.showComplatedIcon = true,
    this.isArchived = false,
    this.showArchivedIcon = true,
    this.isDeleted = false,
    this.showDeletedIcon = true,
  }) : assert(!(isArchived && isDeleted));

  @override
  State<StatefulWidget> createState() => _HabitProgressIndicator();
}

class _HabitProgressIndicator extends State<HabitProgressIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late final AnimationController _checkController;
  late Animation<double> _checkAnimation;

  void _refreshCheckAnimation() {
    if (!widget.showComplatedIcon) return;
    widget.isComplated
        ? _checkController.forward()
        : _checkController.reverse();
  }

  void _updateProgressAnimation(HabitProgressIndicator oldWidget) {
    _controller.reset();
    _animation = Tween(
      begin: oldWidget.value,
      end: widget.value,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    // progress
    _controller = AnimationController(
      value: widget.value,
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween(
      begin: widget.value,
      end: widget.value,
    ).animate(_controller);
    // checker
    _checkController = AnimationController(
      value: widget.isComplated ? 1.0 : 0.0,
      vsync: this,
      duration: widget.duration,
    );
    _checkAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOutCirc),
    );
  }

  @override
  void didUpdateWidget(HabitProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateProgressAnimation(oldWidget);
      _refreshCheckAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _checkController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCheck(BuildContext context, double size) {
    return AnimatedCheck(
      progress: _checkAnimation,
      size: size,
      strokeWidth: widget.strokeWidth != null
          ? math.max(widget.strokeWidth! - 2, 1)
          : widget.strokeWidth,
      color: widget.color,
    );
  }

  Widget _buildArchiveFlag(BuildContext context, double size) {
    return Container(
      padding: EdgeInsets.all(size / 5),
      child: FittedBox(
        child: Icon(MdiIcons.archiveOutline, size: size, color: widget.color),
      ),
    );
  }

  Widget _buildDeleteFlag(BuildContext context, double size) {
    return Container(
      padding: EdgeInsets.all(size / 5),
      child: FittedBox(
        child: Icon(MdiIcons.deleteVariant, size: size, color: widget.color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget layoutBuilder(BuildContext context, BoxConstraints constraints) {
      double getAnimatedArchiveOpcaticy() {
        if (!widget.isArchived) return 0.0;

        if (widget.isComplated &&
            !widget.showComplatedIcon &&
            widget.showArchivedIcon) {
          return 1.0;
        }

        if (!widget.isComplated && widget.showArchivedIcon) return 1.0;

        return 0.0;
      }

      double getAnimatedDeleteOpcaticy() {
        if (!widget.isDeleted) return 0.0;

        if (widget.isComplated &&
            !widget.showComplatedIcon &&
            widget.showDeletedIcon) {
          return 1.0;
        }

        if (!widget.isComplated && widget.showComplatedIcon) return 1.0;

        return 0.0;
      }

      final indicator = CircularProgressIndicator(
        backgroundColor: widget.backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? colorScheme.primary,
        ),
        strokeWidth: widget.strokeWidth ?? 4.0,
        value: _animation.value,
      );

      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            child: indicator,
          ),
          Visibility(
            visible: widget.isComplated && widget.showComplatedIcon,
            child: _buildAnimatedCheck(context, constraints.maxHeight),
          ),
          AnimatedOpacity(
            opacity: getAnimatedArchiveOpcaticy(),
            duration: widget.duration,
            curve: Curves.easeInOutCirc,
            child: _buildArchiveFlag(context, constraints.maxHeight),
          ),
          AnimatedOpacity(
            opacity: getAnimatedDeleteOpcaticy(),
            duration: widget.duration,
            curve: Curves.easeInOutCirc,
            child: _buildDeleteFlag(context, constraints.maxHeight),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(builder: layoutBuilder);
      },
    );
  }
}
