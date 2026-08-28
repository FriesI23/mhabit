import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import '../window_control/toolbar_geometry.dart';

const double _maximumPhoneSafeAreaBonus = 16.0;

/// Keeps the standard Cupertino edge margin while adding only a small
/// hardware-aware cushion on phone-shaped windows.
abstract final class CupertinoToolbarPadding {
  static EdgeInsets resolve(
    BuildContext context, {
    EdgeInsetsDirectional? contentPadding,
    EdgeInsetsDirectional edgePadding = cupertinoWindowControlEdgePadding,
  }) => resolveDirectional(
    context,
    contentPadding: contentPadding,
    edgePadding: edgePadding,
  ).resolve(Directionality.of(context));

  static EdgeInsetsDirectional resolveDirectional(
    BuildContext context, {
    EdgeInsetsDirectional? contentPadding,
    EdgeInsetsDirectional edgePadding = cupertinoWindowControlEdgePadding,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final breakpoints = Breakpoints.of(context);
    final widthClass = breakpoints.widthClass(mediaQuery.size.width);
    final heightClass = breakpoints.heightClass(mediaQuery.size.height);
    final isPhoneFormFactor =
        widthClass == WindowSizeClass.compact ||
        heightClass == WindowSizeClass.compact;
    final safePadding = mediaQuery.padding;
    final textDirection = Directionality.of(context);
    final safeStart = textDirection == TextDirection.ltr
        ? safePadding.left
        : safePadding.right;
    final safeEnd = textDirection == TextDirection.ltr
        ? safePadding.right
        : safePadding.left;
    final startBonus = contentPadding == null && isPhoneFormFactor
        ? math.min(safeStart, _maximumPhoneSafeAreaBonus)
        : 0.0;
    final endBonus = contentPadding == null && isPhoneFormFactor
        ? math.min(safeEnd, _maximumPhoneSafeAreaBonus)
        : 0.0;
    final effectiveContentPadding = contentPadding ?? edgePadding;
    return EdgeInsetsDirectional.fromSTEB(
      effectiveContentPadding.start + startBonus,
      effectiveContentPadding.top,
      effectiveContentPadding.end + endBonus,
      effectiveContentPadding.bottom,
    );
  }
}
