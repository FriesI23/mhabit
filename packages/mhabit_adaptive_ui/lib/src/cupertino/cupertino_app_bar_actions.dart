import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';

import 'adaptive_cupertino_focus_theme.dart';
import 'cupertino_neutral_button.dart';

/// Cupertino renderer adapter for adaptive app-bar actions.
class CupertinoAppBarActions<T extends Object> extends StatelessWidget {
  const CupertinoAppBarActions({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    required this.overflowTooltip,
    this.maxPrimaryActions,
    this.iconBuilder,
    this.overflowIcon,
    this.primaryActionDecorator,
    this.presentationForAction,
    this.actionButtonBuilder,
    this.submenuButtonBuilder,
    this.menuBuilderForAction,
    this.overflowButtonBuilder,
    this.tooltipBuilder,
    this.onOverflowMenuOpened,
    this.onOverflowMenuClosed,
    this.layoutDelegate,
    this.fadeDuration = Duration.zero,
    this.resizeDuration = Duration.zero,
  });

  final ActionCollection<T> collection;
  final void Function(BuildContext anchorContext, T value) onInvoke;
  final double primaryCapacity;
  final int? maxPrimaryActions;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final Widget? overflowIcon;
  final String overflowTooltip;
  final Widget Function(
    BuildContext context,
    AdaptiveAction<T> action,
    Widget child,
  )?
  primaryActionDecorator;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoSubmenuButtonBuilder<T>? submenuButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoOverflowButtonBuilder? overflowButtonBuilder;

  /// Builds the visual tooltip wrapper for the action renderer.
  ///
  /// When null, the renderer uses [AdaptiveCupertinoTooltip]. The renderer
  /// retains ownership of tooltip text, visibility, and action accessibility
  /// semantics.
  final AdaptiveCupertinoTooltipBuilder? tooltipBuilder;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final ActionRegionLayoutDelegate? layoutDelegate;
  final Duration fadeDuration;
  final Duration resizeDuration;

  @override
  Widget build(BuildContext context) {
    final focusTheme = AdaptiveCupertinoFocusThemeData.of(context);
    final primaryAnchors = <T, BuildContext>{};
    BuildContext? overflowAnchorContext;

    return CupertinoAdaptiveActions<T>.moreAction(
      actions: collection,
      onInvoke: (value) => onInvoke(
        primaryAnchors[value] ?? overflowAnchorContext ?? context,
        value,
      ),
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: iconBuilder,
      actionButtonBuilder: (context, action, onPressed, defaultBuilder) =>
          _CupertinoAppBarActionButton<T>(
            action: action,
            onPressed: onPressed,
            defaultBuilder: defaultBuilder,
            actionButtonBuilder: actionButtonBuilder,
            primaryActionDecorator: primaryActionDecorator,
            onAnchor: (payload, anchorContext) =>
                primaryAnchors[payload] = anchorContext,
          ),
      submenuButtonBuilder: (context, action, onPressed, defaultBuilder) =>
          _CupertinoAppBarSubmenuButton<T>(
            action: action,
            onPressed: onPressed,
            defaultBuilder: defaultBuilder,
            submenuButtonBuilder: submenuButtonBuilder,
          ),
      focusHaloBuilder: focusTheme.buildHalo,
      menuBuilderForAction: menuBuilderForAction,
      overflowButtonBuilder: (context, onPressed, defaultBuilder) =>
          _CupertinoAppBarOverflowButton(
            onPressed: onPressed,
            defaultBuilder: defaultBuilder,
            overflowButtonBuilder: overflowButtonBuilder,
            onAnchor: (anchorContext) => overflowAnchorContext = anchorContext,
          ),
      overflowIcon: overflowIcon ?? const Icon(CupertinoIcons.ellipsis),
      overflowTooltip: overflowTooltip,
      tooltipBuilder: tooltipBuilder,
      onOverflowMenuOpened: onOverflowMenuOpened,
      onOverflowMenuClosed: onOverflowMenuClosed,
      presentationForAction: presentationForAction,
      presentationOverride: CupertinoActionPresentation.iconOnly,
      invokeAfterMenuClosed: true,
      layoutDelegate: layoutDelegate,
      fadeDuration: fadeDuration,
      resizeDuration: resizeDuration,
    );
  }
}

typedef _PrimaryActionDecorator<T extends Object> =
    Widget Function(
      BuildContext context,
      AdaptiveAction<T> action,
      Widget child,
    );

class _CupertinoAppBarActionButton<T extends Object> extends StatelessWidget {
  const _CupertinoAppBarActionButton({
    required this.action,
    required this.onPressed,
    required this.defaultBuilder,
    required this.actionButtonBuilder,
    required this.primaryActionDecorator,
    required this.onAnchor,
  });

  final AdaptiveAction<T> action;
  final VoidCallback? onPressed;
  final CupertinoActionButtonDefaultBuilder<T> defaultBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final _PrimaryActionDecorator<T>? primaryActionDecorator;
  final void Function(T payload, BuildContext context) onAnchor;

  @override
  Widget build(BuildContext context) {
    Widget effectiveDefaultBuilder(
      BuildContext context,
      AdaptiveAction<T> action,
      VoidCallback? onPressed,
    ) => NeutralCupertinoButtonBuilder(
      builder: (context) => defaultBuilder(context, action, onPressed),
    );

    final payload = action.payload;
    if (payload != null) onAnchor(payload, context);
    final child =
        actionButtonBuilder?.call(
          context,
          action,
          onPressed,
          effectiveDefaultBuilder,
        ) ??
        effectiveDefaultBuilder(context, action, onPressed);
    return primaryActionDecorator?.call(context, action, child) ?? child;
  }
}

class _CupertinoAppBarSubmenuButton<T extends Object> extends StatelessWidget {
  const _CupertinoAppBarSubmenuButton({
    required this.action,
    required this.onPressed,
    required this.defaultBuilder,
    required this.submenuButtonBuilder,
  });

  final AdaptiveAction<T> action;
  final VoidCallback? onPressed;
  final CupertinoSubmenuButtonDefaultBuilder<T> defaultBuilder;
  final CupertinoSubmenuButtonBuilder<T>? submenuButtonBuilder;

  @override
  Widget build(BuildContext context) {
    Widget effectiveDefaultBuilder(
      BuildContext context,
      AdaptiveAction<T> action,
      VoidCallback? onPressed,
    ) => NeutralCupertinoButtonBuilder(
      builder: (context) => defaultBuilder(context, action, onPressed),
    );

    return submenuButtonBuilder?.call(
          context,
          action,
          onPressed,
          effectiveDefaultBuilder,
        ) ??
        effectiveDefaultBuilder(context, action, onPressed);
  }
}

class _CupertinoAppBarOverflowButton extends StatelessWidget {
  const _CupertinoAppBarOverflowButton({
    required this.onPressed,
    required this.defaultBuilder,
    required this.overflowButtonBuilder,
    required this.onAnchor,
  });

  final VoidCallback onPressed;
  final CupertinoOverflowButtonDefaultBuilder defaultBuilder;
  final CupertinoOverflowButtonBuilder? overflowButtonBuilder;
  final ValueChanged<BuildContext> onAnchor;

  @override
  Widget build(BuildContext context) {
    // Keep the anchor inside the concrete button subtree because the callback
    // context can resolve to a RenderSliver in a pinned bar.
    onAnchor(context);

    Widget effectiveDefaultBuilder(
      BuildContext context,
      VoidCallback onPressed, {
      Widget? icon,
    }) => NeutralCupertinoButtonBuilder(
      builder: (context) => defaultBuilder(context, onPressed, icon: icon),
    );

    return overflowButtonBuilder?.call(
          context,
          onPressed,
          effectiveDefaultBuilder,
        ) ??
        effectiveDefaultBuilder(context, onPressed);
  }
}
