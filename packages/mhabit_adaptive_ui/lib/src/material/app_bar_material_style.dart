import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

import '../window_control/toolbar_geometry.dart';

part 'app_bar_material_style.g.dart';

/// Style config for the Material branch of an adaptive AppBar.
///
/// App-bar fields map to [SliverAppBar]. [windowControlEdgePadding] is the
/// Material visual baseline added only on sides with window-control avoidance.
@CopyWith(skipFields: true)
class AppBarMaterialStyle {
  const AppBarMaterialStyle({
    this.centerTitle = false,
    this.floating = true,
    this.snap = true,
    this.pinned = true,
    this.forceElevated = false,
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
    this.backgroundColor,
    this.surfaceTintColor,
    this.bottom,
    this.windowControlEdgePadding = materialWindowControlEdgePadding,
  });

  final bool centerTitle;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool forceElevated;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final PreferredSizeWidget? bottom;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  bool operator ==(Object other) =>
      other is AppBarMaterialStyle &&
      other.centerTitle == centerTitle &&
      other.floating == floating &&
      other.snap == snap &&
      other.pinned == pinned &&
      other.forceElevated == forceElevated &&
      other.scrolledUnderElevation == scrolledUnderElevation &&
      other.shadowColor == shadowColor &&
      other.backgroundColor == backgroundColor &&
      other.surfaceTintColor == surfaceTintColor &&
      other.bottom == bottom &&
      other.windowControlEdgePadding == windowControlEdgePadding;

  @override
  int get hashCode => Object.hash(
    centerTitle,
    floating,
    snap,
    pinned,
    forceElevated,
    scrolledUnderElevation,
    shadowColor,
    backgroundColor,
    surfaceTintColor,
    bottom,
    windowControlEdgePadding,
  );
}
