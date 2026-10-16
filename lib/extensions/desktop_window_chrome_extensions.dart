import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

/// App-owned conversion from native physical geometry to adaptive UI layout.
extension DesktopWindowChromeAdaptiveLayout on DesktopWindowChrome {
  AdaptivePlatformWindowControlLayout get adaptiveLayout {
    final snapshot = geometry;
    if (!available || isFullScreen || snapshot == null || !snapshot.valid) {
      return const AdaptivePlatformWindowControlLayout();
    }
    final size = snapshot.viewport;
    var left = 0.0;
    var right = 0.0;
    var top = 0.0;
    for (final raw in snapshot.buttons) {
      if (!raw.isFinite || raw.isEmpty) continue;
      final rect = raw.intersect(Offset.zero & size);
      if (rect.isEmpty) continue;
      if (rect.center.dx <= size.width / 2) {
        left = math.max(left, rect.right);
      } else {
        right = math.max(right, size.width - rect.left);
      }
      top = math.max(top, rect.bottom);
    }
    return AdaptivePlatformWindowControlLayout(
      horizontalAvoidance: EdgeInsets.only(left: left, right: right),
      verticalAvoidance: EdgeInsets.only(top: top),
      hasWindowControlAvoidance: left > 0 || right > 0,
    );
  }
}
