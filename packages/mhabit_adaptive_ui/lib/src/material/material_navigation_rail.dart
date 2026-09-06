import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../shell/navigation_shell_form.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/side_navigation.dart';
import '../window_control/window_control_layout.dart';
import 'material_wide_navigation_rail_button.dart';

/// Material-specific NavigationRail geometry.
class MaterialNavigationRailStyle {
  const MaterialNavigationRailStyle({this.collapsedExtent = 96.0})
    : assert(collapsedExtent > 0);

  /// Width of a collapsed Material 3 wide navigation rail.
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
      selectedIndex: null,
      extended: extended,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      // Host the custom content in leading so it shares NavigationRail's
      // surface and animation. It renders the destinations itself, so the
      // NavigationRail destinations below intentionally stay empty.
      leading: _MaterialWideNavigationRailContent(
        collapsedWidth: minWidth,
        expandedWidth: minExtendedWidth,
        leading: leading,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      destinations: const [],
    );
  }
}

class _MaterialWideNavigationRailContent extends StatelessWidget {
  const _MaterialWideNavigationRailContent({
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.leading,
  });

  static const double _headerSpacing = 40.0;
  static const double _destinationSpacing = 6.0;

  final double collapsedWidth;
  final double expandedWidth;
  final Widget? leading;
  final List<AdaptiveNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final animation = NavigationRail.extendedAnimation(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => SizedBox(
            width: lerpDouble(collapsedWidth, expandedWidth, animation.value)!,
            child: child,
          ),
          child: leading,
        ),
        const SizedBox(height: _headerSpacing),
        for (final (index, destination) in destinations.indexed) ...[
          MaterialWideNavigationRailButton(
            slotKey: ValueKey('material-rail-destination-slot-$index'),
            buttonKey: ValueKey('material-rail-destination-$index'),
            animation: animation,
            collapsedRailWidth: collapsedWidth,
            expandedRailWidth: expandedWidth,
            destination: destination,
            selected: selectedIndex == index,
            onPressed: () => onDestinationSelected(index),
          ),
          if (index != destinations.length - 1)
            const SizedBox(height: _destinationSpacing),
        ],
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
    required this.auxiliaryDestinations,
    required this.selectedAuxiliaryIndex,
    required this.onAuxiliaryDestinationSelected,
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
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  final int? selectedAuxiliaryIndex;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

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
  static const double _collapsedDragOpenThreshold = 16.0;

  bool _extended = false;
  final SideNavigationResizeState _resizeState = SideNavigationResizeState();
  double _dragWidth = 0;
  double _dragOpenWidth = 0;

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
    final resolvedExpandedWidth = _resizeState.effectiveWidth(
      widget.sideNavigationExtent,
      windowWidth: windowWidth,
    );
    final expandedWidth = resolvedExpandedWidth < widget.style.collapsedExtent
        ? widget.style.collapsedExtent
        : resolvedExpandedWidth;
    return AnimatedSize(
      duration: _resizeState.dragging
          ? const Duration(milliseconds: 1)
          : navigationShellAnimationDuration,
      curve: Curves.easeOut,
      alignment: AlignmentDirectional.centerStart,
      clipBehavior: Clip.hardEdge,
      child: switch (widget.form) {
        NavigationShellForm.compact => const SizedBox(width: 0),
        NavigationShellForm.constrainedSide ||
        NavigationShellForm.expandedSide => _MaterialNavigationRailPanel(
          selectedIndex: widget.selectedIndex,
          destinations: widget.destinations,
          onDestinationSelected: widget.onDestinationSelected,
          auxiliaryDestinations: widget.auxiliaryDestinations,
          selectedAuxiliaryIndex: widget.selectedAuxiliaryIndex,
          onAuxiliaryDestinationSelected: widget.onAuxiliaryDestinationSelected,
          extended: _extended,
          collapsedWidth: widget.style.collapsedExtent,
          expandedWidth: expandedWidth,
          dragHandleBuilder: widget.dragHandleBuilder,
          expandNavigationLabel: widget.expandNavigationLabel,
          collapseNavigationLabel: widget.collapseNavigationLabel,
          onToggle: _toggleExtended,
          onResizeStart: () => _handleResizeStart(windowWidth),
          onResizeUpdate: (delta) => _handleResizeUpdate(delta, windowWidth),
          onResizeEnd: _handleResizeEnd,
        ),
      },
    );
  }

  void _toggleExtended() => setState(() => _extended = !_extended);

  void _handleResizeStart(double windowWidth) {
    setState(() {
      final effectiveWidth = _resizeState.effectiveWidth(
        widget.sideNavigationExtent,
        windowWidth: windowWidth,
      );
      _dragWidth = _extended ? effectiveWidth : widget.style.collapsedExtent;
      _dragOpenWidth = _extended
          ? widget.sideNavigationExtent.minimum
          : widget.style.collapsedExtent + _collapsedDragOpenThreshold;
      _resizeState.startDrag(
        widget.sideNavigationExtent,
        windowWidth: windowWidth,
      );
    });
  }

  void _handleResizeUpdate(double delta, double windowWidth) {
    setState(() {
      _dragWidth += delta;
      if (_dragWidth < widget.style.collapsedExtent) {
        _dragWidth = widget.style.collapsedExtent;
      }

      if (_extended) {
        _resizeState.updateDrag(
          delta,
          widget.sideNavigationExtent,
          windowWidth: windowWidth,
        );
        if (_dragWidth >= widget.sideNavigationExtent.minimum) return;
        _extended = false;
        _dragOpenWidth = widget.sideNavigationExtent.minimum;
        return;
      }

      if (_dragWidth < _dragOpenWidth) return;
      final effectiveWidth = _resizeState.effectiveWidth(
        widget.sideNavigationExtent,
        windowWidth: windowWidth,
      );
      _resizeState.updateDrag(
        widget.sideNavigationExtent.minimum - effectiveWidth,
        widget.sideNavigationExtent,
        windowWidth: windowWidth,
      );
      _dragWidth = widget.sideNavigationExtent.minimum;
      _extended = true;
    });
  }

  void _handleResizeEnd() => setState(_resizeState.endDrag);
}

class _MaterialNavigationRailPanel extends StatelessWidget {
  const _MaterialNavigationRailPanel({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.auxiliaryDestinations,
    required this.selectedAuxiliaryIndex,
    required this.onAuxiliaryDestinationSelected,
    required this.extended,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.expandNavigationLabel,
    required this.collapseNavigationLabel,
    required this.onToggle,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    this.dragHandleBuilder,
  });

  static const double _minimumRailButtonExtent = 44.0;
  static const double _auxiliaryDestinationSpacing = 6.0;

  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  final int? selectedAuxiliaryIndex;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;
  final bool extended;
  final double collapsedWidth;
  final double expandedWidth;
  final SideNavigationDragHandleBuilder? dragHandleBuilder;
  final String expandNavigationLabel;
  final String collapseNavigationLabel;
  final VoidCallback onToggle;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context) {
    final width = extended ? expandedWidth : collapsedWidth;
    final horizontalAvoidance =
        AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
          context,
        );
    final verticalAvoidance =
        AdaptiveWindowControlLayoutScope.sideNavigationVerticalAvoidanceOf(
          context,
        );
    final toggleAnchorWidth = width < collapsedWidth ? width : collapsedWidth;
    final safeWidth =
        toggleAnchorWidth -
        horizontalAvoidance.left -
        horizontalAvoidance.right;
    final useVerticalFallback = safeWidth < _minimumRailButtonExtent;
    final leadingHorizontalAvoidance = useVerticalFallback
        ? EdgeInsets.zero
        : horizontalAvoidance;
    final leadingTopAvoidance = useVerticalFallback
        ? verticalAvoidance.top
        : 0.0;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final primaryDestinationRail = MaterialAdaptiveNavigationRail(
      key: const ValueKey('rail-panel'),
      selectedIndex: selectedAuxiliaryIndex == null ? selectedIndex : -1,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      minWidth: collapsedWidth,
      minExtendedWidth: expandedWidth,
      leading: Padding(
        padding: EdgeInsets.only(
          left: leadingHorizontalAvoidance.left,
          top: leadingTopAvoidance,
          right: leadingHorizontalAvoidance.right,
        ),
        child: const Align(
          child: SizedBox.square(dimension: kMinInteractiveDimension),
        ),
      ),
      destinations: destinations,
    );

    final auxiliaryDestinationList = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, destination) in auxiliaryDestinations.indexed) ...[
          MaterialWideNavigationRailButton(
            slotKey: ValueKey(
              'material-rail-auxiliary-destination-slot-$index',
            ),
            buttonKey: ValueKey('material-rail-auxiliary-destination-$index'),
            animation: AlwaysStoppedAnimation(extended ? 1 : 0),
            collapsedRailWidth: collapsedWidth,
            expandedRailWidth: expandedWidth,
            destination: destination,
            selected: selectedAuxiliaryIndex == index,
            onPressed: () => onAuxiliaryDestinationSelected?.call(index),
          ),
          if (index != auxiliaryDestinations.length - 1)
            const SizedBox(height: _auxiliaryDestinationSpacing),
        ],
      ],
    );
    final auxiliaryDestinationLayer = auxiliaryDestinations.isEmpty
        ? null
        : Positioned.fill(
            child: SafeArea(
              left: !isRtl,
              right: isRtl,
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: auxiliaryDestinationList,
                ),
              ),
            ),
          );

    final navigationToggleLayer = Positioned.fill(
      child: SafeArea(
        left: !isRtl,
        right: isRtl,
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: toggleAnchorWidth,
            child: Padding(
              key: const ValueKey('rail-leading-safe-span'),
              padding: EdgeInsets.only(
                left: leadingHorizontalAvoidance.left,
                top: leadingTopAvoidance,
                right: leadingHorizontalAvoidance.right,
              ),
              child: Align(
                heightFactor: 1,
                child: IconButton(
                  key: const ValueKey('rail-toggle-button'),
                  tooltip: extended
                      ? collapseNavigationLabel
                      : expandNavigationLabel,
                  icon: Icon(extended ? Icons.menu_open : Icons.menu),
                  onPressed: onToggle,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final navigationResizeHandle = PositionedDirectional(
      end: 0,
      top: 0,
      bottom: 0,
      child: _MaterialNavigationRailResizeHandle(
        extended: extended,
        dragHandleBuilder: dragHandleBuilder,
        onResizeStart: onResizeStart,
        onResizeUpdate: onResizeUpdate,
        onResizeEnd: onResizeEnd,
      ),
    );

    return Stack(
      children: [
        primaryDestinationRail,
        ?auxiliaryDestinationLayer,
        navigationToggleLayer,
        navigationResizeHandle,
      ],
    );
  }
}

class _MaterialNavigationRailResizeHandle extends StatelessWidget {
  const _MaterialNavigationRailResizeHandle({
    required this.extended,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    this.dragHandleBuilder,
  });

  final bool extended;
  final SideNavigationDragHandleBuilder? dragHandleBuilder;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context) {
    return SideNavigationResizeHandle(
      key: const ValueKey('rail-resize-gesture-handle'),
      hitExtent: 16,
      dragHandleBuilder: (context, states) => _MaterialNavigationRailDragHandle(
        extended: extended,
        states: states,
        builder: dragHandleBuilder,
      ),
      onResizeStart: onResizeStart,
      onResizeUpdate: onResizeUpdate,
      onResizeEnd: onResizeEnd,
    );
  }
}

class _MaterialNavigationRailDragHandle extends StatelessWidget {
  const _MaterialNavigationRailDragHandle({
    required this.extended,
    required this.states,
    this.builder,
  });

  final bool extended;
  final Set<WidgetState> states;
  final SideNavigationDragHandleBuilder? builder;

  @override
  Widget build(BuildContext context) {
    if (!extended) {
      return const SizedBox(
        key: ValueKey('rail-collapsed-resize-handle'),
        width: 16,
        height: 48,
      );
    }
    return KeyedSubtree(
      key: const ValueKey('rail-resize-handle'),
      child:
          builder?.call(context, states) ??
          SizedBox(
            key: const ValueKey('material-side-navigation-drag-bar'),
            width: 4,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
    );
  }
}
