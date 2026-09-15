import 'package:flutter/material.dart';

/// Optional list palette. Apple roles and the Material section surface are
/// separate. Null roles fall back to renderer defaults from ColorScheme.
/// Dynamic Cupertino colors are resolved by consumers in their own context.
@immutable
class AdaptiveListThemeData extends ThemeExtension<AdaptiveListThemeData> {
  const AdaptiveListThemeData({
    this.surfaceColor,
    this.materialSurfaceColor,
    this.foregroundColor,
    this.secondaryColor,
    this.iconColor,
    this.separatorColor,
    this.activatedColor,
    this.focusColor,
  });

  final Color? surfaceColor;

  /// Material section surface; separate from the Apple system palette.
  final Color? materialSurfaceColor;
  final Color? foregroundColor;
  final Color? secondaryColor;
  final Color? iconColor;
  final Color? separatorColor;
  final Color? activatedColor;
  final Color? focusColor;

  @override
  AdaptiveListThemeData copyWith({
    Color? surfaceColor,
    Color? materialSurfaceColor,
    Color? foregroundColor,
    Color? secondaryColor,
    Color? iconColor,
    Color? separatorColor,
    Color? activatedColor,
    Color? focusColor,
  }) => AdaptiveListThemeData(
    surfaceColor: surfaceColor ?? this.surfaceColor,
    materialSurfaceColor: materialSurfaceColor ?? this.materialSurfaceColor,
    foregroundColor: foregroundColor ?? this.foregroundColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    iconColor: iconColor ?? this.iconColor,
    separatorColor: separatorColor ?? this.separatorColor,
    activatedColor: activatedColor ?? this.activatedColor,
    focusColor: focusColor ?? this.focusColor,
  );

  @override
  AdaptiveListThemeData lerp(covariant AdaptiveListThemeData? other, double t) {
    if (other == null) return this;
    // Keep dynamic system colors intact; resolve them in the live brightness
    // and interface-level context, rather than interpolating their light value.
    return t < 0.5 ? this : other;
  }
}

/// A local list theme. Omitted fields fall back to the global theme in renderers.
class AdaptiveListTheme extends InheritedTheme {
  const AdaptiveListTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final AdaptiveListThemeData data;

  static AdaptiveListThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveListTheme>()?.data ??
      Theme.of(context).extension<AdaptiveListThemeData>() ??
      const AdaptiveListThemeData();

  /// Retains the nearest component theme's values while applying non-null fields.
  static Widget merge({
    Key? key,
    required AdaptiveListThemeData data,
    required Widget child,
  }) => Builder(
    builder: (context) {
      final parent = of(context);
      return AdaptiveListTheme(
        key: key,
        data: parent.copyWith(
          surfaceColor: data.surfaceColor,
          materialSurfaceColor: data.materialSurfaceColor,
          foregroundColor: data.foregroundColor,
          secondaryColor: data.secondaryColor,
          iconColor: data.iconColor,
          separatorColor: data.separatorColor,
          activatedColor: data.activatedColor,
          focusColor: data.focusColor,
        ),
        child: child,
      );
    },
  );

  @override
  bool updateShouldNotify(AdaptiveListTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      AdaptiveListTheme(data: data, child: child);
}
