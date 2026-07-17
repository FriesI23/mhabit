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

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/localizations.dart';
import '../../models/habit_color.dart';

/// A compact, inline color-wheel editor for custom [HabitColor] values.
///
/// Composes [ColorPicker] (wheel-only, no opacity) with a tint toggle.
/// Fires [onChanged] on every wheel drag or tint switch so callers can
/// preview or commit immediately.
class HabitColorWheelEditor extends StatefulWidget {
  final Color initialColor;
  final bool initialTinted;
  final ValueChanged<HabitColor> onChanged;

  const HabitColorWheelEditor({
    super.key,
    required this.initialColor,
    required this.initialTinted,
    required this.onChanged,
  });

  @override
  State<HabitColorWheelEditor> createState() => _HabitColorWheelEditorState();
}

class _HabitColorWheelEditorState extends State<HabitColorWheelEditor> {
  late Color _wheelColor;
  late bool _tinted;

  @override
  void initState() {
    super.initState();
    _wheelColor = widget.initialColor;
    _tinted = widget.initialTinted;
    // Notify the initial value so callers tracking a draft start in sync.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _notify() {
    widget.onChanged(
      HabitColor.custom(_wheelColor.toARGB32() | 0xFF000000, tinted: _tinted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorPicker(
          color: _wheelColor,
          onColorChanged: (value) {
            _wheelColor = value;
            _notify();
          },
          pickersEnabled: const {
            ColorPickerType.both: false,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
            ColorPickerType.customSecondary: false,
            ColorPickerType.wheel: true,
          },
          enableOpacity: false,
          showColorCode: true,
          colorCodeHasColor: true,
          wheelDiameter: 200,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n?.habitEdit_colorPicker_tintToggleLabel ?? 'Tint to theme',
          ),
          subtitle: l10n == null
              ? null
              : Text(
                  _tinted
                      ? l10n.habitEdit_colorPicker_tintToggleOnHint
                      : l10n.habitEdit_colorPicker_tintToggleOffHint,
                ),
          value: _tinted,
          onChanged: (value) {
            setState(() => _tinted = value);
            _notify();
          },
        ),
      ],
    );
  }
}

/// A plain color circle, or — when [gradientFrom] is given — a circle
/// gradient from [gradientFrom] to [background] plus a small corner badge,
/// visualizing the tint transformation tinting applies.
///
/// Callers stack interactive content (e.g. an [IconButton] or [InkWell]) on
/// top of this widget.
class ColorPreviewCircle extends StatelessWidget {
  final double size;
  final Color background;
  final Color? onColor;
  final Color? gradientFrom;

  const ColorPreviewCircle({
    super.key,
    required this.size,
    required this.background,
    this.onColor,
    this.gradientFrom,
  });

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradientFrom == null ? background : null,
        gradient: gradientFrom == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientFrom!, background],
              ),
      ),
    );
    if (gradientFrom == null) return circle;
    final badgeSize = size * 0.42;
    return Stack(
      children: [
        circle,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onColor ?? Colors.black,
            ),
            child: Icon(
              Icons.palette,
              size: badgeSize * 0.62,
              color: background,
            ),
          ),
        ),
      ],
    );
  }
}
