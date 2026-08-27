import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import 'adaptive_navigation_destination.dart';

/// Adaptive navigation rail (the medium+ chrome of the navigation shell).
///
/// The default constructor resolves the style from the current platform;
/// `.material` forces the Material style. The Apple style currently falls back
/// to the Material implementation.
class AdaptiveNavigationRail extends StatelessWidget {
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

  final AdaptiveStyle? style;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final bool extended;
  final double minWidth;
  final double minExtendedWidth;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      // TODO(adaptive-ui::apple): apple style (HIG sidebar rail).
      AdaptiveStyle.apple || AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      leading: leading,
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: destination.icons.material,
            selectedIcon: destination.icons.materialSelected,
            label: destination.semanticsLabel == null
                ? Text(destination.label)
                : Semantics(
                    label: destination.effectiveSemanticsLabel,
                    excludeSemantics: true,
                    child: Text(destination.label),
                  ),
          ),
      ],
    );
  }
}
