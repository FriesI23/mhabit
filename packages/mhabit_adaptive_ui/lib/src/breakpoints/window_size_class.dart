import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

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
  /// classes (e.g. Apple skips expanded), but the relative order is stable.
  /// Do not reorder the members.
  bool operator >=(WindowSizeClass other) => index >= other.index;
}

/// The window's adaptive layout and height classes at a point in time.
///
/// [fromBreakpoints] constrains the width-derived layout class to compact
/// when the height is compact. This is an app layout policy, separate from
/// the raw axis classifications provided by [Breakpoints]. Directly
/// constructed instances retain their supplied classes for layout thresholds.
@immutable
class WindowSize {
  const WindowSize({required this.width, this.height});

  /// Width-derived layout class, constrained by height in [fromBreakpoints].
  final WindowSizeClass width;

  /// Class derived from the window height, or null when the active
  /// [Breakpoints] implementation does not classify height.
  final WindowSizeClass? height;

  /// Classifies [size] and resolves the height-constrained layout class.
  ///
  /// Compact height requires compact layout at every width. Otherwise the
  /// width class is unchanged. An unclassified height preserves width-only
  /// behavior and leaves [height] null.
  factory WindowSize.fromBreakpoints(Breakpoints breakpoints, Size size) {
    final width = breakpoints.widthClass(size.width);
    final height = breakpoints.heightClass(size.height);
    return WindowSize(
      width: height == WindowSizeClass.compact
          ? WindowSizeClass.compact
          : width,
      height: height,
    );
  }

  /// Resolves layout from local width and the ambient viewport height.
  ///
  /// Scrollable content often has unbounded height; it must not bypass the
  /// viewport's height constraint. A bounded local height also describes
  /// content rather than the window. Unbounded width uses the viewport width.
  /// Keyboard insets are not subtracted from the viewport height.
  static WindowSize fromLayoutConstraints(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final viewport = MediaQuery.sizeOf(context);
    return WindowSize.fromBreakpoints(
      Breakpoints.of(context),
      Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : viewport.width,
        viewport.height,
      ),
    );
  }

  /// The adaptive layout and height classes for the current [MediaQuery] size.
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
