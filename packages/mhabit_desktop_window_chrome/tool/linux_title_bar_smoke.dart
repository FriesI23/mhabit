// Run from the app root with Flutter's Linux runner:
// flutter run -d linux -t packages/mhabit_desktop_window_chrome/tool/linux_title_bar_smoke.dart
// Exercises the real Pigeon channel after temporary plugin registrars are gone.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:window_manager/window_manager.dart';

Future<void> _waitFor(Future<bool> Function() predicate) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (await predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('Window state did not settle');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final titleBar = DesktopWindowTitleBar();
  const systemAppearance = bool.fromEnvironment('SMOKE_SYSTEM_APPEARANCE');
  try {
    if (!Platform.isLinux || !titleBar.supported) {
      throw StateError('This smoke test requires Linux');
    }
    if (systemAppearance) {
      await windowManager.ensureInitialized();
      await windowManager.setMinimumSize(const Size(350, 520));
    } else {
      await titleBar.initialize(minimumSize: const Size(350, 520));
    }
    await windowManager.setTitle('mhabit Linux title bar smoke');
    runApp(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Color(0xFFF2F2F2),
          child: Center(child: Text('Native title bar smoke test')),
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    if (!systemAppearance) {
      await titleBar.applyAppearance(
        const DesktopTitleBarAppearance(
          background: Color(0xFFF2F2F2),
          foreground: Color(0xFF112233),
          brightness: Brightness.light,
        ),
      );
      // Linux reports false for exact colors; GTK owns the light/dark palette.
      final lightColorsApplied = titleBar.lastCustomColorsApplied;
      await titleBar.applyAppearance(
        const DesktopTitleBarAppearance(
          background: Color(0xFF112233),
          foreground: Color(0xFFF2F2F2),
          brightness: Brightness.dark,
        ),
      );
      if (lightColorsApplied == null ||
          titleBar.lastCustomColorsApplied == null) {
        throw StateError('Native appearance calls did not complete');
      }
      stdout.writeln(
        'SMOKE customColors light=$lightColorsApplied '
        'dark=${titleBar.lastCustomColorsApplied}',
      );
    } else {
      stdout.writeln('SMOKE CONTROL: no native title bar appearance calls');
    }
    await windowManager.setSize(const Size(700, 650));
    await windowManager.maximize();
    await _waitFor(windowManager.isMaximized);
    await windowManager.unmaximize();
    await _waitFor(() async => !await windowManager.isMaximized());
    await windowManager.setSize(const Size(350, 520));
    await titleBar.dispose();
    await titleBar.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    stdout.writeln(
      'SMOKE PASS: resize, maximize/restore, reset; closing window',
    );
    await windowManager.close();
  } catch (error, stack) {
    stderr.writeln('SMOKE FAIL: $error\n$stack');
    await titleBar.dispose();
    exit(1);
  }
}
