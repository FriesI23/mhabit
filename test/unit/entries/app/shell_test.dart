import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mhabit/entries/app/shell.dart';
import 'package:mhabit/models/app_entry.dart';
import 'package:mhabit/providers/app_ui/app_launch_entry.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

class _RecordingLaunchEntryViewModel extends AppLaunchEntryViewModel {
  final List<AppEntrys> entries = [];

  @override
  Future<void> setNewLaunchEntry(AppEntrys newLaunchEntry) async {
    entries.add(newLaunchEntry);
  }
}

class _StubPage extends StatelessWidget {
  const _StubPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

GoRouter _buildRouter(List<AdaptiveBranchRouteObserver> observers) {
  final appFlowObserver = AdaptiveBranchRouteObserver();
  final appChromeNavigatorKey = GlobalKey<NavigatorState>();
  final coordinator = AppNavigationCoordinator(
    branchObservers: observers,
    appFlowObserver: appFlowObserver,
    appChromeNavigatorKey: appChromeNavigatorKey,
    initialIndex: 0,
  );
  addTearDown(coordinator.dispose);
  return GoRouter(
    initialLocation: '/habits',
    routes: [
      ShellRoute(
        navigatorKey: appChromeNavigatorKey,
        observers: [appFlowObserver],
        builder: (context, state, child) =>
            AppNavigationShell(coordinator: coordinator, child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              coordinator.attachTabShell(navigationShell);
              return navigationShell;
            },
            branches: [
              StatefulShellBranch(
                observers: [observers[0]],
                routes: [
                  GoRoute(
                    path: '/habits',
                    name: 'habits',
                    builder: (_, _) => const _StubPage('habits page'),
                  ),
                  GoRoute(
                    path: '/habits/detail',
                    name: 'habits-detail',
                    builder: (_, _) => const _StubPage('detail page'),
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [observers[1]],
                routes: [
                  GoRoute(
                    path: '/today',
                    name: 'today',
                    builder: (_, _) => const _StubPage('today page'),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/habit/create',
            name: 'habit/create',
            builder: (_, _) => const _StubPage('create page'),
          ),
          GoRoute(
            path: '/habit/edit',
            name: 'habit/edit',
            builder: (_, state) => state.uri.queryParameters['block'] == 'true'
                ? const PopScope<void>(
                    canPop: false,
                    child: _StubPage('edit page'),
                  )
                : const _StubPage('edit page'),
          ),
        ],
      ),
    ],
  );
}

void _setCompactSurface(WidgetTester tester) {
  _setSurface(tester, const Size(400, 800));
}

void _setSurface(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required GoRouter router,
  required AppLaunchEntryViewModel launchEntry,
}) {
  return tester.pumpWidget(
    ChangeNotifierProvider<AppLaunchEntryViewModel>.value(
      value: launchEntry,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('derives compact bar visibility from the active branch stack', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    final rootScope = AdaptiveNavScope.of(
      tester.element(find.text('habits page')),
    );
    expect(rootScope.visible.value, isTrue);

    router.push('/habits/detail');
    await tester.pumpAndSettle();
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('detail page')),
      ).visible.value,
      isFalse,
    );

    router.pop();
    await tester.pumpAndSettle();
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      ).visible.value,
      isTrue,
    );
  });

  testWidgets('switches branch and persists the selected launch entry', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    final launchEntry = _RecordingLaunchEntryViewModel();
    addTearDown(router.dispose);
    await _pumpApp(tester, router: router, launchEntry: launchEntry);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('today page'), findsOneWidget);
    expect(launchEntry.entries, [AppEntrys.habitToday]);
  });

  testWidgets('keeps the compact bar visible during lazy branch activation', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );
    await tester.pumpAndSettle();

    final scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
    final changes = <bool>[];
    scope.visible.addListener(() => changes.add(scope.visible.value));

    router.go('/today');
    await tester.pumpAndSettle();

    expect(find.text('today page'), findsOneWidget);
    expect(scope.visible.value, isTrue);
    expect(changes, isEmpty);
  });

  testWidgets('keeps detail chrome hidden across an unnamed branch dialog', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habits/detail');
    await tester.pumpAndSettle();
    final detailContext = tester.element(find.text('detail page'));

    showDialog<void>(
      context: detailContext,
      useRootNavigator: false,
      builder: (context) => const AlertDialog(title: Text('dialog')),
    );
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsOneWidget);
    expect(observers[0].routeNameStack, ['habits', 'habits-detail', null]);
    expect(AdaptiveNavScope.of(detailContext).visible.value, isFalse);

    Navigator.of(detailContext).pop();
    await tester.pumpAndSettle();

    expect(observers[0].routeNameStack, ['habits', 'habits-detail']);
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('detail page')),
      ).visible.value,
      isFalse,
    );
  });

  testWidgets('shows compact chrome after leaving a hidden detail branch', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habits/detail');
    await tester.pumpAndSettle();
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('detail page')),
      ).visible.value,
      isFalse,
    );

    router.go('/today');
    await tester.pumpAndSettle();

    expect(find.text('today page'), findsOneWidget);
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('today page')),
      ).visible.value,
      isTrue,
    );
  });

  testWidgets('preserves a branch stack across rail destination switches', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 600));
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habits/detail');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(MdiIcons.calendarTodayOutline));
    await tester.pumpAndSettle();
    expect(find.text('today page'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.text('detail page'), findsOneWidget);
    expect(observers[0].routeNameStack, ['habits', 'habits-detail']);
  });

  testWidgets('pushes create inside app chrome and returns to habits', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    final result = router.push<String>('/habit/create');
    await tester.pumpAndSettle();

    expect(find.text('create page'), findsOneWidget);
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('create page')),
      ).visible.value,
      isFalse,
    );

    router.pop('created');
    await tester.pumpAndSettle();

    expect(find.text('habits page'), findsOneWidget);
    expect(await result, 'created');
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      ).visible.value,
      isTrue,
    );
  });

  testWidgets('returns from edit to the source detail route', (tester) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habits/detail');
    await tester.pumpAndSettle();
    router.push('/habit/edit');
    await tester.pumpAndSettle();

    expect(find.text('edit page'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('detail page'), findsOneWidget);
    expect(observers[0].routeNameStack, ['habits', 'habits-detail']);
  });

  testWidgets('returns from edit to the source today branch', (tester) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.go('/today');
    await tester.pumpAndSettle();
    router.push('/habit/edit');
    await tester.pumpAndSettle();

    expect(find.text('edit page'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('today page'), findsOneWidget);
  });

  testWidgets('rail selection closes app flow before switching branch', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 600));
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habit/edit');
    await tester.pumpAndSettle();
    expect(find.text('edit page'), findsOneWidget);

    await tester.tap(find.byIcon(MdiIcons.calendarTodayOutline));
    await tester.pumpAndSettle();

    expect(find.text('edit page'), findsNothing);
    expect(find.text('today page'), findsOneWidget);
  });

  testWidgets('rail selection respects an app flow PopScope veto', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 600));
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(observers);
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );

    router.push('/habit/edit?block=true');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(MdiIcons.calendarTodayOutline));
    await tester.pumpAndSettle();

    expect(find.text('edit page'), findsOneWidget);
    expect(find.text('today page'), findsNothing);
  });
}
