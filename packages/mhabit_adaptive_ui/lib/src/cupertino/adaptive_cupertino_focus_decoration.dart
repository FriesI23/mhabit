import 'package:flutter/cupertino.dart';

import '../app_adaptive_ui_theme.dart';

/// Paints a themed halo using the caller's focus state and control shape.
///
/// This widget does not change focus, interaction, semantics, or layout.
class AdaptiveCupertinoFocusDecoration extends StatelessWidget {
  const AdaptiveCupertinoFocusDecoration({
    super.key,
    required this.visible,
    required this.decoration,
    required this.child,
  });

  final bool visible;

  /// The renderer-owned decoration. Its shape must be an [OutlinedBorder].
  /// Non-border properties are retained; the side is replaced by the halo.
  final ShapeDecoration decoration;
  final Widget child;

  static Color _resolveHaloColor(BuildContext context, Color? source) =>
      HSLColor.fromColor(
            CupertinoDynamicColor.resolve(
              source ?? CupertinoTheme.of(context).primaryColor,
              context,
            ).withValues(alpha: kCupertinoFocusColorOpacity),
          )
          .withLightness(kCupertinoFocusColorBrightness)
          .withSaturation(kCupertinoFocusColorSaturation)
          .toColor();

  @override
  Widget build(BuildContext context) {
    final theme = AppAdaptiveUiTheme.of(context).cupertinoFocusTheme;
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
                  color: _resolveHaloColor(context, theme.haloColor),
                  width: theme.haloWidth,
                  strokeAlign: BorderSide.strokeAlignOutside,
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
