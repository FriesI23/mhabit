import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoButtonSize,
        CupertinoColors,
        CupertinoIcons,
        CupertinoNavigationBar,
        CupertinoPageScaffoldBackgroundColor,
        CupertinoSliverNavigationBar,
        CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_primary_action.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_scroll_wish_policy.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_shell_frame.dart';
import 'package:mhabit_adaptive_ui/src/shell/side_navigation.dart';

_TestRouter _buildRouter({
  List<AdaptiveNavigationDestination>? destinations,
  ValueChanged<int>? onBranchChanged,
  List<AdaptiveBranchRouteObserver>? observers,
  bool Function(List<String?> routeNames)? barVisibilityPolicy,
}) {
  return _TestRouter(
    destinations:
        destinations ??
        const [
          AdaptiveNavigationDestination(
            label: 'Habits',
            icons: NavigationDestinationIcons(
              material: Icon(Icons.home_outlined),
              materialSelected: Icon(Icons.home),
              apple: Icon(Icons.home_outlined),
              appleSelected: Icon(Icons.home),
            ),
          ),
          AdaptiveNavigationDestination(
            label: 'Today',
            icons: NavigationDestinationIcons(
              material: Icon(Icons.calendar_today_outlined),
              materialSelected: Icon(Icons.calendar_today),
              apple: Icon(Icons.calendar_today_outlined),
              appleSelected: Icon(Icons.calendar_today),
            ),
          ),
        ],
    onBranchChanged: onBranchChanged,
    observers: observers ?? const [],
    barVisibilityPolicy: barVisibilityPolicy,
  );
}

class _TestRouter extends RouterConfig<Object> {
  factory _TestRouter({
    required List<AdaptiveNavigationDestination> destinations,
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

  void setContextualChromeSuppressed(bool suppressed) =>
      delegate.setContextualChromeSuppressed(suppressed);
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

  final List<AdaptiveNavigationDestination> destinations;
  final List<AdaptiveBranchRouteObserver> observers;
  final ValueChanged<int>? onBranchChanged;
  final bool Function(List<String?> routeNames)? barVisibilityPolicy;

  final List<List<_TestRouteEntry>> _branchStacks = [[], []];
  int _selectedIndex = 0;
  bool _contextualChromeSuppressed = false;

  void setContextualChromeSuppressed(bool suppressed) {
    if (_contextualChromeSuppressed == suppressed) return;
    _contextualChromeSuppressed = suppressed;
    notifyListeners();
  }

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
            contextualChromeSuppressed: _contextualChromeSuppressed,
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
      body: CustomScrollView(
        slivers: [
          const AdaptiveSliverAppBar(
            title: Text('Test page'),
            leading: Icon(
              Icons.article_outlined,
              key: ValueKey('test-page-leading'),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
          ),
        ],
      ),
    );
  }
}

class _BranchInsetsProbe extends StatelessWidget {
  const _BranchInsetsProbe();

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Column(
      key: const ValueKey('branch-layout-probe'),
      children: [
        SizedBox(
          key: const ValueKey('branch-horizontal-padding'),
          width: padding.left + padding.right,
        ),
        SizedBox(
          key: const ValueKey('branch-vertical-padding'),
          height: padding.top + padding.bottom,
        ),
        SizedBox(
          key: const ValueKey('branch-horizontal-view-padding'),
          width: viewPadding.left + viewPadding.right,
        ),
        SizedBox(
          key: const ValueKey('branch-vertical-view-padding'),
          height: viewPadding.top + viewPadding.bottom,
        ),
        SizedBox(
          key: const ValueKey('branch-view-insets'),
          width: viewInsets.left + viewInsets.right,
          height: viewInsets.top + viewInsets.bottom,
        ),
      ],
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

class _BranchContractHarness extends StatefulWidget {
  const _BranchContractHarness({this.itemCount = 40});

  final int itemCount;

  @override
  State<_BranchContractHarness> createState() => _BranchContractHarnessState();
}

class _BranchContractHarnessState extends State<_BranchContractHarness> {
  int _selectedIndex = 0;
  bool _routeVisible = true;
  late final CupertinoNavigationPrimaryAction _habitsAction =
      CupertinoNavigationPrimaryAction(
        id: 'test-habits-action',
        label: 'New Habit',
        icon: const Icon(Icons.add),
        onPressed: () {},
      );

  @override
  Widget build(BuildContext context) => AdaptiveNavigationShell(
    selectedIndex: _selectedIndex,
    compactRouteVisible: _routeVisible,
    applePrimaryAction: _selectedIndex == 0 ? _habitsAction : null,
    destinations: const [
      AdaptiveNavigationDestination(
        label: 'Habits',
        icons: NavigationDestinationIcons(
          material: Icon(Icons.home_outlined),
          materialSelected: Icon(Icons.home),
          apple: Icon(Icons.home_outlined),
          appleSelected: Icon(Icons.home),
        ),
      ),
      AdaptiveNavigationDestination(
        label: 'Today',
        icons: NavigationDestinationIcons(
          material: Icon(Icons.calendar_today_outlined),
          materialSelected: Icon(Icons.calendar_today),
          apple: Icon(Icons.calendar_today_outlined),
          appleSelected: Icon(Icons.calendar_today),
        ),
      ),
    ],
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    child: IndexedStack(
      index: _selectedIndex,
      children: [
        for (final index in [0, 1])
          Offstage(
            offstage: index != _selectedIndex,
            child: TickerMode(
              enabled: index == _selectedIndex,
              child: Scaffold(
                body: CustomScrollView(
                  key: ValueKey(index == 0 ? 'habits-scroll' : 'today-scroll'),
                  slivers: [
                    SliverList.builder(
                      itemCount: widget.itemCount,
                      itemBuilder: (context, itemIndex) => SizedBox(
                        height: 56,
                        child: Text('branch $index item $itemIndex'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  void setRouteVisible(bool visible) {
    setState(() => _routeVisible = visible);
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

const MethodChannel _windowControlChannel = MethodChannel(
  'ios_window_control_layout',
);

Map<String, double> _windowInsets({
  double start = 0,
  double top = 0,
  double end = 0,
  double bottom = 0,
}) => <String, double>{
  'start': start,
  'top': top,
  'end': end,
  'bottom': bottom,
};

Map<String, double> _windowCornerRadii({
  double topLeft = 0,
  double topRight = 0,
  double bottomLeft = 0,
  double bottomRight = 0,
}) => <String, double>{
  'topLeft': topLeft,
  'topRight': topRight,
  'bottomLeft': bottomLeft,
  'bottomRight': bottomRight,
};

void _mockWindowControlLayout() {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_windowControlChannel, (call) async {
        return <String, Object>{
          'schemaVersion': 3,
          'isAvailable': true,
          'baseMargins': _windowInsets(),
          'horizontalMargins': _windowInsets(start: 40, end: 12),
          'verticalMargins': _windowInsets(top: 64),
          'baseSafeArea': _windowInsets(bottom: 34),
          'horizontalSafeArea': _windowInsets(start: 24, end: 18, bottom: 34),
          'verticalSafeArea': _windowInsets(bottom: 34),
          'effectiveCornerRadii': _windowCornerRadii(
            topLeft: 62,
            topRight: 62,
            bottomLeft: 62,
            bottomRight: 62,
          ),
        };
      });
}

void _resetWindowControlLayoutMock() {
  debugDefaultTargetPlatformOverride = null;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_windowControlChannel, null);
}

void main() {
  group('SideNavigationExtent', () {
    test('fixed target clamps to the available interval', () {
      const extent = SideNavigationExtent(224);

      expect(extent.resolve(1600), 224);
      expect(extent.resolve(800), 216);
    });

    test('ratio resolves between the available bounds', () {
      const extent = SideNavigationExtent.fromRatio(0.5);

      expect(extent.resolve(1600), 270);
      expect(extent.resolve(800), 198);
    });

    test('owns interval growth and manual clamping', () {
      const extent = SideNavigationExtent(
        240,
        minimum: 200,
        maximum: 320,
        rampStart: 800,
        rampEnd: 1400,
      );

      expect(extent.upperBoundAt(1100), 260);
      expect(extent.resolve(1100), 240);
      expect(extent.clamp(300, windowWidth: 1100), 260);
    });

    test('requires a valid full-width interval', () {
      expect(
        () => SideNavigationExtent(100, minimum: 200, maximum: 100),
        throwsAssertionError,
      );
    });

    test('material rail style owns its collapsed extent', () {
      const style = MaterialNavigationRailStyle(collapsedExtent: 64);
      const defaults = MaterialNavigationRailStyle();

      expect(style.collapsedExtent, 64);
      expect(defaults.collapsedExtent, 96);
      expect(
        () => MaterialNavigationRailStyle(collapsedExtent: 0),
        throwsAssertionError,
      );
    });
  });

  group('SideNavigationResizeState', () {
    const extent = SideNavigationExtent(224);

    test('clamps and hands a wider manual width to the available interval', () {
      final state = SideNavigationResizeState();

      expect(state.effectiveWidth(extent, windowWidth: 1800), 224);
      state.startDrag(extent, windowWidth: 1800);
      expect(state.dragging, isTrue);
      state.updateDrag(500, extent, windowWidth: 1800);
      state.endDrag();

      expect(state.dragging, isFalse);
      expect(state.effectiveWidth(extent, windowWidth: 1800), 360);
      expect(state.effectiveWidth(extent, windowWidth: 900), 234);
      expect(state.effectiveWidth(extent, windowWidth: 1800), 360);
    });

    test('hands a narrower manual width to auto and restores it later', () {
      final state = SideNavigationResizeState();

      state.startDrag(extent, windowWidth: 1800);
      state.updateDrag(-5, extent, windowWidth: 1800);
      state.endDrag();

      expect(state.effectiveWidth(extent, windowWidth: 1400), 219);
      expect(state.effectiveWidth(extent, windowWidth: 700), 198);
      expect(state.effectiveWidth(extent, windowWidth: 1800), 219);
    });

    testWidgets('handle clears dragged state when a gesture is cancelled', (
      tester,
    ) async {
      final observedStates = <Set<WidgetState>>[];
      final logicalDeltas = <double>[];
      var starts = 0;
      var ends = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SizedBox(
              height: 100,
              child: SideNavigationResizeHandle(
                hitExtent: 16,
                dragHandleBuilder: (context, states) {
                  observedStates.add(Set<WidgetState>.of(states));
                  return const SizedBox.shrink();
                },
                onResizeStart: () => starts += 1,
                onResizeUpdate: logicalDeltas.add,
                onResizeEnd: () => ends += 1,
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SideNavigationResizeHandle)),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
      expect(starts, 1);
      expect(logicalDeltas, isNotEmpty);
      expect(logicalDeltas, everyElement(greaterThan(0)));
      expect(
        observedStates.any((states) => states.contains(WidgetState.dragged)),
        isTrue,
      );

      await gesture.cancel();
      await tester.pump();
      expect(ends, 1);
      expect(observedStates.last.contains(WidgetState.dragged), isFalse);
    });
  });

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
    testWidgets(
      'frame delegates body composition with restored ambient geometry',
      (tester) async {
        tester.view.padding = const FakeViewPadding(left: 44, right: 20);
        tester.view.viewPadding = const FakeViewPadding(left: 50, right: 30);
        _setSurfaceSize(tester, const Size(700, 800));
        final selected = <int>[];

        await tester.pumpWidget(
          MaterialApp(
            home: NavigationShellFrame(
              selectedIndex: 0,
              onDestinationSelected: selected.add,
              compactRouteVisible: true,
              contextualChromeSuppressed: false,
              barHeight: 80,
              navHeight: 80,
              keepVisibleOnScroll: false,
              scrollWishPolicy: const NavigationScrollWishPolicy.directional(),
              formResolver: (_) => NavigationShellForm.constrainedSide,
              bodyBuilder: (context, form, onSelected, child) {
                final padding = MediaQuery.paddingOf(context);
                final viewPadding = MediaQuery.viewPaddingOf(context);
                final owner = AdaptiveWindowControlLayoutScope.maybeOf(
                  context,
                )!.owner;
                return Stack(
                  key: const ValueKey('custom-shell-body'),
                  children: [
                    child,
                    SizedBox(
                      key: const ValueKey('custom-shell-geometry'),
                      width: padding.left + padding.right,
                      height: viewPadding.left + viewPadding.right,
                    ),
                    TextButton(
                      key: const ValueKey('custom-shell-destination'),
                      onPressed: () => onSelected(1),
                      child: Text('${form.name}:${owner.name}'),
                    ),
                  ],
                );
              },
              windowControlOwnerResolver: (_) =>
                  WindowControlLayoutOwner.sideNavigation,
              compactNavigationBuilder: (_, _) => const SizedBox.shrink(),
              child: const Text('branch'),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byKey(const ValueKey('custom-shell-body')),
            matching: find.byType(Row),
          ),
          findsNothing,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('custom-shell-geometry'))),
          const Size(64, 80),
        );
        expect(find.text('constrainedSide:sideNavigation'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('custom-shell-destination')),
        );
        expect(selected, [1]);
      },
    );

    testWidgets('style switching preserves branch content state', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final style = ValueNotifier(AdaptiveStyle.material);
      addTearDown(style.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<AdaptiveStyle>(
            valueListenable: style,
            builder: (context, value, child) => AdaptiveStyleScope(
              override: value,
              child: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home_outlined),
                      materialSelected: Icon(Icons.home),
                      apple: Icon(Icons.home_outlined),
                      appleSelected: Icon(Icons.home),
                    ),
                  ),
                  AdaptiveNavigationDestination(
                    label: 'Today',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.today_outlined),
                      materialSelected: Icon(Icons.today),
                      apple: Icon(Icons.today_outlined),
                      appleSelected: Icon(Icons.today),
                    ),
                  ),
                ],
                onDestinationSelected: (_) {},
                child: const _StatefulBranchProbe(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('branch count 0'));
      await tester.pump();
      expect(find.text('branch count 1'), findsOneWidget);
      final branchState = tester.state<_StatefulBranchProbeState>(
        find.byType(_StatefulBranchProbe),
      );

      style.value = AdaptiveStyle.apple;
      await tester.pumpAndSettle();

      expect(find.text('branch count 1'), findsOneWidget);
      expect(
        tester.state<_StatefulBranchProbeState>(
          find.byType(_StatefulBranchProbe),
        ),
        same(branchState),
      );
      expect(
        find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        findsOneWidget,
      );

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpAndSettle();
      expect(find.text('branch count 1'), findsOneWidget);
      expect(
        tester.state<_StatefulBranchProbeState>(
          find.byType(_StatefulBranchProbe),
        ),
        same(branchState),
      );

      tester.view.physicalSize = const Size(1000, 479);
      await tester.pumpAndSettle();
      expect(find.text('branch count 1'), findsOneWidget);
      expect(
        tester.state<_StatefulBranchProbeState>(
          find.byType(_StatefulBranchProbe),
        ),
        same(branchState),
      );
    });

    testWidgets('apple shell keeps the shared transparent app bar surface', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      const scaffoldBackground = Color(0xFF000000);
      const barBackground = Color(0xCC303036);
      Color? scopedBackground;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            platform: TargetPlatform.iOS,
            brightness: Brightness.dark,
            cupertinoOverrideTheme: const CupertinoThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: scaffoldBackground,
              barBackgroundColor: barBackground,
            ),
          ),
          home: AdaptiveNavigationShell(
            selectedIndex: 0,
            destinations: const [
              AdaptiveNavigationDestination(
                label: 'Habits',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.home_outlined),
                  materialSelected: Icon(Icons.home),
                  apple: Icon(Icons.home_outlined),
                  appleSelected: Icon(Icons.home),
                ),
              ),
              AdaptiveNavigationDestination(
                label: 'Today',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.today_outlined),
                  materialSelected: Icon(Icons.today),
                  apple: Icon(Icons.today_outlined),
                  appleSelected: Icon(Icons.today),
                ),
              ),
            ],
            onDestinationSelected: (_) {},
            child: Builder(
              builder: (context) {
                scopedBackground = CupertinoPageScaffoldBackgroundColor.maybeOf(
                  context,
                );
                return const CustomScrollView(
                  slivers: [
                    AdaptiveSliverAppBar.apple(title: Text('Habits')),
                    SliverToBoxAdapter(child: SizedBox(height: 1600)),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Color renderedAppBarBackground() {
        final decorations = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(CupertinoSliverNavigationBar),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .where((decoration) => decoration.color != null);
        expect(decorations, hasLength(1));
        return decorations.single.color!;
      }

      expect(scopedBackground, scaffoldBackground);
      expect(renderedAppBarBackground(), CupertinoColors.transparent);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(renderedAppBarBackground(), CupertinoColors.transparent);
    });

    testWidgets('material shell does not host the Cupertino primary action', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationPrimaryActionButton), findsNothing);
      expect(
        find.byKey(const ValueKey('cupertino-primary-action-surface')),
        findsNothing,
      );
    });

    testWidgets('animates and restores the branch primary action', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(CupertinoNavigationPrimaryActionButton),
        findsOneWidget,
      );
      final navigationSurface = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final primaryActionSurface = find.byKey(
        const ValueKey('cupertino-primary-action-surface'),
      );
      expect(
        tester.getTopLeft(primaryActionSurface).dy,
        tester.getTopLeft(navigationSurface).dy,
      );
      expect(
        tester.getBottomLeft(primaryActionSurface).dy,
        tester.getBottomLeft(navigationSurface).dy,
      );
      final navigationClip = find.descendant(
        of: find.byKey(const ValueKey('bottom-bar')),
        matching: find.byWidgetPredicate(
          (widget) => widget is ClipRect && widget.clipper != null,
        ),
      );
      expect(navigationClip, findsOneWidget);
      final clipWidget = tester.widget<ClipRect>(navigationClip);
      expect(clipWidget.clipper, isNotNull);
      expect(
        clipWidget.clipper!.getClip(tester.getSize(navigationClip)).top,
        -CupertinoFloatingGlassSurface.shadowClipOverflow,
      );

      await tester.tap(
        find.byKey(const ValueKey('cupertino-navigation-destination-1')),
      );
      await tester.pump();
      expect(
        find.byType(CupertinoNavigationPrimaryActionButton),
        findsOneWidget,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      final outgoingFade = tester.widget<FadeTransition>(
        find.ancestor(
          of: find.byType(CupertinoNavigationPrimaryActionButton),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(outgoingFade.opacity.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoNavigationPrimaryActionButton), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('cupertino-navigation-destination-0')),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(CupertinoNavigationPrimaryActionButton),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 125));
      final incomingFade = tester.widget<FadeTransition>(
        find.ancestor(
          of: find.byType(CupertinoNavigationPrimaryActionButton),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(incomingFade.opacity.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(
        find.byType(CupertinoNavigationPrimaryActionButton),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('cupertino-navigation-destination-1')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoNavigationPrimaryActionButton), findsNothing);
    });

    testWidgets(
      'aligns compact primary action with capped bottom fallback margin',
      (tester) async {
        tester.view.padding = const FakeViewPadding(bottom: 40);
        tester.view.viewPadding = const FakeViewPadding(bottom: 40);
        _setSurfaceSize(tester, const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const _BranchContractHarness(),
          ),
        );
        await tester.pumpAndSettle();

        final navigationSurface = find.byKey(
          const ValueKey('cupertino-navigation-surface'),
        );
        final primaryActionSurface = find.byKey(
          const ValueKey('cupertino-primary-action-surface'),
        );
        expect(
          tester.getTopLeft(primaryActionSurface).dy,
          tester.getTopLeft(navigationSurface).dy,
        );
        expect(
          tester.getBottomLeft(primaryActionSurface).dy,
          tester.getBottomLeft(navigationSurface).dy,
        );
      },
    );

    testWidgets('rebuilding the default primary action keeps one Hero', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: StatefulBuilder(
            builder: (context, setState) => AdaptiveNavigationShell(
              selectedIndex: 0,
              applePrimaryAction: CupertinoNavigationPrimaryAction(
                label: 'New Habit',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.home_outlined),
                    materialSelected: Icon(Icons.home),
                    apple: Icon(Icons.home_outlined),
                    appleSelected: Icon(Icons.home),
                  ),
                ),
              ],
              onDestinationSelected: (_) {},
              child: Center(
                child: TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Rebuild'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rebuild'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Hero), findsOneWidget);
      expect(
        find.byType(CupertinoNavigationPrimaryActionButton),
        findsOneWidget,
      );
    });

    testWidgets('observes vertical scrolling from every active branch', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('cupertino-navigation-destination-1')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );

      await tester.fling(
        find.byKey(const ValueKey('today-scroll')),
        const Offset(0, -300),
        1200,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-navigation-minimized')),
        findsOneWidget,
      );

      await tester.fling(
        find.byKey(const ValueKey('today-scroll')),
        const Offset(0, 150),
        1200,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
    });

    testWidgets('keeps Apple navigation expanded without scroll extent', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(itemCount: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('habits-scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
    });

    testWidgets('keeps Apple navigation expanded during a slow drag', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const ValueKey('habits-scroll')),
        const Offset(0, -80),
        const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();

      final scrollable = Scrollable.of(
        tester.element(find.text('branch 0 item 1')),
      );
      expect(scrollable.position.pixels, greaterThan(0));
      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
    });

    testWidgets('minimizes Apple navigation during a fast direct drag', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      final scroll = find.byKey(const ValueKey('habits-scroll'));
      final gesture = await tester.startGesture(tester.getCenter(scroll));
      await gesture.moveBy(
        const Offset(0, -24),
        timeStamp: const Duration(milliseconds: 16),
      );
      await tester.pump();
      await gesture.moveBy(
        const Offset(0, -48),
        timeStamp: const Duration(milliseconds: 32),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cupertino-navigation-minimized')),
        findsOneWidget,
      );
      await gesture.up(timeStamp: const Duration(milliseconds: 48));
    });

    testWidgets('keeps Apple navigation minimized during a slow reverse drag', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      final item = find.text('branch 0 item 1');
      final scrollable = Scrollable.of(tester.element(item));
      scrollable.position.jumpTo(300);
      final scope = AdaptiveNavScope.of(tester.element(item));
      scope.reportScrollWish(false);
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const ValueKey('habits-scroll')),
        const Offset(0, 80),
        const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
      expect(
        find.byKey(const ValueKey('cupertino-navigation-minimized')),
        findsOneWidget,
      );
    });

    testWidgets('expands Apple navigation during a fast direct reverse drag', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      final item = find.text('branch 0 item 1');
      final scrollable = Scrollable.of(tester.element(item));
      scrollable.position.jumpTo(300);
      final scope = AdaptiveNavScope.of(tester.element(item));
      scope.reportScrollWish(false);
      await tester.pumpAndSettle();

      final scroll = find.byKey(const ValueKey('habits-scroll'));
      final gesture = await tester.startGesture(tester.getCenter(scroll));
      await gesture.moveBy(
        const Offset(0, 24),
        timeStamp: const Duration(milliseconds: 16),
      );
      await tester.pump();
      await gesture.moveBy(
        const Offset(0, 48),
        timeStamp: const Duration(milliseconds: 32),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
      await gesture.up(timeStamp: const Duration(milliseconds: 48));
    });

    testWidgets('keeps Material navigation direction-driven in both ways', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.timedDrag(
        find.byKey(const ValueKey('habits-scroll')),
        const Offset(0, -80),
        const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();

      final scope = AdaptiveNavScope.of(
        tester.element(find.text('branch 0 item 1')),
      );
      expect(scope.visible.value, isFalse);

      await tester.timedDrag(
        find.byKey(const ValueKey('habits-scroll')),
        const Offset(0, 20),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(scope.visible.value, isTrue);
    });

    testWidgets('animates the Apple action with route visibility', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const _BranchContractHarness(),
        ),
      );
      await tester.pumpAndSettle();

      final state = tester.state<_BranchContractHarnessState>(
        find.byType(_BranchContractHarness),
      );
      state.setRouteVisible(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));

      final outgoingAction = find.byType(
        CupertinoNavigationPrimaryActionButton,
      );
      expect(outgoingAction, findsOneWidget);
      final outgoingActionOpacityFinder = find.ancestor(
        of: outgoingAction,
        matching: find.byType(Opacity),
      );
      final outgoingBarOpacityFinder = find.ancestor(
        of: find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        matching: find.byType(Opacity),
      );
      expect(outgoingActionOpacityFinder, findsOneWidget);
      expect(outgoingBarOpacityFinder, findsOneWidget);
      final outgoingActionOpacity = tester.widget<Opacity>(
        outgoingActionOpacityFinder,
      );
      final outgoingBarOpacity = tester.widget<Opacity>(
        outgoingBarOpacityFinder,
      );
      expect(outgoingActionOpacity.opacity, inExclusiveRange(0, 1));
      expect(outgoingActionOpacity.opacity, outgoingBarOpacity.opacity);

      await tester.pumpAndSettle();
      expect(outgoingAction, findsOneWidget);
      expect(tester.widget<Opacity>(outgoingActionOpacityFinder).opacity, 0);

      state.setRouteVisible(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));

      final incomingAction = find.byType(
        CupertinoNavigationPrimaryActionButton,
      );
      expect(incomingAction, findsOneWidget);
      final incomingActionOpacityFinder = find.ancestor(
        of: incomingAction,
        matching: find.byType(Opacity),
      );
      final incomingBarOpacityFinder = find.ancestor(
        of: find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        matching: find.byType(Opacity),
      );
      expect(incomingActionOpacityFinder, findsOneWidget);
      expect(incomingBarOpacityFinder, findsOneWidget);
      final incomingActionOpacity = tester.widget<Opacity>(
        incomingActionOpacityFinder,
      );
      final incomingBarOpacity = tester.widget<Opacity>(
        incomingBarOpacityFinder,
      );
      expect(incomingActionOpacity.opacity, inExclusiveRange(0, 1));
      expect(incomingActionOpacity.opacity, incomingBarOpacity.opacity);

      await tester.pumpAndSettle();
      expect(incomingAction, findsOneWidget);
    });

    testWidgets(
      'medium route change starts the Apple action exit immediately',
      (tester) async {
        _setSurfaceSize(tester, const Size(700, 800));
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const _BranchContractHarness(),
          ),
        );
        await tester.pumpAndSettle();

        final state = tester.state<_BranchContractHarnessState>(
          find.byType(_BranchContractHarness),
        );
        state.setRouteVisible(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 125));

        final outgoingAction = find.byType(
          CupertinoNavigationPrimaryActionButton,
        );
        expect(outgoingAction, findsOneWidget);
        final fades = tester.widgetList<FadeTransition>(
          find.ancestor(
            of: outgoingAction,
            matching: find.byType(FadeTransition),
          ),
        );
        expect(
          fades.any(
            (transition) =>
                transition.opacity.value > 0 && transition.opacity.value < 1,
          ),
          isTrue,
        );

        await tester.pumpAndSettle();
        expect(outgoingAction, findsNothing);
      },
    );

    testWidgets('provides adaptive window control layout to branch content', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final context = tester.element(find.text('habits page'));
      final layout = AdaptiveWindowControlLayoutScope.maybeOf(context)!;
      expect(layout.horizontalAvoidance, EdgeInsetsDirectional.zero);
      expect(layout.verticalAvoidance, EdgeInsetsDirectional.zero);
      expect(layout.horizontalSafeAreaAvoidance, isNull);
      expect(layout.verticalSafeAreaAvoidance, isNull);
      expect(layout.effectiveCornerRadii, isNull);
      expect(layout.usesRectangularDisplay, isFalse);
      expect(layout.owner, WindowControlLayoutOwner.appBar);
    });

    testWidgets('preserves rectangular display geometry in the shell', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(
        AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: EdgeInsetsDirectional.zero,
          verticalAvoidance: EdgeInsetsDirectional.zero,
          usesRectangularDisplay: true,
          owner: WindowControlLayoutOwner.appBar,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      final context = tester.element(find.text('habits page'));
      final layout = AdaptiveWindowControlLayoutScope.maybeOf(context)!;
      expect(layout.usesRectangularDisplay, isTrue);
    });

    testWidgets('assigns avoidance to app bar or side navigation', (
      tester,
    ) async {
      _mockWindowControlLayout();
      try {
        _setSurfaceSize(tester, const Size(400, 800));
        final router = _buildRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        var context = tester.element(find.text('habits page'));
        var layout = AdaptiveWindowControlLayoutScope.maybeOf(context)!;
        expect(layout.owner, WindowControlLayoutOwner.appBar);
        expect(
          layout.appBarHorizontalAvoidance,
          const EdgeInsetsDirectional.only(start: 40, end: 12),
        );
        expect(
          layout.sideNavigationHorizontalAvoidance,
          EdgeInsetsDirectional.zero,
        );
        expect(
          layout.sideNavigationVerticalAvoidance,
          EdgeInsetsDirectional.zero,
        );
        expect(
          layout.horizontalSafeAreaAvoidance,
          const EdgeInsetsDirectional.fromSTEB(24, 0, 18, 0),
        );
        expect(layout.verticalSafeAreaAvoidance, EdgeInsetsDirectional.zero);
        expect(
          layout.effectiveCornerRadii,
          const BorderRadius.all(Radius.circular(62)),
        );

        tester.view.physicalSize = const Size(700, 800);
        await tester.pumpAndSettle();

        context = tester.element(find.text('habits page'));
        layout = AdaptiveWindowControlLayoutScope.maybeOf(context)!;
        expect(layout.owner, WindowControlLayoutOwner.sideNavigation);
        expect(layout.appBarHorizontalAvoidance, EdgeInsetsDirectional.zero);
        expect(
          layout.sideNavigationHorizontalAvoidance,
          const EdgeInsetsDirectional.only(start: 40, end: 12),
        );
        expect(
          layout.sideNavigationVerticalAvoidance,
          const EdgeInsetsDirectional.only(top: 64),
        );
        expect(
          layout.horizontalSafeAreaAvoidance,
          const EdgeInsetsDirectional.fromSTEB(24, 0, 18, 0),
        );
        expect(layout.verticalSafeAreaAvoidance, EdgeInsetsDirectional.zero);
        expect(
          layout.effectiveCornerRadii,
          const BorderRadius.all(Radius.circular(62)),
        );

        expect(
          tester
              .getTopLeft(
                find.byKey(
                  const ValueKey('cupertino-sidebar-destination-list'),
                ),
              )
              .dx,
          12,
        );

        final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
        expect(
          tester.getTopRight(toggle).dx,
          tester
                  .getTopRight(
                    find.byKey(const ValueKey('cupertino-sidebar-surface')),
                  )
                  .dx -
              12,
        );
        expect(tester.getTopLeft(toggle).dy, 12);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsNothing,
        );
        expect(tester.getTopLeft(toggle).dx, 56);
      } finally {
        _resetWindowControlLayoutMock();
      }
    });

    testWidgets('apple beside Sidebar uses the RTL side-navigation safe span', (
      tester,
    ) async {
      _mockWindowControlLayout();
      try {
        _setSurfaceSize(tester, const Size(1000, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home_outlined),
                      materialSelected: Icon(Icons.home_outlined),
                      apple: Icon(Icons.home_outlined),
                      appleSelected: Icon(Icons.home_outlined),
                    ),
                  ),
                ],
                onDestinationSelected: (_) {},
                child: const Text('content'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(
          tester
              .getTopRight(
                find.byKey(
                  const ValueKey('cupertino-sidebar-destination-list'),
                ),
              )
              .dx,
          988,
        );
      } finally {
        _resetWindowControlLayoutMock();
      }
    });

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

    testWidgets(
      'apple compact minimizes in a fixed envelope and tap only expands',
      (tester) async {
        tester.view.padding = const FakeViewPadding(bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(bottom: 34);
        _setSurfaceSize(tester, const Size(400, 800));
        final branchChanges = <int>[];
        final router = _buildRouter(onBranchChanged: branchChanges.add);
        await tester.pumpWidget(
          MaterialApp.router(
            theme: ThemeData(platform: TargetPlatform.iOS),
            routerConfig: router,
          ),
        );

        final scope = AdaptiveNavScope.of(
          tester.element(find.text('habits page')),
        );
        expect(scope.barHeight, 50);
        expect(scope.navHeight, 78);
        expect(
          tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
          78,
        );
        expect(
          find.byKey(const ValueKey('cupertino-navigation-expanded')),
          findsOneWidget,
        );

        scope.reportScrollWish(false);
        await tester.pumpAndSettle();

        expect(scope.visible.value, isTrue);
        expect(
          tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
          78,
        );
        expect(
          find.byKey(const ValueKey('cupertino-navigation-minimized')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        );
        await tester.pumpAndSettle();

        expect(scope.scrollWish.value, isTrue);
        expect(
          find.byKey(const ValueKey('cupertino-navigation-expanded')),
          findsOneWidget,
        );
        expect(branchChanges, isEmpty);
      },
    );

    testWidgets('apple branch switch resets minimized chrome to expanded', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final branchChanges = <int>[];
      final router = _buildRouter(onBranchChanged: branchChanges.add);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(platform: TargetPlatform.iOS),
          routerConfig: router,
        ),
      );

      var scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
      scope.reportScrollWish(false);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-navigation-minimized')),
        findsOneWidget,
      );

      router.go('/today');
      await tester.pumpAndSettle();

      scope = AdaptiveNavScope.of(tester.element(find.text('today page')));
      expect(scope.scrollWish.value, isTrue);
      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
      expect(branchChanges, [1]);
    });

    testWidgets('apple route hidden takes priority and pop restores expanded', (
      tester,
    ) async {
      final observers = [
        AdaptiveBranchRouteObserver(),
        AdaptiveBranchRouteObserver(),
      ];
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter(observers: observers);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(platform: TargetPlatform.iOS),
          routerConfig: router,
        ),
      );

      var scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
      scope.reportScrollWish(false);
      await tester.pumpAndSettle();

      router.push('/habits/detail');
      await tester.pumpAndSettle();

      scope = AdaptiveNavScope.of(tester.element(find.text('detail page')));
      expect(scope.visible.value, isFalse);
      expect(
        tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
        0,
      );

      router.pop();
      await tester.pumpAndSettle();

      scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
      expect(scope.visible.value, isTrue);
      expect(scope.scrollWish.value, isTrue);
      expect(
        find.byKey(const ValueKey('cupertino-navigation-expanded')),
        findsOneWidget,
      );
    });

    testWidgets(
      'apple contextual hidden restores the current minimized state',
      (tester) async {
        _setSurfaceSize(tester, const Size(400, 800));
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            theme: ThemeData(platform: TargetPlatform.iOS),
            routerConfig: router,
          ),
        );

        final scope = AdaptiveNavScope.of(
          tester.element(find.text('habits page')),
        );
        scope.reportScrollWish(false);
        await tester.pumpAndSettle();
        router.setContextualChromeSuppressed(true);
        await tester.pumpAndSettle();

        expect(scope.visible.value, isFalse);
        expect(
          tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
          0,
        );

        router.setContextualChromeSuppressed(false);
        await tester.pumpAndSettle();

        expect(scope.visible.value, isTrue);
        expect(scope.scrollWish.value, isFalse);
        expect(
          find.byKey(const ValueKey('cupertino-navigation-minimized')),
          findsOneWidget,
        );
      },
    );

    testWidgets('unrelated MediaQuery changes do not rebuild shell chrome', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
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
        tester.widget<NavigationBar>(find.byType(NavigationBar)),
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

    testWidgets('side form snackbar remains owned by the root scaffold', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byKey(const ValueKey('show-snackbar')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
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

    for (final textDirection in TextDirection.values) {
      testWidgets('rail owns the branch start inset in $textDirection', (
        tester,
      ) async {
        tester.view.padding = const FakeViewPadding(left: 44, right: 20);
        tester.view.viewPadding = const FakeViewPadding(left: 50, right: 30);
        _setSurfaceSize(tester, const Size(800, 400));

        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: textDirection,
              child: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home_outlined),
                      materialSelected: Icon(Icons.home),
                      apple: Icon(Icons.home_outlined),
                      appleSelected: Icon(Icons.home),
                    ),
                  ),
                ],
                onDestinationSelected: (_) {},
                child: const _BranchInsetsProbe(),
              ),
            ),
          ),
        );

        final expectedBranchInset = switch (textDirection) {
          TextDirection.ltr => 20.0,
          TextDirection.rtl => 44.0,
        };
        final expectedBranchViewInset = switch (textDirection) {
          TextDirection.ltr => 36.0,
          TextDirection.rtl => 60.0,
        };
        expect(
          tester
              .getSize(find.byKey(const ValueKey('branch-horizontal-padding')))
              .width,
          expectedBranchInset,
        );
        expect(
          tester
              .getSize(
                find.byKey(const ValueKey('branch-horizontal-view-padding')),
              )
              .width,
          expectedBranchViewInset,
        );

        final railContext = tester.element(find.byType(NavigationRail));
        expect(
          MediaQuery.paddingOf(railContext),
          const EdgeInsets.only(left: 44, right: 20),
        );
        expect(
          MediaQuery.viewPaddingOf(railContext),
          const EdgeInsets.only(left: 50, right: 30),
        );
      });
    }

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
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home_outlined),
                      materialSelected: Icon(Icons.home_outlined),
                      apple: Icon(Icons.home_outlined),
                      appleSelected: Icon(Icons.home_outlined),
                    ),
                  ),
                  AdaptiveNavigationDestination(
                    label: 'Today',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.calendar_today_outlined),
                      materialSelected: Icon(Icons.calendar_today_outlined),
                      apple: Icon(Icons.calendar_today_outlined),
                      appleSelected: Icon(Icons.calendar_today_outlined),
                    ),
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

    testWidgets('contextual suppression follows the declarative shell input', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      var scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
      router.setContextualChromeSuppressed(true);
      await tester.pumpAndSettle();
      expect(scope.visible.value, isFalse);
      expect(scope.scrollWish.value, isTrue);

      router.push('/habits/detail');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      scope = AdaptiveNavScope.of(tester.element(find.text('habits page')));
      expect(scope.visible.value, isFalse);

      scope.reportScrollWish(false);
      router.setContextualChromeSuppressed(false);
      await tester.pumpAndSettle();
      expect(scope.visible.value, isFalse);

      scope.reportScrollWish(true);
      router.setContextualChromeSuppressed(true);
      router.setContextualChromeSuppressed(false);
      router.go('/today');
      await tester.pumpAndSettle();

      scope = AdaptiveNavScope.of(tester.element(find.text('today page')));
      expect(scope.visible.value, isTrue);
      expect(scope.scrollWish.value, isTrue);
    });

    testWidgets('contextual suppression survives medium to compact resize', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.setContextualChromeSuppressed(true);
      await tester.pump();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pump();

      final compactScope = AdaptiveNavScope.of(
        tester.element(find.text('habits page')),
      );
      expect(compactScope.visible.value, isFalse);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
        0,
      );

      router.setContextualChromeSuppressed(false);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('bottom-bar'))).height,
        greaterThan(0),
      );
    });

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

    testWidgets('apple large ignores compact height and uses beside Sidebar', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      _setSurfaceSize(tester, const Size(1000, 479));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byType(NavigationRail), findsNothing);
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
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
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // macOS resolves the three-tier Apple system, so 700dp classifies as
      // medium and uses the same visible beside Sidebar as larger windows.
      expect(find.byType(NavigationRail), findsNothing);
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        findsOneWidget,
      );
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
      // Auto width uses the compact fixed target inside the interval.
      final panel = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel.minExtendedWidth, closeTo(200, 0.01));
      expect(find.byIcon(Icons.menu_open), findsOneWidget);
    });

    testWidgets('accepts a ratio-based automatic rail extent', (tester) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationShell(
            selectedIndex: 0,
            destinations: const [
              AdaptiveNavigationDestination(
                label: 'Home',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.home),
                  materialSelected: Icon(Icons.home),
                  apple: Icon(Icons.home),
                  appleSelected: Icon(Icons.home),
                ),
              ),
              AdaptiveNavigationDestination(
                label: 'Settings',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.settings),
                  materialSelected: Icon(Icons.settings),
                  apple: Icon(Icons.settings),
                  appleSelected: Icon(Icons.settings),
                ),
              ),
            ],
            onDestinationSelected: (_) {},
            sideNavigationExtent: const SideNavigationExtent.fromRatio(0.5),
            materialRailStyle: const MaterialNavigationRailStyle(
              collapsedExtent: 64,
            ),
            child: const SizedBox(),
          ),
        ),
      );

      final panel = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel.minWidth, 64);
      expect(panel.minExtendedWidth, closeTo(270, 0.01));
    });

    testWidgets('rail auto width follows the window within the interval', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1200, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      // The compact 200dp target fits the current 180-288dp interval.
      expect(panel().minExtendedWidth, closeTo(200, 0.01));

      tester.view.physicalSize = const Size(840, 800);
      await tester.pumpAndSettle();

      // The compact target remains inside the narrower interval.
      expect(panel().minExtendedWidth, closeTo(200, 0.01));
    });

    testWidgets('drag resizes the rail and clamps to the interval', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel().minExtendedWidth, closeTo(200, 0.01));
      final dragBar = find.byKey(
        const ValueKey('material-side-navigation-drag-bar'),
      );
      expect(dragBar, findsOneWidget);
      expect(tester.getSize(dragBar), const Size(4, 32));
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: dragBar,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(
        decoration.color,
        Theme.of(tester.element(dragBar)).colorScheme.onSurfaceVariant,
      );

      // Drag to the minimum without crossing it.
      await tester.drag(
        find.byKey(const ValueKey('rail-resize-handle')),
        const Offset(-20, 0),
      );
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, 180.0);
      expect(panel().extended, isTrue);

      // Drag far right: clamps to the maximum width.
      final gesture = await tester.startGesture(
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

    for (final direction in TextDirection.values) {
      testWidgets('material rail resizes from its logical end in $direction', (
        tester,
      ) async {
        _setSurfaceSize(tester, const Size(1000, 600));
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) =>
                Directionality(textDirection: direction, child: child!),
          ),
        );

        final railPanel = find.byKey(const ValueKey('rail-panel'));
        final resizeHandle = find.byKey(const ValueKey('rail-resize-handle'));
        expect(
          tester.getCenter(resizeHandle).dx,
          direction == TextDirection.ltr
              ? tester.getTopRight(railPanel).dx - 8
              : tester.getTopLeft(railPanel).dx + 8,
        );

        final logicalDrag = direction == TextDirection.ltr
            ? const Offset(30, 0)
            : const Offset(-30, 0);
        await tester.drag(resizeHandle, logicalDrag);
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<NavigationRail>(
                find.descendant(
                  of: railPanel,
                  matching: find.byType(NavigationRail),
                ),
              )
              .minExtendedWidth,
          greaterThan(200),
        );
      });
    }

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

      // Drag slightly narrower than the auto width (200) -> 195.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      await gesture.moveBy(const Offset(-5, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      NavigationRail panel() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(panel().minExtendedWidth, closeTo(195, 0.01));

      // The fixed auto target remains above the manual width, so it holds.
      tester.view.physicalSize = const Size(1400, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(195, 0.01));

      // Medium resets to collapsed; expanding it applies the interval-clamped
      // auto width because it has fallen below the remembered manual width.
      tester.view.physicalSize = const Size(680, 800);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(194.4, 0.01));

      // The auto value keeps following the interval down.
      tester.view.physicalSize = const Size(650, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(189, 0.01));

      // Grow back: the remembered manual value resumes.
      tester.view.physicalSize = const Size(1800, 800);
      await tester.pumpAndSettle();
      expect(panel().minExtendedWidth, closeTo(195, 0.01));
    });

    testWidgets('material rail uses the M3 collapsed destination layout', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      final destination = find.byKey(
        const ValueKey('material-rail-destination-0'),
      );
      final destinationSlot = find.byKey(
        const ValueKey('material-rail-destination-slot-0'),
      );
      final indicator = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-indicator')),
      );
      final collapsedLabel = find.descendant(
        of: destinationSlot,
        matching: find.byKey(const ValueKey('material-rail-collapsed-label')),
      );
      final expandedLabel = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-expanded-label')),
      );

      expect(tester.getSize(destination), const Size(56, 32));
      expect(rail.minWidth, 96);
      expect(tester.getSize(indicator), const Size(56, 32));
      expect(tester.widget<Opacity>(collapsedLabel).opacity, 1);
      expect(tester.widget<Opacity>(expandedLabel).opacity, 0);
      expect(
        tester.getCenter(find.byIcon(Icons.home)).dx,
        tester.getCenter(destination).dx,
      );
      expect(
        tester.getRect(destination).overlaps(tester.getRect(collapsedLabel)),
        isFalse,
      );
    });

    testWidgets('material rail frames the complete expanded destination', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1400, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('material-rail-destination-0'),
      );
      final indicator = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-indicator')),
      );
      final expandedLabel = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-expanded-label')),
      );
      final indicatorRect = tester.getRect(indicator);

      expect(tester.getSize(destination), const Size(160, 56));
      expect(tester.getSize(indicator), const Size(160, 56));
      expect(tester.widget<Opacity>(expandedLabel).opacity, 1);
      expect(
        indicatorRect.contains(tester.getCenter(find.byIcon(Icons.home))),
        isTrue,
      );
      expect(indicatorRect.contains(tester.getCenter(expandedLabel)), isTrue);
      expect(
        tester.getRect(
          find.descendant(of: destination, matching: find.byType(InkWell)),
        ),
        tester.getRect(destination),
      );
    });

    testWidgets('material rail destinations follow the rail animation', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('material-rail-destination-0'),
      );
      final destinationSlot = find.byKey(
        const ValueKey('material-rail-destination-slot-0'),
      );
      final indicator = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-indicator')),
      );
      final collapsedLabel = find.descendant(
        of: destinationSlot,
        matching: find.byKey(const ValueKey('material-rail-collapsed-label')),
      );
      final expandedLabel = find.descendant(
        of: destination,
        matching: find.byKey(const ValueKey('material-rail-expanded-label')),
      );
      final todayDestination = find.byKey(
        const ValueKey('material-rail-destination-1'),
      );
      final collapsedCenterY = tester.getCenter(destination).dy;
      final collapsedTodayCenterY = tester.getCenter(todayDestination).dy;

      await tester.tap(find.byKey(const ValueKey('rail-toggle-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.getSize(destination).width, inExclusiveRange(56, 158));
      expect(tester.getSize(indicator).width, inExclusiveRange(56, 158));
      expect(tester.getSize(destination).height, inExclusiveRange(32, 56));
      expect(tester.getSize(indicator).height, inExclusiveRange(32, 56));
      expect(tester.getCenter(destination).dy, collapsedCenterY);
      expect(tester.getCenter(todayDestination).dy, collapsedTodayCenterY);
      expect(
        tester.widget<Opacity>(collapsedLabel).opacity,
        inExclusiveRange(0, 1),
      );
      expect(
        tester.widget<Opacity>(expandedLabel).opacity,
        inExclusiveRange(0, 1),
      );

      await tester.pumpAndSettle();
      expect(tester.getSize(destination).width, closeTo(158, 0.01));
      expect(tester.getSize(indicator).width, closeTo(158, 0.01));
      expect(tester.getCenter(destination).dy, collapsedCenterY);
      expect(tester.getCenter(todayDestination).dy, collapsedTodayCenterY);

      await tester.tap(find.byKey(const ValueKey('rail-toggle-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.getSize(destination).width, inExclusiveRange(56, 158));
      expect(tester.getSize(indicator).width, inExclusiveRange(56, 158));
      expect(tester.getSize(destination).height, inExclusiveRange(32, 56));
      expect(tester.getSize(indicator).height, inExclusiveRange(32, 56));
      expect(tester.getCenter(destination).dy, collapsedCenterY);
      expect(tester.getCenter(todayDestination).dy, collapsedTodayCenterY);
      expect(
        tester.widget<Opacity>(collapsedLabel).opacity,
        inExclusiveRange(0, 1),
      );
      expect(
        tester.widget<Opacity>(expandedLabel).opacity,
        inExclusiveRange(0, 1),
      );

      await tester.pumpAndSettle();
      expect(tester.getSize(destination), const Size(56, 32));
      expect(tester.getSize(indicator), const Size(56, 32));
      expect(tester.getCenter(destination).dy, collapsedCenterY);
      expect(tester.getCenter(todayDestination).dy, collapsedTodayCenterY);
      expect(tester.takeException(), isNull);
    });

    testWidgets('material rail tap target matches each destination button', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(700, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final todayButton = find.byKey(
        const ValueKey('material-rail-destination-1'),
      );
      final todaySlot = find.byKey(
        const ValueKey('material-rail-destination-slot-1'),
      );
      final todayLabel = find.descendant(
        of: todaySlot,
        matching: find.byKey(const ValueKey('material-rail-collapsed-label')),
      );
      final buttonRect = tester.getRect(todayButton);
      await tester.tapAt(Offset(buttonRect.right + 4, buttonRect.center.dy));
      await tester.pumpAndSettle();
      expect(find.text('habits page'), findsOneWidget);

      await tester.tapAt(tester.getCenter(todayLabel));
      await tester.pumpAndSettle();
      expect(find.text('habits page'), findsOneWidget);

      await tester.tap(todayButton);
      await tester.pumpAndSettle();
      expect(find.text('today page'), findsOneWidget);
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

    for (final direction in TextDirection.values) {
      testWidgets(
        'material rail toggle keeps its logical-start anchor in $direction',
        (tester) async {
          _setSurfaceSize(tester, const Size(1800, 800));
          final router = _buildRouter();
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: router,
              builder: (context, child) =>
                  Directionality(textDirection: direction, child: child!),
            ),
          );

          final toggle = find.byKey(const ValueKey('rail-toggle-button'));
          final expandedCenter = tester.getCenter(toggle);
          final expandedTop = tester.getTopLeft(toggle).dy;
          expect(expandedTop, 0);

          await tester.tap(toggle);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.getCenter(toggle).dx, closeTo(expandedCenter.dx, 0.01));
          expect(tester.getTopLeft(toggle).dy, expandedTop);

          await tester.pumpAndSettle();
          expect(tester.getCenter(toggle).dx, closeTo(expandedCenter.dx, 0.01));
          expect(tester.getTopLeft(toggle).dy, expandedTop);
        },
      );
    }

    testWidgets('material rail toggle keeps the iPad window-control fallback', (
      tester,
    ) async {
      _mockWindowControlLayout();
      try {
        _setSurfaceSize(tester, const Size(700, 800));
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => AdaptiveStyleScope(
              override: AdaptiveStyle.material,
              child: child!,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final toggle = find.byKey(const ValueKey('rail-toggle-button'));
        Padding safeSpan() => tester.widget<Padding>(
          find.byKey(const ValueKey('rail-leading-safe-span')),
        );
        final collapsedCenter = tester.getCenter(toggle);
        expect(tester.getTopLeft(toggle).dy, 0);
        expect(
          safeSpan().padding,
          const EdgeInsetsDirectional.only(start: 40, end: 12),
        );

        await tester.tap(toggle);
        await tester.pumpAndSettle();

        expect(tester.getCenter(toggle).dx, closeTo(collapsedCenter.dx, 0.01));
        expect(tester.getTopLeft(toggle).dy, 0);
        expect(
          safeSpan().padding,
          const EdgeInsetsDirectional.only(start: 40, end: 12),
        );
      } finally {
        _resetWindowControlLayoutMock();
      }
    });

    testWidgets('collapsed rail hides the resize handle', (tester) async {
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.byKey(const ValueKey('rail-resize-handle')), findsNothing);
      expect(
        find.byKey(const ValueKey('rail-collapsed-resize-handle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('material-side-navigation-drag-bar')),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rail-resize-handle')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('rail-collapsed-resize-handle')),
        findsNothing,
      );
    });

    for (final direction in TextDirection.values) {
      testWidgets(
        'material rail collapses and reopens by dragging in $direction',
        (tester) async {
          _setSurfaceSize(tester, const Size(1800, 800));
          final router = _buildRouter();
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: router,
              builder: (context, child) =>
                  Directionality(textDirection: direction, child: child!),
            ),
          );
          await tester.pumpAndSettle();

          final collapseOffset = direction == TextDirection.ltr
              ? const Offset(-100, 0)
              : const Offset(100, 0);
          await tester.drag(
            find.byKey(const ValueKey('rail-resize-handle')),
            collapseOffset,
          );
          await tester.pumpAndSettle();

          NavigationRail rail() =>
              tester.widget<NavigationRail>(find.byType(NavigationRail));
          expect(rail().extended, isFalse);
          expect(
            find.byKey(const ValueKey('rail-resize-handle')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('material-side-navigation-drag-bar')),
            findsNothing,
          );

          final expandOffset = direction == TextDirection.ltr
              ? const Offset(24, 0)
              : const Offset(-24, 0);
          await tester.drag(
            find.byKey(const ValueKey('rail-resize-gesture-handle')),
            expandOffset,
          );
          await tester.pumpAndSettle();

          expect(rail().extended, isTrue);
          expect(
            find.byKey(const ValueKey('rail-resize-handle')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('material-side-navigation-drag-bar')),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets('material rail keeps one drag active across collapse', (
      tester,
    ) async {
      _setSurfaceSize(tester, const Size(1800, 800));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      NavigationRail rail() =>
          tester.widget<NavigationRail>(find.byType(NavigationRail));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );

      await gesture.moveBy(const Offset(-100, 0));
      await tester.pumpAndSettle();
      expect(rail().extended, isFalse);
      expect(
        find.byKey(const ValueKey('rail-collapsed-resize-handle')),
        findsOneWidget,
      );

      // The pointer is still down. Reversing the same gesture must reopen the
      // rail without requiring the user to release and grab it again.
      await gesture.moveBy(const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(rail().extended, isTrue);
      expect(find.byKey(const ValueKey('rail-resize-handle')), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('apple boundaries use beside Sidebar from medium upward', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(599, 479));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
        findsNothing,
      );

      for (final width in [600.0, 905.0, 906.0, 1400.0]) {
        tester.view.physicalSize = Size(width, 479);
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NavigationDrawer), findsNothing);
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-resize-handle')),
          findsOneWidget,
        );
        final sidebarSurface = find.byKey(
          const ValueKey('cupertino-sidebar-surface'),
        );
        final sidebarNavigationBar = find.descendant(
          of: sidebarSurface,
          matching: find.byType(CupertinoNavigationBar),
        );
        expect(sidebarNavigationBar, findsOneWidget);
        final navigationBar = tester.widget<CupertinoNavigationBar>(
          sidebarNavigationBar,
        );
        expect(navigationBar.enableBackgroundFilterBlur, isTrue);
        expect(navigationBar.backgroundColor, CupertinoColors.transparent);
        final destinationList = find.byKey(
          const ValueKey('cupertino-sidebar-destination-list'),
        );
        expect(
          tester.getTopLeft(destinationList).dy -
              tester.getTopLeft(sidebarSurface).dy,
          0,
        );
        final firstDestination = find.byKey(
          const ValueKey('cupertino-sidebar-destination-0'),
        );
        expect(
          tester.getTopLeft(firstDestination).dy -
              tester.getTopLeft(sidebarSurface).dy,
          greaterThanOrEqualTo(68),
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-scrim')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-edge-gesture')),
          findsOneWidget,
        );
      }
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar spaces destinations below toolbar blur', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 160));
      final router = _buildRouter(
        destinations: List<AdaptiveNavigationDestination>.generate(
          6,
          (index) => AdaptiveNavigationDestination(
            label: 'Destination $index',
            icons: const NavigationDestinationIcons(
              material: Icon(Icons.circle_outlined),
              materialSelected: Icon(Icons.circle),
              apple: Icon(CupertinoIcons.circle),
              appleSelected: Icon(CupertinoIcons.circle_fill),
            ),
          ),
        ),
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final surface = find.byKey(const ValueKey('cupertino-sidebar-surface'));
      final list = find.byKey(
        const ValueKey('cupertino-sidebar-destination-list'),
      );
      final secondDestination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-1'),
      );
      final surfaceTop = tester.getTopLeft(surface).dy;

      expect(tester.getTopLeft(list).dy, surfaceTop);
      expect(
        tester.getTopLeft(secondDestination).dy,
        greaterThan(surfaceTop + 44),
      );

      await tester.drag(list, const Offset(0, -100));
      await tester.pumpAndSettle();

      final scrolledTop = tester.getTopLeft(secondDestination).dy;
      expect(scrolledTop, greaterThan(surfaceTop));
      expect(scrolledTop, lessThan(surfaceTop + 44));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar visibility survives width-class round trips', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-resize-handle')),
        findsNothing,
      );

      tester.view.physicalSize = const Size(906, 600);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );

      tester.view.physicalSize = const Size(599, 600);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        findsOneWidget,
      );

      tester.view.physicalSize = const Size(700, 600);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'apple detail routes retain the hidden Sidebar command and avoidance',
      (tester) async {
        _mockWindowControlLayout();
        try {
          _setSurfaceSize(tester, const Size(700, 600));
          final router = _buildRouter();
          await tester.pumpWidget(MaterialApp.router(routerConfig: router));
          await tester.pumpAndSettle();

          final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
          final toggleElement = tester.element(toggle);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
          router.push('/habits/detail');
          await tester.pumpAndSettle();

          final pageLeading = find.byKey(const ValueKey('test-page-leading'));
          expect(find.text('detail page'), findsOneWidget);
          expect(toggle.hitTestable(), findsOneWidget);
          expect(tester.element(toggle), same(toggleElement));
          expect(tester.getTopLeft(toggle).dx, 56);
          expect(
            tester.getTopLeft(pageLeading).dx,
            greaterThanOrEqualTo(tester.getTopRight(toggle).dx),
          );
        } finally {
          _resetWindowControlLayoutMock();
        }
      },
    );

    for (final sliver in [false, true]) {
      testWidgets(
        'apple Sidebar command precedes existing ${sliver ? 'sliver ' : ''}app bar leading',
        (tester) async {
          _mockWindowControlLayout();
          try {
            _setSurfaceSize(tester, const Size(700, 600));
            await tester.pumpWidget(
              MaterialApp(
                home: AdaptiveNavigationShell(
                  selectedIndex: 0,
                  destinations: const [
                    AdaptiveNavigationDestination(
                      label: 'Habits',
                      icons: NavigationDestinationIcons(
                        material: Icon(Icons.home_outlined),
                        materialSelected: Icon(Icons.home),
                        apple: Icon(CupertinoIcons.home),
                        appleSelected: Icon(CupertinoIcons.house_fill),
                      ),
                    ),
                  ],
                  onDestinationSelected: (_) {},
                  child: Scaffold(
                    appBar: sliver
                        ? null
                        : const WindowControlAppBar(
                            leading: BackButton(
                              key: ValueKey('test-existing-leading'),
                            ),
                          ),
                    body: sliver
                        ? const CustomScrollView(
                            slivers: [
                              WindowControlSliverAppBar(
                                leading: BackButton(
                                  key: ValueKey('test-existing-leading'),
                                ),
                              ),
                              SliverFillRemaining(child: SizedBox.shrink()),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            await tester.tap(
              find.byKey(const ValueKey('cupertino-sidebar-toggle')),
            );
            await tester.pumpAndSettle();

            final toggle = find.byKey(
              const ValueKey('cupertino-sidebar-toggle'),
            );
            final existingLeading = find.byKey(
              const ValueKey('test-existing-leading'),
            );
            expect(toggle.hitTestable(), findsOneWidget);
            expect(tester.getTopLeft(toggle).dx, 56);
            expect(
              tester.getTopLeft(existingLeading).dx,
              greaterThanOrEqualTo(tester.getTopRight(toggle).dx),
            );
          } finally {
            _resetWindowControlLayoutMock();
          }
        },
      );
    }

    for (final direction in TextDirection.values) {
      testWidgets('apple hidden Sidebar opens from its edge in $direction', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        _setSurfaceSize(tester, const Size(700, 600));
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) =>
                Directionality(textDirection: direction, child: child!),
          ),
        );

        await tester.tap(
          find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-edge-gesture')),
          findsOneWidget,
        );

        final edgeStart = direction == TextDirection.ltr
            ? const Offset(5, 300)
            : const Offset(695, 300);
        final outsideStart = direction == TextDirection.ltr
            ? const Offset(25, 300)
            : const Offset(675, 300);
        final openingDelta = direction == TextDirection.ltr
            ? const Offset(40, 0)
            : const Offset(-40, 0);

        await tester.dragFrom(edgeStart, -openingDelta);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsNothing,
        );

        await tester.dragFrom(outsideStart, openingDelta);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsNothing,
        );

        await tester.dragFrom(edgeStart, openingDelta);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-edge-gesture')),
          findsOneWidget,
        );
        debugDefaultTargetPlatformOverride = null;
      });
    }

    testWidgets('apple Sidebar switches branch without closing', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final selected = <int>[];
      final router = _buildRouter(onBranchChanged: selected.add);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final destinationButtons = find.descendant(
        of: find.byKey(const ValueKey('cupertino-sidebar-destination-list')),
        matching: find.byType(CupertinoButton),
      );
      expect(destinationButtons, findsNWidgets(2));
      for (final button in tester.widgetList<CupertinoButton>(
        destinationButtons,
      )) {
        expect(button.sizeStyle, CupertinoButtonSize.medium);
        expect(button.minimumSize, const Size(0, 44));
        expect(button.pressedOpacity, 0.4);
      }
      await tester.tap(
        find.byKey(const ValueKey('cupertino-sidebar-destination-1')),
      );
      await tester.pumpAndSettle();

      expect(selected, [1]);
      expect(find.text('today page'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'apple Sidebar keeps one tooltip-enabled toggle across hosts and routes',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        tester.view.padding = const FakeViewPadding(top: 12);
        tester.view.viewPadding = const FakeViewPadding(top: 12);
        _setSurfaceSize(tester, const Size(700, 600));
        final router = _buildRouter();
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
        final anchor = find.byKey(
          const ValueKey('cupertino-sidebar-leading-anchor'),
        );
        final localizations = MaterialLocalizations.of(tester.element(toggle));
        final toggleElement = tester.element(toggle);

        expect(toggle, findsOneWidget);
        expect(toggle.hitTestable(), findsOneWidget);
        expect(tester.getSize(toggle), const Size.square(44));
        expect(
          tester
                  .getTopRight(
                    find.byKey(const ValueKey('cupertino-sidebar-surface')),
                  )
                  .dx -
              tester.getTopRight(toggle).dx,
          8,
        );
        expect(tester.getSize(anchor).width, 0);
        expect(
          tester
              .widget<Tooltip>(
                find.ancestor(of: toggle, matching: find.byType(Tooltip)),
              )
              .message,
          localizations.expandedIconTapHint,
        );

        await tester.tap(toggle);
        await tester.pumpAndSettle();

        expect(toggle, findsOneWidget);
        expect(tester.element(toggle), same(toggleElement));
        expect(tester.getSize(anchor), const Size.square(44));
        expect(tester.getTopLeft(toggle), tester.getTopLeft(anchor));
        expect(
          tester
              .widget<Tooltip>(
                find.ancestor(of: toggle, matching: find.byType(Tooltip)),
              )
              .message,
          localizations.collapsedIconTapHint,
        );

        final hiddenPosition = tester.getTopLeft(toggle);
        router.push('/habits/detail');
        await tester.pumpAndSettle();
        expect(tester.element(toggle), same(toggleElement));
        expect(tester.getTopLeft(toggle), hiddenPosition);
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets('apple Sidebar preserves one interactive toggle and focus', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
      final localizations = MaterialLocalizations.of(tester.element(toggle));
      final toggleElement = tester.element(toggle);
      final button = tester.widget<CupertinoButton>(toggle);
      button.focusNode!.requestFocus();
      await tester.pump();
      expect(button.focusNode!.hasFocus, isTrue);

      await tester.tap(toggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));

      expect(toggle, findsOneWidget);
      expect(tester.element(toggle), same(toggleElement));
      expect(
        tester.widget<CupertinoButton>(toggle).focusNode!.hasFocus,
        isTrue,
      );
      expect(
        find
                .bySemanticsLabel(localizations.expandedIconTapHint)
                .evaluate()
                .length +
            find
                .bySemanticsLabel(localizations.collapsedIconTapHint)
                .evaluate()
                .length,
        1,
      );

      await tester.pumpAndSettle();
      expect(tester.element(toggle), same(toggleElement));
      expect(
        tester.widget<CupertinoButton>(toggle).focusNode!.hasFocus,
        isTrue,
      );

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.element(toggle), same(toggleElement));
      expect(
        tester.widget<CupertinoButton>(toggle).focusNode!.hasFocus,
        isTrue,
      );
      semantics.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple macOS Sidebar keeps a compact inset toolbar', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
      final tooltip = find.ancestor(of: toggle, matching: find.byType(Tooltip));
      expect(
        tester.getCenter(toggle).dy,
        tester.getCenter(find.byKey(const ValueKey('test-page-leading'))).dy,
      );
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('cupertino-sidebar-surface')))
            .dy,
        12,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(toggle));
      await tester.pump(const Duration(seconds: 1));

      expect(tooltip, findsOneWidget);
      expect(
        find.text(tester.widget<Tooltip>(tooltip).message!),
        findsOneWidget,
      );

      await mouse.down(tester.getCenter(toggle));
      await mouse.up();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'apple hidden Sidebar toggle anchors to the search command bar',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        _setSurfaceSize(tester, const Size(700, 600));
        final controller = TextEditingController();
        final focusNode = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveNavigationShell(
              selectedIndex: 0,
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.home_outlined),
                    materialSelected: Icon(Icons.home),
                    apple: Icon(Icons.home_outlined),
                    appleSelected: Icon(Icons.home),
                  ),
                ),
                AdaptiveNavigationDestination(
                  label: 'Today',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.calendar_today_outlined),
                    materialSelected: Icon(Icons.calendar_today),
                    apple: Icon(Icons.calendar_today_outlined),
                    appleSelected: Icon(Icons.calendar_today),
                  ),
                ),
              ],
              onDestinationSelected: (_) {},
              child: Scaffold(
                body: CustomScrollView(
                  slivers: [
                    AdaptiveSliverSearchBar.apple(
                      title: const Text('Habits'),
                      leading: const Icon(
                        Icons.article_outlined,
                        key: ValueKey('test-search-leading'),
                      ),
                      controller: controller,
                      focusNode: focusNode,
                      isSearchActive: false,
                      keyword: '',
                      onChanged: (_) {},
                      onSearchActivated: () {},
                      onSearchDismissed: () {},
                    ),
                    const SliverFillRemaining(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        );

        final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
        final anchor = find.byKey(
          const ValueKey('cupertino-sidebar-leading-anchor'),
        );
        final header = tester.widget<SliverPersistentHeader>(
          find.byType(SliverPersistentHeader),
        );

        expect(header.delegate.minExtent, 56);
        expect(header.delegate.maxExtent, 56);
        final toggleElement = tester.element(toggle);
        expect(toggle, findsOneWidget);
        expect(toggle.hitTestable(), findsOneWidget);
        expect(tester.getSize(anchor).width, 0);

        await tester.tap(toggle);
        await tester.pumpAndSettle();

        expect(toggle.hitTestable(), findsOneWidget);
        expect(tester.element(toggle), same(toggleElement));
        expect(tester.getSize(anchor), const Size.square(44));
        expect(tester.getTopLeft(anchor).dy, 12);
        expect(tester.getTopLeft(toggle), tester.getTopLeft(anchor));
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey('test-search-leading')))
              .dx,
          greaterThan(tester.getTopLeft(toggle).dx),
        );
        debugDefaultTargetPlatformOverride = null;
      },
    );

    for (final direction in TextDirection.values) {
      testWidgets('apple Sidebar resizes and remembers width in $direction', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        _setSurfaceSize(tester, const Size(1000, 600));
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) =>
                Directionality(textDirection: direction, child: child!),
          ),
        );

        Size panelSize() => tester.getSize(
          find.byKey(const ValueKey('cupertino-sidebar-panel')),
        );
        expect(panelSize().width, 200);
        final resizeHandle = find.byKey(
          const ValueKey('cupertino-sidebar-resize-handle'),
        );
        expect(
          find.byKey(const ValueKey('material-side-navigation-drag-bar')),
          findsNothing,
        );
        expect(tester.getSize(resizeHandle).width, 16);
        expect(tester.getSize(resizeHandle).height, panelSize().height - 50);
        expect(
          tester.getCenter(resizeHandle).dx,
          direction == TextDirection.ltr
              ? tester
                        .getTopRight(
                          find.byKey(
                            const ValueKey('cupertino-sidebar-surface'),
                          ),
                        )
                        .dx -
                    8
              : tester
                        .getTopLeft(
                          find.byKey(
                            const ValueKey('cupertino-sidebar-surface'),
                          ),
                        )
                        .dx +
                    8,
        );

        final logicalDrag = direction == TextDirection.ltr
            ? const Offset(30, 0)
            : const Offset(-30, 0);
        await tester.drag(resizeHandle, logicalDrag);
        await tester.pumpAndSettle();
        final resizedWidth = panelSize().width;
        expect(resizedWidth, greaterThan(200));

        await tester.tap(
          find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        );
        await tester.pumpAndSettle();
        expect(panelSize().width, resizedWidth);

        tester.view.physicalSize = const Size(599, 600);
        await tester.pumpAndSettle();
        tester.view.physicalSize = const Size(1000, 600);
        await tester.pumpAndSettle();
        expect(panelSize().width, resizedWidth);
        debugDefaultTargetPlatformOverride = null;
      });
    }

    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      testWidgets('custom drag handle builder is adaptive on $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        _setSurfaceSize(tester, const Size(1000, 600));
        final observedStates = <Set<WidgetState>>[];

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveNavigationShell(
              selectedIndex: 0,
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.home_outlined),
                    materialSelected: Icon(Icons.home),
                    apple: Icon(CupertinoIcons.home),
                    appleSelected: Icon(CupertinoIcons.house_fill),
                  ),
                ),
              ],
              onDestinationSelected: (_) {},
              sideNavigationDragHandleBuilder: (context, states) {
                observedStates.add(Set<WidgetState>.of(states));
                return const SizedBox(
                  key: ValueKey('custom-side-navigation-drag-bar'),
                  width: 3,
                  height: 24,
                );
              },
              child: const Scaffold(body: SizedBox.expand()),
            ),
          ),
        );

        final customBar = find.byKey(
          const ValueKey('custom-side-navigation-drag-bar'),
        );
        final resizeHandle = find.byKey(
          ValueKey(
            platform == TargetPlatform.iOS
                ? 'cupertino-sidebar-resize-handle'
                : 'rail-resize-handle',
          ),
        );
        expect(customBar, findsOneWidget);
        expect(tester.getSize(customBar), const Size(3, 24));

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(resizeHandle));
        await tester.pump();
        expect(
          observedStates.any((states) => states.contains(WidgetState.hovered)),
          isTrue,
        );

        await mouse.down(tester.getCenter(resizeHandle));
        await mouse.moveBy(const Offset(10, 0));
        await tester.pump();
        expect(
          observedStates.any((states) => states.contains(WidgetState.dragged)),
          isTrue,
        );
        await mouse.up();
        await tester.pumpAndSettle();
        expect(observedStates.last.contains(WidgetState.dragged), isFalse);
        debugDefaultTargetPlatformOverride = null;
      });
    }

    testWidgets(
      'apple beside span constrains the branch without changing media',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        tester.view.padding = const FakeViewPadding(left: 44, right: 20);
        tester.view.viewPadding = const FakeViewPadding(left: 50, right: 30);
        _setSurfaceSize(tester, const Size(700, 600));

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveNavigationShell(
              selectedIndex: 0,
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.home_outlined),
                    materialSelected: Icon(Icons.home),
                    apple: Icon(CupertinoIcons.home),
                    appleSelected: Icon(CupertinoIcons.house_fill),
                  ),
                ),
              ],
              onDestinationSelected: (_) {},
              child: const _BranchInsetsProbe(),
            ),
          ),
        );

        Size branchPadding() => tester.getSize(
          find.byKey(const ValueKey('branch-horizontal-padding')),
        );
        Size branchViewPadding() => tester.getSize(
          find.byKey(const ValueKey('branch-horizontal-view-padding')),
        );
        final branch = find.byKey(const ValueKey('branch-layout-probe'));
        final surface = find.byKey(const ValueKey('cupertino-sidebar-surface'));
        final surfaceWidget = tester.widget<CupertinoFloatingGlassSurface>(
          surface,
        );

        expect(branchPadding().width, 64);
        expect(branchViewPadding().width, 80);
        expect(tester.getTopLeft(branch).dx, 254);
        expect(tester.getTopLeft(surface), const Offset(44, 12));
        expect(tester.getSize(surface), const Size(198, 576));
        expect(
          surfaceWidget.borderRadius,
          const BorderRadius.all(Radius.circular(25)),
        );
        expect(surfaceWidget.blurSigma, 10);

        await tester.tap(
          find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        );
        await tester.pumpAndSettle();
        expect(branchPadding().width, 64);
        expect(branchViewPadding().width, 80);
        expect(tester.getTopLeft(branch).dx, 0);
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets('apple Sidebar preserves all branch media insets', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.padding = const FakeViewPadding(
        left: 11,
        top: 22,
        right: 33,
        bottom: 44,
      );
      tester.view.viewPadding = const FakeViewPadding(
        left: 15,
        top: 26,
        right: 37,
        bottom: 48,
      );
      tester.view.viewInsets = const FakeViewPadding(
        left: 3,
        top: 5,
        right: 7,
        bottom: 90,
      );
      _setSurfaceSize(tester, const Size(700, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationShell(
            selectedIndex: 0,
            destinations: const [
              AdaptiveNavigationDestination(
                label: 'Habits',
                icons: NavigationDestinationIcons(
                  material: Icon(Icons.home_outlined),
                  materialSelected: Icon(Icons.home),
                  apple: Icon(CupertinoIcons.home),
                  appleSelected: Icon(CupertinoIcons.house_fill),
                ),
              ),
            ],
            onDestinationSelected: (_) {},
            child: const _BranchInsetsProbe(),
          ),
        ),
      );

      expect(
        tester
            .getSize(find.byKey(const ValueKey('branch-horizontal-padding')))
            .width,
        44,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('branch-vertical-padding')))
            .height,
        66,
      );
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('branch-horizontal-view-padding')),
            )
            .width,
        52,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('branch-vertical-view-padding')))
            .height,
        74,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('branch-view-insets'))),
        const Size(10, 95),
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar disables visibility animation immediately', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar exposes selected destination semantics', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final destinationSemantics = tester.getSemantics(
        find.byKey(const ValueKey('cupertino-sidebar-destination-0')),
      );
      expect(destinationSemantics.label, 'Habits');
      expect(destinationSemantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(destinationSemantics.flagsCollection.isButton, isTrue);
      expect(find.bySemanticsLabel('Show Snackbar'), findsOneWidget);
      semanticsHandle.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar supports keyboard activation', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final selected = <int>[];
      final router = _buildRouter(onBranchChanged: selected.add);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final selectedButton = tester.widget<CupertinoButton>(
        find.descendant(
          of: find.byKey(const ValueKey('cupertino-sidebar-destination-0')),
          matching: find.byType(CupertinoButton),
        ),
      );
      expect(selectedButton.autofocus, isTrue);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(selected, [1]);
      expect(find.text('today page'), findsOneWidget);

      final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
      final toggleButton = tester.widget<CupertinoButton>(toggle);
      toggleButton.focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('cupertino-sidebar-panel')),
        findsNothing,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar remains usable at large text scale', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      _setSurfaceSize(tester, const Size(700, 240));
      final router = _buildRouter(
        destinations: const [
          AdaptiveNavigationDestination(
            label: 'A very long habits destination label',
            icons: NavigationDestinationIcons(
              material: Icon(Icons.home_outlined),
              materialSelected: Icon(Icons.home),
              apple: Icon(CupertinoIcons.home),
              appleSelected: Icon(CupertinoIcons.house_fill),
            ),
          ),
          AdaptiveNavigationDestination(
            label: 'Today',
            icons: NavigationDestinationIcons(
              material: Icon(Icons.calendar_today_outlined),
              materialSelected: Icon(Icons.calendar_today),
              apple: Icon(CupertinoIcons.calendar),
              appleSelected: Icon(CupertinoIcons.calendar_today),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final destinationButtons = tester.widgetList<CupertinoButton>(
        find.descendant(
          of: find.byKey(const ValueKey('cupertino-sidebar-destination-list')),
          matching: find.byType(CupertinoButton),
        ),
      );
      expect(destinationButtons, hasLength(2));
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-resize-handle')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('apple Sidebar destination foregrounds stay opaque', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      _setSurfaceSize(tester, const Size(700, 600));
      final router = _buildRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: Color(0x80336699),
            ),
          ),
          routerConfig: router,
        ),
      );

      CupertinoButton destinationButton(int index) =>
          tester.widget<CupertinoButton>(
            find.descendant(
              of: find.byKey(ValueKey('cupertino-sidebar-destination-$index')),
              matching: find.byType(CupertinoButton),
            ),
          );

      expect(destinationButton(0).foregroundColor!.a, 1);
      expect(destinationButton(1).foregroundColor!.a, 1);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'apple Sidebar resolves the Cupertino bar surface in dark mode',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        _setSurfaceSize(tester, const Size(700, 600));
        const barBackground = Color(0xCC112233);
        final router = _buildRouter();
        await tester.pumpWidget(
          MaterialApp.router(
            theme: ThemeData.dark().copyWith(
              cupertinoOverrideTheme: const CupertinoThemeData(
                barBackgroundColor: barBackground,
              ),
            ),
            routerConfig: router,
          ),
        );

        final surfaceFinder = find.byKey(
          const ValueKey('cupertino-sidebar-surface'),
        );
        final surface = tester.widget<CupertinoFloatingGlassSurface>(
          surfaceFinder,
        );
        final coloredSurfaces = tester.widgetList<ColoredBox>(
          find.descendant(of: surfaceFinder, matching: find.byType(ColoredBox)),
        );
        expect(
          surface.borderRadius,
          const BorderRadius.all(Radius.circular(25)),
        );
        expect(surface.blurSigma, 10);
        expect(
          coloredSurfaces.any((surface) => surface.color == barBackground),
          isTrue,
        );
        expect(
          find.descendant(
            of: surfaceFinder,
            matching: find.byType(BackdropFilter),
          ),
          findsNWidgets(2),
        );
        expect(find.byType(NavigationRail), findsNothing);
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets('navigation toggles use Flutter localization labels', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      _setSurfaceSize(tester, const Size(700, 600));
      var router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final materialContext = tester.element(
        find.byKey(const ValueKey('rail-toggle-button')),
      );
      final localizations = MaterialLocalizations.of(materialContext);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('rail-toggle-button')),
            )
            .tooltip,
        localizations.collapsedIconTapHint,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(
        find.bySemanticsLabel(localizations.expandedIconTapHint),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(localizations.collapsedIconTapHint),
        findsOneWidget,
      );
      semantics.dispose();
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

      // Drag wider than the auto width (200) -> 230.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('rail-resize-handle'))),
      );
      for (var i = 0; i < 3; i++) {
        await gesture.moveBy(const Offset(10, 0));
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
      expect(rail.minExtendedWidth, closeTo(230, 0.01));
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

class _StatefulBranchProbe extends StatefulWidget {
  const _StatefulBranchProbe();

  @override
  State<_StatefulBranchProbe> createState() => _StatefulBranchProbeState();
}

class _StatefulBranchProbeState extends State<_StatefulBranchProbe> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () => setState(() => _count += 1),
        child: Text('branch count $_count'),
      ),
    ),
  );
}
