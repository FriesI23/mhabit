import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:mhabit_desktop_window_chrome/src/desktop_window_chrome_api.g.dart';

import 'support/expect_chrome_failure.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const packageChannel = MethodChannel('macos_window_utils/window_manipulator');
  const windowChannel = MethodChannel('window_manager');
  const prefix =
      'dev.flutter.pigeon.mhabit_desktop_window_chrome.DesktopChromeHostApi';
  const codec = DesktopChromeHostApi.pigeonChannelCodec;
  final calls = <String>[];
  Map<Object?, Object?>? minimumArguments;
  var failMinimum = false;
  var failConfiguration = false;
  Completer<void>? standardResize;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    calls.clear();
    minimumArguments = null;
    failMinimum = false;
    failConfiguration = false;
    standardResize = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(packageChannel, (
      call,
    ) async {
      calls.add(call.method);
      expect(call.method, 'initialize');
      expect(call.arguments, {'enableWindowDelegate': false});
      return null;
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(windowChannel, (
      call,
    ) async {
      calls.add(call.method);
      if (call.method == 'setMinimumSize') {
        minimumArguments = call.arguments as Map<Object?, Object?>;
        if (failMinimum) {
          throw PlatformException(code: 'minimum-failed');
        }
      }
      return call.method == 'isFullScreen' || call.method == 'isMinimized'
          ? false
          : null;
    });
    for (final method in ['configure', 'geometry', 'dispose']) {
      binding.defaultBinaryMessenger.setMockMessageHandler('$prefix.$method', (
        message,
      ) async {
        final args = codec.decodeMessage(message) as List<Object?>?;
        calls.add(method == 'configure' ? 'configure:${args!.first}' : method);
        if (method == 'configure' && args!.first == false) {
          await standardResize?.future;
        }
        if (method == 'configure' && failConfiguration) {
          failConfiguration = false;
          return codec.encodeMessage(['chrome-unavailable', null, null]);
        }
        return codec.encodeMessage([
          if (method == 'geometry')
            ChromeGeometry(
              ready: true,
              valid: true,
              fullScreen: false,
              width: 800,
              height: 600,
              buttons: [
                for (var i = 0; i < 3; i++)
                  ChromeRect(x: 20 + i * 20, y: 25, width: 14, height: 14),
              ],
            )
          else
            null,
        ]);
      });
    }
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      packageChannel,
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      windowChannel,
      null,
    );
    for (final method in ['configure', 'geometry', 'dispose']) {
      binding.defaultBinaryMessenger.setMockMessageHandler(
        '$prefix.$method',
        null,
      );
    }
  });

  Future<void> dispose(DesktopWindowChrome chrome) async {
    chrome.dispose();
    await Future<void>.delayed(Duration.zero);
  }

  test(
    'window manager receives the product minimum before fusion and show',
    () async {
      final chrome = DesktopWindowChrome(minimumSize: const Size(410, 620));
      addTearDown(() => dispose(chrome));
      await chrome.initialize();
      expect(minimumArguments!['width'], 410);
      expect(minimumArguments!['height'], 620);
      expect(calls, [
        'ensureInitialized',
        'initialize',
        'setMinimumSize',
        'isFullScreen',
        'configure:true',
        'geometry',
      ]);
      await chrome.initialize();
      expect(calls.where((call) => call == 'initialize'), hasLength(1));
      for (var i = 0; i < 3; i++) {
        chrome.geometryChanged();
        await chrome.refresh();
      }
      expect(calls.where((call) => call == 'setMinimumSize'), hasLength(1));
      await chrome.show();
      expect(calls.sublist(calls.length - 4), [
        'ensureInitialized',
        'isMinimized',
        'show',
        'focus',
      ]);
    },
  );

  test(
    'hot restart retains fusion without waiting for a standard resize',
    () async {
      // The native owner survives a Dart restart. Resetting its decoration before
      // runApp can wait for a resized frame that the new isolate cannot supply.
      standardResize = Completer<void>();
      addTearDown(() => standardResize!.complete());
      final chrome = DesktopWindowChrome(
        minimumSize: const Size(350, 520),
        geometryTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(() => dispose(chrome));
      await chrome.initialize();
      expect(chrome.available, isTrue);
      expect(chrome.geometry, isNotNull);
      expect(minimumArguments!['width'], 350);
      expect(minimumArguments!['height'], 520);
      expect(calls, isNot(contains('configure:false')));
      expect(calls, contains('configure:true'));
    },
  );

  test(
    'minimum initialization failure still shows a standard window',
    () async {
      failMinimum = true;
      final chrome = DesktopWindowChrome(minimumSize: const Size(410, 620));
      addTearDown(() => dispose(chrome));
      await expectChromeFailure(
        chrome.initialize,
        'PlatformException(minimum-failed, null, null, null)',
      );
      expect(chrome.available, isFalse);
      expect(calls, isNot(contains('configure:true')));
      expect(calls.last, 'configure:false');
      await chrome.show();
      expect(calls.sublist(calls.length - 4), [
        'ensureInitialized',
        'isMinimized',
        'show',
        'focus',
      ]);
    },
  );
  test(
    'chrome failure does not skip the independent window constraint',
    () async {
      failConfiguration = true;
      final chrome = DesktopWindowChrome(minimumSize: const Size(410, 620));
      addTearDown(() => dispose(chrome));
      await expectChromeFailure(
        chrome.initialize,
        'PlatformException(chrome-unavailable, null, null, null)',
      );
      expect(chrome.available, isFalse);
      expect(minimumArguments!['width'], 410);
      expect(minimumArguments!['height'], 620);
      expect(calls, contains('configure:true'));
      expect(calls.last, 'configure:false');
      await chrome.show();
      expect(calls, contains('show'));
    },
  );
}
