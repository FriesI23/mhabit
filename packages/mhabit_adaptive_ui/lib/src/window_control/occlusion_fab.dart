import 'package:flutter/material.dart';

import 'occlusion_layout.dart';

/// Places a floating action in its layout owner's declared viewport.
/// Only floating insets are adjusted.
class AdaptiveOcclusionFabLocation extends FloatingActionButtonLocation {
  AdaptiveOcclusionFabLocation._({
    required this.context,
    this.fallbackLocation = FloatingActionButtonLocation.endFloat,
    this.minimumInsets = EdgeInsets.zero,
    this.adaptedLocation,
    this.alignToSystemBar = false,
    this.systemBarMinimumInsets = EdgeInsets.zero,
  }) : _scope = AdaptiveOcclusionScope.maybeOf(context),
       _viewportBounds = OcclusionViewport.maybeOf(context)?.bounds;

  final BuildContext context;
  final FloatingActionButtonLocation fallbackLocation;
  final EdgeInsets minimumInsets;
  final FloatingActionButtonLocation? adaptedLocation;

  /// Aligns a matching physical trailing edge to UIKit's bar layout column.
  /// Missing native geometry keeps the existing floating placement.
  final bool alignToSystemBar;

  /// Corner, gesture and visual protection for the optional aligned position.
  /// The ordinary floating position continues to use [minimumInsets].
  final EdgeInsets systemBarMinimumInsets;
  final AdaptiveOcclusionScope? _scope;
  final Rect? _viewportBounds;

  /// Resolves placement from the enclosing window and declared viewport.
  /// Retains [fallbackLocation] when native geometry is unavailable.
  static FloatingActionButtonLocation resolveOf(
    BuildContext context, {
    FloatingActionButtonLocation fallbackLocation =
        FloatingActionButtonLocation.endFloat,
    FloatingActionButtonLocation? adaptedLocation,
    EdgeInsets minimumInsets = EdgeInsets.zero,
    bool alignToSystemBar = false,
    EdgeInsets systemBarMinimumInsets = EdgeInsets.zero,
  }) {
    final scope = AdaptiveOcclusionScope.maybeOf(context);
    if (scope == null || !scope.isCurrent(context)) return fallbackLocation;
    return AdaptiveOcclusionFabLocation._(
      context: context,
      fallbackLocation: fallbackLocation,
      adaptedLocation: adaptedLocation,
      minimumInsets: minimumInsets,
      alignToSystemBar: alignToSystemBar,
      systemBarMinimumInsets: systemBarMinimumInsets,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdaptiveOcclusionFabLocation &&
      identical(context, other.context) &&
      fallbackLocation == other.fallbackLocation &&
      adaptedLocation == other.adaptedLocation &&
      minimumInsets == other.minimumInsets &&
      alignToSystemBar == other.alignToSystemBar &&
      systemBarMinimumInsets == other.systemBarMinimumInsets &&
      _viewportBounds == other._viewportBounds &&
      _scope?.geometry == other._scope?.geometry &&
      _scope?.systemSafeArea == other._scope?.systemSafeArea &&
      _scope?.cornerRadii == other._scope?.cornerRadii;

  @override
  int get hashCode => Object.hash(
    context,
    fallbackLocation,
    adaptedLocation,
    minimumInsets,
    alignToSystemBar,
    systemBarMinimumInsets,
    _viewportBounds,
    _scope?.geometry,
    _scope?.systemSafeArea,
    _scope?.cornerRadii,
  );

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fallbackOffset = fallbackLocation.getOffset(scaffoldGeometry);
    final scope = _scope;
    final viewportBounds = _viewportBounds;
    if (scope == null || !scope.isCurrent(context) || viewportBounds == null) {
      return fallbackOffset;
    }
    return OcclusionFabCalculator(
      scope: scope,
      viewportBounds: viewportBounds,
      scaffoldGeometry: scaffoldGeometry,
      floatingLocation: adaptedLocation ?? fallbackLocation,
      minimumInsets: minimumInsets,
      alignToSystemBar: alignToSystemBar,
      systemBarMinimumInsets: systemBarMinimumInsets,
    ).calculate(fallbackOffset);
  }
}

/// Calculates placement inside the owner's declared viewport without measuring
/// route paint offsets. Inputs belong to this layout pass; nothing is cached.
abstract interface class OcclusionFabCalculator {
  const factory OcclusionFabCalculator({
    required AdaptiveOcclusionScope scope,
    required Rect viewportBounds,
    required ScaffoldPrelayoutGeometry scaffoldGeometry,
    required FloatingActionButtonLocation floatingLocation,
    required EdgeInsets minimumInsets,
    required bool alignToSystemBar,
    required EdgeInsets systemBarMinimumInsets,
  }) = _OcclusionFabCalculator;

  Offset calculate(Offset fallbackOffset);
}

final class _OcclusionFabCalculator implements OcclusionFabCalculator {
  const _OcclusionFabCalculator({
    required this.scope,
    required this.viewportBounds,
    required this.scaffoldGeometry,
    required this.floatingLocation,
    required this.minimumInsets,
    required this.alignToSystemBar,
    required this.systemBarMinimumInsets,
  });

  final AdaptiveOcclusionScope scope;
  final Rect viewportBounds;
  final ScaffoldPrelayoutGeometry scaffoldGeometry;
  final FloatingActionButtonLocation floatingLocation;
  final EdgeInsets minimumInsets;
  final bool alignToSystemBar;
  final EdgeInsets systemBarMinimumInsets;

  @override
  Offset calculate(Offset fallbackOffset) {
    // Root and pane declarations are independent of route paint transitions.
    // Unknown or mismatched regions keep the owner's conservative placement.
    if (!_matchesScaffold) return fallbackOffset;
    for (final verticalOffset in _candidateVerticalOffsets(fallbackOffset.dy)) {
      if (verticalOffset < scaffoldGeometry.contentTop) continue;
      final protectedOffset = _offsetInBand(verticalOffset);
      if (protectedOffset != null) return protectedOffset;
    }
    return fallbackOffset;
  }

  bool get _matchesScaffold {
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    return viewportBounds.isFinite &&
        !viewportBounds.isEmpty &&
        (viewportBounds.width - scaffoldSize.width).abs() <= 0.5 &&
        (viewportBounds.height - scaffoldSize.height).abs() <= 0.5;
  }

  List<double> _candidateVerticalOffsets(double fallbackY) {
    final fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final verticalOffsets = <double>{fallbackY};
    for (final region in scope.geometry!.activeOcclusionRegions) {
      final aboveObstruction = region.top - viewportBounds.top - fabHeight;
      if (aboveObstruction < fallbackY) verticalOffsets.add(aboveObstruction);
    }
    return verticalOffsets.toList()..sort((a, b) => b.compareTo(a));
  }

  Offset? _offsetInBand(double verticalOffset) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final candidateBand = Rect.fromLTWH(
      viewportBounds.left,
      viewportBounds.top + verticalOffset,
      viewportBounds.width,
      fabSize.height,
    );
    final horizontalInsets = scope.horizontalInsets(
      candidateBand,
      scaffoldGeometry.minInsets,
      minimumInsets: minimumInsets,
    );
    if (horizontalInsets == null ||
        horizontalInsets.horizontal + fabSize.width > viewportBounds.width) {
      return null;
    }
    final adjustedGeometry = _withHorizontalInsets(horizontalInsets);
    final standardOffset = floatingLocation.getOffset(adjustedGeometry);
    final alignedOffset = alignToSystemBar
        ? _systemBarAlignedOffset(candidateBand, standardOffset)
        : null;
    final protectedOffset = Offset(
      alignedOffset?.dx ?? standardOffset.dx,
      verticalOffset,
    );
    final fabBounds = (viewportBounds.topLeft + protectedOffset) & fabSize;
    // An aligned candidate has already passed its own protected slice. Its
    // visual edge margin can be smaller than the ordinary floating margin.
    if ((alignedOffset == null &&
            (fabBounds.left < candidateBand.left + horizontalInsets.left ||
                fabBounds.right >
                    candidateBand.right - horizontalInsets.right)) ||
        scope.geometry!.activeOcclusionRegions.any(fabBounds.overlaps)) {
      return null;
    }
    return protectedOffset;
  }

  ScaffoldPrelayoutGeometry _withHorizontalInsets(
    EdgeInsets horizontalInsets,
  ) => ScaffoldPrelayoutGeometry(
    bottomSheetSize: scaffoldGeometry.bottomSheetSize,
    contentBottom: scaffoldGeometry.contentBottom,
    contentTop: scaffoldGeometry.contentTop,
    floatingActionButtonSize: scaffoldGeometry.floatingActionButtonSize,
    minInsets: scaffoldGeometry.minInsets.copyWith(
      left: horizontalInsets.left,
      right: horizontalInsets.right,
    ),
    minViewPadding: scaffoldGeometry.minViewPadding.copyWith(
      left: horizontalInsets.left,
      right: horizontalInsets.right,
    ),
    scaffoldSize: scaffoldGeometry.scaffoldSize,
    snackBarSize: scaffoldGeometry.snackBarSize,
    materialBannerSize: scaffoldGeometry.materialBannerSize,
    textDirection: scaffoldGeometry.textDirection,
  );

  Offset? _systemBarAlignedOffset(Rect candidateBand, Offset standardOffset) {
    final systemBarBounds = _matchingTrailingSystemBar;
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    if (systemBarBounds == null || fabSize.isEmpty || !fabSize.isFinite) {
      return null;
    }
    final trailingEdgeIsRight =
        scaffoldGeometry.textDirection == TextDirection.ltr;
    final alignedX =
        systemBarBounds.center.dx - viewportBounds.left - fabSize.width / 2;
    // Moving inward could consume the navigation surface's existing reserved
    // action space. Keep that placement until a shared reservation permits it.
    if (trailingEdgeIsRight
        ? alignedX < standardOffset.dx
        : alignedX > standardOffset.dx) {
      return null;
    }
    final horizontalInsets = scope.horizontalInsets(
      candidateBand,
      scaffoldGeometry.minInsets,
      minimumInsets: systemBarMinimumInsets,
    );
    if (horizontalInsets == null ||
        alignedX < horizontalInsets.left ||
        alignedX + fabSize.width >
            viewportBounds.width - horizontalInsets.right) {
      return null;
    }
    final fabBounds =
        Offset(viewportBounds.left + alignedX, candidateBand.top) & fabSize;
    if (scope.geometry!.activeOcclusionRegions.any(fabBounds.overlaps)) {
      return null;
    }
    return Offset(alignedX, standardOffset.dy);
  }

  Rect? get _matchingTrailingSystemBar {
    final snapshot = scope.geometry!;
    final systemBarBounds = snapshot.verticalBarLayoutFrame;
    if (systemBarBounds == null ||
        !systemBarBounds.isFinite ||
        systemBarBounds.isEmpty ||
        !systemBarBounds.overlaps(snapshot.viewBounds)) {
      return null;
    }
    final trailingEdgeIsRight =
        scaffoldGeometry.textDirection == TextDirection.ltr;
    final systemBarIsOnRight =
        systemBarBounds.center.dx > snapshot.viewBounds.center.dx;
    return systemBarBounds.center.dx != snapshot.viewBounds.center.dx &&
            trailingEdgeIsRight == systemBarIsOnRight
        ? systemBarBounds
        : null;
  }
}
