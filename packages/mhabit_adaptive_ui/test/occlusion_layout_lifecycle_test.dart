import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_fab.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_toolbar.dart';

const _size = Size(600, 800);
const _safe = EdgeInsets.only(right: 84, bottom: 34);

IosOcclusionGeometry _geometry({bool vertical = true, Size size = _size}) =>
    IosOcclusionGeometry(
      viewBounds: Offset.zero & size,
      activeOcclusionRegions: const [],
      hasVerticalSystemBar: vertical,
      verticalBarLayoutFrame: Rect.fromLTWH(
        size.width - 70,
        0,
        44,
        size.height - 34,
      ),
    );

Widget _host({
  required GlobalKey<NavigatorState> navigator,
  required Widget child,
  Key? windowKey,
  bool hasWindowControls = false,
  bool declareViewport = true,
  ValueNotifier<IosOcclusionGeometry?>? geometry,
}) => MaterialApp(
  navigatorKey: navigator,
  builder: (context, child) {
    final content = declareViewport
        ? OcclusionViewport(bounds: Offset.zero & _size, child: child!)
        : child!;
    Widget layout(IosOcclusionGeometry? value, Widget child) =>
        AdaptiveOcclusionLayout(
          key: windowKey,
          geometry: value,
          systemSafeArea: _safe,
          cornerRadii: BorderRadius.zero,
          hasWindowControls: hasWindowControls,
          child: child,
        );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(padding: _safe, viewPadding: _safe),
      child: geometry == null
          ? layout(_geometry(), content)
          : ValueListenableBuilder<IosOcclusionGeometry?>(
              valueListenable: geometry,
              child: content,
              builder: (context, value, child) => layout(value, child!),
            ),
    );
  },
  home: child,
);

class _CountingAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _CountingAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value;

  final _statusListeners = <AnimationStatusListener>{};

  int get statusListenerCount => _statusListeners.length;

  @override
  void addStatusListener(AnimationStatusListener listener) {
    _statusListeners.add(listener);
    super.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _statusListeners.remove(listener);
    super.removeStatusListener(listener);
  }
}

class _CountingRoute extends PageRouteBuilder<void> {
  _CountingRoute({required Widget child})
    : super(pageBuilder: (context, animation, secondaryAnimation) => child);

  _CountingAnimation? _animation;
  _CountingAnimation? _secondaryAnimation;

  @override
  Animation<double>? get animation {
    final animation = super.animation;
    return animation == null
        ? null
        : _animation ??= _CountingAnimation(animation);
  }

  @override
  Animation<double>? get secondaryAnimation {
    final animation = super.secondaryAnimation;
    return animation == null
        ? null
        : _secondaryAnimation ??= _CountingAnimation(animation);
  }

  int get statusListenerCount =>
      (_animation?.statusListenerCount ?? 0) +
      (_secondaryAnimation?.statusListenerCount ?? 0);
}

void main() {
  void configure(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
  }

  for (final declared in [true, false]) {
    testWidgets(
      'FAB consumer ${declared ? 'uses its declared viewport without route refreshes' : 'keeps original placement without measurement'}',
      (tester) async {
        configure(tester);
        final navigator = GlobalKey<NavigatorState>();
        final content = ValueNotifier<Widget>(const SizedBox.expand());
        final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
        addTearDown(content.dispose);
        addTearDown(geometry.dispose);
        await tester.pumpWidget(
          _host(
            navigator: navigator,
            declareViewport: declared,
            geometry: geometry,
            child: const SizedBox.expand(),
          ),
        );
        final route = _CountingRoute(
          child: ValueListenableBuilder<Widget>(
            valueListenable: content,
            builder: (context, child, _) => child,
          ),
        );
        navigator.currentState!.push<void>(route);
        await tester.pumpAndSettle();
        // Mount only the consumer after the route has settled so Navigator's
        // own subscriptions and normal transition builds form the baseline.
        final routeListeners = route.statusListenerCount;
        var builds = 0;
        content.value = Builder(
          builder: (context) {
            builds++;
            AdaptiveOcclusionFabLocation.resolveOf(context);
            AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context);
            return const SizedBox.expand();
          },
        );
        await tester.pump();
        final firstBuilds = builds;
        await tester.pump();
        expect(route.statusListenerCount, routeListeners);
        expect(builds, firstBuilds);
        for (final value in <IosOcclusionGeometry?>[null, _geometry()]) {
          geometry.value = value;
          await tester.pump();
          final updatedBuilds = builds;
          await tester.pump();
          expect(route.statusListenerCount, routeListeners);
          expect(builds, updatedBuilds);
        }
        content.value = const SizedBox.expand();
        await tester.pump();
        expect(route.statusListenerCount, routeListeners);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('FAB animation policy is shared across routes in one window', (
    tester,
  ) async {
    configure(tester);
    final navigator = GlobalKey<NavigatorState>();
    final geometry = ValueNotifier<IosOcclusionGeometry?>(null);
    addTearDown(geometry.dispose);
    await tester.pumpWidget(
      _host(
        navigator: navigator,
        geometry: geometry,
        child: Builder(
          builder: (context) => Scaffold(
            floatingActionButtonAnimator:
                AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    FloatingActionButtonAnimator? animator() => tester
        .widget<Scaffold>(find.byType(Scaffold))
        .floatingActionButtonAnimator;
    expect(animator(), isNull);
    for (final value in <IosOcclusionGeometry?>[
      _geometry(),
      null,
      _geometry(),
    ]) {
      geometry.value = value;
      await tester.pumpAndSettle();
      expect(animator(), FloatingActionButtonAnimator.noAnimation);
    }
    geometry.value = null;
    navigator.currentState!.push<void>(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          key: const ValueKey('new-page'),
          floatingActionButtonAnimator:
              AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Scaffold>(find.byKey(const ValueKey('new-page')))
          .floatingActionButtonAnimator,
      FloatingActionButtonAnimator.noAnimation,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving the vertical system-bar mode resets the window policy', (
    tester,
  ) async {
    configure(tester);
    final navigator = GlobalKey<NavigatorState>();
    final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
    addTearDown(geometry.dispose);
    await tester.pumpWidget(
      _host(
        navigator: navigator,
        geometry: geometry,
        child: Builder(
          builder: (context) => Scaffold(
            floatingActionButtonAnimator:
                AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    FloatingActionButtonAnimator? animator() => tester
        .widget<Scaffold>(find.byType(Scaffold))
        .floatingActionButtonAnimator;
    expect(animator(), FloatingActionButtonAnimator.noAnimation);
    geometry.value = null;
    await tester.pumpAndSettle();
    expect(animator(), FloatingActionButtonAnimator.noAnimation);
    geometry.value = _geometry(vertical: false);
    await tester.pumpAndSettle();
    expect(animator(), isNull);
    geometry.value = null;
    await tester.pumpAndSettle();
    expect(animator(), isNull);
    geometry.value = _geometry();
    await tester.pumpAndSettle();
    expect(animator(), FloatingActionButtonAnimator.noAnimation);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a newly mounted window does not inherit another window policy', (
    tester,
  ) async {
    configure(tester);
    final navigator = GlobalKey<NavigatorState>();
    final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
    addTearDown(geometry.dispose);
    final page = Builder(
      builder: (context) => Scaffold(
        floatingActionButtonAnimator:
            AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
      ),
    );
    await tester.pumpWidget(
      _host(
        navigator: navigator,
        geometry: geometry,
        windowKey: const ValueKey('first-window'),
        child: page,
      ),
    );
    await tester.pumpAndSettle();
    FloatingActionButtonAnimator? animator() => tester
        .widget<Scaffold>(find.byType(Scaffold))
        .floatingActionButtonAnimator;
    expect(animator(), FloatingActionButtonAnimator.noAnimation);
    geometry.value = null;
    await tester.pumpAndSettle();
    expect(animator(), FloatingActionButtonAnimator.noAnimation);
    await tester.pumpWidget(
      _host(
        navigator: navigator,
        geometry: geometry,
        windowKey: const ValueKey('second-window'),
        child: page,
      ),
    );
    await tester.pumpAndSettle();
    expect(animator(), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'window resizing keeps animation policy while geometry catches up',
    (tester) async {
      configure(tester);
      final navigator = GlobalKey<NavigatorState>();
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
      addTearDown(geometry.dispose);
      await tester.pumpWidget(
        _host(
          navigator: navigator,
          geometry: geometry,
          child: Builder(
            builder: (context) => Scaffold(
              floatingActionButtonAnimator:
                  AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(
                    context,
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      void expectLayout({required bool current}) {
        final scaffold = find.byType(Scaffold);
        final context = tester.element(scaffold);
        expect(
          AdaptiveOcclusionScope.maybeOf(context)!.isCurrent(context),
          current,
        );
        expect(
          tester.widget<Scaffold>(scaffold).floatingActionButtonAnimator,
          FloatingActionButtonAnimator.noAnimation,
        );
      }

      expectLayout(current: true);
      const resized = Size(800, 600);
      geometry.value = _geometry(size: resized);
      await tester.pumpAndSettle();
      expectLayout(current: false);
      geometry.value = _geometry();
      await tester.pumpAndSettle();
      expectLayout(current: true);
      tester.view.physicalSize = resized;
      await tester.pumpAndSettle();
      expectLayout(current: false);
      geometry.value = _geometry(size: resized);
      await tester.pumpAndSettle();
      expectLayout(current: true);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'window controls reset animation policy through missing snapshots',
    (tester) async {
      configure(tester);
      final navigator = GlobalKey<NavigatorState>();
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
      addTearDown(geometry.dispose);
      final page = Builder(
        builder: (context) => Scaffold(
          floatingActionButtonAnimator:
              AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
        ),
      );
      await tester.pumpWidget(
        _host(navigator: navigator, geometry: geometry, child: page),
      );
      await tester.pumpAndSettle();
      FloatingActionButtonAnimator? animator() => tester
          .widget<Scaffold>(find.byType(Scaffold))
          .floatingActionButtonAnimator;
      expect(animator(), FloatingActionButtonAnimator.noAnimation);
      await tester.pumpWidget(
        _host(
          navigator: navigator,
          geometry: geometry,
          hasWindowControls: true,
          child: page,
        ),
      );
      await tester.pumpAndSettle();
      expect(animator(), isNull);
      geometry.value = null;
      await tester.pumpAndSettle();
      expect(animator(), isNull);
      await tester.pumpWidget(
        _host(navigator: navigator, geometry: geometry, child: page),
      );
      await tester.pumpAndSettle();
      expect(animator(), isNull);
      geometry.value = _geometry();
      await tester.pumpAndSettle();
      expect(animator(), FloatingActionButtonAnimator.noAnimation);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'moving the same owner to another Flutter view resets its policy',
    (tester) async {
      configure(tester);
      final windowKey = GlobalKey();
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
      addTearDown(geometry.dispose);
      final content = ValueListenableBuilder<IosOcclusionGeometry?>(
        valueListenable: geometry,
        builder: (context, snapshot, child) => AdaptiveOcclusionLayout(
          key: windowKey,
          geometry: snapshot,
          systemSafeArea: _safe,
          cornerRadii: BorderRadius.zero,
          child: child!,
        ),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              floatingActionButtonAnimator:
                  AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(
                    context,
                  ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        View(view: tester.view, child: content),
        wrapWithView: false,
      );
      await tester.pumpAndSettle();
      final ownerState = tester.state(find.byKey(windowKey));
      FloatingActionButtonAnimator? animator() => tester
          .widget<Scaffold>(find.byType(Scaffold))
          .floatingActionButtonAnimator;
      expect(animator(), FloatingActionButtonAnimator.noAnimation);
      geometry.value = null;
      await tester.pumpAndSettle();
      expect(animator(), FloatingActionButtonAnimator.noAnimation);
      final otherView = TestFlutterView(
        view: tester.view,
        platformDispatcher: tester.binding.platformDispatcher,
        display: tester.view.display,
      );
      await tester.pumpWidget(
        View(view: otherView, child: content),
        wrapWithView: false,
      );
      await tester.pumpAndSettle();
      expect(tester.state(find.byKey(windowKey)), same(ownerState));
      expect(animator(), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('toolbar keeps declared local insets through route transitions', (
    tester,
  ) async {
    configure(tester);
    final navigator = GlobalKey<NavigatorState>();
    final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry());
    addTearDown(geometry.dispose);
    var padding = EdgeInsets.zero;
    final toolbar = Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 44,
          child: AdaptiveOcclusionToolbar(
            bounds: const Rect.fromLTWH(0, 0, 600, 44),
            child: Builder(
              builder: (context) {
                padding = MediaQuery.paddingOf(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      _host(
        navigator: navigator,
        geometry: geometry,
        child: const SizedBox.expand(),
      ),
    );
    await tester.pumpAndSettle();
    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => toolbar,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero),
            ),
            child: child,
          ),
    );
    navigator.currentState!.push<void>(route);
    await tester.pump();
    expect(padding.right, 26);
    for (var frame = 0; frame < 24; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(padding.right, 26);
    }
    await tester.pumpAndSettle();
    expect(padding.right, 26);
    for (final invalid in <IosOcclusionGeometry?>[
      null,
      _geometry(size: const Size(800, 600)),
    ]) {
      geometry.value = invalid;
      await tester.pump();
      expect(padding.right, _safe.right);
    }
    geometry.value = _geometry();
    await tester.pump();
    expect(padding.right, 26);
    expect(tester.takeException(), isNull);
  });
}
