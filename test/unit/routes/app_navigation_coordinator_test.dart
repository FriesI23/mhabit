// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/routes/app_navigation_branch.dart';
import 'package:mhabit/routes/app_navigation_coordinator.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Route<void> _route(String? name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

void main() {
  test('same-depth replacements notify root availability changes', () async {
    final branches = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final flow = AdaptiveBranchRouteObserver();
    final navigation = AppNavigationCoordinator(
      branchObservers: branches,
      appFlowObserver: flow,
      appChromeNavigatorKey: GlobalKey<NavigatorState>(),
      initialIndex: 0,
    );
    addTearDown(navigation.dispose);
    flow.didPush(_route(null), null);
    final root = _route(AppRoute.habits.name);
    branches.first.didPush(root, null);
    await pumpEventQueue();
    final availability = <bool>[];
    navigation.addListener(
      () => availability.add(
        navigation.isAtPrimaryBranchRoot(AppNavigationBranch.habits),
      ),
    );
    final detail = _route(AppRoute.habitDetail.name);
    branches.first.didReplace(oldRoute: root, newRoute: detail);
    await pumpEventQueue();
    expect(availability, [false]);
    branches.first.didReplace(oldRoute: detail, newRoute: root);
    await pumpEventQueue();
    expect(availability, [false, true]);
  });
  for (final branch in AppNavigationBranch.values) {
    test(
      'only $branch actual root permits root-only UI after replacements',
      () {
        final branches = [
          AdaptiveBranchRouteObserver(),
          AdaptiveBranchRouteObserver(),
        ];
        final flow = AdaptiveBranchRouteObserver();
        final navigation = AppNavigationCoordinator(
          branchObservers: branches,
          appFlowObserver: flow,
          appChromeNavigatorKey: GlobalKey<NavigatorState>(),
          initialIndex: branch.navigationIndex,
        );
        addTearDown(navigation.dispose);
        expect(navigation.isAtPrimaryBranchRoot(branch), isFalse);
        final shell = _route(null);
        flow.didPush(shell, null);
        final root = _route(branch.rootRouteName);
        final observer = branches[branch.navigationIndex];
        observer.didPush(root, null);
        expect(navigation.isAtPrimaryBranchRoot(branch), isTrue);

        final detail = _route(AppRoute.habitDetail.name);
        observer.didReplace(oldRoute: root, newRoute: detail);
        expect(observer.depth, 1);
        expect(navigation.isAtPrimaryBranchRoot(branch), isFalse);
        observer.didReplace(oldRoute: detail, newRoute: root);
        expect(navigation.isAtPrimaryBranchRoot(branch), isTrue);

        final settings = _route(AppRoute.settings.name);
        flow.didReplace(oldRoute: shell, newRoute: settings);
        expect(flow.depth, 1);
        expect(navigation.isAtPrimaryBranchRoot(branch), isFalse);
        flow.didReplace(oldRoute: settings, newRoute: shell);

        final popup = _route(null);
        observer.didPush(popup, root);
        expect(navigation.isAtPrimaryBranchRoot(branch), isFalse);
        observer.didPop(popup, root);
        expect(navigation.isAtPrimaryBranchRoot(branch), isTrue);
        final other = AppNavigationBranch.values.firstWhere(
          (value) => value != branch,
        );
        expect(navigation.isAtPrimaryBranchRoot(other), isFalse);
      },
    );
  }
}
