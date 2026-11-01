import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/adaptive/adaptive_modal_viewport.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

import 'harness/adaptive_ui_theme.dart';

const _bodyKey = ValueKey('pane-presentation-body');

MediaQueryData _geometry(
  Size size, {
  required Rect fold,
  DisplayFeatureType type = DisplayFeatureType.fold,
  double keyboard = 0,
}) => MediaQueryData(
  size: size,
  viewInsets: EdgeInsets.only(bottom: keyboard),
  displayFeatures: [
    DisplayFeature(
      bounds: fold,
      type: type,
      state: DisplayFeatureState.postureHalfOpened,
    ),
  ],
);

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

Finder _surface(AdaptiveStyle style) => switch (style) {
  AdaptiveStyle.material => find.byType(MaterialAdaptiveModalRouteSurface),
  AdaptiveStyle.apple => find.byType(CupertinoAdaptiveModalRouteSurface),
};

void _expectAutomaticPresentation(
  WidgetTester tester,
  AdaptiveStyle style,
  AdaptiveModalPresentation expected,
) {
  final surface = _surface(style);
  final presentation = switch (style) {
    AdaptiveStyle.material =>
      tester.widget<MaterialAdaptiveModalRouteSurface>(surface).presentation,
    AdaptiveStyle.apple =>
      tester.widget<CupertinoAdaptiveModalRouteSurface>(surface).presentation,
  };
  expect(presentation, expected);
  final filter = tester.widget<AdaptiveModalMediaQuery>(
    find
        .ancestor(of: surface, matching: find.byType(AdaptiveModalMediaQuery))
        .first,
  );
  expect(filter.isSheet, expected == AdaptiveModalPresentation.sheet);
  if (style == AdaptiveStyle.material) {
    // The outer transition and feature filter must agree with the inner
    // surface, including after a pane resize changes the presentation.
    final slides = find.ancestor(
      of: surface,
      matching: find.byType(SlideTransition),
    );
    expect(
      slides,
      expected == AdaptiveModalPresentation.sheet
          ? findsOneWidget
          : findsNothing,
    );
    if (expected == AdaptiveModalPresentation.dialog) {
      expect(
        find.ancestor(of: surface, matching: find.byType(FadeTransition)),
        findsWidgets,
      );
    }
  }
}

void _expectContained(Rect actual, Rect pane) {
  expect(actual.left, greaterThanOrEqualTo(pane.left - 0.1));
  expect(actual.right, lessThanOrEqualTo(pane.right + 0.1));
  expect(actual.top, greaterThanOrEqualTo(pane.top - 0.1));
  expect(actual.bottom, lessThanOrEqualTo(pane.bottom + 0.1));
}

Future<void> _openSimple(
  WidgetTester tester, {
  required AdaptiveStyle style,
  required MediaQueryData media,
  required Rect pane,
  required AdaptiveModalPresentation expected,
  TextDirection direction = TextDirection.ltr,
  AdaptiveModalPresentation? fixed,
}) async {
  final geometry = ValueNotifier(media);
  addTearDown(geometry.dispose);
  Size? contentSize;
  await _mount(
    tester,
    style: style,
    geometry: geometry,
    direction: direction,
    home: (context) => Scaffold(
      body: TextButton(
        onPressed: () => showAdaptiveSheet<void>(
          context: context,
          presentationOverride: fixed,
          showDragHandle: false,
          builder: (context) {
            contentSize = MediaQuery.sizeOf(context);
            return const AdaptiveModal(
              title: Text('Editor'),
              body: SizedBox(key: _bodyKey, width: 120, height: 40),
            );
          },
        ),
        child: const Text('Open'),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  if (fixed == null) {
    _expectAutomaticPresentation(tester, style, expected);
  } else if (style == AdaptiveStyle.material) {
    expect(find.byType(MaterialAdaptiveModalDialogSurface), findsOneWidget);
  } else {
    expect(
      tester
          .widget<CupertinoAdaptiveModalRouteSurface>(_surface(style))
          .presentation,
      fixed,
    );
  }
  expect(contentSize, pane.size);
  _expectContained(tester.getRect(find.byKey(_bodyKey)), pane);
  expect(tester.takeException(), isNull);
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
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style $direction uses its unequal vertical pane for auto presentation',
        (tester) async {
          final leading = direction == TextDirection.ltr;
          await _openSimple(
            tester,
            style: style,
            direction: direction,
            media: _geometry(
              const Size(1600, 900),
              fold: const Rect.fromLTWH(590, 0, 20, 900),
            ),
            pane: leading
                ? const Rect.fromLTWH(0, 0, 590, 900)
                : const Rect.fromLTWH(610, 0, 990, 900),
            expected: leading
                ? AdaptiveModalPresentation.sheet
                : AdaptiveModalPresentation.dialog,
          );
        },
      );
    }

    for (final type in [DisplayFeatureType.fold, DisplayFeatureType.hinge]) {
      for (final width in [599.0, 600.0]) {
        testWidgets(
          '$style zero-width $type respects the $width pane breakpoint',
          (tester) async {
            await _openSimple(
              tester,
              style: style,
              media: _geometry(
                const Size(1200, 900),
                fold: Rect.fromLTWH(width, 0, 0, 900),
                type: type,
              ),
              pane: Rect.fromLTWH(0, 0, width, 900),
              expected: width < 600
                  ? AdaptiveModalPresentation.sheet
                  : AdaptiveModalPresentation.dialog,
            );
          },
        );
      }
    }

    testWidgets(
      '$style RTL compact trailing pane presents a sheet on the right',
      (tester) async {
        await _openSimple(
          tester,
          style: style,
          direction: TextDirection.rtl,
          media: _geometry(
            const Size(1600, 900),
            fold: const Rect.fromLTWH(1000, 0, 20, 900),
          ),
          pane: const Rect.fromLTWH(1020, 0, 580, 900),
          expected: AdaptiveModalPresentation.sheet,
        );
      },
    );

    testWidgets(
      '$style horizontal partition keeps the existing presentation policy',
      (tester) async {
        await _openSimple(
          tester,
          style: style,
          media: _geometry(
            const Size(1000, 900),
            fold: const Rect.fromLTWH(0, 300, 1000, 20),
          ),
          pane: const Rect.fromLTWH(0, 0, 1000, 300),
          expected: AdaptiveModalPresentation.dialog,
        );
      },
    );

    testWidgets(
      '$style fixed dialog stays a dialog in a compact vertical pane',
      (tester) async {
        await _openSimple(
          tester,
          style: style,
          media: _geometry(
            const Size(1600, 900),
            fold: const Rect.fromLTWH(590, 0, 20, 900),
          ),
          pane: const Rect.fromLTWH(0, 0, 590, 900),
          expected: AdaptiveModalPresentation.dialog,
          fixed: AdaptiveModalPresentation.dialog,
        );
      },
    );

    testWidgets(
      '$style pane resizing preserves keyboard draft and nested route result',
      (tester) async {
        final geometry = ValueNotifier(
          _geometry(
            const Size(1600, 900),
            fold: const Rect.fromLTWH(610, 0, 20, 900),
          ),
        );
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

        void expectFrame(double width, AdaptiveModalPresentation presentation) {
          _expectAutomaticPresentation(tester, style, presentation);
          expect(tester.state<_DraftState>(find.byType(_Draft)), same(draft));
          expect(Navigator.of(draft.context), same(navigator));
          expect(ModalRoute.of(draft.context), same(route));
          expect(ModalRoute.of(navigator.context), same(outerRoute));
          expect(navigator.canPop(), isTrue);
          expect(draft.controller.text, 'Unfinished draft');
          expect(draft.focus.hasFocus, isTrue);
          expect(MediaQuery.sizeOf(draft.context), Size(width, 900));
          expect(
            MediaQuery.viewInsetsOf(tester.element(_surface(style))).bottom,
            300,
          );
          expect(
            MediaQuery.viewInsetsOf(draft.context).bottom,
            // Flutter's Dialog consumes the inset after padding its surface.
            style == AdaptiveStyle.material &&
                    presentation == AdaptiveModalPresentation.dialog
                ? 0
                : 300,
            reason: '$style pane=$width presentation=$presentation',
          );
          expect(tester.takeException(), isNull);
        }

        for (final width in [590.0, 610.0]) {
          final size = Size(width == 590 ? 1200 : 1600, 900);
          tester.view.physicalSize = size;
          geometry.value = _geometry(
            size,
            fold: Rect.fromLTWH(width, 0, 20, 900),
            keyboard: 300,
          );
          final presentation = width < 600
              ? AdaptiveModalPresentation.sheet
              : AdaptiveModalPresentation.dialog;
          await tester.pump();
          expectFrame(width, presentation);
          await tester.pumpAndSettle();
          expectFrame(width, presentation);
          _expectContained(
            tester.getRect(find.byKey(_bodyKey)),
            Rect.fromLTWH(0, 0, width, 900 - 300),
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
