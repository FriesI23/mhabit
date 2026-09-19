import 'package:flutter/cupertino.dart';

import '../adaptive/adaptive_dialog.dart' show AdaptiveDialogAction;

/// Cupertino alert content with platform-neutral action definitions.
///
/// Always renders Cupertino, independently of [AdaptiveStyleScope]. This widget
/// does not create a route; use [AdaptiveDialog] with [showAdaptiveModalDialog]
/// for matching adaptive route and content styles.
class CupertinoAdaptiveDialog extends StatelessWidget {
  const CupertinoAdaptiveDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? content;
  final List<AdaptiveDialogAction> actions;

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
    title: title,
    content: content,
    actions: [
      for (final action in actions)
        _CupertinoAdaptiveDialogAction(action: action),
    ],
  );
}

/// Adds keyboard focus to CupertinoDialogAction's native touch handling.
class _CupertinoAdaptiveDialogAction extends StatefulWidget {
  const _CupertinoAdaptiveDialogAction({required this.action});

  final AdaptiveDialogAction action;

  @override
  State<_CupertinoAdaptiveDialogAction> createState() =>
      _CupertinoAdaptiveDialogActionState();
}

class _CupertinoAdaptiveDialogActionState
    extends State<_CupertinoAdaptiveDialogAction> {
  bool _showFocus = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final enabled = action.enabled && action.onPressed != null;
    return FocusableActionDetector(
      enabled: enabled,
      onShowFocusHighlight: (value) => setState(() => _showFocus = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (enabled) action.onPressed!();
            return null;
          },
        ),
      },
      child: Semantics(
        enabled: enabled,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: enabled && _showFocus
                ? Border.all(
                    color: CupertinoTheme.of(context).primaryColor,
                    width: 2,
                  )
                : null,
          ),
          child: CupertinoDialogAction(
            onPressed: enabled ? action.onPressed : null,
            isDefaultAction: action.isDefaultAction,
            isDestructiveAction: action.isDestructiveAction,
            child: Text(action.label),
          ),
        ),
      ),
    );
  }
}
