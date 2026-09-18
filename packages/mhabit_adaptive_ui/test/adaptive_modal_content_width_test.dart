import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final fixedWidth in [false, true]) {
      testWidgets(
        '${style.name} tight and loose axes share one policy fixedWidth=$fixedWidth',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1200, 1000);
          addTearDown(tester.view.reset);
          final content = ValueNotifier<Size>(const Size(300, 100));
          addTearDown(content.dispose);
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    styleOverride: style,
                    presentationOverride: AdaptiveModalPresentation.dialog,
                    builder: (_) => ValueListenableBuilder<Size>(
                      valueListenable: content,
                      builder: (_, value, _) => AdaptiveModal(
                        size: fixedWidth
                            ? const AdaptiveModalSize.constrained(
                                minWidth: 480,
                                maxWidth: 480,
                              )
                            : const AdaptiveModalSize.constrained(
                                minWidth: 0,
                                maxWidth: 800,
                                minHeight: 360,
                                maxHeight: 360,
                              ),
                        body: SizedBox.fromSize(size: value),
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
          final frame = find.byKey(
            const ValueKey('adaptive-modal-constraints'),
          );
          final initial = tester.getSize(frame);
          expect(
            fixedWidth ? initial.width : initial.height,
            fixedWidth ? 480 : 360,
          );
          content.value = const Size(700, 300);
          await tester.pumpAndSettle();
          final expanded = tester.getSize(frame);
          expect(
            fixedWidth ? expanded.width : expanded.height,
            fixedWidth ? 480 : 360,
          );
          expect(
            fixedWidth ? expanded.height : expanded.width,
            greaterThan(fixedWidth ? initial.height : initial.width),
          );
          content.value = const Size(300, 100);
          await tester.pumpAndSettle();
          expect(tester.getSize(frame), initial);
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final nested in [false, true]) {
      testWidgets(
        '${style.name} nested=$nested content width shrinks, grows and respects the window',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1000, 1000);
          addTearDown(tester.view.reset);
          final width = ValueNotifier<double>(300);
          addTearDown(width.dispose);
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    styleOverride: style,
                    presentationOverride: AdaptiveModalPresentation.dialog,
                    builder: (routeContext) {
                      Widget content(BuildContext context) =>
                          ValueListenableBuilder<double>(
                            valueListenable: width,
                            builder: (_, value, _) => AdaptiveModal(
                              size: nested
                                  ? null
                                  : const AdaptiveModalSize.constrained(
                                      minWidth: 0,
                                      maxWidth: double.infinity,
                                    ),
                              body: SizedBox(width: value, height: 100),
                            ),
                          );
                      return nested
                          ? AdaptiveModalNavigator<void>(
                              size: const AdaptiveModalSize.constrained(
                                minWidth: 0,
                                maxWidth: double.infinity,
                              ),
                              builder: content,
                            )
                          : content(routeContext);
                    },
                  ),
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
          final padding = style == AdaptiveStyle.material ? 48.0 : 32.0;
          expect(tester.getSize(frame).width, 300 + padding);
          width.value = 700;
          await tester.pumpAndSettle();
          expect(tester.getSize(frame).width, 700 + padding);
          tester.view.physicalSize = const Size(320, 700);
          await tester.pumpAndSettle();
          expect(tester.getSize(frame).width, lessThanOrEqualTo(320));
          tester.view.physicalSize = const Size(1000, 1000);
          width.value = 300;
          await tester.pumpAndSettle();
          expect(tester.getSize(frame).width, 300 + padding);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
