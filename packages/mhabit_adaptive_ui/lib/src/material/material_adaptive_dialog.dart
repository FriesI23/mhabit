import 'package:flutter/material.dart';

import '../adaptive/adaptive_dialog.dart' show AdaptiveDialogAction;

/// Material alert content with platform-neutral action definitions.
///
/// Always renders Material, independently of [AdaptiveStyleScope]. This widget
/// does not create a route; use [AdaptiveDialog] with [showAdaptiveModalDialog]
/// for matching adaptive route and content styles.
class MaterialAdaptiveDialog extends StatelessWidget {
  const MaterialAdaptiveDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<AdaptiveDialogAction> actions;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: icon,
    title: title,
    content: content,
    scrollable: true,
    actions: [
      for (final action in actions)
        TextButton(
          onPressed: action.enabled ? action.onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: action.isDestructiveAction
                ? Theme.of(context).colorScheme.error
                : null,
            textStyle: action.isDefaultAction
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
          child: Text(action.label),
        ),
    ],
  );
}
