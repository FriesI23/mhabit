import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'occlusion_layout.dart';
import 'occlusion_toolbar.dart';

/// Resolves the final top row only for a viewport that fills its declared pane.
///
/// Owners of nested or transformed layouts must declare their own region, or
/// shadow it with null. Matching dimensions do not establish a new position.
extension OcclusionSliverConstraints on SliverConstraints {
  /// Returns a toolbar row in logical native-view coordinates.
  ///
  /// [height] must be finite and positive. [topOffset] is a finite distance from
  /// the declared pane's top edge. Scroll and route paint offsets are ignored:
  /// this describes the row at its pinned position.
  ///
  /// Returns null for an unknown pane, mismatched viewport dimensions, or a
  /// sliver that does not grow forward along [AxisDirection.down].
  Rect? occlusionToolbarBounds(
    BuildContext context, {
    required double height,
    double topOffset = 0,
  }) {
    final bounds = OcclusionViewport.maybeOf(context)?.bounds;
    if (bounds == null ||
        !bounds.isFinite ||
        bounds.isEmpty ||
        axisDirection != AxisDirection.down ||
        growthDirection != GrowthDirection.forward ||
        !height.isFinite ||
        height <= 0 ||
        !topOffset.isFinite ||
        !crossAxisExtent.isFinite ||
        !viewportMainAxisExtent.isFinite ||
        (bounds.width - crossAxisExtent).abs() > 0.5 ||
        (bounds.height - viewportMainAxisExtent).abs() > 0.5) {
      return null;
    }
    return Rect.fromLTWH(
      bounds.left,
      bounds.top + topOffset,
      crossAxisExtent,
      height,
    );
  }
}

/// Adapts a standard vertical sliver toolbar without measuring paint offsets.
class AdaptiveSliverOcclusionToolbar extends StatelessWidget {
  /// Adapts a sliver toolbar using its viewport's declared layout bounds.
  const AdaptiveSliverOcclusionToolbar({
    super.key,
    required this.child,
    this.height = kToolbarHeight,
    this.topOffset = 0,
    this.reclaimTopSafeArea = false,
    this.minimumTopInset = 0,
    this.topToolbarLayoutOverride,
  });

  /// The sliver subtree that receives the projected toolbar insets.
  final Widget child;

  /// The finite, positive toolbar-row height, excluding its top inset.
  final double height;

  /// The original row's offset below the pane's top, before reclamation.
  final double topOffset;

  /// Whether a pinned row may reclaim the top safe area.
  ///
  /// See [AdaptiveOcclusionToolbar.reclaimTopSafeArea].
  final bool reclaimTopSafeArea;

  /// The non-negative local top spacing retained after reclamation.
  final double minimumTopInset;

  /// A shared row override, or null to resolve this toolbar independently.
  ///
  /// An override whose layout is null explicitly rejects reclamation.
  final TopToolbarLayoutOverride? topToolbarLayoutOverride;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) => AdaptiveOcclusionToolbar(
      bounds: constraints.occlusionToolbarBounds(
        context,
        height: height,
        topOffset: topOffset,
      ),
      reclaimTopSafeArea: reclaimTopSafeArea,
      minimumTopInset: minimumTopInset,
      topToolbarLayoutOverride: topToolbarLayoutOverride,
      child: child,
    ),
  );
}
