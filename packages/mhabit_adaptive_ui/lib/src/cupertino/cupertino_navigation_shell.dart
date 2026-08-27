import 'package:flutter/cupertino.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../material/material_navigation_rail.dart' show NavigationRailExtent;
import '../shell/navigation_shell_frame.dart';
import 'cupertino_adaptive_navigation_bar.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';
import 'cupertino_navigation_sidebar.dart';

/// Composes the Cupertino renderers around style-neutral shell mechanics.
class CupertinoNavigationShell extends StatefulWidget {
  /// Creates Cupertino navigation chrome around [child].
  const CupertinoNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.compactRouteVisible,
    required this.railExtent,
    required this.appleBarStyle,
  });

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by Cupertino navigation chrome.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Whether route structure allows compact navigation to be shown.
  final bool compactRouteVisible;

  /// Width policy used by the temporary medium-and-wider rail renderer.
  final NavigationRailExtent railExtent;

  /// Geometry and spacing for the compact Apple navigation bar.
  final AppleNavigationBarStyle appleBarStyle;

  @override
  State<CupertinoNavigationShell> createState() =>
      _CupertinoNavigationShellState();
}

class _CupertinoNavigationShellState extends State<CupertinoNavigationShell> {
  final CupertinoNavigationPrimaryActionController _primaryAction =
      CupertinoNavigationPrimaryActionController();
  int _primaryActionGeneration = 0;

  @override
  void didUpdateWidget(covariant CupertinoNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _primaryActionGeneration += 1;
    }
  }

  @override
  void dispose() {
    _primaryAction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return NavigationShellFrame(
      selectedIndex: widget.selectedIndex,
      destinations: widget.destinations,
      onDestinationSelected: widget.onDestinationSelected,
      compactRouteVisible: widget.compactRouteVisible,
      barHeight: CupertinoAdaptiveNavigationBar.contentHeight,
      navHeight: CupertinoAdaptiveNavigationBar.heightOf(
        context,
        floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
      ),
      keepVisibleOnScroll: true,
      switchDuration: disableAnimations
          ? Duration.zero
          : navigationShellAnimationDuration,
      leadingBuilder: (context, form, onSelected) =>
          CupertinoNavigationSidebarCompatibility(
            form: form,
            selectedIndex: widget.selectedIndex,
            destinations: widget.destinations,
            onDestinationSelected: onSelected,
            railExtent: widget.railExtent,
          ),
      compactNavigationBuilder: _buildCompactNavigation,
      floatingActionButtonBuilder: (context, state) =>
          CupertinoNavigationPrimaryActionHost(
            action: _primaryAction,
            scrollWish: state.scrollWish,
            visibility: state.visible,
            compact: state.compact,
            routeVisible: widget.compactRouteVisible,
          ),
      floatingActionButtonLocation:
          CupertinoNavigationPrimaryActionButton.floatingLocationOf(context),
      child: CupertinoNavigationPrimaryActionScope(
        controller: _primaryAction,
        generation: _primaryActionGeneration,
        child: widget.child,
      ),
    );
  }

  Widget _buildCompactNavigation(
    BuildContext context,
    NavigationShellChromeState state,
  ) {
    return ValueListenableBuilder<CupertinoNavigationPrimaryAction?>(
      valueListenable: _primaryAction,
      builder: (context, primaryAction, child) => ValueListenableBuilder<bool>(
        valueListenable: state.scrollWish,
        builder: (context, scrollWish, child) =>
            CompactNavigationChromeTransition(
              visibility: state.visible,
              collapseLayout: true,
              progressKey: const ValueKey('compact-navigation-chrome-opacity'),
              topClipOverflow: CupertinoFloatingGlassSurface.shadowClipOverflow,
              child: CupertinoAdaptiveNavigationBar(
                selectedIndex: widget.selectedIndex,
                presentation: scrollWish
                    ? AdaptiveNavigationBarPresentation.expanded
                    : AdaptiveNavigationBarPresentation.minimized,
                onExpandRequested: () => state.reportScrollWish(true),
                reservePrimaryActionSpace: primaryAction != null,
                expandedNavigationWidth:
                    widget.appleBarStyle.expandedNavigationWidth,
                floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
                destinations: widget.destinations,
                onDestinationSelected: state.onDestinationSelected,
              ),
            ),
      ),
    );
  }
}
