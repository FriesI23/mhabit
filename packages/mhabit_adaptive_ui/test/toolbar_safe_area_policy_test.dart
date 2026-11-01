import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart'
    show AdaptiveOcclusionLayout, AdaptiveOcclusionScope;
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_toolbar.dart';

const _size = Size(678, 466);
const _rightColumn = Rect.fromLTWH(608, 2.333333, 44, 381.666667);
const _leftColumn = Rect.fromLTWH(26, 2.333333, 44, 381.666667);
const _safe = EdgeInsets.only(right: 84, bottom: 34);

class _Readout {
  MediaQueryData? toolbar;
  MediaQueryData? body;
}

IosOcclusionGeometry _geometry({
  Rect? column = _rightColumn,
  List<Rect> regions = const [],
  bool vertical = true,
  Size size = _size,
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & size,
  activeOcclusionRegions: regions,
  hasVerticalSystemBar: vertical,
  verticalBarLayoutFrame: column,
);

Widget _host(
  _Readout readout, {
  required IosOcclusionGeometry? geometry,
  EdgeInsets safeArea = _safe,
  EdgeInsets? padding,
  EdgeInsets? viewPadding,
  EdgeInsets outer = EdgeInsets.zero,
  double rowTop = 16,
  BorderRadius corners = BorderRadius.zero,
  TextDirection direction = TextDirection.ltr,
  bool windowControls = false,
  bool preserve = true,
  bool scaled = false,
  bool declareBounds = true,
  Widget? toolbarChild,
}) => MaterialApp(
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: padding ?? safeArea,
      viewPadding: viewPadding ?? safeArea,
    ),
    child: AdaptiveOcclusionLayout(
      geometry: geometry,
      systemSafeArea: safeArea,
      cornerRadii: corners,
      hasWindowControls: windowControls,
      child: Directionality(textDirection: direction, child: navigator!),
    ),
  ),
  home: Builder(
    builder: (context) {
      readout.body = MediaQuery.of(context);
      final content = Builder(
        builder: (context) {
          readout.toolbar = MediaQuery.of(context);
          return toolbarChild ?? const SizedBox.expand();
        },
      );
      final toolbar = !declareBounds || scaled
          ? AdaptiveOcclusionToolbar(
              preserveHorizontalSafeArea: preserve,
              child: content,
            )
          : AdaptiveOcclusionToolbar(
              bounds: Rect.fromLTWH(
                outer.left,
                rowTop,
                _size.width - outer.horizontal,
                44,
              ),
              preserveHorizontalSafeArea: preserve,
              child: content,
            );
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
            top: rowTop,
            left: outer.left,
            right: outer.right,
          ),
          child: SizedBox(
            height: 44,
            child: scaled
                ? Transform.scale(scale: 0.9, child: toolbar)
                : toolbar,
          ),
        ),
      );
    },
  ),
);

void main() {
  Future<void> configure(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _size;
    addTearDown(tester.view.reset);
  }

  testWidgets('declared toolbar applies precise insets on its first layout', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(_host(readout, geometry: _geometry()));
    expect(readout.toolbar!.padding.right, 26);
    expect(readout.body!.padding, _safe);
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('unknown toolbar retains Safe Area after settling', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(readout, geometry: _geometry(), declareBounds: false),
    );
    expect(readout.toolbar!.padding, _safe);
    await tester.pumpAndSettle();
    expect(readout.toolbar!.padding, _safe);
  });

  testWidgets('native invalidation and restoration use current geometry', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(_host(readout, geometry: _geometry()));
    expect(readout.toolbar!.padding.right, 26);
    await tester.pumpWidget(_host(readout, geometry: null));
    expect(readout.toolbar!.padding, _safe);
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(regions: const [Rect.fromLTWH(580, 0, 98, 100)]),
      ),
    );
    expect(readout.toolbar!.padding.right, 98);
    expect(readout.body!.padding, _safe);
  });

  testWidgets(
    'unknown and declared bounds preserve the focused toolbar child',
    (tester) async {
      await configure(tester);
      final readout = _Readout();
      final controller = TextEditingController(text: 'kept query');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      Widget host(bool declared) => _host(
        readout,
        geometry: _geometry(),
        declareBounds: declared,
        toolbarChild: TextField(controller: controller, focusNode: focusNode),
      );

      await tester.pumpWidget(host(false));
      expect(readout.toolbar!.padding, _safe);
      focusNode.requestFocus();
      await tester.pump();
      final editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      for (final declared in [true, false]) {
        await tester.pumpWidget(host(declared));
        expect(readout.toolbar!.padding.right, declared ? 26 : _safe.right);
        expect(
          tester.state<EditableTextState>(find.byType(EditableText)),
          same(editableState),
        );
        expect(controller.text, 'kept query');
        expect(focusNode.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('updated declared width applies without a measurement frame', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(),
        outer: const EdgeInsets.only(right: 48),
      ),
    );
    expect(readout.toolbar!.padding.right, 0);
    await tester.pumpWidget(_host(readout, geometry: _geometry()));
    expect(readout.toolbar!.padding.right, 26);
    expect(readout.body!.padding, _safe);
    expect(tester.takeException(), isNull);
  });

  for (final direction in TextDirection.values) {
    for (final left in [false, true]) {
      testWidgets(
        'system column reclaims its physical side in $direction ($left)',
        (tester) async {
          await configure(tester);
          final readout = _Readout();
          final safe = left
              ? const EdgeInsets.only(left: 84, bottom: 34)
              : _safe;
          await tester.pumpWidget(
            _host(
              readout,
              geometry: _geometry(column: left ? _leftColumn : _rightColumn),
              safeArea: safe,
              direction: direction,
            ),
          );
          await tester.pumpAndSettle();
          expect(readout.toolbar!.padding.left, left ? 26 : 0);
          expect(readout.toolbar!.padding.right, left ? 0 : 26);
          expect(readout.toolbar!.padding.bottom, 34);
          expect(readout.body!.padding, safe);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'available native column is used automatically without body changes',
    (tester) async {
      await configure(tester);
      final readout = _Readout();
      final geometry = _geometry();
      await tester.pumpWidget(
        _host(readout, geometry: _geometry(column: null)),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding, _safe);
      await tester.pumpWidget(_host(readout, geometry: geometry));
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding.right, 26);
      expect(readout.body!.padding, _safe);
    },
  );

  final unsuitable = <String, Rect?>{
    'missing': null,
    'empty': Rect.zero,
    'outside view': const Rect.fromLTWH(608, -1, 44, 385),
    'crosses center': const Rect.fromLTWH(320, 0, 44, 384),
    'starts below row': const Rect.fromLTWH(608, 20, 44, 364),
    'ends within row': const Rect.fromLTWH(608, 0, 44, 50),
    'nonfinite': const Rect.fromLTWH(double.nan, 0, 44, 384),
  };
  for (final entry in unsuitable.entries) {
    testWidgets('${entry.key} column retains complete horizontal protection', (
      tester,
    ) async {
      await configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(
        _host(readout, geometry: _geometry(column: entry.value)),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding, _safe);
    });
  }

  testWidgets(
    'UIKit and Flutter rounding at the same edge permits reclamation',
    (tester) async {
      await configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(
        _host(
          readout,
          geometry: _geometry(
            column: const Rect.fromLTRB(
              608,
              2.3333333333333428,
              652,
              46.33333333333333,
            ),
          ),
          rowTop: 2.333333333333333,
        ),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding.right, 26);
    },
  );

  testWidgets(
    'meaningful overlap beyond the column boundary retains safe area',
    (tester) async {
      await configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(
        _host(
          readout,
          geometry: _geometry(
            column: const Rect.fromLTWH(608, 2.343333333333333, 44, 381),
          ),
          rowTop: 2.333333333333333,
        ),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding.right, 84);
    },
  );

  testWidgets('inner status row remains protected even with empty occlusions', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(column: const Rect.fromLTWH(608, 124, 44, 308)),
      ),
    );
    await tester.pumpAndSettle();
    expect(readout.toolbar!.padding.right, 84);
  });

  testWidgets('actual occlusion wins over a reclaimed system column', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(regions: const [Rect.fromLTWH(580, 0, 98, 100)]),
      ),
    );
    await tester.pumpAndSettle();
    expect(readout.toolbar!.padding.right, 98);
  });

  testWidgets('corner and independent consumer padding remain protected', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(),
        corners: const BorderRadius.all(Radius.circular(100)),
        padding: const EdgeInsets.only(right: 140, bottom: 34),
        viewPadding: const EdgeInsets.only(right: 160, bottom: 34),
      ),
    );
    await tester.pumpAndSettle();
    expect(readout.toolbar!.padding.right, 56);
    expect(readout.toolbar!.viewPadding.right, 76);
    expect(readout.body!.padding.right, 140);
    expect(readout.body!.viewPadding.right, 160);
  });

  testWidgets('column clearance never adds more than the existing safe area', (
    tester,
  ) async {
    await configure(tester);
    final readout = _Readout();
    await tester.pumpWidget(
      _host(
        readout,
        geometry: _geometry(),
        safeArea: const EdgeInsets.only(right: 10, bottom: 34),
      ),
    );
    await tester.pumpAndSettle();
    expect(readout.toolbar!.padding.right, 10);
  });

  for (final inset in [48.0, 120.0]) {
    testWidgets(
      'local column uses only its own remaining clearance at $inset',
      (tester) async {
        await configure(tester);
        final readout = _Readout();
        await tester.pumpWidget(
          _host(
            readout,
            geometry: _geometry(),
            outer: EdgeInsets.only(right: inset),
          ),
        );
        await tester.pumpAndSettle();
        expect(readout.toolbar!.padding.right, 0);
      },
    );
  }

  for (final fallback in [
    'ordinary',
    'stale',
    'window controls',
    'unknown map',
  ]) {
    testWidgets('$fallback keeps legacy toolbar safe area', (tester) async {
      await configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(
        _host(
          readout,
          geometry: _geometry(
            vertical: fallback != 'ordinary',
            size: fallback == 'stale' ? const Size(677, 466) : _size,
          ),
          windowControls: fallback == 'window controls',
          scaled: fallback == 'unknown map',
        ),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding, _safe);
    });
  }

  testWidgets(
    'floating consumer opt-out remains independent of toolbar policy',
    (tester) async {
      await configure(tester);
      final readout = _Readout();
      await tester.pumpWidget(
        _host(readout, geometry: _geometry(column: null), preserve: false),
      );
      await tester.pumpAndSettle();
      expect(readout.toolbar!.padding.right, 0);
      expect(readout.body!.padding, _safe);
    },
  );

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    testWidgets(
      '$platform keeps standard toolbar padding without configuration',
      (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          IosOcclusionGeometry? geometry;
          MediaQueryData? toolbar;
          var foundScope = false;
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(padding: _safe),
                child: child!,
              ),
              home: AdaptiveWindowControlLayout(
                child: AdaptiveOcclusionToolbar(
                  child: Builder(
                    builder: (context) {
                      final scope = AdaptiveOcclusionScope.maybeOf(context);
                      foundScope = scope != null;
                      geometry = scope?.geometry;
                      toolbar = MediaQuery.of(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(foundScope, isTrue);
          expect(geometry, isNull);
          expect(toolbar!.padding, _safe);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  }
}
