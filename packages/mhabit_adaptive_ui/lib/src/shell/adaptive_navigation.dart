import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/widgets.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_navigation_bar.dart'
    show AppleNavigationBarStyle;
import '../cupertino/cupertino_navigation_primary_action.dart'
    show CupertinoNavigationPrimaryAction;
import '../cupertino/cupertino_navigation_shell.dart';
import '../material/material_navigation_rail.dart'
    show MaterialNavigationRailStyle;
import '../material/material_navigation_shell.dart';
import 'side_navigation.dart';

export '../material/material_navigation_rail.dart'
    show MaterialNavigationRailStyle;
export 'side_navigation.dart'
    show SideNavigationDragHandleBuilder, SideNavigationExtent;

/// Adaptive navigation chrome around [child].
///
/// The shell resolves the active visual style, while Material and Cupertino
/// renderers own their form resolution, body composition, inset policy, and
/// window-control ownership. Compact windows use bottom navigation. Material
/// side forms use collapsed or extended rails; Apple medium and larger forms
/// use one hideable beside Sidebar.
///
/// ```text
/// form              Material              Apple
/// compact           bottom bar            bottom Tab Bar
/// constrained side  collapsed rail        beside Sidebar
/// expanded side     extended rail         beside Sidebar
/// ```
///
/// Apple side forms share the same visibility and width state. Hiding the
/// Sidebar removes it completely instead of leaving an icon-only rail. In
/// compact form, route visibility, contextual chrome, and scroll direction
/// determine whether Material navigation is hidden or Apple navigation is
/// minimized.
class AdaptiveNavigationShell extends StatefulWidget {
  /// Creates adaptive navigation chrome around [child].
  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.compactRouteVisible = true,
    this.contextualChromeSuppressed = false,
    this.applePrimaryAction,
    this.sideNavigationExtent = const SideNavigationExtent(224.0),
    this.materialRailStyle = const MaterialNavigationRailStyle(),
    this.sideNavigationDragHandleBuilder,
    this.appleBarStyle = const AppleNavigationBarStyle(),
  });

  /// Content displayed beside or underneath the navigation chrome.
  final Widget child;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level navigation destinations.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Whether route structure allows compact navigation to be shown.
  ///
  /// The caller owns route-stack interpretation. Ignored in non-compact forms,
  /// where navigation remains visible.
  final bool compactRouteVisible;

  /// Whether a contextual command surface suppresses compact navigation.
  final bool contextualChromeSuppressed;

  /// App-selected primary command rendered at the Apple shell's trailing
  /// bottom edge.
  ///
  /// This is not a page-owned Material FAB. Material renderers ignore the
  /// command and continue to use page-owned Scaffold FAB slots. See
  /// [CupertinoNavigationPrimaryAction] for placement diagrams.
  final CupertinoNavigationPrimaryAction? applePrimaryAction;

  /// Full-width side-navigation sizing and manual-resize policy.
  ///
  /// Both renderers use this policy for their full-width side navigation.
  final SideNavigationExtent sideNavigationExtent;

  /// Material-specific NavigationRail geometry.
  final MaterialNavigationRailStyle materialRailStyle;

  /// Optional visual displayed inside the side-navigation resize target.
  ///
  /// When null, Material displays its default drag bar while Cupertino keeps
  /// the target visually empty. An explicit builder is used by both renderers.
  final SideNavigationDragHandleBuilder? sideNavigationDragHandleBuilder;

  /// Apple compact navigation-bar geometry and spacing.
  final AppleNavigationBarStyle appleBarStyle;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  final GlobalKey _childKey = GlobalKey(
    debugLabel: 'adaptive-navigation-shell-child',
  );

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final expandNavigationLabel =
        materialLocalizations?.collapsedIconTapHint ?? 'Expand';
    final collapseNavigationLabel =
        materialLocalizations?.expandedIconTapHint ?? 'Collapse';
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialNavigationShell(
        selectedIndex: widget.selectedIndex,
        destinations: widget.destinations,
        onDestinationSelected: widget.onDestinationSelected,
        compactRouteVisible: widget.compactRouteVisible,
        contextualChromeSuppressed: widget.contextualChromeSuppressed,
        sideNavigationExtent: widget.sideNavigationExtent,
        railStyle: widget.materialRailStyle,
        dragHandleBuilder: widget.sideNavigationDragHandleBuilder,
        expandNavigationLabel: expandNavigationLabel,
        collapseNavigationLabel: collapseNavigationLabel,
        child: child,
      ),
      AdaptiveStyle.apple => CupertinoNavigationShell(
        selectedIndex: widget.selectedIndex,
        destinations: widget.destinations,
        onDestinationSelected: widget.onDestinationSelected,
        compactRouteVisible: widget.compactRouteVisible,
        contextualChromeSuppressed: widget.contextualChromeSuppressed,
        primaryAction: widget.applePrimaryAction,
        sideNavigationExtent: widget.sideNavigationExtent,
        dragHandleBuilder: widget.sideNavigationDragHandleBuilder,
        appleBarStyle: widget.appleBarStyle,
        child: child,
      ),
    };
  }
}
