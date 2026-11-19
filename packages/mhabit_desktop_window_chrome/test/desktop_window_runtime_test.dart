import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/src/desktop_window_runtime.dart';
import 'package:window_manager/window_manager.dart' as native;

class _Window implements native.Window {
  @override
  int get id => 7;
  @override
  bool isMinimized = false;
  @override
  bool isVisible = false;
  @override
  bool isFocused = false;
  @override
  bool isFullScreen = false;
  @override
  String title = '';
  Object? minimum;
  final calls = <String>[];
  FutureOr<void> Function(native.WindowEvent)? listener;

  @override
  set minimumSize(dynamic value) => minimum = value;

  @override
  void restore() {
    calls.add('restore');
    isMinimized = false;
  }

  @override
  void show() {
    calls.add('show');
    isVisible = true;
  }

  @override
  void focus() {
    calls.add('focus');
    isFocused = true;
  }

  @override
  bool close() {
    calls.add('close');
    return true;
  }

  @override
  int addListener(FutureOr<void> Function(native.WindowEvent) callback) {
    calls.add('listen');
    listener = callback;
    return 42;
  }

  @override
  bool removeListener(int id) {
    expect(id, 42);
    calls.add('unlisten');
    listener = null;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CloseRequest implements native.EventRequest {
  bool cancelled = false;

  @override
  bool cancel() => cancelled = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Listener with DesktopWindowListener {
  final events = <String>[];
  VoidCallback? closing;

  @override
  void onWindowResize() => events.add('resize');
  @override
  void onWindowEnterFullScreen() => events.add('enter');
  @override
  void onWindowLeaveFullScreen() => events.add('leave');
  @override
  void onWindowClose() => closing?.call();
}

void main() {
  test(
    'hidden main window is resolved once and restored before showing',
    () async {
      final window = _Window()..isMinimized = true;
      var resolutions = 0;
      final runtime = NativeDesktopWindowRuntime(
        resolveWindow: () {
          resolutions++;
          return window;
        },
      );

      await runtime.ensureInitialized();
      await runtime.setMinimumSize(const Size(350, 520));
      await runtime.setTitle('Table Habit');
      await runtime.show();
      await runtime.focus();

      expect(resolutions, 1);
      expect(window.title, 'Table Habit');
      final minimum = window.minimum as dynamic;
      expect((minimum.width, minimum.height), (350, 520));
      expect(window.calls, ['restore', 'show', 'focus']);
      expect(await runtime.isVisible(), isTrue);
      expect(await runtime.isFocused(), isTrue);
    },
  );

  test(
    'listeners attach when an unavailable window becomes ready on retry',
    () async {
      final window = _Window();
      var ready = false;
      final runtime = NativeDesktopWindowRuntime(
        resolveWindow: () => ready ? window : null,
      );
      final listener = _Listener();
      runtime.addListener(listener);
      await expectLater(runtime.ensureInitialized(), throwsStateError);
      expect(window.listener, isNull);
      ready = true;
      await runtime.ensureInitialized();
      await runtime.show();
      await window.listener!(
        const native.WindowEnteredFullScreenEvent(windowId: 7),
      );
      expect(listener.events, ['enter']);
      expect(window.calls, ['listen', 'show']);
      expect(window.isVisible, isTrue);
      runtime.removeListener(listener);
    },
  );

  test(
    'events belong to the main window and stop when the owner detaches',
    () async {
      final window = _Window();
      final runtime = NativeDesktopWindowRuntime(resolveWindow: () => window);
      final listener = _Listener();
      runtime.addListener(listener);
      await window.listener!(
        const native.WindowEnteredFullScreenEvent(windowId: 8),
      );
      await window.listener!(
        const native.WindowEnteredFullScreenEvent(windowId: 7),
      );
      await window.listener!(
        native.WindowResizedEvent(
          windowId: 7,
          newSize: native.SizeToNative(const Size(800, 600)).toNative(),
        ),
      );
      await window.listener!(
        const native.WindowExitedFullScreenEvent(windowId: 7),
      );
      expect(listener.events, ['enter', 'resize', 'leave']);
      runtime.removeListener(listener);
      expect(window.listener, isNull);
      expect(window.calls, ['listen', 'unlisten']);
    },
  );

  test(
    'close is cancelled before persistence and allowed after its save',
    () async {
      final window = _Window();
      final runtime = NativeDesktopWindowRuntime(resolveWindow: () => window);
      final first = _CloseRequest();
      final listener = _Listener()
        ..closing = () => expect(first.cancelled, isTrue);
      runtime.addListener(listener);
      await runtime.setPreventClose(true);
      await window.listener!(
        native.WindowCloseRequestedEvent(windowId: 7, request: first),
      );
      await runtime.setPreventClose(false);
      await runtime.close();
      final second = _CloseRequest();
      listener.closing = () => expect(second.cancelled, isFalse);
      await window.listener!(
        native.WindowCloseRequestedEvent(windowId: 7, request: second),
      );
      expect(window.calls, ['listen', 'close']);
      runtime.removeListener(listener);
    },
  );
}
