import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_sliver_app_bar.dart';
import '../window_control/material_app_bar.dart';
import '../window_control/toolbar_geometry.dart';
import 'app_bar_apple_style.dart';

export 'app_bar_apple_style.dart' show AppBarAppleStyle;

const List<Widget> _kDefaultActions = <Widget>[];

/// Style config for the Material branch of [AdaptiveSliverAppBar].
///
/// App-bar fields map to [SliverAppBar]. [windowControlEdgePadding] is the
/// Material visual baseline added only on sides with window-control avoidance.
class AppBarMaterialStyle {
  const AppBarMaterialStyle({
    this.centerTitle = true,
    this.floating = true,
    this.snap = true,
    this.pinned = true,
    this.forceElevated = false,
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
    this.bottom,
    this.toolbarHeight,
    this.windowControlEdgePadding = materialWindowControlEdgePadding,
  });

  final bool centerTitle;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool forceElevated;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
  final PreferredSizeWidget? bottom;

  /// Material-only toolbar height, overriding the shared app-bar height.
  final double? toolbarHeight;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  AppBarMaterialStyle copyWith({
    bool? centerTitle,
    bool? floating,
    bool? snap,
    bool? pinned,
    bool? forceElevated,
    double? scrolledUnderElevation,
    Color? shadowColor,
    PreferredSizeWidget? bottom,
    double? toolbarHeight,
    EdgeInsetsDirectional? windowControlEdgePadding,
  }) => AppBarMaterialStyle(
    centerTitle: centerTitle ?? this.centerTitle,
    floating: floating ?? this.floating,
    snap: snap ?? this.snap,
    pinned: pinned ?? this.pinned,
    forceElevated: forceElevated ?? this.forceElevated,
    scrolledUnderElevation:
        scrolledUnderElevation ?? this.scrolledUnderElevation,
    shadowColor: shadowColor ?? this.shadowColor,
    bottom: bottom ?? this.bottom,
    toolbarHeight: toolbarHeight ?? this.toolbarHeight,
    windowControlEdgePadding:
        windowControlEdgePadding ?? this.windowControlEdgePadding,
  );

  @override
  bool operator ==(Object other) =>
      other is AppBarMaterialStyle &&
      other.centerTitle == centerTitle &&
      other.floating == floating &&
      other.snap == snap &&
      other.pinned == pinned &&
      other.forceElevated == forceElevated &&
      other.scrolledUnderElevation == scrolledUnderElevation &&
      other.shadowColor == shadowColor &&
      other.bottom == bottom &&
      other.toolbarHeight == toolbarHeight &&
      other.windowControlEdgePadding == windowControlEdgePadding;

  @override
  int get hashCode => Object.hash(
    centerTitle,
    floating,
    snap,
    pinned,
    forceElevated,
    scrolledUnderElevation,
    shadowColor,
    bottom,
    toolbarHeight,
    windowControlEdgePadding,
  );
}

/// Per-style config overrides for [AdaptiveSliverAppBar].
///
/// Callers select styles by name (no platform branching): the dispatched
/// style consumes its matching config, the other one is ignored. Null means
/// "all defaults"; partial overrides fill the rest from the config
/// constructor defaults.
class AppBarStyles {
  const AppBarStyles({this.material, this.apple});

  final AppBarMaterialStyle? material;
  final AppBarAppleStyle? apple;

  AppBarStyles copyWith({
    AppBarMaterialStyle? material,
    AppBarAppleStyle? apple,
  }) => AppBarStyles(
    material: material ?? this.material,
    apple: apple ?? this.apple,
  );

  @override
  bool operator ==(Object other) =>
      other is AppBarStyles &&
      other.material == material &&
      other.apple == apple;

  @override
  int get hashCode => Object.hash(material, apple);
}

/// Adaptive sliver app bar.
///
/// Must be placed in a viewport `slivers:` list (e.g. `CustomScrollView`).
/// The default constructor resolves the style from the current platform;
/// [AdaptiveSliverAppBar.material] forces the Material style and
/// [AdaptiveSliverAppBar.apple] forces the apple style
/// (`CupertinoSliverNavigationBar`).
///
/// Shared parameters live at the top level; style-divergent knobs live in
/// [AppBarStyles]. Material resolves [height] as [SliverAppBar.toolbarHeight].
/// Apple uses a fixed, centered toolbar when [height] is provided unless
/// [AppBarAppleStyle.collapsible] requests the native collapsing navigation
/// bar behavior. A shared [bottom] is hosted below the fixed toolbar on both
/// renderers; a Material-only [AppBarMaterialStyle.bottom] overrides it.
class AdaptiveSliverAppBar extends StatelessWidget {
  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
    this.styles,
  }) : assert(bottom == null || height != null),
       style = null;

  const AdaptiveSliverAppBar.material({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
    this.styles,
  }) : style = AdaptiveStyle.material;

  const AdaptiveSliverAppBar.apple({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
    this.styles,
  }) : assert(bottom == null || height != null),
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final PreferredSizeWidget? bottom;
  final AppBarStyles? styles;

  AppBarMaterialStyle get _effectiveMaterialStyle =>
      styles?.material ?? const AppBarMaterialStyle();

  AppBarAppleStyle get _effectiveAppleStyle =>
      styles?.apple ?? const AppBarAppleStyle();

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AdaptiveStyle.of(context);
    return switch (effectiveStyle) {
      AdaptiveStyle.material => _buildMaterial(_effectiveMaterialStyle),
      AdaptiveStyle.apple => _buildApple(_effectiveAppleStyle),
    };
  }

  Widget _buildMaterial(AppBarMaterialStyle config) {
    // Equivalent of the app's current `SliverTopAppBar` baseline.
    return WindowControlSliverAppBar(
      floating: config.floating,
      snap: config.snap,
      pinned: config.pinned,
      centerTitle: config.centerTitle,
      toolbarHeight: config.toolbarHeight ?? height ?? kToolbarHeight,
      forceElevated: config.forceElevated,
      scrolledUnderElevation: config.scrolledUnderElevation,
      shadowColor: config.shadowColor,
      bottom: config.bottom ?? bottom,
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
      windowControlEdgePadding: config.windowControlEdgePadding,
    );
  }

  Widget _buildApple(AppBarAppleStyle effectiveStyle) => CupertinoSliverAppBar(
    title: title,
    actions: actions,
    leading: leading,
    onLeadingPressed: onLeadingPressed,
    height: effectiveStyle.collapsible ? null : height,
    bottom: bottom,
    bottomExtent: bottom?.preferredSize.height ?? 0.0,
    style: effectiveStyle,
  );
}
