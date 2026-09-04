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
import 'app_material_page.dart';

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
            name == AppRoute.habitsStatus.name ||
            name == AppRoute.groupManage.name ||
            isSettingsFlowRouteName(name) =>
      false,
    _ => true,
  };
}

/// Whether [routeName] belongs to the Settings app flow itself.
bool isSettingsFlowRouteName(String? routeName) => switch (routeName) {
  final name
      when name == AppRoute.settings.name ||
          name == AppRoute.settingsAbout.name ||
          name == AppRoute.settingsSync.name ||
          name == AppRoute.settingsNotify.name ||
          name == AppRoute.experimental.name =>
    true,
  _ => false,
};

/// Whether Settings should be selected in the auxiliary navigation chrome.
///
/// Group Manage is a standalone app-flow route, so its selection follows the
/// route that opened it: a Settings source keeps Settings selected, while a
/// primary-branch source keeps that branch selected.
bool isSettingsAuxiliaryRouteStack(List<String?> routeNames) {
  if (routeNames.isEmpty) return false;
  final topRouteName = routeNames.last;
  if (isSettingsFlowRouteName(topRouteName)) return true;
  if (topRouteName != AppRoute.groupManage.name) return false;
  return routeNames.take(routeNames.length - 1).any(isSettingsFlowRouteName);
}

/// Shared `add*` helpers for the app's route collectors.
///
/// Keeps route path/name knowledge in this library; callers supply only
/// widget builders.
mixin _AppRouteAdder {
  List<RouteBase> get _routes;

  void _addRoute(AppRoute route, GoRouterWidgetBuilder builder) {
    _routes.add(
      GoRoute(
        path: _pathFor(route),
        name: route.name,
        pageBuilder: _appPageBuilder(builder),
      ),
    );
  }

  void addHabits({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.habits, builder);
  }

  void addToday({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.today, builder);
  }

  void addHabitDetail({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.habitDetail, builder);
  }

  void addHabitCreate({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.habitCreate, builder);
  }

  void addHabitEdit({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.habitEdit, builder);
  }

  void addDebugger({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.debugger, builder);
  }

  void addGroupManage({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.groupManage, builder);
  }

  void addHabitsStatus({required GoRouterWidgetBuilder builder}) {
    _addRoute(AppRoute.habitsStatus, builder);
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

  /// Registers Settings and its page hierarchy as one auxiliary app flow.
  void addSettingsFlow({
    required GoRouterPageBuilder settingsBuilder,
    required GoRouterWidgetBuilder aboutBuilder,
    required GoRouterWidgetBuilder syncBuilder,
    required GoRouterWidgetBuilder notifyBuilder,
    required GoRouterWidgetBuilder experimentalBuilder,
  }) {
    _routes
      ..add(
        GoRoute(
          path: _pathFor(AppRoute.settings),
          name: AppRoute.settings.name,
          pageBuilder: settingsBuilder,
          routes: [
            GoRoute(
              path: 'about',
              name: AppRoute.settingsAbout.name,
              pageBuilder: _appPageBuilder(aboutBuilder),
            ),
            GoRoute(
              path: 'sync',
              name: AppRoute.settingsSync.name,
              pageBuilder: _appPageBuilder(syncBuilder),
            ),
            GoRoute(
              path: 'notify',
              name: AppRoute.settingsNotify.name,
              pageBuilder: _appPageBuilder(notifyBuilder),
            ),
          ],
        ),
      )
      // Keep the published path stable even though this page is entered from
      // Settings and participates in the same auxiliary presentation state.
      ..add(
        GoRoute(
          path: _pathFor(AppRoute.experimental),
          name: AppRoute.experimental.name,
          pageBuilder: _appPageBuilder(experimentalBuilder),
        ),
      );
  }
}

/// Adapts a [GoRouterWidgetBuilder] into an app-owned Material page builder
/// without changing the widget builder's context semantics.
///
/// The extra [Builder] matches go_router's own Material-page adapter: it
/// defers the widget builder until the page route is building its subtree.
/// Calling [builder] with the `pageBuilder` context here would place that call
/// above the new [ModalRoute] and go_router's route-state registry.
GoRouterPageBuilder _appPageBuilder(GoRouterWidgetBuilder builder) =>
    (context, state) => AppMaterialPage<void>.fromGoRoute(
      state: state,
      child: Builder(builder: (context) => builder(context, state)),
    );

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
