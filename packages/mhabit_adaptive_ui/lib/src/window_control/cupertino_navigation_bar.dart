import 'package:flutter/cupertino.dart';

import 'toolbar_geometry.dart';

/// A [CupertinoNavigationBar] that pads only its leading and trailing controls.
///
/// The middle keeps Flutter's full-width centering and native collision clamp.
class WindowControlCupertinoNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const WindowControlCupertinoNavigationBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.automaticallyImplyMiddle = true,
    this.previousPageTitle,
    this.middle,
    this.trailing,
    this.border,
    this.backgroundColor,
    this.automaticBackgroundVisibility = true,
    this.enableBackgroundFilterBlur = true,
    this.brightness,
    this.padding,
    this.transitionBetweenRoutes = true,
    this.bottom,
    this.windowControlAvoidance,
    this.windowControlEdgePadding = cupertinoWindowControlEdgePadding,
  });

  /// {@macro flutter.cupertino.CupertinoNavigationBar.leading}
  final Widget? leading;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// See [CupertinoNavigationBar.automaticallyImplyMiddle].
  final bool automaticallyImplyMiddle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.previousPageTitle}
  final String? previousPageTitle;

  /// See [CupertinoNavigationBar.middle].
  final Widget? middle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.trailing}
  final Widget? trailing;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.border}
  final Border? border;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.automaticBackgroundVisibility}
  final bool automaticBackgroundVisibility;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.enableBackgroundFilterBlur}
  final bool enableBackgroundFilterBlur;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.brightness}
  final Brightness? brightness;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.padding}
  final EdgeInsetsDirectional? padding;

  /// See [CupertinoNavigationBar.transitionBetweenRoutes].
  final bool transitionBetweenRoutes;

  /// See [CupertinoNavigationBar.bottom].
  final PreferredSizeWidget? bottom;

  /// {@macro mhabit.windowControlAvoidance}
  final EdgeInsets? windowControlAvoidance;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  CupertinoNavigationBar _createNavigationBar({
    EdgeInsetsDirectional? effectivePadding,
    required Color? effectiveBackgroundColor,
  }) => CupertinoNavigationBar(
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    automaticallyImplyMiddle: automaticallyImplyMiddle,
    previousPageTitle: previousPageTitle,
    middle: middle,
    trailing: trailing,
    border: border,
    backgroundColor: effectiveBackgroundColor,
    automaticBackgroundVisibility: automaticBackgroundVisibility,
    enableBackgroundFilterBlur: enableBackgroundFilterBlur,
    brightness: brightness,
    padding: effectivePadding,
    transitionBetweenRoutes: transitionBetweenRoutes,
    bottom: bottom,
  );

  // Delegate framework-owned geometry and dynamic-color resolution instead of
  // copying Flutter's private navigation-bar behavior into this wrapper.
  @override
  Size get preferredSize => _createNavigationBar(
    effectivePadding: padding,
    effectiveBackgroundColor: backgroundColor,
  ).preferredSize;

  @override
  bool shouldFullyObstruct(BuildContext context) => _createNavigationBar(
    effectivePadding: padding,
    effectiveBackgroundColor: _resolveAutomaticBackgroundColor(
      context,
      backgroundColor: backgroundColor,
      automaticBackgroundVisibility: automaticBackgroundVisibility,
    ),
  ).shouldFullyObstruct(context);

  @override
  Widget build(BuildContext context) => _createNavigationBar(
    effectivePadding: _resolveCupertinoPadding(
      context,
      padding: padding,
      avoidance: windowControlAvoidance,
      edgePadding: windowControlEdgePadding,
    ),
    effectiveBackgroundColor: _resolveAutomaticBackgroundColor(
      context,
      backgroundColor: backgroundColor,
      automaticBackgroundVisibility: automaticBackgroundVisibility,
    ),
  );
}

/// A [CupertinoSliverNavigationBar] with window-control-aware toolbar padding.
///
/// Large-title geometry remains owned by Flutter; avoidance applies to the
/// compact toolbar controls only.
class WindowControlCupertinoSliverNavigationBar extends StatelessWidget {
  const WindowControlCupertinoSliverNavigationBar({
    super.key,
    this.largeTitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.automaticallyImplyTitle = true,
    this.previousPageTitle,
    this.middle,
    this.trailing,
    this.border,
    this.backgroundColor,
    this.automaticBackgroundVisibility = true,
    this.enableBackgroundFilterBlur = true,
    this.brightness,
    this.padding,
    this.stretch = false,
    this.bottom,
    this.windowControlAvoidance,
    this.windowControlEdgePadding = cupertinoWindowControlEdgePadding,
  });

  /// See [CupertinoSliverNavigationBar.largeTitle].
  final Widget? largeTitle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.leading}
  final Widget? leading;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// See [CupertinoSliverNavigationBar.automaticallyImplyTitle].
  final bool automaticallyImplyTitle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.previousPageTitle}
  final String? previousPageTitle;

  /// See [CupertinoSliverNavigationBar.middle].
  final Widget? middle;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.trailing}
  final Widget? trailing;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.border}
  final Border? border;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.automaticBackgroundVisibility}
  final bool automaticBackgroundVisibility;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.enableBackgroundFilterBlur}
  final bool enableBackgroundFilterBlur;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.brightness}
  final Brightness? brightness;

  /// {@macro flutter.cupertino.CupertinoNavigationBar.padding}
  final EdgeInsetsDirectional? padding;

  /// See [CupertinoSliverNavigationBar.stretch].
  final bool stretch;

  /// See [CupertinoSliverNavigationBar.bottom].
  final PreferredSizeWidget? bottom;

  /// {@macro mhabit.windowControlAvoidance}
  final EdgeInsets? windowControlAvoidance;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  Widget build(BuildContext context) => CupertinoSliverNavigationBar(
    largeTitle: largeTitle,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    automaticallyImplyTitle: automaticallyImplyTitle,
    previousPageTitle: previousPageTitle,
    middle: middle,
    trailing: trailing,
    border: border,
    backgroundColor: _resolveAutomaticBackgroundColor(
      context,
      backgroundColor: backgroundColor,
      automaticBackgroundVisibility: automaticBackgroundVisibility,
    ),
    automaticBackgroundVisibility: automaticBackgroundVisibility,
    enableBackgroundFilterBlur: enableBackgroundFilterBlur,
    brightness: brightness,
    padding: _resolveCupertinoPadding(
      context,
      padding: padding,
      avoidance: windowControlAvoidance,
      edgePadding: windowControlEdgePadding,
    ),
    stretch: stretch,
    bottom: bottom,
  );
}

Color? _resolveAutomaticBackgroundColor(
  BuildContext context, {
  required Color? backgroundColor,
  required bool automaticBackgroundVisibility,
}) {
  if (!automaticBackgroundVisibility || backgroundColor == null) {
    return backgroundColor;
  }
  final resolvedBackground = CupertinoDynamicColor.resolve(
    backgroundColor,
    context,
  );
  if (resolvedBackground.a != 0.0) return backgroundColor;

  final pageBackground =
      CupertinoPageScaffoldBackgroundColor.maybeOf(context) ??
      CupertinoTheme.of(context).scaffoldBackgroundColor;
  return CupertinoDynamicColor.resolve(
    pageBackground,
    context,
  ).withValues(alpha: 0.0);
}

EdgeInsetsDirectional _resolveCupertinoPadding(
  BuildContext context, {
  required EdgeInsetsDirectional? padding,
  required EdgeInsets? avoidance,
  required EdgeInsetsDirectional edgePadding,
}) {
  final geometry = WindowControlToolbarGeometry.resolve(
    context,
    avoidance: avoidance,
    edgePadding: padding ?? edgePadding,
  );
  return geometry.cupertinoInsets;
}
