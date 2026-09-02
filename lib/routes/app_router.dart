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

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../common/global.dart';

enum AppRoute {
  habits('habits'),
  today('today'),
  habitDetail('habits/:habitId'),
  habitCreate('habit/create'),
  habitEdit('habit/edit'),
  settings('settings'),
  settingsAbout('settings/about'),
  settingsSync('settings/sync'),
  settingsNotify('settings/notify'),
  experimental('experimental'),
  debugger('debugger'),
  groupManage('group/manage'),
  habitsStatus('habits/status');

  const AppRoute(this.name);
  final String name;
}

String _pathFor(AppRoute route) => switch (route) {
  AppRoute.habits => '/habits',
  AppRoute.today => '/today',
  AppRoute.habitDetail => '/habits/:habitId',
  AppRoute.habitCreate => '/habit/create',
  AppRoute.habitEdit => '/habit/edit',
  AppRoute.settings => '/settings',
  AppRoute.settingsAbout => '/settings/about',
  AppRoute.settingsSync => '/settings/sync',
  AppRoute.settingsNotify => '/settings/notify',
  AppRoute.experimental => '/experimental',
  AppRoute.debugger => '/debugger',
  AppRoute.groupManage => '/group/manage',
  AppRoute.habitsStatus => '/habits/status',
};

/// Bar visibility policy for the app's branches: the bar is shown only on a
/// branch's root route and hidden on anything pushed above it.
bool appShellBarVisibilityPolicy(List<String?> routeNames) =>
    routeNames.length == 1;

/// Compact-bar visibility policy for the app-chrome navigator.
///
/// A pushed common flow adds a second route above the tab shell. A direct
/// entry into create/edit has only one route, so its name is also checked to
/// keep the compact bar hidden without inventing a source tab stack.
bool appShellFlowVisibilityPolicy(List<String?> routeNames) {
  if (routeNames.isEmpty) return true;
  if (routeNames.length > 1) return false;
  return switch (routeNames.single) {
    final name
        when name == AppRoute.habitCreate.name ||
            name == AppRoute.habitEdit.name ||
            name == AppRoute.habitsStatus.name =>
      false,
    _ => true,
  };
}

/// Shared `add*` helpers for the app's route collectors.
///
/// Keeps route path/name knowledge in this library; callers supply only
/// widget builders.
mixin _AppRouteAdder {
  List<RouteBase> get _routes;

  void addHabits({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habits),
        name: AppRoute.habits.name,
        builder: builder,
      ),
    );
  }

  void addToday({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.today),
        name: AppRoute.today.name,
        builder: builder,
      ),
    );
  }

  void addHabitDetail({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitDetail),
        name: AppRoute.habitDetail.name,
        builder: builder,
      ),
    );
  }

  void addHabitCreate({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitCreate),
        name: AppRoute.habitCreate.name,
        builder: builder,
      ),
    );
  }

  void addHabitEdit({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitEdit),
        name: AppRoute.habitEdit.name,
        builder: builder,
      ),
    );
  }

  void addSettings({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.settings),
        name: AppRoute.settings.name,
        builder: builder,
      ),
    );
  }

  void addSettingsAbout({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.settingsAbout),
        name: AppRoute.settingsAbout.name,
        builder: builder,
      ),
    );
  }

  void addSettingsSync({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.settingsSync),
        name: AppRoute.settingsSync.name,
        builder: builder,
      ),
    );
  }

  void addSettingsNotify({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.settingsNotify),
        name: AppRoute.settingsNotify.name,
        builder: builder,
      ),
    );
  }

  void addExperimental({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.experimental),
        name: AppRoute.experimental.name,
        builder: builder,
      ),
    );
  }

  void addDebugger({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.debugger),
        name: AppRoute.debugger.name,
        builder: builder,
      ),
    );
  }

  void addGroupManage({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.groupManage),
        name: AppRoute.groupManage.name,
        builder: builder,
      ),
    );
  }

  void addHabitsStatus({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitsStatus),
        name: AppRoute.habitsStatus.name,
        builder: builder,
      ),
    );
  }
}

/// Branch-scoped route collector for [AppRouterBuilder.addShellRoute].
class BranchRouterBuilder with _AppRouteAdder {
  @override
  final List<RouteBase> _routes = [];
}

/// Route collector for app-internal flows shown inside the app chrome but
/// outside any individual tab branch.
class AppFlowRouterBuilder with _AppRouteAdder {
  @override
  final List<RouteBase> _routes = [];
}

class AppRouterBuilder with _AppRouteAdder {
  @override
  final List<RouteBase> _routes = [];

  /// Builds the state-preserving tab container and composes each branch
  /// Navigator's back handling into the enclosing shell route.
  static Widget _buildBranchNavigatorContainer(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  ) {
    final currentIndex = navigationShell.currentIndex;
    final branches = navigationShell.route.branches;
    assert(branches.length == children.length);
    return IndexedStack(
      index: currentIndex,
      children: [
        for (final (index, child) in children.indexed)
          NavigatorPopHandler<Object?>(
            enabled: index == currentIndex,
            onPopWithResult: index == currentIndex
                ? (result) {
                    final navigator = branches[index].navigatorKey.currentState;
                    if (navigator != null) {
                      unawaited(navigator.maybePop<Object?>(result));
                    }
                  }
                : null,
            child: Offstage(
              offstage: index != currentIndex,
              child: TickerMode(enabled: index == currentIndex, child: child),
            ),
          ),
      ],
    );
  }

  /// Registers an app-chrome [ShellRoute] containing a tab
  /// [StatefulShellRoute] with an indexed, state-preserving branch container.
  ///
  /// Each [BranchRouterBuilder] in [branches] becomes a [StatefulShellBranch]
  /// of the inner shell. [appFlow] routes become siblings of that tab shell on
  /// the outer app-chrome navigator. [branchObservers], when provided, must
  /// have exactly one observer per branch: a [NavigatorObserver] attaches to
  /// a single navigator only, so each branch navigator needs its own instance.
  void addShellRoute({
    required List<BranchRouterBuilder> branches,
    required AppFlowRouterBuilder appFlow,
    List<NavigatorObserver>? branchObservers,
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? navigatorKey,
    required ShellRouteBuilder builder,
    required StatefulShellRouteBuilder branchBuilder,
  }) {
    assert(
      branchObservers == null || branchObservers.length == branches.length,
    );
    _routes.add(
      ShellRoute(
        builder: builder,
        observers: observers,
        navigatorKey: navigatorKey,
        routes: [
          // Match exact common-flow paths before branch parameters such as
          // `/habits/:habitId`; otherwise `/habits/status` is consumed as a
          // Habit Detail route instead of the Status Changer app flow.
          ...appFlow._routes,
          StatefulShellRoute(
            builder: branchBuilder,
            navigatorContainerBuilder: _buildBranchNavigatorContainer,
            branches: [
              for (final (index, branch) in branches.indexed)
                StatefulShellBranch(
                  routes: branch._routes,
                  observers: branchObservers == null
                      ? const <NavigatorObserver>[]
                      : [branchObservers[index]],
                ),
            ],
          ),
        ],
      ),
    );
  }

  GoRouter build({AppRoute? home}) {
    return GoRouter(
      initialLocation: home != null ? _pathFor(home) : null,
      navigatorKey: navigatorKey,
      observers: [currentRouteObserver],
      routes: _routes,
    );
  }
}
