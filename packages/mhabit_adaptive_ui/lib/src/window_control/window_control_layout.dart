import 'package:flutter/material.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';

enum WindowControlLayoutOwner { appBar, rail }

enum _WindowControlLayoutAspect {
  appBarHorizontalAvoidance,
  railHorizontalAvoidance,
  railVerticalAvoidance,
  safeAreaGeometry,
  rectangularDisplay,
}

/// Complete corner-adapted safe-area geometry reported by UIKit.
@immutable
final class AdaptiveWindowSafeAreaGeometry {
  const AdaptiveWindowSafeAreaGeometry({
    required this.horizontalAvoidance,
    required this.verticalAvoidance,
    required this.effectiveCornerRadii,
  });

  /// Additional horizontal safe-area avoidance.
  final EdgeInsetsDirectional horizontalAvoidance;

  /// Additional vertical safe-area avoidance.
  final EdgeInsetsDirectional verticalAvoidance;

  /// Effective physical corner radii for the current window.
  final BorderRadius effectiveCornerRadii;

  @override
  bool operator ==(Object other) =>
      other is AdaptiveWindowSafeAreaGeometry &&
      other.horizontalAvoidance == horizontalAvoidance &&
      other.verticalAvoidance == verticalAvoidance &&
      other.effectiveCornerRadii == effectiveCornerRadii;

  @override
  int get hashCode =>
      Object.hash(horizontalAvoidance, verticalAvoidance, effectiveCornerRadii);
}

/// Queries iOS window-control layout once above an application's navigators.
///
/// Root routes and overlays default to app-bar ownership. A nested
/// [AdaptiveNavigationShell] overrides that allocation when a rail is visible.
class AdaptiveWindowControlLayout extends StatelessWidget {
  const AdaptiveWindowControlLayout({
    super.key,
    this.usesRectangularDisplay = false,
    required this.child,
  });

  /// Whether the current display has rectangular physical corners.
  final bool usesRectangularDisplay;

  final Widget child;

  @override
  Widget build(BuildContext context) => IosWindowControlLayout(
    child: Builder(
      builder: (context) {
        final layout = IosWindowControlLayout.of(context);
        return AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: layout.horizontalAvoidance,
          verticalAvoidance: layout.verticalAvoidance,
          horizontalSafeAreaAvoidance: layout.isAvailable
              ? layout.horizontalSafeAreaAvoidance
              : null,
          verticalSafeAreaAvoidance: layout.isAvailable
              ? layout.verticalSafeAreaAvoidance
              : null,
          effectiveCornerRadii: layout.isAvailable
              ? layout.effectiveCornerRadii
              : null,
          usesRectangularDisplay: usesRectangularDisplay,
          owner: WindowControlLayoutOwner.appBar,
          child: child,
        );
      },
    ),
  );
}

/// Distributes platform window-control avoidance between chrome consumers.
///
/// The application root defaults to app-bar ownership. A navigation shell
/// overrides this scope so rail layouts expose avoidance to the rail instead.
class AdaptiveWindowControlLayoutScope extends InheritedModel<Object> {
  const AdaptiveWindowControlLayoutScope({
    super.key,
    required this.horizontalAvoidance,
    required this.verticalAvoidance,
    this.horizontalSafeAreaAvoidance,
    this.verticalSafeAreaAvoidance,
    this.effectiveCornerRadii,
    this.usesRectangularDisplay = false,
    required this.owner,
    required super.child,
  });

  final EdgeInsetsDirectional horizontalAvoidance;
  final EdgeInsetsDirectional verticalAvoidance;

  /// UIKit's additional horizontal corner-adapted safe-area insets.
  ///
  /// A null value means the current platform cannot report this boundary.
  final EdgeInsetsDirectional? horizontalSafeAreaAvoidance;

  /// UIKit's additional vertical corner-adapted safe-area insets.
  ///
  /// A null value means the current platform cannot report this boundary.
  final EdgeInsetsDirectional? verticalSafeAreaAvoidance;

  /// UIKit's effective physical corner radii, when available.
  final BorderRadius? effectiveCornerRadii;

  /// Whether the current display has rectangular physical corners.
  final bool usesRectangularDisplay;

  final WindowControlLayoutOwner owner;

  EdgeInsetsDirectional get appBarHorizontalAvoidance =>
      owner == WindowControlLayoutOwner.appBar
      ? horizontalAvoidance
      : EdgeInsetsDirectional.zero;

  EdgeInsetsDirectional get railHorizontalAvoidance =>
      owner == WindowControlLayoutOwner.rail
      ? horizontalAvoidance
      : EdgeInsetsDirectional.zero;

  EdgeInsetsDirectional get railVerticalAvoidance =>
      owner == WindowControlLayoutOwner.rail
      ? verticalAvoidance
      : EdgeInsetsDirectional.zero;

  static AdaptiveWindowControlLayoutScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<AdaptiveWindowControlLayoutScope>();

  static EdgeInsetsDirectional appBarAvoidanceOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.appBarHorizontalAvoidance,
      )?.appBarHorizontalAvoidance ??
      EdgeInsetsDirectional.zero;

  static EdgeInsetsDirectional railHorizontalAvoidanceOf(
    BuildContext context,
  ) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.railHorizontalAvoidance,
      )?.railHorizontalAvoidance ??
      EdgeInsetsDirectional.zero;

  static EdgeInsetsDirectional railVerticalAvoidanceOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.railVerticalAvoidance,
      )?.railVerticalAvoidance ??
      EdgeInsetsDirectional.zero;

  /// Whether the current display has rectangular physical corners.
  static bool usesRectangularDisplayOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.rectangularDisplay,
      )?.usesRectangularDisplay ??
      false;

  /// Returns UIKit's corner-adapted safe-area avoidance and effective radii as
  /// one snapshot, rebuilding when any of that geometry changes.
  ///
  /// Returns null unless the complete geometry is available.
  static AdaptiveWindowSafeAreaGeometry? safeAreaGeometryOf(
    BuildContext context,
  ) {
    final scope = InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
      context,
      aspect: _WindowControlLayoutAspect.safeAreaGeometry,
    );
    final horizontalAvoidance = scope?.horizontalSafeAreaAvoidance;
    final verticalAvoidance = scope?.verticalSafeAreaAvoidance;
    final effectiveCornerRadii = scope?.effectiveCornerRadii;
    return horizontalAvoidance == null ||
            verticalAvoidance == null ||
            effectiveCornerRadii == null
        ? null
        : AdaptiveWindowSafeAreaGeometry(
            horizontalAvoidance: horizontalAvoidance,
            verticalAvoidance: verticalAvoidance,
            effectiveCornerRadii: effectiveCornerRadii,
          );
  }

  @override
  bool updateShouldNotify(AdaptiveWindowControlLayoutScope oldWidget) =>
      horizontalAvoidance != oldWidget.horizontalAvoidance ||
      verticalAvoidance != oldWidget.verticalAvoidance ||
      horizontalSafeAreaAvoidance != oldWidget.horizontalSafeAreaAvoidance ||
      verticalSafeAreaAvoidance != oldWidget.verticalSafeAreaAvoidance ||
      effectiveCornerRadii != oldWidget.effectiveCornerRadii ||
      usesRectangularDisplay != oldWidget.usesRectangularDisplay ||
      owner != oldWidget.owner;

  @override
  bool updateShouldNotifyDependent(
    AdaptiveWindowControlLayoutScope oldWidget,
    Set<Object> dependencies,
  ) {
    for (final aspect in _WindowControlLayoutAspect.values) {
      if (!dependencies.contains(aspect)) continue;
      final changed = switch (aspect) {
        _WindowControlLayoutAspect.appBarHorizontalAvoidance =>
          appBarHorizontalAvoidance != oldWidget.appBarHorizontalAvoidance,
        _WindowControlLayoutAspect.railHorizontalAvoidance =>
          railHorizontalAvoidance != oldWidget.railHorizontalAvoidance,
        _WindowControlLayoutAspect.railVerticalAvoidance =>
          railVerticalAvoidance != oldWidget.railVerticalAvoidance,
        _WindowControlLayoutAspect.safeAreaGeometry =>
          horizontalSafeAreaAvoidance !=
                  oldWidget.horizontalSafeAreaAvoidance ||
              verticalSafeAreaAvoidance !=
                  oldWidget.verticalSafeAreaAvoidance ||
              effectiveCornerRadii != oldWidget.effectiveCornerRadii,
        _WindowControlLayoutAspect.rectangularDisplay =>
          usesRectangularDisplay != oldWidget.usesRectangularDisplay,
      };
      if (changed) return true;
    }
    return false;
  }
}
