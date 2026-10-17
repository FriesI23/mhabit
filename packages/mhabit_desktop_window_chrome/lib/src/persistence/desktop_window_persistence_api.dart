import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'desktop_window_state_store.dart';
import 'window_persistence_api.g.dart';

/// Injectable platform persistence behavior. Only the factory selects a platform.
abstract interface class DesktopWindowPersistenceAdapter {
  /// Selects the native adapter without exposing platform branches to the owner.
  factory DesktopWindowPersistenceAdapter() {
    if (kIsWeb) return _UnsupportedPersistence();
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => _MacOSWindowPersistence(),
      TargetPlatform.windows => _WindowsWindowPersistence(),
      TargetPlatform.linux => _LinuxWindowPersistence(),
      _ => _UnsupportedPersistence(),
    };
  }

  bool get supported;

  /// External record format; null when the native window owns storage.
  DesktopWindowStateFormat? get stateFormat;
  bool get managesClose;

  /// Initializes and restores through this implementation's persistence mechanism.
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore? store,
    Duration operationTimeout = const Duration(seconds: 2),
  });

  /// Saves through this implementation's persistence mechanism. Native requests
  /// must be bounded, but an in-flight store write must remain in the save queue.
  Future<void> flush(
    DesktopWindowStateStore? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  });
  Future<void> dispose();
}

/// Explicit store-backed behavior shared by Win32 and GTK adapters.
/// A null capture means no ordinary frame is available, never a storage mode.
abstract class StoredWindowPersistenceAdapter
    implements DesktopWindowPersistenceAdapter {
  DesktopWindowState? _lastSaved;

  @override
  bool get supported => true;
  @override
  DesktopWindowStateFormat get stateFormat;
  @override
  bool get managesClose => true;

  /// Returns true only when this window can be restored before its first show.
  Future<bool> initializeWindow(String name, Size minimumSize);
  Future<void> restoreState(DesktopWindowState state);
  Future<DesktopWindowState?> captureState();

  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore? store,
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
    DesktopWindowStateStore? store, {
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

class _MacOSWindowPersistence implements DesktopWindowPersistenceAdapter {
  final _host = WindowPersistenceHostApi();
  @override
  bool get supported => true;
  @override
  DesktopWindowStateFormat? get stateFormat => null;
  @override
  bool get managesClose => false;
  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {
    // AppKit restores its saved frame as part of native initialization.
    await _host
        .initialize(name, minimumSize.width, minimumSize.height)
        .timeout(operationTimeout);
  }

  @override
  Future<void> flush(
    DesktopWindowStateStore? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) => _host.flush().timeout(operationTimeout);
  @override
  Future<void> dispose() => _host.dispose();
}

class _WindowsWindowPersistence extends StoredWindowPersistenceAdapter {
  final _host = WindowPersistenceHostApi();
  @override
  DesktopWindowStateFormat get stateFormat =>
      DesktopWindowStateFormat.windowsPlacement;
  @override
  Future<bool> initializeWindow(String name, Size minimumSize) =>
      _host.initialize(name, minimumSize.width, minimumSize.height);
  @override
  Future<void> restoreState(DesktopWindowState state) async {
    if (state is! WindowsWindowState) return;
    await _host.restore([
      state.left,
      state.top,
      state.width,
      state.height,
      state.dpi,
      state.monitorLeft,
      state.monitorTop,
      state.workWidth,
      state.workHeight,
    ]);
  }

  @override
  Future<WindowsWindowState?> captureState() async {
    final data = await _host.capture();
    if (data == null) return null;
    return WindowsWindowState(
      left: data[0],
      top: data[1],
      width: data[2],
      height: data[3],
      dpi: data[4],
      monitorLeft: data[5],
      monitorTop: data[6],
      workWidth: data[7],
      workHeight: data[8],
    );
  }

  @override
  Future<void> dispose() => _host.dispose();
}

class _LinuxWindowPersistence extends StoredWindowPersistenceAdapter {
  final _host = WindowPersistenceHostApi();
  @override
  DesktopWindowStateFormat get stateFormat =>
      DesktopWindowStateFormat.gtkGeometry;
  @override
  Future<bool> initializeWindow(String name, Size minimumSize) =>
      _host.initialize(name, minimumSize.width, minimumSize.height);
  @override
  Future<void> restoreState(DesktopWindowState state) async {
    if (state is! LinuxWindowState) return;
    // The native GTK adapter also checks the actual GDK display before moving.
    await _host.restore([
      state.width,
      state.height,
      if (state.position case final position?) ...[position.dx, position.dy],
    ]);
  }

  @override
  Future<LinuxWindowState?> captureState() async {
    final data = await _host.capture();
    if (data == null) return null;
    return LinuxWindowState(
      width: data[0],
      height: data[1],
      position: data.length == 4 ? Offset(data[2], data[3]) : null,
    );
  }

  @override
  Future<void> dispose() => _host.dispose();
}

class _UnsupportedPersistence implements DesktopWindowPersistenceAdapter {
  @override
  bool get supported => false;
  @override
  DesktopWindowStateFormat? get stateFormat => null;
  @override
  bool get managesClose => false;
  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) => Future.value();
  @override
  Future<void> flush(
    DesktopWindowStateStore? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) => Future.value();
  @override
  Future<void> dispose() async {}
}
