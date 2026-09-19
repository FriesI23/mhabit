import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/adaptive/adaptive_modal_layout.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final nested in [false, true]) {
      testWidgets(
        '${style.name} loose sliver dialog shrinks and grows, nested=$nested',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1000, 1000);
          addTearDown(tester.view.reset);
          final height = ValueNotifier<double>(100);
          addTearDown(height.dispose);
          const size = AdaptiveModalSize.constrained(maxHeight: 600);
          Widget content(BuildContext context) =>
              ValueListenableBuilder<double>(
                valueListenable: height,
                builder: (_, value, _) => AdaptiveModal.slivers(
                  title: const Text('Title'),
                  size: size,
                  slivers: [SliverToBoxAdapter(child: SizedBox(height: value))],
                ),
              );
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    styleOverride: style,
                    builder: nested
                        ? (_) => AdaptiveModalNavigator<void>(
                            size: size,
                            builder: content,
                          )
                        : content,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          double modalHeight() => tester
              .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
              .height;
          final initial = modalHeight();
          expect(initial, lessThan(350));
          height.value = 420;
          await tester.pumpAndSettle();
          expect(modalHeight(), greaterThan(initial + 250));
          height.value = 1500;
          await tester.pumpAndSettle();
          expect(modalHeight(), closeTo(600, 1));
          height.value = 40;
          await tester.pumpAndSettle();
          expect(modalHeight(), closeTo(initial - 60, 1));
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets('${style.name} fixed sliver dialog keeps requested height', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 1000);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAdaptiveSheet<void>(
                context: context,
                styleOverride: style,
                builder: (_) => const AdaptiveModal.slivers(
                  title: Text('Title'),
                  size: AdaptiveModalSize.fixed(height: 400),
                  slivers: [SliverToBoxAdapter(child: SizedBox(height: 40))],
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .height,
        400,
      );
      expect(tester.takeException(), isNull);
    });
    for (final height in [800.0, 280.0]) {
      testWidgets('${style.name} sliver modal keeps one viewport at $height', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(900, height);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  styleOverride: style,
                  builder: (_) => AdaptiveModal.slivers(
                    title: const Text('Sliver modal'),
                    pinnedBody: const Text('Pinned content'),
                    size: const AdaptiveModalSize.constrained(maxHeight: 600),
                    slivers: [
                      SliverList.builder(
                        itemCount: 100,
                        itemBuilder: (_, index) =>
                            SizedBox(height: 56, child: Text('Row $index')),
                      ),
                    ],
                    bottomActions: const [Text('Bottom action')],
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Footer action'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveModalLayout), findsNothing);
        expect(find.byType(AdaptiveSliverModalLayout), findsOneWidget);
        final view = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        expect(view.controller!.positions, hasLength(1));
        expect(find.text('Row 99'), findsNothing);
        view.controller!.jumpTo(view.controller!.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(find.text('Row 99'), findsOneWidget);
        expect(find.text('Bottom action').hitTestable(), findsOneWidget);
        expect(find.text('Footer action').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
