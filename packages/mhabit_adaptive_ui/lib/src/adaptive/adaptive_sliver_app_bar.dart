import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_sliver_app_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Style config for the Material branch of [AdaptiveSliverAppBar].
///
/// Every field maps 1:1 to a [SliverAppBar] parameter; constructor defaults
/// reproduce the pre-config baseline, so partial overrides only need to
/// specify the deltas.
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
  });

  final bool centerTitle;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool forceElevated;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
  final PreferredSizeWidget? bottom;

  AppBarMaterialStyle copyWith({
    bool? centerTitle,
    bool? floating,
    bool? snap,
    bool? pinned,
    bool? forceElevated,
    double? scrolledUnderElevation,
    Color? shadowColor,
    PreferredSizeWidget? bottom,
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
      other.bottom == bottom;

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
  );
}

/// Style config for the apple branch of [AdaptiveSliverAppBar].
///
/// Every field maps to a [CupertinoSliverNavigationBar] parameter; null
/// fields fall back to the Cupertino defaults.
class AppBarAppleStyle {
  const AppBarAppleStyle({
    this.collapsible = false,
    this.enableBackgroundFilterBlur = true,
    this.border,
    this.backgroundColor,
    this.padding,
    this.stretch = false,
  });

  final bool collapsible;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color? backgroundColor;
  final EdgeInsetsDirectional? padding;
  final bool stretch;

  AppBarAppleStyle copyWith({
    bool? collapsible,
    bool? enableBackgroundFilterBlur,
    Border? border,
    Color? backgroundColor,
    EdgeInsetsDirectional? padding,
    bool? stretch,
  }) => AppBarAppleStyle(
    collapsible: collapsible ?? this.collapsible,
    enableBackgroundFilterBlur:
        enableBackgroundFilterBlur ?? this.enableBackgroundFilterBlur,
    border: border ?? this.border,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    padding: padding ?? this.padding,
    stretch: stretch ?? this.stretch,
  );

  @override
  bool operator ==(Object other) =>
      other is AppBarAppleStyle &&
      other.collapsible == collapsible &&
      other.enableBackgroundFilterBlur == enableBackgroundFilterBlur &&
      other.border == border &&
      other.backgroundColor == backgroundColor &&
      other.padding == padding &&
      other.stretch == stretch;

  @override
  int get hashCode => Object.hash(
    collapsible,
    enableBackgroundFilterBlur,
    border,
    backgroundColor,
    padding,
    stretch,
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
/// bar behavior.
class AdaptiveSliverAppBar extends StatelessWidget {
  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.styles,
  }) : style = null;

  const AdaptiveSliverAppBar.material({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.styles,
  }) : style = AdaptiveStyle.material;

  const AdaptiveSliverAppBar.apple({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.styles,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final AppBarStyles? styles;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      AdaptiveStyle.material => _buildMaterial(
        styles?.material ?? const AppBarMaterialStyle(),
      ),
      AdaptiveStyle.apple => _buildApple(
        styles?.apple ?? const AppBarAppleStyle(),
      ),
    };
  }

  Widget _buildMaterial(AppBarMaterialStyle config) {
    // Equivalent of the app's current `SliverTopAppBar` baseline.
    return SliverAppBar(
      floating: config.floating,
      snap: config.snap,
      pinned: config.pinned,
      centerTitle: config.centerTitle,
      toolbarHeight: height ?? kToolbarHeight,
      forceElevated: config.forceElevated,
      scrolledUnderElevation: config.scrolledUnderElevation,
      shadowColor: config.shadowColor,
      bottom: config.bottom,
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

  Widget _buildApple(AppBarAppleStyle config) => CupertinoSliverAppBar(
    title: title,
    actions: actions,
    leading: leading,
    onLeadingPressed: onLeadingPressed,
    height: config.collapsible ? null : height,
    enableBackgroundFilterBlur: config.enableBackgroundFilterBlur,
    border: config.border,
    backgroundColor: config.backgroundColor,
    padding: config.padding,
    stretch: config.stretch,
  );
}
