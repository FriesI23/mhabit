import 'dart:async';

import 'package:flutter/widgets.dart';

import 'desktop_window_chrome_api.dart';

/// One window owner. Native geometry is independent of direction and UI style.
class DesktopWindowChrome extends ChangeNotifier
    implements DesktopWindowChromeEvents {
  final DesktopWindowChromeApi _api;

  /// Optional product constraint on the ordinary window's outer frame, in
  /// logical pixels. Applied before fusion and retained across decoration changes.
  final Size? _minimumSize;

  /// Native-request and invalid-geometry deadline. The latter starts only after
  /// the Flutter viewport is attached; not-ready layout waits for notifications.
  final Duration _geometryTimeout;
  Future<void> _pending = Future.value();
  bool _disposed = false;
  bool _initialized = false;
  bool _available = true;
  bool _fullScreen = false;
  bool? _configuredFused;
  int _revision = 0;
  Timer? _invalidGeometryTimer;
  DesktopWindowChromeGeometry? _geometry;

  /// Uses the macOS adapter by default; [api] allows native-boundary test injection.
  DesktopWindowChrome({
    DesktopWindowChromeApi? api,
    this._minimumSize,
    this._geometryTimeout = const Duration(seconds: 2),
  }) : _api = api ?? DesktopWindowChromeApi() {
    if (_minimumSize != null && !_minimumSize.isValid) {
      throw ArgumentError.value(
        _minimumSize,
        'minimumSize',
        'Must be finite and positive',
      );
    }
  }

  bool get available => _available && _api.supported;
  bool get isFullScreen => _fullScreen;
  DesktopWindowChromeGeometry? get geometry => _geometry;

  /// Registers native events and queries layout once. Request failures disable
  /// fusion; a not-ready viewport can supply geometry through later notifications.
  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    if (!_api.supported) {
      _available = false;
      return;
    }
    await _enqueue(() async {
      await _api
          .initialize(this, minimumSize: _minimumSize)
          .timeout(_geometryTimeout);
      _fullScreen = await _api.isFullScreen().timeout(_geometryTimeout);
    });
    if (_available && !_disposed) await refresh();
  }

  /// Shows the initialized window after the app has rendered its first frame.
  /// Also shows standard decoration when fusion initialization has failed.
  Future<void> show() {
    if (!_initialized || !_api.supported || _disposed) return Future.value();
    return _enqueue(() => _api.show().timeout(_geometryTimeout));
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _pending = _pending.then((_) async {
      if (_disposed || !_api.supported) return;
      try {
        await action();
      } catch (error, stack) {
        debugPrint('Desktop window fusion unavailable: $error\n$stack');
        await _restoreStandard();
      }
    });
    return _pending;
  }

  Future<void> _restoreStandard() async {
    _available = false;
    _geometry = null;
    _invalidGeometryTimer?.cancel();
    _configuredFused = false;
    try {
      await _api.configure(fused: false).timeout(_geometryTimeout);
    } catch (_) {}
    if (!_disposed) notifyListeners();
  }

  /// Serializes native requests and discards results superseded by newer queries.
  /// Failures restore standard decoration and disable fusion.
  Future<void> refresh() {
    final revision = ++_revision;
    return _enqueue(() async {
      if (!_available) return;
      final fused = !_fullScreen;
      if (_configuredFused != fused) {
        await _api.configure(fused: fused).timeout(_geometryTimeout);
        if (_disposed || revision != _revision) return;
        _configuredFused = fused;
      }
      final geometry = await _api.geometry().timeout(_geometryTimeout);
      if (_disposed || revision != _revision) return;
      if (geometry.fullScreen && !_fullScreen) {
        _fullScreen = true;
        _configuredFused = false;
      }
      _updateGeometry(geometry);
      notifyListeners();
    });
  }

  /// Accepts usable snapshots, waits for attachment, or starts bounded recovery.
  void _updateGeometry(DesktopWindowChromeGeometry geometry) {
    if (geometry.isUsable(fullScreen: _fullScreen)) {
      _invalidGeometryTimer?.cancel();
      _invalidGeometryTimer = null;
      _geometry = geometry;
      return;
    }

    _geometry = null;
    // Not-ready means the Flutter view is not attached yet. Do not start a
    // deadline until AppKit says it has an actual viewport.
    if (!geometry.ready) {
      _invalidGeometryTimer?.cancel();
      _invalidGeometryTimer = null;
      return;
    }

    _invalidGeometryTimer ??= Timer(_geometryTimeout, () {
      unawaited(
        _enqueue(() async {
          // A valid query may finish while this deadline waits behind it.
          if (!_fullScreen && _geometry?.valid != true) {
            await _restoreStandard();
          }
        }),
      );
    });
  }

  @override
  void geometryChanged() {
    if (_initialized) unawaited(refresh());
  }

  @override
  void willEnterFullScreen() {
    _invalidGeometryTimer?.cancel();
    _invalidGeometryTimer = null;
    _fullScreen = true;
    _configuredFused = false; // Native hook already restored the style.
    _geometry = null;
    _revision++;
    if (!_disposed) notifyListeners();
  }

  @override
  void onWindowEnterFullScreen() => willEnterFullScreen();

  @override
  void onWindowLeaveFullScreen() {
    _fullScreen = false;
    unawaited(refresh());
  }

  /// Stops updates immediately; native cleanup follows outstanding queued work.
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _revision++;
    _invalidGeometryTimer?.cancel();
    // Wait for outstanding mutations before native cleanup; no operation can
    // change decoration again after dispose.
    unawaited(
      _pending
          .then((_) async {
            if (_initialized && _api.supported) await _api.dispose();
          })
          .catchError((Object error) {
            debugPrint('Desktop window cleanup failed: $error');
          }),
    );
    super.dispose();
  }
}

extension _WindowChromeSizeValidation on Size {
  /// Whether both dimensions are finite and strictly positive.
  bool get isValid => isFinite && !isEmpty;
}

extension _WindowChromeGeometryValidation on DesktopWindowChromeGeometry {
  /// Checks numeric bounds using the owner's current full-screen state.
  ///
  /// During full-screen entry, the owner may already suppress button avoidance
  /// while the queried snapshot still reports an ordinary window.
  bool isUsable({required bool fullScreen}) {
    if (!valid || !ready || !viewport.isValid) return false;
    return fullScreen ||
        buttons.every((button) => button.isValidWithin(viewport));
  }
}

extension _WindowChromeRectValidation on Rect {
  /// Checks for a finite, positive rectangle inside an already valid viewport.
  bool isValidWithin(Size viewport) =>
      left.isFinite &&
      top.isFinite &&
      size.isValid &&
      left >= 0 &&
      top >= 0 &&
      left + width <= viewport.width &&
      top + height <= viewport.height;
}
