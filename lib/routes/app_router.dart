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

import 'package:go_router/go_router.dart';

import '../../common/global.dart';

enum AppRoute {
  habits('habits'),
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

class AppRouterBuilder {
  final List<RouteBase> _routes = [];

  static String _pathFor(AppRoute route) => switch (route) {
    AppRoute.habits => '/habits',
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

  void addHabits({required GoRouterWidgetBuilder builder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habits),
        name: AppRoute.habits.name,
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

  void addHabitCreate({required GoRouterPageBuilder pageBuilder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitCreate),
        name: AppRoute.habitCreate.name,
        pageBuilder: pageBuilder,
      ),
    );
  }

  void addHabitEdit({required GoRouterPageBuilder pageBuilder}) {
    _routes.add(
      GoRoute(
        path: _pathFor(AppRoute.habitEdit),
        name: AppRoute.habitEdit.name,
        pageBuilder: pageBuilder,
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

  GoRouter build({AppRoute? home}) {
    return GoRouter(
      initialLocation: home != null ? _pathFor(home) : null,
      navigatorKey: navigatorKey,
      observers: [currentRouteObserver],
      routes: _routes,
    );
  }
}
