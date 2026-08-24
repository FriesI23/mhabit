import 'package:flutter/material.dart';

import '../breakpoints/window_size_class.dart';
import 'material_expandable_search_bar.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Material-only visual configuration for [MaterialSliverSearchBar].
class MaterialSliverSearchBarStyle {
  const MaterialSliverSearchBarStyle({
    this.toolbarHeight = kToolbarHeight,
    this.searchBarHeight = 48.0,
    this.maxSearchWidth = 312.0,
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
  });

  final double toolbarHeight;
  final double searchBarHeight;
  final double maxSearchWidth;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
}

/// Material presentation for an inline, sliver-based search command bar.
class MaterialSliverSearchBar extends StatelessWidget {
  const MaterialSliverSearchBar({
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
    this.style = const MaterialSliverSearchBarStyle(),
    this.pinned = true,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? searchTrailing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearchActive;
  final String keyword;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final VoidCallback onSearchDismissed;
  final TapRegionCallback? onTapOutside;
  final MaterialSliverSearchBarStyle style;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final isWide = WindowSize.of(context).width >= WindowSizeClass.medium;
    final searchBar = MaterialExpandableSearchBar(
      expanded: isWide || isSearchActive,
      collapsedTitle: isWide ? const SizedBox.shrink() : title,
      controller: controller,
      focusNode: focusNode,
      isSearchActive: isSearchActive,
      hintText: hintText,
      trailing: searchTrailing,
      height: style.searchBarHeight,
      maxWidth: style.maxSearchWidth,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onSearchActivated: onSearchActivated,
      onSearchDismissed: onSearchDismissed,
      onTapOutside: onTapOutside,
    );

    // TODO(adaptive-actions): Migrate the Material and Cupertino action
    // regions after adaptive_actions is published as a stable package.
    return SliverAppBar(
      key: const ValueKey('material-sliver-search-bar'),
      floating: true,
      snap: true,
      pinned: pinned,
      centerTitle: false,
      toolbarHeight: style.toolbarHeight,
      scrolledUnderElevation: style.scrolledUnderElevation,
      shadowColor: style.shadowColor,
      bottom: const PreferredSize(
        preferredSize: Size.zero,
        child: SizedBox.shrink(),
      ),
      leading: isWide ? leading : null,
      title: isWide ? title : searchBar,
      actions: isWide
          ? [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: style.maxSearchWidth,
                ),
                child: searchBar,
              ),
              ...actions,
            ]
          : [?leading, ...actions],
    );
  }
}
