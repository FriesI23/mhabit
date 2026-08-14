import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

GoRouter _buildRouter({
  List<NavigationDestination>? destinations,
  ValueChanged<int>? onBranchChanged,
  List<AdaptiveBranchRouteObserver>? observers,
  bool Function(List<String?> routeNames)? barVisibilityPolicy,
}) {
  return GoRouter(
    initialLocation: '/habits',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdaptiveNavigationShell(
          navigationShell: navigationShell,
          branchObservers: observers ?? const [],
          barVisibilityPolicy: barVisibilityPolicy,
          destinations:
              destinations ??
              const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Habits',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Today',
                ),
              ],
          onBranchChanged: onBranchChanged,
        ),
        branches: [
          StatefulShellBranch(
            observers: observers == null
                ? const <NavigatorObserver>[]
                : [observers[0]],
            routes: [
              GoRoute(
                path: '/habits',
                name: 'habits-root',
                builder: (_, _) => const _StubPage(text: 'habits page'),
              ),
              GoRoute(
                path: '/habits/detail',
                name: 'habits-detail',
                builder: (_, _) => const _StubPage(text: 'detail page'),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: observers == null
                ? const <NavigatorObserver>[]
                : [observers[1]],
            routes: [
              GoRoute(
                path: '/today',
                name: 'today-root',
                builder: (_, _) => const _StubPage(text: 'today page'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(text)));
  }
}

void main() {
  group('AdaptiveNavigationShell', () {
    testWidgets('renders destinations and switches branch on tap', (
      tester,
    ) async {
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('habits page'), findsOneWidget);
      expect(find.text('today page'), findsNothing);

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      expect(find.text('today page'), findsOneWidget);
      expect(find.text('habits page'), findsNothing);
    });

    testWidgets('switches branches with one observer per branch', (
      tester,
    ) async {
      final observers = [
        AdaptiveBranchRouteObserver(),
        AdaptiveBranchRouteObserver(),
      ];
      final router = _buildRouter(observers: observers);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.text('habits page'), findsOneWidget);

      router.go('/today');
      await tester.pumpAndSettle();

      expect(find.text('today page'), findsOneWidget);
      expect(find.text('habits page'), findsNothing);
    });

    testWidgets('does not transiently hide the bar on lazy branch activation', (
      tester,
    ) async {
      final observers = [
        AdaptiveBranchRouteObserver(),
        AdaptiveBranchRouteObserver(),
      ];
      final router = _buildRouter(observers: observers);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.visible.value, isTrue);

      // The today branch navigator is created lazily on first activation.
      // While its stack is still empty the shell must not report the bar as
      // hidden; every visibility change during the switch is recorded to
      // catch a transient hide/show flip that settles invisible.
      final changes = <bool>[];
      scope.visible.addListener(() => changes.add(scope.visible.value));

      router.go('/today');
      await tester.pumpAndSettle();

      expect(find.text('today page'), findsOneWidget);
      expect(scope.visible.value, isTrue);
      expect(changes, isEmpty);
    });

    testWidgets('resets visibility and reports branch change via listener', (
      tester,
    ) async {
      final changes = <int>[];
      final router = _buildRouter(onBranchChanged: changes.add);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      scope.scrollWish.value = false;
      await tester.pumpAndSettle();
      expect(scope.visible.value, isFalse);

      router.go('/today');
      await tester.pumpAndSettle();

      expect(changes, [1]);
      expect(scope.visible.value, isTrue);
    });

    testWidgets('animates the bar out when visibility is set to false', (
      tester,
    ) async {
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      scope.scrollWish.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(NavigationBar),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0);
    });

    testWidgets(
      'hides the bar when a branch route is pushed, restores on pop',
      (tester) async {
        final observers = [
          AdaptiveBranchRouteObserver(),
          AdaptiveBranchRouteObserver(),
        ];
        final router = _buildRouter(observers: observers);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        final scope = AdaptiveNavScope.of(
          tester.element(find.text('habits page')),
        );
        expect(scope.visible.value, isTrue);

        router.push('/habits/detail');
        await tester.pumpAndSettle();

        expect(find.text('detail page'), findsOneWidget);
        expect(scope.visible.value, isFalse);

        router.pop();
        await tester.pumpAndSettle();

        expect(find.text('habits page'), findsOneWidget);
        expect(scope.visible.value, isTrue);
      },
    );

    testWidgets(
      'inherits hidden bar across unnamed routes pushed above (dialogs)',
      (tester) async {
        final observers = [
          AdaptiveBranchRouteObserver(),
          AdaptiveBranchRouteObserver(),
        ];
        final router = _buildRouter(
          observers: observers,
          barVisibilityPolicy: (routeNames) =>
              !routeNames.contains('habits-detail'),
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        router.push('/habits/detail');
        await tester.pumpAndSettle();
        final detailContext = tester.element(find.text('detail page'));

        // Push an unnamed dialog route onto the branch navigator.
        showDialog<void>(
          context: detailContext,
          useRootNavigator: false,
          builder: (context) => const AlertDialog(title: Text('dialog')),
        );
        await tester.pumpAndSettle();

        expect(AdaptiveNavScope.of(detailContext).visible.value, isFalse);

        // Closing the dialog keeps the bar hidden (detail still below it).
        Navigator.of(detailContext).pop();
        await tester.pumpAndSettle();
        expect(
          AdaptiveNavScope.of(
            tester.element(find.text('detail page')),
          ).visible.value,
          isFalse,
        );
      },
    );

    testWidgets('shows the bar on pushed routes when the policy allows', (
      tester,
    ) async {
      final observers = [
        AdaptiveBranchRouteObserver(),
        AdaptiveBranchRouteObserver(),
      ];
      final router = _buildRouter(
        observers: observers,
        barVisibilityPolicy: (routeNames) =>
            routeNames.contains('habits-detail')
            ? true
            : routeNames.length == 1,
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.visible.value, isTrue);

      router.push('/habits/detail');
      await tester.pumpAndSettle();

      expect(find.text('detail page'), findsOneWidget);
      expect(scope.visible.value, isTrue);
    });

    testWidgets('recomputes bar visibility when switching branches', (
      tester,
    ) async {
      final observers = [
        AdaptiveBranchRouteObserver(),
        AdaptiveBranchRouteObserver(),
      ];
      final router = _buildRouter(observers: observers);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

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

    testWidgets('resolves bar height and label behavior by width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final wideScope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(wideScope.barHeight, kBottomNavigationBarHeight);
      expect(wideScope.navHeight, kBottomNavigationBarHeight);
      var bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, kBottomNavigationBarHeight);
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysHide);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      final narrowScope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(narrowScope.barHeight, 80.0);
      expect(narrowScope.navHeight, 80.0);
      bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, 80.0);
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
    });
  });

  group('AdaptiveBranchRouteObserver', () {
    Route<dynamic> buildRoute(String name) => MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox.shrink(),
    );

    test('tracks stack depth and top route name', () {
      final observer = AdaptiveBranchRouteObserver();
      final root = buildRoute('habits-root');
      final detail = buildRoute('habits-detail');

      observer.didPush(root, null);
      expect(observer.depth, 1);
      expect(observer.topRouteName, 'habits-root');

      observer.didPush(detail, root);
      expect(observer.depth, 2);
      expect(observer.topRouteName, 'habits-detail');

      observer.didPop(detail, root);
      expect(observer.depth, 1);
      expect(observer.topRouteName, 'habits-root');

      // Flutter reports didRemove for popped routes as well; the observer
      // must not double-count.
      observer.didRemove(detail, root);
      expect(observer.depth, 1);
      expect(observer.topRouteName, 'habits-root');

      observer.didReplace(newRoute: buildRoute('replaced'), oldRoute: root);
      expect(observer.depth, 1);
      expect(observer.topRouteName, 'replaced');
    });
  });
}
