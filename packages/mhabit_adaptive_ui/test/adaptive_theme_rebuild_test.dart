import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final presentation in AdaptiveModalPresentation.values) {
      testWidgets(
        '$style $presentation theme updates stay below the modal surface',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            presentation == AdaptiveModalPresentation.sheet ? 400 : 900,
            800,
          );
          addTearDown(tester.view.reset);
          final data = ValueNotifier(AppAdaptiveUiThemeData(style: style));
          final input = TextEditingController(text: 'retained input');
          final focus = FocusNode();
          addTearDown(data.dispose);
          addTearDown(input.dispose);
          addTearDown(focus.dispose);
          var contentBuilds = 0;
          var unrelatedBuilds = 0;
          var consumerBuilds = 0;
          await tester.pumpWidget(
            MaterialApp(
              builder: (_, child) => ValueListenableBuilder(
                valueListenable: data,
                child: child,
                builder: (_, value, child) =>
                    AppAdaptiveUiTheme(data: value, child: child!),
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showAdaptiveSheet<void>(
                      context: context,
                      builder: (_) {
                        contentBuilds++;
                        return Material(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Builder(
                                builder: (_) {
                                  unrelatedBuilds++;
                                  return TextField(
                                    controller: input,
                                    focusNode: focus,
                                  );
                                },
                              ),
                              Builder(
                                builder: (context) {
                                  consumerBuilds++;
                                  return Text(
                                    'width:${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          focus.requestFocus();
          await tester.pumpAndSettle();
          final surfaceFinder = style == AdaptiveStyle.material
              ? find.byType(MaterialAdaptiveModalRouteSurface)
              : find.byType(CupertinoAdaptiveModalRouteSurface);
          final surface = tester.element(surfaceFinder);
          final navigator = tester.state<NavigatorState>(
            find.byType(Navigator),
          );
          final initialContentBuilds = contentBuilds;
          final initialUnrelatedBuilds = unrelatedBuilds;
          final initialConsumerBuilds = consumerBuilds;
          var surfaceBuilds = 0;
          final previous = debugOnRebuildDirtyWidget;
          addTearDown(() => debugOnRebuildDirtyWidget = previous);
          debugOnRebuildDirtyWidget = (element, builtOnce) {
            previous?.call(element, builtOnce);
            if (identical(element, surface)) surfaceBuilds++;
          };
          data.value = data.value.copyWith(
            cupertinoFocusTheme: const AdaptiveCupertinoFocusThemeData(
              haloWidth: 9,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('width:9.0'), findsOneWidget);
          expect(consumerBuilds, greaterThan(initialConsumerBuilds));
          expect(contentBuilds, initialContentBuilds);
          expect(unrelatedBuilds, initialUnrelatedBuilds);
          expect(
            surfaceBuilds,
            0,
            reason: 'Only the route theme and its consumers should rebuild.',
          );
          expect(
            tester.state<NavigatorState>(find.byType(Navigator)),
            same(navigator),
          );
          expect(input.text, 'retained input');
          expect(focus.hasFocus, isTrue);

          // Geometry remains a route dependency and must update presentation.
          tester.view.physicalSize = Size(
            presentation == AdaptiveModalPresentation.sheet ? 900 : 400,
            800,
          );
          await tester.pumpAndSettle();
          expect(surfaceBuilds, greaterThan(0));
          final actualPresentation = style == AdaptiveStyle.material
              ? tester
                    .widget<MaterialAdaptiveModalRouteSurface>(surfaceFinder)
                    .presentation
              : tester
                    .widget<CupertinoAdaptiveModalRouteSurface>(surfaceFinder)
                    .presentation;
          expect(
            actualPresentation,
            presentation == AdaptiveModalPresentation.sheet
                ? AdaptiveModalPresentation.dialog
                : AdaptiveModalPresentation.sheet,
          );
          expect(input.text, 'retained input');
          expect(focus.hasFocus, isTrue);
          expect(find.text('width:9.0'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
