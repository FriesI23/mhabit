import 'package:flutter/material.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';

/// Chrome subtree that consumes platform window-control avoidance.
enum WindowControlLayoutOwner {
  /// Page app bars consume the window-control region.
  appBar,

  /// The active side-navigation renderer consumes the window-control region.
  sideNavigation,
}

enum _WindowControlLayoutAspect {
  appBarHorizontalAvoidance,
  sideNavigationHorizontalAvoidance,
  sideNavigationVerticalAvoidance,
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
  final EdgeInsets horizontalAvoidance;

  /// Additional vertical safe-area avoidance.
  final EdgeInsets verticalAvoidance;

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
/// [AdaptiveNavigationShell] overrides that allocation when side navigation
/// owns the window controls.
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
          hasWindowControlAvoidance: layout.hasWindowControlAvoidance,
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
/// overrides this scope so side-navigation layouts expose avoidance to their
/// renderer instead.
class AdaptiveWindowControlLayoutScope extends InheritedModel<Object> {
  const AdaptiveWindowControlLayoutScope({
    super.key,
    this.hasWindowControlAvoidance = false,
    required this.horizontalAvoidance,
    required this.verticalAvoidance,
    this.horizontalSafeAreaAvoidance,
    this.verticalSafeAreaAvoidance,
    this.effectiveCornerRadii,
    this.usesRectangularDisplay = false,
    required this.owner,
    required super.child,
  });

  /// Whether the native layout reports an iPad windowed scene whose window
  /// controls require horizontal avoidance.
  final bool hasWindowControlAvoidance;

  final EdgeInsets horizontalAvoidance;
  final EdgeInsets verticalAvoidance;

  /// UIKit's additional horizontal corner-adapted safe-area insets.
  ///
  /// A null value means the current platform cannot report this boundary.
  final EdgeInsets? horizontalSafeAreaAvoidance;

  /// UIKit's additional vertical corner-adapted safe-area insets.
  ///
  /// A null value means the current platform cannot report this boundary.
  final EdgeInsets? verticalSafeAreaAvoidance;

  /// UIKit's effective physical corner radii, when available.
  final BorderRadius? effectiveCornerRadii;

  /// Whether the current display has rectangular physical corners.
  final bool usesRectangularDisplay;

  final WindowControlLayoutOwner owner;

  /// Physical horizontal avoidance owned by page app bars.
  ///
  /// Side navigation owns only its logical leading edge. The opposite physical
  /// edge remains app-bar owned so UIKit geometry is never mirrored by the
  /// application's [Directionality].
  EdgeInsets appBarHorizontalAvoidanceFor(TextDirection direction) {
    if (owner == WindowControlLayoutOwner.appBar) return horizontalAvoidance;
    return switch (direction) {
      TextDirection.ltr => EdgeInsets.only(right: horizontalAvoidance.right),
      TextDirection.rtl => EdgeInsets.only(left: horizontalAvoidance.left),
    };
  }

  /// Horizontal avoidance exposed to the active side-navigation renderer.
  EdgeInsets sideNavigationHorizontalAvoidanceFor(TextDirection direction) {
    if (owner != WindowControlLayoutOwner.sideNavigation) {
      return EdgeInsets.zero;
    }
    return switch (direction) {
      TextDirection.ltr => EdgeInsets.only(left: horizontalAvoidance.left),
      TextDirection.rtl => EdgeInsets.only(right: horizontalAvoidance.right),
    };
  }

  /// Vertical avoidance exposed to the active side-navigation renderer.
  EdgeInsets get sideNavigationVerticalAvoidance =>
      owner == WindowControlLayoutOwner.sideNavigation
      ? verticalAvoidance
      : EdgeInsets.zero;

  static AdaptiveWindowControlLayoutScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<AdaptiveWindowControlLayoutScope>();

  static EdgeInsets appBarAvoidanceOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.appBarHorizontalAvoidance,
      )?.appBarHorizontalAvoidanceFor(Directionality.of(context)) ??
      EdgeInsets.zero;

  /// Returns horizontal avoidance owned by side navigation.
  static EdgeInsets sideNavigationHorizontalAvoidanceOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.sideNavigationHorizontalAvoidance,
      )?.sideNavigationHorizontalAvoidanceFor(Directionality.of(context)) ??
      EdgeInsets.zero;

  /// Returns vertical avoidance owned by side navigation.
  static EdgeInsets sideNavigationVerticalAvoidanceOf(BuildContext context) =>
      InheritedModel.inheritFrom<AdaptiveWindowControlLayoutScope>(
        context,
        aspect: _WindowControlLayoutAspect.sideNavigationVerticalAvoidance,
      )?.sideNavigationVerticalAvoidance ??
      EdgeInsets.zero;

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
      hasWindowControlAvoidance != oldWidget.hasWindowControlAvoidance ||
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
          horizontalAvoidance != oldWidget.horizontalAvoidance ||
              owner != oldWidget.owner,
        _WindowControlLayoutAspect.sideNavigationHorizontalAvoidance =>
          horizontalAvoidance != oldWidget.horizontalAvoidance ||
              owner != oldWidget.owner,
        _WindowControlLayoutAspect.sideNavigationVerticalAvoidance =>
          sideNavigationVerticalAvoidance !=
              oldWidget.sideNavigationVerticalAvoidance,
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
