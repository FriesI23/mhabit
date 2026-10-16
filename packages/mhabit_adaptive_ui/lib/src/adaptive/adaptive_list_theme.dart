import 'package:flutter/material.dart';

import '../app_adaptive_ui_theme.dart';

/// Optional list palette. Apple roles and the Material section surface are
/// separate. Null roles fall back to renderer defaults from ColorScheme.
/// Dynamic Cupertino colors are resolved by consumers in their own context.
@immutable
class AdaptiveListThemeData {
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

  AdaptiveListThemeData lerp(covariant AdaptiveListThemeData? other, double t) {
    if (other == null) return this;
    // Keep dynamic system colors intact; resolve them in the live brightness
    // and interface-level context, rather than interpolating their light value.
    return t < 0.5 ? this : other;
  }

  @override
  bool operator ==(Object other) =>
      other is AdaptiveListThemeData &&
      surfaceColor == other.surfaceColor &&
      materialSurfaceColor == other.materialSurfaceColor &&
      foregroundColor == other.foregroundColor &&
      secondaryColor == other.secondaryColor &&
      iconColor == other.iconColor &&
      separatorColor == other.separatorColor &&
      activatedColor == other.activatedColor &&
      focusColor == other.focusColor;

  @override
  int get hashCode => Object.hash(
    surfaceColor,
    materialSurfaceColor,
    foregroundColor,
    secondaryColor,
    iconColor,
    separatorColor,
    activatedColor,
    focusColor,
  );
}

/// A local list palette. Omitted fields fall back to the active adaptive theme.
class AdaptiveListTheme extends InheritedTheme {
  const AdaptiveListTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final AdaptiveListThemeData data;

  static AdaptiveListThemeData of(BuildContext context) {
    final global = AppAdaptiveUiTheme.of(context).listTheme;
    final local = context
        .dependOnInheritedWidgetOfExactType<AdaptiveListTheme>()
        ?.data;
    if (local == null) return global;
    return global.copyWith(
      surfaceColor: local.surfaceColor,
      materialSurfaceColor: local.materialSurfaceColor,
      foregroundColor: local.foregroundColor,
      secondaryColor: local.secondaryColor,
      iconColor: local.iconColor,
      separatorColor: local.separatorColor,
      activatedColor: local.activatedColor,
      focusColor: local.focusColor,
    );
  }

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
