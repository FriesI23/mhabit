import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';

const double _cupertinoToolbarEdgePadding = 16.0;
const double _maximumPhoneSafeAreaBonus = 16.0;

/// Keeps the standard Cupertino edge margin while adding only a small
/// hardware-aware cushion on phone-shaped windows.
abstract final class CupertinoToolbarPadding {
  static EdgeInsets resolve(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final breakpoints = Breakpoints.of(context);
    final widthClass = breakpoints.widthClass(mediaQuery.size.width);
    final heightClass = breakpoints.heightClass(mediaQuery.size.height);
    final isPhoneFormFactor =
        widthClass == WindowSizeClass.compact ||
        heightClass == WindowSizeClass.compact;
    final safePadding = mediaQuery.padding;
    final leftBonus = isPhoneFormFactor
        ? math.min(safePadding.left, _maximumPhoneSafeAreaBonus)
        : 0.0;
    final rightBonus = isPhoneFormFactor
        ? math.min(safePadding.right, _maximumPhoneSafeAreaBonus)
        : 0.0;
    return EdgeInsets.only(
      left: _cupertinoToolbarEdgePadding + leftBonus,
      right: _cupertinoToolbarEdgePadding + rightBonus,
    );
  }
}
