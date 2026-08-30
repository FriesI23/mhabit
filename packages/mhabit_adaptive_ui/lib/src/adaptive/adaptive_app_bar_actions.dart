import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Receives an invoked action together with the button that anchored it.
///
/// Primary actions report their own button context. Actions selected from an
/// overflow menu report the overflow trigger context.
typedef AdaptiveAppBarActionCallback<T extends Object> =
    void Function(BuildContext anchorContext, T value);

/// Adaptive trailing actions for an app bar or navigation bar.
///
/// The caller owns the platform-neutral [collection] and payload handling.
/// This widget only selects the Material or Apple renderer and keeps the
/// action region compact enough for toolbar placement.
class AdaptiveAppBarActions<T extends Object> extends StatelessWidget {
  const AdaptiveAppBarActions({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.materialIconBuilder,
    this.appleIconBuilder,
    this.materialOverflowIcon,
    this.appleOverflowIcon,
    this.overflowTooltip,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       style = null;

  const AdaptiveAppBarActions.material({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.materialIconBuilder,
    this.appleIconBuilder,
    this.materialOverflowIcon,
    this.appleOverflowIcon,
    this.overflowTooltip,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       style = AdaptiveStyle.material;

  const AdaptiveAppBarActions.apple({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.materialIconBuilder,
    this.appleIconBuilder,
    this.materialOverflowIcon,
    this.appleOverflowIcon,
    this.overflowTooltip,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final double primaryCapacity;
  final int? maxPrimaryActions;
  final MaterialActionIconBuilder<T>? materialIconBuilder;
  final CupertinoActionIconBuilder<T>? appleIconBuilder;
  final Widget? materialOverflowIcon;
  final Widget? appleOverflowIcon;
  final String? overflowTooltip;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AdaptiveStyle.of(context);
    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final effectiveOverflowTooltip =
        overflowTooltip ??
        materialLocalizations?.showMenuTooltip ??
        'More actions';
    return switch (effectiveStyle) {
      AdaptiveStyle.material => _buildMaterial(
        context,
        effectiveOverflowTooltip,
      ),
      AdaptiveStyle.apple => _buildApple(context, effectiveOverflowTooltip),
    };
  }

  Widget _buildMaterial(BuildContext context, String overflowTooltip) {
    final primaryAnchors = <T, BuildContext>{};
    BuildContext? overflowAnchor;
    return MaterialAdaptiveActions<T>.moreAction(
      actions: collection,
      onInvoke: (value) =>
          onInvoke(primaryAnchors[value] ?? overflowAnchor ?? context, value),
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: materialIconBuilder,
      actionButtonBuilder: (context, action, onPressed, defaultBuilder) {
        return Builder(
          builder: (anchorContext) {
            final payload = action.payload;
            if (payload != null) primaryAnchors[payload] = anchorContext;
            return defaultBuilder(anchorContext, action, onPressed);
          },
        );
      },
      overflowButtonBuilder: (context, onPressed, defaultBuilder) {
        return Builder(
          builder: (anchorContext) {
            overflowAnchor = anchorContext;
            return defaultBuilder(anchorContext, onPressed);
          },
        );
      },
      overflowIcon: materialOverflowIcon ?? const Icon(Icons.more_vert),
      overflowTooltip: overflowTooltip,
      presentationOverride: MaterialActionPresentation.iconOnly,
      fadeDuration: Duration.zero,
      resizeDuration: Duration.zero,
    );
  }

  Widget _buildApple(BuildContext context, String overflowTooltip) {
    final primaryAnchors = <T, BuildContext>{};
    BuildContext? overflowAnchor;
    return CupertinoAdaptiveActions<T>.moreAction(
      actions: collection,
      onInvoke: (value) =>
          onInvoke(primaryAnchors[value] ?? overflowAnchor ?? context, value),
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: appleIconBuilder,
      actionButtonBuilder: (context, action, onPressed, defaultBuilder) {
        return Builder(
          builder: (anchorContext) {
            final payload = action.payload;
            if (payload != null) primaryAnchors[payload] = anchorContext;
            return defaultBuilder(anchorContext, action, onPressed);
          },
        );
      },
      overflowButtonBuilder: (context, onPressed, defaultBuilder) {
        return Builder(
          builder: (anchorContext) {
            overflowAnchor = anchorContext;
            return defaultBuilder(anchorContext, onPressed);
          },
        );
      },
      overflowIcon: appleOverflowIcon ?? const Icon(CupertinoIcons.ellipsis),
      overflowTooltip: overflowTooltip,
      presentationOverride: CupertinoActionPresentation.iconOnly,
      invokeAfterMenuClosed: true,
      fadeDuration: Duration.zero,
      resizeDuration: Duration.zero,
    );
  }
}
