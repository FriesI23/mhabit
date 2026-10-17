import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/async.dart';
import '../common/consts.dart';

/// Initializes local preferences and the package's native window coordinator.
class DesktopWindowPersistence implements AsyncInitialization {
  static DesktopWindowPersistence? _instance;

  factory DesktopWindowPersistence() =>
      _instance ??= DesktopWindowPersistence._();

  @visibleForTesting
  DesktopWindowPersistence.forTesting({
    Size minimumSize = appDesktopWindowMinimumSize,
    DesktopWindowPersistenceAdapter? adapter,
    Future<SharedPreferences> Function()? loadPreferences,
  }) : this._(
         minimumSize: minimumSize,
         adapter: adapter,
         loadPreferences: loadPreferences,
       );

  DesktopWindowPersistence._({
    this.minimumSize = appDesktopWindowMinimumSize,
    DesktopWindowPersistenceAdapter? adapter,
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _adapter = adapter ?? DesktopWindowPersistenceAdapter(),
       _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  final Size minimumSize;
  final DesktopWindowPersistenceAdapter _adapter;
  final Future<SharedPreferences> Function() _loadPreferences;
  late final _window = DesktopWindowPersistenceController(
    store: _store,
    adapter: _adapter,
  );
  late final _store = DesktopWindowStateStore(
    format: _adapter.stateFormat,
    read: (key) => _pref?.getString(key),
    write: (key, value) => _pref?.setString(key, value) ?? Future.value(false),
  );
  SharedPreferences? _pref;
  Future<void>? _initialization;
  bool _disposed = false;

  @override
  Future<void> init() {
    if (_disposed || !_adapter.supported) return Future.value();
    return _initialization ??= _initialize().whenComplete(
      () => _initialization = null,
    );
  }

  Future<void> _initialize() async {
    if (_adapter.stateFormat != null) await _initializePreferences();
    if (!_disposed) await _window.initialize(minimumSize: minimumSize);
  }

  Future<void> _initializePreferences() async {
    const wait = Duration(seconds: 2);
    final deadline = TimeoutException(
      'Window preferences initialization',
      wait,
    );
    try {
      _pref ??= await _loadPreferences().timeout(
        wait,
        onTimeout: () => throw deadline,
      );
    } catch (error, stack) {
      // Only our optional window wait can degrade. A backend failure also
      // affects Profile, including a TimeoutException raised by the backend.
      if (!identical(error, deadline)) rethrow;
      if (kDebugMode) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'desktop window persistence',
            context: ErrorDescription(
              'while waiting for optional window preferences; '
              'continuing with the default window',
            ),
          ),
        );
      }
    }
  }

  /// Reads the saved state from the initialized preference cache.
  DesktopWindowState? getSavedState() => _store.get();

  /// Persists the supplied state through the local store.
  Future<bool> saveState(DesktopWindowState state) => _store.set(state);

  Future<void> flush() => _window.flush();

  Future<void> dispose() {
    _disposed = true;
    return _window.dispose();
  }
}
