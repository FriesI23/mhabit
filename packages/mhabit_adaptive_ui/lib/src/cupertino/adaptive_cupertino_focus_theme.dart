import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeExtension;

/// App-level Cupertino focus visuals shared by adaptive renderers.
@immutable
class AdaptiveCupertinoFocusThemeData
    extends ThemeExtension<AdaptiveCupertinoFocusThemeData> {
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

  static AdaptiveCupertinoFocusThemeData of(BuildContext context) =>
      Theme.of(context).extension<AdaptiveCupertinoFocusThemeData>() ??
      const AdaptiveCupertinoFocusThemeData();

  Color resolveHaloColor(BuildContext context) =>
      HSLColor.fromColor(
            CupertinoDynamicColor.resolve(
              haloColor ?? CupertinoTheme.of(context).primaryColor,
              context,
            ).withValues(alpha: kCupertinoFocusColorOpacity),
          )
          .withLightness(kCupertinoFocusColorBrightness)
          .withSaturation(kCupertinoFocusColorSaturation)
          .toColor();

  /// Paints the shared app halo while preserving renderer-owned geometry.
  Widget buildHalo(
    BuildContext context, {
    required Widget child,
    required bool visible,
    required ShapeDecoration decoration,
  }) {
    final shape = decoration.shape;
    assert(shape is OutlinedBorder);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(
        color: decoration.color,
        image: decoration.image,
        gradient: decoration.gradient,
        shadows: decoration.shadows,
        shape: (shape as OutlinedBorder).copyWith(
          side: visible
              ? BorderSide(
                  color: resolveHaloColor(context),
                  width: haloWidth,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  @override
  AdaptiveCupertinoFocusThemeData copyWith({
    double? haloWidth,
    double? haloPaintOutset,
    Color? haloColor,
  }) => AdaptiveCupertinoFocusThemeData(
    haloWidth: haloWidth ?? this.haloWidth,
    haloPaintOutset: haloPaintOutset ?? this.haloPaintOutset,
    haloColor: haloColor ?? this.haloColor,
  );

  @override
  AdaptiveCupertinoFocusThemeData lerp(
    covariant AdaptiveCupertinoFocusThemeData? other,
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
}

/// Applies the shared app focus visual to a focusable descendant.
class AdaptiveCupertinoFocusHalo extends StatefulWidget {
  const AdaptiveCupertinoFocusHalo({
    super.key,
    required this.child,
    this.borderRadius,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<AdaptiveCupertinoFocusHalo> createState() =>
      _AdaptiveCupertinoFocusHaloState();
}

class _AdaptiveCupertinoFocusHaloState
    extends State<AdaptiveCupertinoFocusHalo> {
  bool _childHasFocus = false;

  @override
  Widget build(BuildContext context) {
    final focusTheme = AdaptiveCupertinoFocusThemeData.of(context);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (hasFocus) {
        if (_childHasFocus == hasFocus) return;
        setState(() => _childHasFocus = hasFocus);
      },
      child: focusTheme.buildHalo(
        context,
        visible: _childHasFocus,
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius:
                widget.borderRadius ??
                kCupertinoButtonSizeBorderRadius[CupertinoButtonSize.large]!,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
