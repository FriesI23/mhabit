import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Offset;

/// Native geometry, deliberately separate from Flutter window bounds.
@immutable
sealed class DesktopWindowState {
  const DesktopWindowState();
}

/// Win32 workspace coordinates and the source monitor's DPI/work area.
final class WindowsWindowState extends DesktopWindowState {
  const WindowsWindowState({
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

  final double left;
  final double top;
  final double width;
  final double height;
  final double dpi;
  final double monitorLeft;
  final double monitorTop;
  final double workWidth;
  final double workHeight;

  Object get _values => (
    left,
    top,
    width,
    height,
    dpi,
    monitorLeft,
    monitorTop,
    workWidth,
    workHeight,
  );

  @override
  bool operator ==(Object other) =>
      other is WindowsWindowState && other._values == _values;
  @override
  int get hashCode => _values.hashCode;
}

/// GTK dimensions with an optional X11 position. Wayland has no position.
final class LinuxWindowState extends DesktopWindowState {
  const LinuxWindowState({
    required this.width,
    required this.height,
    this.position,
  });

  final double width;
  final double height;
  final Offset? position;

  @override
  bool operator ==(Object other) =>
      other is LinuxWindowState &&
      (other.width, other.height, other.position) == (width, height, position);
  @override
  int get hashCode => Object.hash(width, height, position);
}

/// The adapter chooses a record format; the store owns its key and encoding.
enum DesktopWindowStateFormat {
  windowsPlacement('desktop.window.windows.v1'),
  gtkGeometry('desktop.window.linux.v1');

  const DesktopWindowStateFormat(this._key);
  final String _key;
}

/// Semantic window storage independent of the application's preference backend.
abstract interface class DesktopWindowStateStore {
  /// Binds a native record format to an initialized preference cache.
  /// A null format is used when the native window owns persistence (AppKit).
  factory DesktopWindowStateStore({
    required DesktopWindowStateFormat? format,
    required String? Function(String key) read,
    required Future<bool> Function(String key, String value) write,
  }) = _PreferencesWindowStateStore;

  /// Reads and constructs a state synchronously; corrupt records return null.
  DesktopWindowState? get();

  /// Completes with false or throws if the state could not be saved.
  Future<bool> set(DesktopWindowState state);
}

class _PreferencesWindowStateStore implements DesktopWindowStateStore {
  _PreferencesWindowStateStore({
    required this._format,
    required this._read,
    required this._write,
  });

  final DesktopWindowStateFormat? _format;
  final String? Function(String key) _read;
  final Future<bool> Function(String key, String value) _write;

  @override
  DesktopWindowState? get() {
    final format = _format;
    if (format == null) return null;
    final record = _read(format._key);
    if (record == null) return null;
    try {
      final value = jsonDecode(record);
      if (value is! Map || value['version'] != 1) return null;
      final width = _number(value['width']);
      final height = _number(value['height']);
      if (width == null || height == null || width <= 0 || height <= 0) {
        return null;
      }
      switch (format) {
        case DesktopWindowStateFormat.windowsPlacement:
          final left = _number(value['left']);
          final top = _number(value['top']);
          final dpi = _number(value['dpi']);
          final monitorLeft = _number(value['monitorLeft']);
          final monitorTop = _number(value['monitorTop']);
          final workWidth = _number(value['workWidth']);
          final workHeight = _number(value['workHeight']);
          if (left == null ||
              top == null ||
              dpi == null ||
              dpi <= 0 ||
              monitorLeft == null ||
              monitorTop == null ||
              workWidth == null ||
              workWidth <= 0 ||
              workHeight == null ||
              workHeight <= 0) {
            return null;
          }
          return WindowsWindowState(
            left: left,
            top: top,
            width: width,
            height: height,
            dpi: dpi,
            monitorLeft: monitorLeft,
            monitorTop: monitorTop,
            workWidth: workWidth,
            workHeight: workHeight,
          );
        case DesktopWindowStateFormat.gtkGeometry:
          final x = _number(value['x']);
          final y = _number(value['y']);
          return LinuxWindowState(
            width: width,
            height: height,
            position: x != null && y != null ? Offset(x, y) : null,
          );
      }
    } on FormatException {
      return null;
    }
  }

  @override
  Future<bool> set(DesktopWindowState state) {
    final format = _format;
    final Map<String, double> fields;
    switch ((format, state)) {
      case (
        DesktopWindowStateFormat.windowsPlacement,
        final WindowsWindowState placement,
      ):
        if (placement.dpi <= 0 ||
            placement.workWidth <= 0 ||
            placement.workHeight <= 0) {
          return Future.value(false);
        }
        fields = {
          'left': placement.left,
          'top': placement.top,
          'width': placement.width,
          'height': placement.height,
          'dpi': placement.dpi,
          'monitorLeft': placement.monitorLeft,
          'monitorTop': placement.monitorTop,
          'workWidth': placement.workWidth,
          'workHeight': placement.workHeight,
        };
      case (
        DesktopWindowStateFormat.gtkGeometry,
        final LinuxWindowState placement,
      ):
        fields = {
          'width': placement.width,
          'height': placement.height,
          if (placement.position case final position?) ...{
            'x': position.dx,
            'y': position.dy,
          },
        };
      default:
        return Future.value(false);
    }
    if (fields['width']! <= 0 ||
        fields['height']! <= 0 ||
        fields.values.any((value) => !value.isFinite)) {
      return Future.value(false);
    }
    return _write(format!._key, jsonEncode({'version': 1, ...fields}));
  }
}

double? _number(Object? value) =>
    value is num && value.isFinite ? value.toDouble() : null;
