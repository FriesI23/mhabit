import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Opens a standard centered dialog, without sheet or drag behavior.
///
/// Style and inherited themes are captured at the call site. The builder runs
/// in the new route; page-local providers must be bridged explicitly. Actions
/// can return a typed result using Navigator.pop with the builder's context.
Future<T?> showAdaptiveModalDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool barrierDismissible,
  AdaptiveStyle? styleOverride,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final style = styleOverride ?? AdaptiveStyle.of(context);
  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );
  final direction = Directionality.of(context);
  Widget buildContent(BuildContext context) => themes.wrap(
    Directionality(
      textDirection: direction,
      child: AdaptiveStyleScope(
        override: style,
        child: Builder(builder: builder),
      ),
    ),
  );

  return switch (style) {
    AdaptiveStyle.material => showDialog<T>(
      context: context,
      builder: buildContent,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    ),
    AdaptiveStyle.apple => showCupertinoDialog<T>(
      context: context,
      builder: buildContent,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    ),
  };
}

/// A platform-neutral action. Invoking it does not automatically close a route.
class AdaptiveDialogAction {
  const AdaptiveDialogAction({
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  /// Visual emphasis only; does not install a keyboard submit shortcut.
  final bool isDefaultAction;
  final bool isDestructiveAction;
}

/// Standard alert content for [showAdaptiveModalDialog].
class AdaptiveDialog extends StatelessWidget {
  const AdaptiveDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? content;
  final List<AdaptiveDialogAction> actions;

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.apple => CupertinoAdaptiveDialog(
      title: title,
      content: content,
      actions: actions,
    ),
    AdaptiveStyle.material => MaterialAdaptiveDialog(
      title: title,
      content: content,
      actions: actions,
    ),
  };
}

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
