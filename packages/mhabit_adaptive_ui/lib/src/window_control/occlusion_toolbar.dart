import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'occlusion_layout.dart';

/// Projects precise horizontal insets into an explicitly declared toolbar row.
/// Unknown bounds retain the current Safe Area; body geometry is unchanged.
class AdaptiveOcclusionToolbar extends StatefulWidget {
  const AdaptiveOcclusionToolbar({
    super.key,
    this.bounds,
    required this.child,
    this.preserveHorizontalSafeArea = true,
  });

  /// The declared toolbar row in native-view coordinates.
  /// Omitting bounds retains the current conservative Safe Area.
  final Rect? bounds;
  final Widget child;

  /// Floating bottom navigation uses its own protected band instead.
  final bool preserveHorizontalSafeArea;

  static bool isAdaptedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
          ?.adapted ??
      false;

  @override
  State<AdaptiveOcclusionToolbar> createState() =>
      _AdaptiveOcclusionToolbarState();
}

class _AdaptiveOcclusionToolbarState extends State<AdaptiveOcclusionToolbar> {
  late final _routeObserver = _OcclusionRouteObserver(_refresh);
  Object? _environmentView;
  bool _hasVerticalToolbarEnvironment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final view = View.of(context);
    final scope = AdaptiveOcclusionScope.maybeOf(context);
    if (!identical(view, _environmentView) || scope == null) {
      _hasVerticalToolbarEnvironment = false;
    }
    _environmentView = view;
    final geometry = scope?.geometry;
    if (geometry != null) {
      _hasVerticalToolbarEnvironment = geometry.hasVerticalSystemBar;
    }
    _routeObserver.update(
      context,
      enabled:
          widget.bounds != null &&
          !AdaptiveOcclusionToolbar.isAdaptedOf(context) &&
          (scope?.isCurrent(context) ?? false),
    );
  }

  @override
  void didUpdateWidget(AdaptiveOcclusionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.bounds == null) != (oldWidget.bounds == null)) {
      final scope = AdaptiveOcclusionScope.maybeOf(context);
      _routeObserver.update(
        context,
        enabled:
            widget.bounds != null &&
            !AdaptiveOcclusionToolbar.isAdaptedOf(context) &&
            (scope?.isCurrent(context) ?? false),
      );
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _routeObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveOcclusionScope.maybeOf(context);
    final parentAdapted = AdaptiveOcclusionToolbar.isAdaptedOf(context);
    final bounds = _canAdaptToolbar(scope, parentAdapted: parentAdapted)
        ? widget.bounds
        : null;
    final media = MediaQuery.of(context);
    final projectedMedia = scope == null || bounds == null
        ? null
        : _projectHorizontalInsets(scope, bounds, media);
    // An invalid snapshot stops precise reclamation immediately. A toolbar
    // already in a vertical-bar environment must still consume the current
    // system Safe Area, rather than temporarily use ordinary-phone spacing.
    // Remember only this environment signal, never stale geometry or insets.
    final preserveCurrentSafeArea =
        widget.preserveHorizontalSafeArea && _hasVerticalToolbarEnvironment;
    return _ToolbarOcclusionConsumed(
      adapted:
          projectedMedia != null || preserveCurrentSafeArea || parentAdapted,
      child: MediaQuery(data: projectedMedia ?? media, child: widget.child),
    );
  }

  bool _canAdaptToolbar(
    AdaptiveOcclusionScope? scope, {
    required bool parentAdapted,
  }) =>
      scope != null &&
      scope.isCurrent(context) &&
      !parentAdapted &&
      !context.occlusionRoutes.any(
        // Hero preparation temporarily supplies completed animations offstage.
        (route) =>
            route.offstage ||
            !route.isCurrent ||
            (route.animation?.isAnimating ?? false) ||
            (route.secondaryAnimation?.isAnimating ?? false),
      );

  MediaQueryData? _projectHorizontalInsets(
    AdaptiveOcclusionScope scope,
    Rect bounds,
    MediaQueryData media,
  ) {
    final geometry = scope.geometry!;
    final minimumInsets = widget.preserveHorizontalSafeArea
        ? ToolbarSafeAreaCalculator(
            viewBounds: geometry.viewBounds,
            toolbarBounds: bounds,
            systemSafeArea: scope.systemSafeArea,
            controlColumn: geometry.verticalBarLayoutFrame,
          ).calculate()
        : EdgeInsets.zero;
    final padding = scope.horizontalInsets(
      bounds,
      media.padding,
      minimumInsets: minimumInsets,
    );
    final viewPadding = scope.horizontalInsets(
      bounds,
      media.viewPadding,
      minimumInsets: minimumInsets,
    );
    if (padding == null || viewPadding == null) return null;
    return media.copyWith(
      padding: media.padding.copyWith(left: padding.left, right: padding.right),
      viewPadding: media.viewPadding.copyWith(
        left: viewPadding.left,
        right: viewPadding.right,
      ),
    );
  }
}

/// Keeps system clearance unless UIKit explicitly permits a control column.
abstract interface class ToolbarSafeAreaCalculator {
  const factory ToolbarSafeAreaCalculator({
    required Rect viewBounds,
    required Rect toolbarBounds,
    required EdgeInsets systemSafeArea,
    required Rect? controlColumn,
  }) = _ToolbarSafeAreaCalculator;

  EdgeInsets calculate();
}

final class _ToolbarSafeAreaCalculator implements ToolbarSafeAreaCalculator {
  const _ToolbarSafeAreaCalculator({
    required this.viewBounds,
    required this.toolbarBounds,
    required this.systemSafeArea,
    required this.controlColumn,
  });

  final Rect viewBounds;
  final Rect toolbarBounds;
  final EdgeInsets systemSafeArea;
  final Rect? controlColumn;

  @override
  EdgeInsets calculate() {
    final preserved = _remainingSystemSafeArea;
    final column = _usableControlColumn;
    return column == null
        ? preserved
        : _reclaimControlColumnEdge(preserved, column);
  }

  EdgeInsets get _remainingSystemSafeArea => EdgeInsets.only(
    left: (viewBounds.left + systemSafeArea.left - toolbarBounds.left).clamp(
      0.0,
      toolbarBounds.width,
    ),
    right: (toolbarBounds.right - viewBounds.right + systemSafeArea.right)
        .clamp(0.0, toolbarBounds.width),
  );

  Rect? get _usableControlColumn {
    final column = controlColumn;
    // UIKit and Flutter can round the same view-space edge differently when
    // converting physical pixels to points. Ignore only arithmetic noise.
    const tolerance = 0.000001;
    if (column == null ||
        !column.isFinite ||
        column.isEmpty ||
        column.left < viewBounds.left - tolerance ||
        column.right > viewBounds.right + tolerance ||
        column.top < viewBounds.top - tolerance ||
        column.bottom > viewBounds.bottom + tolerance ||
        toolbarBounds.top < column.top - tolerance ||
        toolbarBounds.bottom > column.bottom + tolerance) {
      return null;
    }
    return column;
  }

  EdgeInsets _reclaimControlColumnEdge(EdgeInsets preserved, Rect column) {
    // The column describes where UIKit permits controls, not an occlusion.
    // Reclaim only that physical edge and retain its outer visual clearance.
    // The precise slice still adds real occlusions, corners and extra insets.
    if (column.right <= viewBounds.center.dx) {
      return preserved.copyWith(
        left: math.min(
          preserved.left,
          math.max(0.0, column.left - toolbarBounds.left),
        ),
      );
    }
    if (column.left >= viewBounds.center.dx) {
      return preserved.copyWith(
        right: math.min(
          preserved.right,
          math.max(0.0, toolbarBounds.right - column.right),
        ),
      );
    }
    return preserved;
  }
}

extension _OcclusionContext on BuildContext {
  Iterable<ModalRoute<dynamic>> get occlusionRoutes sync* {
    var route = ModalRoute.of(this);
    final visited = <ModalRoute<dynamic>>{};
    while (route != null && visited.add(route)) {
      yield route;
      // A branch route can remain current while an ancestor navigator's route
      // slides its entire subtree underneath Settings or another app flow.
      final navigator = route.navigator;
      route = navigator == null ? null : ModalRoute.of(navigator.context);
    }
  }
}

/// Rebuilds precise toolbar consumers when route transitions change status.
class _OcclusionRouteObserver {
  _OcclusionRouteObserver(this.onRefresh);

  final VoidCallback onRefresh;
  Set<Animation<double>> _animations = {};
  bool _enabled = false;
  bool _refreshScheduled = false;
  bool _disposed = false;

  void update(BuildContext context, {required bool enabled}) {
    _enabled = enabled;
    final animations = <Animation<double>>{
      if (enabled)
        for (final route in context.occlusionRoutes) ...[
          ?route.animation,
          ?route.secondaryAnimation,
        ],
    };
    for (final animation in _animations.difference(animations)) {
      animation.removeStatusListener(_routeChanged);
    }
    for (final animation in animations.difference(_animations)) {
      animation.addStatusListener(_routeChanged);
    }
    _animations = animations;
  }

  void _routeChanged(AnimationStatus status) => _scheduleRefresh();

  void _scheduleRefresh() {
    if (!_enabled || _refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!_disposed && _enabled) onRefresh();
    });
  }

  void dispose() {
    _disposed = true;
    for (final animation in _animations) {
      animation.removeStatusListener(_routeChanged);
    }
  }
}

class _ToolbarOcclusionConsumed extends InheritedWidget {
  const _ToolbarOcclusionConsumed({
    required this.adapted,
    required super.child,
  });

  final bool adapted;

  @override
  bool updateShouldNotify(_ToolbarOcclusionConsumed oldWidget) =>
      adapted != oldWidget.adapted;
}
