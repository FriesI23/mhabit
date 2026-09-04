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

class _NavigationTransactionController {
  _NavigationTransactionController({
    required this.isDisposed,
    required this.onDestinationSwitchChanged,
    required this.syncState,
  });

  final bool Function() isDisposed;
  final ValueChanged<bool> onDestinationSwitchChanged;
  final ValueChanged<int?> syncState;

  bool _active = false;
  bool _holdsUpdates = false;
  bool _destinationSwitch = false;

  bool get isHoldingUpdates => _holdsUpdates;

  bool tryBegin({bool destinationSwitch = false}) {
    if (isDisposed() || _active) return false;
    _active = true;
    _destinationSwitch = destinationSwitch;
    if (destinationSwitch) onDestinationSwitchChanged(true);
    return true;
  }

  void holdUpdates() {
    if (!_active) return;
    _holdsUpdates = true;
  }

  void finish({int? selectedIndex}) {
    if (!_active) return;
    try {
      final shouldSyncState = _holdsUpdates;
      _holdsUpdates = false;
      if (shouldSyncState && !isDisposed()) {
        syncState(selectedIndex);
      }
    } finally {
      try {
        if (_destinationSwitch && !isDisposed()) {
          onDestinationSwitchChanged(false);
        }
      } finally {
        _destinationSwitch = false;
        _active = false;
      }
    }
  }
}

class _AppFlowStackController {
  const _AppFlowStackController({
    required this.observer,
    required this.navigatorKey,
    required this.isDisposed,
  });

  final AdaptiveBranchRouteObserver observer;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool Function() isDisposed;

  Future<bool> popToRoot() => _popUntil(isComplete: () => observer.depth <= 1);

  Future<bool> popToRoute(String routeName) =>
      _popUntil(isComplete: () => observer.topRouteName == routeName);

  Future<bool> _popUntil({required bool Function() isComplete}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return false;
    final initialDepth = observer.depth;
    final maximumPopCount = initialDepth > 1 ? initialDepth - 1 : 0;

    for (var attempt = 0; attempt < maximumPopCount; attempt++) {
      if (isComplete()) return true;
      final previousDepth = observer.depth;
      await navigator.maybePop();
      if (isDisposed()) return false;
      // maybePop reports whether the back action was handled, not whether a
      // route was actually removed. A PopScope veto handles the action while
      // keeping the flow on the stack, so verify the observed stack itself.
      if (observer.depth >= previousDepth) return false;
    }

    return isComplete();
  }
}

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
    _transactions = _NavigationTransactionController(
      isDisposed: () => _disposed,
      onDestinationSwitchChanged: _setDestinationSwitchInProgress,
      syncState: (selectedIndex) =>
          _synchronize(selectedIndexOverride: selectedIndex),
    );
    _appFlowStack = _AppFlowStackController(
      observer: appFlowObserver,
      navigatorKey: appChromeNavigatorKey,
      isDisposed: () => _disposed,
    );
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

  late final _NavigationTransactionController _transactions;
  late final _AppFlowStackController _appFlowStack;
  StatefulNavigationShell? _navigationShell;
  int _selectedIndex;
  String? _appFlowTopRouteName;
  bool _compactRouteVisible = true;
  bool _destinationSwitchInProgress = false;
  bool _notificationScheduled = false;
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
  Future<void> selectBranch(int index) =>
      _goToPrimaryBranch(index, destinationSwitch: true);

  /// Selects an auxiliary app-flow destination from the navigation chrome.
  Future<void> selectAppFlowRoot(String routeName) =>
      _goToAppFlowRoot(routeName, destinationSwitch: true);

  /// Opens [routeName] as an app-flow root or pops its child stack back to it.
  Future<void> openAppFlowRoot(String routeName) => _goToAppFlowRoot(routeName);

  /// Closes the current app flow while preserving the selected branch.
  Future<void> returnToPrimaryBranch() => _goToPrimaryBranch(selectedIndex);

  void _setDestinationSwitchInProgress(bool value) {
    if (_destinationSwitchInProgress == value) return;
    _destinationSwitchInProgress = value;
    notifyListeners();
  }

  Future<void> _goToAppFlowRoot(
    String routeName, {
    bool destinationSwitch = false,
  }) async {
    if (!_transactions.tryBegin(destinationSwitch: destinationSwitch)) return;
    try {
      if (destinationSwitch) {
        await SchedulerBinding.instance.endOfFrame;
        if (_disposed) return;
      }
      _transactions.holdUpdates();

      if (appFlowObserver.routeNameStack.contains(routeName)) {
        await _appFlowStack.popToRoute(routeName);
        return;
      }
      if (!await _appFlowStack.popToRoot()) return;
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
    } finally {
      _transactions.finish();
    }
  }

  Future<void> _goToPrimaryBranch(
    int index, {
    bool destinationSwitch = false,
    bool initialLocation = false,
  }) async {
    if (!_transactions.tryBegin(destinationSwitch: destinationSwitch)) return;
    int? nextSelectedIndex;
    try {
      if (destinationSwitch) {
        await SchedulerBinding.instance.endOfFrame;
        if (_disposed) return;
      }
      _transactions.holdUpdates();

      if (!await _appFlowStack.popToRoot()) return;
      if (_disposed) return;
      final navigationShell = _navigationShell;
      if (navigationShell != null) {
        navigationShell.goBranch(index, initialLocation: initialLocation);
        nextSelectedIndex = index;
        return;
      }
      final context = appChromeNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      final branch = AppNavigationBranch.fromNavigationIndex(index);
      GoRouter.of(context).goNamed(branch.rootRouteName);
      nextSelectedIndex = index;
    } finally {
      _transactions.finish(selectedIndex: nextSelectedIndex);
    }
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
    if (_transactions.isHoldingUpdates) return;
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
      if (!_disposed && !_transactions.isHoldingUpdates) {
        notifyListeners();
      }
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
