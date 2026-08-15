import 'package:flutter/material.dart';

import '../adaptive_style.dart';

/// Adaptive sliver app bar.
///
/// Must be placed in a viewport `slivers:` list (e.g. `CustomScrollView`).
/// The default constructor resolves the style from the current platform;
/// [AdaptiveSliverAppBar.material] forces the Material style. Phase 3 adds
/// the apple style (`CupertinoSliverNavigationBar`-style) and an `.apple`
/// constructor.
class AdaptiveSliverAppBar extends StatelessWidget {
  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.onLeadingPressed,
    this.height,
  }) : style = null;

  const AdaptiveSliverAppBar.material({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.onLeadingPressed,
    this.height,
  }) : style = AdaptiveStyle.material;

  final AdaptiveStyle? style;
  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(adaptive-ui::apple): apple style (CupertinoSliverNavigationBar-style).
      AdaptiveStyle.apple || AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildMaterial() {
    // Equivalent of the app's current `SliverTopAppBar` baseline.
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: true,
      toolbarHeight: height ?? kToolbarHeight,
      shadowColor: Colors.transparent,
      title: title,
      leading:
          leading ??
          (onLeadingPressed == null
              ? null
              : IconButton(
                  onPressed: onLeadingPressed,
                  icon: const Icon(Icons.arrow_back),
                )),
      actions: actions.isEmpty ? null : actions,
    );
  }
}
