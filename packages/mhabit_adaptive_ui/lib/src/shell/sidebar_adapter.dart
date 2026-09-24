import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import '../adaptive/adaptive_navigation_destination.dart' as app;
import '../window_control/window_control_layout.dart';

final class SidebarNavigationAdapter {
  SidebarNavigationAdapter({
    required List<app.AdaptiveNavigationDestination> destinations,
    required List<app.AdaptiveNavigationDestination> auxiliaryDestinations,
    required int selectedIndex,
    required int? selectedAuxiliaryIndex,
    required this.onDestinationSelected,
    required this.onAuxiliaryDestinationSelected,
  }) {
    this.destinations = _adaptDestinations(destinations);
    this.auxiliaryDestinations = _adaptDestinations(auxiliaryDestinations);
    selection = selectedAuxiliaryIndex == null
        ? SidebarPrimarySelection(selectedIndex)
        : SidebarAuxiliarySelection(selectedAuxiliaryIndex);
  }

  late final List<AdaptiveNavigationDestination> destinations;
  late final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  late final SidebarDestinationSelection selection;
  final ValueChanged<int> onDestinationSelected;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

  List<AdaptiveNavigationDestination> _adaptDestinations(
    List<app.AdaptiveNavigationDestination> destinations,
  ) => [
    for (final destination in destinations)
      AdaptiveNavigationDestination(
        label: destination.label,
        semanticsLabel: destination.semanticsLabel,
        icons: NavigationDestinationIcons(
          material: destination.icons.material,
          materialSelected: destination.icons.materialSelected,
          cupertino: destination.icons.apple,
          cupertinoSelected: destination.icons.appleSelected,
        ),
      ),
  ];

  void select(SidebarDestinationSelection selection) {
    switch (selection) {
      case SidebarPrimarySelection(:final index):
        onDestinationSelected(index);
      case SidebarAuxiliarySelection(:final index):
        onAuxiliaryDestinationSelected?.call(index);
    }
  }
}

extension SidebarWindowControlAdapter on BuildContext {
  NavigationObstruction get sidebarNavigationObstruction {
    final horizontal =
        AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
          this,
        );
    final vertical =
        AdaptiveWindowControlLayoutScope.sideNavigationVerticalAvoidanceOf(
          this,
        );
    return NavigationObstruction(
      sidebar: EdgeInsets.fromLTRB(
        horizontal.left,
        vertical.top,
        horizontal.right,
        vertical.bottom,
      ),
      toolbar: horizontal,
    );
  }

  EdgeInsets? sidebarToolbarAvoidance({
    required SidebarLeadingScope? sidebarLeading,
    EdgeInsets? override,
  }) {
    if (override != null) return override;
    if (sidebarLeading == null) return null;

    final appBarAvoidance = AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
      this,
    );
    final sidebarAvoidance = sidebarLeading.toolbarAvoidance;
    return EdgeInsets.fromLTRB(
      math.max(appBarAvoidance.left, sidebarAvoidance.left),
      math.max(appBarAvoidance.top, sidebarAvoidance.top),
      math.max(appBarAvoidance.right, sidebarAvoidance.right),
      math.max(appBarAvoidance.bottom, sidebarAvoidance.bottom),
    );
  }
}
