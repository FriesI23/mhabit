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

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../models/app_entry.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../routes/app_router.dart';
import '../../widgets/widgets.dart';

/// [AdaptiveNavigationShell] wired up for the app: localized destinations,
/// app navigation-bar styling, launch-entry persistence on branch switches,
/// and the route-level bar visibility policy.
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  final AppNavigationCoordinator coordinator;
  final Widget child;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  late int _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = widget.coordinator.selectedIndex;
    widget.coordinator.addListener(_handleNavigationChanged);
  }

  @override
  void didUpdateWidget(covariant AppNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinator != widget.coordinator) {
      oldWidget.coordinator.removeListener(_handleNavigationChanged);
      _lastSelectedIndex = widget.coordinator.selectedIndex;
      widget.coordinator.addListener(_handleNavigationChanged);
    }
  }

  @override
  void dispose() {
    widget.coordinator.removeListener(_handleNavigationChanged);
    super.dispose();
  }

  void _handleNavigationChanged() {
    final nextIndex = widget.coordinator.selectedIndex;
    if (nextIndex != _lastSelectedIndex) {
      _lastSelectedIndex = nextIndex;
      final newLaunchEntry = AppEntrys.getFromDBCode(nextIndex + 1);
      if (newLaunchEntry != null && context.mounted) {
        context.read<AppLaunchEntryViewModel>().setNewLaunchEntry(
          newLaunchEntry,
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulNavibar(
      child: L10nBuilder(
        builder: (context, l10n) => AdaptiveNavigationShell(
          selectedIndex: widget.coordinator.selectedIndex,
          compactRouteVisible: widget.coordinator.compactRouteVisible,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n?.habitDisplay_tab_habits_label ?? 'Habits',
            ),
            NavigationDestination(
              icon: const Icon(MdiIcons.calendarTodayOutline),
              selectedIcon: const Icon(MdiIcons.calendarToday),
              label: l10n?.habitDisplay_tab_today_label ?? 'Today',
            ),
          ],
          onDestinationSelected: widget.coordinator.selectBranch,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Per-entry bridge between go_router's tab shell and app navigation chrome.
///
/// Owns no global state: one instance is created by each app entry together
/// with its branch observers. The outer app-chrome shell consumes the derived
/// presentation state while the inner stateful shell attaches its tab
/// navigator here.
class AppNavigationCoordinator extends ChangeNotifier {
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

  final List<AdaptiveBranchRouteObserver> branchObservers;
  final AdaptiveBranchRouteObserver appFlowObserver;
  final GlobalKey<NavigatorState> appChromeNavigatorKey;

  StatefulNavigationShell? _navigationShell;
  int _selectedIndex;
  bool _compactRouteVisible = true;
  bool _notificationScheduled = false;
  bool _disposed = false;

  int get selectedIndex => _selectedIndex;
  bool get compactRouteVisible => _compactRouteVisible;

  void attachTabShell(StatefulNavigationShell navigationShell) {
    _navigationShell = navigationShell;
    _synchronize(scheduleNotification: true);
  }

  void selectBranch(int index) {
    unawaited(_closeAppFlowThenSelectBranch(index));
  }

  Future<void> _closeAppFlowThenSelectBranch(int index) async {
    final navigationShell = _navigationShell;
    if (navigationShell == null) return;
    if (appFlowObserver.depth > 1) {
      final navigator = appChromeNavigatorKey.currentState;
      if (navigator == null) return;
      await navigator.maybePop();
      // maybePop reports whether the back action was handled, not whether a
      // route was actually removed. A PopScope veto handles the action while
      // keeping the flow on the stack, so verify the observed stack itself.
      if (appFlowObserver.depth > 1) return;
    }
    navigationShell.goBranch(index);
    _synchronize();
  }

  AdaptiveBranchRouteObserver? get _activeBranchObserver {
    final index = _navigationShell?.currentIndex ?? _selectedIndex;
    return index < branchObservers.length ? branchObservers[index] : null;
  }

  bool get _currentRouteVisibility {
    if (!appShellFlowVisibilityPolicy(appFlowObserver.routeNameStack)) {
      return false;
    }

    final observer = _activeBranchObserver;
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

  void _synchronize({bool scheduleNotification = false}) {
    final nextIndex = _navigationShell?.currentIndex ?? _selectedIndex;
    final nextVisible = _currentRouteVisibility;
    if (nextIndex == _selectedIndex && nextVisible == _compactRouteVisible) {
      return;
    }
    _selectedIndex = nextIndex;
    _compactRouteVisible = nextVisible;
    if (!scheduleNotification) {
      notifyListeners();
      return;
    }
    if (_notificationScheduled) return;
    _notificationScheduled = true;
    scheduleMicrotask(() {
      _notificationScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
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
