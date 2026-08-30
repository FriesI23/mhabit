import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Full-width side-navigation sizing configuration.
///
/// The available interval grows from [minimum] to [maximum] as the window
/// moves from [rampStart] to [rampEnd]. The default constructor expresses a
/// fixed logical-pixel target inside that interval. Use [fromRatio] to express
/// a relative position instead, where 0 selects the minimum and 1 the current
/// upper bound.
class SideNavigationExtent {
  /// Creates an extent with a fixed preferred [width].
  const SideNavigationExtent(
    double width, {
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(width >= 0),
       assert(minimum > 0),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = width,
       _ratio = null;

  /// Creates an extent at [ratio] within the available interval.
  const SideNavigationExtent.fromRatio(
    double ratio, {
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(ratio >= 0 && ratio <= 1),
       assert(minimum > 0),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = null,
       _ratio = ratio;

  /// Smallest full-width side-navigation extent.
  final double minimum;

  /// Largest full-width side-navigation extent available to manual resizing.
  final double maximum;

  /// Window width where the available upper bound equals [minimum].
  final double rampStart;

  /// Window width where the available upper bound reaches [maximum].
  final double rampEnd;

  final double? _width;
  final double? _ratio;

  /// Returns the largest side-navigation extent available at [windowWidth].
  double upperBoundAt(double windowWidth) {
    final t = ((windowWidth - rampStart) / (rampEnd - rampStart)).clamp(
      0.0,
      1.0,
    );
    return minimum + (maximum - minimum) * t;
  }

  /// Resolves the automatic side-navigation extent at [windowWidth].
  double resolve(double windowWidth) {
    final upperBound = upperBoundAt(windowWidth);
    final width = _width;
    if (width != null) return width.clamp(minimum, upperBound);
    return minimum + (upperBound - minimum) * _ratio!;
  }

  /// Clamps a manually requested [width] to the interval at [windowWidth].
  double clamp(double width, {required double windowWidth}) =>
      width.clamp(minimum, upperBoundAt(windowWidth));
}

/// Builds the optional visual displayed inside a side-navigation resize target.
typedef SideNavigationDragHandleBuilder =
    Widget Function(BuildContext context, Set<WidgetState> states);

/// Mutable width state shared by side-navigation renderers.
///
/// This type is package-internal. Renderers retain ownership of their widget
/// lifecycle and call these methods from their own `setState` callbacks.
class SideNavigationResizeState {
  double? _manualWidth;
  bool _manualAboveAuto = false;
  double _dragCurrentWidth = 0;
  bool _dragging = false;

  /// Whether a resize drag is active.
  bool get dragging => _dragging;

  /// Resolves the current width without discarding a remembered manual width.
  double effectiveWidth(
    SideNavigationExtent extent, {
    required double windowWidth,
  }) {
    final manualWidth = _manualWidth;
    if (manualWidth == null) return extent.resolve(windowWidth);
    final bound = _manualAboveAuto
        ? extent.upperBoundAt(windowWidth)
        : extent.resolve(windowWidth);
    return math.min(manualWidth, bound);
  }

  /// Starts resizing from the currently effective width.
  void startDrag(SideNavigationExtent extent, {required double windowWidth}) {
    _dragging = true;
    _dragCurrentWidth = effectiveWidth(extent, windowWidth: windowWidth);
  }

  /// Applies a logical horizontal [delta] and remembers the resulting width.
  void updateDrag(
    double delta,
    SideNavigationExtent extent, {
    required double windowWidth,
  }) {
    assert(_dragging);
    _dragCurrentWidth = extent.clamp(
      _dragCurrentWidth + delta,
      windowWidth: windowWidth,
    );
    _manualWidth = _dragCurrentWidth;
    _manualAboveAuto = _dragCurrentWidth > extent.resolve(windowWidth);
  }

  /// Ends or cancels the active drag while preserving its last width.
  void endDrag() => _dragging = false;
}

/// Direction-aware horizontal resize target for side navigation.
class SideNavigationResizeHandle extends StatefulWidget {
  const SideNavigationResizeHandle({
    super.key,
    required this.hitExtent,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    this.dragHandleBuilder,
  }) : assert(hitExtent > 0);

  /// Width of the interactive target around the optional visual.
  final double hitExtent;

  /// Optional visual centered inside the interactive target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  @override
  State<SideNavigationResizeHandle> createState() =>
      _SideNavigationResizeHandleState();
}

class _SideNavigationResizeHandleState
    extends State<SideNavigationResizeHandle> {
  final Set<WidgetState> _states = <WidgetState>{};

  void _setState(WidgetState state, bool value) {
    final changed = value ? _states.add(state) : _states.remove(state);
    if (changed) setState(() {});
  }

  void _handleResizeEnd() {
    _setState(WidgetState.dragged, false);
    widget.onResizeEnd();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final builder = widget.dragHandleBuilder;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => _setState(WidgetState.hovered, true),
      onExit: (_) => _setState(WidgetState.hovered, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _setState(WidgetState.dragged, true);
          widget.onResizeStart();
        },
        onHorizontalDragUpdate: (details) {
          final logicalDelta = direction == TextDirection.ltr
              ? details.delta.dx
              : -details.delta.dx;
          widget.onResizeUpdate(logicalDelta);
        },
        onHorizontalDragEnd: (_) => _handleResizeEnd(),
        onHorizontalDragCancel: _handleResizeEnd,
        child: SizedBox(
          width: widget.hitExtent,
          height: double.infinity,
          child: Center(
            child: builder == null
                ? const SizedBox.shrink()
                : builder(context, Set<WidgetState>.unmodifiable(_states)),
          ),
        ),
      ),
    );
  }
}
