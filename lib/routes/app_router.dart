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
  habits('habits');

  const AppRoute(this.name);
  final String name;
}

class AppRouterBuilder {
  final List<RouteBase> _routes = [];

  static String _pathFor(AppRoute route) => switch (route) {
    AppRoute.habits => '/habits',
  };

  AppRouterBuilder addHabits({required GoRouterWidgetBuilder builder}) {
    const route = AppRoute.habits;
    _routes.add(
      GoRoute(path: _pathFor(route), name: route.name, builder: builder),
    );
    return this;
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
