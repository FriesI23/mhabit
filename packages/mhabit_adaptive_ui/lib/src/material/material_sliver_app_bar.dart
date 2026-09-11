import 'package:flutter/material.dart';

import '../window_control/material_app_bar.dart';
import 'app_bar_material_style.dart';

/// Material renderer for the adaptive sliver app-bar facade.
class MaterialSliverAppBar extends StatelessWidget {
  const MaterialSliverAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.style,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
  }) : _variant = _MaterialSliverAppBarVariant.small;

  const MaterialSliverAppBar.medium({
    super.key,
    required this.title,
    required this.actions,
    required this.style,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
  }) : _variant = _MaterialSliverAppBarVariant.medium;

  const MaterialSliverAppBar.large({
    super.key,
    required this.title,
    required this.actions,
    required this.style,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
  }) : _variant = _MaterialSliverAppBarVariant.large;

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final PreferredSizeWidget? bottom;
  final AppBarMaterialStyle style;
  final _MaterialSliverAppBarVariant _variant;

  @override
  Widget build(BuildContext context) {
    final resolvedLeading =
        leading ??
        (onLeadingPressed == null
            ? null
            : IconButton(
                onPressed: onLeadingPressed,
                icon: const Icon(Icons.arrow_back),
              ));
    final automaticallyImplyLeading =
        leading == null && onLeadingPressed == null;
    final actions = this.actions.isEmpty ? null : this.actions;
    final effectiveBottom = style.bottom ?? bottom;

    return switch (_variant) {
      _MaterialSliverAppBarVariant.small => WindowControlSliverAppBar(
        floating: style.floating,
        snap: style.snap,
        pinned: style.pinned,
        centerTitle: style.centerTitle,
        toolbarHeight: height ?? kToolbarHeight,
        forceElevated: style.forceElevated,
        scrolledUnderElevation: style.scrolledUnderElevation,
        shadowColor: style.shadowColor,
        backgroundColor: style.backgroundColor,
        surfaceTintColor: style.surfaceTintColor,
        bottom: effectiveBottom,
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: resolvedLeading,
        actions: actions,
        windowControlEdgePadding: style.windowControlEdgePadding,
      ),
      _MaterialSliverAppBarVariant.medium => WindowControlSliverAppBar.medium(
        floating: style.floating,
        snap: style.snap,
        pinned: style.pinned,
        centerTitle: style.centerTitle,
        toolbarHeight: height,
        forceElevated: style.forceElevated,
        scrolledUnderElevation: style.scrolledUnderElevation,
        shadowColor: style.shadowColor,
        backgroundColor: style.backgroundColor,
        surfaceTintColor: style.surfaceTintColor,
        bottom: effectiveBottom,
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: resolvedLeading,
        actions: actions,
        windowControlEdgePadding: style.windowControlEdgePadding,
      ),
      _MaterialSliverAppBarVariant.large => WindowControlSliverAppBar.large(
        floating: style.floating,
        snap: style.snap,
        pinned: style.pinned,
        centerTitle: style.centerTitle,
        toolbarHeight: height,
        forceElevated: style.forceElevated,
        scrolledUnderElevation: style.scrolledUnderElevation,
        shadowColor: style.shadowColor,
        backgroundColor: style.backgroundColor,
        surfaceTintColor: style.surfaceTintColor,
        bottom: effectiveBottom,
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: resolvedLeading,
        actions: actions,
        windowControlEdgePadding: style.windowControlEdgePadding,
      ),
    };
  }
}

enum _MaterialSliverAppBarVariant { small, medium, large }
