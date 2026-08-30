import 'package:flutter/widgets.dart';

/// Renderer-owned Sidebar command exposed to page app bars.
///
/// The navigation renderer owns the actual floating control. Page app bars
/// consume only this geometry so they reserve space beside existing leading
/// content without reparenting the control during route changes.
class NavigationSidebarAppBarLeading extends InheritedWidget {
  const NavigationSidebarAppBarLeading({
    super.key,
    required this.toolbarAvoidance,
    required this.toolbarTopInset,
    required this.progress,
    required super.child,
  });

  static const double buttonExtent = 44;

  /// Logical toolbar space occupied by platform window controls.
  final EdgeInsetsDirectional toolbarAvoidance;

  /// Extra top inset used to align a toolbar with floating side navigation.
  final double toolbarTopInset;

  /// Visibility progress for the AppBar's reserved leading slot.
  final double progress;

  /// Width reserved before the page-owned leading content.
  double get reservedExtent => buttonExtent * progress;

  static NavigationSidebarAppBarLeading? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<NavigationSidebarAppBarLeading>();

  @override
  bool updateShouldNotify(NavigationSidebarAppBarLeading oldWidget) =>
      toolbarAvoidance != oldWidget.toolbarAvoidance ||
      toolbarTopInset != oldWidget.toolbarTopInset ||
      progress != oldWidget.progress;
}
