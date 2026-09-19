import 'package:flutter/cupertino.dart';

import 'cupertino_adaptive_list_tile.dart';

class CupertinoAdaptiveSwitchListTile extends StatelessWidget {
  const CupertinoAdaptiveSwitchListTile({
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
  Widget build(BuildContext context) => MergeSemantics(
    child: CupertinoAdaptiveListTile(
      title: title,
      subtitle: subtitle,
      trailing: ExcludeFocus(
        child: CupertinoSwitch(value: value, onChanged: onChanged),
      ),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    ),
  );
}
