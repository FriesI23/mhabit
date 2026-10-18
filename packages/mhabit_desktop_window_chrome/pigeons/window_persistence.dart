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
/// Ordinary Win32 frame in workspace coordinates plus source monitor metadata.
class WindowsWindowState {
  WindowsWindowState({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.dpi,
    required this.monitorLeft,
    required this.monitorTop,
    required this.workWidth,
    required this.workHeight,
  });
  double left;
  double top;
  double width;
  double height;
  double dpi;
  double monitorLeft;
  double monitorTop;
  double workWidth;
  double workHeight;
}

/// Optional global position, available only on X11.
class LinuxWindowPosition {
  LinuxWindowPosition({required this.x, required this.y});
  double x;
  double y;
}

/// GTK logical dimensions. Wayland leaves position unset.
class LinuxWindowState {
  LinuxWindowState({required this.width, required this.height, this.position});
  double width;
  double height;
  LinuxWindowPosition? position;
}

@HostApi()
abstract class WindowPersistenceHostApi {
  /// Returns true only for a newly initialized, hidden native window.
  bool initialize(String name, double minimumWidth, double minimumHeight);

  /// Flushes AppKit's ordinary frame; other backends have no native storage.
  void flush();

  /// Detaches persistence observers without removing saved state.
  void dispose();
}

@HostApi()
abstract class WindowsWindowPersistenceHostApi {
  void restore(WindowsWindowState placement);
  WindowsWindowState? capture();
}

@HostApi()
abstract class LinuxWindowPersistenceHostApi {
  void restore(LinuxWindowState placement);
  LinuxWindowState? capture();
}
