import 'package:flutter/foundation.dart';

/// Output controller of the adaptive navigation shell.
///
/// Extends [ValueNotifier] so consumers can subscribe to it as a
/// [Listenable] and rebuild with [ValueListenableBuilder]. The shell
/// writes it through [show] / [hide]; pages only see the read-only
/// [ValueListenable] view exposed by the navigation scope.
class AdaptiveNavVisibilityController extends ValueNotifier<bool> {
  AdaptiveNavVisibilityController({bool visible = true}) : super(visible);

  /// Makes the bar visible; no-op when it is already visible.
  void show() {
    if (value) return;
    value = true;
  }

  /// Makes the bar invisible; no-op when it is already invisible.
  void hide() {
    if (!value) return;
    value = false;
  }
}

/// Input controller of the adaptive navigation shell.
///
/// Extends [ValueNotifier] so consumers can subscribe to it as a
/// [Listenable] and rebuild with [ValueListenableBuilder]. Pages report
/// wishes through the navigation scope; the shell resets the wish on
/// branch switches. Pages only see the read-only [ValueListenable] view
/// exposed by the navigation scope.
class AdaptiveScrollWishController extends ValueNotifier<bool> {
  AdaptiveScrollWishController({bool visible = true}) : super(visible);

  /// Reports a new wish; no-op when the wish is unchanged.
  void report(bool visible) {
    if (value == visible) return;
    value = visible;
  }

  /// Resets the wish to visible, e.g. after a branch switch or when a
  /// branch stack returns to its root.
  void reset() => report(true);
}
