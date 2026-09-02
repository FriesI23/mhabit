import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/app_bar_apple_style.dart';
import '../cupertino/cupertino_sliver_app_bar.dart';
import '../material/app_bar_material_style.dart';
import '../material/material_sliver_app_bar.dart';

export '../cupertino/app_bar_apple_style.dart' show AppBarAppleStyle;
export '../material/app_bar_material_style.dart' show AppBarMaterialStyle;

const List<Widget> _kDefaultActions = <Widget>[];

/// Per-style config overrides for [AdaptiveSliverAppBar].
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
/// [styles]. Material resolves [height] as [SliverAppBar.toolbarHeight]. Apple
/// uses a fixed, centered toolbar when [height] is provided unless
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
       _adaptiveStyle = null;

  const AdaptiveSliverAppBar.material({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
    this.styles,
  }) : _adaptiveStyle = AdaptiveStyle.material;

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
       _adaptiveStyle = AdaptiveStyle.apple;

  final AdaptiveStyle? _adaptiveStyle;
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
    final effectiveStyle = _adaptiveStyle ?? AdaptiveStyle.of(context);
    return switch (effectiveStyle) {
      AdaptiveStyle.material => MaterialSliverAppBar(
        title: title,
        actions: actions,
        leading: leading,
        onLeadingPressed: onLeadingPressed,
        height: height,
        bottom: bottom,
        style: _effectiveMaterialStyle,
      ),
      AdaptiveStyle.apple => _buildApple(_effectiveAppleStyle),
    };
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
