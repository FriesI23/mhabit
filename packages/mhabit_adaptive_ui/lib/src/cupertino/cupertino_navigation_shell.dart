import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    hide AdaptiveNavigationDestination, NavigationDestinationIcons;

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_form.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/sidebar_adapter.dart';
import '../window_control/window_control_layout.dart';
import 'cupertino_adaptive_navigation_bar.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_navigation_primary_action.dart';

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
class CupertinoNavigationShell extends StatefulWidget {
  /// Creates Cupertino navigation chrome around [child].
  const CupertinoNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.auxiliaryDestinations,
    required this.selectedAuxiliaryIndex,
    required this.onAuxiliaryDestinationSelected,
    required this.compactRouteVisible,
    required this.contextualChromeSuppressed,
    required this.primaryAction,
    required this.sideNavigationExtent,
    required this.dragHandleBuilder,
    required this.appleBarStyle,
    this.expandNavigationLabel,
    this.collapseNavigationLabel,
  });

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by Cupertino navigation chrome.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;
  final int? selectedAuxiliaryIndex;
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

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
  State<CupertinoNavigationShell> createState() =>
      _CupertinoNavigationShellState();
}

class _CupertinoNavigationShellState extends State<CupertinoNavigationShell> {
  final AdaptiveNavigationController _controller =
      AdaptiveNavigationController();

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    // Match the actual Material Scaffold surface during ThemeData animation.
    // CupertinoThemeData switches brightness discretely at the midpoint,
    // which otherwise makes an idle automatic navigation bar flash between
    // its light and dark scaffold colors while the page keeps interpolating.
    final scaffoldBackground = Theme.of(context).colorScheme.surface;
    return NavigationShellFrame(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      compactRouteVisible: widget.compactRouteVisible,
      contextualChromeSuppressed: widget.contextualChromeSuppressed,
      barHeight: CupertinoAdaptiveNavigationBar.contentHeight,
      navHeight: CupertinoAdaptiveNavigationBar.heightOf(
        context,
        floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
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
      bodyBuilder: (context, form, onSelected, child) {
        if (form == NavigationShellForm.compact) return child;

        final adapter = SidebarNavigationAdapter(
          destinations: widget.destinations,
          auxiliaryDestinations: widget.auxiliaryDestinations,
          selectedIndex: widget.selectedIndex,
          selectedAuxiliaryIndex: widget.selectedAuxiliaryIndex,
          onDestinationSelected: onSelected,
          onAuxiliaryDestinationSelected: widget.onAuxiliaryDestinationSelected,
        );
        return NavigationObstructionScope(
          obstruction: context.sidebarNavigationObstruction,
          child: CupertinoSidebar(
            controller: _controller,
            content: CupertinoSidebarNavigation(
              destinations: adapter.destinations,
              selection: adapter.selection,
              onSelectionChanged: adapter.select,
              auxiliaryDestinations: adapter.auxiliaryDestinations,
            ),
            extent: widget.sideNavigationExtent,
            dragHandleBuilder: widget.dragHandleBuilder,
            expandLabel: widget.expandNavigationLabel,
            collapseLabel: widget.collapseNavigationLabel,
            scaffoldBackgroundColor: scaffoldBackground,
            child: child,
          ),
        );
      },
      windowControlOwnerResolver: _resolveWindowControlOwner,
      compactNavigationBuilder: _buildCompactNavigation,
      floatingActionButtonBuilder: (context, state) =>
          CupertinoNavigationPrimaryActionHost(
            action: widget.primaryAction,
            scrollWish: state.scrollWish,
            visibility: state.visible,
            compact: state.form == NavigationShellForm.compact,
            routeVisible: widget.compactRouteVisible,
          ),
      floatingActionButtonLocation:
          CupertinoNavigationPrimaryActionButton.floatingLocationOf(context),
      child: CupertinoPageScaffoldBackgroundColor(
        color: scaffoldBackground,
        child: widget.child,
      ),
    );
  }

  Widget _buildCompactNavigation(
    BuildContext context,
    NavigationShellChromeState state,
  ) {
    final widget = this.widget;
    return ValueListenableBuilder<bool>(
      valueListenable: state.scrollWish,
      builder: (context, scrollWish, child) =>
          CompactNavigationChromeTransition(
            visibility: state.visible,
            collapseLayout: true,
            topClipOverflow: CupertinoFloatingGlassSurface.shadowClipOverflow,
            child: CupertinoAdaptiveNavigationBar(
              selectedIndex: widget.selectedIndex,
              presentation: scrollWish
                  ? AdaptiveNavigationBarPresentation.expanded
                  : AdaptiveNavigationBarPresentation.minimized,
              onExpandRequested: () => state.reportScrollWish(true),
              reservePrimaryActionSpace: widget.primaryAction != null,
              expandedNavigationWidth:
                  widget.appleBarStyle.expandedNavigationWidth,
              floatingBottomMargin: widget.appleBarStyle.floatingBottomMargin,
              destinations: widget.destinations,
              onDestinationSelected: state.onDestinationSelected,
            ),
          ),
    );
  }
}
