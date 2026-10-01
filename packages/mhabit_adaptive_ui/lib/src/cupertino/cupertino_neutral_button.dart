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

/// Builds a package-owned Cupertino button with a neutral app foreground.
///
/// [builder] is invoked below the local theme so the button retains its
/// existing text, icon, pressed, disabled, focus, and semantics behavior.
class CupertinoNeutralButtonBuilder extends StatelessWidget {
  /// Creates a neutral Cupertino button build boundary.
  const CupertinoNeutralButtonBuilder({super.key, required this.builder});

  /// Builds the button below the locally overridden Cupertino theme.
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
