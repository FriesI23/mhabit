import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  test('size policies keep the existing defaults', () {
    final defaultNavigator = AdaptiveModalNavigator<void>(
      builder: (_) => const SizedBox(),
    );
    expect(defaultNavigator.size, isA<AdaptiveModalFixedSize>());
    const fixed = AdaptiveModalSize.fixed();
    const constrained = AdaptiveModalSize.constrained();
    expect((fixed as AdaptiveModalFixedSize).width, 560);
    expect(fixed.height, 560);
    expect(
      (constrained as AdaptiveModalConstrainedSize).constraints,
      const BoxConstraints(minWidth: 560, maxWidth: 560, maxHeight: 720),
    );
  });

  for (final enableDrag in [false, true]) {
    testWidgets(
      'Apple dialog clears keyboard in a resizable window, drag $enableDrag',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  styleOverride: AdaptiveStyle.apple,
                  presentationOverride: AdaptiveModalPresentation.dialog,
                  enableDrag: enableDrag,
                  builder: (_) => AdaptiveModalNavigator<void>(
                    builder: (_) => const AdaptiveModal(
                      body: SizedBox(
                        height: 1000,
                        child: Material(child: TextField()),
                      ),
                      actions: [SizedBox(height: 50, child: Text('Save'))],
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
        final dialog = find.byType(AdaptiveModalNavigator<void>);
        final initial = tester.getRect(dialog);
        expect(initial.center.dy, 500);
        await tester.enterText(find.byType(TextField), 'Window draft');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(tester.getRect(dialog).bottom, closeTo(700, 1));
        expect(tester.getSize(dialog).height, initial.height);
        expect(
          tester
              .getBottomLeft(
                find.byKey(const ValueKey('adaptive-modal-actions')),
              )
              .dy,
          closeTo(700, 1),
        );
        tester.view.physicalSize = const Size(800, 800);
        await tester.pumpAndSettle();
        expect(tester.getRect(dialog).bottom, closeTo(500, 1));
        expect(tester.getRect(dialog).top, greaterThanOrEqualTo(0));
        expect(tester.getSize(dialog).height, lessThan(initial.height));
        expect(find.text('Window draft'), findsOneWidget);
        tester.view.viewInsets = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        expect(tester.getRect(dialog).center.dy, closeTo(400, 1));
        expect(tester.getSize(dialog).height, initial.height);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '${style.name} auto height survives responsive resize and keyboard',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.reset);
        late BuildContext pageContext;
        final bodyHeight = ValueNotifier<double>(120);
        addTearDown(bodyHeight.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  styleOverride: style,
                  builder: (_) => AdaptiveModalNavigator<void>(
                    size: const AdaptiveModalSize.constrained(),
                    builder: (context) {
                      pageContext = context;
                      return ValueListenableBuilder<double>(
                        valueListenable: bodyHeight,
                        builder: (_, height, _) => AdaptiveModal(
                          title: const Text('Root'),
                          body: SizedBox(
                            height: height,
                            child: const Material(child: TextField()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Retained draft');
        final navigator = Navigator.of(pageContext);
        navigator.push<void>(
          adaptiveModalPageRoute<void>(
            context: pageContext,
            builder: (_) => const AdaptiveModal(
              title: Text('Second'),
              body: SizedBox(height: 240),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final secondHeight = tester
            .getSize(find.byType(AdaptiveModalNavigator<void>))
            .height;
        bodyHeight.value = 400;
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(AdaptiveModalNavigator<void>)).height,
          secondHeight,
        );
        tester.view.physicalSize = const Size(390, 800);
        await tester.pumpAndSettle();
        expect(find.text('Second'), findsOneWidget);
        expect(
          Navigator.of(tester.element(find.text('Second'))),
          same(navigator),
        );
        tester.view.physicalSize = const Size(1000, 1000);
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(AdaptiveModalNavigator<void>)).height,
          closeTo(secondHeight, 1),
        );
        navigator.pop();
        await tester.pumpAndSettle();
        expect(find.text('Retained draft'), findsOneWidget);
        final rootHeight = tester
            .getSize(find.byType(AdaptiveModalNavigator<void>))
            .height;
        expect(rootHeight, greaterThan(secondHeight));
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        expect(find.text('Retained draft'), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(AdaptiveModalNavigator<void>)).height,
          closeTo(rootHeight, 1),
        );
      },
    );

    testWidgets(
      '${style.name} dialog respects custom minimum and maximum size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.reset);
        final bodyHeight = ValueNotifier<double>(10);
        addTearDown(bodyHeight.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  styleOverride: style,
                  presentationOverride: AdaptiveModalPresentation.dialog,
                  builder: (_) => AdaptiveModalNavigator<void>(
                    size: const AdaptiveModalSize.constrained(
                      constraints: BoxConstraints(
                        minWidth: 300,
                        maxWidth: 400,
                        minHeight: 320,
                        maxHeight: 440,
                      ),
                    ),
                    builder: (_) => ValueListenableBuilder<double>(
                      valueListenable: bodyHeight,
                      builder: (_, height, _) =>
                          AdaptiveModal(body: SizedBox(height: height)),
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
        Size size() =>
            tester.getSize(find.byType(AdaptiveModalNavigator<void>));
        expect(size(), const Size(400, 320));
        bodyHeight.value = 1000;
        await tester.pumpAndSettle();
        expect(size(), const Size(400, 440));
        bodyHeight.value = 10;
        await tester.pumpAndSettle();
        expect(size(), const Size(400, 320));
        tester.view.physicalSize = const Size(280, 280);
        await tester.pumpAndSettle();
        expect(size().width, lessThanOrEqualTo(252));
        expect(size().height, lessThanOrEqualTo(252));
        expect(tester.takeException(), isNull);
      },
    );

    for (final sizePolicy in [
      const AdaptiveModalSize.fixed(),
      const AdaptiveModalSize.constrained(),
    ]) {
      testWidgets(
        '${style.name} $sizePolicy keyboard keeps actions at dialog bottom',
        (tester) async {
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
                    presentationOverride: AdaptiveModalPresentation.dialog,
                    builder: (_) => AdaptiveModalNavigator<void>(
                      size: sizePolicy,
                      builder: (_) => const AdaptiveModal(
                        title: Text('Edit'),
                        body: SizedBox(
                          height: 100,
                          child: Material(child: TextField()),
                        ),
                        actions: [SizedBox(height: 50, child: Text('Save'))],
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
          double bottomGap() =>
              tester
                  .getBottomLeft(find.byType(AdaptiveModalNavigator<void>))
                  .dy -
              tester
                  .getBottomLeft(
                    find.byKey(const ValueKey('adaptive-modal-actions')),
                  )
                  .dy;
          final initialGap = bottomGap();
          final initialHeight = tester
              .getSize(find.byType(AdaptiveModalNavigator<void>))
              .height;
          expect(initialGap, closeTo(0, 1));
          await tester.enterText(find.byType(TextField), 'Draft');
          tester.view.viewInsets = const FakeViewPadding(bottom: 250);
          await tester.pumpAndSettle();
          expect(bottomGap(), closeTo(initialGap, 1));
          expect(
            tester.getSize(find.byType(AdaptiveModalNavigator<void>)).height,
            closeTo(initialHeight, 1),
          );
          expect(find.text('Draft'), findsOneWidget);
          tester.view.viewInsets = FakeViewPadding.zero;
          await tester.pumpAndSettle();
          expect(bottomGap(), closeTo(initialGap, 1));
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final fixedHeight in <double?>[null, 500]) {
      testWidgets(
        '${style.name} dialog height $fixedHeight follows page content',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1000, 1000);
          addTearDown(tester.view.reset);
          final bodyHeight = ValueNotifier<double>(100);
          addTearDown(bodyHeight.dispose);
          late BuildContext firstContext;
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    styleOverride: style,
                    presentationOverride: AdaptiveModalPresentation.dialog,
                    builder: (_) => AdaptiveModalNavigator<void>(
                      size: fixedHeight == null
                          ? const AdaptiveModalSize.constrained()
                          : AdaptiveModalSize.fixed(height: fixedHeight),
                      builder: (context) {
                        firstContext = context;
                        return ValueListenableBuilder<double>(
                          valueListenable: bodyHeight,
                          builder: (_, height, _) => AdaptiveModal(
                            title: const Text('First'),
                            body: SizedBox(height: height),
                          ),
                        );
                      },
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          double height() =>
              tester.getSize(find.byType(AdaptiveModalNavigator<void>)).height;
          final initial = height();
          expect(initial, fixedHeight ?? lessThan(300));
          final navigator = Navigator.of(firstContext);
          navigator.push<void>(
            adaptiveModalPageRoute<void>(
              context: firstContext,
              builder: (_) => const AdaptiveModal(
                title: Text('Second'),
                body: SizedBox(height: 360),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(height(), fixedHeight ?? closeTo(initial + 260, 1));
          navigator.pop();
          await tester.pumpAndSettle();
          expect(height(), closeTo(initial, 1));
          final navigatorElement = navigator.context;
          var navigatorRebuilds = 0;
          final previousRebuildCallback = debugOnRebuildDirtyWidget;
          debugOnRebuildDirtyWidget = (element, builtOnce) {
            previousRebuildCallback?.call(element, builtOnce);
            if (element == navigatorElement ||
                element.widget is AdaptiveModalNavigator<void>) {
              navigatorRebuilds++;
            }
          };
          addTearDown(
            () => debugOnRebuildDirtyWidget = previousRebuildCallback,
          );
          bodyHeight.value = 230;
          await tester.pumpAndSettle();
          expect(height(), fixedHeight ?? closeTo(initial + 130, 1));
          bodyHeight.value = 1400;
          await tester.pumpAndSettle();
          expect(height(), fixedHeight ?? 720);
          final scroll = tester.widget<SingleChildScrollView>(
            find.byKey(const ValueKey('adaptive-modal-scroll-body')),
          );
          expect(scroll.controller!.position.maxScrollExtent, greaterThan(0));
          bodyHeight.value = 1600;
          await tester.pumpAndSettle();
          expect(height(), fixedHeight ?? 720);
          bodyHeight.value = 100;
          await tester.pumpAndSettle();
          expect(height(), closeTo(initial, 1));
          expect(navigatorRebuilds, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
