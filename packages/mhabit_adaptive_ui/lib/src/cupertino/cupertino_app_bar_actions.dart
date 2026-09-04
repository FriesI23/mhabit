import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';

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
    this.overflowButtonBuilder,
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
  final CupertinoOverflowButtonBuilder? overflowButtonBuilder;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final ActionRegionLayoutDelegate? layoutDelegate;
  final Duration fadeDuration;
  final Duration resizeDuration;

  @override
  Widget build(BuildContext context) {
    final primaryAnchors = <T, BuildContext>{};
    BuildContext? overflowAnchor;
    return CupertinoAdaptiveActions<T>.moreAction(
      actions: collection,
      onInvoke: (value) =>
          onInvoke(primaryAnchors[value] ?? overflowAnchor ?? context, value),
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: iconBuilder,
      actionButtonBuilder: (context, action, onPressed, defaultBuilder) {
        /// Keeps the anchor context inside the concrete button subtree because
        /// the callback context can resolve to a RenderSliver in a pinned bar.
        return Builder(
          builder: (anchorContext) {
            final payload = action.payload;
            if (payload != null) primaryAnchors[payload] = anchorContext;
            final child =
                actionButtonBuilder?.call(
                  anchorContext,
                  action,
                  onPressed,
                  defaultBuilder,
                ) ??
                defaultBuilder(anchorContext, action, onPressed);
            return primaryActionDecorator?.call(anchorContext, action, child) ??
                child;
          },
        );
      },
      overflowButtonBuilder: (context, onPressed, defaultBuilder) {
        /// Keeps the anchor context inside the concrete button subtree because
        /// the callback context can resolve to a RenderSliver in a pinned bar.
        return Builder(
          builder: (anchorContext) {
            overflowAnchor = anchorContext;
            return overflowButtonBuilder?.call(
                  anchorContext,
                  onPressed,
                  defaultBuilder,
                ) ??
                defaultBuilder(anchorContext, onPressed);
          },
        );
      },
      overflowIcon: overflowIcon ?? const Icon(CupertinoIcons.ellipsis),
      overflowTooltip: overflowTooltip,
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
