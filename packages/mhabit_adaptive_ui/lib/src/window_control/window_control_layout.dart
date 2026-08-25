import 'package:flutter/material.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';

enum WindowControlLayoutOwner { appBar, rail }

/// Queries iOS window-control layout once above an application's navigators.
///
/// Root routes and overlays default to app-bar ownership. A nested
/// [AdaptiveNavigationShell] overrides that allocation when a rail is visible.
class AdaptiveWindowControlLayout extends StatelessWidget {
  const AdaptiveWindowControlLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => IosWindowControlLayout(
    child: Builder(
      builder: (context) {
        final layout = IosWindowControlLayout.of(context);
        return AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: layout.horizontalAvoidance,
          verticalAvoidance: layout.verticalAvoidance,
          owner: WindowControlLayoutOwner.appBar,
          child: child,
        );
      },
    ),
  );
}

/// Distributes platform window-control avoidance between chrome consumers.
///
/// The application root defaults to app-bar ownership. A navigation shell
/// overrides this scope so rail layouts expose avoidance to the rail instead.
class AdaptiveWindowControlLayoutScope extends InheritedWidget {
  const AdaptiveWindowControlLayoutScope({
    super.key,
    required this.horizontalAvoidance,
    required this.verticalAvoidance,
    required this.owner,
    required super.child,
  });

  final EdgeInsetsDirectional horizontalAvoidance;
  final EdgeInsetsDirectional verticalAvoidance;
  final WindowControlLayoutOwner owner;

  EdgeInsetsDirectional get appBarHorizontalAvoidance =>
      owner == WindowControlLayoutOwner.appBar
      ? horizontalAvoidance
      : EdgeInsetsDirectional.zero;

  EdgeInsetsDirectional get railHorizontalAvoidance =>
      owner == WindowControlLayoutOwner.rail
      ? horizontalAvoidance
      : EdgeInsetsDirectional.zero;

  EdgeInsetsDirectional get railVerticalAvoidance =>
      owner == WindowControlLayoutOwner.rail
      ? verticalAvoidance
      : EdgeInsetsDirectional.zero;

  static AdaptiveWindowControlLayoutScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<AdaptiveWindowControlLayoutScope>();

  static EdgeInsetsDirectional appBarAvoidanceOf(BuildContext context) =>
      maybeOf(context)?.appBarHorizontalAvoidance ?? EdgeInsetsDirectional.zero;

  static EdgeInsetsDirectional railHorizontalAvoidanceOf(
    BuildContext context,
  ) => maybeOf(context)?.railHorizontalAvoidance ?? EdgeInsetsDirectional.zero;

  static EdgeInsetsDirectional railVerticalAvoidanceOf(BuildContext context) =>
      maybeOf(context)?.railVerticalAvoidance ?? EdgeInsetsDirectional.zero;

  @override
  bool updateShouldNotify(AdaptiveWindowControlLayoutScope oldWidget) =>
      horizontalAvoidance != oldWidget.horizontalAvoidance ||
      verticalAvoidance != oldWidget.verticalAvoidance ||
      owner != oldWidget.owner;
}
