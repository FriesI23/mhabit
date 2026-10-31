import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'occlusion_layout.dart';
import 'occlusion_toolbar.dart';

/// Resolves the final top row only for a viewport that fills its declared pane.
/// Owners of nested or transformed layouts must declare their own region, or
/// shadow it with null. Matching dimensions do not establish a new position.
extension OcclusionSliverConstraints on SliverConstraints {
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
  const AdaptiveSliverOcclusionToolbar({
    super.key,
    required this.child,
    this.height = kToolbarHeight,
    this.topOffset = 0,
    this.reclaimTopSafeArea = false,
    this.minimumTopInset = 0,
  });

  final Widget child;
  final double height;
  final double topOffset;
  final bool reclaimTopSafeArea;
  final double minimumTopInset;

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
      child: child,
    ),
  );
}
