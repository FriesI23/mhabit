// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import '../adaptive/adaptive_choice_list_tile.dart'
    show AdaptiveChoiceLayout, AdaptiveChoiceListTileConfig;
import '../adaptive/adaptive_list_tile.dart';

/// Choice form row: label and control share a line only when they fit.
class CupertinoAdaptiveChoiceListTile<T extends Object>
    extends StatelessWidget {
  const CupertinoAdaptiveChoiceListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.labels,
    required this.value,
    required this.onChanged,
    required this.config,
    this.controlKey,
  });

  final Widget title;
  final Widget? subtitle;
  final Map<T, String> labels;
  final T? value;
  final ValueChanged<T>? onChanged;
  final AdaptiveChoiceListTileConfig config;
  final Key? controlKey;

  double _measureLabelWidth(
    TextStyle style,
    TextScaler scaler,
    TextDirection direction,
  ) {
    var labelWidth = 0.0;
    for (final label in labels.values) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      labelWidth = math.max(labelWidth, painter.width);
      painter.dispose();
    }
    return labelWidth;
  }

  bool _isSideBySide({
    required bool segmented,
    required double controlWidth,
    required double availableWidth,
    required TextScaler scaler,
  }) {
    final layout = segmented ? config.segmented : config.choice;
    return switch (layout) {
      AdaptiveChoiceLayout.inline => true,
      AdaptiveChoiceLayout.stacked => false,
      AdaptiveChoiceLayout.responsive =>
        availableWidth >= controlWidth + math.max(200, scaler.scale(160)) + 48,
    };
  }

  @override
  Widget build(BuildContext context) {
    final segmented = labels.length <= config.maxSegmentCount;
    final style = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontSize: 14);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final labelWidth = _measureLabelWidth(style, scaler, direction);
    final controlWidth = segmented
        // Equal-width segments, including padding and the outer inset.
        ? (labelWidth + 32) * labels.length + 8
        : labelWidth + 48;
    final control = segmented
        ? CupertinoSlidingSegmentedControl<T>(
            key: controlKey,
            groupValue: value,
            disabledChildren: onChanged == null
                ? labels.keys.toSet()
                : const {},
            children: {
              for (final entry in labels.entries)
                entry.key: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.value,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                ),
            },
            onValueChanged: (value) {
              if (value != null) onChanged?.call(value);
            },
          )
        : CupertinoMenuAnchor(
            constrainCrossAxis: true,
            menuChildren: [
              for (final entry in labels.entries)
                CupertinoMenuItem(
                  leading: Opacity(
                    opacity: entry.key == value ? 1 : 0,
                    child: const Icon(CupertinoIcons.check_mark),
                  ),
                  onPressed: onChanged == null
                      ? null
                      : () => onChanged!(entry.key),
                  child: Text(entry.value),
                ),
            ],
            builder: (context, controller, child) => SizedBox(
              height: 28,
              child: CupertinoButton.tinted(
                key: controlKey,
                sizeStyle: CupertinoButtonSize.small,
                minimumSize: const Size(0, 28),
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
                onPressed: onChanged == null
                    ? null
                    : () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        labels[value] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(CupertinoIcons.chevron_down, size: 14),
                  ],
                ),
              ),
            ),
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = _isSideBySide(
          segmented: segmented,
          controlWidth: controlWidth,
          availableWidth: constraints.maxWidth,
          scaler: scaler,
        );
        return AdaptiveListTile.apple(
          title: title,
          trailing: sideBySide
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: segmented
                        ? controlWidth
                        : math.min(controlWidth, constraints.maxWidth * .4),
                  ),
                  child: control,
                )
              : null,
          subtitle: sideBySide
              ? subtitle
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ?subtitle,
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: control,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
