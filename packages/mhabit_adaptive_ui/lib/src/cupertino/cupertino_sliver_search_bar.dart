import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import '../adaptive/adaptive_app_bar_actions.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/sidebar_adapter.dart';
import '../window_control/cupertino_navigation_bar.dart';
import 'cupertino_search_toolbar.dart';
import 'cupertino_sidebar_navigation_bar_bottom.dart';

/// Cupertino presentation for an inline, sliver-based search command bar.
///
/// Search remains at the trailing edge. Compact layouts expand a button toward
/// the leading edge. Medium and large layouts keep a field visible while at
/// least 100 points remain, then fall back to the same expandable button.
/// The bar always uses the fixed Cupertino toolbar height and never introduces
/// a large title.
/// Business state and the text controller stay with the caller.
class CupertinoSliverSearchBar<T extends Object> extends StatefulWidget {
  static const double toolbarHeight = kMinInteractiveDimensionCupertino;

  const CupertinoSliverSearchBar({
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
    required this.collection,
    required this.onInvoke,
    this.actions,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.maxSearchWidth = 240.0,
    this.bottom,
    this.bottomExtent = 0.0,
    this.pinned = true,
  }) : assert(bottomExtent >= 0.0),
       assert(bottom != null || bottomExtent == 0.0);

  final Widget title;
  final Widget? leading;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoAppBarActionsConfig<T>? actions;
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
  final double maxSearchWidth;
  final Widget? bottom;
  final double bottomExtent;
  final bool pinned;

  @override
  State<CupertinoSliverSearchBar<T>> createState() =>
      _CupertinoSliverSearchBarState<T>();
}

class _CupertinoSliverSearchBarState<T extends Object>
    extends State<CupertinoSliverSearchBar<T>> {
  late bool _expanded;
  bool _overflowMenuOpen = false;
  bool _keepSearchExpandedForMenu = false;
  bool _focusSearchWhenOverflowCloses = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.keyword.isNotEmpty || widget.focusNode.hasFocus;
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(CupertinoSliverSearchBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
    if (widget.keyword.isNotEmpty || widget.focusNode.hasFocus) {
      _expanded = true;
    } else if (!_keepSearchExpandedForMenu &&
        (!widget.isSearchActive || oldWidget.keyword.isNotEmpty)) {
      _expanded = false;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    final expanded =
        widget.focusNode.hasFocus ||
        widget.keyword.isNotEmpty ||
        _keepSearchExpandedForMenu;
    if (_expanded == expanded) return;
    setState(() => _expanded = expanded);
  }

  void _activateSearch() {
    if (!_expanded) setState(() => _expanded = true);
    if (_overflowMenuOpen) {
      _keepSearchExpandedForMenu = true;
      _focusSearchWhenOverflowCloses = true;
    }
    widget.onSearchActivated();
  }

  void _handleOverflowMenuOpened() {
    if (!mounted) return;
    setState(() {
      _overflowMenuOpen = true;
      _keepSearchExpandedForMenu = _expanded;
    });
  }

  void _handleOverflowMenuClosed() {
    if (!mounted) return;
    final focusSearch = _focusSearchWhenOverflowCloses;
    setState(() {
      _overflowMenuOpen = false;
      _keepSearchExpandedForMenu = false;
      _focusSearchWhenOverflowCloses = false;
      if (!focusSearch &&
          !widget.focusNode.hasFocus &&
          widget.keyword.isEmpty) {
        _expanded = false;
      }
    });
    if (focusSearch && !widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }
  }

  void _handleOverflowPressed(
    bool searchExpanded,
    VoidCallback openOverflowMenu,
  ) {
    if (!searchExpanded || !_expanded || widget.keyword.isNotEmpty) {
      openOverflowMenu();
      return;
    }
    setState(() {
      _expanded = false;
      _keepSearchExpandedForMenu = false;
      _focusSearchWhenOverflowCloses = false;
    });
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = SidebarLeadingScope.maybeOf(context);
    final widthClass = WindowSize.of(context).width;
    final isCompact = !(widthClass >= WindowSizeClass.medium);
    final isLarge = widthClass >= WindowSizeClass.large;
    final topPadding = MediaQuery.paddingOf(context).top;
    final toolbarGeometry = CupertinoSidebarPresentationScope.toolbarGeometryOf(
      context,
    );
    final sidebarNavigationBarBottom = sidebarLeading == null
        ? null
        : CupertinoSidebarNavigationBarBottom.maybeFromGeometry(
            toolbarGeometry,
          );
    final toolbarHeight = toolbarGeometry.contentHeight;
    final sidebarToolbarHeight = sidebarLeading == null
        ? toolbarHeight
        : toolbarGeometry.height;
    final extent = topPadding + sidebarToolbarHeight + widget.bottomExtent;

    return SliverPersistentHeader(
      key: const ValueKey('cupertino-sliver-search-bar'),
      pinned: widget.pinned,
      delegate: _CupertinoSearchToolbarDelegate(
        extent: extent,
        child: SizedBox(
          height: extent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              WindowControlCupertinoNavigationBar(
                automaticallyImplyLeading: false,
                transitionBetweenRoutes: false,
                automaticBackgroundVisibility: true,
                backgroundColor: CupertinoColors.transparent,
                border: null,
                bottom: sidebarNavigationBarBottom,
              ),
              Positioned(
                top: topPadding,
                left: 0,
                right: 0,
                height: toolbarHeight,
                child: DefaultTextStyle(
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  child: CupertinoSearchToolbar(
                    title: widget.keyword.isEmpty
                        ? widget.title
                        : Text(widget.hintText ?? 'Search'),
                    showTitle: sidebarLeading != null || !isLarge,
                    centerTitle:
                        sidebarLeading == null && !isCompact && !isLarge,
                    preferPersistentSearch: isLarge,
                    sidebarLeading: sidebarLeading,
                    leading: widget.leading,
                    collection: widget.collection,
                    onInvoke: widget.onInvoke,
                    iconBuilder: widget.actions?.iconBuilder,
                    actionButtonBuilder: widget.actions?.actionButtonBuilder,
                    menuBuilderForAction: widget.actions?.menuBuilderForAction,
                    presentationForAction:
                        widget.actions?.presentationForAction,
                    manuallyExpanded: _expanded,
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    hintText: widget.hintText,
                    maxSearchWidth: widget.maxSearchWidth,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onSearchActivated: _activateSearch,
                    onTapOutside: widget.onTapOutside,
                    onOverflowMenuOpened: _handleOverflowMenuOpened,
                    onOverflowMenuClosed: _handleOverflowMenuClosed,
                    onOverflowPressed: _handleOverflowPressed,
                  ),
                ),
              ),
              if (widget.bottom case final bottom?)
                Positioned(
                  top: topPadding + sidebarToolbarHeight,
                  left: 0,
                  right: 0,
                  height: widget.bottomExtent,
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupertinoSearchToolbarDelegate extends SliverPersistentHeaderDelegate {
  const _CupertinoSearchToolbarDelegate({
    required this.extent,
    required this.child,
  });

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(_CupertinoSearchToolbarDelegate oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}
