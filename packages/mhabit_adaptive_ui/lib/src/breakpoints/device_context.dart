import 'dart:ui' show DisplayFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show BuildContext, MediaQuery, Size, Theme;

/// The device environment for adaptive decisions: window geometry, platform
/// and display features.
///
/// Serves as the single input for downstream adaptive shell selection.
/// Resolve instances through [DeviceContext.of]. Further signals such as
/// folding posture can be added later as optional fields once Flutter
/// exposes them; today they are only observable through [displayFeatures].
@immutable
final class DeviceContext {
  const DeviceContext({
    required this.windowSize,
    required this.platform,
    this.displayFeatures = const [],
  });

  /// The current window size in logical pixels.
  final Size windowSize;

  /// The current platform, taken from the ambient [Theme].
  final TargetPlatform platform;

  /// Hinge, fold and cutout features, as reported by the engine.
  final List<DisplayFeature> displayFeatures;

  /// Builds a [DeviceContext] from the ambient [MediaQuery] and [Theme].
  ///
  /// Platform detection stays centralized in `resolveAdaptiveStyle`, so this
  /// reads `Theme.of(context).platform` rather than `defaultTargetPlatform`.
  static DeviceContext of(BuildContext context) => DeviceContext(
    windowSize: MediaQuery.sizeOf(context),
    platform: Theme.of(context).platform,
    displayFeatures: MediaQuery.displayFeaturesOf(context),
  );
}
