import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_dialog.dart';
import '../material/material_adaptive_dialog.dart';

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
