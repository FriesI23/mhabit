import 'package:flutter/material.dart';

import '../app_adaptive_ui_theme.dart';

/// Internal paint resolution for the adaptive app-bar theme.
abstract final class MaterialAppBarBackground {
  static bool fixedBackgroundOf(BuildContext context) =>
      AppAdaptiveUiTheme.of(context).appBarTheme.materialFixedScrollBackground;

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
}
