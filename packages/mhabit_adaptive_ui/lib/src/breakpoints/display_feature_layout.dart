import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:foldable/foldable.dart';

/// Supplies iOS fold geometry to the same Flutter routes used on Android.
///
/// Platform detection is independent of the visual style. Android and other
/// platforms retain their existing engine-provided MediaQuery unchanged.
///
/// On iOS, publishes foldable geometry through [MediaQueryData.displayFeatures]
/// above the Navigator. Framework dialogs, sheets, menus, and pickers can then
/// select a pane using their usual anchor-point policy. Adaptive sheet routes
/// apply their own filtering for top/bottom folds.
class AdaptiveDisplayFeatureLayout extends StatelessWidget {
  /// Creates a platform-aware display-feature boundary.
  const AdaptiveDisplayFeatureLayout({super.key, required this.child});

  /// The app subtree, including the Navigator that creates modal routes.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? FoldableProvider(
          bridgeMode: DisplayFeatureBridgeMode.full,
          child: child,
        )
      : child;
}
