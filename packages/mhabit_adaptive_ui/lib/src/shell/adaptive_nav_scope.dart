import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';
import 'adaptive_nav_visibility.dart';

/// Inherited scope exposed by the adaptive navigation shell to its
/// branches.
///
/// In the compact form, branch pages read [visible] to coordinate FAB /
/// placeholder animations with the bottom bar, call [reportScrollWish] to
/// report scroll-driven visibility changes, and reserve [navHeight]. In
/// non-compact forms (medium+) the navigation is always visible: [visible]
/// and [scrollWish] are constant true, [barHeight] / [navHeight] are 0, and
/// [reportScrollWish] is ignored, so pages keep their wiring unchanged.
class AdaptiveNavScope extends InheritedWidget {
  const AdaptiveNavScope({
    super.key,
    required this.barHeight,
    required this.navHeight,
    required super.child,
    this._visible,
    this._scrollWish,
    this._contextualChrome,
  });

  final AdaptiveNavVisibilityController? _visible;
  final AdaptiveScrollWishController? _scrollWish;
  final AdaptiveContextualChromeController? _contextualChrome;

  /// Fallback listenable for non-compact forms; always true, never notifies.
  static const ConstValueListenable<bool> _alwaysTrue = ConstValueListenable(
    true,
  );

  /// Whether the bottom navigation bar is currently visible.
  ///
  /// Derived by the shell from [scrollWish], the branch stack depth, and
  /// the bar visibility policy. Pages read it to coordinate FAB /
  /// placeholder animations, e.g. through [ValueListenableBuilder]; the
  /// [ValueListenable] view is read-only by construction. Non-compact forms
  /// expose a constant-true listenable.
  ValueListenable<bool> get visible => _visible ?? _alwaysTrue;

  /// Whether the active page wants the bottom bar visible.
  ///
  /// Exposed as a read-only [ValueListenable]; pages report changes
  /// through [reportScrollWish]. The shell combines the wish with the
  /// route stack policy to derive [visible]. Non-compact forms expose a
  /// constant-true listenable.
  ValueListenable<bool> get scrollWish => _scrollWish ?? _alwaysTrue;

  /// Reports the page's scroll-driven visibility wish to the shell.
  ///
  /// Call this from scroll handlers; the shell may override the wish with
  /// the route stack policy. Ignored in non-compact forms, where the
  /// navigation is always visible.
  void reportScrollWish(bool visible) => _scrollWish?.report(visible);

  /// Suppresses compact navigation for a contextual command surface.
  ///
  /// Unlike [reportScrollWish], this value is not affected by scrolling.
  /// Reports remain active across shell-form changes so a compact bar cannot
  /// flash while a contextual surface is resizing from a wider layout.
  void reportContextualChromeSuppressed(bool suppressed) =>
      _contextualChrome?.report(suppressed);

  /// Content height of the bar, excluding the bottom safe-area inset.
  ///
  /// Use this to lift floating widgets (e.g. FABs) above the bar: Scaffold
  /// already positions them above the system inset, so adding [navHeight]
  /// would double-count the inset. Always 0 in non-compact forms.
  final double barHeight;

  /// Total rendered height of the bottom bar, including the bottom
  /// safe-area inset (NavigationBar wraps its content in a SafeArea).
  ///
  /// Always 0 in non-compact forms.
  final double navHeight;

  /// Reads the scope and rebuilds the caller when it changes.
  ///
  /// Throws when no scope exists in [context]. Use [maybeOf] when the scope is
  /// optional.
  static AdaptiveNavScope of(BuildContext context) => maybeOf(context)!;

  /// Reads the optional scope and rebuilds the caller when it changes.
  static AdaptiveNavScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveNavScope>();

  /// Reads the scope without establishing a dependency.
  ///
  /// Use this for callbacks and one-time controller wiring that must not
  /// rebuild when the scope changes. Throws when no scope exists in [context].
  static AdaptiveNavScope read(BuildContext context) => maybeRead(context)!;

  /// Reads the optional scope without establishing a dependency.
  static AdaptiveNavScope? maybeRead(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AdaptiveNavScope>();

  @override
  bool updateShouldNotify(AdaptiveNavScope oldWidget) =>
      _visible != oldWidget._visible ||
      _scrollWish != oldWidget._scrollWish ||
      _contextualChrome != oldWidget._contextualChrome ||
      barHeight != oldWidget.barHeight ||
      navHeight != oldWidget.navHeight;
}
