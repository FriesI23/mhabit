import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

import 'support/expect_chrome_failure.dart';
import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final platform in TargetPlatform.values.where(
    (p) => p != TargetPlatform.macOS,
  )) {
    test('$platform default adapter never calls native channels', () async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final chrome = DesktopWindowChrome(minimumSize: const Size(410, 620));
      await chrome.initialize();
      await chrome.show();
      await chrome.refresh();
      expect(chrome.available, isFalse);
      expect(chrome.geometry, isNull);
      chrome.dispose();
      await Future<void>.delayed(Duration.zero);
    });
  }

  test(
    'product minimum is initialized once and show stops after disposal',
    () async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(
        api: api,
        minimumSize: const Size(410, 620),
      );
      await chrome.show();
      expect(api.showCount, 0);
      await chrome.initialize();
      await chrome.initialize();
      expect(api.initializationCount, 1);
      expect(api.minimumSize, const Size(410, 620));
      await chrome.show();
      expect(api.showCount, 1);
      chrome.dispose();
      await chrome.show();
      expect(api.showCount, 1);
      await Future<void>.delayed(Duration.zero);
    },
  );

  test('invalid product minimum is rejected before native initialization', () {
    final api = FakeDesktopWindowChromeApi();
    for (final size in [
      Size.zero,
      const Size(-1, 520),
      const Size(350, double.infinity),
      const Size(double.nan, 520),
    ]) {
      expect(
        () => DesktopWindowChrome(api: api, minimumSize: size),
        throwsArgumentError,
      );
    }
    expect(api.initializationCount, 0);
  });

  test(
    'unsupported adapter never initializes or configures a window',
    () async {
      final api = FakeDesktopWindowChromeApi()..supported = false;
      final chrome = DesktopWindowChrome(api: api);
      await chrome.initialize();
      await chrome.refresh();
      await chrome.refresh();
      expect(chrome.available, isFalse);
      expect(chrome.geometry, isNull);
      expect(api.initializationCount, 0);
      expect(api.configurations, isEmpty);
      chrome.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(api.disposalCount, 0);
    },
  );

  test(
    'geometry keeps an immutable defensive copy and has no button count rule',
    () async {
      final buttons = [const Rect.fromLTWH(700, 0, 40, 32)];
      final api = FakeDesktopWindowChromeApi()
        ..snapshot = snapshotGeometry(buttons: buttons);
      buttons.clear();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      expect(chrome.geometry!.buttons, [const Rect.fromLTWH(700, 0, 40, 32)]);
      expect(() => chrome.geometry!.buttons.clear(), throwsUnsupportedError);
    },
  );

  test('fixed decoration changes only on fullscreen or failure', () async {
    final api = FakeDesktopWindowChromeApi();
    final chrome = DesktopWindowChrome(api: api);
    addTearDown(chrome.dispose);
    await chrome.initialize();
    for (final size in [const Size(350, 520), const Size(800, 600)]) {
      api.snapshot = snapshotGeometry(width: size.width, height: size.height);
      api.events!.geometryChanged();
      await chrome.refresh();
    }
    expect(api.configurations, [true]);
    chrome.willEnterFullScreen();
    chrome.onWindowLeaveFullScreen();
    // Let the exit notification's queued refresh finish without superseding it
    // with a second query while configuration is still in flight.
    await Future<void>.delayed(Duration.zero);
    expect(api.configurations, [true, true]);
    api.failGeometry = true;
    await expectChromeFailure(chrome.refresh, 'Bad state: query failed');
    expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
    expect(api.configurations.last, isFalse);
  });

  test(
    'not ready waits for native notification, ready invalid has deadline',
    () async {
      final api = FakeDesktopWindowChromeApi()
        ..snapshot = snapshotGeometry(ready: false, valid: false);
      final chrome = DesktopWindowChrome(
        api: api,
        geometryTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(api.configurations, [true]);
      expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
      api.snapshot = snapshotGeometry();
      api.events!.geometryChanged();
      await chrome.refresh();
      expect(chrome.geometry!.buttons.last.right, 61);
      api.snapshot = snapshotGeometry(valid: false);
      await chrome.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
      expect(api.configurations.last, isFalse);
      await chrome.show();
      expect(api.showCount, 1);
    },
  );

  test(
    'invalid viewport and button bounds clear geometry and recover before deadline',
    () async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      for (final invalid in [
        snapshotGeometry(width: 0),
        snapshotGeometry(width: double.nan),
        snapshotGeometry(height: double.infinity),
        snapshotGeometry(buttons: const [Rect.fromLTWH(7, -2, 14, 14)]),
      ]) {
        api.snapshot = invalid;
        await chrome.refresh();
        expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
      }
      api.snapshot = snapshotGeometry();
      await chrome.refresh();
      expect(chrome.geometry!.buttons.last.right, 61);
    },
  );

  test(
    'initialization failure restores native standard chrome with no Flutter reservation',
    () async {
      final api = FakeDesktopWindowChromeApi()..failInitialize = true;
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await expectChromeFailure(
        chrome.initialize,
        'Bad state: plugin unavailable',
      );
      expect(chrome.geometry, isNull);
      expect(api.configurations, [false]);
    },
  );

  test('bounded query timeout restores native style', () async {
    final api = FakeDesktopWindowChromeApi()..request = Completer();
    final chrome = DesktopWindowChrome(
      api: api,
      geometryTimeout: const Duration(milliseconds: 20),
    );
    addTearDown(chrome.dispose);
    await expectChromeFailure(
      chrome.initialize,
      'TimeoutException after 0:00:00.020000: Future not completed',
    );
    expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
    expect(api.configurations, [true, false]);
    api.request!.complete(snapshotGeometry());
  });

  test('outdated query cannot replace newer snapshot', () async {
    final api = FakeDesktopWindowChromeApi();
    final chrome = DesktopWindowChrome(api: api);
    addTearDown(chrome.dispose);
    await chrome.initialize();
    final stale = Completer<DesktopWindowChromeGeometry>();
    api.request = stale;
    final first = chrome.refresh();
    await Future<void>.delayed(Duration.zero);
    api.request = null;
    api.snapshot = snapshotGeometry(right: true);
    final second = chrome.refresh();
    stale.complete(snapshotGeometry());
    await Future.wait([first, second]);
    expect(chrome.geometry!.buttons.last.left, 740);
  });

  test(
    'fullscreen pre-hook clears avoidance; exit reconfigures and requeries',
    () async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await chrome.refresh();
      api.events!.willEnterFullScreen();
      expect(chrome.geometry != null && !chrome.isFullScreen, isFalse);
      await chrome.refresh();
      api.events!.onWindowLeaveFullScreen();
      await Future<void>.delayed(Duration.zero);
      expect(chrome.geometry!.buttons.last.right, 61);
      expect(api.configurations, [true, true]);
    },
  );

  test(
    'dispose prevents stale query publication and cleans native subscription once',
    () async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      await chrome.initialize();
      final query = Completer<DesktopWindowChromeGeometry>();
      api.request = query;
      final pending = chrome.refresh();
      await Future<void>.delayed(Duration.zero);
      chrome.dispose();
      query.complete(snapshotGeometry(right: true));
      await pending;
      await Future<void>.delayed(Duration.zero);
      expect(chrome.geometry!.buttons.last.right, 61);
      expect(api.disposalCount, 1);
    },
  );

  test(
    'geometry notification during configuration does not deadlock',
    () async {
      final api = FakeDesktopWindowChromeApi()
        ..geometryChangeOnConfigure = true;
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await chrome.refresh();
      expect(chrome.geometry!.buttons.last.right, 61);
    },
  );
  testWidgets(
    'queued invalid-geometry deadline cannot undo a recovered snapshot',
    (tester) async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(
        api: api,
        geometryTimeout: const Duration(milliseconds: 80),
      );
      addTearDown(chrome.dispose);
      await chrome.initialize();
      api.snapshot = snapshotGeometry(valid: false);
      await chrome.refresh();
      await tester.pump(const Duration(milliseconds: 50));
      api.request = Completer();
      final pending = chrome.refresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      api.request!.complete(snapshotGeometry());
      await pending;
      await chrome.refresh();
      expect(chrome.geometry!.buttons.last.right, 61);
      expect(api.configurations, [true]);
    },
  );
}
