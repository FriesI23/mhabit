// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'app_navigation_branch.dart';
import 'app_router.dart';

/// Coordinates primary branches with routes in the app-flow navigator.
///
/// One instance is created by each app entry together with its branch
/// observers. It owns no process-global state and exposes derived navigation
/// state to the app shell without coupling that shell to individual app flows.
class AppNavigationCoordinator extends ChangeNotifier {
  /// Creates an app navigation coordinator.
  AppNavigationCoordinator({
    required this.branchObservers,
    required this.appFlowObserver,
    required this.appChromeNavigatorKey,
    required int initialIndex,
  }) : _selectedIndex = initialIndex {
    for (final observer in branchObservers) {
      observer.onStackChanged = _handleStackChanged;
    }
    appFlowObserver.onStackChanged = _handleStackChanged;
  }

  /// Observers for the stateful shell's primary branches.
  final List<AdaptiveBranchRouteObserver> branchObservers;

  /// Observer for routes presented above the primary branches.
  final AdaptiveBranchRouteObserver appFlowObserver;

  /// Navigator key for the app-flow layer.
  final GlobalKey<NavigatorState> appChromeNavigatorKey;

  StatefulNavigationShell? _navigationShell;
  int _selectedIndex;
  String? _appFlowTopRouteName;
  bool _compactRouteVisible = true;
  bool _destinationSwitchInProgress = false;
  bool _notificationScheduled = false;
  int _navigationStateGuardDepth = 0;
  bool _navigationInProgress = false;
  bool _disposed = false;

  /// Index of the currently selected primary branch.
  int get selectedIndex => _selectedIndex;

  /// Name of the route currently presented by the app-flow navigator.
  String? get appFlowTopRouteName => _appFlowTopRouteName;

  /// Whether compact navigation chrome should remain visible.
  bool get compactRouteVisible => _compactRouteVisible;

  /// Whether app chrome is switching to a selected destination.
  ///
  /// Normal system back does not set this value.
  bool get destinationSwitchInProgress => _destinationSwitchInProgress;

  /// Attaches go_router's stateful navigation shell.
  void attachTabShell(StatefulNavigationShell navigationShell) {
    if (_disposed) return;
    _navigationShell = navigationShell;
    _synchronize(scheduleNotification: true);
  }

  /// Closes the current app flow and selects a primary branch.
  Future<void> selectBranch(int index) async {
    if (!_beginDestinationNavigation()) return;
    try {
      await SchedulerBinding.instance.endOfFrame;
      if (_disposed) return;
      await _closeAppFlowThenSelectBranch(index);
    } finally {
      _finishDestinationNavigation();
    }
  }

  /// Selects an auxiliary app-flow destination from the navigation chrome.
  Future<void> selectAppFlowRoot(String routeName) async {
    if (!_beginDestinationNavigation()) return;
    try {
      await SchedulerBinding.instance.endOfFrame;
      if (_disposed) return;
      await _openAppFlowRootWithNavigationStateGuard(routeName);
    } finally {
      _finishDestinationNavigation();
    }
  }

  /// Opens [routeName] as an app-flow root or pops its child stack back to it.
  Future<void> openAppFlowRoot(String routeName) =>
      _runNavigation(() => _openAppFlowRootWithNavigationStateGuard(routeName));

  /// Closes the current app flow while preserving the selected branch.
  Future<void> returnToPrimaryBranch() =>
      _runNavigation(() => _closeAppFlowThenSelectBranch(selectedIndex));

  Future<void> _runNavigation(Future<void> Function() action) async {
    if (_disposed || _navigationInProgress) return;
    _navigationInProgress = true;
    try {
      await action();
    } finally {
      _navigationInProgress = false;
    }
  }

  bool _beginDestinationNavigation() {
    if (_disposed || _navigationInProgress) return false;
    _navigationInProgress = true;
    // Route-level PopScopes observe this intent on the next frame before the
    // asynchronous chain starts popping the app-flow stack.
    _setDestinationSwitchInProgress(true);
    return true;
  }

  void _finishDestinationNavigation() {
    if (!_disposed) _setDestinationSwitchInProgress(false);
    _navigationInProgress = false;
  }

  void _setDestinationSwitchInProgress(bool value) {
    if (_destinationSwitchInProgress == value) return;
    _destinationSwitchInProgress = value;
    notifyListeners();
  }

  Future<void> _openAppFlowRootWithNavigationStateGuard(String routeName) {
    return _runWithNavigationStateGuard(() => _openAppFlowRoot(routeName));
  }

  Future<void> _openAppFlowRoot(String routeName) async {
    final navigator = appChromeNavigatorKey.currentState;
    if (navigator == null) return;

    if (appFlowObserver.routeNameStack.contains(routeName)) {
      await _popAppFlowUntil(
        navigator: navigator,
        isComplete: () => appFlowObserver.topRouteName == routeName,
      );
      return;
    }
    if (!await _closeAppFlow()) return;
    if (_disposed) return;

    final context = appChromeNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final router = GoRouter.of(context);
    if (_navigationShell == null) {
      router.goNamed(routeName);
      await SchedulerBinding.instance.endOfFrame;
      return;
    }
    // The returned future completes when the route is later popped. Starting
    // the push is the end of this navigation transaction; awaiting the result
    // here would block every later branch or app-flow command.
    unawaited(router.pushNamed<void>(routeName));
    // Wait until Navigator publishes the pushed route to the observer before
    // accepting another command that may inspect the app-flow stack.
    await SchedulerBinding.instance.endOfFrame;
  }

  Future<void> _closeAppFlowThenSelectBranch(
    int index, {
    bool initialLocation = false,
  }) async {
    var didSelectBranch = false;
    await _runWithNavigationStateGuard(() async {
      if (!await _closeAppFlow()) return;
      if (_disposed) return;
      final navigationShell = _navigationShell;
      if (navigationShell != null) {
        navigationShell.goBranch(index, initialLocation: initialLocation);
        didSelectBranch = true;
        return;
      }
      final context = appChromeNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      final branch = AppNavigationBranch.fromNavigationIndex(index);
      GoRouter.of(context).goNamed(branch.rootRouteName);
      didSelectBranch = true;
    }, selectedIndexOverride: () => didSelectBranch ? index : null);
  }

  Future<void> _runWithNavigationStateGuard(
    Future<void> Function() action, {
    int? Function()? selectedIndexOverride,
  }) async {
    _navigationStateGuardDepth++;
    try {
      await action();
    } finally {
      _navigationStateGuardDepth--;
      if (_navigationStateGuardDepth == 0 && !_disposed) {
        _synchronize(selectedIndexOverride: selectedIndexOverride?.call());
      }
    }
  }

  Future<bool> _closeAppFlow() async {
    final navigator = appChromeNavigatorKey.currentState;
    if (navigator == null) return false;

    return _popAppFlowUntil(
      navigator: navigator,
      isComplete: () => appFlowObserver.depth <= 1,
    );
  }

  Future<bool> _popAppFlowUntil({
    required NavigatorState navigator,
    required bool Function() isComplete,
  }) async {
    final initialDepth = appFlowObserver.depth;
    final maximumPopCount = initialDepth > 1 ? initialDepth - 1 : 0;

    for (var attempt = 0; attempt < maximumPopCount; attempt++) {
      if (isComplete()) return true;
      final previousDepth = appFlowObserver.depth;
      await navigator.maybePop();
      if (_disposed) return false;
      // maybePop reports whether the back action was handled, not whether a
      // route was actually removed. A PopScope veto handles the action while
      // keeping the flow on the stack, so verify the observed stack itself.
      if (appFlowObserver.depth >= previousDepth) return false;
    }

    return isComplete();
  }

  AdaptiveBranchRouteObserver? _branchObserverAt(int index) {
    return index < branchObservers.length ? branchObservers[index] : null;
  }

  bool _routeVisibilityAt(int index) {
    if (!appShellFlowVisibilityPolicy(appFlowObserver.routeNameStack)) {
      return false;
    }
    final observer = _branchObserverAt(index);
    if (observer == null || observer.depth == 0) {
      // Branch navigators are lazy. Keep the bar visible until the active
      // branch reports its first route instead of flashing hidden.
      return true;
    }
    return appShellBarVisibilityPolicy(observer.routeNameStack);
  }

  void _handleStackChanged() {
    _synchronize(scheduleNotification: true);
  }

  void _synchronize({
    bool scheduleNotification = false,
    int? selectedIndexOverride,
  }) {
    if (_navigationStateGuardDepth > 0) return;
    final previousIndex = _selectedIndex;
    final nextIndex =
        selectedIndexOverride ??
        _navigationShell?.currentIndex ??
        _selectedIndex;
    final nextAppFlowTopRouteName = appFlowObserver.topRouteName;
    _selectedIndex = nextIndex;
    final nextVisible = _routeVisibilityAt(nextIndex);
    if (nextIndex == previousIndex &&
        nextAppFlowTopRouteName == _appFlowTopRouteName &&
        nextVisible == _compactRouteVisible) {
      return;
    }
    _appFlowTopRouteName = nextAppFlowTopRouteName;
    _compactRouteVisible = nextVisible;
    if (!scheduleNotification) {
      notifyListeners();
      return;
    }
    if (_notificationScheduled) return;
    _notificationScheduled = true;
    scheduleMicrotask(() {
      _notificationScheduled = false;
      if (!_disposed && _navigationStateGuardDepth == 0) notifyListeners();
    });
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _navigationShell = null;
    for (final observer in branchObservers) {
      if (observer.onStackChanged == _handleStackChanged) {
        observer.onStackChanged = null;
      }
    }
    if (appFlowObserver.onStackChanged == _handleStackChanged) {
      appFlowObserver.onStackChanged = null;
    }
    super.dispose();
  }
}
