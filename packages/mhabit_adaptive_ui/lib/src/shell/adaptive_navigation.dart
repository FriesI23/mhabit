import 'package:flutter/widgets.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_navigation_bar.dart'
    show AppleNavigationBarStyle;
import '../cupertino/cupertino_navigation_shell.dart';
import '../material/material_navigation_rail.dart' show NavigationRailExtent;
import '../material/material_navigation_shell.dart';

export '../material/material_navigation_rail.dart' show NavigationRailExtent;

/// Adaptive navigation chrome around [child].
///
/// The shell resolves the active visual style, while Material and Cupertino
/// renderers own their platform policy. Compact windows use a bottom bar,
/// medium windows use a collapsed rail, and wider windows use an extended rail
/// unless their height is compact.
///
/// ```text
/// compact          medium            expanded
/// +----------+     +--+---------+    +------+-------+
/// | content  |     |  | content |    | rail |content|
/// +----------+     |r |         |    |      |       |
/// | nav bar  |     |a |         |    |      |       |
/// +----------+     |i |         |    +------+-------+
///                  |l |         |
///                  +--+---------+
/// ```
///
/// The extended rail uses [railExtent] for its automatic width and resizable
/// interval. In compact form, route visibility, contextual chrome, and scroll
/// direction determine whether Material navigation is hidden or Apple
/// navigation is minimized. Non-compact navigation remains visible.
class AdaptiveNavigationShell extends StatefulWidget {
  /// Creates adaptive navigation chrome around [child].
  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.compactRouteVisible = true,
    this.railExtent = const NavigationRailExtent(224.0),
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

  /// Extended-rail sizing and manual-resize policy.
  final NavigationRailExtent railExtent;

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
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => MaterialNavigationShell(
        selectedIndex: widget.selectedIndex,
        destinations: widget.destinations,
        onDestinationSelected: widget.onDestinationSelected,
        compactRouteVisible: widget.compactRouteVisible,
        railExtent: widget.railExtent,
        child: child,
      ),
      AdaptiveStyle.apple => CupertinoNavigationShell(
        selectedIndex: widget.selectedIndex,
        destinations: widget.destinations,
        onDestinationSelected: widget.onDestinationSelected,
        compactRouteVisible: widget.compactRouteVisible,
        railExtent: widget.railExtent,
        appleBarStyle: widget.appleBarStyle,
        child: child,
      ),
    };
  }
}
