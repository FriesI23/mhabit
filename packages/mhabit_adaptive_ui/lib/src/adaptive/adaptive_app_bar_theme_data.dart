import 'package:flutter/foundation.dart';

/// Visual policy shared by adaptive app bars and their search fields.
@immutable
class AdaptiveAppBarThemeData {
  const AdaptiveAppBarThemeData({this.materialFixedScrollBackground = false});

  /// Keeps Material app-bar and search backgrounds in their ordinary scroll
  /// state, disables app-bar surface tint, and retains scroll elevation.
  final bool materialFixedScrollBackground;

  AdaptiveAppBarThemeData copyWith({bool? materialFixedScrollBackground}) =>
      AdaptiveAppBarThemeData(
        materialFixedScrollBackground:
            materialFixedScrollBackground ?? this.materialFixedScrollBackground,
      );

  AdaptiveAppBarThemeData lerp(AdaptiveAppBarThemeData? other, double t) =>
      other == null || t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is AdaptiveAppBarThemeData &&
      materialFixedScrollBackground == other.materialFixedScrollBackground;

  @override
  int get hashCode => materialFixedScrollBackground.hashCode;
}
