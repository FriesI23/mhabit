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

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../models/app_entry.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../routes/app_router.dart';
import '../../widgets/widgets.dart';
import 'navigation_chrome.dart';
import 'navigation_destination.dart';

/// [AdaptiveNavigationShell] wired up for the app: localized destinations,
/// app navigation-bar styling, launch-entry persistence on branch switches,
/// and the route-level bar visibility policy.
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({
    super.key,
    required this.coordinator,
    required this.chromeController,
    required this.child,
  });

  final AppNavigationCoordinator coordinator;
  final AppNavigationChromeController chromeController;
  final Widget child;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  late int _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _bindCoordinator(widget.coordinator);
  }

  @override
  void didUpdateWidget(covariant AppNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.coordinator, widget.coordinator)) return;
    oldWidget.coordinator.removeListener(_handleNavigationChanged);
    _bindCoordinator(widget.coordinator);
  }

  @override
  void dispose() {
    widget.coordinator.removeListener(_handleNavigationChanged);
    super.dispose();
  }

  void _bindCoordinator(AppNavigationCoordinator coordinator) {
    _lastSelectedIndex = coordinator.selectedIndex;
    coordinator.addListener(_handleNavigationChanged);
  }

  void _handleNavigationChanged() {
    final coordinator = widget.coordinator;
    final nextIndex = coordinator.selectedIndex;
    if (nextIndex != _lastSelectedIndex) {
      _lastSelectedIndex = nextIndex;
      final branch = AppNavigationBranch.fromNavigationIndex(nextIndex);
      if (context.mounted) {
        context.read<AppLaunchEntryViewModel>().setNewLaunchEntry(
          switch (branch) {
            AppNavigationBranch.habits => AppEntrys.habitDisplay,
            AppNavigationBranch.today => AppEntrys.habitToday,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (result) {
        final navigator = widget.coordinator.appChromeNavigatorKey.currentState;
        if (navigator != null) {
          unawaited(navigator.maybePop<Object?>(result));
        }
      },
      child: ColorfulNavibar(
        child: ListenableBuilder(
          listenable: widget.coordinator,
          builder: (context, _) => _AppNavigationShellChrome(
            coordinator: widget.coordinator,
            chromeController: widget.chromeController,
            selectedIndex: widget.coordinator.selectedIndex,
            compactRouteVisible: widget.coordinator.compactRouteVisible,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _AppNavigationShellChrome extends StatelessWidget {
  const _AppNavigationShellChrome({
    required this.coordinator,
    required this.chromeController,
    required this.selectedIndex,
    required this.compactRouteVisible,
    required this.child,
  });

  final AppNavigationCoordinator coordinator;
  final AppNavigationChromeController chromeController;
  final int selectedIndex;
  final bool compactRouteVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final branch = AppNavigationBranch.fromNavigationIndex(selectedIndex);
    return L10nBuilder(
      builder: (context, l10n) => ListenableBuilder(
        listenable: chromeController,
        builder: (context, _) {
          final chrome = chromeController.chromeFor(branch);
          return AdaptiveNavigationShell(
            selectedIndex: selectedIndex,
            compactRouteVisible: compactRouteVisible,
            contextualChromeSuppressed: chrome.contextualChromeSuppressed,
            applePrimaryAction: chrome.contextualChromeSuppressed
                ? null
                : switch (chrome.primaryAction) {
                    AppNavigationPrimaryAction.createHabit =>
                      CupertinoNavigationPrimaryAction(
                        id: 'habit-display-create-primary-action',
                        label: l10n?.habitDisplay_fab_text ?? 'New Habit',
                        icon: const Icon(CupertinoIcons.add),
                        onPressed: () =>
                            chromeController.invokePrimaryAction(branch),
                      ),
                    null => null,
                  },
            appleBarStyle: const AppleNavigationBarStyle(
              expandedNavigationWidth: 220.0,
            ),
            destinations: [
              AppNavigationDestinations.habits(
                label: l10n?.habitDisplay_tab_habits_label ?? 'Habits',
              ),
              AppNavigationDestinations.today(
                label: l10n?.habitDisplay_tab_today_label ?? 'Today',
              ),
            ],
            onDestinationSelected: coordinator.selectBranch,
            child: child,
          );
        },
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
