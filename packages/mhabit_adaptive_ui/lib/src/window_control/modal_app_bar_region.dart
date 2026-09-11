import 'package:flutter/material.dart';

import 'window_control_layout.dart';

/// Supplies an internal position-change signal for modal surfaces whose motion
/// is independent of their route animation.
class ModalWindowControlMotion extends InheritedWidget {
  const ModalWindowControlMotion({
    super.key,
    required this.notifier,
    required super.child,
  });

  final Listenable notifier;

  static Listenable? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ModalWindowControlMotion>()
      ?.notifier;

  @override
  bool updateShouldNotify(ModalWindowControlMotion oldWidget) =>
      notifier != oldWidget.notifier;
}

/// Restricts inherited app-bar avoidance to window-control rectangles that
/// overlap this subtree in global coordinates.
class ModalWindowControlAppBarRegion extends StatefulWidget {
  const ModalWindowControlAppBarRegion({super.key, required this.child});

  final Widget child;

  @override
  State<ModalWindowControlAppBarRegion> createState() =>
      _ModalWindowControlAppBarRegionState();
}

class _ModalWindowControlAppBarRegionState
    extends State<ModalWindowControlAppBarRegion> {
  final GlobalKey _regionKey = GlobalKey();
  Animation<double>? _routeAnimation;
  Animation<double>? _secondaryRouteAnimation;
  Listenable? _motion;
  Rect? _globalBounds;
  bool _measurementScheduled = false;

  static EdgeInsets _intersectingHorizontalAvoidance({
    required Rect? bounds,
    required Size windowSize,
    required EdgeInsets horizontal,
    required EdgeInsets vertical,
  }) {
    if (bounds == null || horizontal == EdgeInsets.zero) {
      return EdgeInsets.zero;
    }

    final top = vertical.top;
    final bottom = vertical.bottom;
    final leftIntersects =
        _overlaps(bounds, Rect.fromLTWH(0, 0, horizontal.left, top)) ||
        _overlaps(
          bounds,
          Rect.fromLTWH(0, windowSize.height - bottom, horizontal.left, bottom),
        );
    final rightIntersects =
        _overlaps(
          bounds,
          Rect.fromLTWH(
            windowSize.width - horizontal.right,
            0,
            horizontal.right,
            top,
          ),
        ) ||
        _overlaps(
          bounds,
          Rect.fromLTWH(
            windowSize.width - horizontal.right,
            windowSize.height - bottom,
            horizontal.right,
            bottom,
          ),
        );
    return EdgeInsets.only(
      left: leftIntersects
          ? (horizontal.left - bounds.left).clamp(0, bounds.width)
          : 0,
      right: rightIntersects
          ? (bounds.right - (windowSize.width - horizontal.right)).clamp(
              0,
              bounds.width,
            )
          : 0,
    );
  }

  static bool _overlaps(Rect bounds, Rect avoidance) =>
      !avoidance.isEmpty && bounds.overlaps(avoidance);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextMotion = ModalWindowControlMotion.maybeOf(context);
    if (nextMotion != _motion) {
      _motion?.removeListener(_scheduleMeasurement);
      _motion = nextMotion;
      _motion?.addListener(_scheduleMeasurement);
    }
    final route = ModalRoute.of(context);
    final nextAnimation = route?.animation;
    final nextSecondaryAnimation = route?.secondaryAnimation;
    if (nextAnimation == _routeAnimation &&
        nextSecondaryAnimation == _secondaryRouteAnimation) {
      return;
    }
    _routeAnimation?.removeListener(_scheduleMeasurement);
    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    _secondaryRouteAnimation?.removeListener(_scheduleMeasurement);
    _secondaryRouteAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    _routeAnimation = nextAnimation;
    _secondaryRouteAnimation = nextSecondaryAnimation;
    _routeAnimation?.addListener(_scheduleMeasurement);
    _routeAnimation?.addStatusListener(_handleRouteAnimationStatus);
    _secondaryRouteAnimation?.addListener(_scheduleMeasurement);
    _secondaryRouteAnimation?.addStatusListener(_handleRouteAnimationStatus);
  }

  @override
  void dispose() {
    _motion?.removeListener(_scheduleMeasurement);
    _routeAnimation?.removeListener(_scheduleMeasurement);
    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    _secondaryRouteAnimation?.removeListener(_scheduleMeasurement);
    _secondaryRouteAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    super.dispose();
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }
    _scheduleMeasurement();
  }

  void _scheduleMeasurement() {
    if (_measurementScheduled) return;
    _measurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measurementScheduled = false;
      if (!mounted) return;
      final renderObject = _regionKey.currentContext?.findRenderObject();
      final localBounds = switch (renderObject) {
        final RenderBox box when box.hasSize => Offset.zero & box.size,
        _ => null,
      };
      if (renderObject == null || localBounds == null) return;
      final bounds = MatrixUtils.transformRect(
        renderObject.getTransformTo(null),
        localBounds,
      );
      if (bounds == _globalBounds) return;
      setState(() => _globalBounds = bounds);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasurement();
    final parent = AdaptiveWindowControlLayoutScope.maybeOf(context);
    if (parent == null) {
      return SizedBox(
        key: _regionKey,
        width: double.infinity,
        child: widget.child,
      );
    }
    final horizontal = parent.appBarHorizontalAvoidanceFor(
      Directionality.of(context),
    );
    final effectiveHorizontal = _intersectingHorizontalAvoidance(
      bounds: _globalBounds,
      windowSize: MediaQuery.sizeOf(context),
      horizontal: horizontal,
      vertical: parent.verticalAvoidance,
    );
    return SizedBox(
      key: _regionKey,
      width: double.infinity,
      child: AdaptiveWindowControlLayoutScope(
        hasWindowControlAvoidance: parent.hasWindowControlAvoidance,
        horizontalAvoidance: effectiveHorizontal,
        verticalAvoidance: parent.verticalAvoidance,
        horizontalSafeAreaAvoidance: parent.horizontalSafeAreaAvoidance,
        verticalSafeAreaAvoidance: parent.verticalSafeAreaAvoidance,
        effectiveCornerRadii: parent.effectiveCornerRadii,
        usesRectangularDisplay: parent.usesRectangularDisplay,
        owner: WindowControlLayoutOwner.appBar,
        child: widget.child,
      ),
    );
  }
}
