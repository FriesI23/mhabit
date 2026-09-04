import 'dart:math' as math;

import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_app_bar_actions.dart';
import '../material/material_app_bar_actions.dart';

/// Receives an invoked action together with the button that anchored it.
typedef AdaptiveAppBarActionCallback<T extends Object> =
    void Function(BuildContext anchorContext, T value);

/// Decorates one renderer-owned primary action button.
typedef AdaptiveAppBarPrimaryActionDecorator<T extends Object> =
    Widget Function(
      BuildContext context,
      AdaptiveAction<T> action,
      Widget child,
    );

/// Platform-specific rendering configuration for adaptive app-bar actions.
sealed class AppBarActionsConfig<T extends Object> {
  const AppBarActionsConfig();
}

/// Material rendering configuration for adaptive app-bar actions.
final class MaterialAppBarActionsConfig<T extends Object>
    extends AppBarActionsConfig<T> {
  const MaterialAppBarActionsConfig({
    this.iconBuilder,
    this.overflowIcon,
    this.presentationForAction,
    this.actionButtonBuilder,
    this.overflowButtonBuilder,
    this.responsiveLayout,
  });

  final MaterialActionIconBuilder<T>? iconBuilder;
  final Widget? overflowIcon;
  final MaterialActionPresentationCallback<T>? presentationForAction;
  final MaterialActionButtonBuilder<T>? actionButtonBuilder;
  final MaterialOverflowButtonBuilder? overflowButtonBuilder;
  final MaterialAppBarResponsiveLayout? responsiveLayout;
}

/// Geometry used to shrink a Material toolbar action region by whole slots.
///
/// [reservedWidth] belongs to the surrounding toolbar chrome (leading, title,
/// padding, or another composite control). The action region keeps its
/// preferred capacity while possible, then yields whole 48dp slots down to
/// [minimumCapacity], which is normally the single More button.
final class MaterialAppBarResponsiveLayout {
  const MaterialAppBarResponsiveLayout({
    required this.reservedWidth,
    this.minimumCapacity = 48.0,
    this.slotExtent = 48.0,
  }) : assert(reservedWidth >= 0),
       assert(minimumCapacity >= 0),
       assert(slotExtent > 0);

  final double reservedWidth;
  final double minimumCapacity;
  final double slotExtent;
}

/// Cupertino rendering configuration for adaptive app-bar actions.
final class CupertinoAppBarActionsConfig<T extends Object>
    extends AppBarActionsConfig<T> {
  const CupertinoAppBarActionsConfig({
    this.iconBuilder,
    this.overflowIcon,
    this.presentationForAction,
    this.actionButtonBuilder,
    this.overflowButtonBuilder,
    this.onOverflowMenuOpened,
    this.onOverflowMenuClosed,
  });

  final CupertinoActionIconBuilder<T>? iconBuilder;
  final Widget? overflowIcon;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoOverflowButtonBuilder? overflowButtonBuilder;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
}

/// Adaptive trailing actions for an app bar or navigation bar.
///
/// Flutter's adaptive widgets keep common behavior on the adaptive facade and
/// dispatch platform presentation internally. This widget follows the same
/// boundary while grouping renderer-only knobs into [material] and [apple].
class AdaptiveAppBarActions<T extends Object> extends StatelessWidget {
  const AdaptiveAppBarActions({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.material,
    this.apple,
    this.overflowTooltip,
    this.primaryActionDecorator,
    this.layoutDelegate,
    this.fadeDuration = Duration.zero,
    this.resizeDuration = Duration.zero,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       style = null;

  const AdaptiveAppBarActions.material({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.material,
    this.overflowTooltip,
    this.primaryActionDecorator,
    this.layoutDelegate,
    this.fadeDuration = Duration.zero,
    this.resizeDuration = Duration.zero,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       apple = null,
       style = AdaptiveStyle.material;

  const AdaptiveAppBarActions.apple({
    super.key,
    required this.collection,
    required this.onInvoke,
    required this.primaryCapacity,
    this.maxPrimaryActions,
    this.apple,
    this.overflowTooltip,
    this.primaryActionDecorator,
    this.layoutDelegate,
    this.fadeDuration = Duration.zero,
    this.resizeDuration = Duration.zero,
  }) : assert(primaryCapacity >= 0 && primaryCapacity < double.infinity),
       assert(maxPrimaryActions == null || maxPrimaryActions >= 0),
       material = null,
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final double primaryCapacity;
  final int? maxPrimaryActions;
  final MaterialAppBarActionsConfig<T>? material;
  final CupertinoAppBarActionsConfig<T>? apple;
  final String? overflowTooltip;
  final AdaptiveAppBarPrimaryActionDecorator<T>? primaryActionDecorator;
  final ActionRegionLayoutDelegate? layoutDelegate;
  final Duration fadeDuration;
  final Duration resizeDuration;

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
      AdaptiveStyle.apple => _buildApple(effectiveOverflowTooltip),
    };
  }

  Widget _buildMaterial(BuildContext context, String effectiveOverflowTooltip) {
    final config = material ?? MaterialAppBarActionsConfig<T>();
    final responsiveLayout = config.responsiveLayout;
    final effectivePrimaryCapacity = responsiveLayout == null
        ? primaryCapacity
        : _resolveMaterialCapacity(context, responsiveLayout);
    return MaterialAppBarActions<T>(
      collection: collection,
      onInvoke: onInvoke,
      primaryCapacity: effectivePrimaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: config.iconBuilder,
      overflowIcon: config.overflowIcon,
      overflowTooltip: effectiveOverflowTooltip,
      primaryActionDecorator: primaryActionDecorator,
      presentationForAction: config.presentationForAction,
      actionButtonBuilder: config.actionButtonBuilder,
      overflowButtonBuilder: config.overflowButtonBuilder,
      layoutDelegate: layoutDelegate,
      fadeDuration: fadeDuration,
      resizeDuration: resizeDuration,
    );
  }

  double _resolveMaterialCapacity(
    BuildContext context,
    MaterialAppBarResponsiveLayout layout,
  ) {
    if (primaryCapacity == 0) return 0;
    final available = math.max(
      0.0,
      MediaQuery.sizeOf(context).width - layout.reservedWidth,
    );
    final slotted =
        (available / layout.slotExtent).floorToDouble() * layout.slotExtent;
    return math.min(primaryCapacity, math.max(layout.minimumCapacity, slotted));
  }

  Widget _buildApple(String effectiveOverflowTooltip) {
    final config = apple ?? CupertinoAppBarActionsConfig<T>();
    return CupertinoAppBarActions<T>(
      collection: collection,
      onInvoke: onInvoke,
      primaryCapacity: primaryCapacity,
      maxPrimaryActions: maxPrimaryActions,
      iconBuilder: config.iconBuilder,
      overflowIcon: config.overflowIcon,
      overflowTooltip: effectiveOverflowTooltip,
      primaryActionDecorator: primaryActionDecorator,
      presentationForAction: config.presentationForAction,
      actionButtonBuilder: config.actionButtonBuilder,
      overflowButtonBuilder: config.overflowButtonBuilder,
      onOverflowMenuOpened: config.onOverflowMenuOpened,
      onOverflowMenuClosed: config.onOverflowMenuClosed,
      layoutDelegate: layoutDelegate,
      fadeDuration: fadeDuration,
      resizeDuration: resizeDuration,
    );
  }
}
