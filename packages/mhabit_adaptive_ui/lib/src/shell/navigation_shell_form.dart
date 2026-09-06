import '../breakpoints/window_size_class.dart';

/// Style-neutral space available to a navigation renderer.
///
/// ```text
/// compact          constrained side   expanded side
/// +----------+     +-------------+    +-------------+
/// | content  |     | renderer    |    | renderer    |
/// +----------+     | composition |    | composition |
/// | nav      |     +-------------+    +-------------+
/// +----------+
/// ```
enum NavigationShellForm {
  /// Compact bottom navigation below the branch content.
  compact,

  /// Side navigation with constrained horizontal space.
  constrainedSide,

  /// Side navigation with expanded horizontal space.
  expandedSide,
}

/// Resolves style-neutral shell space from the current window classes.
typedef NavigationShellFormResolver =
    NavigationShellForm Function(WindowSize windowSize);
