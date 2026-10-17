import 'package:pigeon/pigeon.dart';

/// Internal transport only. Placement coordinates remain in each native
/// backend's units; they must never be applied through Flutter setBounds.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/persistence/window_persistence_api.g.dart',
    swiftOut:
        'macos/mhabit_desktop_window_chrome/Sources/mhabit_desktop_window_chrome/WindowPersistence.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'WindowPersistenceError'),
    cppHeaderOut: 'windows/window_persistence.g.h',
    cppSourceOut: 'windows/window_persistence.g.cpp',
    cppOptions: CppOptions(namespace: 'mhabit_window_persistence'),
    gobjectHeaderOut: 'linux/window_persistence.g.h',
    gobjectSourceOut: 'linux/window_persistence.g.cc',
    gobjectOptions: GObjectOptions(module: 'MhabitPersistence'),
    dartPackageName: 'mhabit_desktop_window_chrome',
  ),
)
@HostApi()
abstract class WindowPersistenceHostApi {
  /// Returns true only for a newly initialized, hidden native window.
  bool initialize(String name, double minimumWidth, double minimumHeight);

  /// Windows: normal rect, DPI, monitor work area (9 values).
  /// GTK: width, height, optional X11 position (2 or 4 values).
  /// macOS restores its AppKit autosave during initialize.
  void restore(List<double> placement);

  /// Latest ordinary frame; transient/maximized/fullscreen geometry is never
  /// returned. Null if unavailable. Adapters may retain the last ordinary frame.
  List<double>? capture();

  /// Flushes AppKit's ordinary frame; other backends have no native storage.
  void flush();

  /// Detaches persistence observers without removing saved state.
  void dispose();
}
