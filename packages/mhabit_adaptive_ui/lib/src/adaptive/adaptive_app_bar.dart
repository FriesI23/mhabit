import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_sidebar_navigation_bar_bottom.dart';
import '../shell/sidebar_adapter.dart';
import '../window_control/cupertino_navigation_bar.dart';
import '../window_control/material_app_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];
const CupertinoSidebarToolbarGeometry _kBaseAppleToolbarGeometry =
    CupertinoSidebarToolbarGeometry(
      contentHeight: 44,
      collapsedBarHeight: 44,
      height: 44,
    );

/// Adaptive regular app bar for non-sliver page scaffolds.
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
    this.automaticBackgroundVisibility = false,
    this.sidebarToolbarGeometry = _kBaseAppleToolbarGeometry,
    required this.toolbarHeight,
  }) : _adaptiveStyle = null;

  const AdaptiveAppBar.material({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
  }) : automaticBackgroundVisibility = true,
       sidebarToolbarGeometry = _kBaseAppleToolbarGeometry,
       _adaptiveStyle = AdaptiveStyle.material;

  const AdaptiveAppBar.apple({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
    this.automaticBackgroundVisibility = false,
    this.sidebarToolbarGeometry = CupertinoSidebarToolbarGeometry.standard,
  }) : toolbarHeight = kMinInteractiveDimensionCupertino,
       _adaptiveStyle = AdaptiveStyle.apple;

  final AdaptiveStyle? _adaptiveStyle;
  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;

  /// Whether the Apple background and blur appear automatically when content
  /// scrolls behind the navigation bar.
  ///
  /// This defaults to false for a regular app bar because a Material
  /// [Scaffold] reserves the app-bar slot instead of scrolling its body behind
  /// it. Sliver app bars keep native automatic scroll-under behavior by
  /// default because they share the page's scrollable.
  final bool automaticBackgroundVisibility;

  /// Geometry used when this bar hosts a collapsed Cupertino sidebar.
  final CupertinoSidebarToolbarGeometry sidebarToolbarGeometry;

  /// Material toolbar height or the resolved adaptive toolbar height.
  ///
  /// The default adaptive constructor requires this value because
  /// [PreferredSizeWidget.preferredSize] has no [BuildContext] from which to
  /// resolve the active style. The Apple constructor uses the Cupertino
  /// minimum interactive dimension.
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
    _adaptiveStyle == AdaptiveStyle.material
        ? toolbarHeight
        : sidebarToolbarGeometry.height,
  );

  @override
  Widget build(BuildContext context) =>
      switch (_adaptiveStyle ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => MaterialAdaptiveAppBar(
          title: title,
          leading: leading,
          actions: actions,
          automaticallyImplyLeading: automaticallyImplyLeading,
          toolbarHeight: toolbarHeight,
        ),
        AdaptiveStyle.apple => CupertinoAdaptiveAppBar(
          title: title,
          leading: leading,
          actions: actions,
          automaticallyImplyLeading: automaticallyImplyLeading,
          automaticBackgroundVisibility: automaticBackgroundVisibility,
          sidebarToolbarGeometry: sidebarToolbarGeometry,
        ),
      };
}

/// Material renderer for the regular adaptive app bar.
class MaterialAdaptiveAppBar extends StatelessWidget {
  const MaterialAdaptiveAppBar({
    super.key,
    required this.title,
    required this.leading,
    required this.actions,
    required this.automaticallyImplyLeading,
    required this.toolbarHeight,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) => WindowControlAppBar(
    title: title,
    leading: leading,
    actions: actions,
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: false,
    toolbarHeight: toolbarHeight,
  );
}

class CupertinoAdaptiveAppBar extends StatelessWidget {
  const CupertinoAdaptiveAppBar({
    super.key,
    required this.title,
    required this.leading,
    required this.actions,
    required this.automaticallyImplyLeading,
    required this.automaticBackgroundVisibility,
    required this.sidebarToolbarGeometry,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final bool automaticBackgroundVisibility;
  final CupertinoSidebarToolbarGeometry sidebarToolbarGeometry;

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = SidebarLeadingScope.maybeOf(context);
    if (sidebarLeading != null) {
      final trailing = switch (actions) {
        [] => const SizedBox.shrink(),
        [final action] => action,
        _ => Row(mainAxisSize: MainAxisSize.min, children: actions),
      };
      return WindowControlCupertinoNavigationBar(
        automaticallyImplyLeading: false,
        automaticallyImplyMiddle: false,
        middle: CupertinoSidebarToolbarRegions(
          start: Row(
            children: [
              SizedBox(
                key: const ValueKey('cupertino-sidebar-leading-anchor'),
                width: sidebarLeading.reservedExtent,
                height: SidebarLeadingScope.buttonExtent,
              ),
              ?leading,
              Flexible(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: CupertinoSidebarToolbarLayout.titleStartPadding,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DefaultTextStyle.merge(
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: title,
                    ),
                  ),
                ),
              ),
            ],
          ),
          end: ClipRect(
            child: OverflowBox(
              alignment: AlignmentDirectional.centerEnd,
              minWidth: 0.0,
              maxWidth: double.infinity,
              child: trailing,
            ),
          ),
        ),
        backgroundColor: CupertinoColors.transparent,
        automaticBackgroundVisibility: automaticBackgroundVisibility,
        transitionBetweenRoutes: false,
        bottom: CupertinoSidebarNavigationBarBottom.maybeFromGeometry(
          sidebarToolbarGeometry,
        ),
        windowControlAvoidance: context.sidebarToolbarAvoidance(
          sidebarLeading: sidebarLeading,
        ),
      );
    }
    final trailing = actions.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: actions);
    return WindowControlCupertinoNavigationBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      middle: title,
      trailing: trailing,
      backgroundColor: CupertinoColors.transparent,
      automaticBackgroundVisibility: automaticBackgroundVisibility,
      transitionBetweenRoutes: false,
      bottom: CupertinoSidebarNavigationBarBottom.maybeFromGeometry(
        sidebarToolbarGeometry,
      ),
      windowControlAvoidance: context.sidebarToolbarAvoidance(
        sidebarLeading: null,
      ),
    );
  }
}
