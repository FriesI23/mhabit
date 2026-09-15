import 'package:flutter/material.dart';

class MaterialAdaptiveExpansionTile extends StatelessWidget {
  const MaterialAdaptiveExpansionTile({
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
  Widget build(BuildContext context) => ExpansionTile(
    controller: controller,
    initiallyExpanded: controller.isExpanded,
    title: title,
    subtitle: subtitle,
    trailing: trailing,
    enabled: enabled,
    showTrailingIcon: enabled,
    maintainState: true,
    tilePadding: ListTileTheme.of(context).contentPadding,
    shape: const Border(),
    collapsedShape: const Border(),
    expandedAlignment: AlignmentDirectional.centerStart,
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
