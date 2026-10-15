import 'package:flutter/material.dart';

import 'adaptive/adaptive_app_bar_theme_data.dart';
import 'adaptive/adaptive_list_theme.dart';
import 'adaptive_style.dart';
import 'breakpoints/breakpoints.dart';
import 'cupertino/adaptive_cupertino_focus_theme.dart';
import 'cupertino/cupertino_neutral_button.dart';

const Object _unspecified = Object();

/// Design configuration shared by adaptive components.
///
/// Register this extension in [ThemeData.extensions]. Component data is replaced
/// as a whole; use its own `copyWith` when changing only some component fields.
@immutable
class AppAdaptiveUiThemeData extends ThemeExtension<AppAdaptiveUiThemeData> {
  const AppAdaptiveUiThemeData({
    this.style,
    this.breakpoints,
    this.listTheme = const AdaptiveListThemeData(),
    this.appBarTheme = const AdaptiveAppBarThemeData(),
    this.cupertinoButtonTheme = const AdaptiveCupertinoButtonThemeData(),
    this.cupertinoFocusTheme = const AdaptiveCupertinoFocusThemeData(),
  });

  /// Null follows [ThemeData.platform] without changing the actual platform.
  final AdaptiveStyle? style;

  /// Null uses the defaults for the resolved adaptive design style.
  final Breakpoints? breakpoints;

  /// Defaults shared by adaptive list rows and sections.
  final AdaptiveListThemeData listTheme;

  /// Shared app-bar background policy; per-widget Style objects stay separate.
  final AdaptiveAppBarThemeData appBarTheme;

  /// Neutral Cupertino button foreground defaults.
  final AdaptiveCupertinoButtonThemeData cupertinoButtonTheme;

  /// Cupertino keyboard-focus painting and clipping defaults.
  final AdaptiveCupertinoFocusThemeData cupertinoFocusTheme;

  /// Omitting [style] or [breakpoints] retains it; passing null resets it.
  ///
  /// Non-null values must be an [AdaptiveStyle] and [Breakpoints], respectively.
  /// The sentinel parameters allow explicit null without extra reset flags.
  @override
  AppAdaptiveUiThemeData copyWith({
    Object? style = _unspecified,
    Object? breakpoints = _unspecified,
    AdaptiveListThemeData? listTheme,
    AdaptiveAppBarThemeData? appBarTheme,
    AdaptiveCupertinoButtonThemeData? cupertinoButtonTheme,
    AdaptiveCupertinoFocusThemeData? cupertinoFocusTheme,
  }) => AppAdaptiveUiThemeData(
    style: identical(style, _unspecified)
        ? this.style
        : style as AdaptiveStyle?,
    breakpoints: identical(breakpoints, _unspecified)
        ? this.breakpoints
        : breakpoints as Breakpoints?,
    listTheme: listTheme ?? this.listTheme,
    appBarTheme: appBarTheme ?? this.appBarTheme,
    cupertinoButtonTheme: cupertinoButtonTheme ?? this.cupertinoButtonTheme,
    cupertinoFocusTheme: cupertinoFocusTheme ?? this.cupertinoFocusTheme,
  );

  @override
  AppAdaptiveUiThemeData lerp(
    covariant AppAdaptiveUiThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return AppAdaptiveUiThemeData(
      style: t < 0.5 ? style : other.style,
      breakpoints: t < 0.5 ? breakpoints : other.breakpoints,
      listTheme: listTheme.lerp(other.listTheme, t),
      appBarTheme: appBarTheme.lerp(other.appBarTheme, t),
      cupertinoButtonTheme: cupertinoButtonTheme.lerp(
        other.cupertinoButtonTheme,
        t,
      ),
      cupertinoFocusTheme: cupertinoFocusTheme.lerp(
        other.cupertinoFocusTheme,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppAdaptiveUiThemeData &&
      style == other.style &&
      breakpoints == other.breakpoints &&
      listTheme == other.listTheme &&
      appBarTheme == other.appBarTheme &&
      cupertinoButtonTheme == other.cupertinoButtonTheme &&
      cupertinoFocusTheme == other.cupertinoFocusTheme;

  @override
  int get hashCode => Object.hash(
    style,
    breakpoints,
    listTheme,
    appBarTheme,
    cupertinoButtonTheme,
    cupertinoFocusTheme,
  );
}

/// Replaces the adaptive design configuration for a subtree.
///
/// To retain unrelated configuration, derive [data] from
/// `AppAdaptiveUiTheme.of(context).copyWith(...)`. This theme participates in
/// [InheritedTheme.capture] for routes and overlays.
class AppAdaptiveUiTheme extends StatelessWidget {
  const AppAdaptiveUiTheme({
    super.key,
    required this.data,
    required this.child,
  });

  /// Complete replacement data for this subtree.
  final AppAdaptiveUiThemeData data;
  final Widget child;

  /// Reads local data, the Flutter theme extension, or empty defaults.
  static AppAdaptiveUiThemeData of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_AdaptiveUiThemeScope>()
          ?.data ??
      Theme.of(context).extension<AppAdaptiveUiThemeData>() ??
      const AppAdaptiveUiThemeData();

  @override
  Widget build(BuildContext context) => _InheritedAppAdaptiveUiTheme(
    data: data,
    child: _AdaptiveUiThemeScope(data: data, child: child),
  );
}

/// Only explicit local themes participate in Flutter's theme capture.
class _InheritedAppAdaptiveUiTheme extends InheritedTheme {
  const _InheritedAppAdaptiveUiTheme({
    required this.data,
    required super.child,
  });

  final AppAdaptiveUiThemeData data;

  @override
  bool updateShouldNotify(_InheritedAppAdaptiveUiTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      AppAdaptiveUiTheme(data: data, child: child);
}

/// Captures explicit configuration only when it is local to the source route.
/// Shared Navigator ancestors stay live instead of becoming route snapshots.
AppAdaptiveUiThemeData? captureAdaptiveUiThemeData(
  BuildContext from,
  BuildContext to,
) {
  final source = from
      .getInheritedWidgetOfExactType<_InheritedAppAdaptiveUiTheme>();
  final target = to
      .getInheritedWidgetOfExactType<_InheritedAppAdaptiveUiTheme>();
  return identical(source, target) ? null : source?.data;
}

/// Internal component choices, resolved against the live parent theme.
///
/// Unlike an explicit local theme, this boundary is not captured by routes.
/// A route captures its style and breakpoints separately at the call site.
class AdaptiveComponentTheme extends StatelessWidget {
  const AdaptiveComponentTheme({
    super.key,
    required this.style,
    this.breakpoints,
    required this.child,
  });

  final AdaptiveStyle style;
  final Breakpoints? breakpoints;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parent = AppAdaptiveUiTheme.of(context);
    return _AdaptiveUiThemeScope(
      data: parent.copyWith(
        style: style,
        breakpoints: breakpoints ?? parent.breakpoints,
      ),
      child: child,
    );
  }
}

/// The single data dependency for local themes and resolved component choices.
class _AdaptiveUiThemeScope extends InheritedWidget {
  const _AdaptiveUiThemeScope({required this.data, required super.child});

  final AppAdaptiveUiThemeData data;

  @override
  bool updateShouldNotify(_AdaptiveUiThemeScope oldWidget) =>
      data != oldWidget.data;
}
