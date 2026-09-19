import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final presentation in AdaptiveModalPresentation.values) {
      for (final automatic
          in presentation == AdaptiveModalPresentation.sheet
              ? [false, true]
              : [false]) {
        testWidgets(
          '$style $presentation automatic=$automatic simple has no toolbar space and preserves results',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(automatic ? 400 : 1000, 900);
            addTearDown(tester.view.reset);
            int? result;
            var completions = 0;
            await tester.pumpWidget(
              MaterialApp(
                home: Builder(
                  builder: (context) => TextButton(
                    onPressed: () async {
                      result = await showAdaptiveSheet<int>(
                        context: context,
                        styleOverride: style,
                        presentationOverride: automatic ? null : presentation,
                        showDragHandle: true,
                        barrierDismissible: true,
                        builder: (context) => AdaptiveModal.simple(
                          body: SizedBox(
                            key: const ValueKey('simple-body'),
                            height: 80,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(7),
                              child: const Text('Choose'),
                            ),
                          ),
                        ),
                      );
                      completions++;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            final frame = find.byKey(
              const ValueKey('adaptive-modal-constraints'),
            );
            final body = find.byKey(const ValueKey('simple-body'));
            final topPadding = style == AdaptiveStyle.material ? 20.0 : 12.0;
            expect(
              find.byKey(const ValueKey('adaptive-modal-app-bar')),
              findsNothing,
            );
            expect(
              find.byKey(const ValueKey('adaptive-modal-implied-close')),
              findsNothing,
            );
            expect(
              tester.getTopLeft(body).dy - tester.getTopLeft(frame).dy,
              closeTo(topPadding, 0.01),
            );
            if (presentation == AdaptiveModalPresentation.dialog) {
              expect(
                tester.getSize(frame).height,
                closeTo(80 + topPadding + 16, 0.01),
              );
            }
            await tester.tap(find.text('Choose'));
            await tester.pumpAndSettle();
            expect(result, 7);
            expect(completions, 1);
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
            if (automatic) {
              final handle = find.byKey(
                ValueKey(
                  style == AdaptiveStyle.material
                      ? 'adaptive-material-sheet-drag-handle'
                      : 'adaptive-cupertino-sheet-drag-handle',
                ),
              );
              expect(handle.hitTestable(), findsOneWidget);
              await tester.drag(handle, const Offset(0, 850));
            } else if (presentation == AdaptiveModalPresentation.sheet) {
              Navigator.of(tester.element(body)).pop();
            } else {
              await tester.tapAt(const Offset(5, 5));
            }
            await tester.pumpAndSettle();
            expect(result, isNull);
            expect(completions, 2);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
