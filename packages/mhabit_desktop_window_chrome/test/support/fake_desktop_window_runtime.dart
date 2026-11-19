import 'package:flutter/services.dart';
import 'package:mhabit_desktop_window_chrome/src/desktop_window_runtime.dart';

/// Records the existing owners' operations without opening an FFI window.
class FakeDesktopWindowRuntime implements DesktopWindowRuntime {
  FakeDesktopWindowRuntime([this.onCall]);

  Future<Object?> Function(MethodCall)? onCall;
  final listeners = <DesktopWindowListener>{};

  Future<Object?> _call(String method, [Object? arguments]) async =>
      onCall?.call(MethodCall(method, arguments));

  @override
  Future<void> ensureInitialized() async => _call('ensureInitialized');
  @override
  Future<void> setMinimumSize(Size size) async =>
      _call('setMinimumSize', {'width': size.width, 'height': size.height});
  @override
  Future<void> show() async {
    if (await _call('isMinimized') == true) await _call('restore');
    await _call('show');
  }

  @override
  Future<void> focus() async => _call('focus');
  @override
  Future<bool> isVisible() async => await _call('isVisible') == true;
  @override
  Future<bool> isFocused() async => await _call('isFocused') == true;
  @override
  Future<bool> isFullScreen() async => await _call('isFullScreen') == true;
  @override
  Future<void> setTitle(String title) async =>
      _call('setTitle', {'title': title});
  @override
  Future<void> setPreventClose(bool prevent) async =>
      _call('setPreventClose', {'isPreventClose': prevent});
  @override
  Future<void> close() async => _call('close');
  @override
  Future<void> destroy() async => _call('destroy');
  @override
  void addListener(DesktopWindowListener listener) => listeners.add(listener);
  @override
  void removeListener(DesktopWindowListener listener) =>
      listeners.remove(listener);
}
