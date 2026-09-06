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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A Material page whose route ignores predictive back while an ancestor
/// navigator has a route above it.
///
/// A route can remain current in a nested navigator while a dialog, sheet, or
/// page on an ancestor navigator covers it. Flutter's predictive-back detector
/// otherwise treats both routes as eligible and can pop the covered route.
///
/// This works around
/// [flutter/flutter#152323](https://github.com/flutter/flutter/issues/152323).
/// Remove the ancestor-aware route override once the minimum Flutter version
/// contains an equivalent framework fix.
final class AppMaterialPage<T> extends Page<T> {
  const AppMaterialPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    super.canPop,
    super.onPopInvoked,
    super.name,
    super.arguments,
    super.restorationId,
  });

  AppMaterialPage.fromGoRoute({
    required GoRouterState state,
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
  }) : super(
         key: state.pageKey,
         name: state.name ?? state.path,
         arguments: <String, String>{
           ...state.pathParameters,
           ...state.uri.queryParameters,
         },
         restorationId: state.pageKey.value,
       );

  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool allowSnapshotting;

  @override
  Route<T> createRoute(BuildContext context) =>
      _AppMaterialPageRoute<T>(page: this);
}

/// Base route for app pages that participate in ancestor-aware predictive
/// back handling without changing their normal pop disposition. This is the
/// route-level workaround for
/// [flutter/flutter#152323](https://github.com/flutter/flutter/issues/152323).
abstract base class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({required super.settings, super.allowSnapshotting});

  @override
  bool get popGestureEnabled =>
      !isRouteCoveredByAncestorRoute(this) && super.popGestureEnabled;
}

final class _AppMaterialPageRoute<T> extends AppPageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _AppMaterialPageRoute({required AppMaterialPage<T> page})
    : super(settings: page, allowSnapshotting: page.allowSnapshotting);

  AppMaterialPage<T> get _page => settings as AppMaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

/// Whether [route]'s navigator is covered by a route on an ancestor navigator.
///
/// Each shell contributes another navigator/route pair, so the entire
/// navigator ancestry must be checked. Routes on the root navigator itself
/// have no ancestor route and are never considered covered.
bool isRouteCoveredByAncestorRoute(PageRoute<dynamic> route) {
  NavigatorState? navigator = route.navigator;
  final visitedNavigators = <NavigatorState>{};
  while (navigator != null && visitedNavigators.add(navigator)) {
    final ancestorRoute = ModalRoute.of(navigator.context);
    if (ancestorRoute == null) return false;
    if (!ancestorRoute.isCurrent) return true;
    navigator = ancestorRoute.navigator;
  }
  return false;
}
