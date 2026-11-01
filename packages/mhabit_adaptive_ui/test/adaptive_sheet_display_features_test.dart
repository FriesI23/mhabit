import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

import 'harness/adaptive_ui_theme.dart';

const _bodyKey = ValueKey('sheet-display-feature-body');

DisplayFeature _feature(Rect bounds, DisplayFeatureType type) => DisplayFeature(
  bounds: bounds,
  type: type,
  state: type == DisplayFeatureType.cutout
      ? DisplayFeatureState.unknown
      : DisplayFeatureState.postureHalfOpened,
);

MediaQueryData _geometry(
  Size size, [
  List<DisplayFeature> features = const [],
]) => MediaQueryData(size: size, displayFeatures: features);

Future<void> _mount(
  WidgetTester tester, {
  required AdaptiveStyle style,
  required ValueNotifier<MediaQueryData> geometry,
  required WidgetBuilder home,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = geometry.value.size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => ValueListenableBuilder<MediaQueryData>(
        valueListenable: geometry,
        builder: (_, data, _) => MediaQuery(
          data: data,
          child: Directionality(
            textDirection: direction,
            child: TestAdaptiveUiTheme(
              update: (theme) => theme.copyWith(style: style),
              child: child!,
            ),
          ),
        ),
      ),
      home: Builder(builder: home),
    ),
  );
}

Future<void> _open(
  BuildContext context,
  WidgetBuilder body, {
  AdaptiveModalPresentation? presentation,
}) => showAdaptiveSheet<void>(
  context: context,
  presentationOverride: presentation,
  showDragHandle: false,
  builder: (context) =>
      AdaptiveModal(title: const Text('Editor'), body: body(context)),
);

AdaptiveModalPresentation _presentation(
  WidgetTester tester,
  AdaptiveStyle style,
) => switch (style) {
  AdaptiveStyle.material =>
    tester
        .widget<MaterialAdaptiveModalRouteSurface>(
          find.byType(MaterialAdaptiveModalRouteSurface),
        )
        .presentation,
  AdaptiveStyle.apple =>
    tester
        .widget<CupertinoAdaptiveModalRouteSurface>(
          find.byType(CupertinoAdaptiveModalRouteSurface),
        )
        .presentation,
};

void _expectContained(Rect actual, Rect region, {String? reason}) {
  expect(actual.left, greaterThanOrEqualTo(region.left - 0.1), reason: reason);
  expect(actual.top, greaterThanOrEqualTo(region.top - 0.1), reason: reason);
  expect(actual.right, lessThanOrEqualTo(region.right + 0.1), reason: reason);
  expect(actual.bottom, lessThanOrEqualTo(region.bottom + 0.1), reason: reason);
}

class _Draft extends StatefulWidget {
  const _Draft();

  @override
  State<_Draft> createState() => _DraftState();
}

class _DraftState extends State<_Draft> {
  final controller = TextEditingController();
  final focus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(key: _bodyKey, controller: controller, focusNode: focus),
        TextButton(
          onPressed: () => AdaptiveModalNavigator.pop(context, controller.text),
          child: const Text('Save draft'),
        ),
      ],
    ),
  );
}

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final fixed in [false, true]) {
      for (final type in [DisplayFeatureType.fold, DisplayFeatureType.hinge]) {
        testWidgets(
          '$style ${fixed ? 'fixed' : 'auto'} sheet uses the whole window across a horizontal $type',
          (tester) async {
            const size = Size(500, 1000);
            final geometry = ValueNotifier(
              _geometry(size, [
                _feature(const Rect.fromLTWH(0, 300, 500, 20), type),
              ]),
            );
            addTearDown(geometry.dispose);
            Size? localSize;
            List<DisplayFeature>? localFeatures;
            await _mount(
              tester,
              style: style,
              geometry: geometry,
              home: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => _open(
                    context,
                    (context) {
                      localSize = MediaQuery.sizeOf(context);
                      localFeatures = MediaQuery.displayFeaturesOf(context);
                      return const SizedBox(
                        key: _bodyKey,
                        width: 120,
                        height: 40,
                      );
                    },
                    presentation: fixed
                        ? AdaptiveModalPresentation.sheet
                        : null,
                  ),
                  child: const Text('Open'),
                ),
              ),
            );
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            // The native Cupertino sheet retains its existing 8% top gap.
            // No horizontal fold may reduce either route's available height.
            final expected = fixed && style == AdaptiveStyle.apple
                ? const Size(500, 920)
                : size;
            expect(localSize, expected);
            expect(localFeatures, isEmpty);
            _expectContained(
              tester.getRect(find.byKey(_bodyKey)),
              Offset.zero & size,
            );
            expect(
              find
                  .byType(ModalBarrier)
                  .evaluate()
                  .map(
                    (element) => tester.getRect(find.byWidget(element.widget)),
                  )
                  .any((bounds) => bounds == Offset.zero & size),
              isTrue,
            );
            if (!fixed) {
              expect(
                _presentation(tester, style),
                AdaptiveModalPresentation.sheet,
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }

      testWidgets(
        '$style ${fixed ? 'fixed' : 'auto'} dialog still chooses the upper pane',
        (tester) async {
          final size = Size(fixed ? 500 : 1000, 1000);
          final geometry = ValueNotifier(
            _geometry(size, [
              _feature(
                Rect.fromLTWH(0, 300, size.width, 20),
                DisplayFeatureType.fold,
              ),
            ]),
          );
          addTearDown(geometry.dispose);
          Size? localSize;
          await _mount(
            tester,
            style: style,
            geometry: geometry,
            home: (context) => Scaffold(
              body: TextButton(
                onPressed: () => _open(
                  context,
                  (context) {
                    localSize = MediaQuery.sizeOf(context);
                    return const SizedBox(
                      key: _bodyKey,
                      width: 120,
                      height: 40,
                    );
                  },
                  presentation: fixed ? AdaptiveModalPresentation.dialog : null,
                ),
                child: const Text('Open'),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(localSize, Size(size.width, 300));
          _expectContained(
            tester.getRect(find.byKey(_bodyKey)),
            Rect.fromLTWH(0, 0, size.width, 300),
          );
          if (!fixed) {
            // Global window breakpoints still determine the presentation.
            expect(
              _presentation(tester, style),
              AdaptiveModalPresentation.dialog,
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final direction in TextDirection.values) {
      testWidgets('$style $direction sheet preserves vertical-fold selection', (
        tester,
      ) async {
        const size = Size(500, 1000);
        final geometry = ValueNotifier(
          _geometry(size, [
            _feature(
              const Rect.fromLTWH(190, 0, 20, 1000),
              DisplayFeatureType.fold,
            ),
          ]),
        );
        addTearDown(geometry.dispose);
        Size? localSize;
        await _mount(
          tester,
          style: style,
          direction: direction,
          geometry: geometry,
          home: (context) => Scaffold(
            body: TextButton(
              onPressed: () => _open(context, (context) {
                localSize = MediaQuery.sizeOf(context);
                return const SizedBox(key: _bodyKey, width: 80, height: 40);
              }),
              child: const Text('Open'),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final region = direction == TextDirection.ltr
            ? const Rect.fromLTWH(0, 0, 190, 1000)
            : const Rect.fromLTWH(210, 0, 290, 1000);
        expect(localSize, region.size);
        _expectContained(tester.getRect(find.byKey(_bodyKey)), region);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('$style sheet removes horizontal folds but preserves cutouts', (
      tester,
    ) async {
      const size = Size(500, 1000);
      final cutout = _feature(
        const Rect.fromLTWH(200, 0, 100, 24),
        DisplayFeatureType.cutout,
      );
      final geometry = ValueNotifier(
        _geometry(size, [
          _feature(
            const Rect.fromLTWH(0, 300, 500, 20),
            DisplayFeatureType.fold,
          ),
          _feature(
            const Rect.fromLTWH(0, 600, 500, 20),
            DisplayFeatureType.hinge,
          ),
          cutout,
        ]),
      );
      addTearDown(geometry.dispose);
      MediaQueryData? local;
      await _mount(
        tester,
        style: style,
        geometry: geometry,
        home: (context) => Scaffold(
          body: TextButton(
            onPressed: () => _open(context, (context) {
              local = MediaQuery.of(context);
              return const SizedBox(key: _bodyKey, width: 120, height: 40);
            }),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(local!.size, size);
      expect(local!.displayFeatures, [cutout]);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$style changing sheet and dialog partitions retains navigation',
      (tester) async {
        const narrow = Size(500, 1000);
        const wide = Size(1000, 1000);
        final geometry = ValueNotifier(_geometry(narrow));
        addTearDown(geometry.dispose);
        String? result;
        await _mount(
          tester,
          style: style,
          geometry: geometry,
          home: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showAdaptiveSheet<String>(
                  context: context,
                  showDragHandle: false,
                  builder: (_) => AdaptiveModalNavigator<String>(
                    size: const AdaptiveModalSize.constrained(maxHeight: 720),
                    builder: (_) => AdaptiveModal(
                      title: const Text('First page'),
                      body: Builder(
                        builder: (context) => TextButton(
                          onPressed: () => Navigator.of(context).push<void>(
                            adaptiveModalPageRoute<void>(
                              context: context,
                              builder: (_) => const AdaptiveModal(
                                title: Text('Second page'),
                                body: _Draft(),
                              ),
                            ),
                          ),
                          child: const Text('Next page'),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next page'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(_bodyKey), 'Unfinished draft');
        final draft = tester.state<_DraftState>(find.byType(_Draft));
        final navigator = Navigator.of(draft.context);
        final route = ModalRoute.of(draft.context);
        final outerRoute = ModalRoute.of(navigator.context);
        expect(navigator.canPop(), isTrue);

        void expectState(Size viewport, String phase) {
          expect(tester.state<_DraftState>(find.byType(_Draft)), same(draft));
          expect(Navigator.of(draft.context), same(navigator));
          expect(ModalRoute.of(draft.context), same(route));
          expect(ModalRoute.of(navigator.context), same(outerRoute));
          expect(navigator.canPop(), isTrue);
          expect(draft.controller.text, 'Unfinished draft');
          expect(draft.focus.hasFocus, isTrue);
          expect(MediaQuery.sizeOf(draft.context), viewport, reason: phase);
          expect(tester.takeException(), isNull, reason: phase);
        }

        for (final step in [
          (narrow, true, narrow, AdaptiveModalPresentation.sheet),
          (wide, true, const Size(1000, 300), AdaptiveModalPresentation.dialog),
          (wide, false, wide, AdaptiveModalPresentation.dialog),
          (narrow, false, narrow, AdaptiveModalPresentation.sheet),
        ]) {
          tester.view.physicalSize = step.$1;
          geometry.value = _geometry(step.$1, [
            if (step.$2)
              _feature(
                Rect.fromLTWH(0, 300, step.$1.width, 20),
                DisplayFeatureType.fold,
              ),
          ]);
          await tester.pump();
          expectState(step.$3, 'first frame: ${step.$4} folded=${step.$2}');
          expect(_presentation(tester, style), step.$4);
          await tester.pumpAndSettle();
          expectState(step.$3, 'settled frame: ${step.$4} folded=${step.$2}');
          _expectContained(
            tester.getRect(find.byKey(_bodyKey)),
            Offset.zero & step.$3,
          );
        }
        await tester.tap(find.text('Save draft'));
        await tester.pumpAndSettle();
        expect(result, 'Unfinished draft');
        expect(find.byType(_Draft), findsNothing);
      },
    );
  }
}
