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
/// branch's root route and hidden on anything pushed above it. Routes that
/// cover the shell (edit, create, group manage, status) never consult this
/// policy, and neither does the shell until the active branch has loaded a
/// route.
bool appShellBarVisibilityPolicy(List<String?> routeNames) =>
    routeNames.length == 1;

/// Shared `add*` helpers for [AppRouterBuilder] and [BranchRouterBuilder].
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

class AppRouterBuilder with _AppRouteAdder {
  @override
  final List<RouteBase> _routes = [];

  /// Registers a [StatefulShellRoute.indexedStack] as a top-level route.
  ///
  /// Each [BranchRouterBuilder] in [branches] becomes a [StatefulShellBranch]
  /// of the shell. [branchObservers], when provided, must have exactly one
  /// observer per branch: a [NavigatorObserver] attaches to a single
  /// navigator only, so each branch navigator needs its own instance.
  void addShellRoute({
    required List<BranchRouterBuilder> branches,
    List<NavigatorObserver>? branchObservers,
    required StatefulShellRouteBuilder builder,
  }) {
    assert(
      branchObservers == null || branchObservers.length == branches.length,
    );
    _routes.add(
      StatefulShellRoute.indexedStack(
        builder: builder,
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
