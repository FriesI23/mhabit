import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/side_navigation.dart';
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
/// | content  |     | side |body |    | side |content|
/// +----------+     | bar  |     |    | bar  |       |
/// | Tab Bar  |     |      |     |    |      |       |
/// +----------+     +------+-----+    +------+-------+
/// ```
///
/// Medium and larger widths use the same hideable beside presentation. In
/// compact form, route and contextual state control visibility while scroll
/// direction selects the expanded or minimized Tab Bar presentation.
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
    required this.sideNavigationExtent,
    required this.dragHandleBuilder,
    required this.appleBarStyle,
    this.expandNavigationLabel,
    this.collapseNavigationLabel,
  });

  NavigationShellForm _resolveForm(WindowSize windowSize) =>
      switch (windowSize.width) {
        WindowSizeClass.compact => NavigationShellForm.compact,
        WindowSizeClass.medium => NavigationShellForm.constrainedSide,
        WindowSizeClass.expanded ||
        WindowSizeClass.large ||
        WindowSizeClass.extraLarge => NavigationShellForm.expandedSide,
      };

  WindowControlLayoutOwner _resolveWindowControlOwner(
    NavigationShellForm form,
  ) => switch (form) {
    NavigationShellForm.compact => WindowControlLayoutOwner.appBar,
    NavigationShellForm.constrainedSide ||
    NavigationShellForm.expandedSide => WindowControlLayoutOwner.sideNavigation,
  };

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

  /// Full-width policy used by the Sidebar panel.
  final SideNavigationExtent sideNavigationExtent;

  /// Optional visual displayed inside the Sidebar resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Geometry and spacing for the compact Apple navigation bar.
  final AppleNavigationBarStyle appleBarStyle;

  /// Localized action label used when the Sidebar can be shown.
  ///
  /// Defaults to the closest available Flutter localization.
  final String? expandNavigationLabel;

  /// Localized action label used when the Sidebar can be hidden.
  ///
  /// Defaults to the closest available Flutter localization.
  final String? collapseNavigationLabel;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    // Match the actual Material Scaffold surface during ThemeData animation.
    // CupertinoThemeData switches brightness discretely at the midpoint,
    // which otherwise makes an idle automatic navigation bar flash between
    // its light and dark scaffold colors while the page keeps interpolating.
    final scaffoldBackground = Theme.of(context).colorScheme.surface;
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
      formResolver: _resolveForm,
      bodyBuilder: (context, form, onSelected, child) =>
          CupertinoNavigationSidebar(
            form: form,
            selectedIndex: selectedIndex,
            destinations: destinations,
            onDestinationSelected: onSelected,
            sideNavigationExtent: sideNavigationExtent,
            dragHandleBuilder: dragHandleBuilder,
            expandNavigationLabel: expandNavigationLabel,
            collapseNavigationLabel: collapseNavigationLabel,
            child: child,
          ),
      windowControlOwnerResolver: _resolveWindowControlOwner,
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
