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

class AnimatedLinearProgress extends StatefulWidget {
  final double? value;
  final Duration duration;

  const AnimatedLinearProgress({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<StatefulWidget> createState() => _AnimatedLinearProgress();
}

class _AnimatedLinearProgress extends State<AnimatedLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Animation<double>? _animation;

  void _onAnimationNotified() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final value = widget.value;
    if (value != null) {
      _animation = Tween(begin: 0.0, end: value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      )..addListener(_onAnimationNotified);
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _controller.reset();
    final newValue = widget.value;
    if (newValue != null) {
      _animation?.removeListener(_onAnimationNotified);
      _animation = Tween(begin: oldWidget.value ?? 0.0, end: newValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      )..addListener(_onAnimationNotified);
      _controller.forward();
    } else {
      _animation?.removeListener(_onAnimationNotified);
      _animation = null;
    }
  }

  @override
  void dispose() {
    _animation?.removeListener(_onAnimationNotified);
    _controller.dispose();
    debugPrint(widget.value.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: _animation?.value);
  }
}
