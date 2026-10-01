import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeExtension;

/// App-owned foreground policy for neutral Cupertino icon buttons.
@immutable
class AdaptiveCupertinoButtonThemeData
    extends ThemeExtension<AdaptiveCupertinoButtonThemeData> {
  const AdaptiveCupertinoButtonThemeData({this.neutralForegroundColor});

  /// Foreground inherited by enabled neutral icon-only buttons.
  ///
  /// Null falls back to the native Cupertino label color.
  final Color? neutralForegroundColor;

  static AdaptiveCupertinoButtonThemeData of(BuildContext context) =>
      Theme.of(context).extension<AdaptiveCupertinoButtonThemeData>() ??
      const AdaptiveCupertinoButtonThemeData();

  @override
  AdaptiveCupertinoButtonThemeData copyWith({Color? neutralForegroundColor}) =>
      AdaptiveCupertinoButtonThemeData(
        neutralForegroundColor:
            neutralForegroundColor ?? this.neutralForegroundColor,
      );

  @override
  AdaptiveCupertinoButtonThemeData lerp(
    covariant AdaptiveCupertinoButtonThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return AdaptiveCupertinoButtonThemeData(
      neutralForegroundColor: Color.lerp(
        neutralForegroundColor,
        other.neutralForegroundColor,
        t,
      ),
    );
  }
}

/// A [CupertinoButton] with the app's neutral foreground policy.
///
/// Interaction, focus, disabled, and semantics behavior remain owned by the
/// Flutter button. An explicit [foregroundColor] overrides the app default.
class NeutralCupertinoButton extends StatelessWidget {
  const NeutralCupertinoButton({
    super.key,
    required this.child,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.foregroundColor,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minimumSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.onLongPress,
    required this.onPressed,
  });

  final Widget child;
  final CupertinoButtonSize sizeStyle;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? foregroundColor;
  final Color disabledColor;
  final Size? minimumSize;
  final double? pressedOpacity;
  final BorderRadius? borderRadius;
  final AlignmentGeometry alignment;
  final Color? focusColor;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final MouseCursor? mouseCursor;
  final VoidCallback? onLongPress;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => CupertinoTheme(
    data: CupertinoTheme.of(context).copyWith(
      primaryColor:
          AdaptiveCupertinoButtonThemeData.of(context).neutralForegroundColor ??
          CupertinoColors.label,
    ),
    child: CupertinoButton(
      sizeStyle: sizeStyle,
      padding: padding,
      color: color,
      foregroundColor: foregroundColor,
      disabledColor: disabledColor,
      minimumSize: minimumSize,
      pressedOpacity: pressedOpacity,
      borderRadius: borderRadius,
      alignment: alignment,
      focusColor: focusColor,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      mouseCursor: mouseCursor,
      onLongPress: onLongPress,
      onPressed: onPressed,
      child: child,
    ),
  );
}

/// Internal theme boundary for package callbacks that build their own button.
///
/// This type is intentionally omitted from the package barrel API. Direct
/// callers should use [NeutralCupertinoButton].
class NeutralCupertinoButtonBuilder extends StatelessWidget {
  const NeutralCupertinoButtonBuilder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => CupertinoTheme(
    data: CupertinoTheme.of(context).copyWith(
      primaryColor:
          AdaptiveCupertinoButtonThemeData.of(context).neutralForegroundColor ??
          CupertinoColors.label,
    ),
    child: Builder(builder: builder),
  );
}
