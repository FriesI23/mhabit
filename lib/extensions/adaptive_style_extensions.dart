import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

extension AppAdaptiveStyle on AdaptiveStyle {
  static const double materialToolbarHeight = 64.0;
  static const double appleToolbarHeight = 44.0;

  double get appToolbarHeight => switch (this) {
    AdaptiveStyle.material => materialToolbarHeight,
    AdaptiveStyle.apple => appleToolbarHeight,
  };
}
