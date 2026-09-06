import 'package:adaptive_actions/material.dart';
import 'package:flutter/material.dart';

/// Material renderer adapter for adaptive app-bar actions.
class MaterialAppBarActions<T extends Object> extends StatelessWidget {
  const MaterialAppBarActions({
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
    this.menuBuilderForAction,
    this.overflowButtonBuilder,
    this.layoutDelegate,
    this.fadeDuration = Duration.zero,
    this.resizeDuration = Duration.zero,
  });

  final ActionCollection<T> collection;
  final void Function(BuildContext anchorContext, T value) onInvoke;
  final double primaryCapacity;
  final int? maxPrimaryActions;
  final MaterialActionIconBuilder<T>? iconBuilder;
  final Widget? overflowIcon;
  final String overflowTooltip;
  final Widget Function(
    BuildContext context,
    AdaptiveAction<T> action,
    Widget child,
  )?
  primaryActionDecorator;
  final MaterialActionPresentationCallback<T>? presentationForAction;
  final MaterialActionButtonBuilder<T>? actionButtonBuilder;
  final MaterialActionMenuBuilder<T>? menuBuilderForAction;
  final MaterialOverflowButtonBuilder? overflowButtonBuilder;
  final ActionRegionLayoutDelegate? layoutDelegate;
  final Duration fadeDuration;
  final Duration resizeDuration;

  @override
  Widget build(BuildContext context) {
    final primaryAnchors = <T, BuildContext>{};
    BuildContext? overflowAnchor;
    return MaterialAdaptiveActions<T>.moreAction(
      actions: collection,
      onInvoke: (value) =>
          onInvoke(primaryAnchors[value] ?? overflowAnchor ?? context, value),
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: iconBuilder,
      menuBuilderForAction: menuBuilderForAction,
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
      overflowIcon: overflowIcon ?? const Icon(Icons.more_vert),
      overflowTooltip: overflowTooltip,
      presentationForAction: presentationForAction,
      presentationOverride: MaterialActionPresentation.iconOnly,
      style: const MaterialAdaptiveActionsStyle(iconSize: 24),
      layoutDelegate: layoutDelegate,
      fadeDuration: fadeDuration,
      resizeDuration: resizeDuration,
    );
  }
}
