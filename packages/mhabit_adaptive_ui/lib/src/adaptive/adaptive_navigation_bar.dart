import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Adaptive bottom navigation bar (box, for a `Scaffold.bottomNavigationBar`
/// slot).
///
/// The default constructor resolves the style from the current platform;
/// `.material` forces the Material style. Phase 3 adds the apple style
/// (`CupertinoTabBar`-style).
class AdaptiveNavigationBar extends StatelessWidget {
  const AdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.height,
    this.labelBehavior,
  }) : style = null;

  const AdaptiveNavigationBar.material({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.height,
    this.labelBehavior,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double? height;
  final NavigationDestinationLabelBehavior? labelBehavior;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(Phase 3): apple style (CupertinoTabBar-style).
      AdaptiveStyle.apple || AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    // Matches the app's current `naviBarBody` parameter surface.
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: destinations,
      onDestinationSelected: onDestinationSelected,
      height: height,
      labelBehavior: labelBehavior,
    );
  }
}
