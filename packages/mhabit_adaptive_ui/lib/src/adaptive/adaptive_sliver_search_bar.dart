import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../material/material_sliver_search_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Adaptive sliver search bar.
///
/// Must be placed in a viewport `slivers:` list. The default constructor
/// resolves the style from the current platform; `.material` forces the
/// Material style. The Apple style currently falls back to the Material
/// implementation.
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
    this.materialStyle = const MaterialSliverSearchBarStyle(),
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
    this.materialStyle = const MaterialSliverSearchBarStyle(),
  }) : style = AdaptiveStyle.material;

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
    this.materialStyle = const MaterialSliverSearchBarStyle(),
  }) : style = AdaptiveStyle.apple;

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
  final MaterialSliverSearchBarStyle materialStyle;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? context.adaptiveStyle;
    return switch (effective) {
      // TODO(adaptive-ui::apple): Supply the Cupertino renderer in Phase 3-2f.
      AdaptiveStyle.apple || AdaptiveStyle.material => _buildMaterial(),
    };
  }

  Widget _buildMaterial() => MaterialSliverSearchBar(
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
    style: materialStyle,
  );
}
