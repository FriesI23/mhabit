import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';

/// Material-only visual configuration for `AdaptiveNavigationBar`.
class MaterialNavigationBarStyle {
  /// Creates Material navigation-bar styling.
  const MaterialNavigationBarStyle({this.height, this.labelBehavior});

  /// Overrides the navigation bar's height.
  final double? height;

  /// Controls when destination labels are displayed.
  final NavigationDestinationLabelBehavior? labelBehavior;
}

/// Renders adaptive destinations with a Material [NavigationBar].
class MaterialAdaptiveNavigationBar extends StatelessWidget {
  /// Content height of the full navigation-bar presentation.
  static const double fullHeight = 80.0;

  /// Content height of the short navigation-bar presentation.
  static const double shortHeight = 64.0;

  /// Creates a Material navigation bar for [destinations].
  const MaterialAdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.height,
    this.labelBehavior,
  });

  /// Creates the standard navigation bar with visible labels.
  const MaterialAdaptiveNavigationBar.full({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  }) : height = fullHeight,
       labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;

  /// Creates a shorter, icon-only navigation bar.
  ///
  /// Destination labels remain available to tooltips and accessibility
  /// semantics through Flutter's [NavigationDestination].
  const MaterialAdaptiveNavigationBar.short({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  }) : height = shortHeight,
       labelBehavior = NavigationDestinationLabelBehavior.alwaysHide;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Top-level destinations rendered by the bar.
  final List<AdaptiveNavigationDestination> destinations;

  /// Overrides the navigation bar's height.
  final double? height;

  /// Controls when destination labels are displayed.
  final NavigationDestinationLabelBehavior? labelBehavior;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(
      context,
    ).colorScheme.surfaceContainer.withValues(alpha: 0.8);
    return NavigationBarTheme(
      data: NavigationBarTheme.of(
        context,
      ).copyWith(backgroundColor: backgroundColor),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: destination.icons.material,
              selectedIcon: destination.icons.materialSelected,
              label: destination.label,
              tooltip: destination.effectiveSemanticsLabel,
            ),
        ],
        onDestinationSelected: onDestinationSelected,
        height: height,
        labelBehavior: labelBehavior,
      ),
    );
  }
}
