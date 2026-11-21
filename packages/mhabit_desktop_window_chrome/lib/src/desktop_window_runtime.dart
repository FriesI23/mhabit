import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart' as native;

/// The main window operations shared by chrome and persistence owners.
///
/// Keeps nativeapi handles inside this package and lets tests replace native
/// calls without relying on the platform channel removed in window_manager 0.6.
abstract interface class DesktopWindowRuntime {
  static final DesktopWindowRuntime _native = NativeDesktopWindowRuntime();

  /// Replaces [instance] in tests; reset to `null` during teardown.
  @visibleForTesting
  static DesktopWindowRuntime? debugOverride;

  /// The shared runtime, or [debugOverride] when provided by a test.
  static DesktopWindowRuntime get instance => debugOverride ?? _native;

  /// Resolves the main window and attaches pending event listeners.
  ///
  /// Throws [StateError] if the runner has not provided a window yet.
  Future<void> ensureInitialized();

  /// Sets the minimum window [size] in logical pixels.
  Future<void> setMinimumSize(Size size);

  /// Restores the window if minimized, then makes it visible.
  Future<void> show();

  /// Requests keyboard focus for the main window.
  Future<void> focus();

  /// Returns whether the main window is currently visible.
  Future<bool> isVisible();

  /// Returns whether the main window currently has keyboard focus.
  Future<bool> isFocused();

  /// Returns whether the main window is currently in fullscreen mode.
  Future<bool> isFullScreen();

  /// Sets the title displayed by the native window.
  Future<void> setTitle(String title);

  /// Cancels native close requests while [prevent] is true.
  ///
  /// Listeners still receive [DesktopWindowListener.onWindowClose] after a veto.
  Future<void> setPreventClose(bool prevent);

  /// Requests a normal close, subject to [setPreventClose].
  Future<void> close();

  /// Clears this runtime's close prevention and requests a normal close.
  ///
  /// Window destruction and process termination remain owned by the runner.
  Future<void> destroy();

  /// Subscribes [listener] to main-window events until [removeListener] is called.
  void addListener(DesktopWindowListener listener);

  /// Stops delivering main-window events to [listener].
  void removeListener(DesktopWindowListener listener);
}

/// Events from the app's main window, without nativeapi message types.
abstract mixin class DesktopWindowListener {
  /// Called when the main window's native position changes.
  void onWindowMove() {}

  /// Called when the main window's native size changes.
  void onWindowResize() {}

  /// Called on close requests, including those cancelled by close prevention.
  void onWindowClose() {}

  /// Called after the main window enters fullscreen mode.
  void onWindowEnterFullScreen() {}

  /// Called after the main window leaves fullscreen mode.
  void onWindowLeaveFullScreen() {}
}

/// Uses the per-window native API introduced in window_manager 0.6.
class NativeDesktopWindowRuntime implements DesktopWindowRuntime {
  NativeDesktopWindowRuntime({native.Window? Function()? resolveWindow})
    : _resolveWindow =
          resolveWindow ?? native.WindowManager.instance.getCurrent;

  final native.Window? Function() _resolveWindow;
  final _listeners = <DesktopWindowListener>{};
  native.Window? _window;
  native.ListenerId? _listenerId;
  bool _preventClose = false;

  native.Window get _target => _window ??=
      _resolveWindow() ??
      (throw StateError('The desktop window is not available.'));

  @override
  Future<void> ensureInitialized() async {
    _target;
    _updateListener();
  }

  @override
  Future<void> setMinimumSize(Size size) async =>
      _target.minimumSize = size.toNative();

  @override
  Future<void> show() async {
    final window = _target;
    if (window.isMinimized) window.restore();
    window.show();
  }

  @override
  Future<void> focus() async => _target.focus();
  @override
  Future<bool> isVisible() async => _target.isVisible;
  @override
  Future<bool> isFocused() async => _target.isFocused;
  @override
  Future<bool> isFullScreen() async => _target.isFullScreen;
  @override
  Future<void> setTitle(String title) async => _target.title = title;

  @override
  Future<void> setPreventClose(bool prevent) async {
    _preventClose = prevent;
    _updateListener();
  }

  @override
  Future<void> close() async => _target.close();

  @override
  Future<void> destroy() async {
    // Native close remains runner-owned on every platform. In particular, do
    // not replace it with process termination when a bounded save fails.
    _preventClose = false;
    _updateListener();
    _target.close();
  }

  @override
  void addListener(DesktopWindowListener listener) {
    _listeners.add(listener);
    _updateListener();
  }

  @override
  void removeListener(DesktopWindowListener listener) {
    _listeners.remove(listener);
    _updateListener();
  }

  void _updateListener() {
    if (_listeners.isNotEmpty || _preventClose) {
      // Owners can subscribe after setup fails, before the runner has a window.
      // ensureInitialized retries this attachment before the eventual show.
      final window = _window ??= _resolveWindow();
      if (window == null) return;
      _listenerId ??= window.addListener(_onEvent);
    } else if (_listenerId case final id?) {
      _window?.removeListener(id);
      _listenerId = null;
    }
  }

  void _onEvent(native.WindowEvent event) {
    if (event.windowId != _window?.id) return;
    if (event is native.WindowCloseRequestedEvent && _preventClose) {
      // Veto before notifying the persistence owner, which saves asynchronously
      // and then requests a fresh native close with interception disabled.
      event.request.cancel();
    }
    for (final listener in List.of(_listeners)) {
      if (!_listeners.contains(listener)) continue;
      switch (event) {
        case native.WindowMovedEvent():
          listener.onWindowMove();
        case native.WindowResizedEvent():
          listener.onWindowResize();
        case native.WindowCloseRequestedEvent():
          listener.onWindowClose();
        case native.WindowEnteredFullScreenEvent():
          listener.onWindowEnterFullScreen();
        case native.WindowExitedFullScreenEvent():
          listener.onWindowLeaveFullScreen();
        default:
          break;
      }
    }
  }
}
