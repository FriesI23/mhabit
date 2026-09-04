import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../breakpoints/window_size_class.dart';
import '../window_control/material_app_bar.dart';
import 'material_expandable_search_bar.dart';

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
  static const _mediumTitleTrailingWidthThreshold = 0.7;
  static const _actionSlotExtent = 48.0;
  static const _minimumActionCapacity = _actionSlotExtent;
  static const _collapsedSearchReserve = 120.0;
  static const _wideLeadingReserve = kToolbarHeight;
  static const _compactLeadingReserve = 48.0;
  static const _wideTitleReserve = 96.0;
  static const _wideHorizontalReserve = 32.0;
  static const _compactHorizontalReserve = 16.0;

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
  Widget build(BuildContext context) {
    final widthClass = WindowSize.of(context).width;
    final isWide = widthClass >= WindowSizeClass.medium;
    final showWideTitle = _shouldShowWideTitle(context, widthClass);
    final actionCapacity = _resolveActionCapacity(
      context,
      isWide: isWide,
      showWideTitle: showWideTitle,
    );
    final actions = actionCapacity > 0
        ? SizedBox(
            width: actionCapacity,
            child: actionsBuilder(context, actionCapacity),
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

  bool _shouldShowWideTitle(BuildContext context, WindowSizeClass widthClass) {
    if (widthClass >= WindowSizeClass.expanded) return true;
    if (widthClass != WindowSizeClass.medium) return false;
    final windowWidth = MediaQuery.sizeOf(context).width;
    final preferredTrailingWidth =
        style.maxSearchWidth + preferredActionCapacity;
    return preferredTrailingWidth <
        windowWidth * _mediumTitleTrailingWidthThreshold;
  }

  /// Logical horizontal budget (start -> end; mirrored automatically in RTL):
  ///
  /// wide:
  /// | leading | title | flexible gap | search | action slots | outer reserve |
  ///
  /// compact:
  /// | collapsed/active search | flexible gap | leading | actions | reserve |
  ///
  /// action capacity = floor((window width - fixed reserves) / slot) * slot
  ///                           └─ rounded down to whole action slots
  /// minimum capacity: one slot reserved for More
  double _resolveActionCapacity(
    BuildContext context, {
    required bool isWide,
    required bool showWideTitle,
  }) {
    if (preferredActionCapacity <= 0) return 0;
    final windowWidth = MediaQuery.sizeOf(context).width;
    final searchReserve = isWide || isSearchActive
        ? style.maxSearchWidth
        : _collapsedSearchReserve;
    final leadingReserve = leading == null
        ? 0.0
        : (isWide ? _wideLeadingReserve : _compactLeadingReserve);
    final titleReserve = showWideTitle ? _wideTitleReserve : 0.0;
    final horizontalReserve = isWide
        ? _wideHorizontalReserve
        : _compactHorizontalReserve;
    final available =
        windowWidth -
        searchReserve -
        leadingReserve -
        titleReserve -
        horizontalReserve;
    final slotted =
        (available / _actionSlotExtent).floorToDouble() * _actionSlotExtent;
    return math.min(
      preferredActionCapacity,
      math.max(_minimumActionCapacity, slotted),
    );
  }
}
