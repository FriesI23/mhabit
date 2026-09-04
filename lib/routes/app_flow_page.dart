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

import 'app_material_page.dart';

/// A page whose route identity stays stable while its transition mode changes.
///
/// Compact app flows can use the active Material page transition, including
/// Android predictive back, while wider forms can disable route animation
/// without replacing the route with a different [Page] runtime type.
final class AppFlowPage<T> extends Page<T> {
  /// Creates an app-flow page.
  const AppFlowPage({
    required this.child,
    required this.transitionsEnabled,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// Content displayed by the route.
  final Widget child;

  /// Whether the active Material page transition is rendered.
  final bool transitionsEnabled;

  @override
  Route<T> createRoute(BuildContext context) =>
      _AppFlowPageRoute<T>(page: this);
}

final class _AppFlowPageRoute<T> extends AppPageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _AppFlowPageRoute({required AppFlowPage<T> page}) : super(settings: page);

  AppFlowPage<T> get _page => settings as AppFlowPage<T>;

  @override
  Duration get transitionDuration =>
      _page.transitionsEnabled ? super.transitionDuration : Duration.zero;

  @override
  Duration get reverseTransitionDuration => _page.transitionsEnabled
      ? super.reverseTransitionDuration
      : Duration.zero;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => _page.transitionsEnabled
      ? super.buildTransitions(context, animation, secondaryAnimation, child)
      : child;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;
}
