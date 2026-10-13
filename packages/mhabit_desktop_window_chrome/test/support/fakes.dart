import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

DesktopWindowChromeGeometry snapshotGeometry({
  bool ready = true,
  bool valid = true,
  bool fullScreen = false,
  double width = 800,
  double height = 600,
  bool right = false,
  List<Rect>? buttons,
}) => DesktopWindowChromeGeometry(
  ready: ready,
  valid: valid,
  fullScreen: fullScreen,
  viewport: Size(width, height),
  buttons:
      buttons ??
      [
        for (var i = 0; i < 3; i++)
          Rect.fromLTWH(right ? width - 20 - i * 20 : 7 + i * 20, 7, 14, 14),
      ],
);

class FakeDesktopWindowChromeApi implements DesktopWindowChromeApi {
  DesktopWindowChromeEvents? events;
  @override
  bool supported = true;
  bool fullScreen = false;
  bool failInitialize = false;
  bool geometryChangeOnConfigure = false;
  bool failGeometry = false;
  DesktopWindowChromeGeometry snapshot = snapshotGeometry();
  Completer<DesktopWindowChromeGeometry>? request;
  final List<bool> configurations = [];
  int initializationCount = 0;
  Size? minimumSize;
  int showCount = 0;
  int disposalCount = 0;

  @override
  Future<void> initialize(
    DesktopWindowChromeEvents events, {
    Size? minimumSize,
  }) async {
    initializationCount++;
    this.minimumSize = minimumSize;
    this.events = events;
    if (failInitialize) throw StateError('plugin unavailable');
  }

  @override
  Future<void> show() async {
    showCount++;
  }

  @override
  Future<bool> isFullScreen() async => fullScreen;
  @override
  Future<void> configure({required bool fused}) async {
    configurations.add(fused);
    if (geometryChangeOnConfigure) {
      geometryChangeOnConfigure = false;
      events!.geometryChanged();
    }
  }

  @override
  Future<DesktopWindowChromeGeometry> geometry() async {
    if (failGeometry) throw StateError('query failed');
    return request?.future ?? snapshot;
  }

  @override
  Future<void> dispose() async {
    disposalCount++;
  }
}
