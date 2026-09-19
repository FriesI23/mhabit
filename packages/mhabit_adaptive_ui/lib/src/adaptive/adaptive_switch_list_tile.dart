import 'package:flutter/widgets.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_switch_list_tile.dart';
import '../material/material_adaptive_switch_list_tile.dart';

/// A single boolean setting whose row and switch perform the same action.
///
/// Like SwitchListTile, descendants must support merged semantics. Use a plain
/// AdaptiveListTile for rows with an independent secondary action.
class AdaptiveSwitchListTile extends StatelessWidget {
  const AdaptiveSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : style = null;
  const AdaptiveSwitchListTile.material({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : style = AdaptiveStyle.material;
  const AdaptiveSwitchListTile.apple({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) =>
      switch (style ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => MaterialAdaptiveSwitchListTile(
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: onChanged,
        ),
        AdaptiveStyle.apple => CupertinoAdaptiveSwitchListTile(
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: onChanged,
        ),
      };
}
