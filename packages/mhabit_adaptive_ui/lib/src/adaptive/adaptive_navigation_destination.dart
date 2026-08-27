import 'package:flutter/widgets.dart';

/// Platform-specific icon pair for an [AdaptiveNavigationDestination].
///
/// Callers describe both renderers without reading the current platform.
class NavigationDestinationIcons {
  const NavigationDestinationIcons({
    required this.material,
    required this.materialSelected,
    required this.apple,
    required this.appleSelected,
  });

  final Widget material;
  final Widget materialSelected;
  final Widget apple;
  final Widget appleSelected;
}

/// Platform-neutral description of a top-level navigation destination.
class AdaptiveNavigationDestination {
  const AdaptiveNavigationDestination({
    required this.label,
    required this.icons,
    this.semanticsLabel,
  });

  /// Visible short label for the destination.
  final String label;

  /// Accessibility label, falling back to [label] when omitted.
  final String? semanticsLabel;

  /// Material and Apple default/selected icon pairs.
  final NavigationDestinationIcons icons;

  String get effectiveSemanticsLabel => semanticsLabel ?? label;
}
