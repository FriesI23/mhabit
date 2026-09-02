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
  });

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final PreferredSizeWidget? bottom;
  final AppBarMaterialStyle style;

  @override
  Widget build(BuildContext context) => WindowControlSliverAppBar(
    floating: style.floating,
    snap: style.snap,
    pinned: style.pinned,
    centerTitle: style.centerTitle,
    toolbarHeight: height ?? kToolbarHeight,
    forceElevated: style.forceElevated,
    scrolledUnderElevation: style.scrolledUnderElevation,
    shadowColor: style.shadowColor,
    bottom: style.bottom ?? bottom,
    title: title,
    automaticallyImplyLeading: leading == null && onLeadingPressed == null,
    leading:
        leading ??
        (onLeadingPressed == null
            ? null
            : IconButton(
                onPressed: onLeadingPressed,
                icon: const Icon(Icons.arrow_back),
              )),
    actions: actions.isEmpty ? null : actions,
    windowControlEdgePadding: style.windowControlEdgePadding,
  );
}
