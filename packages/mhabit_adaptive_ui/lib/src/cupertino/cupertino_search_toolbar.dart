import 'dart:math' as math;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Easing;
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import '../adaptive/adaptive_app_bar_actions.dart';
import '../shell/sidebar_adapter.dart';
import '../window_control/toolbar_geometry.dart';
import 'cupertino_focus_halo_clip.dart';
import 'cupertino_neutral_button.dart';
import 'cupertino_toolbar_padding.dart';

const double _toolbarItemExtent = kMinInteractiveDimensionCupertino;

typedef CupertinoSearchOverflowPressed =
    void Function(bool searchExpanded, VoidCallback openOverflowMenu);

class CupertinoSearchToolbar<T extends Object> extends StatelessWidget {
  static const double _minimumTitleExtent = 96.0;
  static const double _titleHorizontalPadding = 20.0;

  final Widget title;
  final bool showTitle;
  final bool centerTitle;
  final bool preferPersistentSearch;
  final SidebarLeadingScope? sidebarLeading;
  final Widget? leading;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
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
  final CupertinoSearchOverflowPressed onOverflowPressed;

  const CupertinoSearchToolbar({
    super.key,
    required this.title,
    required this.showTitle,
    required this.centerTitle,
    required this.preferPersistentSearch,
    required this.sidebarLeading,
    required this.leading,
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
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
    final sidebarLeading = this.sidebarLeading;
    final insets = WindowControlToolbarGeometry.resolve(
      context,
      avoidance: context.sidebarToolbarAvoidance(
        sidebarLeading: sidebarLeading,
      ),
      edgePadding: contentPadding,
    ).cupertinoInsets;
    final preferredTitleExtent = _measureTitleExtent(context);
    final leadingRegion = _CupertinoSearchToolbarLeading(
      sidebarLeading: sidebarLeading,
      leading: leading,
      itemExtent: _toolbarItemExtent,
    );
    final leadingWidth =
        (sidebarLeading?.reservedExtent ?? 0.0) +
        (leading == null ? 0.0 : _toolbarItemExtent);
    final actions = _CupertinoSearchToolbarActionsSpec<T>(
      collection: collection,
      onInvoke: onInvoke,
      iconBuilder: iconBuilder,
      actionButtonBuilder: actionButtonBuilder,
      menuBuilderForAction: menuBuilderForAction,
      presentationForAction: presentationForAction,
      onOverflowMenuOpened: onOverflowMenuOpened,
      onOverflowMenuClosed: onOverflowMenuClosed,
      onOverflowPressed: onOverflowPressed,
    );
    final search = _CupertinoSearchToolbarFieldSpec(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      maxWidth: maxSearchWidth,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onActivated: onSearchActivated,
      onTapOutside: onTapOutside,
    );

    return Padding(
      padding: EdgeInsets.only(top: insets.top, bottom: insets.bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (sidebarLeading != null) {
            return _CupertinoSidebarSearchToolbar<T>(
              title: title,
              preferPersistentSearch: preferPersistentSearch,
              manuallyExpanded: manuallyExpanded,
              insets: insets,
              leadingRegion: leadingRegion,
              actions: actions,
              search: search,
            );
          }
          return _CupertinoStandardSearchToolbar<T>(
            title: title,
            showTitle: showTitle,
            centerTitle: centerTitle,
            preferPersistentSearch: preferPersistentSearch,
            manuallyExpanded: manuallyExpanded,
            insets: insets,
            leadingRegion: leadingRegion,
            leadingWidth: leadingWidth,
            preferredTitleExtent: preferredTitleExtent,
            maxWidth: constraints.maxWidth,
            actions: actions,
            search: search,
          );
        },
      ),
    );
  }
}

final class _CupertinoSearchToolbarActionsSpec<T extends Object> {
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final CupertinoSearchOverflowPressed onOverflowPressed;

  const _CupertinoSearchToolbarActionsSpec({
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
    required this.onOverflowMenuOpened,
    required this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });
}

final class _CupertinoSearchToolbarFieldSpec {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final double maxWidth;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onActivated;
  final TapRegionCallback? onTapOutside;

  const _CupertinoSearchToolbarFieldSpec({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.maxWidth,
    required this.onChanged,
    required this.onSubmitted,
    required this.onActivated,
    required this.onTapOutside,
  });
}

final class _CupertinoSearchToolbarMetrics {
  final bool persistent;
  final bool expanded;
  final double searchWidth;

  const _CupertinoSearchToolbarMetrics({
    required this.persistent,
    required this.expanded,
    required this.searchWidth,
  });

  factory _CupertinoSearchToolbarMetrics.resolve({
    required double availableWidth,
    required int actionCount,
    required bool preferPersistentSearch,
    required bool manuallyExpanded,
    required double maxSearchWidth,
    required bool wasPersistent,
  }) {
    const minimumPersistentSearchWidth = 100.0;
    final fullActionWidth = actionCount * _toolbarItemExtent;
    final minimumAdaptiveWidth = actionCount == 0 ? 0.0 : _toolbarItemExtent;
    final automaticSearchWidth = math.max(
      0.0,
      availableWidth - fullActionWidth,
    );
    final effectiveMinimumPersistentWidth = math.min(
      minimumPersistentSearchWidth,
      math.max(_toolbarItemExtent, maxSearchWidth),
    );
    final retainedSearchWidth = math.max(
      0.0,
      availableWidth - minimumAdaptiveWidth,
    );
    final persistent =
        preferPersistentSearch &&
        (wasPersistent
            ? retainedSearchWidth > _toolbarItemExtent
            : automaticSearchWidth >= effectiveMinimumPersistentWidth);
    final expanded = persistent || manuallyExpanded;
    final preferredSearchWidth = expanded ? maxSearchWidth : _toolbarItemExtent;
    final searchWidth = math.min(
      preferredSearchWidth,
      math.max(0.0, availableWidth - minimumAdaptiveWidth),
    );
    return _CupertinoSearchToolbarMetrics(
      persistent: persistent,
      expanded: expanded,
      searchWidth: searchWidth,
    );
  }
}

typedef _CupertinoSearchToolbarMetricsBuilder =
    Widget Function(
      BuildContext context,
      _CupertinoSearchToolbarMetrics metrics,
    );

final class _CupertinoSearchToolbarMetricsLayout extends StatefulWidget {
  final double availableWidth;
  final int actionCount;
  final bool preferPersistentSearch;
  final bool manuallyExpanded;
  final double maxSearchWidth;
  final _CupertinoSearchToolbarMetricsBuilder builder;

  const _CupertinoSearchToolbarMetricsLayout({
    required this.availableWidth,
    required this.actionCount,
    required this.preferPersistentSearch,
    required this.manuallyExpanded,
    required this.maxSearchWidth,
    required this.builder,
  });

  @override
  State<_CupertinoSearchToolbarMetricsLayout> createState() =>
      _CupertinoSearchToolbarMetricsLayoutState();
}

final class _CupertinoSearchToolbarMetricsLayoutState
    extends State<_CupertinoSearchToolbarMetricsLayout> {
  late _CupertinoSearchToolbarMetrics _metrics;

  @override
  void initState() {
    super.initState();
    _metrics = _resolve(wasPersistent: false);
  }

  @override
  void didUpdateWidget(_CupertinoSearchToolbarMetricsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _metrics = _resolve(wasPersistent: _metrics.persistent);
  }

  _CupertinoSearchToolbarMetrics _resolve({required bool wasPersistent}) =>
      _CupertinoSearchToolbarMetrics.resolve(
        availableWidth: widget.availableWidth,
        actionCount: widget.actionCount,
        preferPersistentSearch: widget.preferPersistentSearch,
        manuallyExpanded: widget.manuallyExpanded,
        maxSearchWidth: widget.maxSearchWidth,
        wasPersistent: wasPersistent,
      );

  @override
  Widget build(BuildContext context) => widget.builder(context, _metrics);
}

class _CupertinoSidebarSearchToolbar<T extends Object> extends StatelessWidget {
  final Widget title;
  final bool preferPersistentSearch;
  final bool manuallyExpanded;
  final EdgeInsetsDirectional insets;
  final _CupertinoSearchToolbarLeading leadingRegion;
  final _CupertinoSearchToolbarActionsSpec<T> actions;
  final _CupertinoSearchToolbarFieldSpec search;

  const _CupertinoSidebarSearchToolbar({
    required this.title,
    required this.preferPersistentSearch,
    required this.manuallyExpanded,
    required this.insets,
    required this.leadingRegion,
    required this.actions,
    required this.search,
  });

  @override
  Widget build(BuildContext context) => CupertinoSidebarToolbarRegions(
    middleEnabled: !manuallyExpanded || preferPersistentSearch,
    start: Row(
      children: [
        SizedBox(width: insets.start),
        leadingRegion,
        Expanded(
          child: Padding(
            key: const ValueKey('cupertino-search-title'),
            padding: const EdgeInsetsDirectional.only(
              start: CupertinoSidebarToolbarLayout.titleStartPadding,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
            ),
          ),
        ),
      ],
    ),
    end: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.max(0.0, constraints.maxWidth - insets.end);
        return _CupertinoSearchToolbarMetricsLayout(
          availableWidth: availableWidth,
          actionCount: actions.collection.roots.length,
          preferPersistentSearch: preferPersistentSearch,
          manuallyExpanded: manuallyExpanded,
          maxSearchWidth: search.maxWidth,
          builder: (context, metrics) => _CupertinoSearchToolbarContent<T>(
            title: title,
            actions: actions,
            search: search,
            insets: insets,
            metrics: metrics,
            showTitle: false,
            preferredTitleExtent: 0.0,
          ),
        );
      },
    ),
  );
}

class _CupertinoStandardSearchToolbar<T extends Object>
    extends StatelessWidget {
  final Widget title;
  final bool showTitle;
  final bool centerTitle;
  final bool preferPersistentSearch;
  final bool manuallyExpanded;
  final EdgeInsetsDirectional insets;
  final _CupertinoSearchToolbarLeading leadingRegion;
  final double leadingWidth;
  final double preferredTitleExtent;
  final double maxWidth;
  final _CupertinoSearchToolbarActionsSpec<T> actions;
  final _CupertinoSearchToolbarFieldSpec search;

  const _CupertinoStandardSearchToolbar({
    required this.title,
    required this.showTitle,
    required this.centerTitle,
    required this.preferPersistentSearch,
    required this.manuallyExpanded,
    required this.insets,
    required this.leadingRegion,
    required this.leadingWidth,
    required this.preferredTitleExtent,
    required this.maxWidth,
    required this.actions,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    final contentWidth = math.max(0.0, maxWidth - insets.start - insets.end);
    final availableWidth = math.max(0.0, contentWidth - leadingWidth);
    return _CupertinoSearchToolbarMetricsLayout(
      availableWidth: availableWidth,
      actionCount: actions.collection.roots.length,
      preferPersistentSearch: preferPersistentSearch,
      manuallyExpanded: manuallyExpanded,
      maxSearchWidth: search.maxWidth,
      builder: (context, metrics) {
        final showCenteredTitle = showTitle && centerTitle && !metrics.expanded;
        final centeredTitleActionLimit = showCenteredTitle
            ? math.max(
                0.0,
                maxWidth / 2 -
                    preferredTitleExtent / 2 -
                    metrics.searchWidth -
                    insets.end,
              )
            : null;

        return Stack(
          fit: StackFit.expand,
          children: [
            _CupertinoSearchToolbarContent<T>(
              title: title,
              actions: actions,
              search: search,
              insets: insets,
              metrics: metrics,
              leadingRegion: leadingRegion,
              showTitle: showTitle && !centerTitle,
              maxActionRegionWidth: centeredTitleActionLimit,
              preferredTitleExtent: metrics.expanded
                  ? 0.0
                  : preferredTitleExtent,
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
    );
  }
}

class _CupertinoSearchToolbarContent<T extends Object> extends StatelessWidget {
  final Widget title;
  final _CupertinoSearchToolbarActionsSpec<T> actions;
  final _CupertinoSearchToolbarFieldSpec search;
  final EdgeInsetsDirectional insets;
  final _CupertinoSearchToolbarMetrics metrics;
  final bool showTitle;
  final double preferredTitleExtent;
  final _CupertinoSearchToolbarLeading? leadingRegion;
  final double? maxActionRegionWidth;

  const _CupertinoSearchToolbarContent({
    required this.title,
    required this.actions,
    required this.search,
    required this.insets,
    required this.metrics,
    required this.showTitle,
    required this.preferredTitleExtent,
    this.leadingRegion,
    this.maxActionRegionWidth,
  });

  @override
  Widget build(BuildContext context) => TextFieldTapRegion(
    onTapOutside: search.onTapOutside,
    child: Row(
      children: [
        if (leadingRegion case final leadingRegion?) ...[
          SizedBox(width: insets.start),
          leadingRegion,
        ],
        Expanded(
          child: _CupertinoCommandRegion<T>(
            title: title,
            showTitle: showTitle,
            maxActionRegionWidth: maxActionRegionWidth,
            preferredTitleExtent: preferredTitleExtent,
            collection: actions.collection,
            onInvoke: actions.onInvoke,
            iconBuilder: actions.iconBuilder,
            actionButtonBuilder: actions.actionButtonBuilder,
            menuBuilderForAction: actions.menuBuilderForAction,
            presentationForAction: actions.presentationForAction,
            searchExpanded: metrics.expanded,
            onOverflowMenuOpened: actions.onOverflowMenuOpened,
            onOverflowMenuClosed: actions.onOverflowMenuClosed,
            onOverflowPressed: actions.onOverflowPressed,
          ),
        ),
        _CupertinoExpandableSearchItem(
          expanded: metrics.expanded,
          persistent: metrics.persistent,
          controller: search.controller,
          focusNode: search.focusNode,
          hintText: search.hintText,
          maxSearchWidth: metrics.searchWidth,
          onChanged: search.onChanged,
          onSubmitted: search.onSubmitted,
          onSearchActivated: search.onActivated,
        ),
        SizedBox(width: insets.end),
      ],
    ),
  );
}

class _CupertinoSearchToolbarLeading extends StatelessWidget {
  final SidebarLeadingScope? sidebarLeading;
  final Widget? leading;
  final double itemExtent;

  const _CupertinoSearchToolbarLeading({
    required this.sidebarLeading,
    required this.leading,
    required this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = this.sidebarLeading;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sidebarLeading case final sidebarLeading?)
          SizedBox(
            key: const ValueKey('cupertino-sidebar-leading-anchor'),
            width: sidebarLeading.reservedExtent,
            height: itemExtent,
          ),
        if (leading case final leading?)
          SizedBox(width: itemExtent, height: itemExtent, child: leading),
      ],
    );
  }
}

class _CupertinoCommandRegion<T extends Object> extends StatelessWidget {
  static const double _minimumTitleExtent = 96.0;
  static const double _compactTitleStartPadding = 10.0;

  final Widget title;
  final bool showTitle;
  final double? maxActionRegionWidth;
  final double preferredTitleExtent;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final bool searchExpanded;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final CupertinoSearchOverflowPressed onOverflowPressed;

  const _CupertinoCommandRegion({
    required this.title,
    required this.showTitle,
    required this.maxActionRegionWidth,
    required this.preferredTitleExtent,
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
    required this.searchExpanded,
    required this.onOverflowMenuOpened,
    required this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const itemExtent = _toolbarItemExtent;
      final actionRegionBudget = math.min(
        constraints.maxWidth,
        maxActionRegionWidth ?? constraints.maxWidth,
      );
      final actionBudget = math.max(0.0, actionRegionBudget);
      final minimumAdaptiveCapacity = collection.roots.isEmpty
          ? 0.0
          : itemExtent;
      final titlePreservingCapacity = math.max(
        minimumAdaptiveCapacity,
        actionBudget - preferredTitleExtent,
      );
      final rawAdaptiveCapacity = collection.roots.isEmpty
          ? 0.0
          : showTitle
          ? math.min(
              collection.roots.length * itemExtent,
              math.min(actionBudget, titlePreservingCapacity),
            )
          : actionBudget;
      final adaptiveCapacity = rawAdaptiveCapacity < itemExtent
          ? 0.0
          : rawAdaptiveCapacity;
      final actionRegionWidth = math.min(actionRegionBudget, adaptiveCapacity);
      final availableTitleWidth = math.max(
        0.0,
        constraints.maxWidth - actionRegionWidth,
      );
      final keepTitle = showTitle && availableTitleWidth >= _minimumTitleExtent;
      final titleWidth = keepTitle ? availableTitleWidth : 0.0;

      return Stack(
        clipBehavior: Clip.none,
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
              child: _CupertinoSearchActions<T>(
                collection: collection,
                onInvoke: onInvoke,
                iconBuilder: iconBuilder,
                actionButtonBuilder: actionButtonBuilder,
                menuBuilderForAction: menuBuilderForAction,
                presentationForAction: presentationForAction,
                primaryCapacity: adaptiveCapacity,
                searchExpanded: searchExpanded,
                onOverflowMenuOpened: onOverflowMenuOpened,
                onOverflowMenuClosed: onOverflowMenuClosed,
                onOverflowPressed: onOverflowPressed,
              ),
            ),
        ],
      );
    },
  );
}

class _CupertinoSearchActions<T extends Object> extends StatelessWidget {
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final double primaryCapacity;
  final bool searchExpanded;
  final VoidCallback? onOverflowMenuOpened;
  final VoidCallback? onOverflowMenuClosed;
  final CupertinoSearchOverflowPressed onOverflowPressed;

  const _CupertinoSearchActions({
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
    required this.primaryCapacity,
    required this.searchExpanded,
    required this.onOverflowMenuOpened,
    required this.onOverflowMenuClosed,
    required this.onOverflowPressed,
  });

  @override
  Widget build(BuildContext context) {
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
      child: CupertinoFocusHaloClip(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerEnd,
          minWidth: 0,
          maxWidth: double.infinity,
          child: AdaptiveAppBarActions<T>.apple(
            key: const ValueKey('cupertino-search-adaptive-actions'),
            collection: collection,
            primaryCapacity: primaryCapacity,
            onInvoke: onInvoke,
            apple: CupertinoAppBarActionsConfig<T>(
              presentationForAction: presentationForAction,
              onOverflowMenuOpened: onOverflowMenuOpened,
              onOverflowMenuClosed: onOverflowMenuClosed,
              iconBuilder: iconBuilder,
              actionButtonBuilder: actionButtonBuilder,
              menuBuilderForAction: menuBuilderForAction,
              overflowButtonBuilder: (context, onPressed, defaultBuilder) =>
                  defaultBuilder(
                    context,
                    () => onOverflowPressed(searchExpanded, onPressed),
                    icon: overflowIcon,
                  ),
            ),
            fadeDuration: const Duration(milliseconds: 300),
            resizeDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}

class _CupertinoExpandableSearchItem extends StatefulWidget {
  final bool expanded;
  final bool persistent;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final double maxSearchWidth;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onSearchActivated;

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
      _animateWidth = true;
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
        child: _showSearchField
            ? ClipRect(
                child: OverflowBox(
                  alignment: AlignmentDirectional.centerEnd,
                  minWidth: expandedWidth,
                  maxWidth: expandedWidth,
                  child: _buildSearchField(expandedWidth),
                ),
              )
            : CupertinoNeutralButtonBuilder(
                builder: (context) => CupertinoButton(
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
