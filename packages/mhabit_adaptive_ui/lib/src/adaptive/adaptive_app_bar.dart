import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../shell/navigation_sidebar_app_bar_leading.dart';
import '../window_control/cupertino_navigation_bar.dart';
import '../window_control/material_app_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];
const double _kCupertinoToolbarHeight = 44.0;

/// Adaptive regular app bar for non-sliver page scaffolds.
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
    required this.toolbarHeight,
  }) : _adaptiveStyle = null;

  const AdaptiveAppBar.material({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
  }) : _adaptiveStyle = AdaptiveStyle.material;

  const AdaptiveAppBar.apple({
    super.key,
    required this.title,
    this.leading,
    this.actions = _kDefaultActions,
    this.automaticallyImplyLeading = true,
  }) : toolbarHeight = _kCupertinoToolbarHeight,
       _adaptiveStyle = AdaptiveStyle.apple;

  final AdaptiveStyle? _adaptiveStyle;
  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;

  /// Material toolbar height or the resolved adaptive toolbar height.
  ///
  /// The default adaptive constructor requires this value because
  /// [PreferredSizeWidget.preferredSize] has no [BuildContext] from which to
  /// resolve the active style. The Apple constructor fixes it to 44pt.
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) =>
      switch (_adaptiveStyle ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => WindowControlAppBar(
          title: title,
          leading: leading,
          actions: actions,
          automaticallyImplyLeading: automaticallyImplyLeading,
          toolbarHeight: toolbarHeight,
        ),
        AdaptiveStyle.apple => _CupertinoAdaptiveAppBar(
          title: title,
          leading: leading,
          actions: actions,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      };
}

class _CupertinoAdaptiveAppBar extends StatelessWidget {
  const _CupertinoAdaptiveAppBar({
    required this.title,
    required this.leading,
    required this.actions,
    required this.automaticallyImplyLeading,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = NavigationSidebarAppBarLeading.maybeOf(context);
    final effectiveLeading = sidebarLeading == null && leading == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sidebarLeading case final sidebarLeading?)
                SizedBox(
                  key: const ValueKey('cupertino-sidebar-leading-anchor'),
                  width: sidebarLeading.reservedExtent,
                  height: NavigationSidebarAppBarLeading.buttonExtent,
                ),
              ?leading,
            ],
          );
    final trailing = actions.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: actions);
    return WindowControlCupertinoNavigationBar(
      leading: effectiveLeading,
      automaticallyImplyLeading:
          sidebarLeading == null && automaticallyImplyLeading,
      middle: title,
      trailing: trailing,
      backgroundColor: CupertinoColors.transparent,
      automaticBackgroundVisibility: false,
      transitionBetweenRoutes: false,
      windowControlAvoidance: sidebarLeading?.toolbarAvoidance,
    );
  }
}
