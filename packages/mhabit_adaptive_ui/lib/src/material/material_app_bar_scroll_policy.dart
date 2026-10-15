import 'package:flutter/material.dart';

/// Controls background changes without changing scroll shadows or geometry.
class MaterialAppBarScrollPolicy extends InheritedWidget {
  const MaterialAppBarScrollPolicy({
    super.key,
    required this.fixedBackground,
    required super.child,
  });

  final bool fixedBackground;

  static bool fixedBackgroundOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MaterialAppBarScrollPolicy>()
          ?.fixedBackground ??
      false;

  static Color? backgroundOf(BuildContext context, Color? explicitColor) {
    if (!fixedBackgroundOf(context)) return explicitColor;
    final theme = Theme.of(context);
    return WidgetStateProperty.resolveAs<Color>(
      explicitColor ??
          theme.appBarTheme.backgroundColor ??
          theme.colorScheme.surface,
      const <WidgetState>{},
    );
  }

  static Color? tintOf(BuildContext context, Color? explicitColor) =>
      fixedBackgroundOf(context) ? Colors.transparent : explicitColor;

  @override
  bool updateShouldNotify(MaterialAppBarScrollPolicy oldWidget) =>
      fixedBackground != oldWidget.fixedBackground;
}
