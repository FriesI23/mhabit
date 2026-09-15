import 'package:flutter/cupertino.dart';

import 'cupertino_adaptive_list_tile.dart';

class CupertinoAdaptiveExpansionTile extends StatelessWidget {
  const CupertinoAdaptiveExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    required this.controller,
    required this.enabled,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final ExpansibleController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Expansible(
    controller: controller,
    headerBuilder: (context, animation) => Semantics(
      expanded: enabled ? controller.isExpanded : null,
      child: CupertinoAdaptiveListTile(
        title: title,
        subtitle: subtitle,
        trailing:
            trailing ??
            (enabled
                ? Icon(
                    controller.isExpanded
                        ? CupertinoIcons.chevron_down
                        : CupertinoIcons.chevron_forward,
                  )
                : null),
        onTap: enabled ? controller.toggle : null,
      ),
    ),
    bodyBuilder: (context, animation) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
