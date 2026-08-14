import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'adaptive_navigation_bar.dart';

/// Shell for a [StatefulNavigationShell] with a bottom navigation bar.
///
/// Bar visibility is derived, not stored: the bar shows when the active
/// branch's top route satisfies [barVisibilityPolicy] and the page has not
/// asked to hide it while scrolling ([AdaptiveNavScope.scrollWish]). By
/// default it is visible only on a branch's root route.
class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({
    super.key,
    required this.navigationShell,
    required this.wideWidthThreshold,
    required this.destinations,
    this.onBranchChanged,
    this.branchObservers = const [],
    this.barVisibilityPolicy,
  });

  /// The go_router shell whose branches are switched by the navigation bar.
  final StatefulNavigationShell navigationShell;

  /// Width in logical pixels at which the shell switches to the wide layout
  /// (shorter bar, hidden labels).
  // TODO(adaptive-ui::window-class): resolve the layout from the window class and drop
  // this parameter.
  final double wideWidthThreshold;

  /// Bottom navigation destinations; destination i switches to branch i.
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
  /// current visibility until the first stack event arrives.
  final bool Function(List<String?> routeNames)? barVisibilityPolicy;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  static const Duration _bottomNavAnimationDuration = Duration(
    milliseconds: 250,
  );
  static const double _narrowNavHeight = 80.0;

  /// Whether the bottom bar is actually shown, derived from the route stack
  /// and [_scrollWish].
  final ValueNotifier<bool> _isBottomNavVisible = ValueNotifier(true);

  /// Whether the active page wants the bar shown, e.g. while scrolling.
  final ValueNotifier<bool> _scrollWish = ValueNotifier(true);

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
    _scrollWish.value = true;
    widget.onBranchChanged?.call(index);
    _recomputeVisibility();
  }

  @override
  void dispose() {
    _unbindBranchObservers(widget.branchObservers);
    _scrollWish.removeListener(_recomputeVisibility);
    _scrollWish.dispose();
    _isBottomNavVisible.dispose();
    super.dispose();
  }

  AdaptiveBranchRouteObserver? get _activeBranchObserver {
    final index = widget.navigationShell.currentIndex;
    final observers = widget.branchObservers;
    return index < observers.length ? observers[index] : null;
  }

  void _recomputeVisibility() {
    if (!mounted) return;
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
    if (_isBottomNavVisible.value == visible) return;
    _isBottomNavVisible.value = visible;
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
      _scrollWish.value = true;
      _recomputeVisibility();
    });
  }

  void _onDestinationSelected(int index) {
    _scrollWish.value = true;
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final isWideLayout =
        MediaQuery.sizeOf(context).width >= widget.wideWidthThreshold;
    final barHeight = isWideLayout
        ? kBottomNavigationBarHeight
        : _narrowNavHeight;
    // NavigationBar adds a SafeArea around its content, so the rendered bar
    // is barHeight plus the bottom system inset. The scope exposes the
    // total height so branch pages can reserve it.
    final navHeight = barHeight + MediaQuery.paddingOf(context).bottom;
    final labelBehavior = isWideLayout
        ? NavigationDestinationLabelBehavior.alwaysHide
        : NavigationDestinationLabelBehavior.alwaysShow;

    final naviBarBody = AdaptiveNavigationBar(
      height: barHeight,
      selectedIndex: _currentBranchIndex,
      labelBehavior: labelBehavior,
      destinations: widget.destinations,
      onDestinationSelected: _onDestinationSelected,
    );

    return AdaptiveNavScope(
      visible: _isBottomNavVisible,
      scrollWish: _scrollWish,
      barHeight: barHeight,
      navHeight: navHeight,
      child: ColoredBox(
        // Opaque backdrop behind the branch content: the bar is translucent
        // and slides over it, so without this the window background would
        // show through the fading bar.
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            // Overlay layout: branch content extends behind the translucent
            // bar; pages reserve the bar height via [AdaptiveNavScope].
            Positioned.fill(child: widget.navigationShell),
            Align(
              alignment: Alignment.bottomCenter,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isBottomNavVisible,
                  builder: (context, visible, child) => AnimatedSlide(
                    duration: _bottomNavAnimationDuration,
                    curve: Curves.easeOut,
                    offset: visible ? Offset.zero : const Offset(0, 1),
                    child: AnimatedOpacity(
                      duration: _bottomNavAnimationDuration,
                      opacity: visible ? 1 : 0,
                      child: child,
                    ),
                  ),
                  child: naviBarBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inherited scope exposed by [AdaptiveNavigationShell] to its branches.
///
/// Branch pages read [visible] to coordinate FAB / placeholder animations
/// with the bottom bar, write [scrollWish] to report scroll-driven
/// visibility changes, and reserve [navHeight].
class AdaptiveNavScope extends InheritedWidget {
  const AdaptiveNavScope({
    super.key,
    required this.visible,
    required this.scrollWish,
    required this.barHeight,
    required this.navHeight,
    required super.child,
  });

  /// Whether the bottom navigation bar is currently visible.
  ///
  /// Derived by the shell from [scrollWish], the branch stack depth, and
  /// the bar visibility policy. Pages read it to coordinate FAB /
  /// placeholder animations; they must not write it.
  final ValueListenable<bool> visible;

  /// Whether the active page wants the bottom bar visible.
  ///
  /// Pages write this to report scroll-driven visibility changes; the shell
  /// combines it with the route stack policy to derive [visible].
  final ValueNotifier<bool> scrollWish;

  /// Content height of the bar, excluding the bottom safe-area inset.
  ///
  /// Use this to lift floating widgets (e.g. FABs) above the bar: Scaffold
  /// already positions them above the system inset, so adding [navHeight]
  /// would double-count the inset.
  final double barHeight;

  /// Total rendered height of the bottom bar, including the bottom
  /// safe-area inset (NavigationBar wraps its content in a SafeArea).
  final double navHeight;

  /// Reads the scope and rebuilds the caller when it changes.
  static AdaptiveNavScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveNavScope>()!;

  /// Reads the scope without depending on it, for handlers that only write
  /// [scrollWish].
  static AdaptiveNavScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AdaptiveNavScope>();

  @override
  bool updateShouldNotify(AdaptiveNavScope oldWidget) =>
      visible != oldWidget.visible ||
      scrollWish != oldWidget.scrollWish ||
      barHeight != oldWidget.barHeight ||
      navHeight != oldWidget.navHeight;
}

/// Route observer for shell branches.
///
/// Attach one instance per [StatefulShellBranch] of a shell and pass the
/// same instances to [AdaptiveNavigationShell.branchObservers]. Tracks the
/// branch navigator's stack so the shell can derive bar visibility from it.
class AdaptiveBranchRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = [];
  String? _topRouteName;

  /// Stack depth of the observed branch navigator.
  int get depth => _stack.length;

  /// [RouteSettings.name] of the branch navigator's top route.
  ///
  /// go_router sets it to the matched route name; it is null for unnamed
  /// routes.
  String? get topRouteName => _topRouteName;

  /// Names of every route in the branch navigator, bottom to top; unnamed
  /// routes (e.g. dialogs) yield null entries.
  List<String?> get routeNameStack =>
      List.unmodifiable(_stack.map((route) => route.settings.name));

  /// Called when [depth] or [topRouteName] change.
  VoidCallback? onStackChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _topRouteName = route.settings.name;
    onStackChanged?.call();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_stack.isNotEmpty && identical(_stack.last, route)) {
      _stack.removeLast();
    }
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      final index = _stack.lastIndexWhere((r) => identical(r, oldRoute));
      if (index >= 0) {
        if (newRoute == null) {
          _stack.removeAt(index);
        } else {
          _stack[index] = newRoute;
        }
      }
    }
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // didPop already removed a popped route, so removeWhere only matters
    // for removals below the top (e.g. page replacement).
    _stack.removeWhere((r) => identical(r, route));
    _topRouteName = _stack.isNotEmpty ? _stack.last.settings.name : null;
    onStackChanged?.call();
  }
}
