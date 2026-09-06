import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Places a rail destination group after a vertically flexible leading gap.
///
/// The gap uses [maximumGap] when space is available, shrinks as necessary,
/// and contributes [minimumGap] to the child's intrinsic height. A surrounding
/// scroll viewport can therefore begin scrolling only after the gap reaches
/// its minimum.
final class MaterialRailDestinationGroupLayout
    extends SingleChildRenderObjectWidget {
  const MaterialRailDestinationGroupLayout({
    super.key,
    required this.minimumGap,
    required this.maximumGap,
    required super.child,
  }) : assert(minimumGap >= 0 && minimumGap < double.infinity),
       assert(maximumGap >= minimumGap && maximumGap < double.infinity);

  /// Smallest gap preserved before the surrounding viewport must scroll.
  final double minimumGap;

  /// Preferred gap used when the available height permits it.
  final double maximumGap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMaterialRailDestinationGroupLayout(minimumGap, maximumGap);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final destinationLayout =
        renderObject as _RenderMaterialRailDestinationGroupLayout;
    destinationLayout
      ..minimumGap = minimumGap
      ..maximumGap = maximumGap;
  }
}

final class _RenderMaterialRailDestinationGroupLayout extends RenderShiftedBox {
  _RenderMaterialRailDestinationGroupLayout(this._minimumGap, this._maximumGap)
    : super(null);

  double _minimumGap;

  double get minimumGap => _minimumGap;

  set minimumGap(double value) {
    if (_minimumGap == value) return;
    _minimumGap = value;
    markNeedsLayout();
  }

  double _maximumGap;

  double get maximumGap => _maximumGap;

  set maximumGap(double value) {
    if (_maximumGap == value) return;
    _maximumGap = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      minimumGap + (child?.getMinIntrinsicHeight(width) ?? 0);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      minimumGap + (child?.getMaxIntrinsicHeight(width) ?? 0);

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = child?.getDryLayout(constraints.loosen()) ?? Size.zero;
    return constraints.constrain(
      Size(childSize.width, childSize.height + minimumGap),
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, child.size.height + minimumGap),
    );
    final availableGap = size.height - child.size.height;
    final gap = availableGap.clamp(minimumGap, maximumGap);
    final childParentData = child.parentData! as BoxParentData;
    childParentData.offset = Offset((size.width - child.size.width) / 2, gap);
  }
}
