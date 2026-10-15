import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import 'desktop_title_bar_api.g.dart';

/// Resolved window-level colors. Page-local themes must not supply these.
@immutable
class DesktopTitleBarAppearance {
  const DesktopTitleBarAppearance({
    required this.background,
    required this.foreground,
    required this.brightness,
  });

  final Color background;
  final Color foreground;
  final Brightness brightness;

  @override
  bool operator ==(Object other) =>
      other is DesktopTitleBarAppearance &&
      background == other.background &&
      foreground == other.foreground &&
      brightness == other.brightness;

  @override
  int get hashCode => Object.hash(background, foreground, brightness);
}

/// Injectable native boundary for the independent Windows title bar.
abstract interface class DesktopWindowTitleBarApi {
  factory DesktopWindowTitleBarApi() => _WindowsTitleBarApi();
  bool get supported;
  Future<void> initialize({Size? minimumSize});
  Future<bool> applyAppearance(DesktopTitleBarAppearance appearance);
  Future<void> reset();
}

/// Serializes appearance changes while leaving all caption interaction native.
class DesktopWindowTitleBar {
  DesktopWindowTitleBar({DesktopWindowTitleBarApi? api})
    : _api = api ?? DesktopWindowTitleBarApi();

  final DesktopWindowTitleBarApi _api;
  Future<void> _pending = Future.value();
  DesktopTitleBarAppearance? _requested;
  bool _initialized = false;
  bool _disposed = false;
  bool? _customColorsSupported;
  int _revision = 0;

  bool get supported => _api.supported;
  bool? get customColorsSupported => _customColorsSupported;

  Future<void> initialize({Size? minimumSize}) async {
    if (minimumSize != null && (!minimumSize.isFinite || minimumSize.isEmpty)) {
      throw ArgumentError.value(minimumSize, 'minimumSize');
    }
    if (_initialized || _disposed || !supported) return;
    try {
      await _api
          .initialize(minimumSize: minimumSize)
          .timeout(const Duration(seconds: 2));
      _initialized = true;
    } catch (error) {
      debugPrint('Native title bar initialization failed: $error');
    }
  }

  Future<void> applyAppearance(DesktopTitleBarAppearance appearance) {
    if (!_initialized || _disposed || !supported || appearance == _requested) {
      return _pending;
    }
    _requested = appearance;
    final revision = ++_revision;
    _pending = _pending.then((_) async {
      if (_disposed || revision != _revision) return;
      try {
        _customColorsSupported = await _api
            .applyAppearance(appearance)
            .timeout(const Duration(seconds: 2));
      } catch (error) {
        if (revision == _revision) _requested = null;
        debugPrint('Native title bar colors unavailable: $error');
        try {
          await _api.reset().timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
    });
    return _pending;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_revision;
    await _pending;
    if (!_initialized || !supported) return;
    try {
      await _api.reset().timeout(const Duration(seconds: 2));
    } catch (error) {
      debugPrint('Native title bar cleanup failed: $error');
    }
  }
}

class _WindowsTitleBarApi implements DesktopWindowTitleBarApi {
  final _host = DesktopTitleBarHostApi();

  @override
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  Future<void> initialize({Size? minimumSize}) async {
    await windowManager.ensureInitialized();
    if (minimumSize != null) await windowManager.setMinimumSize(minimumSize);
  }

  @override
  Future<bool> applyAppearance(DesktopTitleBarAppearance appearance) =>
      _host.setAppearance(
        appearance.background.toARGB32(),
        appearance.foreground.toARGB32(),
        appearance.brightness == Brightness.dark,
      );

  @override
  Future<void> reset() => _host.reset();
}
