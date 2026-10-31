import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'occlusion_layout.dart';

/// Aligned toolbar geometry and the protected extent before bottom content.
typedef TopToolbarLayout = ({
  double topInset,
  double minimumExtent,
  Rect bounds,
});

/// Projects precise horizontal insets into an explicitly declared toolbar row.
/// Unknown bounds retain the current Safe Area; body geometry is unchanged.
/// Route paint transitions do not change this layout projection.
class AdaptiveOcclusionToolbar extends StatefulWidget {
  const AdaptiveOcclusionToolbar({
    super.key,
    this.bounds,
    required this.child,
    this.preserveHorizontalSafeArea = true,
    this.reclaimTopSafeArea = false,
    this.minimumTopInset = 0,
  });

  /// The declared layout row in native-view coordinates before route painting.
  /// Omitting bounds retains the current conservative Safe Area.
  final Rect? bounds;
  final Widget child;

  /// Floating bottom navigation uses its own protected band instead.
  final bool preserveHorizontalSafeArea;

  /// Only a pinned top-row owner can release the status area's vertical inset.
  final bool reclaimTopSafeArea;
  final double minimumTopInset;

  static bool isAdaptedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
          ?.adapted ??
      false;

  static bool isTopReclaimedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
          ?.topReclaimed ??
      false;

  /// Protected extent before an app bar's additional bottom content.
  static double? minimumExtentOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
      ?.minimumExtent;

  @override
  State<AdaptiveOcclusionToolbar> createState() =>
      _AdaptiveOcclusionToolbarState();
}

class _AdaptiveOcclusionToolbarState extends State<AdaptiveOcclusionToolbar> {
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
  }

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveOcclusionScope.maybeOf(context);
    final parentAdapted = AdaptiveOcclusionToolbar.isAdaptedOf(context);
    final media = MediaQuery.of(context);
    final canAdapt = _canAdaptToolbar(scope, parentAdapted: parentAdapted);
    final topLayout = canAdapt && widget.reclaimTopSafeArea
        ? _resolveTopLayout(scope!, media)
        : null;
    final bounds = canAdapt
        ? topLayout?.bounds ??
              ((scope?.isCurrent(context) ?? false) ? widget.bounds : null)
        : null;
    final horizontalMedia = scope == null || bounds == null
        ? null
        : _projectHorizontalInsets(scope, bounds, media);
    final projectedMedia = topLayout == null || horizontalMedia == null
        ? horizontalMedia
        : horizontalMedia.copyWith(
            padding: horizontalMedia.padding.copyWith(top: topLayout.topInset),
            viewPadding: horizontalMedia.viewPadding.copyWith(
              top: math.max(
                0,
                media.viewPadding.top -
                    (media.padding.top - topLayout.topInset),
              ),
            ),
          );
    // An invalid snapshot stops precise reclamation immediately. A toolbar
    // already in a vertical-bar environment must still consume the current
    // system Safe Area, rather than temporarily use ordinary-phone spacing.
    // Remember only this environment signal, never stale geometry or insets.
    final preserveCurrentSafeArea =
        widget.preserveHorizontalSafeArea && _hasVerticalToolbarEnvironment;
    return _ToolbarOcclusionConsumed(
      adapted:
          projectedMedia != null || preserveCurrentSafeArea || parentAdapted,
      topReclaimed:
          (topLayout != null && projectedMedia != null) ||
          AdaptiveOcclusionToolbar.isTopReclaimedOf(context),
      minimumExtent: topLayout != null && projectedMedia != null
          ? topLayout.minimumExtent
          : AdaptiveOcclusionToolbar.minimumExtentOf(context),
      child: MediaQuery(data: projectedMedia ?? media, child: widget.child),
    );
  }

  bool _canAdaptToolbar(
    AdaptiveOcclusionScope? scope, {
    required bool parentAdapted,
  }) {
    bool hasToolbarEnvironment() =>
        (scope?.isCurrent(context) ?? false) ||
        (widget.reclaimTopSafeArea &&
            (scope?.allowTopToolbarReclamation ?? false));

    return scope != null && hasToolbarEnvironment() && !parentAdapted;
  }

  TopToolbarLayout? _resolveTopLayout(
    AdaptiveOcclusionScope scope,
    MediaQueryData media,
  ) {
    final geometry = scope.geometry;
    final row = widget.bounds;
    final pane = OcclusionViewport.maybeOf(context)?.bounds;
    if (!scope.allowTopToolbarReclamation ||
        geometry == null ||
        geometry.hasVerticalSystemBar ||
        scope.hasWindowControls ||
        scope.cornerRadii == null ||
        media.viewInsets.top != 0 ||
        row == null ||
        pane == null) {
      return null;
    }
    final view = View.of(context);
    return TopToolbarLayoutResolver(
      viewBounds: geometry.viewBounds,
      viewSize: view.physicalSize / view.devicePixelRatio,
      occlusions: geometry.activeOcclusionRegions,
      pane: pane,
      row: row,
      systemTopInset: scope.systemSafeArea.top,
      currentTopInset: media.padding.top,
      currentViewTopInset: media.viewPadding.top,
      minimumTopInset: widget.minimumTopInset,
      alignmentHeight: scope.topToolbarAlignmentHeight,
    ).resolve();
  }

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

/// Resolves one layout pass from supplied geometry without reading widgets.
abstract interface class TopToolbarLayoutResolver {
  const factory TopToolbarLayoutResolver({
    required Rect viewBounds,
    required Size viewSize,
    required List<Rect> occlusions,
    required Rect pane,
    required Rect row,
    required double systemTopInset,
    required double currentTopInset,
    required double currentViewTopInset,
    required double minimumTopInset,
    required double? alignmentHeight,
  }) = _TopToolbarLayoutResolver;

  /// Returns the local top inset, protected extent before bottom content, and
  /// final row bounds in native-view layout coordinates.
  /// Returns null when the declared row cannot reclaim the top status band.
  TopToolbarLayout? resolve();
}

final class _TopToolbarLayoutResolver implements TopToolbarLayoutResolver {
  const _TopToolbarLayoutResolver({
    required this.viewBounds,
    required this.viewSize,
    required this.occlusions,
    required this.pane,
    required this.row,
    required this.systemTopInset,
    required this.currentTopInset,
    required this.currentViewTopInset,
    required this.minimumTopInset,
    required this.alignmentHeight,
  });

  // Native and Flutter coordinates can differ by floating-point noise.
  // View-size matching retains its separate half-point rounding tolerance.
  static const double _edgeTolerance = 0.000001;

  final Rect viewBounds;
  final Size viewSize;
  final List<Rect> occlusions;
  final Rect pane;
  final Rect row;
  final double systemTopInset;
  final double currentTopInset;
  final double currentViewTopInset;
  final double minimumTopInset;
  final double? alignmentHeight;

  double get _originalTopInset => math.max(currentTopInset, minimumTopInset);

  @override
  TopToolbarLayout? resolve() {
    if (!_hasUsableInputs || !_matchesDeclaredLayout()) return null;
    final statusBand = _resolveSupportedTopBand();
    if (statusBand == null) return null;
    return _resolveAlignedToolbar(statusBand);
  }

  bool get _hasUsableInputs {
    final alignmentHeight = this.alignmentHeight;
    return row.isFinite &&
        !row.isEmpty &&
        pane.isFinite &&
        !pane.isEmpty &&
        systemTopInset > 0 &&
        minimumTopInset.isFinite &&
        minimumTopInset >= 0 &&
        (alignmentHeight == null ||
            (alignmentHeight.isFinite && alignmentHeight > 0));
  }

  bool _matchesDeclaredLayout() =>
      OcclusionInsetsResolver.matchesViewSize(viewBounds, viewSize) &&
      viewSize.width < viewSize.height &&
      (pane.top - viewBounds.top).abs() <= _edgeTolerance &&
      (pane.right - viewBounds.right).abs() <= _edgeTolerance &&
      pane.left >= viewBounds.left - _edgeTolerance &&
      pane.bottom <= viewBounds.bottom + _edgeTolerance &&
      (row.left - pane.left).abs() <= _edgeTolerance &&
      (row.right - pane.right).abs() <= _edgeTolerance &&
      (row.top - pane.top - _originalTopInset).abs() <= _edgeTolerance &&
      currentTopInset >= systemTopInset - _edgeTolerance;

  Rect? _resolveSupportedTopBand() {
    // Find complete top-right blocks connected to the viewport's top edge.
    var bottom = pane.top;
    for (final region in occlusions) {
      if (!region.overlaps(pane) || region.top > pane.top + _edgeTolerance) {
        continue;
      }
      // Only a complete top-right block can replace the system top inset.
      if (region.left < pane.center.dx ||
          region.right < pane.right - _edgeTolerance ||
          region.bottom > pane.bottom + _edgeTolerance) {
        return null;
      }
      bottom = math.max(bottom, region.bottom);
    }
    if (bottom - pane.top < systemTopInset - _edgeTolerance) return null;

    // Check the complete band for other occlusions that need not touch its top.
    final band = Rect.fromLTRB(pane.left, pane.top, pane.right, bottom);
    final hasConflict = occlusions.any(
      (region) =>
          region.overlaps(band) &&
          (region.left < pane.center.dx ||
              region.bottom > band.bottom + _edgeTolerance),
    );
    return hasConflict ? null : band;
  }

  TopToolbarLayout? _resolveAlignedToolbar(Rect statusBand) {
    final extraTop = math.max(
      0.0,
      math.max(currentTopInset, currentViewTopInset) - systemTopInset,
    );
    final alignmentHeight = math.max(
      row.height,
      this.alignmentHeight ?? row.height,
    );
    final alignmentTop = math.max(0.0, statusBand.height - alignmentHeight);
    final top = math.max(
      math.max(minimumTopInset, extraTop),
      alignmentTop + (alignmentHeight - row.height) / 2,
    );
    if (!top.isFinite || top >= _originalTopInset - _edgeTolerance) return null;
    return (
      topInset: top,
      minimumExtent: math.max(alignmentTop + alignmentHeight, top + row.height),
      bounds: Rect.fromLTWH(row.left, pane.top + top, row.width, row.height),
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

class _ToolbarOcclusionConsumed extends InheritedWidget {
  const _ToolbarOcclusionConsumed({
    required this.adapted,
    required this.topReclaimed,
    required this.minimumExtent,
    required super.child,
  });

  final bool adapted;
  final bool topReclaimed;
  final double? minimumExtent;

  @override
  bool updateShouldNotify(_ToolbarOcclusionConsumed oldWidget) =>
      adapted != oldWidget.adapted ||
      topReclaimed != oldWidget.topReclaimed ||
      minimumExtent != oldWidget.minimumExtent;
}
