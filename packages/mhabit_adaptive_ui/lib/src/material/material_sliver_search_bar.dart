import 'package:flutter/material.dart';
import '../breakpoints/window_size_class.dart';
import '../window_control/material_app_bar.dart';
import 'material_expandable_search_bar.dart';
import 'material_sliver_search_bar_layout.dart';

typedef MaterialSearchActionsBuilder =
    Widget Function(BuildContext context, double primaryCapacity);

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
    required this.actionsBuilder,
    required this.preferredActionCapacity,
    this.searchTrailing,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.style = const MaterialSliverSearchBarStyle(),
    this.pinned = true,
  });

  final Widget title;
  final Widget? leading;
  final MaterialSearchActionsBuilder actionsBuilder;
  final double preferredActionCapacity;
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
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) =>
        _buildSliver(context, availableWidth: constraints.crossAxisExtent),
  );

  Widget _buildSliver(BuildContext context, {required double availableWidth}) {
    final widthClass = WindowSize.of(context).width;
    final layout = MaterialSliverSearchBarLayoutCalculator(
      widthClass: widthClass,
      availableWidth: availableWidth,
      isSearchActive: isSearchActive,
      hasLeading: leading != null,
      maxSearchWidth: style.maxSearchWidth,
      preferredActionCapacity: preferredActionCapacity,
    ).calculate();
    final isWide = layout.isWide;
    final showWideTitle = layout.showWideTitle;
    final actionCapacity = layout.actionCapacity;
    final actions = actionCapacity > 0
        ? SizedBox(
            width: actionCapacity,
            child: ClipRect(
              child: OverflowBox(
                alignment: AlignmentDirectional.centerEnd,
                minWidth: 0,
                maxWidth: double.infinity,
                child: actionsBuilder(context, actionCapacity),
              ),
            ),
          )
        : null;
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

    return WindowControlSliverAppBar(
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
      title: isWide ? (showWideTitle ? title : null) : searchBar,
      actions: isWide
          ? [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: style.maxSearchWidth,
                ),
                child: searchBar,
              ),
              ?actions,
            ]
          : [?leading, ?actions],
    );
  }
}
