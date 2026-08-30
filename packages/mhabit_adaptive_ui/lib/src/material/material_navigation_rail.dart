import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/side_navigation.dart';
import '../window_control/window_control_layout.dart';

/// Material-specific NavigationRail geometry.
class MaterialNavigationRailStyle {
  const MaterialNavigationRailStyle({this.collapsedExtent = 72.0})
    : assert(collapsedExtent > 0);

  /// Width of the collapsed icon-only rail.
  final double collapsedExtent;
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
    required this.sideNavigationExtent,
    required this.style,
    required this.dragHandleBuilder,
    required this.expandNavigationLabel,
    required this.collapseNavigationLabel,
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
  final SideNavigationExtent sideNavigationExtent;

  /// Material-specific rail geometry.
  final MaterialNavigationRailStyle style;

  /// Visual displayed in the rail's resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Localized action label used while the rail is collapsed.
  final String expandNavigationLabel;

  /// Localized action label used while the rail is expanded.
  final String collapseNavigationLabel;

  @override
  State<MaterialNavigationRailRegion> createState() =>
      _MaterialNavigationRailRegionState();
}

class _MaterialNavigationRailRegionState
    extends State<MaterialNavigationRailRegion> {
  static const double _minimumRailButtonExtent = 44.0;

  bool _extended = false;
  final SideNavigationResizeState _resizeState = SideNavigationResizeState();

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

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    return AnimatedSize(
      duration: _resizeState.dragging
          ? const Duration(milliseconds: 1)
          : navigationShellAnimationDuration,
      curve: Curves.easeOut,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.hardEdge,
      child: switch (widget.form) {
        NavigationShellForm.compact => const SizedBox(width: 0),
        NavigationShellForm.constrainedSide ||
        NavigationShellForm.expandedSide => _buildRail(context, windowWidth),
      },
    );
  }

  Widget _buildRail(BuildContext context, double windowWidth) {
    final width = _extended
        ? _resizeState.effectiveWidth(
            widget.sideNavigationExtent,
            windowWidth: windowWidth,
          )
        : widget.style.collapsedExtent;
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
          minWidth: widget.style.collapsedExtent,
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
                      ? widget.collapseNavigationLabel
                      : widget.expandNavigationLabel,
                  icon: Icon(_extended ? Icons.menu_open : Icons.menu),
                  onPressed: () => setState(() => _extended = !_extended),
                ),
              ),
            ),
          ),
          destinations: widget.destinations,
        ),
        if (_extended)
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: _buildResizeHandle(windowWidth),
          ),
      ],
    );
  }

  Widget _buildResizeHandle(double windowWidth) {
    return SideNavigationResizeHandle(
      key: const ValueKey('rail-resize-handle'),
      hitExtent: 8,
      dragHandleBuilder: widget.dragHandleBuilder ?? _materialDragHandle,
      onResizeStart: () => setState(
        () => _resizeState.startDrag(
          widget.sideNavigationExtent,
          windowWidth: windowWidth,
        ),
      ),
      onResizeUpdate: (delta) => setState(
        () => _resizeState.updateDrag(
          delta,
          widget.sideNavigationExtent,
          windowWidth: windowWidth,
        ),
      ),
      onResizeEnd: () => setState(_resizeState.endDrag),
    );
  }
}

Widget _materialDragHandle(BuildContext context, Set<WidgetState> _) {
  return SizedBox(
    key: const ValueKey('material-side-navigation-drag-bar'),
    width: 4,
    height: 32,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
    ),
  );
}
