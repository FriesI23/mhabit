import 'package:flutter/material.dart';

import '../window_control/toolbar_geometry.dart';

/// Style config for the Material branch of an adaptive AppBar.
///
/// App-bar fields map to [SliverAppBar]. [windowControlEdgePadding] is the
/// Material visual baseline added only on sides with window-control avoidance.
class AppBarMaterialStyle {
  const AppBarMaterialStyle({
    this.centerTitle = true,
    this.floating = true,
    this.snap = true,
    this.pinned = true,
    this.forceElevated = false,
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
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
  final PreferredSizeWidget? bottom;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  AppBarMaterialStyle copyWith({
    bool? centerTitle,
    bool? floating,
    bool? snap,
    bool? pinned,
    bool? forceElevated,
    double? scrolledUnderElevation,
    Color? shadowColor,
    PreferredSizeWidget? bottom,
    EdgeInsetsDirectional? windowControlEdgePadding,
  }) => AppBarMaterialStyle(
    centerTitle: centerTitle ?? this.centerTitle,
    floating: floating ?? this.floating,
    snap: snap ?? this.snap,
    pinned: pinned ?? this.pinned,
    forceElevated: forceElevated ?? this.forceElevated,
    scrolledUnderElevation:
        scrolledUnderElevation ?? this.scrolledUnderElevation,
    shadowColor: shadowColor ?? this.shadowColor,
    bottom: bottom ?? this.bottom,
    windowControlEdgePadding:
        windowControlEdgePadding ?? this.windowControlEdgePadding,
  );

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
    bottom,
    windowControlEdgePadding,
  );
}
