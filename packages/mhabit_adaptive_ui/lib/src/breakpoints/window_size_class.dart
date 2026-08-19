import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext, MediaQuery, Size;

import 'breakpoints.dart' show Breakpoints;

/// Window size classes for adaptive layout decisions.
///
/// Names and breakpoints follow the Android window size classes and the
/// Material Design layout guidance: five width classes and three height
/// classes. Height classification is optional and driven by the active
/// [Breakpoints] implementation.
enum WindowSizeClass {
  /// Width below 600 dp (phone portrait).
  compact,

  /// Width from 600 to below 840 dp.
  medium,

  /// Width from 840 to below 1200 dp.
  expanded,

  /// Width from 1200 to below 1600 dp.
  large,

  /// Width of 1600 dp and above.
  extraLarge;

  /// Whether this class is at least as large as [other].
  ///
  /// The declaration order is the class order: compact < medium < expanded
  /// < large < extraLarge. Platform implementations may skip intermediate
  /// classes (e.g. Apple skips medium), but the relative order is stable.
  /// Do not reorder the members.
  bool operator >=(WindowSizeClass other) => index >= other.index;
}

/// The window's width and height classes at a point in time.
@immutable
class WindowSize {
  const WindowSize({required this.width, this.height});

  /// Class derived from the window width.
  final WindowSizeClass width;

  /// Class derived from the window height, or null when the active
  /// [Breakpoints] implementation does not classify height.
  final WindowSizeClass? height;

  /// Classifies [size] through [breakpoints] into width and height classes;
  /// the height class is null when [breakpoints] does not classify height.
  factory WindowSize.fromBreakpoints(Breakpoints breakpoints, Size size) =>
      WindowSize(
        width: breakpoints.widthClass(size.width),
        height: breakpoints.heightClass(size.height),
      );

  /// The window's width and height classes for the current [MediaQuery] size.
  static WindowSize of(BuildContext context) => WindowSize.fromBreakpoints(
    Breakpoints.of(context),
    MediaQuery.sizeOf(context),
  );

  /// Rectangle-style containment: this size reaches [other] on every
  /// classified axis.
  ///
  /// When [other] does not classify height, only the width is compared.
  /// When this size has no height classification but [other] requires one,
  /// containment fails.
  bool contains(WindowSize other) {
    final height = this.height;
    final otherHeight = other.height;
    if (otherHeight == null) return width >= other.width;
    return width >= other.width && height != null && height >= otherHeight;
  }
}
