import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_sliver_search_bar.dart';
import '../material/material_sliver_search_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Adaptive sliver search bar.
///
/// Must be placed in a viewport `slivers:` list. The default constructor
/// resolves the style from the current platform; named constructors force a
/// renderer style.
class AdaptiveSliverSearchBar extends StatelessWidget {
  const AdaptiveSliverSearchBar({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.leading,
    this.actions = _kDefaultActions,
    this.searchTrailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.materialStyle,
    this.cupertinoMaxSearchWidth = 240.0,
    this.cupertinoActions = const [],
    this.cupertinoBottom,
    this.cupertinoBottomExtent = 0.0,
    this.pinned = true,
  }) : style = null;

  const AdaptiveSliverSearchBar.material({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.leading,
    this.actions = _kDefaultActions,
    this.searchTrailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.materialStyle,
    this.pinned = true,
  }) : cupertinoMaxSearchWidth = 240.0,
       cupertinoActions = const [],
       cupertinoBottom = null,
       cupertinoBottomExtent = 0.0,
       style = AdaptiveStyle.material;

  const AdaptiveSliverSearchBar.apple({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.isSearchActive,
    required this.keyword,
    required this.onChanged,
    required this.onSearchActivated,
    required this.onSearchDismissed,
    this.leading,
    this.actions = _kDefaultActions,
    this.searchTrailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.cupertinoMaxSearchWidth = 240.0,
    this.cupertinoActions = const [],
    this.cupertinoBottom,
    this.cupertinoBottomExtent = 0.0,
    this.pinned = true,
  }) : materialStyle = null,
       style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? searchTrailing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearchActive;
  final String keyword;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;

  /// Material-specific visual configuration, or null for the defaults.
  final MaterialSliverSearchBarStyle? materialStyle;
  final double cupertinoMaxSearchWidth;
  final List<CupertinoSliverSearchBarAction> cupertinoActions;
  final Widget? cupertinoBottom;
  final double cupertinoBottomExtent;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? AdaptiveStyle.of(context);
    return switch (effective) {
      AdaptiveStyle.apple => _buildCupertino(),
      AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildCupertino() => CupertinoSliverSearchBar(
    title: title,
    leading: leading,
    actions: cupertinoActions,
    fixedActions: cupertinoActions.isEmpty
        ? <Widget>[...actions, ?searchTrailing]
        : const <Widget>[],
    controller: controller,
    focusNode: focusNode,
    isSearchActive: isSearchActive,
    keyword: keyword,
    hintText: hintText,
    maxSearchWidth: cupertinoMaxSearchWidth,
    bottom: cupertinoBottom,
    bottomExtent: cupertinoBottomExtent,
    pinned: pinned,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    onSearchActivated: onSearchActivated,
    onSearchDismissed: onSearchDismissed,
    onTapOutside: onTapOutside,
  );

  Widget _buildMaterial() {
    final effectiveMaterialStyle =
        materialStyle ?? const MaterialSliverSearchBarStyle();
    return MaterialSliverSearchBar(
      title: title,
      leading: leading,
      actions: actions,
      searchTrailing: searchTrailing,
      controller: controller,
      focusNode: focusNode,
      isSearchActive: isSearchActive,
      keyword: keyword,
      hintText: hintText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSearchActivated: onSearchActivated,
      onSearchDismissed: onSearchDismissed,
      onTapOutside: onTapOutside,
      style: effectiveMaterialStyle,
      pinned: pinned,
    );
  }
}
