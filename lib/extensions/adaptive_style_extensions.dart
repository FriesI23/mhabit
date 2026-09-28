import 'package:flutter/cupertino.dart'
    show CupertinoTheme, kMinInteractiveDimensionCupertino;
import 'package:flutter/material.dart' show BuildContext, Color, Theme;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

extension AppAdaptiveStyle on AdaptiveStyle {
  static const double materialToolbarHeight = 64.0;
  static const double appleToolbarHeight = kMinInteractiveDimensionCupertino;

  double get appToolbarHeight => switch (this) {
    AdaptiveStyle.material => materialToolbarHeight,
    AdaptiveStyle.apple => appleToolbarHeight,
  };
}

extension AppAdaptiveThemeContext on BuildContext {
  Color get adaptivePrimaryColor => switch (AdaptiveStyle.of(this)) {
    AdaptiveStyle.material => Theme.of(this).colorScheme.primary,
    AdaptiveStyle.apple => CupertinoTheme.of(this).primaryColor,
  };
}
