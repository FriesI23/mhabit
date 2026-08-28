import 'package:flutter/foundation.dart' show ValueChanged, VoidCallback;

/// App-shell commands and state owned by the Habits branch.
abstract interface class HabitDisplayNavigationChrome {
  factory HabitDisplayNavigationChrome({
    required ValueChanged<VoidCallback> registerPrimaryAction,
    required ValueChanged<VoidCallback> unregisterPrimaryAction,
    required ValueChanged<bool> setContextualChromeSuppressed,
  }) => _HabitDisplayNavigationChrome(
    registerPrimaryAction,
    unregisterPrimaryAction,
    setContextualChromeSuppressed,
  );

  void registerPrimaryAction(VoidCallback action);

  void unregisterPrimaryAction(VoidCallback action);

  void setContextualChromeSuppressed(bool suppressed);
}

final class _HabitDisplayNavigationChrome
    implements HabitDisplayNavigationChrome {
  const _HabitDisplayNavigationChrome(
    this._registerPrimaryAction,
    this._unregisterPrimaryAction,
    this._setContextualChromeSuppressed,
  );

  final ValueChanged<VoidCallback> _registerPrimaryAction;
  final ValueChanged<VoidCallback> _unregisterPrimaryAction;
  final ValueChanged<bool> _setContextualChromeSuppressed;

  @override
  void registerPrimaryAction(VoidCallback action) =>
      _registerPrimaryAction(action);

  @override
  void unregisterPrimaryAction(VoidCallback action) =>
      _unregisterPrimaryAction(action);

  @override
  void setContextualChromeSuppressed(bool suppressed) =>
      _setContextualChromeSuppressed(suppressed);
}
