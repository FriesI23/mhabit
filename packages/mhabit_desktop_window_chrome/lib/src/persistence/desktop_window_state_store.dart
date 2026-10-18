import 'dart:convert';

import 'window_persistence_api.g.dart';

export 'window_persistence_api.g.dart'
    show LinuxWindowPosition, LinuxWindowState, WindowsWindowState;

/// A typed codec for the existing local preference record. The same generated
/// state travels between this store and Pigeon without a second model.
enum DesktopWindowStateFormat<T extends Object> {
  windowsPlacement<WindowsWindowState>(
    'desktop.window.windows.v1',
    _decodeWindows,
    _encodeWindows,
  ),
  gtkGeometry<LinuxWindowState>(
    'desktop.window.linux.v1',
    _decodeLinux,
    _encodeLinux,
  );

  const DesktopWindowStateFormat(this._key, this._decode, this._encode);

  final String _key;
  final T? Function(Map<String, Object?> fields) _decode;
  final Map<String, double> Function(T state) _encode;

  /// Retains the concrete platform type when selected through a platform factory.
  DesktopWindowStateStore<T> createStore({
    required String? Function(String key) read,
    required Future<bool> Function(String key, String value) write,
  }) => DesktopWindowStateStore<T>(format: this, read: read, write: write);
}

abstract interface class DesktopWindowStateStore<T extends Object> {
  factory DesktopWindowStateStore({
    required DesktopWindowStateFormat<T>? format,
    required String? Function(String key) read,
    required Future<bool> Function(String key, String value) write,
  }) = _PreferencesWindowStateStore<T>;

  T? get();
  Future<bool> set(T state);
}

class _PreferencesWindowStateStore<T extends Object>
    implements DesktopWindowStateStore<T> {
  _PreferencesWindowStateStore({
    required this._format,
    required this._read,
    required this._write,
  });

  final DesktopWindowStateFormat<T>? _format;
  final String? Function(String key) _read;
  final Future<bool> Function(String key, String value) _write;

  @override
  T? get() {
    final format = _format;
    if (format == null) return null;
    final record = _read(format._key);
    if (record == null) return null;
    try {
      final value = jsonDecode(record);
      if (value is! Map<String, Object?> || value['version'] != 1) return null;
      return format._decode(value);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<bool> set(T state) {
    final format = _format;
    if (format == null) return Future.value(false);
    final fields = format._encode(state);
    if (fields.values.any((value) => !value.isFinite) ||
        fields['width']! <= 0 ||
        fields['height']! <= 0 ||
        (fields['dpi'] ?? 1) <= 0 ||
        (fields['workWidth'] ?? 1) <= 0 ||
        (fields['workHeight'] ?? 1) <= 0) {
      return Future.value(false);
    }
    return _write(format._key, jsonEncode({'version': 1, ...fields}));
  }
}

WindowsWindowState? _decodeWindows(Map<String, Object?> value) {
  final left = _number(value['left']);
  final top = _number(value['top']);
  final width = _number(value['width']);
  final height = _number(value['height']);
  final dpi = _number(value['dpi']);
  final monitorLeft = _number(value['monitorLeft']);
  final monitorTop = _number(value['monitorTop']);
  final workWidth = _number(value['workWidth']);
  final workHeight = _number(value['workHeight']);
  if (left == null ||
      top == null ||
      width == null ||
      width <= 0 ||
      height == null ||
      height <= 0 ||
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
}

Map<String, double> _encodeWindows(WindowsWindowState state) => {
  'left': state.left,
  'top': state.top,
  'width': state.width,
  'height': state.height,
  'dpi': state.dpi,
  'monitorLeft': state.monitorLeft,
  'monitorTop': state.monitorTop,
  'workWidth': state.workWidth,
  'workHeight': state.workHeight,
};

LinuxWindowState? _decodeLinux(Map<String, Object?> value) {
  final width = _number(value['width']);
  final height = _number(value['height']);
  if (width == null || width <= 0 || height == null || height <= 0) return null;
  final x = _number(value['x']);
  final y = _number(value['y']);
  return LinuxWindowState(
    width: width,
    height: height,
    position: x != null && y != null ? LinuxWindowPosition(x: x, y: y) : null,
  );
}

Map<String, double> _encodeLinux(LinuxWindowState state) => {
  'width': state.width,
  'height': state.height,
  if (state.position case final position?) 'x': position.x,
  if (state.position case final position?) 'y': position.y,
};

double? _number(Object? value) =>
    value is num && value.isFinite ? value.toDouble() : null;
