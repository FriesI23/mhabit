import 'dart:math' as math;

import 'package:flutter/material.dart' show TargetPlatform, Theme;
import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import '../adaptive/adaptive_navigation_destination.dart' as app;
import '../breakpoints/window_size_class.dart';
import '../window_control/window_control_layout.dart';

typedef CupertinoSidebarToolbarMiddleBuilder =
    Widget Function(BuildContext context, Widget middle, double progress);

/// The leading sidebar does not touch the window's opposite physical edge.
/// Keep its local safe area from inheriting that edge's camera/status inset.
class CupertinoSidebarContentSafeArea extends StatelessWidget {
  const CupertinoSidebarContentSafeArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeLeft: direction == TextDirection.rtl,
      removeRight: direction == TextDirection.ltr,
      child: child,
    );
  }
}

/// Returns the route containing [context] followed by every route enclosing
/// its nested Navigator.
List<ModalRoute<dynamic>> _routesAcrossNavigators(BuildContext context) {
  final routes = <ModalRoute<dynamic>>[];
  var route = ModalRoute.of(context);
  final visitedNavigators = <NavigatorState>{};
  while (route != null) {
    routes.add(route);
    final navigator = route.navigator;
    if (navigator == null || !visitedNavigators.add(navigator)) break;
    route = ModalRoute.of(navigator.context);
  }
  return routes;
}

/// Builds a toolbar placeholder for the shell-owned collapsed bar.
class CupertinoSidebarToolbarMiddleLayout extends StatefulWidget {
  const CupertinoSidebarToolbarMiddleLayout({
    super.key,
    required this.builder,
    this.enabled = true,
  });

  final CupertinoSidebarToolbarMiddleBuilder builder;
  final bool enabled;

  @override
  State<CupertinoSidebarToolbarMiddleLayout> createState() =>
      _CupertinoSidebarToolbarMiddleLayoutState();
}

class _CupertinoSidebarToolbarMiddleLayoutState
    extends State<CupertinoSidebarToolbarMiddleLayout> {
  bool? _scheduledVisibility;

  void _scheduleVisibility(
    CupertinoSidebarCollapsedBarController controller,
    bool visible,
  ) {
    if (_scheduledVisibility == visible) return;
    _scheduledVisibility = visible;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scheduledVisibility != visible) return;
      controller.visible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routes = _routesAcrossNavigators(context);
    final animations = <Listenable>[
      for (final route in routes) ...[
        ?route.animation,
        ?route.secondaryAnimation,
      ],
    ];
    // Retained branch routes still participate in visibility, but the bar is
    // now painted by the shell and never follows these page placeholders.
    return AnimatedBuilder(
      animation: Listenable.merge(animations),
      builder: (context, _) => _buildMiddle(context),
    );
  }

  Widget _buildMiddle(BuildContext context) {
    final eligible =
        SidebarLeadingScope.maybeOf(context) != null &&
        WindowSize.of(context).width >= WindowSizeClass.medium &&
        TickerMode.valuesOf(context).enabled &&
        _routesAcrossNavigators(context).every((route) => route.isCurrent);
    final controller = CupertinoSidebarPresentationScope.maybeOf(
      context,
    )?.collapsedBarController;
    if (eligible && controller != null) {
      _scheduleVisibility(controller, widget.enabled);
    }
    if (!eligible) {
      return widget.builder(context, const SizedBox.shrink(), 0.0);
    }

    const middle = CupertinoSidebarMiddle(title: SizedBox.shrink());
    if (controller == null) {
      return widget.builder(
        context,
        widget.enabled ? middle : const SizedBox.shrink(),
        widget.enabled ? 1.0 : 0.0,
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          widget.builder(context, child!, controller.progress),
      child: middle,
    );
  }
}

/// Exposes the Cupertino sidebar presentation to branch content.
class CupertinoSidebarPresentationScope extends InheritedWidget {
  const CupertinoSidebarPresentationScope({
    super.key,
    required this.expanded,
    required this.collapsedBarController,
    required this.toolbarGeometry,
    required super.child,
  });

  final bool expanded;
  final CupertinoSidebarCollapsedBarController collapsedBarController;
  final CupertinoSidebarToolbarGeometry toolbarGeometry;

  static CupertinoSidebarPresentationScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<CupertinoSidebarPresentationScope>();

  /// Resolves the inherited geometry or mhabit's platform default.
  static CupertinoSidebarToolbarGeometry toolbarGeometryOf(
    BuildContext context,
  ) =>
      maybeOf(context)?.toolbarGeometry ??
      (Theme.of(context).platform == TargetPlatform.macOS
          ? CupertinoSidebarToolbarGeometry.compact
          : CupertinoSidebarToolbarGeometry.standard);

  @override
  bool updateShouldNotify(CupertinoSidebarPresentationScope oldWidget) =>
      expanded != oldWidget.expanded ||
      collapsedBarController != oldWidget.collapsedBarController ||
      toolbarGeometry != oldWidget.toolbarGeometry;
}

/// Lays out toolbar regions around a centered collapsed bar.
class CupertinoSidebarToolbarRegions extends StatelessWidget {
  const CupertinoSidebarToolbarRegions({
    super.key,
    required this.start,
    required this.end,
    this.middleSpacing = 6.0,
    this.middleEnabled = true,
  });

  final Widget start;
  final Widget end;
  final double middleSpacing;
  final bool middleEnabled;

  @override
  Widget build(BuildContext context) => CupertinoSidebarToolbarMiddleLayout(
    enabled: middleEnabled,
    builder: (context, middle, visibilityProgress) => CustomMultiChildLayout(
      delegate: _CupertinoSidebarToolbarRegionsDelegate(
        textDirection: Directionality.of(context),
        middleSpacing: middleSpacing,
        middleVisibility: visibilityProgress,
      ),
      children: [
        LayoutId(
          id: _SidebarToolbarRegion.start,
          child: KeyedSubtree(
            key: const ValueKey('cupertino-sidebar-toolbar-start-region'),
            child: start,
          ),
        ),
        LayoutId(
          id: _SidebarToolbarRegion.end,
          child: KeyedSubtree(
            key: const ValueKey('cupertino-sidebar-toolbar-end-region'),
            child: end,
          ),
        ),
        LayoutId(id: _SidebarToolbarRegion.middle, child: middle),
      ],
    ),
  );
}

enum _SidebarToolbarRegion { start, middle, end }

class _CupertinoSidebarToolbarRegionsDelegate extends MultiChildLayoutDelegate {
  _CupertinoSidebarToolbarRegionsDelegate({
    required this.textDirection,
    required this.middleSpacing,
    required this.middleVisibility,
  });

  final TextDirection textDirection;
  final double middleSpacing;
  final double middleVisibility;

  @override
  void performLayout(Size size) {
    final middleSize = layoutChild(
      _SidebarToolbarRegion.middle,
      BoxConstraints.loose(size),
    );
    final middleLeft = (size.width - middleSize.width) / 2;
    final excludedMiddleWidth = middleSize.width * middleVisibility;
    final sideExtent = ((size.width - excludedMiddleWidth) / 2 - middleSpacing)
        .clamp(0.0, size.width);
    final sideConstraints = BoxConstraints.tight(Size(sideExtent, size.height));
    final startSize = layoutChild(_SidebarToolbarRegion.start, sideConstraints);
    final endSize = layoutChild(_SidebarToolbarRegion.end, sideConstraints);
    final startX = textDirection == TextDirection.ltr
        ? 0.0
        : size.width - startSize.width;
    final endX = textDirection == TextDirection.ltr
        ? size.width - endSize.width
        : 0.0;
    positionChild(
      _SidebarToolbarRegion.start,
      Offset(startX, (size.height - startSize.height) / 2),
    );
    positionChild(
      _SidebarToolbarRegion.end,
      Offset(endX, (size.height - endSize.height) / 2),
    );
    positionChild(
      _SidebarToolbarRegion.middle,
      Offset(middleLeft, (size.height - middleSize.height) / 2),
    );
  }

  @override
  bool shouldRelayout(_CupertinoSidebarToolbarRegionsDelegate oldDelegate) =>
      textDirection != oldDelegate.textDirection ||
      middleSpacing != oldDelegate.middleSpacing ||
      middleVisibility != oldDelegate.middleVisibility;
}

/// Lays out a title and actions around a centered collapsed bar.
class CupertinoSidebarToolbarLayout extends StatelessWidget {
  static const double titleStartPadding = 10.0;

  const CupertinoSidebarToolbarLayout({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.middleSpacing = 6.0,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final double middleSpacing;

  @override
  Widget build(BuildContext context) => CupertinoSidebarToolbarRegions(
    middleSpacing: middleSpacing,
    start: Row(
      children: [
        ?leading,
        Flexible(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: titleStartPadding),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
            ),
          ),
        ),
      ],
    ),
    end: ClipRect(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: trailing ?? const SizedBox.shrink(),
      ),
    ),
  );
}

final class SidebarNavigationAdapter {
  SidebarNavigationAdapter({
    required List<app.AdaptiveNavigationDestination> destinations,
    required List<app.AdaptiveNavigationDestination> auxiliaryDestinations,
    required int selectedIndex,
    required int? selectedAuxiliaryIndex,
    required this.onDestinationSelected,
    required this.onAuxiliaryDestinationSelected,
  }) {
    this.destinations = _adaptDestinations(destinations);
    this.auxiliaryDestinations = _adaptDestinations(auxiliaryDestinations);
    selection = selectedAuxiliaryIndex == null
        ? SidebarPrimarySelection(selectedIndex)
        : SidebarAuxiliarySelection(selectedAuxiliaryIndex);
  }

  late final List<AdaptiveNavigationDestination> destinations;
  late final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  late final SidebarDestinationSelection selection;
  final ValueChanged<int> onDestinationSelected;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

  List<AdaptiveNavigationDestination> _adaptDestinations(
    List<app.AdaptiveNavigationDestination> destinations,
  ) => [
    for (final destination in destinations)
      AdaptiveNavigationDestination(
        label: destination.label,
        semanticsLabel: destination.semanticsLabel,
        icons: NavigationDestinationIcons(
          material: destination.icons.material,
          materialSelected: destination.icons.materialSelected,
          cupertino: destination.icons.apple,
          // Files keeps the same Sidebar glyph and changes only its color.
          // Compact Apple navigation still consumes appleSelected directly.
          cupertinoSelected: destination.icons.apple,
        ),
      ),
  ];

  void select(SidebarDestinationSelection selection) {
    switch (selection) {
      case SidebarPrimarySelection(:final index):
        onDestinationSelected(index);
      case SidebarAuxiliarySelection(:final index):
        onAuxiliaryDestinationSelected?.call(index);
    }
  }
}

extension SidebarWindowControlAdapter on BuildContext {
  NavigationObstruction get sidebarNavigationObstruction {
    final horizontal =
        AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
          this,
        );
    final vertical =
        AdaptiveWindowControlLayoutScope.sideNavigationVerticalAvoidanceOf(
          this,
        );
    return NavigationObstruction(
      sidebar: EdgeInsets.fromLTRB(
        horizontal.left,
        vertical.top,
        horizontal.right,
        vertical.bottom,
      ),
      toolbar: horizontal,
    );
  }

  EdgeInsets? sidebarToolbarAvoidance({
    required SidebarLeadingScope? sidebarLeading,
    EdgeInsets? override,
  }) {
    if (override != null) return override;
    if (sidebarLeading == null) return null;

    final appBarAvoidance = AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
      this,
    );
    final sidebarAvoidance = sidebarLeading.toolbarAvoidance;
    return EdgeInsets.fromLTRB(
      math.max(appBarAvoidance.left, sidebarAvoidance.left),
      math.max(appBarAvoidance.top, sidebarAvoidance.top),
      math.max(appBarAvoidance.right, sidebarAvoidance.right),
      math.max(appBarAvoidance.bottom, sidebarAvoidance.bottom),
    );
  }
}
