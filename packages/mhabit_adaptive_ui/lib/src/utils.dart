import 'package:flutter/foundation.dart';

/// Immutable [ValueListenable] holding a fixed [value]; never notifies.
///
/// Package-internal helper (not exported from the barrel): used for
/// constant fallbacks such as "the navigation is always visible" in
/// non-compact forms.
class ConstValueListenable<T> extends ValueListenable<T> {
  const ConstValueListenable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
