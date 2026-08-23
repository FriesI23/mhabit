import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

_TestRouter _buildRouter({
  List<NavigationDestination>? destinations,
  ValueChanged<int>? onBranchChanged,
  List<AdaptiveBranchRouteObserver>? observers,
  bool Function(List<String?> routeNames)? barVisibilityPolicy,
}) {
  return _TestRouter(
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
    observers: observers ?? const [],
    barVisibilityPolicy: barVisibilityPolicy,
  );
}

class _TestRouter extends RouterConfig<Object> {
  factory _TestRouter({
    required List<NavigationDestination> destinations,
    required List<AdaptiveBranchRouteObserver> observers,
    ValueChanged<int>? onBranchChanged,
    bool Function(List<String?> routeNames)? barVisibilityPolicy,
  }) {
    final delegate = _TestRouterDelegate(
      destinations: destinations,
      onBranchChanged: onBranchChanged,
      observers: observers,
      barVisibilityPolicy: barVisibilityPolicy,
    );
    return _TestRouter._(delegate);
  }

  const _TestRouter._(this.delegate) : super(routerDelegate: delegate);

  final _TestRouterDelegate delegate;

  void go(String location) => delegate.go(location);

  void push(String location) => delegate.push(location);

  void pop() => delegate.pop();
}

class _TestRouteEntry {
  _TestRouteEntry({required this.name, required this.label})
    : route = MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (_) => const SizedBox.shrink(),
      );

  final String name;
  final String label;
  final Route<void> route;
}

class _TestRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _TestRouterDelegate({
    required this.destinations,
    required this.observers,
    this.onBranchChanged,
    this.barVisibilityPolicy,
  }) {
    _pushEntry(
      0,
      _TestRouteEntry(name: 'habits-root', label: 'habits page'),
      notify: false,
    );
  }

  final List<NavigationDestination> destinations;
  final List<AdaptiveBranchRouteObserver> observers;
  final ValueChanged<int>? onBranchChanged;
  final bool Function(List<String?> routeNames)? barVisibilityPolicy;

  final List<List<_TestRouteEntry>> _branchStacks = [[], []];
  int _selectedIndex = 0;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool get _compactRouteVisible {
    final routeNames = _branchStacks[_selectedIndex]
        .map<String?>((entry) => entry.name)
        .toList(growable: false);
    final policy = barVisibilityPolicy;
    return policy == null ? routeNames.length == 1 : policy(routeNames);
  }

  void go(String location) {
    final nextIndex = switch (location) {
      '/habits' => 0,
      '/today' => 1,
      _ => throw ArgumentError.value(location, 'location'),
    };
    if (_branchStacks[nextIndex].isEmpty) {
      _pushEntry(
        nextIndex,
        _TestRouteEntry(
          name: nextIndex == 0 ? 'habits-root' : 'today-root',
          label: nextIndex == 0 ? 'habits page' : 'today page',
        ),
        notify: false,
      );
    }
    if (nextIndex == _selectedIndex) return;
    _selectedIndex = nextIndex;
    onBranchChanged?.call(nextIndex);
    notifyListeners();
  }

  void push(String location) {
    if (location != '/habits/detail' || _selectedIndex != 0) {
      throw ArgumentError.value(location, 'location');
    }
    _pushEntry(0, _TestRouteEntry(name: 'habits-detail', label: 'detail page'));
  }

  void pop() {
    final stack = _branchStacks[_selectedIndex];
    if (stack.length <= 1) return;
    final removed = stack.removeLast();
    _observerFor(_selectedIndex)?.didPop(removed.route, stack.last.route);
    notifyListeners();
  }

  AdaptiveBranchRouteObserver? _observerFor(int index) {
    return index < observers.length ? observers[index] : null;
  }

  void _pushEntry(int index, _TestRouteEntry entry, {bool notify = true}) {
    final stack = _branchStacks[index];
    final previousRoute = stack.isEmpty ? null : stack.last.route;
    stack.add(entry);
    _observerFor(index)?.didPush(entry.route, previousRoute);
    if (notify) notifyListeners();
  }

  void _selectDestination(int index) {
    go(index == 0 ? '/habits' : '/today');
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = _branchStacks[_selectedIndex].last;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: const ValueKey('test-shell'),
          child: AdaptiveNavigationShell(
            selectedIndex: _selectedIndex,
            destinations: destinations,
            compactRouteVisible: _compactRouteVisible,
            onDestinationSelected: _selectDestination,
            child: _StubPage(text: currentEntry.label),
          ),
        ),
      ],
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<bool> popRoute() async {
    if (_branchStacks[_selectedIndex].length <= 1) return false;
    pop();
    return true;
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            SizedBox(
              key: const ValueKey('branch-bottom-padding'),
              height: bottomPadding,
            ),
            TextButton(
              key: const ValueKey('show-snackbar'),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('saved'),
                ),
              ),
              child: const Text('Show Snackbar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabStubPage extends StatelessWidget {
  const _FabStubPage();

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveNavScope.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: scope.visible,
        builder: (context, visible, child) => Padding(
          padding: EdgeInsets.only(bottom: visible ? scope.barHeight : 0),
          child: child,
        ),
        child: const FloatingActionButton(
          key: ValueKey('test-fab'),
          onPressed: null,
        ),
      ),
    );
  }
}

class _ScopeLookupProbe extends StatelessWidget {
  const _ScopeLookupProbe({required this.listen, required this.onBuild});

  final bool listen;
  final ValueChanged<double> onBuild;

  @override
  Widget build(BuildContext context) {
    final scope = listen
        ? AdaptiveNavScope.maybeOf(context)
        : AdaptiveNavScope.maybeRead(context);
    onBuild(scope!.barHeight);
    return const SizedBox.shrink();
  }
}

/// Pins the test surface to [size] logical pixels for this test.
///
/// The default test surface is 800x600, which already classifies as medium;
/// compact shell cases must pin a narrow viewport explicitly.
void _setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('scope lookups distinguish listening from read access', (
    tester,
  ) async {
    final barHeight = ValueNotifier(80.0);
    final listeningBuilds = <double>[];
    final readBuilds = <double>[];
    addTearDown(barHeight.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<double>(
        valueListenable: barHeight,
        child: Column(
          children: [
            _ScopeLookupProbe(listen: true, onBuild: listeningBuilds.add),
            _ScopeLookupProbe(listen: false, onBuild: readBuilds.add),
          ],
        ),
        builder: (context, value, child) =>
            AdaptiveNavScope(barHeight: value, navHeight: value, child: child!),
      ),
    );

    expect(listeningBuilds, [80]);
    expect(readBuilds, [80]);

    barHeight.value = 0;
    await tester.pump();

    expect(listeningBuilds, [80, 0]);
    expect(readBuilds, [80]);
  });

  group('AdaptiveNavigationShell', () {
    testWidgets('renders destinations and switches branch on tap', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
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
      _setSurfaceSize(tester, const Size(400, 800));
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
      _setSurfaceSize(tester, const Size(400, 800));
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
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter(onBranchChanged: changes.add);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      scope.reportScrollWish(false);
      await tester.pumpAndSettle();
      expect(scope.visible.value, isFalse);

      router.go('/today');
      await tester.pumpAndSettle();

      expect(changes, [1]);
      expect(scope.visible.value, isTrue);
    });

    testWidgets('collapses the bar height when visibility is set to false', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      scope.reportScrollWish(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
        0,
      );
    });

    testWidgets(
      'hides the bar when a branch route is pushed, restores on pop',
      (tester) async {
        final observers = [
          AdaptiveBranchRouteObserver(),
          AdaptiveBranchRouteObserver(),
        ];
        _setSurfaceSize(tester, const Size(400, 800));
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
        _setSurfaceSize(tester, const Size(400, 800));
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
      _setSurfaceSize(tester, const Size(400, 800));
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
      _setSurfaceSize(tester, const Size(400, 800));
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

    testWidgets('compact form shows the bar with labels at 80dp', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.barHeight, 80.0);
      expect(scope.navHeight, 80.0);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, 80.0);
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
    });

    testWidgets('unrelated MediaQuery changes do not rebuild shell chrome', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final navigationBar = tester.widget<AdaptiveNavigationBar>(
        find.byType(AdaptiveNavigationBar),
      );

      tester.platformDispatcher.textScaleFactorTestValue = 1.25;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();

      expect(
        MediaQuery.textScalerOf(
          tester.element(find.text('habits page')),
        ).scale(100),
        125,
      );
      expect(
        tester.widget<AdaptiveNavigationBar>(
          find.byType(AdaptiveNavigationBar),
        ),
        same(navigationBar),
      );
    });

    testWidgets('compact snackbar is shown once above the navigation bar', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byKey(const ValueKey('show-snackbar')));
      await tester.pumpAndSettle();

      final snackBar = find.byType(SnackBar);
      final navigationBar = find.byType(NavigationBar);
      expect(snackBar, findsOneWidget);
      expect(navigationBar, findsOneWidget);
      expect(
        tester.getBottomLeft(snackBar).dy,
        lessThanOrEqualTo(tester.getTopLeft(navigationBar).dy),
      );
    });

    testWidgets('floating snackbar follows the collapsing navigation bar', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byKey(const ValueKey('show-snackbar')));
      await tester.pumpAndSettle();

      final snackBar = find.byType(SnackBar);
      final visibleBottom = tester.getBottomLeft(snackBar).dy;
      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );

      scope.reportScrollWish(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.getBottomLeft(snackBar).dy, greaterThan(visibleBottom));
      expect(
        tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
        0,
      );
    });

    testWidgets('extendBody keeps the branch bottom padding unchanged', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(bottom: 24);
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        tester.getSize(find.byKey(const ValueKey('branch-bottom-padding'))),
        const Size(0, 24),
      );
      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.barHeight, 80);
      expect(scope.navHeight, 104);
    });

    for (final bottomInset in [24.0, 34.0]) {
      testWidgets(
        'compact FAB clears bar and system inset at ${bottomInset}dp',
        (tester) async {
          tester.view.padding = FakeViewPadding(bottom: bottomInset);
          tester.view.viewPadding = FakeViewPadding(bottom: bottomInset);
          _setSurfaceSize(tester, const Size(400, 800));

          await tester.pumpWidget(
            MaterialApp(
              home: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Habits',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    label: 'Today',
                  ),
                ],
                onDestinationSelected: (_) {},
                child: const _FabStubPage(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final fab = find.byKey(const ValueKey('test-fab'));
          final barTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
          expect(
            tester.getBottomRight(fab).dy,
            barTop - kFloatingActionButtonMargin,
          );

          final scope = AdaptiveNavScope.of(tester.element(fab));
          scope.reportScrollWish(false);
          await tester.pumpAndSettle();

          expect(
            tester.getBottomRight(fab).dy,
            800 - bottomInset - kFloatingActionButtonMargin,
          );
        },
      );
    }

    testWidgets('medium form shows an always-visible collapsible rail', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('habits page'), findsOneWidget);

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.barHeight, 0);
      expect(scope.navHeight, 0);
      expect(scope.visible.value, isTrue);
      expect(scope.scrollWish.value, isTrue);

      // Scroll wishes are ignored; the navigation stays visible.
      scope.reportScrollWish(false);
      await tester.pump();
      expect(scope.visible.value, isTrue);
    });

    testWidgets('medium form switches branch from the rail', (tester) async {
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      expect(find.text('today page'), findsOneWidget);
      expect(find.text('habits page'), findsNothing);
    });

    testWidgets('medium form toggles the rail between collapsed and extended', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail rail() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail().extended, isFalse);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(rail().extended, isTrue);

      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(rail().extended, isFalse);
    });

    testWidgets('expanded form defaults to an extended collapsible rail', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1000, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(scope.barHeight, 0);
      expect(scope.visible.value, isTrue);
    });

    testWidgets(
      'expanded compact-height defaults collapsed and remains expandable',
      (tester) async {
        _setSurfaceSize(tester, const Size(1000, 479));
        final router = _buildRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        NavigationRail rail() =>
            tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail().extended, isFalse);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        expect(rail().extended, isTrue);
      },
    );

    testWidgets('large compact-height defaults to a collapsed rail', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1400, 479));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });

    testWidgets('expanded medium-height boundary defaults extended', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1000, 480));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    testWidgets('apple large compact-height defaults to a collapsed rail', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      _setSurfaceSize(tester, const Size(1000, 479));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('compact and medium widths remain authoritative over height', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 1000));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationBar), findsOneWidget);

      tester.view.physicalSize = const Size(700, 1000);
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );

      tester.view.physicalSize = const Size(700, 400);
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });

    testWidgets('unclassified height preserves width-only shell behavior', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1000, 300));
      final router = _buildRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => BreakpointsScope(
            breakpoints: const CustomBreakpoints(width: [600, 840]),
            child: child!,
          ),
        ),
      );

      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    testWidgets('height boundary switches the rail default form at runtime', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1000, 479));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail rail() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail().extended, isFalse);

      tester.view.physicalSize = const Size(1000, 480);
      await tester.pumpAndSettle();
      expect(rail().extended, isTrue);

      tester.view.physicalSize = const Size(1000, 479);
      await tester.pumpAndSettle();
      expect(rail().extended, isFalse);
    });

    testWidgets('macOS classifies with apple tiers', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // macOS resolves the three-tier apple system, so 700dp classifies as
      // medium: a rail collapsed by default.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
      expect(find.byIcon(Icons.menu), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('large form keeps a collapsible rail extended by default', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      expect(find.byIcon(Icons.menu_open), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
    });

    testWidgets('extra-large form keeps the rail at its maximum auto width', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      // Auto width tops out at 180 + 0.7 * (360 - 180) = 306.
      final panel = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel.minExtendedWidth, closeTo(306, 0.01));
      expect(find.byIcon(Icons.menu_open), findsOneWidget);
    });

    testWidgets('rail auto width follows the window within the interval', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1200, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      // Upper bound: 180 + 180 * (1200-600)/1000 = 288;
      // auto: 180 + 0.7 * 108 = 255.6.
      expect(panel().minExtendedWidth, closeTo(255.6, 0.01));

      tester.view.physicalSize = const Size(900, 800);
      await tester.pumpAndSettle();

      // Upper bound: 180 + 180 * (900-600)/1000 = 234;
      // auto: 180 + 0.7 * 54 = 217.8.
      expect(panel().minExtendedWidth, closeTo(217.8, 0.01));
    });

    testWidgets('drag resizes the rail and clamps to the interval', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel().minExtendedWidth, closeTo(306, 0.01));

      // Drag far left: many small moves accumulate and clamp to the minimum.
      var gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      for (var i = 0; i < 60; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, 180.0);

      // Drag far right: clamps to the maximum width.
      gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      for (var i = 0; i < 60; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, 360.0);
    });

    testWidgets('manual width above auto hands off along the interval', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.drag(
        find.byKey(const ValueKey('rail-resize-handle')),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();
      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel().minExtendedWidth, 360.0);

      // Shrink into expanded: 900 -> upper bound 234, so the manual 360
      // follows the interval's upper bound down (no jump, never rewritten).
      tester.view.physicalSize = const Size(900, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(234, 0.01));

      // Grow back: the remembered manual value applies again.
      tester.view.physicalSize = const Size(1800, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, 360.0);
    });

    testWidgets('manual width below auto follows auto after the handoff', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Drag slightly narrower than the auto width (306) -> 276.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      for (var i = 0; i < 3; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel().minExtendedWidth, closeTo(276, 0.01));

      // 1400: auto 280.8 > manual -> manual holds.
      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(276, 0.01));

      // 1300: auto 268.2 < manual -> follows the auto value down.
      tester.view.physicalSize = const Size(1300, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(268.2, 0.01));

      // 1150: auto 249.3 -> keeps following the auto value.
      tester.view.physicalSize = const Size(1150, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(249.3, 0.01));

      // Grow back: the remembered manual value resumes.
      tester.view.physicalSize = const Size(1800, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(276, 0.01));
    });

    testWidgets('drag while the panel animation is running does not crash', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1200, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Resize to extra-large: the panel starts animating.
      tester.view.physicalSize = const Size(1800, 800);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Drag while the animation is still running. A zero-duration restart
      // would synchronously re-dirty RenderAnimatedSize inside its own
      // performLayout and crash.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('collapsed rail hides the resize handle', (tester) async {
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byKey(const ValueKey('rail-resize-handle')), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rail-resize-handle')), findsOneWidget);
    });

    testWidgets('apple platforms keep three tiers without a drawer', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Apple medium maps to the collapsible rail, collapsed by default.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );

      tester.view.physicalSize = const Size(1300, 800);
      await tester.pumpAndSettle();

      // Apple large maps to the collapsible rail, extended by default; no
      // drawer tier exists on Apple platforms.
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byIcon(Icons.menu_open), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('switches forms when crossing the compact/medium boundary', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      tester.view.physicalSize = const Size(700, 600);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('habits page'), findsOneWidget);
      final mediumScope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(mediumScope.barHeight, 0);
      expect(mediumScope.visible.value, isTrue);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      final compactScope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(compactScope.barHeight, 80.0);
    });

    testWidgets('resets rail extension to the form default on form changes', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1000, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail rail() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      // The expanded form defaults to an extended rail.
      expect(rail().extended, isTrue);

      // Collapse manually, then shrink into medium: the medium default
      // (collapsed) applies.
      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(rail().extended, isFalse);
      tester.view.physicalSize = const Size(700, 600);
      await tester.pumpAndSettle();
      expect(rail().extended, isFalse);

      // Grow back into expanded: the expanded default (extended) applies
      // again, overriding the manual collapse.
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      expect(rail().extended, isTrue);
    });

    testWidgets('keeps the manual rail width across a compact round-trip', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Drag slightly narrower than the auto width (306) -> 276.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      for (var i = 0; i < 3; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      // Cross into compact: the bottom bar replaces the rail.
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Grow back: the remembered manual width resumes.
      tester.view.physicalSize = const Size(1800, 800);
      await tester.pumpAndSettle();
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.minExtendedWidth, closeTo(276, 0.01));
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
