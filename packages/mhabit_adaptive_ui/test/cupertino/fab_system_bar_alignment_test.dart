import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_primary_action.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

const _size = Size(951, 669);
const _safeArea = EdgeInsets.only(right: 84, bottom: 34);
const _rightBar = Rect.fromLTWH(881, 124, 44, 511);
const _leftBar = Rect.fromLTWH(26, 124, 44, 511);
const _surface = ValueKey('cupertino-primary-action-surface');
const _materialFab = ValueKey('material-alignment-opt-out');
const _body = ValueKey('system-bar-alignment-body');

IosOcclusionGeometry _geometry({
  Rect? frame = _rightBar,
  bool vertical = true,
  Size size = _size,
  List<Rect> regions = const [],
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & size,
  activeOcclusionRegions: regions,
  hasVerticalSystemBar: vertical,
  verticalBarLayoutFrame: frame,
);

Widget _host({
  required IosOcclusionGeometry? geometry,
  double extent = 50,
  TextDirection direction = TextDirection.ltr,
  EdgeInsets safeArea = _safeArea,
  EdgeInsets outer = EdgeInsets.zero,
  EdgeInsets gestures = EdgeInsets.zero,
  EdgeInsets keyboard = EdgeInsets.zero,
  BorderRadius corners = BorderRadius.zero,
  bool windowControls = false,
  bool material = false,
}) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: safeArea,
      viewPadding: safeArea,
      viewInsets: keyboard,
      systemGestureInsets: gestures,
    ),
    child: AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: EdgeInsets.zero,
      verticalAvoidance: EdgeInsets.zero,
      effectiveCornerRadii: corners,
      owner: WindowControlLayoutOwner.appBar,
      child: AdaptiveOcclusionLayout(
        geometry: geometry,
        systemSafeArea: safeArea,
        cornerRadii: corners,
        hasWindowControls: windowControls,
        child: OcclusionViewport(
          bounds: Rect.fromLTRB(
            outer.left,
            outer.top,
            MediaQuery.sizeOf(context).width - outer.right,
            MediaQuery.sizeOf(context).height - outer.bottom,
          ),
          child: Directionality(textDirection: direction, child: navigator!),
        ),
      ),
    ),
  ),
  home: Padding(
    padding: outer,
    child: Builder(
      builder: (context) => Scaffold(
        floatingActionButtonAnimator:
            AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
        floatingActionButtonLocation: material
            ? AdaptiveOcclusionFabLocation.resolveOf(context)
            : CupertinoNavigationPrimaryActionButton.floatingLocationOf(
                context,
              ),
        floatingActionButton: material
            ? FloatingActionButton(
                key: _materialFab,
                onPressed: () {},
                child: const Icon(Icons.add),
              )
            : CupertinoNavigationPrimaryActionButton(
                extent: extent,
                action: CupertinoNavigationPrimaryAction(
                  id: 'system-bar-aligned-action',
                  label: 'New Habit',
                  icon: const Icon(CupertinoIcons.add),
                  onPressed: () {},
                ),
              ),
        body: const SafeArea(child: SizedBox.expand(key: _body)),
      ),
    ),
  ),
);

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('native physical column fixes the center in $direction', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      final frame = direction == TextDirection.ltr ? _rightBar : _leftBar;
      final safe = direction == TextDirection.ltr
          ? _safeArea
          : const EdgeInsets.only(left: 84, bottom: 34);
      Rect? body;
      for (final extent in [50.0, 44.0, 50.0]) {
        await tester.pumpWidget(
          _host(
            geometry: _geometry(frame: frame),
            direction: direction,
            extent: extent,
            safeArea: safe,
          ),
        );
        await tester.pumpAndSettle();
        final action = tester.getRect(find.byKey(_surface));
        expect(action.width, closeTo(extent, 0.001));
        expect(action.center.dx, closeTo(frame.center.dx, 0.001));
        // UIKit's bar center differs from the Safe Area band's midpoint.
        expect(
          action.center.dx,
          isNot(direction == TextDirection.ltr ? _size.width - 42 : 42),
        );
        expect(action.bottom, _size.height - 28);
        body ??= tester.getRect(find.byKey(_body));
        expect(tester.getRect(find.byKey(_body)), body);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'ordinary landscape phone keeps exact legacy FAB in $direction',
      (tester) async {
        const landscape = Size(852, 393);
        const originalInsets = EdgeInsets.fromLTRB(59, 0, 59, 21);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = landscape;
        addTearDown(tester.view.reset);
        for (final extent in [50.0, 44.0]) {
          await tester.pumpWidget(
            _host(
              geometry: null,
              direction: direction,
              safeArea: originalInsets,
              extent: extent,
            ),
          );
          await tester.pumpAndSettle();
          final original = tester.getRect(find.byKey(_surface));
          final originalBody = tester.getRect(find.byKey(_body));
          await tester.pumpWidget(
            _host(
              geometry: _geometry(
                size: landscape,
                vertical: false,
                frame: const Rect.fromLTWH(782, 0, 44, 350),
              ),
              direction: direction,
              safeArea: originalInsets,
              extent: extent,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.getRect(find.byKey(_surface)), original);
          expect(tester.getRect(find.byKey(_body)), originalBody);
        }
      },
    );
  }

  testWidgets('RTL retains its existing edge when native column is right', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(geometry: _geometry(frame: null), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_surface));
    await tester.pumpWidget(
      _host(geometry: _geometry(), direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_surface)), original);
  });

  testWidgets('nested Scaffold uses the native root coordinate column', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(geometry: _geometry(), outer: const EdgeInsets.only(left: 200)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(_surface)).center.dx,
      closeTo(_rightBar.center.dx, 0.001),
    );
  });

  testWidgets('a local Scaffold outside the native column keeps its edge', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    const outer = EdgeInsets.only(right: 200);
    await tester.pumpWidget(
      _host(geometry: _geometry(frame: null), outer: outer),
    );
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_surface));
    await tester.pumpWidget(_host(geometry: _geometry(), outer: outer));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_surface)), original);
  });

  testWidgets('window controls retain the existing conservative placement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(geometry: null, windowControls: true));
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_surface));
    await tester.pumpWidget(_host(geometry: _geometry(), windowControls: true));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_surface)), original);
  });

  for (final invalidFrame in <Rect?>[
    null,
    Rect.zero,
    const Rect.fromLTWH(1200, 0, 44, 500),
    const Rect.fromLTWH(450, 0, 51, 500),
    const Rect.fromLTRB(double.nan, 0, 925, 635),
  ]) {
    testWidgets('unusable native frame keeps placement: $invalidFrame', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(geometry: _geometry(frame: null)));
      await tester.pumpAndSettle();
      final original = tester.getRect(find.byKey(_surface));
      await tester.pumpWidget(_host(geometry: _geometry(frame: invalidFrame)));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_surface)), original);
    });
  }

  testWidgets('alignment cannot move inward into reserved navigation space', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(geometry: _geometry(frame: null)));
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_surface));
    await tester.pumpWidget(
      _host(geometry: _geometry(frame: const Rect.fromLTWH(840, 124, 44, 511))),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_surface)), original);
  });

  for (final obstruction in [
    const Rect.fromLTWH(900, 550, 51, 119),
    const Rect.fromLTWH(0, 550, 951, 119),
  ]) {
    testWidgets('unsafe column respects actual obstruction $obstruction', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(geometry: _geometry(regions: [obstruction])),
      );
      await tester.pumpAndSettle();
      final action = tester.getRect(find.byKey(_surface));
      expect(action.overlaps(obstruction), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('gesture and rounded corner protection win over alignment', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    for (final useCorners in [false, true]) {
      final corners = useCorners
          ? const BorderRadius.only(bottomRight: Radius.circular(200))
          : BorderRadius.zero;
      final gestures = useCorners
          ? EdgeInsets.zero
          : const EdgeInsets.only(right: 28);
      await tester.pumpWidget(
        _host(
          geometry: _geometry(frame: null),
          corners: corners,
          gestures: gestures,
        ),
      );
      await tester.pumpAndSettle();
      final original = tester.getRect(find.byKey(_surface));
      await tester.pumpWidget(
        _host(geometry: _geometry(), corners: corners, gestures: gestures),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_surface)), original);
    }
  });

  testWidgets(
    'keyboard vertical placement and invalid snapshots keep fallback',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      addTearDown(tester.view.reset);
      const keyboard = EdgeInsets.only(bottom: 300);
      await tester.pumpWidget(
        _host(geometry: _geometry(frame: null), keyboard: keyboard),
      );
      await tester.pumpAndSettle();
      final original = tester.getRect(find.byKey(_surface));
      await tester.pumpWidget(_host(geometry: _geometry(), keyboard: keyboard));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_surface)).top, original.top);
      expect(
        tester.getRect(find.byKey(_surface)).center.dx,
        closeTo(_rightBar.center.dx, 0.001),
      );
      await tester.pumpWidget(
        _host(
          geometry: _geometry(size: const Size(669, 951)),
          keyboard: keyboard,
        ),
      );
      await tester.pumpAndSettle();
      final invalid = tester.getRect(find.byKey(_surface));
      await tester.pumpWidget(_host(geometry: null, keyboard: keyboard));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_surface)), invalid);
    },
  );

  testWidgets('M3 default FAB does not opt into native column alignment', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(geometry: _geometry(frame: null), material: true),
    );
    await tester.pumpAndSettle();
    final original = tester.getRect(find.byKey(_materialFab));
    await tester.pumpWidget(_host(geometry: _geometry(), material: true));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_materialFab)), original);
  });
}
