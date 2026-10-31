import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:foldable/foldable.dart';

/// Supplies iOS fold geometry to the same Flutter routes used on Android.
///
/// Platform detection is independent of the visual style. Android and other
/// platforms retain their existing engine-provided MediaQuery unchanged.
class AdaptiveDisplayFeatureLayout extends StatelessWidget {
  const AdaptiveDisplayFeatureLayout({super.key, required this.child});

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
