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

/// Injectable native boundary for the independent native title bar.
abstract interface class DesktopWindowTitleBarApi {
  factory DesktopWindowTitleBarApi() => _NativeTitleBarApi();
  bool get supported;
  Future<void> initialize({Size? minimumSize});
  Future<bool> applyAppearance(DesktopTitleBarAppearance appearance);
  Future<void> setTitle(String title);
  Future<void> reset();
}

/// Serializes appearance changes while leaving all caption interaction native.
class DesktopWindowTitleBar implements DesktopTitleBarFlutterApi {
  DesktopWindowTitleBar({DesktopWindowTitleBarApi? api})
    : _api = api ?? DesktopWindowTitleBarApi();

  final DesktopWindowTitleBarApi _api;
  Future<void> _pending = Future.value();
  DesktopTitleBarAppearance? _requested;
  String? _requestedTitle;
  bool _initialized = false;
  bool _disposed = false;
  bool? _lastCustomColorsApplied;
  int _revision = 0;
  int _titleRevision = 0;
  final _foreground = ValueNotifier(false);
  bool _listeningForForeground = false;
  int _foregroundRevision = 0;

  bool get supported => _api.supported;

  /// Native Windows visibility and focus, for missing Flutter lifecycle state.
  /// Other platforms continue using the framework's lifecycle notifications.
  ValueListenable<bool>? get foreground =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows && supported
      ? _foreground
      : null;

  /// Runner keeps the window hidden until placement and the first frame exist.
  Future<void> show() async {
    if (_disposed || !supported) return;
    await windowManager.ensureInitialized();
    await windowManager.show();
    await windowManager.focus();
    await _refreshForeground();
  }

  /// Whether the last native response confirmed that custom colors were applied.
  /// Null until the first response; false also covers temporary conditions such
  /// as high contrast or an unavailable window, rather than platform capability.
  bool? get lastCustomColorsApplied => _lastCustomColorsApplied;

  Future<void> initialize({Size? minimumSize}) async {
    if (minimumSize != null && (!minimumSize.isFinite || minimumSize.isEmpty)) {
      throw ArgumentError.value(minimumSize, 'minimumSize');
    }
    if (_initialized || _disposed || !supported) return;
    if (foreground != null && !_listeningForForeground) {
      DesktopTitleBarFlutterApi.setUp(this);
      _listeningForForeground = true;
    }
    try {
      await _api
          .initialize(minimumSize: minimumSize)
          .timeout(const Duration(seconds: 2));
      if (_disposed) return;
      _initialized = true;
    } catch (error) {
      debugPrint('Native title bar initialization failed: $error');
    }
    await _refreshForeground();
  }

  @override
  void foregroundChanged(bool foreground) {
    if (_disposed || !_listeningForForeground) return;
    ++_foregroundRevision;
    _foreground.value = foreground;
  }

  Future<void> _refreshForeground() async {
    if (_disposed || !_listeningForForeground) return;
    final revision = ++_foregroundRevision;
    try {
      final visible = await windowManager.isVisible();
      if (_disposed || revision != _foregroundRevision) return;
      final focused = visible && await windowManager.isFocused();
      if (_disposed || revision != _foregroundRevision) return;
      _foreground.value = focused;
    } catch (_) {
      if (!_disposed && revision == _foregroundRevision) {
        _foreground.value = false;
      }
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
        _lastCustomColorsApplied = await _api
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

  /// Synchronizes the native title, including later application locale changes.
  Future<void> setTitle(String title) {
    if (!_initialized || _disposed || !supported || title == _requestedTitle) {
      return _pending;
    }
    _requestedTitle = title;
    final revision = ++_titleRevision;
    _pending = _pending.then((_) async {
      if (_disposed || revision != _titleRevision) return;
      try {
        await _api.setTitle(title).timeout(const Duration(seconds: 2));
      } catch (error) {
        if (revision == _titleRevision) _requestedTitle = null;
        debugPrint('Native window title unavailable: $error');
      }
    });
    return _pending;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_revision;
    ++_foregroundRevision;
    if (_listeningForForeground) {
      DesktopTitleBarFlutterApi.setUp(null);
      _listeningForForeground = false;
    }
    _foreground.value = false;
    _foreground.dispose();
    await _pending;
    if (!_initialized || !supported) return;
    try {
      await _api.reset().timeout(const Duration(seconds: 2));
    } catch (error) {
      debugPrint('Native title bar cleanup failed: $error');
    }
  }
}

class _NativeTitleBarApi implements DesktopWindowTitleBarApi {
  final _host = DesktopTitleBarHostApi();

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

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
  Future<void> setTitle(String title) => windowManager.setTitle(title);

  @override
  Future<void> reset() => _host.reset();
}
