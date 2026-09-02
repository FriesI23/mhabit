import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_app_bar_actions.dart';
import '../material/material_app_bar_actions.dart';

/// Receives an invoked action together with the button that anchored it.
///
/// Primary actions report their own button context. Actions selected from an
/// overflow menu report the overflow trigger context.
typedef AdaptiveAppBarActionCallback<T extends Object> =
    void Function(BuildContext anchorContext, T value);

/// Decorates one renderer-owned primary action button.
///
/// [child] retains the platform button, invocation anchor, and resolved
/// presentation. Use [action] to apply state to one declared action without
/// wrapping the complete action collection.
typedef AdaptiveAppBarPrimaryActionDecorator<T extends Object> =
    Widget Function(
      BuildContext context,
      AdaptiveAction<T> action,
      Widget child,
    );

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
    this.primaryActionDecorator,
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
    this.materialOverflowIcon,
    this.overflowTooltip,
    this.primaryActionDecorator,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       appleIconBuilder = null,
       appleOverflowIcon = null,
       style = AdaptiveStyle.material;

  const AdaptiveAppBarActions.apple({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.appleIconBuilder,
    this.appleOverflowIcon,
    this.overflowTooltip,
    this.primaryActionDecorator,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       materialIconBuilder = null,
       materialOverflowIcon = null,
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
  final AdaptiveAppBarPrimaryActionDecorator<T>? primaryActionDecorator;

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
      AdaptiveStyle.material => MaterialAppBarActions<T>(
        collection: collection,
        onInvoke: onInvoke,
        primaryCapacity: primaryCapacity,
        maxPrimaryActions: maxPrimaryActions,
        iconBuilder: materialIconBuilder,
        overflowIcon: materialOverflowIcon,
        overflowTooltip: effectiveOverflowTooltip,
        primaryActionDecorator: primaryActionDecorator,
      ),
      AdaptiveStyle.apple => CupertinoAppBarActions<T>(
        collection: collection,
        onInvoke: onInvoke,
        primaryCapacity: primaryCapacity,
        maxPrimaryActions: maxPrimaryActions,
        iconBuilder: appleIconBuilder,
        overflowIcon: appleOverflowIcon,
        overflowTooltip: effectiveOverflowTooltip,
        primaryActionDecorator: primaryActionDecorator,
      ),
    };
  }
}
