import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

const _headerKey = ValueKey('adaptive-modal-app-bar');
const _confirmKey = ValueKey('adaptive-modal-confirm');
const _closeKey = ValueKey('adaptive-modal-implied-close');

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final dialog in [false, true]) {
      testWidgets(
        '$style ${dialog ? 'centered dialog clears' : 'edge sheet keeps'} horizontal safe area for Save and Close',
        (tester) async {
          final size = Size(dialog ? 1600 : 500, 900);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final geometry = ValueNotifier(MediaQueryData(size: size));
          addTearDown(geometry.dispose);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) =>
                  ValueListenableBuilder<MediaQueryData>(
                    valueListenable: geometry,
                    builder: (_, data, _) => MediaQuery(
                      data: data,
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
                      showDragHandle: false,
                      // Production Group editing uses this automatic route
                      // and nested Navigator, rather than fixed showDialog.
                      builder: (_) => AdaptiveModalNavigator<void>(
                        size: const AdaptiveModalSize.constrained(
                          maxHeight: 720,
                        ),
                        builder: (_) => AdaptiveModal(
                          title: const Text('Create Group'),
                          confirmAction: AdaptiveModalConfirmAction(
                            label: 'Save',
                            onPressed: () {},
                          ),
                          body: const SizedBox(
                            height: 200,
                            child: Text('Form'),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final headerBefore = tester.getRect(find.byKey(_headerKey));
          final confirmBefore = tester.getRect(find.byKey(_confirmKey));
          final closeBefore = tester.getRect(find.byKey(_closeKey));
          final endGapBefore = headerBefore.right - confirmBefore.right;
          final startGapBefore = closeBefore.left - headerBefore.left;
          expect(
            MediaQuery.paddingOf(tester.element(find.byKey(_headerKey))),
            EdgeInsets.zero,
          );

          const safeArea = EdgeInsets.only(left: 72, right: 96);
          geometry.value = geometry.value.copyWith(
            padding: safeArea,
            viewPadding: safeArea,
          );
          await tester.pumpAndSettle();
          final headerAfter = tester.getRect(find.byKey(_headerKey));
          final confirmAfter = tester.getRect(find.byKey(_confirmKey));
          final closeAfter = tester.getRect(find.byKey(_closeKey));
          final endGapAfter = headerAfter.right - confirmAfter.right;
          final startGapAfter = closeAfter.left - headerAfter.left;
          // Read before AppBar's own SafeArea consumes the incoming padding.
          final toolbarPadding = MediaQuery.paddingOf(
            tester.element(find.byKey(_headerKey)),
          );
          if (dialog) {
            // The full header already lies inside the safe horizontal edges.
            expect(headerAfter.left, greaterThan(72));
            expect(headerAfter.right, lessThan(size.width - 96));
            expect(toolbarPadding, EdgeInsets.zero);
            expect(endGapAfter, closeTo(endGapBefore, 0.1));
            expect(startGapAfter, closeTo(startGapBefore, 0.1));
          } else {
            expect(headerAfter.left, closeTo(0, 0.1));
            expect(headerAfter.right, closeTo(size.width, 0.1));
            expect(toolbarPadding, safeArea);
            expect(endGapAfter, closeTo(endGapBefore + 96, 0.1));
            expect(startGapAfter, closeTo(startGapBefore + 72, 0.1));
          }
          expect(find.byKey(_confirmKey).hitTestable(), findsOneWidget);
          expect(find.byKey(_closeKey).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
