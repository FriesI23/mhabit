import 'package:flutter/material.dart';

/// Platform design styles supported by the adaptive components.
///
/// [AdaptiveStyle.apple] is resolved for iOS / macOS but not implemented in
/// Phase 0: adaptive components fall back to [AdaptiveStyle.material] until
/// Phase 3.
enum AdaptiveStyle { material, apple }

/// Maps the current platform of [context] to an [AdaptiveStyle].
///
/// This is the single place that maps a platform to a style; callers must
/// never branch on `defaultTargetPlatform` / `Platform.isXxx` themselves.
AdaptiveStyle resolveAdaptiveStyle(BuildContext context) =>
    switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => AdaptiveStyle.apple,
      _ => AdaptiveStyle.material,
    };

/// Convenience accessors for adaptive components built from [BuildContext].
extension AdaptiveStyleContext on BuildContext {
  /// The adaptive style resolved for this context.
  AdaptiveStyle get adaptiveStyle => resolveAdaptiveStyle(this);
}
