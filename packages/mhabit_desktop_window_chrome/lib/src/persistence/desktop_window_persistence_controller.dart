import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import 'desktop_window_persistence_api.dart';
import 'desktop_window_state_store.dart';

/// Coordinates persistence only. Native adapters own geometry and state rules;
/// the existing window owner remains responsible for displaying the window.
class DesktopWindowPersistenceController<T extends Object> with WindowListener {
  /// The adapter selects native or store-backed persistence; this owner
  /// coordinates scheduling and lifecycle for either implementation.
  DesktopWindowPersistenceController({
    this._store,
    required this._adapter,
    this.debounce = const Duration(milliseconds: 300),
    this.operationTimeout = const Duration(seconds: 2),
  });

  final DesktopWindowStateStore<T>? _store;
  final DesktopWindowPersistenceAdapter<T> _adapter;
  final Duration debounce;
  final Duration operationTimeout;
  Future<void>? _initialization;
  Future<void>? _saving;
  Future<void>? _disposal;
  Timer? _timer;
  bool _ready = false;
  bool _dirty = false;
  bool _closing = false;
  bool _closeHookActive = false;
  bool _disposed = false;

  Future<void> initialize({
    required Size minimumSize,
    String name = 'main-window',
  }) {
    if (_disposed || !_adapter.supported) return Future.value();
    return _initialization ??= _initialize(name, minimumSize);
  }

  Future<void> _initialize(String name, Size minimumSize) async {
    try {
      if (_adapter.managesClose) {
        await windowManager.ensureInitialized().timeout(operationTimeout);
      }
      await _adapter.initialize(
        name,
        minimumSize,
        store: _store,
        operationTimeout: operationTimeout,
      );
    } catch (error) {
      debugPrint('Window placement restore failed: $error');
    }
    if (_disposed) return;
    // Restore/storage failures must not prevent tracking or showing defaults.
    windowManager.addListener(this);
    _ready = true;
    if (_adapter.managesClose) {
      try {
        await windowManager.setPreventClose(true).timeout(operationTimeout);
        _closeHookActive = true;
      } catch (error) {
        debugPrint('Window placement close hook failed: $error');
      }
    }
  }

  void _schedule() {
    if (!_ready || _disposed || _closing) return;
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(flush()));
  }

  /// Coalesces callers behind one writer; an older write can never finish last.
  Future<void> flush() {
    if (!_ready || _disposed) return Future.value();
    _timer?.cancel();
    _dirty = true;
    return _saving ??= _drain().whenComplete(() => _saving = null);
  }

  Future<void> _drain() async {
    while (_dirty && !_disposed) {
      _dirty = false;
      try {
        await _adapter.flush(_store, operationTimeout: operationTimeout);
      } catch (error) {
        debugPrint('Window placement save failed: $error');
      }
    }
  }

  @override
  void onWindowMove() => _schedule();
  @override
  void onWindowResize() => _schedule();
  @override
  void onWindowMoved() => _schedule();
  @override
  void onWindowResized() => _schedule();

  @override
  void onWindowClose() {
    if (_closeHookActive && !_closing && !_disposed) {
      _closing = true;
      unawaited(_close());
    }
  }

  Future<void> _close() async {
    try {
      await flush().timeout(operationTimeout);
    } on TimeoutException {
      debugPrint('Window placement close flush timed out');
    } finally {
      // Restore native closing semantics after the bounded save. Do not use
      // destroy(): on Windows window_manager implements it as PostQuitMessage.
      try {
        await windowManager.setPreventClose(false).timeout(operationTimeout);
        _closeHookActive = false;
        await windowManager.close().timeout(operationTimeout);
      } catch (error) {
        debugPrint('Window placement native close failed: $error');
        await windowManager.destroy();
      }
    }
  }

  Future<void> dispose() => _disposal ??= _dispose();

  Future<void> _dispose() async {
    _timer?.cancel();
    try {
      await _initialization?.timeout(operationTimeout);
      await flush().timeout(operationTimeout);
    } on TimeoutException {
      debugPrint('Window placement dispose flush timed out');
    }
    _disposed = true;
    windowManager.removeListener(this);
    try {
      if (_closeHookActive) {
        await windowManager.setPreventClose(false).timeout(operationTimeout);
        _closeHookActive = false;
      }
      await _adapter.dispose().timeout(operationTimeout);
    } catch (error) {
      debugPrint('Window placement cleanup failed: $error');
    }
  }
}
