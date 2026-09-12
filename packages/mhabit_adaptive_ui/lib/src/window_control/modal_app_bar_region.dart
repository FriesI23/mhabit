import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  final ValueNotifier<Rect?> _globalBounds = ValueNotifier(null);
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
    // Dependency changes may move an unchanged child (for example, a keyboard
    // inset or a window resize). Read geometry only after layout has completed.
    _scheduleMeasurement();
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
    _globalBounds.dispose();
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
    if (!mounted || _measurementScheduled) return;
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
      // Publish measured state, never raw motion from a build/layout callback.
      // ValueNotifier suppresses equal bounds without rebuilding the region.
      _globalBounds.value = bounds;
    });
    // addPostFrameCallback does not request a frame when the scheduler is idle.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final parent = AdaptiveWindowControlLayoutScope.maybeOf(context);
    final direction = parent == null
        ? TextDirection.ltr
        : Directionality.of(context);
    final windowSize = parent == null ? Size.zero : MediaQuery.sizeOf(context);
    return _ModalGeometryObserver(
      key: _regionKey,
      onGeometryInvalidated: _scheduleMeasurement,
      child: SizedBox(
        width: double.infinity,
        child: ValueListenableBuilder<Rect?>(
          valueListenable: _globalBounds,
          child: widget.child,
          builder: (context, bounds, child) {
            if (parent == null) return child!;
            final effectiveHorizontal = _intersectingHorizontalAvoidance(
              bounds: bounds,
              windowSize: windowSize,
              horizontal: parent.appBarHorizontalAvoidanceFor(direction),
              vertical: parent.verticalAvoidance,
            );
            return AdaptiveWindowControlLayoutScope(
              hasWindowControlAvoidance: parent.hasWindowControlAvoidance,
              horizontalAvoidance: effectiveHorizontal,
              verticalAvoidance: parent.verticalAvoidance,
              horizontalSafeAreaAvoidance: parent.horizontalSafeAreaAvoidance,
              verticalSafeAreaAvoidance: parent.verticalSafeAreaAvoidance,
              effectiveCornerRadii: parent.effectiveCornerRadii,
              usesRectangularDisplay: parent.usesRectangularDisplay,
              owner: WindowControlLayoutOwner.appBar,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

/// Invalidates geometry on initial layout and subsequent layout/paint, including
/// parent positioning that leaves this widget and its local size unchanged.
/// Route and sheet listeners are still needed for transforms above a retained
/// repaint boundary, where this render object need not lay out or paint again.
class _ModalGeometryObserver extends SingleChildRenderObjectWidget {
  const _ModalGeometryObserver({
    super.key,
    required this.onGeometryInvalidated,
    required super.child,
  });

  final VoidCallback onGeometryInvalidated;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderModalGeometryObserver(onGeometryInvalidated);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderModalGeometryObserver renderObject,
  ) {
    renderObject.onGeometryInvalidated = onGeometryInvalidated;
  }
}

class _RenderModalGeometryObserver extends RenderProxyBox {
  _RenderModalGeometryObserver(this.onGeometryInvalidated);

  VoidCallback onGeometryInvalidated;

  @override
  void performLayout() {
    super.performLayout();
    onGeometryInvalidated();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onGeometryInvalidated();
  }
}
