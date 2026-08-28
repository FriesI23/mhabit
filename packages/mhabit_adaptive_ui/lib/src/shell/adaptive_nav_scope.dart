import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils.dart';
import 'adaptive_nav_visibility.dart';

/// Inherited scope exposed by the adaptive navigation shell to its
/// branches.
///
/// In the compact form, branch pages read [visible] to coordinate FAB /
/// floating-action animations with the bottom bar and reserve [navHeight].
/// The shell derives [scrollWish] from active vertical user scrolling;
/// [reportScrollWish] remains available for explicit non-scroll policy. In
/// non-compact forms (medium+) navigation is always visible.
class AdaptiveNavScope extends InheritedWidget {
  /// Creates a navigation scope for a shell branch subtree.
  const AdaptiveNavScope({
    super.key,
    required this.barHeight,
    required this.navHeight,
    required super.child,
    this._visible,
    this._scrollWish,
  });

  final AdaptiveNavVisibilityController? _visible;
  final AdaptiveScrollWishController? _scrollWish;

  /// Fallback listenable for non-compact forms; always true, never notifies.
  static const ConstValueListenable<bool> _alwaysTrue = ConstValueListenable(
    true,
  );

  /// Whether compact navigation chrome currently occupies its envelope.
  ///
  /// Apple minimized chrome remains visible; route or contextual suppression
  /// makes it false. Material also makes it false for a hidden scroll wish.
  /// Pages read it to coordinate FAB animations, e.g. through
  /// [ValueListenableBuilder]; the [ValueListenable] view is read-only by
  /// construction. Non-compact forms expose a constant-true listenable.
  ValueListenable<bool> get visible => _visible ?? _alwaysTrue;

  /// Whether the active page wants expanded/visible navigation chrome.
  ///
  /// Exposed as a read-only [ValueListenable]. The shell normally derives it
  /// from active vertical scrolling; a false wish hides Material chrome and
  /// minimizes Apple chrome. Non-compact forms expose a constant-true
  /// listenable.
  ValueListenable<bool> get scrollWish => _scrollWish ?? _alwaysTrue;

  /// Reports an explicit visibility wish to the shell.
  ///
  /// Normal vertical page scrolling is observed automatically by the shell.
  /// Use this for specialized non-scroll policy. Ignored in non-compact forms,
  /// where navigation is always visible.
  void reportScrollWish(bool visible) => _scrollWish?.report(visible);

  /// Content height of the bar, excluding the bottom safe-area inset.
  ///
  /// Use this to lift floating widgets (e.g. FABs) above the bar: Scaffold
  /// already positions them above the system inset, so adding [navHeight]
  /// would double-count the inset. Always 0 in non-compact forms.
  final double barHeight;

  /// Total rendered height of the bottom bar, including the system bottom
  /// safe-area inset.
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
      barHeight != oldWidget.barHeight ||
      navHeight != oldWidget.navHeight;
}
