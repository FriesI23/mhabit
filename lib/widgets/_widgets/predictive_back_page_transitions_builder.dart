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

class CustomPredictiveBackPageTransitionsBuilder
    extends PredictiveBackPageTransitionsBuilder {
  static const kTransitionMilliseconds =
      FadeForwardsPageTransitionsBuilder.kTransitionMilliseconds ~/ 2;

  @override
  final Duration transitionDuration;

  const CustomPredictiveBackPageTransitionsBuilder({
    this.transitionDuration = const Duration(
      milliseconds:
          CustomPredictiveBackPageTransitionsBuilder.kTransitionMilliseconds,
    ),
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (isRouteCoveredByRootRoute(route)) {
      // A root-level route (dialog, bottom sheet, or page) covers this
      // route's navigator, so drop the predictive back detector: the
      // gesture then pops only the covering route.
      return const FadeForwardsPageTransitionsBuilder().buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

/// Whether [route]'s navigator is covered by a route on an ancestor navigator.
///
/// A route whose navigator sits inside a [ModalRoute] on the root navigator
/// (e.g. a go_router shell branch inside the shell route) must not take part
/// in the Android predictive back gesture while that ancestor route is not
/// the current root route: the gesture would otherwise pop this route
/// instead of the covering modal. See
/// [flutter/flutter#152323](https://github.com/flutter/flutter/issues/152323).
///
/// Every shell adds another navigator/route pair, so checking only the nearest
/// ancestor is insufficient for routes inside a stateful shell branch. Walk
/// the complete navigator ancestry until a non-current covering route is found.
/// Routes on the root navigator itself have no such ancestor and return false.
bool isRouteCoveredByRootRoute(PageRoute<dynamic> route) {
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
