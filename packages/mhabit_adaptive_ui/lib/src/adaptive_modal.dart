import 'package:flutter/material.dart';

import 'adaptive_style.dart';

/// Contract for one-shot, platform-dispatched modal invocations.
///
/// Implementations bind their `context` / `builder` and the result type [T] at
/// construction time and are invoked via the pure [call] method; the instance
/// itself is a temporary object that carries no call-time parameters.
abstract interface class AdaptiveModal<T> {
  /// The context the modal is shown from.
  BuildContext get context;

  /// Shows the modal, returning its result.
  Future<T?> call();
}

/// Style accessor for [AdaptiveModal] implementations.
extension AdaptiveModalStyle<T> on AdaptiveModal<T> {
  /// The adaptive style resolved for the modal's [AdaptiveModal.context].
  AdaptiveStyle get adaptiveStyle => resolveAdaptiveStyle(context);
}
