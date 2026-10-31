import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

import 'harness/adaptive_ui_theme.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style responsive dialog reads its selected pane before content',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        Size? bodyMedia;
        BoxConstraints? bodyConstraints;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: const MediaQueryData(
                size: Size(1000, 1000),
                displayFeatures: [
                  DisplayFeature(
                    bounds: Rect.fromLTWH(0, 300, 1000, 20),
                    type: DisplayFeatureType.fold,
                    state: DisplayFeatureState.postureHalfOpened,
                  ),
                ],
              ),
              child: TestAdaptiveUiTheme(
                update: (theme) => theme.copyWith(style: style),
                child: child!,
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    builder: (context) {
                      bodyMedia = MediaQuery.sizeOf(context);
                      return AdaptiveModal(
                        title: const Text('Dialog'),
                        body: LayoutBuilder(
                          builder: (context, constraints) {
                            bodyConstraints = constraints;
                            return const SizedBox(width: 120, height: 40);
                          },
                        ),
                      );
                    },
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final responsive = find.byWidgetPredicate(
          (widget) =>
              widget.runtimeType.toString() == '_ResponsiveAdaptiveModalRoute',
        );
        expect(responsive, findsOneWidget);
        final routeMedia = MediaQuery.sizeOf(tester.element(responsive));
        final routeConstraints = tester
            .renderObject<RenderBox>(responsive)
            .constraints;
        // Existing content-level tests already prove the pane is published here.
        expect(bodyMedia, const Size(1000, 300));
        expect(routeConstraints.biggest, const Size(1000, 300));
        // The responsive route must observe the same space as its constraints.
        expect(
          routeMedia,
          routeConstraints.biggest,
          reason: 'Content MQ: $bodyMedia; body constraints: $bodyConstraints',
        );
        final presentation = switch (style) {
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
        expect(presentation, AdaptiveModalPresentation.dialog);
        expect(tester.takeException(), isNull);
      },
    );

    for (final direction in TextDirection.values) {
      testWidgets('$style $direction fixed sheet reads its vertical pane', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        const bodyKey = ValueKey('fixed-sheet-pane-body');
        Size? localMedia;
        BoxConstraints? localConstraints;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: const MediaQueryData(
                size: Size(1000, 800),
                displayFeatures: [
                  DisplayFeature(
                    bounds: Rect.fromLTWH(390, 0, 20, 800),
                    type: DisplayFeatureType.fold,
                    state: DisplayFeatureState.postureHalfOpened,
                  ),
                ],
              ),
              child: Directionality(
                textDirection: direction,
                child: TestAdaptiveUiTheme(
                  update: (theme) => theme.copyWith(style: style),
                  child: child!,
                ),
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    presentationOverride: AdaptiveModalPresentation.sheet,
                    showDragHandle: false,
                    builder: (context) {
                      localMedia = MediaQuery.sizeOf(context);
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          localConstraints = constraints;
                          return const AdaptiveModal(
                            title: Text('Fixed sheet'),
                            body: SizedBox(
                              key: bodyKey,
                              width: 120,
                              height: 40,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final pane = direction == TextDirection.ltr
            ? const Rect.fromLTWH(0, 0, 390, 800)
            : const Rect.fromLTWH(410, 0, 590, 800);
        expect(localConstraints!.maxWidth, pane.width);
        expect(
          localMedia,
          Size(pane.width, style == AdaptiveStyle.apple ? 800 * 0.92 : 800),
        );
        final bodyBounds = tester.getRect(find.byKey(bodyKey));
        expect(bodyBounds.left, greaterThanOrEqualTo(pane.left));
        expect(bodyBounds.right, lessThanOrEqualTo(pane.right));
        expect(bodyBounds.top, greaterThanOrEqualTo(pane.top));
        expect(bodyBounds.bottom, lessThanOrEqualTo(pane.bottom));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
