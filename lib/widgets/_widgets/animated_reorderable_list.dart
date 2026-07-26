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

// ignore_for_file: implementation_imports

import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:animated_reorderable_list/src/component/drag_listener.dart';
import 'package:flutter/material.dart';
// ReorderableGridDragStartListener is not exported from the package barrel
// in v1.3.0; re-export from src/ as a workaround until the package is updated.
export 'package:animated_reorderable_list/animated_reorderable_list.dart';
export 'package:animated_reorderable_list/src/component/drag_listener.dart';

typedef SliverReorderableAnimatedList<E extends Object> =
    ReorderableAnimatedListImpl<E>;

/// A drag handle button for use inside a [ReorderableAnimatedListImpl] item.
///
/// Wraps a drag-handle icon in [ReorderableGridDragStartListener] so that
/// tapping the handle immediately starts a drag (no long-press needed), then
/// wraps both in an [IconButton] for consistent sizing with other trailing
/// actions.
class DragHandleButton extends StatelessWidget {
  final int index;
  final double iconSize;
  final Color? color;

  const DragHandleButton({
    super.key,
    required this.index,
    this.iconSize = 20,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: null,
      icon: ReorderableGridDragStartListener(
        index: index,
        child: Icon(Icons.drag_handle, size: iconSize, color: color),
      ),
    );
  }
}
