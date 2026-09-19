import 'package:flutter/material.dart';

import '../adaptive/adaptive_choice_list_tile.dart'
    show AdaptiveChoiceLayout, AdaptiveChoiceListTileConfig;
import '../adaptive/adaptive_list_tile.dart';

class MaterialAdaptiveChoiceListTile<T extends Object> extends StatelessWidget {
  const MaterialAdaptiveChoiceListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.config,
    required this.controlKey,
    required this.value,
    required this.labels,
    required this.onChanged,
  });
  final Widget title;
  final Widget? subtitle;
  final AdaptiveChoiceListTileConfig config;
  final Key? controlKey;
  final T? value;
  final Map<T, String> labels;
  final ValueChanged<T>? onChanged;

  bool _isStacked(
    BuildContext context,
    BoxConstraints constraints, {
    required bool segmented,
  }) {
    final layout = segmented ? config.segmented : config.choice;
    return switch (layout) {
      AdaptiveChoiceLayout.inline => false,
      AdaptiveChoiceLayout.stacked => true,
      AdaptiveChoiceLayout.responsive =>
        constraints.maxWidth < 400 ||
            MediaQuery.textScalerOf(context).scale(14) > 20,
    };
  }

  @override
  Widget build(BuildContext context) {
    final segmented = labels.length <= config.maxSegmentCount;
    final control = segmented
        ? SegmentedButton<T>(
            key: controlKey,
            segments: [
              for (final entry in labels.entries)
                ButtonSegment<T>(value: entry.key, label: Text(entry.value)),
            ],
            selected: {if (value != null) value!},
            emptySelectionAllowed: value == null,
            onSelectionChanged: onChanged == null
                ? null
                : (values) {
                    if (values.isNotEmpty) onChanged!(values.first);
                  },
          )
        : MenuAnchor(
            animated: true,
            menuChildren: [
              for (final entry in labels.entries)
                MenuItemButton(
                  leadingIcon: Opacity(
                    opacity: entry.key == value ? 1 : 0,
                    child: const Icon(Icons.check),
                  ),
                  onPressed: onChanged == null
                      ? null
                      : () => onChanged!(entry.key),
                  child: Text(entry.value),
                ),
            ],
            builder: (context, controller, child) => TextButton.icon(
              key: controlKey,
              onPressed: onChanged == null
                  ? null
                  : () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(labels[value] ?? ''),
            ),
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = _isStacked(context, constraints, segmented: segmented);
        return AdaptiveListTile.material(
          title: title,
          trailing: stacked
              ? null
              : segmented
              ? control
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        (constraints.maxWidth - 32).clamp(0, double.infinity) *
                        .6,
                  ),
                  child: control,
                ),
          subtitle: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ?subtitle,
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: control,
                    ),
                  ],
                )
              : subtitle,
        );
      },
    );
  }
}
