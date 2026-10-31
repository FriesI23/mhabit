import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/material.dart' show FloatingActionButtonAnimator;
import 'package:flutter/widgets.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';

/// Shares native geometry and the FAB animation policy for one Flutter view.
/// A temporarily missing snapshot retains the known policy. A new view or a
/// confirmed non-vertical/window-control environment restores default motion.
class AdaptiveOcclusionLayout extends StatefulWidget {
  const AdaptiveOcclusionLayout({
    super.key,
    required this.geometry,
    required this.systemSafeArea,
    required this.cornerRadii,
    this.hasWindowControls = false,
    this.allowTopToolbarReclamation = false,
    this.topToolbarAlignmentHeight,
    required this.child,
  });

  final IosOcclusionGeometry? geometry;
  final EdgeInsets systemSafeArea;
  final BorderRadius? cornerRadii;
  final bool hasWindowControls;

  /// Explicitly opts into top-row reclamation on any platform.
  /// The caller owns device policy; consumers still require usable geometry
  /// and a trusted declaration of their layout bounds.
  final bool allowTopToolbarReclamation;
  final double? topToolbarAlignmentHeight;
  final Widget child;

  static FloatingActionButtonAnimator? floatingActionButtonAnimatorOf(
    BuildContext context,
  ) {
    final scope = AdaptiveOcclusionScope.maybeOf(context);
    final suppressAnimation =
        (scope?.suppressFabAnimation ?? false) ||
        (scope?.isCurrent(context) ?? false);
    return suppressAnimation ? FloatingActionButtonAnimator.noAnimation : null;
  }

  @override
  State<AdaptiveOcclusionLayout> createState() =>
      _AdaptiveOcclusionLayoutState();
}

class _AdaptiveOcclusionLayoutState extends State<AdaptiveOcclusionLayout> {
  FlutterView? _view;
  bool _suppressFabAnimation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimationPolicy();
  }

  @override
  void didUpdateWidget(AdaptiveOcclusionLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationPolicy();
  }

  void _updateAnimationPolicy() {
    final currentView = View.of(context);
    if (!identical(currentView, _view)) {
      _view = currentView;
      _suppressFabAnimation = false;
    }
    if (widget.hasWindowControls) {
      _suppressFabAnimation = false;
      return;
    }
    final snapshot = widget.geometry;
    final viewSize = currentView.physicalSize / currentView.devicePixelRatio;
    if (snapshot == null ||
        !OcclusionInsetsResolver.matchesViewSize(
          snapshot.viewBounds,
          viewSize,
        )) {
      return;
    }
    if (!snapshot.hasVerticalSystemBar) {
      _suppressFabAnimation = false;
    } else if (widget.cornerRadii != null) {
      _suppressFabAnimation = true;
    }
  }

  @override
  Widget build(BuildContext context) => AdaptiveOcclusionScope(
    geometry: widget.geometry,
    systemSafeArea: widget.systemSafeArea,
    cornerRadii: widget.cornerRadii,
    hasWindowControls: widget.hasWindowControls,
    allowTopToolbarReclamation: widget.allowTopToolbarReclamation,
    topToolbarAlignmentHeight: widget.topToolbarAlignmentHeight,
    suppressFabAnimation: _suppressFabAnimation,
    child: widget.child,
  );
}

/// Native view geometry shared without changing the body's MediaQuery.
class AdaptiveOcclusionScope extends InheritedWidget {
  const AdaptiveOcclusionScope({
    super.key,
    required this.geometry,
    required this.systemSafeArea,
    required this.cornerRadii,
    this.hasWindowControls = false,
    this.suppressFabAnimation = false,
    this.allowTopToolbarReclamation = false,
    this.topToolbarAlignmentHeight,
    required super.child,
  });

  final IosOcclusionGeometry? geometry;
  final EdgeInsets systemSafeArea;
  final BorderRadius? cornerRadii;
  final bool hasWindowControls;
  final bool suppressFabAnimation;

  /// See [AdaptiveOcclusionLayout.allowTopToolbarReclamation].
  final bool allowTopToolbarReclamation;
  final double? topToolbarAlignmentHeight;

  static AdaptiveOcclusionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveOcclusionScope>();

  /// Ordinary phones and windowed iPads retain their existing safe areas.
  bool isCurrent(BuildContext context) {
    final snapshot = geometry;
    if (snapshot == null ||
        !snapshot.hasVerticalSystemBar ||
        hasWindowControls ||
        cornerRadii == null) {
      return false;
    }
    final view = View.of(context);
    final viewSize = view.physicalSize / view.devicePixelRatio;
    return OcclusionInsetsResolver.matchesViewSize(
      snapshot.viewBounds,
      viewSize,
    );
  }

  /// Resolves a protected horizontal band in native-view coordinates.
  /// Null retains the current conservative layout.
  EdgeInsets? horizontalInsets(
    Rect bounds,
    EdgeInsets currentInsets, {
    EdgeInsets minimumInsets = EdgeInsets.zero,
  }) {
    final snapshot = geometry;
    if (snapshot == null) return null;
    return OcclusionInsetsResolver(
      geometry: snapshot,
      systemSafeArea: systemSafeArea,
      cornerRadii: cornerRadii,
    ).resolve(bounds, currentInsets, minimumInsets);
  }

  @override
  bool updateShouldNotify(AdaptiveOcclusionScope oldWidget) =>
      geometry != oldWidget.geometry ||
      systemSafeArea != oldWidget.systemSafeArea ||
      cornerRadii != oldWidget.cornerRadii ||
      hasWindowControls != oldWidget.hasWindowControls ||
      allowTopToolbarReclamation != oldWidget.allowTopToolbarReclamation ||
      topToolbarAlignmentHeight != oldWidget.topToolbarAlignmentHeight ||
      suppressFabAnimation != oldWidget.suppressFabAnimation;
}

/// Resolves protected horizontal insets from consumer margins, rounded corners
/// and actual occlusions. Unusable regions retain the caller's safe-area fallback.
abstract interface class OcclusionInsetsResolver {
  const factory OcclusionInsetsResolver({
    required IosOcclusionGeometry geometry,
    required EdgeInsets systemSafeArea,
    required BorderRadius? cornerRadii,
  }) = _OcclusionInsetsResolver;

  static bool matchesViewSize(Rect viewBounds, Size viewSize) =>
      (viewSize.width - viewBounds.width).abs() < 0.5 &&
      (viewSize.height - viewBounds.height).abs() < 0.5;

  EdgeInsets? resolve(
    Rect bounds,
    EdgeInsets currentInsets,
    EdgeInsets minimumInsets,
  );
}

final class _OcclusionInsetsResolver implements OcclusionInsetsResolver {
  const _OcclusionInsetsResolver({
    required this.geometry,
    required this.systemSafeArea,
    required this.cornerRadii,
  });

  final IosOcclusionGeometry geometry;
  final EdgeInsets systemSafeArea;
  final BorderRadius? cornerRadii;

  @override
  EdgeInsets? resolve(
    Rect bounds,
    EdgeInsets currentInsets,
    EdgeInsets minimumInsets,
  ) {
    if (bounds.isEmpty || !bounds.isFinite) return null;
    final consumerMargins = _consumerMargins(currentInsets, minimumInsets);
    final cornerClearance = _cornerClearance(bounds);
    final obstructionClearance = _obstructionClearance(bounds);
    final protectedCorners = _maximumInsets(consumerMargins, cornerClearance);
    final protectedBand = _maximumInsets(
      protectedCorners,
      obstructionClearance,
    );
    return protectedBand.horizontal >= bounds.width ? null : protectedBand;
  }

  EdgeInsets _consumerMargins(
    EdgeInsets currentInsets,
    EdgeInsets minimumInsets,
  ) {
    final additionalLeftMargin = math.max(
      0.0,
      currentInsets.left - systemSafeArea.left,
    );
    final additionalRightMargin = math.max(
      0.0,
      currentInsets.right - systemSafeArea.right,
    );
    return EdgeInsets.only(
      left: math.max(minimumInsets.left, additionalLeftMargin),
      right: math.max(minimumInsets.right, additionalRightMargin),
    );
  }

  EdgeInsets _cornerClearance(Rect bounds) {
    final radii = cornerRadii;
    if (radii == null) return EdgeInsets.zero;
    final viewBounds = geometry.viewBounds;
    final distanceFromTop = bounds.top - viewBounds.top;
    final distanceFromBottom = viewBounds.bottom - bounds.bottom;
    final topLeftBoundary =
        viewBounds.left +
        _horizontalCornerInset(radii.topLeft, distanceFromTop);
    final bottomLeftBoundary =
        viewBounds.left +
        _horizontalCornerInset(radii.bottomLeft, distanceFromBottom);
    final topRightClearance =
        bounds.right -
        viewBounds.right +
        _horizontalCornerInset(radii.topRight, distanceFromTop);
    final bottomRightClearance =
        bounds.right -
        viewBounds.right +
        _horizontalCornerInset(radii.bottomRight, distanceFromBottom);
    return EdgeInsets.only(
      left: math.max(topLeftBoundary, bottomLeftBoundary) - bounds.left,
      right: math.max(topRightClearance, bottomRightClearance),
    );
  }

  EdgeInsets _obstructionClearance(Rect bounds) {
    var leftClearance = 0.0;
    var rightClearance = 0.0;
    for (final obstruction in geometry.activeOcclusionRegions) {
      if (!bounds.overlaps(obstruction)) continue;
      final clearanceFromLeft = obstruction.right - bounds.left;
      final clearanceFromRight = bounds.right - obstruction.left;
      if (clearanceFromLeft <= clearanceFromRight) {
        leftClearance = math.max(leftClearance, clearanceFromLeft);
      } else {
        rightClearance = math.max(rightClearance, clearanceFromRight);
      }
    }
    return EdgeInsets.only(left: leftClearance, right: rightClearance);
  }

  EdgeInsets _maximumInsets(
    EdgeInsets retainedInsets,
    EdgeInsets extraClearance,
  ) => EdgeInsets.only(
    left: math.max(retainedInsets.left, extraClearance.left),
    right: math.max(retainedInsets.right, extraClearance.right),
  );

  double _horizontalCornerInset(Radius radius, double verticalDistance) {
    if (radius.x <= 0 || radius.y <= 0 || verticalDistance >= radius.y) {
      return 0;
    }
    final normalizedHeight = ((radius.y - verticalDistance) / radius.y).clamp(
      0.0,
      1.0,
    );
    final ellipseWidthFactor = math.sqrt(
      math.max(0.0, 1 - normalizedHeight * normalizedHeight),
    );
    return radius.x * (1 - ellipseWidthFactor);
  }
}

/// A layout-owned viewport in native-view coordinates, outside route paint
/// transitions. Its contents fill this region; a different nested layout must
/// declare its own bounds or omit them to retain conservative positioning.
/// Nested, translated and modal layouts must shadow an inapplicable declaration;
/// matching sizes alone do not prove that their origins coincide.
class OcclusionViewport extends InheritedWidget {
  const OcclusionViewport({super.key, this.bounds, required super.child});

  /// Omitted or null bounds declare an unknown region and shadow the ancestor.
  final Rect? bounds;

  static OcclusionViewport? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OcclusionViewport>();

  /// Resolves the remaining logical-end pane after a Sidebar consumes space.
  /// Unbounded or oversized panes retain the conservative unknown declaration.
  Rect? trailingPaneBounds(
    BoxConstraints constraints,
    TextDirection direction,
  ) {
    final viewport = bounds;
    return viewport != null &&
            constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            constraints.maxWidth <= viewport.width &&
            constraints.maxHeight <= viewport.height
        ? AlignmentDirectional.topEnd
              .resolve(direction)
              .inscribe(constraints.biggest, viewport)
        : null;
  }

  @override
  bool updateShouldNotify(OcclusionViewport oldWidget) =>
      bounds != oldWidget.bounds;
}
