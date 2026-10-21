// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/widgets.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

/// Runs the real native window and plugins without the app's asynchronous chrome
/// owner or toolbar passthrough widgets competing with the AppKit test suite.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = DesktopWindowChromeApi();
  await api.initialize(
    const _NativeWindowTestEvents(),
    minimumSize: appDesktopWindowMinimumSize,
  );
  await api.configure(fused: true);
  runApp(const SizedBox.shrink());
  await WidgetsBinding.instance.endOfFrame;
  await api.show();
}

/// XCTest owns native state changes; geometry events must not reconfigure it.
final class _NativeWindowTestEvents implements DesktopWindowChromeEvents {
  const _NativeWindowTestEvents();

  @override
  void geometryChanged() {}

  @override
  void willEnterFullScreen() {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}
}
