import 'package:flutter/widgets.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_choice_list_tile.dart';
import '../material/material_adaptive_choice_list_tile.dart';

/// Layout of the label and its choice control.
enum AdaptiveChoiceLayout {
  /// Always keep the control beside the label.
  inline,

  /// Place the control beside the label when it fits, otherwise below it.
  responsive,

  /// Always place the control below the label.
  stacked,
}

/// Aggregates control selection and the independent layout of each form.
class AdaptiveChoiceListTileConfig {
  const AdaptiveChoiceListTileConfig({
    this.maxSegmentCount = 3,
    this.choice = AdaptiveChoiceLayout.inline,
    this.segmented = AdaptiveChoiceLayout.responsive,
  }) : assert(maxSegmentCount >= 0);

  /// Forces the selected platform renderer to use its menu presentation.
  const AdaptiveChoiceListTileConfig.choice({
    this.choice = AdaptiveChoiceLayout.inline,
    this.segmented = AdaptiveChoiceLayout.responsive,
  }) : maxSegmentCount = 0;

  /// Both renderers use segments up to this count, and a menu above it.
  /// Zero forces the platform menu renderer.
  final int maxSegmentCount;
  final AdaptiveChoiceLayout choice;
  final AdaptiveChoiceLayout segmented;
}

/// Single-choice form row with platform renderers and a shared layout policy.
/// A null callback disables selection. Option order follows [labels].
class AdaptiveChoiceListTile<T extends Object> extends StatelessWidget {
  const AdaptiveChoiceListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.labels,
    required this.value,
    required this.onChanged,
    this.config = const AdaptiveChoiceListTileConfig(),
    this.controlKey,
  }) : style = null;

  const AdaptiveChoiceListTile.material({
    super.key,
    required this.title,
    this.subtitle,
    required this.labels,
    required this.value,
    required this.onChanged,
    this.config = const AdaptiveChoiceListTileConfig(),
    this.controlKey,
  }) : style = AdaptiveStyle.material;

  const AdaptiveChoiceListTile.apple({
    super.key,
    required this.title,
    this.subtitle,
    required this.labels,
    required this.value,
    required this.onChanged,
    this.config = const AdaptiveChoiceListTileConfig(),
    this.controlKey,
  }) : style = AdaptiveStyle.apple;

  final Widget title;
  final Widget? subtitle;
  final Map<T, String> labels;
  final T? value;
  final ValueChanged<T>? onChanged;
  final AdaptiveChoiceListTileConfig config;
  final Key? controlKey;
  final AdaptiveStyle? style;

  @override
  Widget build(BuildContext context) {
    assert(labels.length >= 2);
    assert(value == null || labels.containsKey(value));
    return switch (style ?? AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialAdaptiveChoiceListTile<T>(
        title: title,
        subtitle: subtitle,
        labels: labels,
        value: value,
        onChanged: onChanged,
        controlKey: controlKey,
        config: config,
      ),
      AdaptiveStyle.apple => CupertinoAdaptiveChoiceListTile<T>(
        title: title,
        subtitle: subtitle,
        labels: labels,
        value: value,
        onChanged: onChanged,
        controlKey: controlKey,
        config: config,
      ),
    };
  }
}
