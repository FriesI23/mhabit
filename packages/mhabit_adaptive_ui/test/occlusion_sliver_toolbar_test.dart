import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/modal_app_bar_region.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_sliver_toolbar.dart';

const _size = Size(678, 466);
const _safe = EdgeInsets.only(right: 84, bottom: 34);

class _Readout {
  MediaQueryData? toolbar;
}

IosOcclusionGeometry _geometry() => IosOcclusionGeometry(
  viewBounds: Offset.zero & _size,
  activeOcclusionRegions: const [],
  hasVerticalSystemBar: true,
  verticalBarLayoutFrame: const Rect.fromLTWH(608, 2.333333, 44, 381.666667),
);

Widget _sliverHost(
  _Readout readout, {
  required String layout,
  bool geometryAvailable = true,
}) => MaterialApp(
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: _safe,
      viewPadding: _safe,
      viewInsets: layout == 'keyboard'
          ? const EdgeInsets.only(bottom: 100)
          : EdgeInsets.zero,
    ),
    child: AdaptiveOcclusionLayout(
      geometry: geometryAvailable ? _geometry() : null,
      systemSafeArea: _safe,
      cornerRadii: BorderRadius.zero,
      child: layout == 'missing'
          ? navigator!
          : OcclusionViewport(
              bounds: layout == 'unknown' ? null : Offset.zero & _size,
              child: navigator!,
            ),
    ),
  ),
  home: Scaffold(
    body: Column(
      children: [
        if (layout == 'fixed top') const SizedBox(height: 100),
        Expanded(
          child: layout == 'modal'
              ? ModalWindowControlAppBarRegion(
                  child: _scrollView(readout, layout),
                )
              : _scrollView(readout, layout),
        ),
      ],
    ),
  ),
);

Widget _scrollView(_Readout readout, String layout) => CustomScrollView(
  reverse: layout == 'reverse',
  slivers: [
    SliverPadding(
      padding: layout == 'narrow sliver'
          ? const EdgeInsets.only(left: 120)
          : EdgeInsets.zero,
      sliver: AdaptiveSliverOcclusionToolbar(
        height: 44,
        topOffset: 16,
        child: SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              readout.toolbar = MediaQuery.of(context);
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(height: 44),
              );
            },
          ),
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 1000)),
  ],
);

void main() {
  void configure(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
  }

  for (final layout in [
    'standard',
    'fixed top',
    'narrow sliver',
    'reverse',
    'unknown',
    'missing',
    'keyboard',
    'modal',
  ]) {
    testWidgets('Sliver $layout uses only a matching declared viewport', (
      tester,
    ) async {
      configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(_sliverHost(readout, layout: layout));
      expect(readout.toolbar!.padding.right, layout == 'standard' ? 26 : 84);
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding.right, layout == 'standard' ? 26 : 84);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('native invalidation and restoration keep the declared Sliver', (
    tester,
  ) async {
    configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(_sliverHost(readout, layout: 'standard'));
    expect(readout.toolbar!.padding.right, 26);
    await tester.pumpWidget(
      _sliverHost(readout, layout: 'standard', geometryAvailable: false),
    );
    expect(readout.toolbar!.padding, _safe);
    await tester.pumpWidget(_sliverHost(readout, layout: 'standard'));
    expect(readout.toolbar!.padding.right, 26);
    expect(tester.takeException(), isNull);
  });
}
