import 'package:flutter/widgets.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

/// App integration fixtures using only the plugin's public contract.
DesktopWindowChromeGeometry snapshotGeometry({
  double width = 800,
  double height = 600,
  bool right = false,
  List<Rect>? buttons,
}) => DesktopWindowChromeGeometry(
  ready: true,
  valid: true,
  fullScreen: false,
  viewport: Size(width, height),
  buttons:
      buttons ??
      [
        for (var i = 0; i < 3; i++)
          Rect.fromLTWH(right ? width - 20 - i * 20 : 7 + i * 20, 7, 14, 14),
      ],
);

class FakeDesktopWindowChromeApi implements DesktopWindowChromeApi {
  DesktopWindowChromeGeometry snapshot = snapshotGeometry();
  final List<bool> configurations = [];
  int initializationCount = 0;

  @override
  bool get supported => true;

  @override
  Future<void> initialize(
    DesktopWindowChromeEvents events, {
    Size? minimumSize,
  }) async {
    initializationCount++;
  }

  @override
  Future<void> show() async {}

  @override
  Future<bool> isFullScreen() async => false;

  @override
  Future<void> configure({required bool fused}) async {
    configurations.add(fused);
  }

  @override
  Future<DesktopWindowChromeGeometry> geometry() async => snapshot;

  @override
  Future<void> dispose() async {}
}
