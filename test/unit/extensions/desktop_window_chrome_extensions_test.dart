import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/desktop_window_chrome_extensions.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

import '../../support/desktop_window_chrome_fakes.dart';

void main() {
  test(
    'logical points and physical edge geometry; resize never repeats style',
    () async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await chrome.initialize();
      expect(api.initializationCount, 1);
      expect(
        chrome.adaptiveLayout.horizontalAvoidance,
        const EdgeInsets.only(left: 61),
      );
      expect(chrome.adaptiveLayout.verticalAvoidance.top, 21);
      expect(chrome.geometry!.viewport, const Size(800, 600));
      api.snapshot = snapshotGeometry(width: 350, height: 520, right: true);
      await chrome.refresh();
      expect(
        chrome.adaptiveLayout.horizontalAvoidance,
        const EdgeInsets.only(right: 60),
      );
      expect(api.configurations, [true]);
    },
  );

  test('native left/right rectangles merge with max, not sum', () async {
    final api = FakeDesktopWindowChromeApi()
      ..snapshot = snapshotGeometry(
        buttons: const [
          Rect.fromLTWH(0, 0, 80, 24),
          Rect.fromLTWH(760, 0, 40, 18),
          Rect.fromLTWH(0, 0, 20, 12),
        ],
      );
    final chrome = DesktopWindowChrome(api: api);
    addTearDown(chrome.dispose);
    await chrome.initialize();
    expect(
      chrome.adaptiveLayout.horizontalAvoidance,
      const EdgeInsets.only(left: 80, right: 40),
    );
    expect(chrome.adaptiveLayout.verticalAvoidance.top, 24);
    api.snapshot = snapshotGeometry();
    await chrome.refresh();
    expect(chrome.adaptiveLayout.horizontalAvoidance.left, 61);
    expect(chrome.adaptiveLayout.horizontalAvoidance.right, 0);
  });
}
