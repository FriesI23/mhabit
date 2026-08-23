import 'dart:core' as core;

import 'package:flutter/material.dart';

/// Platform design styles supported by the adaptive components.
///
/// [AdaptiveStyle.apple] is resolved for iOS and macOS; everything else
/// resolves to [AdaptiveStyle.material]. Adaptive components fall back to
/// material when they do not provide an Apple-specific implementation.
enum AdaptiveStyle { material, apple }

/// Overrides the platform-derived adaptive style for this subtree.
///
/// A null [override] explicitly keeps platform-based resolution for the
/// subtree.
class AdaptiveStyleScope extends InheritedWidget {
  const AdaptiveStyleScope({
    required this.override,
    required super.child,
    super.key,
  });

  final AdaptiveStyle? override;

  static AdaptiveStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveStyleScope>();

  @core.override
  core.bool updateShouldNotify(AdaptiveStyleScope oldWidget) =>
      override != oldWidget.override;
}

/// Maps the current platform of [context] to an [AdaptiveStyle].
///
/// This is the single place that maps a platform to a style; callers must
/// never branch on `defaultTargetPlatform` / `Platform.isXxx` themselves.
AdaptiveStyle resolveAdaptiveStyle(BuildContext context) =>
    AdaptiveStyleScope.maybeOf(context)?.override ??
    switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => AdaptiveStyle.apple,
      _ => AdaptiveStyle.material,
    };

/// Convenience accessors for adaptive components built from [BuildContext].
extension AdaptiveStyleContext on BuildContext {
  /// The adaptive style resolved for this context.
  AdaptiveStyle get adaptiveStyle => resolveAdaptiveStyle(this);
}
