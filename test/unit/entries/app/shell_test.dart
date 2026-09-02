import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/entries/app/navigation_chrome.dart';
import 'package:mhabit/entries/app/shell.dart';
import 'package:mhabit/models/app_entry.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/pages/habits_display/navigation_chrome.dart';
import 'package:mhabit/providers/app_ui/app_launch_entry.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/routes/navigator_helpers.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

class _RecordingLaunchEntryViewModel extends AppLaunchEntryViewModel {
  final List<AppEntrys> entries = [];

  @override
  Future<void> setNewLaunchEntry(AppEntrys newLaunchEntry) async {
    entries.add(newLaunchEntry);
  }
}

class _BlockingPopViewModel extends ChangeNotifier implements PopScopeHandler {
  @override
  bool get canPop => false;
}

class _MutableNavigationCoordinator extends AppNavigationCoordinator {
  _MutableNavigationCoordinator({required super.initialIndex})
    : _selectedIndex = initialIndex,
      super(
        branchObservers: const [],
        appFlowObserver: AdaptiveBranchRouteObserver(),
        appChromeNavigatorKey: GlobalKey<NavigatorState>(),
      );

  int _selectedIndex;

  @override
  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
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

class _PrimaryActionStubPage extends StatelessWidget {
  const _PrimaryActionStubPage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('habits action page')));
}

class _NavigatingPrimaryActionStubPage extends StatefulWidget {
  const _NavigatingPrimaryActionStubPage();

  @override
  State<_NavigatingPrimaryActionStubPage> createState() =>
      _NavigatingPrimaryActionStubPageState();
}

class _NavigatingPrimaryActionStubPageState
    extends State<_NavigatingPrimaryActionStubPage> {
  HabitDisplayNavigationChrome? _navigationChrome;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navigationChrome = context.read<HabitDisplayNavigationChrome>();
    if (identical(_navigationChrome, navigationChrome)) return;
    _navigationChrome?.unregisterPrimaryAction(_handlePressed);
    _navigationChrome = navigationChrome..registerPrimaryAction(_handlePressed);
  }

  @override
  void dispose() {
    _navigationChrome?.unregisterPrimaryAction(_handlePressed);
    super.dispose();
  }

  void _handlePressed() {
    unawaited(naviToHabitCreatePage(context: context));
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('habits action page')));
}

GoRouter _buildRouter(
  List<AdaptiveBranchRouteObserver> observers, {
  Widget habitsPage = const _StubPage('habits page'),
}) {
  final branches = [
    BranchRouterBuilder()
      ..addHabits(builder: (_, _) => habitsPage)
      ..addHabitDetail(builder: (_, _) => const _StubPage('detail page')),
    BranchRouterBuilder()
      ..addToday(builder: (_, _) => const _StubPage('today page')),
  ];
  final appFlow = AppFlowRouterBuilder()
    ..addHabitCreate(builder: (_, _) => const _StubPage('create page'))
    ..addHabitEdit(
      builder: (_, state) => state.uri.queryParameters['block'] == 'true'
          ? const PopScope<void>(canPop: false, child: _StubPage('edit page'))
          : const _StubPage('edit page'),
    )
    ..addHabitsStatus(builder: (_, _) => const _StubPage('status page'));
  final appFlowObserver = AdaptiveBranchRouteObserver();
  final appChromeNavigatorKey = GlobalKey<NavigatorState>();
  final coordinator = AppNavigationCoordinator(
    branchObservers: observers,
    appFlowObserver: appFlowObserver,
    appChromeNavigatorKey: appChromeNavigatorKey,
    initialIndex: 0,
  );
  final chromeController = AppNavigationChromeController();
  final habitChrome = HabitDisplayNavigationChrome(
    registerPrimaryAction: (action) => chromeController.registerPrimaryAction(
      AppNavigationBranch.habits,
      action,
    ),
    unregisterPrimaryAction: (action) => chromeController
        .unregisterPrimaryAction(AppNavigationBranch.habits, action),
    setContextualChromeSuppressed: (suppressed) => chromeController
        .setContextualChromeSuppressed(AppNavigationBranch.habits, suppressed),
  );
  addTearDown(coordinator.dispose);
  addTearDown(chromeController.dispose);
  final routerBuilder = AppRouterBuilder()
    ..addSettings(builder: (_, _) => const _StubPage('settings page'))
    ..addShellRoute(
      branches: branches,
      appFlow: appFlow,
      branchObservers: observers,
      observers: [appFlowObserver],
      navigatorKey: appChromeNavigatorKey,
      builder: (context, state, child) => MultiProvider(
        providers: [
          Provider<HabitDisplayNavigationChrome>.value(value: habitChrome),
        ],
        child: AppNavigationShell(
          coordinator: coordinator,
          chromeController: chromeController,
          child: child,
        ),
      ),
      branchBuilder: (context, state, navigationShell) {
        coordinator.attachTabShell(navigationShell);
        return navigationShell;
      },
    );
  return routerBuilder.build(home: AppRoute.habits);
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
  TargetPlatform platform = TargetPlatform.android,
}) {
  return tester.pumpWidget(
    ChangeNotifierProvider<AppLaunchEntryViewModel>.value(
      value: launchEntry,
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          platform: platform,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android:
                  CustomPredictiveBackPageTransitionsBuilder(),
            },
          ),
        ),
      ),
    ),
  );
}

Future<void> _commitPredictiveBack(WidgetTester tester) async {
  for (final call in [
    const MethodCall('startBackGesture', <String, dynamic>{
      'touchOffset': <double>[5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    }),
    const MethodCall('commitBackGesture'),
  ]) {
    final message = const StandardMethodCodec().encodeMethodCall(call);
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/backgesture',
      message,
      (data) {},
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('moves its listener when the coordinator instance changes', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final firstCoordinator = _MutableNavigationCoordinator(initialIndex: 0);
    final secondCoordinator = _MutableNavigationCoordinator(initialIndex: 0);
    final chromeController = AppNavigationChromeController();
    final launchEntry = _RecordingLaunchEntryViewModel();
    addTearDown(firstCoordinator.dispose);
    addTearDown(secondCoordinator.dispose);
    addTearDown(chromeController.dispose);
    addTearDown(launchEntry.dispose);

    Widget buildApp(AppNavigationCoordinator coordinator) =>
        ChangeNotifierProvider<AppLaunchEntryViewModel>.value(
          value: launchEntry,
          child: MaterialApp(
            home: AppNavigationShell(
              coordinator: coordinator,
              chromeController: chromeController,
              child: const _StubPage('content'),
            ),
          ),
        );

    await tester.pumpWidget(buildApp(firstCoordinator));
    firstCoordinator.selectIndex(1);
    await tester.pump();
    expect(launchEntry.entries, [AppEntrys.habitToday]);

    await tester.pumpWidget(buildApp(secondCoordinator));
    expect(
      tester
          .widget<AdaptiveNavigationShell>(find.byType(AdaptiveNavigationShell))
          .selectedIndex,
      0,
    );

    firstCoordinator.selectIndex(0);
    await tester.pump();
    expect(
      tester
          .widget<AdaptiveNavigationShell>(find.byType(AdaptiveNavigationShell))
          .selectedIndex,
      0,
    );

    secondCoordinator.selectIndex(1);
    await tester.pump();

    expect(
      tester
          .widget<AdaptiveNavigationShell>(find.byType(AdaptiveNavigationShell))
          .selectedIndex,
      1,
    );
    expect(launchEntry.entries, [AppEntrys.habitToday, AppEntrys.habitToday]);
  });

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

  testWidgets('uses Apple destination icons and switches branch', (
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
    await _pumpApp(
      tester,
      router: router,
      launchEntry: launchEntry,
      platform: TargetPlatform.iOS,
    );

    expect(
      find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
      findsOneWidget,
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('cupertino-navigation-surface')),
      ),
      const Size(220, 50),
    );
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(CupertinoIcons.today));
    await tester.pumpAndSettle();

    expect(find.text('today page'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.today_fill), findsOneWidget);
    expect(launchEntry.entries, [AppEntrys.habitToday]);
  });

  testWidgets('restores an Apple primary action after a branch round trip', (
    tester,
  ) async {
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(
      observers,
      habitsPage: const _PrimaryActionStubPage(),
    );
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
      platform: TargetPlatform.iOS,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-navigation-destination-1')),
    );
    await tester.pumpAndSettle();
    expect(
      TickerMode.valuesOf(
        tester.element(find.text('habits action page', skipOffstage: false)),
      ).enabled,
      isFalse,
    );
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-navigation-destination-0')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-navigation-destination-1')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-primary-action-surface')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('entering settings keeps the Apple primary-action Hero unique', (
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
      platform: TargetPlatform.iOS,
    );
    await tester.pumpAndSettle();

    router.push('/settings');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('settings page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restores the medium Apple action after app flow pop', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 800));
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    final router = _buildRouter(
      observers,
      habitsPage: const _NavigatingPrimaryActionStubPage(),
    );
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
      platform: TargetPlatform.iOS,
    );
    await tester.pumpAndSettle();

    final action = find.byKey(
      const ValueKey('cupertino-primary-action-surface'),
    );
    expect(action, findsOneWidget);

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('create page'), findsOneWidget);

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(action, findsOneWidget);
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
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final frameworkHandlesBack = <bool>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
          frameworkHandlesBack.add(call.arguments as bool);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/lifecycle',
      const StringCodec().encodeMessage(AppLifecycleState.resumed.toString()),
      (data) {},
    );
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
      builder: (context) => const AlertDialog(title: Text('dialog')),
    );
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsOneWidget);
    expect(observers[0].routeNameStack, [
      AppRoute.habits.name,
      AppRoute.habitDetail.name,
    ]);
    expect(AdaptiveNavScope.of(detailContext).visible.value, isFalse);

    await _commitPredictiveBack(tester);

    expect(find.text('dialog'), findsNothing);
    expect(find.text('detail page'), findsOneWidget);
    expect(frameworkHandlesBack.last, isTrue);
    expect(observers[0].routeNameStack, [
      AppRoute.habits.name,
      AppRoute.habitDetail.name,
    ]);
    expect(
      AdaptiveNavScope.of(
        tester.element(find.text('detail page')),
      ).visible.value,
      isFalse,
    );

    await Navigator.maybePop(tester.element(find.text('detail page')));
    await tester.pumpAndSettle();

    expect(find.text('detail page'), findsNothing);
    expect(find.text('habits page'), findsOneWidget);
    expect(observers[0].routeNameStack, ['habits']);
    debugDefaultTargetPlatformOverride = null;
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

  testWidgets('restores branch PopScope handling after a root dialog', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final frameworkHandlesBack = <bool>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
          frameworkHandlesBack.add(call.arguments as bool);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/lifecycle',
      const StringCodec().encodeMessage(AppLifecycleState.resumed.toString()),
      (data) {},
    );
    _setCompactSurface(tester);
    final observers = [
      AdaptiveBranchRouteObserver(),
      AdaptiveBranchRouteObserver(),
    ];
    var blockedPops = 0;
    final popViewModel = _BlockingPopViewModel();
    addTearDown(popViewModel.dispose);
    final router = _buildRouter(
      observers,
      habitsPage: ChangeNotifierProvider<_BlockingPopViewModel>.value(
        value: popViewModel,
        child: PopScopeConsumer<_BlockingPopViewModel>(
          onCannotPop: (context, vm, result) => blockedPops++,
          child: const _StubPage('search page'),
        ),
      ),
    );
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      router: router,
      launchEntry: _RecordingLaunchEntryViewModel(),
    );
    showDialog<void>(
      context: tester.element(find.text('search page')),
      builder: (context) => const AlertDialog(title: Text('dialog')),
    );
    await tester.pumpAndSettle();

    await _commitPredictiveBack(tester);

    expect(find.text('dialog'), findsNothing);
    expect(find.text('search page'), findsOneWidget);
    expect(frameworkHandlesBack.last, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(blockedPops, 1);
    expect(find.text('search page'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
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
    expect(observers[0].routeNameStack, [
      AppRoute.habits.name,
      AppRoute.habitDetail.name,
    ]);
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
    expect(observers[0].routeNameStack, [
      AppRoute.habits.name,
      AppRoute.habitDetail.name,
    ]);
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

  testWidgets('returns from status changer to the source habits stack', (
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

    router.push('/habits/status');
    await tester.pumpAndSettle();
    expect(find.text('status page'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('habits page'), findsOneWidget);
    expect(observers[0].routeNameStack, [AppRoute.habits.name]);
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

  testWidgets('rail selection closes status changer before switching branch', (
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

    router.push('/habits/status');
    await tester.pumpAndSettle();
    expect(find.text('status page'), findsOneWidget);

    await tester.tap(find.byIcon(MdiIcons.calendarTodayOutline));
    await tester.pumpAndSettle();

    expect(find.text('status page'), findsNothing);
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
