import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import '../harness/adaptive_ui_theme.dart';

const _size = Size(466, 678);
const _safe = EdgeInsets.only(right: 84, bottom: 34);

Widget _host({
  required GlobalKey<NavigatorState> navigator,
  required bool vertical,
  required bool nested,
  required ValueNotifier<bool> showFab,
  EdgeInsets viewportPadding = EdgeInsets.zero,
  Object? heroTag,
}) => MaterialApp(
  navigatorKey: navigator,
  theme: ThemeData(platform: TargetPlatform.iOS, useMaterial3: true),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(padding: _safe, viewPadding: _safe),
    child: AdaptiveOcclusionLayout(
      geometry: IosOcclusionGeometry(
        viewBounds: Offset.zero & _size,
        activeOcclusionRegions: const [Rect.fromLTWH(382, 0, 84, 174)],
        hasVerticalSystemBar: vertical,
        verticalBarLayoutFrame: const Rect.fromLTWH(396, 174, 44, 470),
      ),
      systemSafeArea: _safe,
      cornerRadii: BorderRadius.zero,
      child: Padding(
        padding: viewportPadding,
        child: OcclusionViewport(
          bounds: viewportPadding.deflateRect(Offset.zero & _size),
          child: child!,
        ),
      ),
    ),
  ),
  home: nested
      ? Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) =>
                _FabPage(id: 'home', showFab: showFab, heroTag: heroTag),
          ),
        )
      : _FabPage(id: 'home', showFab: showFab, heroTag: heroTag),
);

class _FabPage extends StatelessWidget {
  const _FabPage({required this.id, required this.showFab, this.heroTag});

  final String id;
  final ValueNotifier<bool> showFab;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: showFab,
    builder: (context, visible, _) => Scaffold(
      key: ValueKey('scaffold-$id'),
      floatingActionButtonAnimator:
          AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
      floatingActionButtonLocation: AdaptiveOcclusionFabLocation.resolveOf(
        context,
      ),
      body: SafeArea(child: SizedBox.expand(key: ValueKey('body-$id'))),
      // The production Material pages reserve the floating navigation bar
      // with AnimatedPadding around the complete FAB, including its label.
      floatingActionButton: visible
          ? AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.only(bottom: 48),
              child: FloatingActionButton.extended(
                key: ValueKey('fab-$id'),
                heroTag: heroTag,
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Habit'),
              ),
            )
          : null,
    ),
  );
}

Rect _localFabRect(WidgetTester tester, String id) {
  final scaffold = tester.renderObject<RenderBox>(
    find.byKey(ValueKey('scaffold-$id'), skipOffstage: false),
  );
  final fab = tester.renderObject<RenderBox>(
    find.byKey(ValueKey('fab-$id'), skipOffstage: false),
  );
  // Remove the page's own route transform. Its normal slide/scale is not a
  // relayout of the FAB inside the page, while Scaffold's FAB scale still is.
  return MatrixUtils.transformRect(
    fab.getTransformTo(scaffold),
    Offset.zero & fab.size,
  );
}

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'Material rail declares its trailing FAB viewport in $direction',
      (tester) async {
        const size = Size(951, 669);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        final paneNavigator = GlobalKey<NavigatorState>();
        final visible = ValueNotifier(true);
        addTearDown(visible.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            builder: (context, child) => Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: _safe, viewPadding: _safe),
                child: AdaptiveWindowControlLayoutScope(
                  horizontalAvoidance: EdgeInsets.zero,
                  verticalAvoidance: EdgeInsets.zero,
                  owner: WindowControlLayoutOwner.appBar,
                  child: AdaptiveOcclusionLayout(
                    geometry: IosOcclusionGeometry(
                      viewBounds: Offset.zero & size,
                      activeOcclusionRegions: const [
                        Rect.fromLTWH(867, 0, 84, 124),
                      ],
                      hasVerticalSystemBar: true,
                    ),
                    systemSafeArea: _safe,
                    cornerRadii: BorderRadius.zero,
                    child: OcclusionViewport(
                      bounds: Offset.zero & size,
                      child: child!,
                    ),
                  ),
                ),
              ),
            ),
            home: TestAdaptiveUiTheme(
              update: (theme) => theme.copyWith(style: AdaptiveStyle.material),
              child: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home),
                      materialSelected: Icon(Icons.home),
                      apple: Icon(Icons.home),
                      appleSelected: Icon(Icons.home),
                    ),
                  ),
                ],
                onDestinationSelected: (_) {},
                child: Navigator(
                  key: paneNavigator,
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => _FabPage(id: 'home', showFab: visible),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewport = OcclusionViewport.maybeOf(
          tester.element(find.byKey(const ValueKey('scaffold-home'))),
        )!.bounds!;
        expect(viewport.width, lessThan(size.width));
        expect(viewport.height, size.height);
        expect(
          direction == TextDirection.ltr ? viewport.right : viewport.left,
          direction == TextDirection.ltr ? size.width : 0,
        );
        final expected = _localFabRect(tester, 'home');
        expect(
          direction == TextDirection.ltr ? expected.right : expected.left,
          closeTo(
            direction == TextDirection.ltr ? viewport.width - 16 : 16,
            0.01,
          ),
        );
        paneNavigator.currentState!.push<void>(
          MaterialPageRoute<void>(
            allowSnapshotting: false,
            builder: (_) => _FabPage(id: 'detail', showFab: visible),
          ),
        );
        await tester.pump();
        for (var frame = 0; frame < 30; frame++) {
          final current = _localFabRect(tester, 'detail');
          expect(current.left, closeTo(expected.left, 0.01));
          expect(current.top, closeTo(expected.top, 0.01));
          expect(current.right, closeTo(expected.right, 0.01));
          expect(current.bottom, closeTo(expected.bottom, 0.01));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final vertical in [true, false]) {
    for (final nested in [false, true]) {
      testWidgets(
        'Material FAB keeps its page-local anchor while pushing and popping '
        '(vertical: $vertical, nested: $nested)',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = _size;
          addTearDown(tester.view.reset);
          final navigator = GlobalKey<NavigatorState>();
          final visible = ValueNotifier(true);
          addTearDown(visible.dispose);
          await tester.pumpWidget(
            _host(
              navigator: navigator,
              vertical: vertical,
              nested: nested,
              showFab: visible,
            ),
          );
          await tester.pumpAndSettle();
          final expected = _localFabRect(tester, 'home');
          final expectedRight = vertical ? 450.0 : 366.0;
          expect(expected.right, closeTo(expectedRight, 0.01));
          expect(
            tester.getRect(find.byKey(const ValueKey('body-home'))).right,
            closeTo(382, 0.01),
          );
          final rectangles = <Rect>[];
          navigator.currentState!.push<void>(
            MaterialPageRoute<void>(
              allowSnapshotting: false,
              builder: (_) => _FabPage(id: 'detail', showFab: visible),
            ),
          );
          await tester.pump();
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
            rectangles.add(_localFabRect(tester, 'detail'));
          }
          await tester.pumpAndSettle();
          rectangles.add(_localFabRect(tester, 'detail'));
          navigator.currentState!.pop();
          await tester.pump();
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
            rectangles.add(_localFabRect(tester, 'home'));
          }
          await tester.pumpAndSettle();
          rectangles.add(_localFabRect(tester, 'home'));
          final rightEdges = rectangles.map((rect) => rect.right).toSet();
          // Retain a readable baseline trace without relying on screenshots.
          debugPrint(
            'FAB_ROUTE vertical=$vertical nested=$nested '
            'rightEdges=$rightEdges',
          );
          for (var frame = 0; frame < rectangles.length; frame++) {
            final rect = rectangles[frame];
            expect(
              rect.right,
              closeTo(expectedRight, 0.01),
              reason: 'page-local right edge at transition frame $frame',
            );
            expect(
              rect.bottom,
              closeTo(expected.bottom, 0.01),
              reason: 'navigation reservation at transition frame $frame',
            );
            expect(rect.size.width, closeTo(expected.width, 0.01));
            expect(rect.size.height, closeTo(expected.height, 0.01));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Duo Material FAB appears directly in its complete reserved slot',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      final navigator = GlobalKey<NavigatorState>();
      final visible = ValueNotifier(false);
      addTearDown(visible.dispose);
      await tester.pumpWidget(
        _host(
          navigator: navigator,
          vertical: true,
          nested: false,
          showFab: visible,
        ),
      );
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pump();
      final rectangles = <Rect>[];
      for (var frame = 0; frame < 24; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        rectangles.add(_localFabRect(tester, 'home'));
      }
      await tester.pumpAndSettle();
      final expected = _localFabRect(tester, 'home');
      debugPrint(
        'FAB_ENTRANCE widths=${rectangles.map((r) => r.width).toSet()}',
      );
      for (var frame = 0; frame < rectangles.length; frame++) {
        expect(
          rectangles[frame],
          expected,
          reason: 'direct placement at entrance frame $frame',
        );
      }
    },
  );

  for (final viewportPadding in [
    EdgeInsets.zero,
    const EdgeInsets.fromLTRB(80, 48, 24, 60),
  ]) {
    testWidgets(
      'Duo Material route uses its final FAB slot on the first layout '
      '(viewport: $viewportPadding)',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final navigator = GlobalKey<NavigatorState>();
        final visible = ValueNotifier(true);
        addTearDown(visible.dispose);
        await tester.pumpWidget(
          _host(
            navigator: navigator,
            vertical: true,
            nested: true,
            showFab: visible,
            viewportPadding: viewportPadding,
          ),
        );
        await tester.pumpAndSettle();
        final expected = _localFabRect(tester, 'home');
        expect(
          expected.right,
          closeTo(_size.width - viewportPadding.horizontal - 16, 0.01),
        );
        navigator.currentState!.push<void>(
          MaterialPageRoute<void>(
            allowSnapshotting: false,
            builder: (_) => _FabPage(id: 'detail', showFab: visible),
          ),
        );
        // This first frame lays out the fresh Scaffold. A post-frame
        // correction must not hide its initial Safe Area fallback.
        await tester.pump();
        final first = _localFabRect(tester, 'detail');
        await tester.pumpAndSettle();
        final settled = _localFabRect(tester, 'detail');
        debugPrint(
          'FAB_FIRST_LAYOUT viewport=$viewportPadding '
          'first=$first settled=$settled',
        );
        expect(first, settled);
        expect(settled.right, closeTo(expected.right, 0.01));
        expect(settled.bottom, closeTo(expected.bottom, 0.01));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Duo Material Hero captures the final equal FAB endpoints during push/pop',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      final navigator = GlobalKey<NavigatorState>();
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      const tag = 'equal-material-fab';
      await tester.pumpWidget(
        _host(
          navigator: navigator,
          vertical: true,
          nested: false,
          showFab: visible,
          heroTag: tag,
        ),
      );
      await tester.pumpAndSettle();
      final surface = find.byWidgetPredicate(
        (widget) => widget is Material && widget.type == MaterialType.button,
      );
      final expected = tester.getRect(surface);
      navigator.currentState!.push<void>(
        MaterialPageRoute<void>(
          allowSnapshotting: false,
          builder: (_) =>
              _FabPage(id: 'detail', showFab: visible, heroTag: tag),
        ),
      );
      await tester.pump();
      final rectangles = <Rect>[];
      for (final popping in [false, true]) {
        if (popping) {
          await tester.pumpAndSettle();
          navigator.currentState!.pop();
          await tester.pump();
        }
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          // FloatingActionButton itself sits outside its internal Hero, so
          // both route widgets remain mounted while only one Material surface
          // is painted in the flight overlay.
          expect(surface, findsOneWidget);
          rectangles.add(tester.getRect(surface));
        }
      }
      await tester.pumpAndSettle();
      rectangles.add(tester.getRect(surface));
      debugPrint(
        'FAB_HERO rightEdges='
        '${rectangles.map((rect) => rect.right).toSet()}',
      );
      for (var frame = 0; frame < rectangles.length; frame++) {
        final rect = rectangles[frame];
        expect(
          rect.right,
          closeTo(expected.right, 0.01),
          reason: 'equal Hero endpoint at flight frame $frame',
        );
        expect(rect.bottom, closeTo(expected.bottom, 0.01));
        expect(rect.size.width, closeTo(expected.width, 0.01));
        expect(rect.size.height, closeTo(expected.height, 0.01));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Omitted viewport bounds shadow a known parent and retain conservative FAB positioning',
    (tester) async {
      const size = Size(600, 800);
      const safe = EdgeInsets.only(right: 96, bottom: 34);
      const obstruction = Rect.fromLTWH(520, 680, 80, 120);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      final child = _FabPage(id: 'unknown', showFab: visible);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: safe, viewPadding: safe),
            child: AdaptiveOcclusionLayout(
              geometry: IosOcclusionGeometry(
                viewBounds: Offset.zero & size,
                activeOcclusionRegions: const [obstruction],
                hasVerticalSystemBar: true,
              ),
              systemSafeArea: safe,
              cornerRadii: BorderRadius.zero,
              child: OcclusionViewport(
                bounds: const Rect.fromLTWH(300, 400, 300, 400),
                child: OcclusionViewport(child: child!),
              ),
            ),
          ),
          home: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(width: 300, height: 400, child: child),
          ),
        ),
      );
      final finder = find.byKey(const ValueKey('fab-unknown'));
      final rectangles = <Rect>[tester.getRect(finder)];
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        rectangles.add(tester.getRect(finder));
      }
      debugPrint(
        'FAB_UNKNOWN '
        'rightEdges=${rectangles.map((rect) => rect.right).toSet()} '
        'overlap=${rectangles.map((rect) => rect.overlaps(obstruction)).toSet()}',
      );
      for (var frame = 0; frame < rectangles.length; frame++) {
        final rect = rectangles[frame];
        expect(rect.overlaps(obstruction), isFalse);
        expect(
          rect.right,
          closeTo(size.width - safe.right - 16, 0.01),
          reason:
              'unknown origin must retain original protection at '
              'frame $frame',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
