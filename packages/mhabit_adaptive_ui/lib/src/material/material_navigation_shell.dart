import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_frame.dart';
import 'material_navigation_bar.dart';
import 'material_navigation_rail.dart';

/// Composes the Material renderers around style-neutral shell mechanics.
class MaterialNavigationShell extends StatelessWidget {
  /// Creates Material navigation chrome around [child].
  const MaterialNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.compactRouteVisible,
    required this.contextualChromeSuppressed,
    required this.railExtent,
  });

  static const double _barHeight = 80.0;

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by Material navigation chrome.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Whether route structure allows compact navigation to be shown.
  final bool compactRouteVisible;

  /// Whether contextual commands suppress compact navigation chrome.
  final bool contextualChromeSuppressed;

  /// Automatic and manually resizable rail-width policy.
  final NavigationRailExtent railExtent;

  @override
  Widget build(BuildContext context) {
    return NavigationShellFrame(
      selectedIndex: selectedIndex,
      destinations: destinations,
      onDestinationSelected: onDestinationSelected,
      compactRouteVisible: compactRouteVisible,
      contextualChromeSuppressed: contextualChromeSuppressed,
      barHeight: _barHeight,
      navHeight: _barHeight + MediaQuery.paddingOf(context).bottom,
      keepVisibleOnScroll: false,
      scrollWishPolicy: const NavigationScrollWishPolicy.directional(),
      leadingBuilder: (context, form, onSelected) =>
          MaterialNavigationRailRegion(
            form: form,
            selectedIndex: selectedIndex,
            destinations: destinations,
            onDestinationSelected: onSelected,
            railExtent: railExtent,
          ),
      compactNavigationBuilder: (context, state) =>
          CompactNavigationChromeTransition(
            visibility: state.visible,
            collapseLayout: true,
            child: MaterialAdaptiveNavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: state.onDestinationSelected,
              destinations: destinations,
              height: _barHeight,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
      child: child,
    );
  }
}
