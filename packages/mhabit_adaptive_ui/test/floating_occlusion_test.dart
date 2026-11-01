import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

const _size = Size(600, 800);
const _safe = EdgeInsets.only(right: 96, bottom: 34);
const _fab = ValueKey('fab');

Widget _host({
  IosOcclusionGeometry? geometry,
  EdgeInsets outer = EdgeInsets.zero,
  EdgeInsets keyboard = EdgeInsets.zero,
  TextDirection direction = TextDirection.ltr,
  bool extended = false,
  bool declareViewport = true,
  Rect? viewportBounds,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: _size,
      padding: _safe,
      viewPadding: _safe,
      viewInsets: keyboard,
    ),
    child: AdaptiveOcclusionLayout(
      geometry: geometry,
      systemSafeArea: _safe,
      cornerRadii: BorderRadius.zero,
      child: OcclusionViewport(
        bounds: declareViewport
            ? viewportBounds ??
                  Rect.fromLTRB(
                    outer.left,
                    outer.top,
                    _size.width - outer.right,
                    _size.height - outer.bottom,
                  )
            : null,
        child: Directionality(
          textDirection: direction,
          child: Padding(
            padding: outer,
            child: Builder(
              builder: (context) => Scaffold(
                floatingActionButtonAnimator:
                    AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(
                      context,
                    ),
                body: const SafeArea(
                  child: SizedBox.expand(key: ValueKey('body')),
                ),
                floatingActionButtonLocation:
                    AdaptiveOcclusionFabLocation.resolveOf(context),
                floatingActionButton: extended
                    ? FloatingActionButton.extended(
                        key: _fab,
                        onPressed: () {},
                        label: const Text('Create a new habit'),
                      )
                    : FloatingActionButton(
                        key: _fab,
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

IosOcclusionGeometry _geometry(List<Rect> regions, {Size size = _size}) =>
    IosOcclusionGeometry(
      viewBounds: Offset.zero & size,
      activeOcclusionRegions: regions,
      hasVerticalSystemBar: true,
    );

class _CustomFabLocation extends FloatingActionButtonLocation {
  const _CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) =>
      const Offset(17, 29);
}

void main() {
  testWidgets(
    'ordinary and invalid scopes preserve the supplied FAB location',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      const fallbackLocation = _CustomFabLocation();
      for (final geometry in <IosOcclusionGeometry?>[
        null,
        IosOcclusionGeometry(
          viewBounds: Offset.zero & _size,
          activeOcclusionRegions: const [],
          hasVerticalSystemBar: false,
        ),
        _geometry([], size: const Size(800, 600)),
      ]) {
        late FloatingActionButtonLocation location;
        await tester.pumpWidget(
          AdaptiveOcclusionLayout(
            geometry: geometry,
            systemSafeArea: _safe,
            cornerRadii: BorderRadius.zero,
            child: Builder(
              builder: (context) {
                location = AdaptiveOcclusionFabLocation.resolveOf(
                  context,
                  fallbackLocation: fallbackLocation,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(location, same(fallbackLocation));
      }
    },
  );

  for (final direction in TextDirection.values) {
    testWidgets(
      'FAB uses physical free side in $direction with body unchanged',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _host(
            geometry: _geometry([const Rect.fromLTWH(520, 0, 80, 72)]),
            direction: direction,
          ),
        );
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byKey(_fab));
        expect(
          direction == TextDirection.ltr ? rect.right : rect.left,
          closeTo(direction == TextDirection.ltr ? 584 : 16, 0.001),
        );
        expect(tester.getRect(find.byKey(const ValueKey('body'))).right, 504);
        final y = rect.top;
        await tester.pumpWidget(_host(direction: direction));
        await tester.pumpAndSettle();
        final original = tester.getRect(find.byKey(_fab));
        expect(original.top, y);
        expect(
          direction == TextDirection.ltr ? original.right : original.left,
          closeTo(direction == TextDirection.ltr ? 488 : 16, 0.001),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('declared inset Scaffold maps its extended FAB width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    const obstruction = Rect.fromLTWH(520, 680, 80, 120);
    await tester.pumpWidget(
      _host(
        geometry: _geometry([obstruction]),
        outer: const EdgeInsets.only(left: 120),
        extended: true,
      ),
    );
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byKey(_fab));
    expect(rect.right, 504);
    expect(rect.overlaps(obstruction), isFalse);
    expect(rect.left, greaterThan(120));
    expect(tester.takeException(), isNull);
  });
  testWidgets('unknown local viewport retains the original FAB placement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        geometry: _geometry([const Rect.fromLTWH(520, 680, 80, 120)]),
        outer: const EdgeInsets.only(left: 120),
        extended: true,
        declareViewport: false,
      ),
    );
    expect(tester.getRect(find.byKey(_fab)).right, 488);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_fab)).right, 488);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mismatched declared viewport retains the original FAB placement',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          geometry: _geometry([const Rect.fromLTWH(520, 680, 80, 120)]),
          outer: const EdgeInsets.only(left: 120),
          viewportBounds: const Rect.fromLTWH(120, 0, 479, 800),
        ),
      );
      expect(tester.getRect(find.byKey(_fab)).right, 488);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_fab)).right, 488);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('same-size pane origin updates its FAB in the current layout', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    final geometry = _geometry([const Rect.fromLTWH(520, 680, 80, 120)]);
    await tester.pumpWidget(
      _host(geometry: geometry, outer: const EdgeInsets.only(left: 120)),
    );
    expect(tester.getRect(find.byKey(_fab)).right, 504);
    await tester.pumpWidget(
      _host(geometry: geometry, outer: const EdgeInsets.only(right: 120)),
    );
    expect(tester.getRect(find.byKey(_fab)).right, 464);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_fab)).right, 464);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard vertical placement is delegated', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    const keyboard = EdgeInsets.only(bottom: 300);
    await tester.pumpWidget(_host(keyboard: keyboard));
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_fab));
    await tester.pumpWidget(_host(keyboard: keyboard, geometry: _geometry([])));
    await tester.pumpAndSettle();
    final updated = tester.getRect(find.byKey(_fab));
    expect(updated.top, original.top);
    expect(updated.right, 584);
    expect(updated.bottom, lessThan(500));
  });
  testWidgets(
    'lower obstruction moves FAB up; invalid size restores old layout',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      const lower = Rect.fromLTWH(0, 650, 600, 150);
      await tester.pumpWidget(_host(geometry: _geometry([lower])));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_fab)).bottom, 650);
      await tester.pumpWidget(
        _host(geometry: _geometry([], size: const Size(800, 600))),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_fab)).right, 488);
      expect(tester.takeException(), isNull);
    },
  );
}
