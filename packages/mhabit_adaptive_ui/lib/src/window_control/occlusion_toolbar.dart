import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'occlusion_layout.dart';

/// Aligned toolbar geometry and the protected extent before bottom content.
///
/// All distances are logical pixels. The insets and extents are measured from
/// the pane's top edge; [Rect] bounds use native-view coordinates.
typedef TopToolbarLayout = ({
  /// The local distance from the pane's top to the toolbar's top.
  double topInset,

  /// The minimum distance from the pane's top to additional bottom content.
  double minimumExtent,

  /// The final toolbar row in logical native-view coordinates.
  Rect bounds,
});

/// A shared toolbar layout override in native-view coordinates.
///
/// A supplied override with a null layout explicitly rejects reclamation.
/// This differs from omitting the override, which allows independent resolution.
typedef TopToolbarLayoutOverride = ({
  /// The accepted shared row, or null to reject top-safe-area reclamation.
  TopToolbarLayout? layout,

  /// The native root bounds against which the shared row was accepted.
  Rect? viewportBounds,
});

/// Projects precise horizontal insets into an explicitly declared toolbar row.
///
/// Unknown bounds retain the current Safe Area; body geometry is unchanged.
/// Route paint transitions do not change this layout projection.
class AdaptiveOcclusionToolbar extends StatefulWidget {
  /// Creates a toolbar-local boundary for safe-area projection.
  const AdaptiveOcclusionToolbar({
    super.key,
    this.bounds,
    required this.child,
    this.preserveHorizontalSafeArea = true,
    this.reclaimTopSafeArea = false,
    this.minimumTopInset = 0,
    this.topToolbarLayoutOverride,
  });

  /// The declared layout row in native-view coordinates before route painting.
  ///
  /// Omitting bounds retains the current conservative Safe Area.
  final Rect? bounds;

  /// The toolbar subtree that receives the projected [MediaQuery].
  final Widget child;

  /// Whether to retain system horizontal clearance outside a usable bar column.
  ///
  /// Defaults to true. Floating bottom navigation sets this to false and uses
  /// its own protected band; actual occlusions and corners still apply.
  final bool preserveHorizontalSafeArea;

  /// Whether this pinned top-row toolbar may release the status-area top inset.
  ///
  /// Defaults to false. Reclamation also requires the enclosing scope's opt-in
  /// and a valid declared row and viewport.
  final bool reclaimTopSafeArea;

  /// The minimum local top spacing retained after reclamation.
  ///
  /// Must be finite and non-negative. Defaults to zero.
  final double minimumTopInset;

  /// Null resolves independently; an override must contain valid geometry.
  final TopToolbarLayoutOverride? topToolbarLayoutOverride;

  /// Whether an ancestor owns horizontal safe-area handling for this toolbar.
  ///
  /// This includes conservative handling during a missing native snapshot;
  /// true does not necessarily indicate that precise geometry was applied.
  static bool isAdaptedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
          ?.adapted ??
      false;

  /// Whether an ancestor successfully reclaimed the top safe area.
  static bool isTopReclaimedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_ToolbarOcclusionConsumed>()
          ?.topReclaimed ??
      false;

  /// Protected extent before an app bar's additional bottom content.
  ///
  /// Measured from the pane's top edge. Null means no ancestor has supplied a
  /// reclaimed row; consumers then retain their ordinary extent calculation.
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
    final row = widget.bounds;
    final pane = OcclusionViewport.maybeOf(context)?.bounds;
    if (!scope.canReclaimTopToolbar(topViewInset: media.viewInsets.top) ||
        row == null ||
        pane == null) {
      return null;
    }
    final geometry = scope.geometry!;
    final view = View.of(context);
    final viewSize = view.physicalSize / view.devicePixelRatio;
    return TopToolbarLayoutResolver(
      viewBounds: geometry.viewBounds,
      viewSize: viewSize,
      occlusions: geometry.activeOcclusionRegions,
      pane: pane,
      row: row,
      systemTopInset: scope.systemSafeArea.top,
      currentTopInset: media.padding.top,
      currentViewTopInset: media.viewPadding.top,
      minimumTopInset: widget.minimumTopInset,
      alignmentHeight: scope.topToolbarAlignmentHeight,
      topToolbarLayoutOverride: widget.topToolbarLayoutOverride,
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
///
/// Independent resolution supports portrait panes touching the native view's
/// top and right edges, with a complete top-right status block. A shared
/// override can align other panes to a row accepted by their layout owner.
///
/// ```text
/// pane.top      +-------------------+----------+
///               |                   | status   |
/// topInset      | +---------------+ | block    |
///               | | toolbar row   | |          |
///               | +---------------+ +----------+
/// minimumExtent +------------------------------+  bottom content starts here
/// ```
///
/// The diagram shows local vertical distances; row bounds retain their
/// position in native-view coordinates.
abstract interface class TopToolbarLayoutResolver {
  /// Creates a resolver for one declared row and its current safe-area data.
  ///
  /// [viewBounds], [pane], [row], and [occlusions] use logical native-view
  /// coordinates. [viewSize] is the current Flutter view size for freshness
  /// validation. [row] describes the original row before reclamation.
  ///
  /// [systemTopInset] is the view-wide system inset. [currentTopInset] and
  /// [currentViewTopInset] are the consumer's current padding and view padding.
  /// [minimumTopInset] is its non-negative local spacing floor.
  /// [alignmentHeight] optionally supplies a shared positive row height.
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
    TopToolbarLayoutOverride? topToolbarLayoutOverride,
  }) = _TopToolbarLayoutResolver;

  /// Returns the local top inset, protected extent before bottom content, and
  /// final row bounds in native-view layout coordinates.
  ///
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
    this.topToolbarLayoutOverride,
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
  final TopToolbarLayoutOverride? topToolbarLayoutOverride;

  double get _originalTopInset => math.max(currentTopInset, minimumTopInset);

  @override
  TopToolbarLayout? resolve() {
    if (!_hasUsableInputs) return null;
    final topToolbarLayoutOverride = this.topToolbarLayoutOverride;
    if (topToolbarLayoutOverride != null) {
      final layout = topToolbarLayoutOverride.layout;
      final viewportBounds = topToolbarLayoutOverride.viewportBounds;
      if (layout == null ||
          viewportBounds == null ||
          !_matchesLayoutOverride(layout, viewportBounds)) {
        return null;
      }
      return _resolveLayoutOverride(layout);
    }
    if (!_matchesDeclaredLayout()) return null;
    final statusBand = _resolveSupportedTopBand();
    if (statusBand == null) return null;
    return _resolveAlignedToolbar(statusBand);
  }

  bool _matchesLayoutOverride(TopToolbarLayout layout, Rect viewportBounds) {
    final hasCurrentGeometry =
        viewportBounds == viewBounds &&
        layout.bounds.isFinite &&
        !layout.bounds.isEmpty &&
        layout.minimumExtent.isFinite &&
        layout.topInset.isFinite &&
        OcclusionInsetsResolver.matchesViewSize(viewBounds, viewSize) &&
        viewSize.width < viewSize.height;
    final containsPane =
        (pane.top - viewportBounds.top).abs() <= _edgeTolerance &&
        pane.left >= viewportBounds.left - _edgeTolerance &&
        pane.right <= viewportBounds.right + _edgeTolerance &&
        pane.bottom <= viewportBounds.bottom + _edgeTolerance;
    final matchesDeclaredRow =
        (row.left - pane.left).abs() <= _edgeTolerance &&
        (row.right - pane.right).abs() <= _edgeTolerance &&
        (row.top - pane.top - _originalTopInset).abs() <= _edgeTolerance &&
        currentTopInset >= systemTopInset - _edgeTolerance;
    return hasCurrentGeometry && containsPane && matchesDeclaredRow;
  }

  TopToolbarLayout? _resolveLayoutOverride(TopToolbarLayout layout) {
    final extraTop = math.max(
      0.0,
      math.max(currentTopInset, currentViewTopInset) - systemTopInset,
    );
    final top = math.max(
      math.max(minimumTopInset, extraTop),
      layout.bounds.center.dy - pane.top - row.height / 2,
    );
    if (!top.isFinite || top >= _originalTopInset - _edgeTolerance) return null;
    return (
      topInset: top,
      minimumExtent: math.max(layout.minimumExtent, top + row.height),
      bounds: Rect.fromLTWH(row.left, pane.top + top, row.width, row.height),
    );
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
  /// Creates a calculator using logical native-view bounds.
  ///
  /// [systemSafeArea] describes the whole view. [controlColumn] is UIKit's
  /// permitted control-layout region, not an occlusion. A missing or unusable
  /// column retains system clearance where it intersects [toolbarBounds].
  const factory ToolbarSafeAreaCalculator({
    required Rect viewBounds,
    required Rect toolbarBounds,
    required EdgeInsets systemSafeArea,
    required Rect? controlColumn,
  }) = _ToolbarSafeAreaCalculator;

  /// Returns the minimum physical left/right insets relative to the toolbar.
  ///
  /// Only a column containing the full toolbar height can reduce clearance at
  /// its physical edge. Top and bottom components are zero. Consumers add
  /// actual occlusion, corner, and visual protection separately.
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
