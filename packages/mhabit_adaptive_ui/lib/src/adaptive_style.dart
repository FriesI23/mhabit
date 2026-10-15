import 'package:flutter/material.dart';

import 'app_adaptive_ui_theme.dart';

/// Platform design styles supported by the adaptive components.
///
/// [AdaptiveStyle.apple] is resolved for iOS and macOS; everything else
/// resolves to [AdaptiveStyle.material]. Adaptive components fall back to
/// material when they do not provide an Apple-specific implementation.
enum AdaptiveStyle {
  material,
  apple;

  /// Resolves the adaptive style for [context].
  static AdaptiveStyle of(BuildContext context) =>
      resolveAdaptiveStyle(context);
}

/// Maps the current platform of [context] to an [AdaptiveStyle].
///
/// This is the single place that maps a platform to a style; callers must
/// never branch on `defaultTargetPlatform` / `Platform.isXxx` themselves.
AdaptiveStyle resolveAdaptiveStyle(BuildContext context) =>
    AppAdaptiveUiTheme.of(context).style ??
    switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => AdaptiveStyle.apple,
      _ => AdaptiveStyle.material,
    };
