import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/navigation_scroll_wish_policy.dart';
import '../shell/navigation_shell_frame.dart';
import '../shell/side_navigation.dart';
import '../window_control/window_control_layout.dart';
import 'material_navigation_bar.dart';
import 'material_navigation_rail.dart';

/// Composes the Material renderers around style-neutral shell mechanics.
///
/// Compact-width windows use a bottom bar. Medium-width windows and windows
/// with compact height use a collapsed rail; the remaining wider windows use
/// an extended rail.
///
/// ```text
/// compact          constrained side  expanded side
/// +----------+     +--+---------+    +------+-------+
/// | content  |     |  | content |    | rail |content|
/// +----------+     |r |         |    |      |       |
/// | nav bar  |     |a |         |    |      |       |
/// +----------+     |i |         |    +------+-------+
///                  |l |         |
///                  +--+---------+
/// ```
///
/// The extended rail uses [sideNavigationExtent] for its automatic width and resizable
/// interval. In compact form, route visibility, contextual chrome, and scroll
/// direction determine whether navigation is hidden. Side navigation remains
/// visible.
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
    required this.sideNavigationExtent,
    required this.railStyle,
    required this.dragHandleBuilder,
    required this.expandNavigationLabel,
    required this.collapseNavigationLabel,
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
  final SideNavigationExtent sideNavigationExtent;

  /// Material-specific rail geometry.
  final MaterialNavigationRailStyle railStyle;

  /// Visual displayed inside the rail resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Localized action label used when side navigation can expand.
  final String expandNavigationLabel;

  /// Localized action label used when side navigation can collapse.
  final String collapseNavigationLabel;

  @override
  Widget build(BuildContext context) {
    return NavigationShellFrame(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      compactRouteVisible: compactRouteVisible,
      contextualChromeSuppressed: contextualChromeSuppressed,
      barHeight: _barHeight,
      navHeight: _barHeight + MediaQuery.paddingOf(context).bottom,
      keepVisibleOnScroll: false,
      scrollWishPolicy: const NavigationScrollWishPolicy.directional(),
      formResolver: _resolveMaterialNavigationShellForm,
      bodyBuilder: (context, form, onSelected, child) =>
          _MaterialNavigationShellBody(
            form: form,
            selectedIndex: selectedIndex,
            destinations: destinations,
            onDestinationSelected: onSelected,
            sideNavigationExtent: sideNavigationExtent,
            railStyle: railStyle,
            dragHandleBuilder: dragHandleBuilder,
            expandNavigationLabel: expandNavigationLabel,
            collapseNavigationLabel: collapseNavigationLabel,
            child: child,
          ),
      windowControlOwnerResolver: _resolveMaterialWindowControlOwner,
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

NavigationShellForm _resolveMaterialNavigationShellForm(
  WindowSize windowSize,
) => switch (windowSize.width) {
  WindowSizeClass.compact => NavigationShellForm.compact,
  WindowSizeClass.medium => NavigationShellForm.constrainedSide,
  _ when windowSize.height == WindowSizeClass.compact =>
    NavigationShellForm.constrainedSide,
  _ => NavigationShellForm.expandedSide,
};

WindowControlLayoutOwner _resolveMaterialWindowControlOwner(
  NavigationShellForm form,
) => switch (form) {
  NavigationShellForm.compact => WindowControlLayoutOwner.appBar,
  NavigationShellForm.constrainedSide ||
  NavigationShellForm.expandedSide => WindowControlLayoutOwner.sideNavigation,
};

class _MaterialNavigationShellBody extends StatelessWidget {
  const _MaterialNavigationShellBody({
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.sideNavigationExtent,
    required this.railStyle,
    required this.dragHandleBuilder,
    required this.expandNavigationLabel,
    required this.collapseNavigationLabel,
    required this.child,
  });

  final NavigationShellForm form;
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final SideNavigationExtent sideNavigationExtent;
  final MaterialNavigationRailStyle railStyle;
  final SideNavigationDragHandleBuilder? dragHandleBuilder;
  final String expandNavigationLabel;
  final String collapseNavigationLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaterialNavigationRailRegion(
          form: form,
          selectedIndex: selectedIndex,
          destinations: destinations,
          onDestinationSelected: onDestinationSelected,
          sideNavigationExtent: sideNavigationExtent,
          style: railStyle,
          dragHandleBuilder: dragHandleBuilder,
          expandNavigationLabel: expandNavigationLabel,
          collapseNavigationLabel: collapseNavigationLabel,
        ),
        Expanded(
          child: _MaterialNavigationBranch(form: form, child: child),
        ),
      ],
    ),
  );
}

class _MaterialNavigationBranch extends StatelessWidget {
  const _MaterialNavigationBranch({required this.form, required this.child});

  final NavigationShellForm form;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (form == NavigationShellForm.compact) return child;

    // The rail consumes the shell's logical-start system inset. Remove only
    // that padding from the sibling branch so nested page SafeAreas do not
    // reserve it again, while keeping the opposite side available to content.
    final removeLeft = Directionality.of(context) == TextDirection.ltr;
    return MediaQuery.removePadding(
      context: context,
      removeLeft: removeLeft,
      removeRight: !removeLeft,
      child: child,
    );
  }
}
