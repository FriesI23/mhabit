import 'package:flutter/material.dart';

import '../adaptive/list_section_row_scope.dart';
import '../adaptive_style.dart';

class MaterialAdaptiveSwitchListTile extends StatelessWidget {
  const MaterialAdaptiveSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final section = ListSectionRowScope.maybeOf(context);
    return SwitchListTile(
      statesController: section?.style == AdaptiveStyle.material
          ? section?.statesController
          : null,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }
}
