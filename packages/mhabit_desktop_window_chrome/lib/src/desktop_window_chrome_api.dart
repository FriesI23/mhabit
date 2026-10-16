import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:window_manager/window_manager.dart';

import 'desktop_window_chrome_api.g.dart';

/// Receives platform-independent window state and geometry notifications.
///
/// Passed to [DesktopWindowChromeApi.initialize] by the window owner. Callbacks
/// request geometry refreshes or report transitions; they carry no native or
/// generated message types, so test implementations can emit the same events.
abstract interface class DesktopWindowChromeEvents {
  /// Requests a geometry query after viewport or native control layout changes.
  void geometryChanged();

  /// Reports full-screen entry before the system animation completes.
  ///
  /// On macOS, native decoration has already been restored. The owner should
  /// clear ordinary-window avoidance and interaction forwarding immediately.
  void willEnterFullScreen();

  /// Reports full-screen entry through the window-management listener.
  ///
  /// May follow [willEnterFullScreen] for the same transition.
  void onWindowEnterFullScreen();

  /// Reports full-screen exit so ordinary-window fusion can be restored.
  void onWindowLeaveFullScreen();
}

/// Controls native window chrome without exposing platform message types.
///
/// One window owner should initialize the instance once, serialize requests,
/// and dispose it after outstanding work finishes. This API does not provide
/// controller-level timeouts, geometry validation, or failure recovery.
///
/// Check [supported] before calling any operation. When it is false, every
/// operation, including [dispose], completes with an [UnsupportedError]. When
/// it is true, native calls can still fail if the bridge or window is unavailable.
abstract interface class DesktopWindowChromeApi {
  /// Creates the implementation for the current Flutter target platform.
  ///
  /// Currently supports native macOS only. Other platforms, including web,
  /// return an instance with [supported] set to false without opening channels.
  factory DesktopWindowChromeApi() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS
      ? _MacOSWindowChromeApi()
      : _UnsupportedWindowChromeApi();

  /// Whether this implementation supports native chrome on the target platform.
  ///
  /// This is a capability check, not confirmation of successful initialization
  /// or usable geometry. It can be read before [initialize] and after [dispose].
  bool get supported;

  /// Registers [events] and initializes window management before fusion.
  ///
  /// If supplied, [minimumSize] constrains the ordinary window's outer frame in
  /// logical pixels. The owner must validate that both dimensions are finite
  /// and positive. macOS applies the outer-frame constraint directly; an
  /// existing fused window keeps its decoration across Dart hot restarts.
  ///
  /// Does not show the window or enable fusion. A supported implementation can
  /// still fail during native setup; the owner handles that failure.
  Future<void> initialize(
    DesktopWindowChromeEvents events, {
    Size? minimumSize,
  });

  /// Shows and focuses the window after Flutter has rendered its first frame.
  ///
  /// On macOS, retries window-manager initialization so a standard window can
  /// still be shown after chrome initialization fails. Does not enable fusion.
  Future<void> show();

  /// Queries the window manager's current full-screen state.
  ///
  /// During entry, [DesktopWindowChromeGeometry.fullScreen] may become true
  /// earlier because it also includes the native transition.
  Future<bool> isFullScreen();

  /// Enables ordinary-window fusion when [fused] is true.
  ///
  /// Passing false restores standard system decoration. Full-screen windows
  /// and entry transitions retain system decoration even when true is requested.
  Future<void> configure({required bool fused});

  /// Queries viewport-relative geometry without changing the window layout.
  ///
  /// The result can be not ready or invalid; the owner must check both flags
  /// and validate its numeric bounds before using it. Coordinates are measured
  /// from the attached Flutter view.
  Future<DesktopWindowChromeGeometry> geometry();

  /// Removes layout changes, listeners, and handlers.
  ///
  /// Call after outstanding requests finish and do not reuse the instance.
  /// Does not close the window or replace its system delegate.
  Future<void> dispose();
}

/// An immutable native layout snapshot in Flutter viewport coordinates.
///
/// All dimensions and rectangles use logical pixels with the origin at the
/// viewport's physical top-left, x increasing rightward and y downward:
///
/// ```text
/// (0, 0) +--------------------------------+ --> x
///        | +--+ +--+ +--+                 |
///        | |  | |  | |  | native buttons  |
///        | +--+ +--+ +--+                 |
///        |                                |
///        |         Flutter content        | viewport.height
///        |                                |
///      y v--------------------------------+
///                  viewport.width
/// ```
///
/// The drawing illustrates an ordinary macOS window. Button placement is
/// platform-specific. Physical edges stay fixed in RTL layouts; do not mirror
/// rectangles or apply backing scale to their logical coordinates.
@immutable
final class DesktopWindowChromeGeometry {
  /// Whether Flutter is attached to its window with a nonempty viewport.
  final bool ready;

  /// Whether the native implementation considers the snapshot usable.
  ///
  /// Validity rules are platform-specific. macOS requires three usable buttons
  /// in an ordinary window, but other platforms need not use that rule. The
  /// owner must still check [ready] and validate numeric values and bounds.
  final bool valid;

  /// Whether the window is full screen or entering full screen.
  ///
  /// Ordinary-window avoidance and interaction forwarding should be disabled
  /// throughout that state, including the entry animation.
  final bool fullScreen;

  /// The Flutter viewport's size in logical pixels, excluding the outer frame.
  final Size viewport;

  /// An unmodifiable list of visible native button rectangles.
  ///
  /// Rectangles use the viewport's physical edges in logical pixels. Their
  /// count and placement are platform-specific and remain unchanged by RTL.
  final List<Rect> buttons;

  /// Creates a snapshot, taking an unmodifiable defensive copy of [buttons].
  ///
  /// Preserves the supplied flags and values without validating them. This
  /// allows not-ready or invalid native snapshots to reach the window owner.
  DesktopWindowChromeGeometry({
    required this.ready,
    required this.valid,
    required this.fullScreen,
    required this.viewport,
    required List<Rect> buttons,
  }) : buttons = List.unmodifiable(buttons);
}

class _MacOSWindowChromeApi
    with WindowListener
    implements DesktopWindowChromeApi, DesktopChromeFlutterApi {
  static Future<void>? _packageInitialization;
  final DesktopChromeHostApi _host = DesktopChromeHostApi();
  DesktopWindowChromeEvents? _events;

  @override
  bool get supported => true;

  @override
  Future<void> initialize(
    DesktopWindowChromeEvents events, {
    Size? minimumSize,
  }) async {
    if (_events != null) return;
    _events = events;
    DesktopChromeFlutterApi.setUp(this);
    await windowManager.ensureInitialized();
    try {
      await (_packageInitialization ??= WindowManipulator.initialize(
        enableWindowDelegate: false,
      ));
    } finally {
      // Package/bridge failure must still retain the app's standard-window size.
      if (minimumSize != null) await windowManager.setMinimumSize(minimumSize);
    }
    windowManager.addListener(this);
  }

  @override
  Future<void> show() async {
    // Initialization may have failed before window_manager was ready. Retry its
    // idempotent setup so the standard-window fallback can still be displayed.
    await windowManager.ensureInitialized();
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Future<bool> isFullScreen() => windowManager.isFullScreen();

  @override
  Future<void> configure({required bool fused}) => _host.configure(fused);

  @override
  Future<DesktopWindowChromeGeometry> geometry() async {
    final wire = await _host.geometry();
    return DesktopWindowChromeGeometry(
      ready: wire.ready,
      valid: wire.valid && (wire.fullScreen || wire.buttons.length == 3),
      fullScreen: wire.fullScreen,
      viewport: Size(wire.width, wire.height),
      buttons: [
        for (final b in wire.buttons)
          Rect.fromLTWH(b.x, b.y, b.width, b.height),
      ],
    );
  }

  @override
  void geometryChanged() => _events?.geometryChanged();
  @override
  void willEnterFullScreen() => _events?.willEnterFullScreen();
  @override
  void onWindowEnterFullScreen() => _events?.onWindowEnterFullScreen();
  @override
  void onWindowLeaveFullScreen() => _events?.onWindowLeaveFullScreen();

  @override
  Future<void> dispose() async {
    _events = null;
    windowManager.removeListener(this);
    DesktopChromeFlutterApi.setUp(null);
    await _host.dispose();
  }
}

class _UnsupportedWindowChromeApi implements DesktopWindowChromeApi {
  @override
  bool get supported => false;
  @override
  Future<void> initialize(
    DesktopWindowChromeEvents events, {
    Size? minimumSize,
  }) async => throw UnsupportedError('Desktop window chrome is not supported.');
  @override
  Future<void> show() async =>
      throw UnsupportedError('Desktop window chrome is not supported.');
  @override
  Future<bool> isFullScreen() async =>
      throw UnsupportedError('Desktop window chrome is not supported.');
  @override
  Future<void> configure({required bool fused}) async =>
      throw UnsupportedError('Desktop window chrome is not supported.');
  @override
  Future<DesktopWindowChromeGeometry> geometry() async =>
      throw UnsupportedError('Desktop window chrome is not supported.');
  @override
  Future<void> dispose() async =>
      throw UnsupportedError('Desktop window chrome is not supported.');
}
