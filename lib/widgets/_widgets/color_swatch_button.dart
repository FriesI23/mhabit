// Copyright 2026 Fries_I23
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

import 'habit_color_wheel_editor.dart';

/// A tappable circular color swatch.
///
/// Composes [ColorPreviewCircle] (background + optional tint gradient)
/// with an [IconButton] whose tap-target is pinned to the swatch size via
/// `styleFrom(fixedSize, tapTargetSize: shrinkWrap)`.  When [selected] is
/// true a checkmark icon is overlaid; callers that need a different
/// selection indicator can stack their own overlay on top of this widget
/// instead.
///
/// [tooltip] is forwarded to [Tooltip] when non-null.
class ColorSwatchButton extends StatelessWidget {
  final Color background;
  final Color? onColor;
  final Color? gradientFrom;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;

  const ColorSwatchButton({
    super.key,
    required this.background,
    this.onColor,
    this.gradientFrom,
    this.selected = false,
    required this.onTap,
    this.tooltip,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final button = Stack(
      alignment: Alignment.center,
      children: [
        ColorPreviewCircle(
          size: size,
          background: background,
          onColor: onColor,
          gradientFrom: gradientFrom,
        ),
        IconButton(
          onPressed: onTap,
          icon: selected ? const Icon(Icons.check) : const Icon(null),
          isSelected: selected,
          style: IconButton.styleFrom(
            foregroundColor: onColor,
            backgroundColor: Colors.transparent,
            hoverColor: onColor?.withValues(alpha: 0.08),
            focusColor: onColor?.withValues(alpha: 0.12),
            highlightColor: onColor?.withValues(alpha: 0.12),
            fixedSize: Size.square(size),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
