import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_adaptive_navigation_bar.dart';
import 'adaptive_navigation_bar_presentation.dart';
import 'adaptive_navigation_destination.dart';

/// Material-only visual configuration for [AdaptiveNavigationBar].
class MaterialNavigationBarStyle {
  const MaterialNavigationBarStyle({this.height, this.labelBehavior});

  final double? height;
  final NavigationDestinationLabelBehavior? labelBehavior;
}

/// Apple-only visual configuration for [AdaptiveNavigationBar].
class AppleNavigationBarStyle {
  /// Creates Apple navigation-bar styling.
  ///
  /// A null or infinite [expandedNavigationWidth] uses all available width.
  const AppleNavigationBarStyle({
    this.expandedNavigationWidth,
    this.floatingBottomMargin,
  }) : assert(expandedNavigationWidth == null || expandedNavigationWidth > 0),
       assert(
         floatingBottomMargin == null ||
             (floatingBottomMargin >= 0 &&
                 floatingBottomMargin < double.infinity),
       );

  /// Preferred width of the expanded destination surface.
  ///
  /// A null or infinite value fills the space available before the trailing
  /// action boundary. A finite value is clamped when the compact width is
  /// smaller, while any remaining space stays flexible.
  final double? expandedNavigationWidth;

  /// Overrides the distance between the floating surfaces and the bottom.
  ///
  /// When null, the renderer combines UIKit's reported boundary geometry with
  /// Flutter's bottom view padding and its visual baseline. Values must be
  /// finite and non-negative; values smaller than the renderer's minimum
  /// surface margin are clamped.
  final double? floatingBottomMargin;
}

/// Adaptive bottom navigation bar (box, for a `Scaffold.bottomNavigationBar`
/// slot).
///
/// The default constructor resolves the style from the current platform;
/// `.material` and `.apple` force a renderer.
class AdaptiveNavigationBar extends StatelessWidget {
  const AdaptiveNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.presentation = AdaptiveNavigationBarPresentation.expanded,
    this.onExpandRequested,
    this.materialStyle = const MaterialNavigationBarStyle(),
    this.appleStyle = const AppleNavigationBarStyle(),
  }) : assert(
         presentation != AdaptiveNavigationBarPresentation.minimized ||
             onExpandRequested != null,
       ),
       style = null;

  const AdaptiveNavigationBar.material({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.materialStyle = const MaterialNavigationBarStyle(),
  }) : presentation = AdaptiveNavigationBarPresentation.expanded,
       onExpandRequested = null,
       appleStyle = const AppleNavigationBarStyle(),
       style = AdaptiveStyle.material;

  const AdaptiveNavigationBar.apple({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.presentation = AdaptiveNavigationBarPresentation.expanded,
    this.onExpandRequested,
    this.appleStyle = const AppleNavigationBarStyle(),
  }) : assert(
         presentation != AdaptiveNavigationBarPresentation.minimized ||
             onExpandRequested != null,
       ),
       materialStyle = const MaterialNavigationBarStyle(),
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationBarPresentation presentation;
  final VoidCallback? onExpandRequested;
  final MaterialNavigationBarStyle materialStyle;
  final AppleNavigationBarStyle appleStyle;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      AdaptiveStyle.apple => CupertinoAdaptiveNavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        onExpandRequested: onExpandRequested ?? () {},
        destinations: destinations,
        presentation: presentation,
        expandedNavigationWidth: appleStyle.expandedNavigationWidth,
        floatingBottomMargin: appleStyle.floatingBottomMargin,
      ),
      AdaptiveStyle.material => _buildMaterial(context),
    };
  }

  Widget _buildMaterial(BuildContext context) {
    // NavigationBar has no built-in blur or opacity, so translucency comes
    // from the background color's alpha. Keep the default theme otherwise.
    final backgroundColor = Theme.of(
      context,
    ).colorScheme.surfaceContainer.withValues(alpha: 0.8);
    return NavigationBarTheme(
      data: NavigationBarThemeData(backgroundColor: backgroundColor),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: destination.icons.material,
              selectedIcon: destination.icons.materialSelected,
              label: destination.label,
              tooltip: destination.effectiveSemanticsLabel,
            ),
        ],
        onDestinationSelected: onDestinationSelected,
        height: materialStyle.height,
        labelBehavior: materialStyle.labelBehavior,
      ),
    );
  }
}
