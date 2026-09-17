import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final presentation in AdaptiveModalPresentation.values) {
      for (final direction in TextDirection.values) {
        testWidgets('$style $presentation $direction modal confirmation', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1000, 900);
          addTearDown(tester.view.reset);
          final state = ValueNotifier<int>(0);
          addTearDown(state.dispose);
          var saves = 0;
          var closes = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    styleOverride: style,
                    presentationOverride: presentation,
                    builder: (_) => Directionality(
                      textDirection: direction,
                      child: ValueListenableBuilder<int>(
                        valueListenable: state,
                        builder: (_, mode, _) => AdaptiveModal.constrained(
                          title: const Text('Title'),
                          body: const Text('Body'),
                          leadingAction: mode == 3 ? const Text('Back') : null,
                          confirmAction: mode == 0
                              ? null
                              : AdaptiveModalConfirmAction(
                                  label: 'Save',
                                  onPressed: mode == 2 ? null : () => saves++,
                                ),
                          onCloseRequested: () => closes++,
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final close = find.byKey(
            const ValueKey('adaptive-modal-implied-close'),
          );
          final confirm = find.byKey(const ValueKey('adaptive-modal-confirm'));
          final sign = direction == TextDirection.ltr ? 1 : -1;
          double offset(Finder target) =>
              (tester.getCenter(target).dx -
                  tester.getCenter(find.text('Title')).dx) *
              sign;
          expect(
            offset(close),
            style == AdaptiveStyle.apple ? greaterThan(0) : lessThan(0),
          );
          state.value = 1;
          await tester.pumpAndSettle();
          expect(offset(close), lessThan(0));
          expect(offset(confirm), greaterThan(0));
          expect(
            find.byKey(const ValueKey('adaptive-modal-actions')),
            findsNothing,
          );
          if (style == AdaptiveStyle.apple) {
            expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
            expect(find.byTooltip('Save'), findsOneWidget);
            expect(find.text('Save'), findsNothing);
          } else {
            expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
          }
          await tester.tap(confirm);
          await tester.pumpAndSettle();
          expect(saves, 1);
          expect(closes, 0);
          state.value = 2;
          await tester.pumpAndSettle();
          await tester.tap(confirm);
          await tester.pumpAndSettle();
          expect(saves, 1);
          state.value = 3;
          await tester.pumpAndSettle();
          expect(offset(find.text('Back')), lessThan(0));
          expect(offset(confirm), greaterThan(0));
          expect(close, findsNothing);
          state.value = 0;
          await tester.pumpAndSettle();
          expect(confirm, findsNothing);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(closes, 1);
          expect(saves, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
