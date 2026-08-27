import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_navigation_bar.dart';
import '../material/material_navigation_bar.dart';
import 'adaptive_navigation_destination.dart';

export '../cupertino/cupertino_adaptive_navigation_bar.dart'
    show AdaptiveNavigationBarPresentation, AppleNavigationBarStyle;
export '../material/material_navigation_bar.dart'
    show MaterialNavigationBarStyle;

/// Adaptive bottom navigation bar (box, for a `Scaffold.bottomNavigationBar`
/// slot).
///
/// The default constructor resolves the style from the current platform;
/// `.material` and `.apple` force a renderer.
class AdaptiveNavigationBar extends StatelessWidget {
  /// Creates a navigation bar using the ambient adaptive style.
  const AdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.presentation,
    this.onExpandRequested,
    this.materialStyle,
    this.appleStyle,
  }) : assert(
         presentation != AdaptiveNavigationBarPresentation.minimized ||
             onExpandRequested != null,
       ),
       style = null;

  /// Creates a navigation bar that always uses the Material renderer.
  const AdaptiveNavigationBar.material({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.materialStyle,
  }) : presentation = null,
       onExpandRequested = null,
       appleStyle = null,
       style = AdaptiveStyle.material;

  /// Creates a navigation bar that always uses the Apple renderer.
  const AdaptiveNavigationBar.apple({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.presentation,
    this.onExpandRequested,
    this.appleStyle,
  }) : assert(
         presentation != AdaptiveNavigationBarPresentation.minimized ||
             onExpandRequested != null,
       ),
       materialStyle = null,
       style = AdaptiveStyle.apple;

  /// Explicit renderer style, or null to resolve it from the context.
  final AdaptiveStyle? style;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Top-level destinations rendered by the bar.
  final List<AdaptiveNavigationDestination> destinations;

  /// Expanded or minimized presentation used by the Apple renderer.
  ///
  /// A null value resolves to [AdaptiveNavigationBarPresentation.expanded].
  final AdaptiveNavigationBarPresentation? presentation;

  /// Called when a minimized Apple bar requests expansion.
  final VoidCallback? onExpandRequested;

  /// Material-specific visual configuration, or null for the defaults.
  final MaterialNavigationBarStyle? materialStyle;

  /// Apple-specific geometry and spacing configuration, or null for defaults.
  final AppleNavigationBarStyle? appleStyle;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    final effectivePresentation =
        presentation ?? AdaptiveNavigationBarPresentation.expanded;
    final effectiveMaterialStyle =
        materialStyle ?? const MaterialNavigationBarStyle();
    final effectiveAppleStyle = appleStyle ?? const AppleNavigationBarStyle();
    return switch (effective) {
      AdaptiveStyle.apple => CupertinoAdaptiveNavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        onExpandRequested: onExpandRequested ?? () {},
        destinations: destinations,
        presentation: effectivePresentation,
        expandedNavigationWidth: effectiveAppleStyle.expandedNavigationWidth,
        floatingBottomMargin: effectiveAppleStyle.floatingBottomMargin,
      ),
      AdaptiveStyle.material => MaterialAdaptiveNavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        height: effectiveMaterialStyle.height,
        labelBehavior: effectiveMaterialStyle.labelBehavior,
      ),
    };
  }
}
