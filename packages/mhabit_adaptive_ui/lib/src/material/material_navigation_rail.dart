import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../shell/navigation_shell_frame.dart';
import '../window_control/window_control_layout.dart';

/// Extended navigation rail sizing configuration.
///
/// [collapsed] controls the icon-only rail. The extended interval grows from
/// [minimum] to [maximum] as the window moves from [rampStart] to [rampEnd].
/// The default constructor expresses a fixed logical-pixel target inside that
/// interval. Use [fromRatio] to express a relative position instead, where 0
/// selects the minimum and 1 the current upper bound.
///
/// ```text
/// window width  rampStart ------------------------- rampEnd
/// upper bound   minimum        /------------------- maximum
/// actual width  clamp(requested, minimum..upper bound)
/// ```
class NavigationRailExtent {
  /// Creates an extent with a fixed preferred extended [width].
  ///
  /// The preferred width is clamped to the interval available at runtime.
  const NavigationRailExtent(
    double width, {
    this.collapsed = 72.0,
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(width >= 0),
       assert(collapsed > 0),
       assert(minimum > 0),
       assert(minimum >= collapsed),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = width,
       _ratio = null;

  /// Creates an extent at [ratio] within the available extended interval.
  ///
  /// A ratio of zero selects [minimum], while one selects the current upper
  /// bound.
  const NavigationRailExtent.fromRatio(
    double ratio, {
    this.collapsed = 72.0,
    this.minimum = 180.0,
    this.maximum = 360.0,
    this.rampStart = 600.0,
    this.rampEnd = 1600.0,
  }) : assert(ratio >= 0 && ratio <= 1),
       assert(collapsed > 0),
       assert(minimum > 0),
       assert(minimum >= collapsed),
       assert(maximum >= minimum),
       assert(rampEnd > rampStart),
       _width = null,
       _ratio = ratio;

  /// Width of the collapsed icon rail.
  final double collapsed;

  /// Smallest extended rail width.
  final double minimum;

  /// Largest extended rail width available to manual resizing.
  final double maximum;

  /// Window width where the available upper bound equals [minimum].
  final double rampStart;

  /// Window width where the available upper bound reaches [maximum].
  final double rampEnd;

  final double? _width;
  final double? _ratio;

  /// Returns the largest rail width available at [windowWidth].
  double upperBoundAt(double windowWidth) {
    final t = ((windowWidth - rampStart) / (rampEnd - rampStart)).clamp(
      0.0,
      1.0,
    );
    return minimum + (maximum - minimum) * t;
  }

  /// Resolves the automatic rail width at [windowWidth].
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

/// Renders adaptive destinations with a Material [NavigationRail].
class MaterialAdaptiveNavigationRail extends StatelessWidget {
  /// Creates a Material navigation rail for [destinations].
  const MaterialAdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.extended,
    required this.minWidth,
    required this.minExtendedWidth,
    this.leading,
  });

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Top-level destinations rendered by the rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Whether labels and the extended rail layout are displayed.
  final bool extended;

  /// Minimum width of the collapsed rail.
  final double minWidth;

  /// Minimum width of the extended rail.
  final double minExtendedWidth;

  /// Optional widget displayed above the destinations.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      leading: leading,
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: destination.icons.material,
            selectedIcon: destination.icons.materialSelected,
            label: destination.semanticsLabel == null
                ? Text(destination.label)
                : Semantics(
                    label: destination.effectiveSemanticsLabel,
                    excludeSemantics: true,
                    child: Text(destination.label),
                  ),
          ),
      ],
    );
  }
}

/// Material collapsible/resizable rail region.
class MaterialNavigationRailRegion extends StatefulWidget {
  /// Creates a rail region that follows the current shell [form].
  const MaterialNavigationRailRegion({
    super.key,
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
  });

  /// Current compact, constrained-side, or expanded-side shell form.
  final NavigationShellForm form;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by the rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Automatic and manually resizable rail-width policy.
  final NavigationRailExtent railExtent;

  @override
  State<MaterialNavigationRailRegion> createState() =>
      _MaterialNavigationRailRegionState();
}

class _MaterialNavigationRailRegionState
    extends State<MaterialNavigationRailRegion> {
  static const double _minimumRailButtonExtent = 44.0;

  bool _extended = false;
  double? _manualWidth;
  bool _manualAboveAuto = false;
  double _dragCurrentWidth = 0.0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _extended = widget.form == NavigationShellForm.expandedSide;
  }

  @override
  void didUpdateWidget(covariant MaterialNavigationRailRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form == widget.form) return;
    _extended = widget.form == NavigationShellForm.expandedSide;
  }

  double _railAutoWidth(double windowWidth) =>
      widget.railExtent.resolve(windowWidth);

  double _effectiveRailWidth(double windowWidth) {
    final manual = _manualWidth;
    if (manual == null) return _railAutoWidth(windowWidth);
    final bound = _manualAboveAuto
        ? widget.railExtent.upperBoundAt(windowWidth)
        : _railAutoWidth(windowWidth);
    return math.min(manual, bound);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    return AnimatedSize(
      duration: _dragging
          ? const Duration(milliseconds: 1)
          : navigationShellAnimationDuration,
      curve: Curves.easeOut,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.hardEdge,
      child: switch (widget.form) {
        NavigationShellForm.compact => const SizedBox(width: 0),
        NavigationShellForm.constrainedSide ||
        NavigationShellForm.expandedSide => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRail(context, windowWidth),
            const VerticalDivider(width: 1),
          ],
        ),
      },
    );
  }

  Widget _buildRail(BuildContext context, double windowWidth) {
    final width = _extended
        ? _effectiveRailWidth(windowWidth)
        : widget.railExtent.collapsed;
    final horizontalAvoidance =
        AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
          context,
        );
    final verticalAvoidance =
        AdaptiveWindowControlLayoutScope.sideNavigationVerticalAvoidanceOf(
          context,
        );
    final safeWidth =
        width - horizontalAvoidance.start - horizontalAvoidance.end;
    final useVerticalFallback =
        !_extended && safeWidth < _minimumRailButtonExtent;
    final leadingHorizontalAvoidance = useVerticalFallback
        ? EdgeInsetsDirectional.zero
        : horizontalAvoidance;
    final leadingTopAvoidance = useVerticalFallback
        ? verticalAvoidance.top
        : 0.0;

    return Stack(
      children: [
        MaterialAdaptiveNavigationRail(
          key: const ValueKey('rail-panel'),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          extended: _extended,
          minWidth: widget.railExtent.collapsed,
          minExtendedWidth: width,
          leading: SizedBox(
            width: width,
            child: Padding(
              key: const ValueKey('rail-leading-safe-span'),
              padding: EdgeInsetsDirectional.only(
                start: leadingHorizontalAvoidance.start,
                top: leadingTopAvoidance,
                end: leadingHorizontalAvoidance.end,
              ),
              child: Align(
                child: IconButton(
                  key: const ValueKey('rail-toggle-button'),
                  tooltip: _extended
                      ? 'Collapse navigation rail'
                      : 'Expand navigation rail',
                  icon: Icon(_extended ? Icons.menu_open : Icons.menu),
                  onPressed: () => setState(() => _extended = !_extended),
                ),
              ),
            ),
          ),
          destinations: widget.destinations,
        ),
        if (_extended)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildResizeHandle(windowWidth),
          ),
      ],
    );
  }

  Widget _buildResizeHandle(double windowWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: const ValueKey('rail-resize-handle'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          setState(() {
            _dragging = true;
            _dragCurrentWidth = _effectiveRailWidth(windowWidth);
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragCurrentWidth = widget.railExtent.clamp(
              _dragCurrentWidth + details.delta.dx,
              windowWidth: windowWidth,
            );
            _manualWidth = _dragCurrentWidth;
            _manualAboveAuto = _dragCurrentWidth > _railAutoWidth(windowWidth);
          });
        },
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragCancel: () => setState(() => _dragging = false),
        child: const SizedBox(width: 8, height: double.infinity),
      ),
    );
  }
}
