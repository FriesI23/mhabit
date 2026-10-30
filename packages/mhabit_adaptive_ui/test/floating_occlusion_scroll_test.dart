import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import 'harness/adaptive_ui_theme.dart';

const _surface = ValueKey('cupertino-primary-action-surface');
const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home),
      materialSelected: Icon(Icons.home),
      apple: Icon(CupertinoIcons.house),
      appleSelected: Icon(CupertinoIcons.house_fill),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.today),
      materialSelected: Icon(Icons.today),
      apple: Icon(CupertinoIcons.today),
      appleSelected: Icon(CupertinoIcons.today_fill),
    ),
  ),
];

Widget _host(
  ValueNotifier<IosOcclusionGeometry?> geometry,
  ScrollController scroll,
) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: const EdgeInsets.only(right: 84, bottom: 34),
      viewPadding: const EdgeInsets.only(right: 84, bottom: 34),
    ),
    child: AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: EdgeInsets.zero,
      verticalAvoidance: EdgeInsets.zero,
      owner: WindowControlLayoutOwner.appBar,
      child: ValueListenableBuilder<IosOcclusionGeometry?>(
        valueListenable: geometry,
        child: navigator,
        builder: (context, value, child) => AdaptiveOcclusionLayout(
          geometry: value,
          systemSafeArea: const EdgeInsets.only(right: 84, bottom: 34),
          cornerRadii: BorderRadius.zero,
          child: OcclusionViewport(
            bounds: Offset.zero & MediaQuery.sizeOf(context),
            child: child!,
          ),
        ),
      ),
    ),
  ),
  home: TestAdaptiveUiTheme(
    update: (t) => t.copyWith(style: AdaptiveStyle.apple),
    child: AdaptiveNavigationShell(
      selectedIndex: 0,
      destinations: _destinations,
      onDestinationSelected: (_) {},
      applePrimaryAction: CupertinoNavigationPrimaryAction(
        id: 'scroll-action',
        label: 'New Habit',
        icon: const Icon(CupertinoIcons.add),
        onPressed: () {},
      ),
      child: Scaffold(
        body: ListView.builder(
          key: const ValueKey('scroll-occlusion-list'),
          controller: scroll,
          itemCount: 100,
          itemExtent: 60,
          itemBuilder: (context, index) => Text('Habit $index'),
        ),
      ),
    ),
  ),
);

Rect _barFrame(Size size) =>
    Rect.fromLTRB(size.width - 70, 124, size.width - 26, size.height - 34);

IosOcclusionGeometry _geometry(Size size, {double height = 124}) =>
    IosOcclusionGeometry(
      viewBounds: Offset.zero & size,
      activeOcclusionRegions: [Rect.fromLTWH(size.width - 84, 0, 84, height)],
      hasVerticalSystemBar: true,
      verticalBarLayoutFrame: _barFrame(size),
    );

const _materialFab = ValueKey('scroll-material-fab');
Widget _materialHost(
  ValueNotifier<IosOcclusionGeometry?> geometry,
  ValueNotifier<bool> visible,
) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: const EdgeInsets.only(right: 84, bottom: 34),
      viewPadding: const EdgeInsets.only(right: 84, bottom: 34),
    ),
    child: ValueListenableBuilder<IosOcclusionGeometry?>(
      valueListenable: geometry,
      child: navigator,
      builder: (context, value, child) => AdaptiveOcclusionLayout(
        geometry: value,
        systemSafeArea: const EdgeInsets.only(right: 84, bottom: 34),
        cornerRadii: BorderRadius.zero,
        child: OcclusionViewport(
          bounds: Offset.zero & MediaQuery.sizeOf(context),
          child: child!,
        ),
      ),
    ),
  ),
  home: ValueListenableBuilder<bool>(
    valueListenable: visible,
    builder: (context, show, _) => Scaffold(
      floatingActionButtonAnimator:
          AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
      floatingActionButtonLocation: AdaptiveOcclusionFabLocation.resolveOf(
        context,
      ),
      body: const SizedBox.expand(),
      floatingActionButton: show
          ? FloatingActionButton(
              key: _materialFab,
              onPressed: () {},
              child: const Icon(Icons.add),
            )
          : null,
    ),
  ),
);

void main() {
  for (final size in [const Size(466, 678), const Size(951, 669)]) {
    testWidgets('Apple primary action remains visible during scroll at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry(size));
      addTearDown(geometry.dispose);
      await tester.pumpWidget(_host(geometry, scroll));
      await tester.pumpAndSettle();
      final expectedCenter = _barFrame(size).center.dx;
      expect(
        tester.getRect(find.byKey(_surface)).center.dx,
        closeTo(expectedCenter, 0.01),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('scroll-occlusion-list'))),
      );
      for (var i = 0; i < 30; i++) {
        await gesture.moveBy(
          const Offset(0, -6),
          timeStamp: Duration(milliseconds: (i + 1) * 16),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final action = tester.getRect(find.byKey(_surface));
        expect(
          action.width,
          greaterThanOrEqualTo(43.9),
          reason: 'scroll frame $i',
        );
        expect(
          action.center.dx,
          closeTo(expectedCenter, 0.01),
          reason: 'center column at scroll frame $i',
        );
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(_surface)).width,
        closeTo(size.width < 600 ? 44 : 50, 0.01),
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Top-only system occlusion updates do not pulse the bottom action',
    (tester) async {
      const size = Size(951, 669);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry(size));
      addTearDown(geometry.dispose);
      await tester.pumpWidget(_host(geometry, scroll));
      await tester.pumpAndSettle();
      final originalCenter = tester.getRect(find.byKey(_surface)).center.dx;
      geometry.value = _geometry(size, height: 125);
      var minimumWidth = 50.0;
      for (var i = 0; i < 30; i++) {
        scroll.jumpTo(i * 18);
        await tester.pump(const Duration(milliseconds: 16));
        final action = tester.getRect(find.byKey(_surface));
        final width = action.width;
        if (width < minimumWidth) minimumWidth = width;
        expect(action.center.dx, closeTo(originalCenter, 0.01));
      }
      expect(minimumWidth, greaterThanOrEqualTo(49.9));
    },
  );
  testWidgets(
    'Occlusion invalidation and lower-region correction keep the action visible',
    (tester) async {
      const size = Size(951, 669);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry(size));
      addTearDown(geometry.dispose);
      await tester.pumpWidget(_host(geometry, scroll));
      await tester.pumpAndSettle();
      for (final value in <IosOcclusionGeometry?>[
        null,
        _geometry(size),
        IosOcclusionGeometry(
          viewBounds: Offset.zero & size,
          activeOcclusionRegions: const [Rect.fromLTWH(867, 540, 84, 129)],
          hasVerticalSystemBar: true,
          verticalBarLayoutFrame: _barFrame(size),
        ),
      ]) {
        geometry.value = value;
        await tester.pump();
        for (var i = 0; i < 26; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          final rect = tester.getRect(find.byKey(_surface));
          expect(rect.width, closeTo(50, 0.001));
          for (final region in value?.activeOcclusionRegions ?? <Rect>[]) {
            expect(
              rect.overlaps(region),
              isFalse,
              reason: 'unsafe correction frame $i',
            );
          }
        }
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Precise geometry keeps Material FAB at full scale when visibility changes',
    (tester) async {
      const size = Size(951, 669);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final geometry = ValueNotifier<IosOcclusionGeometry?>(_geometry(size));
      addTearDown(geometry.dispose);
      final visible = ValueNotifier(false);
      addTearDown(visible.dispose);
      await tester.pumpWidget(_materialHost(geometry, visible));
      await tester.pumpAndSettle();
      visible.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final entering = tester.getRect(find.byKey(_materialFab)).width;
      expect(entering, closeTo(56, 0.001));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(_materialFab)).width,
        closeTo(56, 0.001),
      );
      visible.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final leaving = tester.getRect(find.byKey(_materialFab)).width;
      expect(leaving, closeTo(56, 0.001));
      await tester.pumpAndSettle();
      expect(find.byKey(_materialFab), findsNothing);
    },
  );
  testWidgets(
    'Devices without precise geometry retain Scaffold default motion policy',
    (tester) async {
      const size = Size(951, 669);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final geometry = ValueNotifier<IosOcclusionGeometry?>(null);
      addTearDown(geometry.dispose);
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      await tester.pumpWidget(_materialHost(geometry, visible));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Scaffold>(find.byType(Scaffold))
            .floatingActionButtonAnimator,
        isNull,
      );
    },
  );
}
