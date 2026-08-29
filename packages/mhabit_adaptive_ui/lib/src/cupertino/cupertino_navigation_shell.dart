import 'package:flutter/cupertino.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../material/material_navigation_rail.dart' show NavigationRailExtent;
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_frame.dart';
import '../window_control/window_control_layout.dart';
import 'cupertino_adaptive_navigation_bar.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';
import 'cupertino_navigation_sidebar.dart';

/// Composes the Cupertino renderers around style-neutral shell mechanics.
///
/// Forms are resolved only from Apple width classes; compact height never
/// downgrades a wider window to constrained side navigation.
///
/// ```text
/// compact          constrained side  expanded side
/// +----------+     +------------+    +------+-------+
/// | content  |     |  overlay   |    | side |content|
/// +----------+     |  Sidebar   |    | bar  |       |
/// | Tab Bar  |     +------------+    |      |       |
/// +----------+                       +------+-------+
/// ```
///
/// The side-form diagrams show the target Cupertino presentation. The
/// compatibility rail preserves current behavior until the Sidebar renderer
/// replaces it. In compact form, route and contextual state control visibility
/// while scroll direction selects the expanded or minimized Tab Bar
/// presentation.
class CupertinoNavigationShell extends StatelessWidget {
  /// Creates Cupertino navigation chrome around [child].
  const CupertinoNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.compactRouteVisible,
    required this.contextualChromeSuppressed,
    required this.primaryAction,
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

  /// Whether contextual commands suppress compact navigation chrome.
  final bool contextualChromeSuppressed;

  /// App-selected primary action for the active branch.
  final CupertinoNavigationPrimaryAction? primaryAction;

  /// Full-width policy shared by the compatibility rail and future sidebar.
  final NavigationRailExtent railExtent;

  /// Geometry and spacing for the compact Apple navigation bar.
  final AppleNavigationBarStyle appleBarStyle;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final scaffoldBackground = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).scaffoldBackgroundColor,
      context,
    );
    return NavigationShellFrame(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      compactRouteVisible: compactRouteVisible,
      contextualChromeSuppressed: contextualChromeSuppressed,
      barHeight: CupertinoAdaptiveNavigationBar.contentHeight,
      navHeight: CupertinoAdaptiveNavigationBar.heightOf(
        context,
        floatingBottomMargin: appleBarStyle.floatingBottomMargin,
      ),
      keepVisibleOnScroll: true,
      scrollWishPolicy: const NavigationScrollWishPolicy.flingThreshold(
        distanceFactor: 1.5,
        velocityFactor: 1.5,
      ),
      switchDuration: disableAnimations
          ? Duration.zero
          : navigationShellAnimationDuration,
      formResolver: _resolveCupertinoNavigationShellForm,
      bodyBuilder: (context, form, onSelected, child) =>
          CupertinoNavigationSidebarCompatibility(
            form: form,
            selectedIndex: selectedIndex,
            destinations: destinations,
            onDestinationSelected: onSelected,
            railExtent: railExtent,
            child: child,
          ),
      windowControlOwnerResolver: _resolveCupertinoWindowControlOwner,
      compactNavigationBuilder: _buildCompactNavigation,
      floatingActionButtonBuilder: (context, state) =>
          CupertinoNavigationPrimaryActionHost(
            action: primaryAction,
            scrollWish: state.scrollWish,
            visibility: state.visible,
            compact: state.compact,
            routeVisible: compactRouteVisible,
          ),
      floatingActionButtonLocation:
          CupertinoNavigationPrimaryActionButton.floatingLocationOf(context),
      child: CupertinoPageScaffoldBackgroundColor(
        color: scaffoldBackground,
        child: child,
      ),
    );
  }

  Widget _buildCompactNavigation(
    BuildContext context,
    NavigationShellChromeState state,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: state.scrollWish,
      builder: (context, scrollWish, child) =>
          CompactNavigationChromeTransition(
            visibility: state.visible,
            collapseLayout: true,
            topClipOverflow: CupertinoFloatingGlassSurface.shadowClipOverflow,
            child: CupertinoAdaptiveNavigationBar(
              selectedIndex: selectedIndex,
              presentation: scrollWish
                  ? AdaptiveNavigationBarPresentation.expanded
                  : AdaptiveNavigationBarPresentation.minimized,
              onExpandRequested: () => state.reportScrollWish(true),
              reservePrimaryActionSpace: primaryAction != null,
              expandedNavigationWidth: appleBarStyle.expandedNavigationWidth,
              floatingBottomMargin: appleBarStyle.floatingBottomMargin,
              destinations: destinations,
              onDestinationSelected: state.onDestinationSelected,
            ),
          ),
    );
  }
}

NavigationShellForm _resolveCupertinoNavigationShellForm(
  WindowSize windowSize,
) => switch (windowSize.width) {
  WindowSizeClass.compact => NavigationShellForm.compact,
  WindowSizeClass.medium => NavigationShellForm.constrainedSide,
  WindowSizeClass.expanded ||
  WindowSizeClass.large ||
  WindowSizeClass.extraLarge => NavigationShellForm.expandedSide,
};

WindowControlLayoutOwner _resolveCupertinoWindowControlOwner(
  NavigationShellForm form,
) => switch (form) {
  NavigationShellForm.compact => WindowControlLayoutOwner.appBar,
  NavigationShellForm.constrainedSide ||
  NavigationShellForm.expandedSide => WindowControlLayoutOwner.sideNavigation,
};
