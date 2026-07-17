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
import 'package:provider/provider.dart';

import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_form.dart';
import '../../../providers/app_ui/custom_color_history.dart';
import '../../../theme/color.dart';
import '../../../widgets/widgets.dart';

Future<HabitColor?> showHabitColorPickerDialog({
  required BuildContext context,
  required HabitColor color,
}) async {
  return showDialog<HabitColor>(
    context: context,
    builder: (context) => HabitColorPickerDialog(color),
  );
}

class HabitColorPickerDialog extends StatefulWidget {
  final HabitColor color;

  const HabitColorPickerDialog(this.color, {super.key});

  @override
  State<HabitColorPickerDialog> createState() => _HabitColorPickerDialogState();
}

class _HabitColorPickerDialogState extends State<HabitColorPickerDialog> {
  // Content width is adaptive (tracks screen width) but bounded above, like
  // a BoxConstraints range, so a single row doesn't look sparse on
  // tablets/desktop. `_minContentWidth` is deliberately *not* an aesthetic
  // floor: forcing it up to e.g. 280 would inflate the content area past
  // what's actually available on narrow phones (most are well under
  // 280 + _dialogHorizontalChrome wide in portrait), risking overflow, and
  // would also mean a natural fit of 5 or fewer columns could never occur —
  // `_resolveSwatchSpacing` below already computes correct spacing for any
  // column count >= 1, so a low column count needs the *same* treatment as
  // a high one, not a different floor. This is just a degenerate-case guard
  // (enough for two swatches) so the column/spacing math never divides by a
  // non-positive width; real screens are always far wider than this.
  static const _minContentWidth = 2 * _swatchExtent + _minSwatchSpacing;
  static const _maxContentWidth = 480.0;
  // AlertDialog's default `insetPadding` (40 each side) + M3 default
  // `contentPadding` (24 each side) — see Flutter SDK `material/dialog.dart`
  // `_defaultInsetPadding`/`defaultContentPadding`. Subtracted from the
  // screen width to approximate the content area actually available.
  static const _dialogHorizontalChrome = 128.0;

  // Swatch buttons are pinned to an exact size (overriding Material's
  // default minimum-tap-target padding via `tapTargetSize: shrinkWrap`) so
  // the adaptive spacing math below has a fixed, known item extent to work
  // with instead of guessing at IconButton's effective layout size.
  static const _swatchExtent = 40.0;
  static const _minSwatchSpacing = 8.0;
  static const _maxSwatchSpacing = 16.0;
  static const _swatchRunSpacing = 12.0;

  // M3 spacing scale: 16dp between distinct content groups in a dialog.
  static const _sectionSpacing = 16.0;

  late Color _wheelColor;
  late bool _tinted;

  @override
  void initState() {
    super.initState();
    // Seeds the wheel/hex/RGB area with the current custom value when one is
    // already selected; otherwise it just needs *some* starting point, since
    // this area produces a brand-new custom color regardless of where it
    // started.
    _wheelColor = switch (widget.color) {
      CustomHabitColor(argb: final v) => Color(v),
      BuiltInHabitColor() => const Color(0xFF2196F3),
    };
    _tinted = switch (widget.color) {
      CustomHabitColor(tinted: final t) => t,
      BuiltInHabitColor() => true,
    };
  }

  void _selectAndClose(HabitColor color) {
    if (color is CustomHabitColor) {
      context.read<CustomColorHistoryViewModel>().recordUsage(color);
    }
    Navigator.of(context).pop(color);
  }

  // HabitColorWheelEditor wraps flex_color_picker's ColorPicker, whose
  // hex/RGB code field relies on a `DryIntrinsicWidth` layout workaround
  // (flex_color_picker's own fix for flutter/flutter#71687) that is only
  // exercised, by upstream, with the picker as the *direct* content of its
  // own dialog.  Nesting it inside another scroll view + column would break
  // that assumption and crash layout with a "RenderBox was not laid out"
  // assertion.  Showing the editor in its own nested dialog avoids
  // re-hosting the picker's internal render tree in a context upstream
  // never tests.
  Future<void> _openCustomColorPicker(BuildContext context) async {
    // Only committed to `_selectAndClose` below if the user confirms.  The
    // tint toggle lives inside HabitColorWheelEditor (not in the outer
    // dialog), keeping the draft self-contained: the outer dialog never
    // holds a stale pick or tint that could diverge from the wheel state.
    HabitColor? draft;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = L10n.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: l10n != null ? Text(l10n.habitEdit_colorPicker_title) : null,
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.6,
              ),
              child: SingleChildScrollView(
                child: HabitColorWheelEditor(
                  initialColor: _wheelColor,
                  initialTinted: _tinted,
                  onChanged: (color) => setDialogState(() => draft = color),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.habitEdit_colorPicker_cancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true && draft != null && mounted) {
      _selectAndClose(draft!);
    }
  }

  static String _hex(int argb) =>
      '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static String _tintStateLabel(bool tinted, L10n? l10n) => tinted
      ? (l10n?.habitEdit_colorPicker_tintedLabel ?? 'Tinted')
      : (l10n?.habitEdit_colorPicker_untintedLabel ?? 'Not tinted');

  // Width of the available content area, bounded to [_minContentWidth,
  // _maxContentWidth] via a `BoxConstraints` (the framework's own range
  // type, rather than a hand-rolled `.clamp()`). Read directly off
  // `MediaQuery` rather than via `LayoutBuilder`: `AlertDialog` lays out its
  // content inside an `IntrinsicWidth` (see `material/dialog.dart`), and
  // `LayoutBuilder`'s render object explicitly throws "LayoutBuilder does
  // not support returning intrinsic dimensions" whenever an ancestor
  // queries it that way — the same crash family as the
  // `GridView`/`ColorPicker` issues above, just from a different widget.
  // `MediaQuery.sizeOf` is a plain value read, not a layout-time
  // measurement, so it can't trigger that.
  double _resolveContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return const BoxConstraints(
      minWidth: _minContentWidth,
      maxWidth: _maxContentWidth,
    ).constrainWidth(screenWidth - _dialogHorizontalChrome);
  }

  // Gap between swatches, shared by *every* swatch grid in this dialog and
  // derived from `contentWidth` alone — never from any individual section's
  // item count. Computing it per-section (against that section's own
  // `swatches.length`) was the bug: a sparse section such as "recently
  // used" (often 4 items or fewer) would clamp its column count down to its
  // own item count and then stretch the gap to fill the row on its own,
  // landing at a different (often maxed-out) spacing than the fuller
  // built-in-colors grid above it. Sharing one spacing value means a sparse
  // row just leaves unused trailing width instead of re-justifying itself.
  //
  // The column count is fixed by how many swatches fit at the *minimum*
  // spacing, then the actual gap is stretched to use up the rest of
  // `contentWidth`, bounded to [_minSwatchSpacing, _maxSwatchSpacing] via
  // `BoxConstraints.constrainWidth` rather than a hand-rolled `.clamp()`.
  double _resolveSwatchSpacing(double contentWidth) {
    final columns =
        ((contentWidth + _minSwatchSpacing) /
                (_swatchExtent + _minSwatchSpacing))
            .floor();
    if (columns <= 1) return _minSwatchSpacing;
    final rawSpacing = (contentWidth - columns * _swatchExtent) / (columns - 1);
    return const BoxConstraints(
      minWidth: _minSwatchSpacing,
      maxWidth: _maxSwatchSpacing,
    ).constrainWidth(rawSpacing);
  }

  // Uses `Wrap`, not `GridView`/`ListView`: `AlertDialog` lays out its
  // content inside an `IntrinsicWidth` (see dialog.dart), and any viewport
  // reachable from there — even a `shrinkWrap: true` one — throws
  // "RenderShrinkWrappingViewport does not support returning intrinsic
  // dimensions" once that intrinsic query reaches it. `Wrap` has no
  // viewport, so it can't hit that assertion.
  Widget _buildSwatchGrid(
    double contentWidth,
    double spacing,
    List<Widget> swatches,
  ) {
    if (swatches.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: contentWidth,
      child: Wrap(
        spacing: spacing,
        runSpacing: _swatchRunSpacing,
        children: swatches,
      ),
    );
  }

  Widget _buildBuiltInSection(
    BuildContext context,
    CustomColors? colorData,
    Brightness brightness,
    L10n? l10n,
    double contentWidth,
    double spacing,
  ) {
    final swatches = [
      for (final t in HabitColorType.values)
        ColorSwatchButton(
          background: colorData?.getBuiltInColor(t) ?? Colors.transparent,
          onColor: colorData?.getBuiltInOnColor(t),
          selected: widget.color == HabitColor.builtIn(t),
          onTap: () => _selectAndClose(HabitColor.builtIn(t)),
          tooltip: HabitColorType.getColorName(t, l10n),
          size: _swatchExtent,
        ),
    ];
    return _buildSwatchGrid(contentWidth, spacing, swatches);
  }

  Widget? _buildHistorySection(
    BuildContext context,
    CustomColors? colorData,
    Brightness brightness,
    L10n? l10n,
    List<CustomHabitColor> history,
    double contentWidth,
    double spacing,
  ) {
    if (history.isEmpty) return null;
    final swatches = [
      for (final entry in history)
        ColorSwatchButton(
          background:
              colorData?.getColor(entry, brightness: brightness) ??
              Color(entry.argb),
          onColor: colorData?.getOnColor(entry, brightness: brightness),
          gradientFrom: entry.tinted ? Color(entry.argb) : null,
          selected: widget.color == entry,
          onTap: () => _selectAndClose(entry),
          tooltip:
              '${_hex(entry.argb)} · ${_tintStateLabel(entry.tinted, l10n)}',
          size: _swatchExtent,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _sectionSpacing),
        if (l10n != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.habitEdit_colorPicker_historySectionLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        _buildSwatchGrid(contentWidth, spacing, swatches),
      ],
    );
  }

  Widget _buildCustomEntry(
    BuildContext context,
    CustomColors? colorData,
    Brightness brightness,
    L10n? l10n,
  ) {
    final wheelArgb = _wheelColor.toARGB32() | 0xFF000000;
    final previewHabitColor = HabitColor.custom(wheelArgb, tinted: _tinted);
    final previewColor =
        colorData?.getColor(previewHabitColor, brightness: brightness) ??
        _wheelColor;
    final previewOnColor = colorData?.getOnColor(
      previewHabitColor,
      brightness: brightness,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _sectionSpacing),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ColorPreviewCircle(
            size: 40,
            background: previewColor,
            onColor: previewOnColor,
            gradientFrom: _tinted ? Color(wheelArgb) : null,
          ),
          title: Text(
            l10n?.habitEdit_colorPicker_customSectionLabel(
                  _tinted.toString(),
                ) ??
                '',
          ),
          subtitle: Text(_hex(wheelArgb)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openCustomColorPicker(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    final l10n = L10n.of(context);
    final history = context.read<CustomColorHistoryViewModel>().history;
    final contentWidth = _resolveContentWidth(context);
    final spacing = _resolveSwatchSpacing(contentWidth);

    return AlertDialog(
      title: l10n != null ? Text(l10n.habitEdit_colorPicker_title) : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBuiltInSection(
              context,
              colorData,
              themeData.brightness,
              l10n,
              contentWidth,
              spacing,
            ),
            _buildHistorySection(
                  context,
                  colorData,
                  themeData.brightness,
                  l10n,
                  history,
                  contentWidth,
                  spacing,
                ) ??
                const SizedBox.shrink(),
            _buildCustomEntry(context, colorData, themeData.brightness, l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.habitEdit_colorPicker_cancel ?? 'cancel'),
        ),
      ],
    );
  }
}
