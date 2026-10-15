import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/app_ui/app_window_appearance.dart';
import 'package:mhabit/providers/support/commons.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

void main() {
  const light = DesktopTitleBarAppearance(
    background: Colors.white,
    foreground: Colors.black,
    brightness: Brightness.light,
  );
  const dark = DesktopTitleBarAppearance(
    background: Colors.black,
    foreground: Colors.white,
    brightness: Brightness.dark,
  );

  test('resolves latest inputs and ignores stale releases and repeats', () {
    final owner = AppWindowAppearanceOwner();
    addTearDown(owner.dispose);
    final changes = <DesktopTitleBarAppearance?>[];
    owner.changes.addListener(() => changes.add(owner.appearance));
    final oldSource = Object();
    final currentSource = Object();

    // Navigation can contribute before the window theme is available.
    owner.reportSurface(source: oldSource, background: Colors.amber);
    expect(owner.appearance, isNull);
    expect(changes, isEmpty);
    owner.updateWindow(light);
    owner.updateWindow(dark);
    owner.reportSurface(source: currentSource, background: Colors.green);
    owner.clearSurface(oldSource);
    const resolved = DesktopTitleBarAppearance(
      background: Colors.green,
      foreground: Colors.white,
      brightness: Brightness.dark,
    );
    expect(owner.appearance, resolved);
    expect(changes.last, resolved);

    final count = changes.length;
    owner.clearSurface(oldSource);
    owner.updateWindow(dark);
    owner.reportSurface(source: currentSource, background: Colors.green);
    expect(changes, hasLength(count));

    owner.clearSurface(currentSource);
    expect(owner.appearance, dark);
    expect(changes, hasLength(count + 1));
  });

  test(
    'retains changed fallback without notifying for equal resolved colors',
    () {
      final owner = AppWindowAppearanceOwner();
      addTearDown(owner.dispose);
      var notifications = 0;
      owner.changes.addListener(() => notifications++);
      final firstSource = Object();
      final latestSource = Object();
      owner.updateWindow(light);
      owner.reportSurface(source: firstSource, background: Colors.green);
      final count = notifications;

      const fallback = DesktopTitleBarAppearance(
        background: Colors.blue,
        foreground: Colors.black,
        brightness: Brightness.light,
      );
      owner.updateWindow(fallback);
      // Equal colors still transfer ownership to the newest source.
      owner.reportSurface(source: latestSource, background: Colors.green);
      owner.clearSurface(firstSource);
      expect(notifications, count);
      expect(owner.appearance!.background, Colors.green);

      owner.reportSurface(source: latestSource, background: null);
      expect(owner.appearance, fallback);
      expect(notifications, count + 1);
    },
  );

  test('disposal clears data and ignores late navigation reports', () {
    final owner = AppWindowAppearanceOwner();
    expect(owner, isA<ProviderMounted>());
    expect(owner.mounted, isTrue);
    var notifications = 0;
    owner.changes.addListener(() => notifications++);
    final source = Object();
    owner.updateWindow(light);
    owner.reportSurface(source: source, background: Colors.amber);
    final count = notifications;

    owner.dispose();
    expect(owner.mounted, isFalse);
    owner.clearSurface(source);
    owner.reportSurface(source: source, background: Colors.green);
    owner.updateWindow(dark);
    owner.dispose();
    expect(owner.appearance, isNull);
    expect(notifications, count);
  });
}
