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
          _buildActionButton(
            context,
            action,
            onPressed,
            defaultBuilder,
            primaryAnchors,
          ),
      submenuButtonBuilder: _buildSubmenuButton,
      focusHaloBuilder: focusTheme.buildHalo,
      menuBuilderForAction: menuBuilderForAction,
      overflowButtonBuilder: (context, onPressed, defaultBuilder) => Builder(
        builder: (anchorContext) {
          // Keep the anchor inside the concrete button subtree because the
          // callback context can resolve to a RenderSliver in a pinned bar.
          overflowAnchorContext = anchorContext;
          return _buildOverflowButton(anchorContext, onPressed, defaultBuilder);
        },
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

  Widget _buildActionButton(
    BuildContext context,
    AdaptiveAction<T> action,
    VoidCallback? onPressed,
    CupertinoActionButtonDefaultBuilder<T> defaultBuilder,
    Map<T, BuildContext> primaryAnchors,
  ) {
    // Keep the anchor inside the concrete button subtree because [context]
    // can resolve to a RenderSliver in a pinned bar.
    return Builder(
      builder: (anchorContext) {
        Widget effectiveDefaultBuilder(
          BuildContext context,
          AdaptiveAction<T> action,
          VoidCallback? onPressed,
        ) => CupertinoNeutralButtonBuilder(
          builder: (context) => defaultBuilder(context, action, onPressed),
        );

        final payload = action.payload;
        if (payload != null) primaryAnchors[payload] = anchorContext;
        final child =
            actionButtonBuilder?.call(
              anchorContext,
              action,
              onPressed,
              effectiveDefaultBuilder,
            ) ??
            effectiveDefaultBuilder(anchorContext, action, onPressed);
        return primaryActionDecorator?.call(anchorContext, action, child) ??
            child;
      },
    );
  }

  Widget _buildSubmenuButton(
    BuildContext context,
    AdaptiveAction<T> action,
    VoidCallback? onPressed,
    CupertinoSubmenuButtonDefaultBuilder<T> defaultBuilder,
  ) {
    Widget effectiveDefaultBuilder(
      BuildContext context,
      AdaptiveAction<T> action,
      VoidCallback? onPressed,
    ) => CupertinoNeutralButtonBuilder(
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

  Widget _buildOverflowButton(
    BuildContext context,
    VoidCallback onPressed,
    CupertinoOverflowButtonDefaultBuilder defaultBuilder,
  ) {
    Widget effectiveDefaultBuilder(
      BuildContext context,
      VoidCallback onPressed, {
      Widget? icon,
    }) => CupertinoNeutralButtonBuilder(
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
