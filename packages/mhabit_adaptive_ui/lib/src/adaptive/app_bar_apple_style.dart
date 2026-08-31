import 'package:flutter/cupertino.dart';

import '../window_control/toolbar_geometry.dart';

/// Style config for the Apple branch of an adaptive AppBar.
class AppBarAppleStyle {
  const AppBarAppleStyle({
    this.collapsible = false,
    this.enableBackgroundFilterBlur = true,
    this.border,
    this.backgroundColor = CupertinoColors.transparent,
    this.automaticBackgroundVisibility = true,
    this.padding,
    this.stretch = false,
    this.windowControlEdgePadding = cupertinoWindowControlEdgePadding,
  });

  final bool collapsible;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color backgroundColor;
  final bool automaticBackgroundVisibility;
  final EdgeInsetsDirectional? padding;
  final bool stretch;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  AppBarAppleStyle copyWith({
    bool? collapsible,
    bool? enableBackgroundFilterBlur,
    Border? border,
    Color? backgroundColor,
    bool? automaticBackgroundVisibility,
    EdgeInsetsDirectional? padding,
    bool? stretch,
    EdgeInsetsDirectional? windowControlEdgePadding,
  }) => AppBarAppleStyle(
    collapsible: collapsible ?? this.collapsible,
    enableBackgroundFilterBlur:
        enableBackgroundFilterBlur ?? this.enableBackgroundFilterBlur,
    border: border ?? this.border,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    automaticBackgroundVisibility:
        automaticBackgroundVisibility ?? this.automaticBackgroundVisibility,
    padding: padding ?? this.padding,
    stretch: stretch ?? this.stretch,
    windowControlEdgePadding:
        windowControlEdgePadding ?? this.windowControlEdgePadding,
  );

  @override
  bool operator ==(Object other) =>
      other is AppBarAppleStyle &&
      other.collapsible == collapsible &&
      other.enableBackgroundFilterBlur == enableBackgroundFilterBlur &&
      other.border == border &&
      other.backgroundColor == backgroundColor &&
      other.automaticBackgroundVisibility == automaticBackgroundVisibility &&
      other.padding == padding &&
      other.stretch == stretch &&
      other.windowControlEdgePadding == windowControlEdgePadding;

  @override
  int get hashCode => Object.hash(
    collapsible,
    enableBackgroundFilterBlur,
    border,
    backgroundColor,
    automaticBackgroundVisibility,
    padding,
    stretch,
    windowControlEdgePadding,
  );
}
