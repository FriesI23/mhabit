import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adaptive/adaptive_navigation_bar.dart';
import '../adaptive/adaptive_navigation_rail.dart';
import '../breakpoints/window_size_class.dart';
import 'adaptive_branch_route_observer.dart';
import 'adaptive_nav_scope.dart';
import 'adaptive_nav_visibility.dart';

/// Shell for a [StatefulNavigationShell] with adaptive navigation chrome.
///
/// The form follows the window's width class ([WindowSize.of]): compact
/// keeps the bottom [NavigationBar] overlay; medium keeps a collapsible
/// [NavigationRail] collapsed by default; expanded, large, and extra-large
/// keep the collapsible rail extended by default. The three-tier Apple
/// classification (iOS) maps compact / expanded / large onto the first
/// three forms. The chrome animates when the form changes; the content area
/// always fills the remaining width without a maximum-width cap.
///
/// The extended rail width follows the window width between the M3 drawer
/// bounds — the interval's upper bound grows up to the M3 recommended width
/// at the extra-large boundary, and the default sits inside the interval
/// rather than at an extreme. Users can drag the rail's trailing edge within
/// the current interval; a manual value stays in memory and hands off
/// continuously to the automatic width when the window shrinks (the system
/// never rewrites it, so it resumes when the window grows back).
///
/// In the compact form, bar visibility is derived, not stored: the bar shows
/// when the active branch's top route satisfies [barVisibilityPolicy] and the
/// page has not asked to hide it while scrolling
/// ([AdaptiveNavScope.reportScrollWish]). By default it is visible only on a
/// branch's root route. In non-compact forms the navigation is always
/// visible; the policy and scroll wishes are ignored.
class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.onBranchChanged,
    this.branchObservers = const [],
    this.barVisibilityPolicy,
  });

  /// The go_router shell whose branches are switched by the navigation.
  final StatefulNavigationShell navigationShell;

  /// Bottom navigation destinations; destination i switches to branch i.
  ///
  /// Non-compact forms map these to [NavigationRailDestination]s.
  final List<NavigationDestination> destinations;

  /// Called with the new branch index whenever the active branch changes.
  final ValueChanged<int>? onBranchChanged;

  /// Observers attached to the shell branches, one per branch. Must be the
  /// same instances attached to the corresponding branches.
  final List<AdaptiveBranchRouteObserver> branchObservers;

  /// Whether the bar should be shown for the active branch's current stack.
  ///
  /// [routeNames] holds the branch navigator's stack of route names, bottom
  /// to top; entries are [RouteSettings.name]s (null for unnamed routes
  /// such as dialogs). A policy can use the whole stack to express
  /// inheritance: hiding on one entry also hides everything pushed above.
  /// When null, the bar shows only on branch roots (stack length 1).
  ///
  /// Not consulted while the active branch's stack is still empty (its
  /// navigator is created lazily on first activation); the shell keeps the
  /// current visibility until the first stack event arrives. Ignored in
  /// non-compact forms, where the navigation is always visible.
  final bool Function(List<String?> routeNames)? barVisibilityPolicy;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

/// Navigation forms of [AdaptiveNavigationShell].
enum _ShellForm {
  /// Compact: bottom [NavigationBar] overlay.
  bar,

  /// Collapsible [NavigationRail], collapsed by default.
  railCollapsed,

  /// Collapsible [NavigationRail], extended by default.
  railExtended,
}

/// Chrome animation duration shared by the bottom bar overlay and the rail
/// region.
const Duration _animationDuration = Duration(milliseconds: 250);

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  static const double _narrowNavHeight = 80.0;

  /// Current shell form, tracked in [didChangeDependencies].
  _ShellForm _form = _ShellForm.bar;

  /// Whether the bottom bar is actually shown, derived from the route stack
  /// and [_scrollWish].
  final AdaptiveNavVisibilityController _navVisibility =
      AdaptiveNavVisibilityController();

  /// Whether the active page wants the bar shown, e.g. while scrolling.
  final AdaptiveScrollWishController _scrollWish =
      AdaptiveScrollWishController();

  late int _currentBranchIndex;

  @override
  void initState() {
    super.initState();
    _currentBranchIndex = widget.navigationShell.currentIndex;
    _scrollWish.addListener(_recomputeVisibility);
    _bindBranchObservers();
    _recomputeVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final form = _formFor(WindowSize.of(context).width);
    if (form == _form) return;
    _form = form;
    if (form == _ShellForm.bar) {
      _recomputeVisibility();
    } else {
      // The navigation is always visible outside the compact form.
      _navVisibility.show();
    }
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchObservers != widget.branchObservers) {
      _unbindBranchObservers(oldWidget.branchObservers);
      _bindBranchObservers();
    }
    if (oldWidget.barVisibilityPolicy != widget.barVisibilityPolicy) {
      _recomputeVisibility();
    }
    final index = widget.navigationShell.currentIndex;
    if (index == _currentBranchIndex) return;
    _currentBranchIndex = index;
    // A branch switch starts with the bar visible; the route stack policy
    // can still hide it (e.g. switching back to a branch showing a detail
    // page).
    _scrollWish.reset();
    widget.onBranchChanged?.call(index);
    _recomputeVisibility();
  }

  @override
  void dispose() {
    _unbindBranchObservers(widget.branchObservers);
    _scrollWish.removeListener(_recomputeVisibility);
    _scrollWish.dispose();
    _navVisibility.dispose();
    super.dispose();
  }

  AdaptiveBranchRouteObserver? get _activeBranchObserver {
    final index = widget.navigationShell.currentIndex;
    final observers = widget.branchObservers;
    return index < observers.length ? observers[index] : null;
  }

  void _recomputeVisibility() {
    if (!mounted || _form != _ShellForm.bar) return;
    final observer = _activeBranchObserver;
    final depth = observer?.depth ?? 1;
    // A branch activates lazily, so its navigator may not exist yet on the
    // first switch. Keep the current visibility until the first stack event
    // arrives instead of briefly hiding the bar.
    if (observer != null && depth == 0) return;
    final policy = widget.barVisibilityPolicy;
    final structuralVisible = policy == null
        ? depth == 1
        : policy(observer?.routeNameStack ?? const <String?>[]);
    final visible = structuralVisible && _scrollWish.value;
    if (_navVisibility.value == visible) return;
    visible ? _navVisibility.show() : _navVisibility.hide();
  }

  void _bindBranchObservers() {
    for (final observer in widget.branchObservers) {
      observer.onStackChanged = _handleStackChanged;
    }
  }

  void _unbindBranchObservers(List<AdaptiveBranchRouteObserver> observers) {
    for (final observer in observers) {
      if (observer.onStackChanged == _handleStackChanged) {
        observer.onStackChanged = null;
      }
    }
  }

  void _handleStackChanged() {
    // Navigator observers run while the navigator is still building, so
    // defer the writes to a microtask: mutating a notifier mid-build would
    // mark an unrelated ValueListenableBuilder as needing build.
    scheduleMicrotask(() {
      // Re-entering a root page starts with the bar visible; scrolling can
      // hide it again afterwards.
      _scrollWish.reset();
      _recomputeVisibility();
    });
  }

  void _onDestinationSelected(int index) {
    _scrollWish.reset();
    widget.navigationShell.goBranch(index);
  }

  /// Maps a width class to the shell form.
  /// Width-class to navigation-form mapping shared by all styles: compact
  /// keeps the bottom bar, medium keeps a rail collapsed by default, and
  /// everything from expanded on keeps the rail extended by default.
  ///
  /// The Apple chain only produces compact / medium / large, so this single
  /// mapping covers it without a platform branch.
  _ShellForm _formFor(WindowSizeClass widthClass) {
    if (widthClass == WindowSizeClass.compact) return _ShellForm.bar;
    return widthClass == WindowSizeClass.medium
        ? _ShellForm.railCollapsed
        : _ShellForm.railExtended;
  }

  @override
  Widget build(BuildContext context) {
    final compact = _form == _ShellForm.bar;
    const barHeight = _narrowNavHeight;
    // NavigationBar adds a SafeArea around its content, so the rendered bar
    // is barHeight plus the bottom system inset. The scope exposes the
    // total height so branch pages can reserve it.
    final navHeight = barHeight + MediaQuery.paddingOf(context).bottom;

    final naviBarBody = AdaptiveNavigationBar(
      height: barHeight,
      selectedIndex: _currentBranchIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: widget.destinations,
      onDestinationSelected: _onDestinationSelected,
    );

    return AdaptiveNavScope(
      visible: compact ? _navVisibility : null,
      scrollWish: compact ? _scrollWish : null,
      barHeight: compact ? barHeight : 0,
      navHeight: compact ? navHeight : 0,
      child: ColoredBox(
        // Opaque backdrop behind the branch content: the bar is translucent
        // and slides over it, so without this the window background would
        // show through the fading bar.
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            // Branch content with leading chrome in non-compact forms; the
            // chrome panel animates its width when the form switches.
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavigationRailRegion(
                    form: _form,
                    selectedIndex: _currentBranchIndex,
                    destinations: widget.destinations,
                    onDestinationSelected: _onDestinationSelected,
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
            // Compact form only: the bottom bar overlays the branch content
            // and slides over it; pages reserve the bar height via
            // [AdaptiveNavScope]. Switching forms fades the whole overlay.
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: _animationDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: compact
                    ? MediaQuery.removePadding(
                        key: const ValueKey('bottom-bar'),
                        context: context,
                        removeTop: true,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _navVisibility,
                          builder: (context, visible, child) => AnimatedSlide(
                            duration: _animationDuration,
                            curve: Curves.easeOut,
                            offset: visible ? Offset.zero : const Offset(0, 1),
                            child: AnimatedOpacity(
                              duration: _animationDuration,
                              opacity: visible ? 1 : 0,
                              child: child,
                            ),
                          ),
                          child: naviBarBody,
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('bottom-bar-hidden')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Medium+ chrome region of the shell: a collapsible rail panel whose width
/// follows the window and can be dragged at its trailing edge.
///
/// Owns the rail's local state (extended, manual width, dragging) so the
/// shell stays free of expand/collapse mechanics. Always mounted: in the
/// compact form it builds a zero-width box, which keeps the manual width
/// across compact round-trips. The extended state resets to the form
/// default whenever the form changes.
class _NavigationRailRegion extends StatefulWidget {
  const _NavigationRailRegion({
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final _ShellForm form;
  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<_NavigationRailRegion> createState() => _NavigationRailRegionState();
}

class _NavigationRailRegionState extends State<_NavigationRailRegion> {
  /// Extended rail width bounds.
  static const double _railMinWidth = 180.0;
  static const double _railMaxWidth = 360.0;

  /// Collapsed rail width (icon rail).
  static const double _railCollapsedWidth = 72.0;

  /// Where the auto width sits inside the effective interval (interior, not
  /// an extreme).
  static const double _railAutoRatio = 0.7;

  /// Window widths between which the effective interval grows from
  /// [_railMinWidth] to [_railMaxWidth].
  static const double _railWidthRampStart = 600.0;
  static const double _railWidthRampEnd = 1600.0;

  /// Whether the rail is extended.
  ///
  /// Initialized from the form's default and toggled by the rail's leading
  /// button; reset to the form default whenever the form changes.
  bool _extended = false;

  /// Manual rail width from the last drag.
  ///
  /// Persists for the region's lifetime; the system never rewrites it. The
  /// effective width hands off to the automatic width continuously when the
  /// window shrinks (see [_manualAboveAuto]), so the value resumes once the
  /// window grows back.
  double? _manualWidth;

  /// Whether [_manualWidth] was dragged above the auto value at its window
  /// width; picks the handoff direction when the window shrinks.
  bool _manualAboveAuto = false;

  /// Accumulated rail width during a drag; assigned to [_manualWidth] on
  /// every update.
  double _dragCurrentWidth = _railMinWidth;

  /// Whether a rail resize drag is in progress (disables width animation).
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _extended = widget.form == _ShellForm.railExtended;
  }

  @override
  void didUpdateWidget(covariant _NavigationRailRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form == widget.form) return;
    _extended = widget.form == _ShellForm.railExtended;
  }

  /// Drag upper bound at [windowWidth]: the interval grows from
  /// [_railMinWidth] at the medium boundary to the full [_railMaxWidth] at
  /// the extra-large boundary.
  double _railUpperBound(double windowWidth) {
    final t =
        ((windowWidth - _railWidthRampStart) /
                (_railWidthRampEnd - _railWidthRampStart))
            .clamp(0.0, 1.0);
    return _railMinWidth + (_railMaxWidth - _railMinWidth) * t;
  }

  /// Auto rail width at [windowWidth]: interior of the effective interval,
  /// reaching its maximum at the extra-large boundary.
  double _railAutoWidth(double windowWidth) =>
      _railMinWidth +
      (_railUpperBound(windowWidth) - _railMinWidth) * _railAutoRatio;

  /// Effective extended rail width at [windowWidth].
  ///
  /// A manual value dragged below the auto value holds until the auto value
  /// drops to it and then follows the auto value; a manual value dragged
  /// above the auto value holds while it fits the interval and then follows
  /// the interval's upper bound. Both handoffs are continuous, so the rail
  /// never jumps while the window resizes.
  double _effectiveRailWidth(double windowWidth) {
    final manual = _manualWidth;
    if (manual == null) return _railAutoWidth(windowWidth);
    final bound = _manualAboveAuto
        ? _railUpperBound(windowWidth)
        : _railAutoWidth(windowWidth);
    return min(manual, bound);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.sizeOf(context).width;
    return AnimatedSize(
      // A zero duration would crash RenderAnimatedSize: its controller
      // listener calls markNeedsLayout and forward(from: 0) notifies
      // synchronously under zero duration. 1ms keeps the async tick path,
      // so drags stay frame-synced and resize animations keep running.
      duration: _dragging
          ? const Duration(milliseconds: 1)
          : _animationDuration,
      curve: Curves.easeOut,
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.hardEdge,
      child: switch (widget.form) {
        _ShellForm.bar => const SizedBox(width: 0),
        _ShellForm.railCollapsed || _ShellForm.railExtended => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRail(windowWidth),
            // Divider between the rail and the branch content, matching
            // the NavigationDrawer sample layout.
            const VerticalDivider(width: 1),
          ],
        ),
      },
    );
  }

  /// Collapsible rail with a trailing drag handle.
  ///
  /// The extended width follows the auto value unless a manual value
  /// applies (inside the current interval); collapsed keeps the fixed
  /// icon-rail width.
  Widget _buildRail(double windowWidth) {
    final width = _extended
        ? _effectiveRailWidth(windowWidth)
        : _railCollapsedWidth;

    return Stack(
      children: [
        AdaptiveNavigationRail(
          key: const ValueKey('rail-panel'),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onDestinationSelected,
          extended: _extended,
          minWidth: _railCollapsedWidth,
          minExtendedWidth: width,
          leading: IconButton(
            tooltip: _extended
                ? 'Collapse navigation rail'
                : 'Expand navigation rail',
            icon: Icon(_extended ? Icons.menu_open : Icons.menu),
            onPressed: () => setState(() => _extended = !_extended),
          ),
          destinations: widget.destinations,
        ),
        if (_extended)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildResizeHandle(windowWidth),
          ),
      ],
    );
  }

  /// Trailing drag handle that resizes the extended rail within the
  /// effective interval.
  Widget _buildResizeHandle(double windowWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: const ValueKey('rail-resize-handle'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          setState(() {
            _dragging = true;
            _dragCurrentWidth = _effectiveRailWidth(windowWidth);
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragCurrentWidth = (_dragCurrentWidth + details.delta.dx).clamp(
              _railMinWidth,
              _railUpperBound(windowWidth),
            );
            _manualWidth = _dragCurrentWidth;
            _manualAboveAuto = _dragCurrentWidth > _railAutoWidth(windowWidth);
          });
        },
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragCancel: () => setState(() => _dragging = false),
        child: const SizedBox(width: 8, height: double.infinity),
      ),
    );
  }
}
