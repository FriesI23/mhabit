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

class PinnedAppbarScrollController extends ScrollController {
  final double? _toolbarHeight;
  final ValueChanged<bool>? onAppbarStatusChanged;

  PinnedAppbarScrollController(
      {double? toolbarHeight, this.onAppbarStatusChanged})
      : _toolbarHeight = toolbarHeight,
        super();

  double get toolbarHeight => _toolbarHeight ?? kToolbarHeight;

  void _onAppbarStatusChanged() {
    if (hasClients && offset > toolbarHeight) {
      onAppbarStatusChanged?.call(true);
    } else if (hasClients && offset < toolbarHeight) {
      onAppbarStatusChanged?.call(false);
    }
  }

  void addChangeAppbarStatusListener() {
    addListener(_onAppbarStatusChanged);
  }

  @override
  void dispose() {
    removeListener(_onAppbarStatusChanged);
    super.dispose();
  }
}

class VerticalScrollVisibilityDispatcher {
  final Duration animationDuration;
  final void Function(bool visible) onVisibilityChanged;
  late final ScrollController controller;
  double _lastOffset = 0.0;
  bool _lastVisible = true;

  VerticalScrollVisibilityDispatcher({
    required double toolbarHeight,
    required this.onVisibilityChanged,
    this.animationDuration = const Duration(milliseconds: 250),
  }) {
    controller = PinnedAppbarScrollController(
      toolbarHeight: toolbarHeight,
      onAppbarStatusChanged: (_) {},
    )..addListener(_onScroll);
    _lastOffset = controller.initialScrollOffset;
  }

  void _onScroll() {
    if (!controller.hasClients) return;
    final offset = controller.offset.clamp(0.0, double.infinity);
    final delta = offset - _lastOffset;
    const threshold = 8.0;
    if (delta.abs() < threshold) return;

    _lastOffset = offset;

    bool? targetVisible;
    if (delta > 0 && _lastVisible) {
      targetVisible = false;
    } else if (delta < 0 && !_lastVisible) {
      targetVisible = true;
    }

    if (targetVisible == null) return;
    _lastVisible = targetVisible;
    onVisibilityChanged(targetVisible);
  }

  void dispose() {
    controller.removeListener(_onScroll);
    controller.dispose();
  }
}
