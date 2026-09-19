import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/cupertino.dart';

import '../window_control/toolbar_geometry.dart';

part 'app_bar_apple_style.g.dart';

/// Style config for the Apple branch of an adaptive AppBar.
@CopyWith(skipFields: true)
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
