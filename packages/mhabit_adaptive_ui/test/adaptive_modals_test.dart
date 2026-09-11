import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const _modalRouteName = '/adaptive-modal';

final class _RecordingObserver extends NavigatorObserver {
  final List<Route<dynamic>> modalRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == _modalRouteName) modalRoutes.add(route);
  }
}

class _StatefulModalContent extends StatefulWidget {
  const _StatefulModalContent();

  @override
  State<_StatefulModalContent> createState() => _StatefulModalContentState();
}

class _StatefulModalContentState extends State<_StatefulModalContent> {
  int count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count += 1),
    child: Text('Count $count'),
  );
}

Widget _buildNestedNavigatorApp({
  required AdaptiveStyle style,
  required AdaptiveModalPresentation presentation,
  required bool useRootNavigator,
  required NavigatorObserver rootObserver,
  required NavigatorObserver branchObserver,
  WidgetBuilder? modalBuilder,
  bool? barrierDismissible,
  bool enableDrag = true,
  bool showDragHandle = false,
}) => MaterialApp(
  navigatorObservers: [rootObserver],
  home: AdaptiveStyleScope(
    override: style,
    child: Navigator(
      observers: [branchObserver],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showAdaptiveSheet<void>(
              context: context,
              presentationOverride: presentation,
              useRootNavigator: useRootNavigator,
              barrierDismissible: barrierDismissible,
              enableDrag: enableDrag,
              showDragHandle: showDragHandle,
              routeSettings: const RouteSettings(name: _modalRouteName),
              builder: modalBuilder ?? (_) => const Text('modal content'),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _openModal(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  group('Adaptive modal presentation', () {
    for (final testCase in <(Size, AdaptiveModalPresentation)>[
      (const Size(400, 800), AdaptiveModalPresentation.sheet),
      (const Size(800, 400), AdaptiveModalPresentation.sheet),
      (const Size(800, 800), AdaptiveModalPresentation.dialog),
    ]) {
      testWidgets('${testCase.$1} resolves to ${testCase.$2.name}', (
        tester,
      ) async {
        tester.view.physicalSize = testCase.$1;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        final observer = _RecordingObserver();
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [observer],
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  routeSettings: const RouteSettings(name: _modalRouteName),
                  builder: (_) => const Text('modal content'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await _openModal(tester);

        final route = observer.modalRoutes.single;
        expect(route, isA<RawDialogRoute<void>>());
        // The RawDialogRoute barrier is visual only; the responsive page owns
        // the interactive barrier and routes it through modal close handling.
        expect((route as RawDialogRoute<void>).barrierDismissible, isFalse);
        switch (testCase.$2) {
          case AdaptiveModalPresentation.sheet:
            expect(find.byType(DraggableScrollableSheet), findsOneWidget);
            expect(find.byType(Dialog), findsNothing);
          case AdaptiveModalPresentation.dialog:
            expect(find.byType(Dialog), findsOneWidget);
            expect(find.byType(DraggableScrollableSheet), findsNothing);
        }
      });
    }

    testWidgets('presentation override wins over the window size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final observer = _RecordingObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAdaptiveSheet<void>(
                context: context,
                presentationOverride: AdaptiveModalPresentation.dialog,
                routeSettings: const RouteSettings(name: _modalRouteName),
                builder: (_) => const Text('modal content'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await _openModal(tester);

      expect(observer.modalRoutes.single, isA<DialogRoute<void>>());
    });

    testWidgets('automatic presentation respects BreakpointsScope', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final observer = _RecordingObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: BreakpointsScope(
            breakpoints: const CustomBreakpoints(width: [1000], height: [1000]),
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  routeSettings: const RouteSettings(name: _modalRouteName),
                  builder: (_) => const Text('modal content'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await _openModal(tester);

      expect(observer.modalRoutes.single, isA<RawDialogRoute<void>>());
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('resizing changes presentation without replacing its route', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final observer = _RecordingObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAdaptiveSheet<void>(
                context: context,
                routeSettings: const RouteSettings(name: _modalRouteName),
                builder: (_) => const _StatefulModalContent(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await _openModal(tester);
      final initialRoute = observer.modalRoutes.single;
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      await tester.tap(find.text('Count 0'));
      await tester.pump();

      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpAndSettle();

      expect(observer.modalRoutes, hasLength(1));
      expect(observer.modalRoutes.single, same(initialRoute));
      expect(observer.modalRoutes.single, isA<RawDialogRoute<void>>());
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsNothing);
      expect(find.text('Count 1'), findsOneWidget);
    });

    testWidgets(
      'Material dialog to sheet resize does not notify motion during build',
      (tester) async {
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  builder: (_) => const AdaptiveModal(
                    title: Text('Title'),
                    body: Text('Body'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await _openModal(tester);
        expect(find.byType(Dialog), findsOneWidget);

        tester.view.physicalSize = const Size(400, 800);
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} automatic sheet uses its height cap', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(400, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveStyleScope(
              override: style,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    builder: (_) => const AdaptiveModal(
                      body: SizedBox(height: 1200, child: Text('Body')),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await _openModal(tester);

        final sheet = tester.widget<DraggableScrollableSheet>(
          find.byType(DraggableScrollableSheet),
        );
        expect(sheet.initialChildSize, sheet.maxChildSize);
        expect(sheet.minChildSize, 0);
        expect(sheet.snap, isTrue);

        final expectedHeight = switch (style) {
          AdaptiveStyle.apple => 1200 * 0.92,
          AdaptiveStyle.material => AdaptiveModalConstraints.maxHeight,
        };
        expect(
          tester
              .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
              .height,
          expectedHeight,
        );
      });

      testWidgets('${style.name} automatic sheet snaps to max or dismisses', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveStyleScope(
              override: style,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    builder: (_) => const AdaptiveModal(
                      body: SizedBox(height: 1200, child: Text('Body')),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await _openModal(tester);

        final sheet = find.byType(DraggableScrollableSheet);
        final scrollBody = find.byKey(
          const ValueKey('adaptive-modal-scroll-body'),
        );
        final initialTop = tester.getTopLeft(sheet).dy;
        final firstDrag = await tester.startGesture(
          tester.getCenter(scrollBody),
        );
        await firstDrag.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 100));
        await firstDrag.moveBy(const Offset(0, 280));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.getTopLeft(sheet).dy, greaterThan(initialTop));
        await firstDrag.up();
        await tester.pumpAndSettle();

        expect(find.text('Body'), findsOneWidget);
        expect(tester.getTopLeft(sheet).dy, moreOrLessEquals(initialTop));

        final secondDrag = await tester.startGesture(
          tester.getCenter(scrollBody),
        );
        await secondDrag.moveBy(const Offset(0, 20));
        await tester.pump(const Duration(milliseconds: 100));
        await secondDrag.moveBy(const Offset(0, 380));
        await tester.pump(const Duration(milliseconds: 300));
        await secondDrag.up();
        await tester.pumpAndSettle();

        expect(find.text('Body'), findsNothing);
      });
    }

    testWidgets('barrier dismissal slides an automatic sheet down', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAdaptiveSheet<void>(
                context: context,
                builder: (_) => const AdaptiveModal(body: Text('Body')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await _openModal(tester);
      final sheet = find.byType(DraggableScrollableSheet);
      final initialTop = tester.getTopLeft(sheet).dy;

      await tester.tapAt(const Offset(4, 4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Body'), findsOneWidget);
      expect(tester.getTopLeft(sheet).dy, greaterThan(initialTop));

      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });
  });

  group('Adaptive modal renderer matrix', () {
    for (final style in AdaptiveStyle.values) {
      for (final presentation in AdaptiveModalPresentation.values) {
        testWidgets('${style.name} ${presentation.name} route and options', (
          tester,
        ) async {
          final rootObserver = _RecordingObserver();
          final branchObserver = _RecordingObserver();
          await tester.pumpWidget(
            _buildNestedNavigatorApp(
              style: style,
              presentation: presentation,
              useRootNavigator: true,
              rootObserver: rootObserver,
              branchObserver: branchObserver,
              barrierDismissible: false,
              enableDrag: false,
            ),
          );

          await _openModal(tester);

          final route = rootObserver.modalRoutes.single;
          expect(branchObserver.modalRoutes, isEmpty);
          switch ((style, presentation)) {
            case (AdaptiveStyle.material, AdaptiveModalPresentation.dialog):
              expect(route, isA<DialogRoute<void>>());
              expect((route as DialogRoute<void>).barrierDismissible, isFalse);
              expect(find.byType(Dialog), findsOneWidget);
            case (AdaptiveStyle.apple, AdaptiveModalPresentation.dialog):
              expect(route, isA<PopupRoute<void>>());
              expect((route as PopupRoute<void>).barrierDismissible, isFalse);
              expect(find.byType(CupertinoPopupSurface), findsOneWidget);
              expect(find.byType(Dismissible), findsNothing);
            case (AdaptiveStyle.material, AdaptiveModalPresentation.sheet):
              expect(route, isA<ModalBottomSheetRoute<void>>());
              final sheetRoute = route as ModalBottomSheetRoute<void>;
              expect(sheetRoute.isDismissible, isFalse);
              expect(sheetRoute.enableDrag, isFalse);
            case (AdaptiveStyle.apple, AdaptiveModalPresentation.sheet):
              expect(route, isA<CupertinoSheetRoute<void>>());
              final sheetRoute = route as CupertinoSheetRoute<void>;
              expect(sheetRoute.barrierDismissible, isFalse);
              expect(sheetRoute.enableDrag, isFalse);
              expect(sheetRoute.topGap, 0.08);
          }
        });

        testWidgets(
          '${style.name} ${presentation.name} uses nearest navigator',
          (tester) async {
            final rootObserver = _RecordingObserver();
            final branchObserver = _RecordingObserver();
            await tester.pumpWidget(
              _buildNestedNavigatorApp(
                style: style,
                presentation: presentation,
                useRootNavigator: false,
                rootObserver: rootObserver,
                branchObserver: branchObserver,
              ),
            );

            await _openModal(tester);

            expect(rootObserver.modalRoutes, isEmpty);
            expect(branchObserver.modalRoutes, hasLength(1));
          },
        );
      }
    }

    testWidgets('builder receives the pushed route context', (tester) async {
      final rootObserver = _RecordingObserver();
      final branchObserver = _RecordingObserver();
      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.sheet,
          useRootNavigator: true,
          rootObserver: rootObserver,
          branchObserver: branchObserver,
          modalBuilder: (context) =>
              Text(ModalRoute.settingsOf(context)?.name ?? 'missing route'),
        ),
      );

      await _openModal(tester);

      expect(find.text(_modalRouteName), findsOneWidget);
    });

    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} dialog uses its default barrier behavior', (
        tester,
      ) async {
        final rootObserver = _RecordingObserver();
        final branchObserver = _RecordingObserver();
        await tester.pumpWidget(
          _buildNestedNavigatorApp(
            style: style,
            presentation: AdaptiveModalPresentation.dialog,
            useRootNavigator: true,
            rootObserver: rootObserver,
            branchObserver: branchObserver,
          ),
        );

        await _openModal(tester);

        final route = rootObserver.modalRoutes.single as PopupRoute<void>;
        expect(route.barrierDismissible, style == AdaptiveStyle.material);

        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
        expect(find.text('modal content'), findsNothing);
      });
    }

    testWidgets('apple dialog slides vertically and dismisses past halfway', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  builder: (_) => const AdaptiveModal(
                    body: SizedBox(height: 1200, child: Text('Body')),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final popup = find.byType(CupertinoPopupSurface);
      final enteringTop = tester.getTopLeft(popup).dy;
      await tester.pumpAndSettle();
      final initialTop = tester.getTopLeft(popup).dy;
      expect(enteringTop, greaterThan(initialTop));

      expect(
        find.byKey(const ValueKey('adaptive-cupertino-dialog-scroll-dismiss')),
        findsOneWidget,
      );

      final firstDrag = await tester.startGesture(
        Offset(tester.getCenter(popup).dx, initialTop + 10),
      );
      await firstDrag.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await firstDrag.moveBy(const Offset(0, 280));
      await tester.pump(const Duration(milliseconds: 300));
      await firstDrag.up();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));

      final secondDrag = await tester.startGesture(
        Offset(tester.getCenter(popup).dx, initialTop + 10),
      );
      await secondDrag.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await secondDrag.moveBy(const Offset(0, 380));
      await tester.pump(const Duration(milliseconds: 300));
      await secondDrag.up();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog explicit close slides down', (tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  builder: (_) => const AdaptiveModal(body: Text('Body')),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await _openModal(tester);

      final popup = find.byType(CupertinoPopupSurface);
      final initialTop = tester.getTopLeft(popup).dy;
      await tester.tap(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Body'), findsOneWidget);
      expect(tester.getTopLeft(popup).dy, greaterThan(initialTop));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog continues a top-edge body drag into dismissal', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  builder: (_) => const AdaptiveModal(
                    body: SizedBox(height: 1200, child: Text('Body')),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await _openModal(tester);

      final popup = find.byType(CupertinoPopupSurface);
      final scrollBody = find.byKey(
        const ValueKey('adaptive-modal-scroll-body'),
      );
      final scrollController = tester
          .widget<SingleChildScrollView>(scrollBody)
          .controller!;
      final initialTop = tester.getTopLeft(popup).dy;

      final reboundDrag = await tester.startGesture(
        tester.getCenter(scrollBody),
      );
      await reboundDrag.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await reboundDrag.moveBy(const Offset(0, 280));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getTopLeft(popup).dy, greaterThan(initialTop));
      await reboundDrag.up();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));

      scrollController.jumpTo(200);
      await tester.pump();
      final dismissDrag = await tester.startGesture(
        tester.getCenter(scrollBody),
      );
      await dismissDrag.moveBy(const Offset(0, 220));
      await tester.pump(const Duration(milliseconds: 100));
      expect(scrollController.offset, 0);
      await dismissDrag.moveBy(const Offset(0, 380));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getTopLeft(popup).dy, greaterThan(initialTop));
      await dismissDrag.up();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog accepts pointer scrolling at the body top edge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          useRootNavigator: true,
          rootObserver: _RecordingObserver(),
          branchObserver: _RecordingObserver(),
          modalBuilder: (_) => const AdaptiveModal(
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _openModal(tester);

      final popup = find.byType(CupertinoPopupSurface);
      final scrollBody = find.byKey(
        const ValueKey('adaptive-modal-scroll-body'),
      );
      final scrollController = tester
          .widget<SingleChildScrollView>(scrollBody)
          .controller!;
      final initialTop = tester.getTopLeft(popup).dy;

      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(scrollBody),
          scrollDelta: const Offset(0, -300),
        ),
      );
      await tester.pump();
      expect(tester.getTopLeft(popup).dy, greaterThan(initialTop));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));

      scrollController.jumpTo(200);
      await tester.pump();
      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(scrollBody),
          scrollDelta: const Offset(0, -220),
        ),
      );
      await tester.pump();
      expect(scrollController.offset, 0);
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));

      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(scrollBody),
          scrollDelta: const Offset(0, -400),
        ),
      );
      await tester.pump();
      expect(tester.getTopLeft(popup).dy, greaterThan(initialTop));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog ignores mouse drag outside the drag handle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          useRootNavigator: true,
          rootObserver: _RecordingObserver(),
          branchObserver: _RecordingObserver(),
          modalBuilder: (_) => const AdaptiveModal(
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _openModal(tester);

      final popup = find.byType(CupertinoPopupSurface);
      final initialTop = tester.getTopLeft(popup).dy;
      final gesture = await tester.startGesture(
        tester.getCenter(
          find.byKey(const ValueKey('adaptive-modal-scroll-body')),
        ),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 400));
      await tester.pump();
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('apple dialog accepts mouse drag from its drag handle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      final rootObserver = _RecordingObserver();

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          useRootNavigator: true,
          rootObserver: rootObserver,
          branchObserver: _RecordingObserver(),
          showDragHandle: true,
          modalBuilder: (_) => const AdaptiveModal(body: Text('Body')),
        ),
      );
      await _openModal(tester);

      final handle = find.byKey(
        const ValueKey('adaptive-cupertino-dialog-drag-handle'),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(handle),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 400));
      await tester.pump();
      expect(rootObserver.navigator!.userGestureInProgress, isFalse);
      await gesture.up();
      await tester.pump();
      expect(rootObserver.navigator!.userGestureInProgress, isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog accepts trackpad pan at the body top edge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          useRootNavigator: true,
          rootObserver: _RecordingObserver(),
          branchObserver: _RecordingObserver(),
          modalBuilder: (_) => const AdaptiveModal(
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _openModal(tester);

      final body = find.byKey(const ValueKey('adaptive-modal-scroll-body'));
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(tester.getCenter(body));
      await gesture.panZoomUpdate(
        tester.getCenter(body),
        pan: const Offset(0, 400),
      );
      await tester.pump();
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('apple dialog rebounds when drag close is rejected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      var closeRequests = 0;
      var bodyTaps = 0;
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAdaptiveSheet<void>(
                  context: context,
                  builder: (_) => AdaptiveModal(
                    onCloseRequested: () => closeRequests += 1,
                    body: SizedBox(
                      height: 1200,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ElevatedButton(
                          onPressed: () => bodyTaps += 1,
                          child: const Text('Continue'),
                        ),
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
      await _openModal(tester);

      final popup = find.byType(CupertinoPopupSurface);
      final initialTop = tester.getTopLeft(popup).dy;
      final drag = await tester.startGesture(
        Offset(tester.getCenter(popup).dx, initialTop + 10),
      );
      await drag.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await drag.moveBy(const Offset(0, 380));
      await tester.pump(const Duration(milliseconds: 300));
      expect(navigatorKey.currentState!.userGestureInProgress, isFalse);
      await drag.up();
      await tester.pump();
      expect(navigatorKey.currentState!.userGestureInProgress, isFalse);
      await tester.pumpAndSettle();

      expect(closeRequests, 1);
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.getTopLeft(popup).dy, moreOrLessEquals(initialTop));
      await tester.tap(find.text('Continue'));
      expect(bodyTaps, 1);
    });

    for (final style in AdaptiveStyle.values) {
      for (final presentation in AdaptiveModalPresentation.values) {
        testWidgets(
          '${style.name} ${presentation.name} preserves typed result',
          (tester) async {
            String? result;
            await tester.pumpWidget(
              MaterialApp(
                home: AdaptiveStyleScope(
                  override: style,
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () async {
                        result = await showAdaptiveSheet<String>(
                          context: context,
                          presentationOverride: presentation,
                          builder: (routeContext) => ElevatedButton(
                            onPressed: () =>
                                Navigator.of(routeContext).pop<String>('saved'),
                            child: const Text('Return result'),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            );

            await _openModal(tester);
            await tester.tap(find.text('Return result'));
            await tester.pumpAndSettle();

            expect(result, 'saved');
          },
        );
      }
    }
  });

  group('AdaptiveModalNavigator', () {
    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} keeps pushed pages inside the modal', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveStyleScope(
              override: style,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    presentationOverride: AdaptiveModalPresentation.dialog,
                    builder: (_) => AdaptiveModalNavigator<void>(
                      builder: (pageContext) => AdaptiveModal(
                        body: TextButton(
                          onPressed: () => Navigator.of(pageContext).push(
                            adaptiveModalPageRoute<void>(
                              context: pageContext,
                              builder: (_) => const AdaptiveModal(
                                body: Text('Second page'),
                              ),
                            ),
                          ),
                          child: const Text('Push page'),
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

        await _openModal(tester);
        await tester.tap(find.text('Push page'));
        await tester.pumpAndSettle();
        expect(find.text('Second page'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Push page'), findsOneWidget);
        expect(find.text('Second page'), findsNothing);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Push page'), findsNothing);
        expect(find.text('Open'), findsOneWidget);
      });
    }

    for (final style in AdaptiveStyle.values) {
      for (final presentation in AdaptiveModalPresentation.values) {
        testWidgets(
          '${style.name} ${presentation.name} preserves the modal result',
          (tester) async {
            String? result;
            await tester.pumpWidget(
              MaterialApp(
                home: AdaptiveStyleScope(
                  override: style,
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () async {
                        result = await showAdaptiveSheet<String>(
                          context: context,
                          presentationOverride: presentation,
                          builder: (_) => AdaptiveModalNavigator<String>(
                            builder: (pageContext) => AdaptiveModal(
                              body: TextButton(
                                onPressed: () =>
                                    AdaptiveModalNavigator.pop<String>(
                                      pageContext,
                                      'saved',
                                    ),
                                child: const Text('Return result'),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            );

            await _openModal(tester);
            await tester.tap(find.text('Return result'));
            await tester.pumpAndSettle();

            expect(result, 'saved');
            expect(find.text('Return result'), findsNothing);
          },
        );
      }
    }
  });

  group('fixed presentation entries', () {
    testWidgets('AdaptiveBottomSheet stays a sheet on a large window', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final observer = _RecordingObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAdaptiveBottomSheet<void>(
                context: context,
                routeSettings: const RouteSettings(name: _modalRouteName),
                builder: (_) => const Text('sheet'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await _openModal(tester);

      expect(observer.modalRoutes.single, isA<ModalBottomSheetRoute<void>>());
    });
  });
}
