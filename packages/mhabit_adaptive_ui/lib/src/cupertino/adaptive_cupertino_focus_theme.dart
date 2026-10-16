import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// App-level Cupertino focus visuals shared by adaptive renderers.
@immutable
class AdaptiveCupertinoFocusThemeData {
  const AdaptiveCupertinoFocusThemeData({
    this.haloWidth = 3.5,
    this.haloPaintOutset = 4,
    this.haloColor,
  });

  /// Width of the keyboard-focus halo.
  final double haloWidth;

  /// Paint allowance required outside a focused control's layout bounds.
  final double haloPaintOutset;

  /// Optional halo source color. Null resolves the Cupertino theme tint.
  final Color? haloColor;

  AdaptiveCupertinoFocusThemeData copyWith({
    double? haloWidth,
    double? haloPaintOutset,
    Color? haloColor,
  }) => AdaptiveCupertinoFocusThemeData(
    haloWidth: haloWidth ?? this.haloWidth,
    haloPaintOutset: haloPaintOutset ?? this.haloPaintOutset,
    haloColor: haloColor ?? this.haloColor,
  );

  AdaptiveCupertinoFocusThemeData lerp(
    AdaptiveCupertinoFocusThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return AdaptiveCupertinoFocusThemeData(
      haloWidth: haloWidth + (other.haloWidth - haloWidth) * t,
      haloPaintOutset:
          haloPaintOutset + (other.haloPaintOutset - haloPaintOutset) * t,
      haloColor: Color.lerp(haloColor, other.haloColor, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdaptiveCupertinoFocusThemeData &&
      haloWidth == other.haloWidth &&
      haloPaintOutset == other.haloPaintOutset &&
      haloColor == other.haloColor;

  @override
  int get hashCode => Object.hash(haloWidth, haloPaintOutset, haloColor);
}
