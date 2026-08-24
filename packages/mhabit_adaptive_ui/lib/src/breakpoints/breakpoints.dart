import 'package:flutter/widgets.dart';

import '../adaptive_style.dart';
import 'window_size_class.dart';

// Width bounds shared by the platform implementations.
const double _compactWidthBound = 600;
const double _mediumWidthBound = 840;
const double _largeWidthBound = 1200;
const double _extraLargeWidthBound = 1600;

// Height bounds shared by the platform implementations.
const double _compactHeightBound = 480;
const double _expandedHeightBound = 900;

// Apple large tier: ≈ 80% of the iPad mini landscape width (1133dp), so the
// large tier is reached comfortably below real iPad landscape widths. iPad
// 13-inch portrait (1032dp) and every iPad landscape (≥ 1080dp) are large;
// iPad portraits and split-view windows stay medium.
const double _appleLargeWidthBound = 906;

/// Classifies window dimensions into [WindowSizeClass]es.
///
/// The fixed contract for breakpoint resolution: each platform provides its
/// own implementation, callers go through [Breakpoints.of] / [WindowSize.of]
/// and never branch on the implementation. Platforms without an
/// implementation fall back to [MaterialBreakpoints].
abstract interface class Breakpoints {
  /// Classifies a window width into a [WindowSizeClass].
  WindowSizeClass widthClass(double width);

  /// Classifies a window height into a [WindowSizeClass], or returns null
  /// when the implementation does not classify height.
  WindowSizeClass? heightClass(double height);

  /// Resolves the active [Breakpoints]:
  ///
  /// 1. the nearest [BreakpointsScope] (tree-level override),
  /// 2. the platform implementation selected by the adaptive style,
  /// 3. [MaterialBreakpoints] as the final fallback.
  static Breakpoints of(BuildContext context) =>
      BreakpointsScope.maybeOf(context)?.breakpoints ??
      switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.apple => const AppleBreakpoints(),
        AdaptiveStyle.material => const MaterialBreakpoints(),
      };
}

/// Data-driven [Breakpoints] from ascending lists of exclusive upper bounds.
///
/// n width bounds yield n+1 classes, mapped positionally to
/// `compact..WindowSizeClass.values[n]` (extra classes clamp to
/// [WindowSizeClass.extraLarge]). An empty height list disables height
/// classification.
class CustomBreakpoints implements Breakpoints {
  const CustomBreakpoints({required this.width, this.height = const []});

  /// Ascending exclusive upper bounds of the width classes.
  final List<double> width;

  /// Ascending exclusive upper bounds of the height classes; empty means
  /// height is not classified.
  final List<double> height;

  @override
  WindowSizeClass widthClass(double value) => _classFor(value, width);

  @override
  WindowSizeClass? heightClass(double value) =>
      height.isEmpty ? null : _classFor(value, height);

  WindowSizeClass _classFor(double value, List<double> bounds) {
    var index = 0;
    for (final bound in bounds) {
      if (value < bound) break;
      index++;
    }
    return WindowSizeClass.values[index < WindowSizeClass.values.length
        ? index
        : WindowSizeClass.values.length - 1];
  }
}

/// Material breakpoints: the M3 window size classes extended with Android's
/// large and extra-large tiers (5 width / 3 height classes).
///
/// The final fallback when a platform provides no [Breakpoints].
final class MaterialBreakpoints extends CustomBreakpoints {
  const MaterialBreakpoints()
    : super(
        // Android window size classes: compact < 600, medium 600-839,
        // expanded 840-1199, large 1200-1599, extra-large >= 1600.
        width: const [
          _compactWidthBound,
          _mediumWidthBound,
          _largeWidthBound,
          _extraLargeWidthBound,
        ],
        // Android height classes: compact < 480, medium 480-899,
        // expanded >= 900.
        height: const [_compactHeightBound, _expandedHeightBound],
      );
}

/// Apple breakpoints: three width classes (compact, medium, large) and
/// Material-style height classes.
///
/// Anchors: phones classify as compact, iPad portraits (incl. iPad mini) as
/// medium, iPad landscape / 13-inch portrait / desktop windows as large.
final class AppleBreakpoints extends CustomBreakpoints {
  const AppleBreakpoints()
    : super(
        // Apple width classes: compact < 600, medium 600-905, large >= 906.
        // The duplicated bound skips the expanded tier positionally, like
        // the old chain skipped medium.
        width: const [
          _compactWidthBound,
          _appleLargeWidthBound,
          _appleLargeWidthBound,
        ],
        // Same height classes as material: compact < 480, medium 480-899,
        // expanded >= 900.
        height: const [_compactHeightBound, _expandedHeightBound],
      );
}

/// Overrides [Breakpoints] for a subtree, like [Theme] overrides theme data.
class BreakpointsScope extends InheritedWidget {
  const BreakpointsScope({
    super.key,
    required this.breakpoints,
    required super.child,
  });

  /// The manual breakpoints applied to the subtree.
  final Breakpoints breakpoints;

  /// Reads the nearest scope and rebuilds the caller when it changes.
  static BreakpointsScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BreakpointsScope>();

  @override
  bool updateShouldNotify(BreakpointsScope oldWidget) =>
      oldWidget.breakpoints != breakpoints;
}
