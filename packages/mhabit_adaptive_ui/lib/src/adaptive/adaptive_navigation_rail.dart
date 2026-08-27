import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../material/material_navigation_rail.dart';
import 'adaptive_navigation_destination.dart';

/// Adaptive navigation rail (the medium+ chrome of the navigation shell).
///
/// The default constructor resolves the style from the current platform;
/// `.material` forces the Material style. The Apple style currently falls back
/// to the Material implementation.
class AdaptiveNavigationRail extends StatelessWidget {
  /// Creates a navigation rail using the ambient adaptive style.
  const AdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.extended,
    required this.minWidth,
    required this.minExtendedWidth,
    this.leading,
  }) : style = null;

  /// Creates a navigation rail that always uses the Material renderer.
  const AdaptiveNavigationRail.material({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.extended,
    required this.minWidth,
    required this.minExtendedWidth,
    this.leading,
  }) : style = AdaptiveStyle.material;

  /// Explicit renderer style, or null to resolve it from the context.
  final AdaptiveStyle? style;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Top-level destinations rendered by the rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Whether labels and the extended rail layout are displayed.
  final bool extended;

  /// Minimum width of the collapsed rail.
  final double minWidth;

  /// Minimum width of the extended rail.
  final double minExtendedWidth;

  /// Optional widget displayed above the destinations.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      // TODO(adaptive-ui::apple): apple style (HIG sidebar rail).
      AdaptiveStyle.apple ||
      AdaptiveStyle.material => MaterialAdaptiveNavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        extended: extended,
        minWidth: minWidth,
        minExtendedWidth: minExtendedWidth,
        leading: leading,
      ),
    };
  }
}
