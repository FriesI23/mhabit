import 'package:flutter/widgets.dart';

/// Platform-specific icon pair for an [AdaptiveNavigationDestination].
///
/// Callers describe both renderers without reading the current platform.
abstract interface class NavigationDestinationIcons {
  const factory NavigationDestinationIcons({
    required Widget material,
    required Widget materialSelected,
    required Widget apple,
    required Widget appleSelected,
  }) = _SeparateNavigationDestinationIcons;

  /// Uses the same adaptive icon for every platform and selection state.
  const factory NavigationDestinationIcons.union(Widget icon) =
      _UnionNavigationDestinationIcons;

  Widget get material;
  Widget get materialSelected;
  Widget get apple;
  Widget get appleSelected;
}

final class _SeparateNavigationDestinationIcons
    implements NavigationDestinationIcons {
  const _SeparateNavigationDestinationIcons({
    required this.material,
    required this.materialSelected,
    required this.apple,
    required this.appleSelected,
  });

  @override
  final Widget material;

  @override
  final Widget materialSelected;

  @override
  final Widget apple;

  @override
  final Widget appleSelected;
}

final class _UnionNavigationDestinationIcons
    implements NavigationDestinationIcons {
  const _UnionNavigationDestinationIcons(this.icon);

  final Widget icon;

  @override
  Widget get material => icon;

  @override
  Widget get materialSelected => icon;

  @override
  Widget get apple => icon;

  @override
  Widget get appleSelected => icon;
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
