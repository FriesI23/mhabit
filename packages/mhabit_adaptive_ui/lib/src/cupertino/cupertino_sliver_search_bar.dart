import 'dart:math' as math;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Easing;

import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import '../window_control/toolbar_geometry.dart';
import 'cupertino_toolbar_padding.dart';

typedef _CupertinoSearchOverflowPressed =
    void Function(bool searchExpanded, VoidCallback openOverflowMenu);

const List<CupertinoSliverSearchBarAction> _kDefaultActions =
    <CupertinoSliverSearchBarAction>[];
const List<CupertinoSliverSearchBarMenuEntry> _kDefaultChildActions =
    <CupertinoSliverSearchBarMenuEntry>[];
const List<Widget> _kDefaultFixedActions = <Widget>[];

typedef CupertinoSliverSearchBarPrimaryActionBuilder =
    Widget Function(BuildContext context);

/// An action or visual divider inside a Cupertino search-bar action menu.
sealed class CupertinoSliverSearchBarMenuEntry {
  const CupertinoSliverSearchBarMenuEntry();
}

/// A visual divider between Cupertino search-bar menu action groups.
@immutable
final class CupertinoSliverSearchBarMenuDivider
    extends CupertinoSliverSearchBarMenuEntry {
  const CupertinoSliverSearchBarMenuDivider();
}

/// A semantic toolbar action that can move between the Cupertino navigation
/// bar and its overflow menu.
@immutable
final class CupertinoSliverSearchBarAction
    extends CupertinoSliverSearchBarMenuEntry {
  const CupertinoSliverSearchBarAction({
    required this.id,
    required this.label,
    required this.icon,
    this.subtitle,
    this.onPressed,
    this.children = _kDefaultChildActions,
    this.tooltip,
    this.isEnabled = true,
    this.isDestructive = false,
    this.overflowOnly = false,
    this.retentionPriority = 0,
    this.primaryBuilder,
  }) : assert(onPressed != null || children.length > 0);

  final String id;
  final String label;
  final String? subtitle;
  final String? tooltip;
  final Widget icon;
  final VoidCallback? onPressed;
  final List<CupertinoSliverSearchBarMenuEntry> children;
  final bool isEnabled;
  final bool isDestructive;
  final bool overflowOnly;

  /// Higher values keep the action in the toolbar for longer.
  final int retentionPriority;

  /// Optional primary-only presentation. Overflow remains renderer-owned.
  final CupertinoSliverSearchBarPrimaryActionBuilder? primaryBuilder;
}

/// Cupertino presentation for an inline, sliver-based search command bar.
///
/// Search remains at the trailing edge. Compact layouts expand a button toward
/// the leading edge. Medium and large layouts keep a field visible while at
/// least 100 points remain, then fall back to the same expandable button.
/// The bar always uses the fixed Cupertino toolbar height and never introduces
/// a large title.
/// Business state and the text controller stay with the caller.
class CupertinoSliverSearchBar extends StatefulWidget {
  static const double toolbarHeight = 52.0;

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
    this.actions = _kDefaultActions,
    this.fixedActions = _kDefaultFixedActions,
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
  final List<CupertinoSliverSearchBarAction> actions;

  /// Compatibility path for callers that still provide presentation-only
  /// widgets. Semantic [actions] should be preferred when overflow is needed.
  final List<Widget> fixedActions;
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
  State<CupertinoSliverSearchBar> createState() =>
      _CupertinoSliverSearchBarState();
}

class _CupertinoSliverSearchBarState extends State<CupertinoSliverSearchBar> {
  static const double _toolbarItemExtent = 44.0;

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
  void didUpdateWidget(CupertinoSliverSearchBar oldWidget) {
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final widthClass = Breakpoints.of(context).widthClass(screenWidth);
    final isCompact = !(widthClass >= WindowSizeClass.medium);
    final isLarge = widthClass >= WindowSizeClass.large;
    final topPadding = MediaQuery.paddingOf(context).top;
    final extent =
        topPadding +
        CupertinoSliverSearchBar.toolbarHeight +
        widget.bottomExtent;

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
              const CupertinoNavigationBar(
                automaticallyImplyLeading: false,
                transitionBetweenRoutes: false,
                border: null,
              ),
              Positioned(
                top: topPadding,
                left: 0,
                right: 0,
                height: CupertinoSliverSearchBar.toolbarHeight,
                child: DefaultTextStyle(
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  child: _CupertinoSearchToolbar(
                    title: widget.title,
                    showTitle: !isLarge,
                    centerTitle: !isCompact && !isLarge,
                    preferPersistentSearch: isLarge,
                    leading: widget.leading,
                    actions: widget.actions,
                    fixedActions: widget.fixedActions,
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
                  top: topPadding + CupertinoSliverSearchBar.toolbarHeight,
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

class _CupertinoSearchToolbar extends StatelessWidget {
  static const double _minimumTitleExtent = 96.0;
  static const double _titleHorizontalPadding = 20.0;

  const _CupertinoSearchToolbar({
    required this.title,
    required this.showTitle,
    required this.centerTitle,
    required this.preferPersistentSearch,
    required this.leading,
    required this.actions,
    required this.fixedActions,
    required this.manuallyExpanded,
    required this.controller,
    required this.focusNode,
    required this.maxSearchWidth,
    required this.onChanged,
    required this.onSearchActivated,
    this.hintText,
    this.onSubmitted,
    this.onTapOutside,
    this.onOverflowMenuOpened,
    this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });

  final Widget title;
  final bool showTitle;
  final bool centerTitle;
  final bool preferPersistentSearch;
  final Widget? leading;
  final List<CupertinoSliverSearchBarAction> actions;
  final List<Widget> fixedActions;
  final bool manuallyExpanded;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final double maxSearchWidth;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final _CupertinoSearchOverflowPressed onOverflowPressed;

  double _measureTitleExtent(BuildContext context) {
    final title = this.title;
    if (title is! Text) return _minimumTitleExtent;
    final span = title.textSpan ?? TextSpan(text: title.data);
    final painter = TextPainter(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.merge(title.style),
        children: [span],
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: title.textScaler ?? MediaQuery.textScalerOf(context),
      locale: title.locale ?? Localizations.maybeLocaleOf(context),
    )..layout();
    return math.max(
      _minimumTitleExtent,
      painter.width + _titleHorizontalPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding = CupertinoToolbarPadding.resolveDirectional(context);
    final insets = WindowControlToolbarGeometry.resolve(
      context,
      edgePadding: contentPadding,
    ).cupertinoInsets;
    return Padding(
      padding: EdgeInsets.only(top: insets.top, bottom: insets.bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const itemExtent = _CupertinoSliverSearchBarState._toolbarItemExtent;
          const minimumPersistentSearchWidth = 100.0;
          final preferredTitleExtent = _measureTitleExtent(context);
          final leadingWidth = leading == null ? 0.0 : itemExtent;
          final fixedActionWidth = fixedActions.length * itemExtent;
          final contentWidth = math.max(
            0.0,
            constraints.maxWidth - insets.start - insets.end,
          );
          final availableWidth = math.max(0.0, contentWidth - leadingWidth);
          final fullActionWidth =
              actions.length * itemExtent + fixedActionWidth;
          final minimumAdaptiveWidth = actions.isEmpty ? 0.0 : itemExtent;
          final automaticSearchWidth = math.max(
            0.0,
            availableWidth - fullActionWidth,
          );
          final effectiveMinimumPersistentWidth = math.min(
            minimumPersistentSearchWidth,
            math.max(itemExtent, maxSearchWidth),
          );
          final persistent =
              preferPersistentSearch &&
              automaticSearchWidth >= effectiveMinimumPersistentWidth;
          final expanded = persistent || manuallyExpanded;
          final preferredSearchWidth = persistent
              ? math.min(maxSearchWidth, automaticSearchWidth)
              : expanded
              ? maxSearchWidth
              : itemExtent;
          final searchWidth = math.min(
            preferredSearchWidth,
            math.max(
              0.0,
              availableWidth - fixedActionWidth - minimumAdaptiveWidth,
            ),
          );
          final showCenteredTitle = showTitle && centerTitle && !expanded;
          final centeredTitleActionLimit = showCenteredTitle
              ? math.max(
                  0.0,
                  constraints.maxWidth / 2 -
                      preferredTitleExtent / 2 -
                      searchWidth -
                      insets.end,
                )
              : null;
          return Stack(
            fit: StackFit.expand,
            children: [
              TextFieldTapRegion(
                onTapOutside: onTapOutside,
                child: Row(
                  children: [
                    SizedBox(width: insets.start),
                    if (leading case final leading?)
                      SizedBox(
                        width: itemExtent,
                        height: itemExtent,
                        child: leading,
                      ),
                    Expanded(
                      child: _CupertinoCommandRegion(
                        title: title,
                        showTitle: showTitle && !centerTitle,
                        maxActionRegionWidth: centeredTitleActionLimit,
                        preferredTitleExtent: expanded
                            ? 0.0
                            : preferredTitleExtent,
                        actions: actions,
                        fixedActions: fixedActions,
                        searchExpanded: expanded,
                        onOverflowMenuOpened: onOverflowMenuOpened,
                        onOverflowMenuClosed: onOverflowMenuClosed,
                        onOverflowPressed: onOverflowPressed,
                      ),
                    ),
                    _CupertinoExpandableSearchItem(
                      expanded: expanded,
                      persistent: persistent,
                      controller: controller,
                      focusNode: focusNode,
                      hintText: hintText,
                      maxSearchWidth: searchWidth,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      onSearchActivated: onSearchActivated,
                    ),
                    SizedBox(width: insets.end),
                  ],
                ),
              ),
              if (showCenteredTitle)
                IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      key: const ValueKey('cupertino-search-title'),
                      width: preferredTitleExtent,
                      child: DefaultTextStyle.merge(
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        child: title,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CupertinoCommandRegion extends StatelessWidget {
  static const double _minimumTitleExtent = 96.0;
  static const double _compactTitleStartPadding = 10.0;

  const _CupertinoCommandRegion({
    required this.title,
    required this.showTitle,
    required this.maxActionRegionWidth,
    required this.preferredTitleExtent,
    required this.actions,
    required this.fixedActions,
    required this.searchExpanded,
    required this.onOverflowMenuOpened,
    required this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });

  final Widget title;
  final bool showTitle;
  final double? maxActionRegionWidth;
  final double preferredTitleExtent;
  final List<CupertinoSliverSearchBarAction> actions;
  final List<Widget> fixedActions;
  final bool searchExpanded;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final _CupertinoSearchOverflowPressed onOverflowPressed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const itemExtent = _CupertinoSliverSearchBarState._toolbarItemExtent;
      final fixedActionWidth = fixedActions.length * itemExtent;
      final actionRegionBudget = math.min(
        constraints.maxWidth,
        maxActionRegionWidth ?? constraints.maxWidth,
      );
      final actionBudget = math.max(0.0, actionRegionBudget - fixedActionWidth);
      final minimumAdaptiveCapacity = actions.isEmpty ? 0.0 : itemExtent;
      final titlePreservingCapacity = math.max(
        minimumAdaptiveCapacity,
        actionBudget - preferredTitleExtent,
      );
      final rawAdaptiveCapacity = showTitle
          ? math.min(
              actions.length * itemExtent,
              math.min(actionBudget, titlePreservingCapacity),
            )
          : actionBudget;
      final adaptiveCapacity = rawAdaptiveCapacity < itemExtent
          ? 0.0
          : rawAdaptiveCapacity;
      final actionRegionWidth = math.min(
        actionRegionBudget,
        adaptiveCapacity + fixedActionWidth,
      );
      final availableTitleWidth = math.max(
        0.0,
        constraints.maxWidth - actionRegionWidth,
      );
      final keepTitle = showTitle && availableTitleWidth >= _minimumTitleExtent;
      final titleWidth = keepTitle ? availableTitleWidth : 0.0;

      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showTitle)
              PositionedDirectional(
                key: const ValueKey('cupertino-search-title'),
                start: 0,
                width: titleWidth,
                top: 0,
                bottom: 0,
                child: ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: _compactTitleStartPadding,
                      ),
                      child: DefaultTextStyle.merge(
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: title,
                      ),
                    ),
                  ),
                ),
              ),
            if (actionRegionWidth > 0)
              PositionedDirectional(
                end: 0,
                width: actionRegionWidth,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actions.isNotEmpty && adaptiveCapacity > 0)
                      _CupertinoSearchActions(
                        actions: actions,
                        primaryCapacity: adaptiveCapacity,
                        searchExpanded: searchExpanded,
                        onOverflowMenuOpened: onOverflowMenuOpened,
                        onOverflowMenuClosed: onOverflowMenuClosed,
                        onOverflowPressed: onOverflowPressed,
                      ),
                    ...fixedActions,
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _CupertinoSearchActions extends StatelessWidget {
  const _CupertinoSearchActions({
    required this.actions,
    required this.primaryCapacity,
    required this.searchExpanded,
    required this.onOverflowMenuOpened,
    required this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });

  final List<CupertinoSliverSearchBarAction> actions;
  final double primaryCapacity;
  final bool searchExpanded;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final _CupertinoSearchOverflowPressed onOverflowPressed;

  @override
  Widget build(BuildContext context) {
    final actionsById = _indexActions(actions);
    final collection = ActionCollection<VoidCallback>(
      roots: actions.map(_toAdaptiveAction),
    );
    final pointsRight =
        searchExpanded == (Directionality.of(context) == TextDirection.ltr);
    final overflowIcon = Icon(
      pointsRight
          ? CupertinoIcons.chevron_right_2
          : CupertinoIcons.chevron_left_2,
      key: ValueKey(
        searchExpanded
            ? 'cupertino-search-overflow-expanded'
            : 'cupertino-search-overflow-collapsed',
      ),
    );
    return SizedBox(
      width: primaryCapacity,
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerEnd,
          minWidth: 0,
          maxWidth: double.infinity,
          child: CupertinoAdaptiveActions<VoidCallback>.moreAction(
            key: const ValueKey('cupertino-search-adaptive-actions'),
            actions: collection,
            primaryCapacity: primaryCapacity,
            presentationOverride: CupertinoActionPresentation.iconOnly,
            onInvoke: (callback) => callback(),
            onOverflowMenuOpened: onOverflowMenuOpened,
            onOverflowMenuClosed: onOverflowMenuClosed,
            invokeAfterMenuClosed: true,
            iconBuilder: (context, action) =>
                actionsById[action.id.value]?.icon,
            actionButtonBuilder: (context, action, onPressed, defaultBuilder) {
              final descriptor = actionsById[action.id.value];
              return descriptor?.primaryBuilder?.call(context) ??
                  defaultBuilder(context, action, onPressed);
            },
            overflowButtonBuilder: (context, onPressed, defaultBuilder) =>
                defaultBuilder(
                  context,
                  () => onOverflowPressed(searchExpanded, onPressed),
                  icon: overflowIcon,
                ),
            fadeDuration: const Duration(milliseconds: 300),
            resizeDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}

Map<String, CupertinoSliverSearchBarAction> _indexActions(
  Iterable<CupertinoSliverSearchBarAction> roots,
) {
  final result = <String, CupertinoSliverSearchBarAction>{};
  void visit(CupertinoSliverSearchBarAction action) {
    result[action.id] = action;
    for (final child in action.children) {
      if (child case final CupertinoSliverSearchBarAction childAction) {
        visit(childAction);
      }
    }
  }

  roots.forEach(visit);
  return result;
}

AdaptiveAction<VoidCallback> _toAdaptiveAction(
  CupertinoSliverSearchBarAction action,
) {
  final metadata = ActionMetadata(
    label: action.label,
    subtitle: action.subtitle,
    tooltip: action.tooltip,
    iconKey: action.id,
    isDestructive: action.isDestructive,
  );
  final placementPolicy = action.overflowOnly
      ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
      : ActionPlacementPolicy(
          automaticPreference: AutomaticPlacementPreference(
            retentionPriority: PrimaryRetentionPriority.custom(
              action.retentionPriority,
            ),
          ),
        );
  final children = action.children.map(_toAdaptiveMenuEntry);
  final onPressed = action.onPressed;
  if (action.children.isEmpty) {
    return AdaptiveAction<VoidCallback>.action(
      id: ActionId(action.id),
      metadata: metadata,
      payload: onPressed!,
      isEnabled: action.isEnabled,
      placementPolicy: placementPolicy,
    );
  }
  if (onPressed == null) {
    return AdaptiveAction<VoidCallback>.menu(
      id: ActionId(action.id),
      metadata: metadata,
      children: children,
      isEnabled: action.isEnabled,
      placementPolicy: placementPolicy,
    );
  }
  return AdaptiveAction<VoidCallback>.composite(
    id: ActionId(action.id),
    metadata: metadata,
    payload: onPressed,
    children: children,
    isEnabled: action.isEnabled,
    placementPolicy: placementPolicy,
  );
}

AdaptiveMenuEntry<VoidCallback> _toAdaptiveMenuEntry(
  CupertinoSliverSearchBarMenuEntry entry,
) => switch (entry) {
  final CupertinoSliverSearchBarAction action => _toAdaptiveAction(action),
  CupertinoSliverSearchBarMenuDivider() =>
    const AdaptiveMenuDivider<VoidCallback>.menuOnly(),
};

class _CupertinoExpandableSearchItem extends StatefulWidget {
  const _CupertinoExpandableSearchItem({
    required this.expanded,
    required this.persistent,
    required this.controller,
    required this.focusNode,
    required this.maxSearchWidth,
    required this.onChanged,
    required this.onSearchActivated,
    this.hintText,
    this.onSubmitted,
  });

  final bool expanded;
  final bool persistent;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final double maxSearchWidth;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;

  @override
  State<_CupertinoExpandableSearchItem> createState() =>
      _CupertinoExpandableSearchItemState();
}

class _CupertinoExpandableSearchItemState
    extends State<_CupertinoExpandableSearchItem> {
  static const double _collapsedExtent = 44.0;
  static const double _searchFieldHeight = 40.0;
  static const Duration _duration = Duration(milliseconds: 300);

  late bool _showSearchField;
  bool _animateWidth = false;
  bool _autofocusSearchField = false;

  @override
  void initState() {
    super.initState();
    _showSearchField = widget.expanded;
  }

  @override
  void didUpdateWidget(_CupertinoExpandableSearchItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      _animateWidth = widget.persistent == oldWidget.persistent;
      _showSearchField = widget.expanded;
      if (!widget.expanded) _autofocusSearchField = false;
    }
  }

  void _activateSearch() {
    _autofocusSearchField = true;
    widget.onSearchActivated();
  }

  void _handleAnimationEnd() {
    if (!mounted) return;
    if (_animateWidth || (!widget.expanded && _showSearchField)) {
      setState(() {
        _animateWidth = false;
        if (!widget.expanded) _showSearchField = false;
      });
    }
  }

  Widget _buildSearchField(double width) => SizedBox(
    width: width,
    height: _collapsedExtent,
    child: Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SizedBox(
        width: width,
        height: _searchFieldHeight,
        child: CupertinoSearchTextField(
          key: const ValueKey('cupertino-search-field'),
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: _autofocusSearchField,
          placeholder: widget.hintText,
          suffixMode: OverlayVisibilityMode.editing,
          suffixIcon: const Icon(
            CupertinoIcons.xmark_circle_fill,
            key: ValueKey('clear-cupertino-search'),
          ),
          onSuffixTap: () {
            if (widget.controller.text.isEmpty) return;
            widget.controller.clear();
            widget.onChanged('');
          },
          onTap: widget.onSearchActivated,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final expandedWidth = math.max(widget.maxSearchWidth, _collapsedExtent);
    final collapsedWidth = math.min(_collapsedExtent, expandedWidth);
    final animateWidth = _animateWidth;
    if (!animateWidth && !widget.expanded) _showSearchField = false;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: AnimatedContainer(
        key: const ValueKey('cupertino-expandable-search-region'),
        width: widget.expanded ? expandedWidth : collapsedWidth,
        height: _collapsedExtent,
        duration: animateWidth ? _duration : Duration.zero,
        curve: Easing.standard,
        onEnd: animateWidth ? _handleAnimationEnd : null,
        child: ClipRect(
          child: _showSearchField
              ? OverflowBox(
                  alignment: AlignmentDirectional.centerEnd,
                  minWidth: expandedWidth,
                  maxWidth: expandedWidth,
                  child: _buildSearchField(expandedWidth),
                )
              : CupertinoButton(
                  key: const ValueKey('activate-cupertino-search'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(_collapsedExtent),
                  sizeStyle: CupertinoButtonSize.small,
                  onPressed: _activateSearch,
                  child: const Icon(CupertinoIcons.search),
                ),
        ),
      ),
    );
  }
}
