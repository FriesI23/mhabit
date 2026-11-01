import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

import 'harness/adaptive_ui_theme.dart';

enum _Entry { alert, responsive, fixedDialog, fixedSheet }

const _bodyKey = ValueKey('shared-modal-body');

Future<void> _mount(
  WidgetTester tester, {
  required AdaptiveStyle style,
  required ValueNotifier<MediaQueryData> geometry,
  required WidgetBuilder home,
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
          child: TestAdaptiveUiTheme(
            update: (theme) => theme.copyWith(style: style),
            child: child!,
          ),
        ),
      ),
      home: Builder(builder: home),
    ),
  );
}

Future<void> _open(
  BuildContext context,
  _Entry entry,
  WidgetBuilder bodyBuilder,
) async {
  if (entry == _Entry.alert) {
    await showAdaptiveModalDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdaptiveDialog(content: bodyBuilder(context)),
    );
  } else {
    await showAdaptiveSheet<void>(
      context: context,
      presentationOverride: switch (entry) {
        _Entry.fixedDialog => AdaptiveModalPresentation.dialog,
        _Entry.fixedSheet => AdaptiveModalPresentation.sheet,
        _ => null,
      },
      builder: (context) =>
          AdaptiveModal(title: const Text('Modal'), body: bodyBuilder(context)),
    );
  }
}

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

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final entry in _Entry.values) {
      for (final horizontal in [false, true]) {
        testWidgets(
          '$style $entry automatically receives the existing ${horizontal ? 'horizontal' : 'vertical'} route viewport',
          (tester) async {
            final geometry = ValueNotifier(
              MediaQueryData(
                size: const Size(1000, 800),
                displayFeatures: [
                  DisplayFeature(
                    bounds: horizontal
                        ? const Rect.fromLTWH(0, 390, 1000, 20)
                        : const Rect.fromLTWH(490, 0, 20, 800),
                    type: DisplayFeatureType.fold,
                    state: DisplayFeatureState.postureHalfOpened,
                  ),
                ],
              ),
            );
            addTearDown(geometry.dispose);
            Size? builderSize;
            await _mount(
              tester,
              style: style,
              geometry: geometry,
              home: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => _open(context, entry, (context) {
                    builderSize = MediaQuery.sizeOf(context);
                    return const SizedBox(
                      key: _bodyKey,
                      width: 160,
                      height: 60,
                      child: Text('Content'),
                    );
                  }),
                  child: const Text('Open'),
                ),
              ),
            );
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            // Native Cupertino sheets retain their 8% top gap. Only horizontal
            // fold partitions use the full window; vertical folds select a pane.
            final nativeCupertinoSheet =
                style == AdaptiveStyle.apple && entry == _Entry.fixedSheet;
            final nativeMaterialSheet =
                style == AdaptiveStyle.material && entry == _Entry.fixedSheet;
            final expected = nativeCupertinoSheet
                ? Size(horizontal ? 1000 : 490, 800 * 0.92)
                : nativeMaterialSheet
                // Native Material sheets reserve a 48px drag-handle target
                // and constrain wide M3 sheets to 640px before this builder.
                // Horizontal folds no longer reduce the sheet's height.
                ? horizontal
                      ? const Size(640, 800 - kMinInteractiveDimension)
                      : const Size(490, 800 - kMinInteractiveDimension)
                : horizontal
                ? const Size(1000, 390)
                : const Size(490, 800);
            expect(builderSize, expected);
            expect(
              MediaQuery.sizeOf(tester.element(find.byKey(_bodyKey))),
              expected,
            );
            if (entry == _Entry.responsive) {
              // Vertical panes use their width; horizontal partitions retain
              // the whole-window presentation policy.
              expect(
                _presentation(tester, style),
                horizontal
                    ? AdaptiveModalPresentation.dialog
                    : AdaptiveModalPresentation.sheet,
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets(
      '$style local viewport retains editor and existing resize policy',
      (tester) async {
        final geometry = ValueNotifier(
          const MediaQueryData(size: Size(1000, 800)),
        );
        final controller = TextEditingController();
        final focus = FocusNode();
        addTearDown(geometry.dispose);
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await _mount(
          tester,
          style: style,
          geometry: geometry,
          home: (context) => Scaffold(
            body: TextButton(
              onPressed: () => _open(
                context,
                _Entry.responsive,
                (_) => Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    key: _bodyKey,
                    controller: controller,
                    focusNode: focus,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          MediaQuery.sizeOf(tester.element(find.byKey(_bodyKey))),
          const Size(1000, 800),
        );
        await tester.enterText(find.byKey(_bodyKey), 'draft');
        final editor = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        tester.view.physicalSize = const Size(430, 932);
        geometry.value = const MediaQueryData(size: Size(430, 932));
        await tester.pumpAndSettle();
        expect(
          MediaQuery.sizeOf(tester.element(find.byKey(_bodyKey))),
          const Size(430, 932),
        );
        expect(_presentation(tester, style), AdaptiveModalPresentation.sheet);
        expect(
          tester.state<EditableTextState>(find.byType(EditableText)),
          same(editor),
        );
        expect(controller.text, 'draft');
        expect(focus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
