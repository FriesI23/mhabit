import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'desktop_window_state_store.dart';
import 'window_persistence_api.g.dart';

/// Injectable platform persistence behavior. Only the factory selects a platform.
abstract interface class DesktopWindowPersistenceAdapter<T extends Object> {
  /// Selects the native adapter without exposing platform branches to the owner.
  static DesktopWindowPersistenceAdapter create() {
    if (kIsWeb) return _UnsupportedPersistence<Object>();
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => _MacOSWindowPersistence<Object>(),
      TargetPlatform.windows => _WindowsWindowPersistence(),
      TargetPlatform.linux => _LinuxWindowPersistence(),
      _ => _UnsupportedPersistence<Object>(),
    };
  }

  bool get supported;

  /// External record format; null when the native window owns storage.
  DesktopWindowStateFormat<T>? get stateFormat;
  bool get managesClose;

  /// Initializes and restores through this implementation's persistence mechanism.
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore<T>? store,
    Duration operationTimeout = const Duration(seconds: 2),
  });

  /// Saves through this implementation's persistence mechanism. Native requests
  /// must be bounded, but an in-flight store write must remain in the save queue.
  Future<void> flush(
    DesktopWindowStateStore<T>? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  });
  Future<void> dispose();
}

/// Explicit store-backed behavior shared by Win32 and GTK adapters.
/// A null capture means no ordinary frame is available, never a storage mode.
abstract class StoredWindowPersistenceAdapter<T extends Object>
    implements DesktopWindowPersistenceAdapter<T> {
  T? _lastSaved;

  @override
  bool get supported => true;
  @override
  DesktopWindowStateFormat<T> get stateFormat;
  @override
  bool get managesClose => true;

  /// Returns true only when this window can be restored before its first show.
  Future<bool> initializeWindow(String name, Size minimumSize);
  Future<void> restoreState(T state);
  Future<T?> captureState();

  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore<T>? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {
    final shouldRestore = await initializeWindow(
      name,
      minimumSize,
    ).timeout(operationTimeout);
    if (!shouldRestore) return;
    final state = store?.get();
    if (state != null) await restoreState(state).timeout(operationTimeout);
  }

  @override
  Future<void> flush(
    DesktopWindowStateStore<T>? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {
    if (store == null) return;
    final state = await captureState().timeout(operationTimeout);
    if (state == null || state == _lastSaved) return;
    // A timeout cannot cancel a store write. The controller keeps this future
    // in its serial queue; only close/dispose impose an overall wait deadline.
    if (!await store.set(state)) {
      throw StateError('Could not save window placement');
    }
    _lastSaved = state;
  }
}

class _MacOSWindowPersistence<T extends Object>
    implements DesktopWindowPersistenceAdapter<T> {
  final _host = WindowPersistenceHostApi();
  @override
  bool get supported => true;
  @override
  DesktopWindowStateFormat<T>? get stateFormat => null;
  @override
  bool get managesClose => false;
  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore<T>? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {
    // AppKit restores its saved frame as part of native initialization.
    await _host
        .initialize(name, minimumSize.width, minimumSize.height)
        .timeout(operationTimeout);
  }

  @override
  Future<void> flush(
    DesktopWindowStateStore<T>? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) => _host.flush().timeout(operationTimeout);
  @override
  Future<void> dispose() => _host.dispose();
}

class _WindowsWindowPersistence
    extends StoredWindowPersistenceAdapter<WindowsWindowState> {
  final _lifecycle = WindowPersistenceHostApi();
  final _host = WindowsWindowPersistenceHostApi();
  @override
  DesktopWindowStateFormat<WindowsWindowState> get stateFormat =>
      DesktopWindowStateFormat.windowsPlacement;
  @override
  Future<bool> initializeWindow(String name, Size minimumSize) =>
      _lifecycle.initialize(name, minimumSize.width, minimumSize.height);
  @override
  Future<void> restoreState(WindowsWindowState state) => _host.restore(state);
  @override
  Future<WindowsWindowState?> captureState() => _host.capture();
  @override
  Future<void> dispose() => _lifecycle.dispose();
}

class _LinuxWindowPersistence
    extends StoredWindowPersistenceAdapter<LinuxWindowState> {
  final _lifecycle = WindowPersistenceHostApi();
  final _host = LinuxWindowPersistenceHostApi();
  @override
  DesktopWindowStateFormat<LinuxWindowState> get stateFormat =>
      DesktopWindowStateFormat.gtkGeometry;
  @override
  Future<bool> initializeWindow(String name, Size minimumSize) =>
      _lifecycle.initialize(name, minimumSize.width, minimumSize.height);
  @override
  Future<void> restoreState(LinuxWindowState state) => _host.restore(state);
  @override
  Future<LinuxWindowState?> captureState() => _host.capture();
  @override
  Future<void> dispose() => _lifecycle.dispose();
}

class _UnsupportedPersistence<T extends Object>
    implements DesktopWindowPersistenceAdapter<T> {
  @override
  bool get supported => false;
  @override
  DesktopWindowStateFormat<T>? get stateFormat => null;
  @override
  bool get managesClose => false;
  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore<T>? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) => Future.value();
  @override
  Future<void> flush(
    DesktopWindowStateStore<T>? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) => Future.value();
  @override
  Future<void> dispose() async {}
}
