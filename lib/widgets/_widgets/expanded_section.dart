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

import 'package:flutter/material.dart';

const _defaultDuration = Duration(milliseconds: 500);

// Copyright Stackoverflow / Adam Jonsson
// see: https://stackoverflow.com/a/54173729
class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final Duration? duration;
  final Curve curve;
  final Curve? reverseCurve;

  const ExpandedSection({
    super.key,
    this.expand = false,
    required this.child,
    this.duration,
    this.curve = Curves.fastOutSlowIn,
    this.reverseCurve,
  });

  @override
  State<StatefulWidget> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController expandController;
  late final Animation<double> animation;

  Duration get duration => widget.duration ?? _defaultDuration;

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(vsync: this, duration: duration);
    expandController.value = widget.expand ? 1.0 : 0.0;
    animation = CurvedAnimation(
      parent: expandController,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: FocusTraversalGroup(
          descendantsAreFocusable: widget.expand, child: widget.child),
    );
  }
}
