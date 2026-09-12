import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/modal_app_bar_region.dart';

class _MotionBuildHarness extends StatefulWidget {
  const _MotionBuildHarness();

  @override
  State<_MotionBuildHarness> createState() => _MotionBuildHarnessState();
}

class _MotionBuildHarnessState extends State<_MotionBuildHarness> {
  final ChangeNotifier motion = ChangeNotifier();
  bool notifyDuringBuild = false;

  void trigger() => setState(() => notifyDuringBuild = true);

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ModalWindowControlMotion(
    notifier: motion,
    child: Stack(
      children: [
        const ModalWindowControlAppBarRegion(child: SizedBox(height: 44)),
        if (notifyDuringBuild)
          Builder(
            builder: (context) {
              motion.notifyListeners();
              return const SizedBox.shrink();
            },
          ),
      ],
    ),
  );
}

Widget _buildTestApp({
  required AdaptiveStyle style,
  required AdaptiveModalPresentation presentation,
  required WidgetBuilder modalBuilder,
  EdgeInsets horizontalAvoidance = EdgeInsets.zero,
  EdgeInsets verticalAvoidance = EdgeInsets.zero,
  ThemeData? theme,
}) => AdaptiveWindowControlLayoutScope(
  horizontalAvoidance: horizontalAvoidance,
  verticalAvoidance: verticalAvoidance,
  owner: WindowControlLayoutOwner.appBar,
  child: MaterialApp(
    theme: theme,
    home: AdaptiveStyleScope(
      override: style,
      child: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showAdaptiveSheet<void>(
              context: context,
              presentationOverride: presentation,
              builder: modalBuilder,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

AdaptiveModal _fullModal({VoidCallback? onCloseRequested}) => AdaptiveModal(
  title: const Text('Title'),
  leadingAction: const Text('Leading'),
  actions: const [Text('Action')],
  pinnedBody: const Text('Pinned'),
  body: const SizedBox(height: 600, child: Text('Body')),
  bottomActions: const [Text('Bottom')],
  automaticallyImplyCloseButton: false,
  onCloseRequested: onCloseRequested,
);

void main() {
  testWidgets('modal motion notification during build is deferred safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _MotionBuildHarness())),
    );

    tester
        .state<_MotionBuildHarnessState>(find.byType(_MotionBuildHarness))
        .trigger();
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  for (final transformOnly in [false, true]) {
    testWidgets(
      'geometry tracks ${transformOnly ? 'paint' : 'layout'} movement of an unchanged region',
      (tester) async {
        final offset = ValueNotifier(Offset.zero);
        addTearDown(offset.dispose);
        EdgeInsets? avoidance;
        final region = ModalWindowControlAppBarRegion(
          child: Builder(
            builder: (context) {
              avoidance = AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                context,
              );
              return const SizedBox(height: 44);
            },
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveWindowControlLayoutScope(
              horizontalAvoidance: const EdgeInsets.only(left: 100),
              verticalAvoidance: const EdgeInsets.only(top: 80),
              owner: WindowControlLayoutOwner.appBar,
              child: ValueListenableBuilder<Offset>(
                valueListenable: offset,
                child: region,
                builder: (context, value, child) => Stack(
                  children: [
                    Positioned(
                      top: transformOnly ? 0 : value.dy,
                      left: transformOnly ? 0 : value.dx,
                      width: 300,
                      child: Transform.translate(
                        offset: transformOnly ? value : Offset.zero,
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(avoidance!.left, 100);

        offset.value = const Offset(40, 0);
        await tester.pumpAndSettle();
        expect(
          tester.widget(find.byType(ModalWindowControlAppBarRegion)),
          same(region),
        );
        expect(avoidance!.left, 60);

        offset.value = const Offset(40, 100);
        await tester.pumpAndSettle();
        expect(avoidance, EdgeInsets.zero);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('motion while idle schedules measurement and tolerates unmount', (
    tester,
  ) async {
    final motion = ChangeNotifier();
    addTearDown(motion.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ModalWindowControlMotion(
          notifier: motion,
          child: const ModalWindowControlAppBarRegion(
            child: SizedBox(height: 44),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    motion.notifyListeners();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('AdaptiveModal ownership', () {
    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} content does not create a route surface', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptiveStyleScope(
              override: style,
              child: const SizedBox(
                width: 320,
                height: 320,
                child: AdaptiveModal(body: Text('Body')),
              ),
            ),
          ),
        );

        expect(find.byType(Dialog), findsNothing);
        expect(find.byType(CupertinoPopupSurface), findsNothing);
      });
    }
  });

  group('AdaptiveModal layout', () {
    for (final style in AdaptiveStyle.values) {
      for (final presentation in AdaptiveModalPresentation.values) {
        for (final verticalExtent in const [1.0, 800.0]) {
          testWidgets(
            '${style.name} ${presentation.name} app bar uses 2D window-control overlap at $verticalExtent',
            (tester) async {
              tester.view.physicalSize = const Size(600, 800);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              EdgeInsets? observedAvoidance;

              await tester.pumpWidget(
                _buildTestApp(
                  style: style,
                  presentation: presentation,
                  horizontalAvoidance: const EdgeInsets.only(left: 100),
                  verticalAvoidance: EdgeInsets.only(top: verticalExtent),
                  modalBuilder: (_) => AdaptiveModal(
                    title: Builder(
                      builder: (context) {
                        observedAvoidance =
                            AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                              context,
                            );
                        return const Text('Title');
                      },
                    ),
                    body: const Text('Body'),
                  ),
                ),
              );
              await _open(tester);

              expect(observedAvoidance!.left, switch ((
                verticalExtent,
                presentation,
              )) {
                (800, AdaptiveModalPresentation.dialog) => allOf(
                  greaterThan(0),
                  lessThan(100),
                ),
                (800, AdaptiveModalPresentation.sheet) => 100,
                _ => 0,
              });
            },
          );
        }
      }
    }

    testWidgets('Apple dialog updates avoidance while moving vertically', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      EdgeInsets? observedAvoidance;

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          horizontalAvoidance: const EdgeInsets.only(left: 100),
          verticalAvoidance: const EdgeInsets.only(top: 80),
          modalBuilder: (_) => AdaptiveModal(
            title: Builder(
              builder: (context) {
                observedAvoidance =
                    AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(context);
                return const Text('Title');
              },
            ),
            body: const SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);
      expect(observedAvoidance!.left, greaterThan(0));

      final popup = find.byType(CupertinoPopupSurface);
      final drag = await tester.startGesture(
        Offset(tester.getCenter(popup).dx, tester.getTopLeft(popup).dy + 10),
      );
      await drag.moveBy(const Offset(0, 100));
      await tester.pump();
      await tester.pump();
      expect(observedAvoidance, EdgeInsets.zero);

      await drag.up();
      await tester.pumpAndSettle();
      expect(observedAvoidance!.left, greaterThan(0));
    });

    testWidgets('Apple sheet updates avoidance while moving vertically', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      EdgeInsets? observedAvoidance;

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.sheet,
          horizontalAvoidance: const EdgeInsets.only(left: 100),
          verticalAvoidance: const EdgeInsets.only(top: 80),
          modalBuilder: (_) => AdaptiveModal(
            title: Builder(
              builder: (context) {
                observedAvoidance =
                    AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(context);
                return const Text('Title');
              },
            ),
            body: const SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);
      expect(observedAvoidance!.left, greaterThan(0));

      final appBar = find.byKey(const ValueKey('adaptive-modal-app-bar'));
      final drag = await tester.startGesture(tester.getCenter(appBar));
      await drag.moveBy(const Offset(0, 100));
      await tester.pump();
      await tester.pump();
      expect(observedAvoidance, EdgeInsets.zero);

      await drag.up();
      await tester.pumpAndSettle();
      expect(observedAvoidance!.left, greaterThan(0));
    });

    testWidgets('Material sheet updates avoidance while moving vertically', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      EdgeInsets? observedAvoidance;

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.sheet,
          horizontalAvoidance: const EdgeInsets.only(left: 100),
          verticalAvoidance: const EdgeInsets.only(top: 120),
          modalBuilder: (_) => AdaptiveModal(
            title: Builder(
              builder: (context) {
                observedAvoidance =
                    AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(context);
                return const Text('Title');
              },
            ),
            body: const SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);
      expect(observedAvoidance!.left, greaterThan(0));

      final appBar = find.byKey(const ValueKey('adaptive-modal-app-bar'));
      final drag = await tester.startGesture(tester.getCenter(appBar));
      await drag.moveBy(const Offset(0, 20));
      await tester.pump();
      await drag.moveBy(const Offset(0, 100));
      await tester.pump();
      await tester.pump();
      expect(observedAvoidance, EdgeInsets.zero);

      await drag.up();
      await tester.pumpAndSettle();
      expect(observedAvoidance!.left, greaterThan(0));
    });

    testWidgets(
      'automatic Apple sheet updates avoidance while moving vertically',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        EdgeInsets? observedAvoidance;

        await tester.pumpWidget(
          AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: const EdgeInsets.only(left: 100),
            verticalAvoidance: const EdgeInsets.only(top: 80),
            owner: WindowControlLayoutOwner.appBar,
            child: MaterialApp(
              home: AdaptiveStyleScope(
                override: AdaptiveStyle.apple,
                child: Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () => showAdaptiveSheet<void>(
                        context: context,
                        builder: (_) => AdaptiveModal(
                          title: Builder(
                            builder: (context) {
                              observedAvoidance =
                                  AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                                    context,
                                  );
                              return const Text('Title');
                            },
                          ),
                          body: const SizedBox(
                            height: 1200,
                            child: Text('Body'),
                          ),
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await _open(tester);
        expect(
          tester
              .getTopLeft(find.byKey(const ValueKey('adaptive-modal-app-bar')))
              .dy,
          lessThan(80),
        );
        expect(observedAvoidance!.left, greaterThan(0));

        final body = find.byKey(const ValueKey('adaptive-modal-scroll-body'));
        final drag = await tester.startGesture(tester.getCenter(body));
        await drag.moveBy(const Offset(0, 100));
        await tester.pump();
        await tester.pump();
        expect(observedAvoidance, EdgeInsets.zero);

        await drag.up();
        await tester.pumpAndSettle();
        expect(observedAvoidance!.left, greaterThan(0));
      },
    );

    testWidgets(
      'automatic Material sheet updates avoidance while moving vertically',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        EdgeInsets? observedAvoidance;

        await tester.pumpWidget(
          AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: const EdgeInsets.only(left: 100),
            verticalAvoidance: const EdgeInsets.only(top: 120),
            owner: WindowControlLayoutOwner.appBar,
            child: MaterialApp(
              home: AdaptiveStyleScope(
                override: AdaptiveStyle.material,
                child: Builder(
                  builder: (context) => Scaffold(
                    body: ElevatedButton(
                      onPressed: () => showAdaptiveSheet<void>(
                        context: context,
                        builder: (_) => AdaptiveModal(
                          title: Builder(
                            builder: (context) {
                              observedAvoidance =
                                  AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                                    context,
                                  );
                              return const Text('Title');
                            },
                          ),
                          body: const SizedBox(
                            height: 1200,
                            child: Text('Body'),
                          ),
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await _open(tester);
        expect(observedAvoidance!.left, greaterThan(0));

        final body = find.byKey(const ValueKey('adaptive-modal-scroll-body'));
        final drag = await tester.startGesture(tester.getCenter(body));
        await drag.moveBy(const Offset(0, 100));
        await tester.pump();
        await tester.pump();
        expect(observedAvoidance, EdgeInsets.zero);

        await drag.up();
        await tester.pumpAndSettle();
        expect(observedAvoidance!.left, greaterThan(0));
      },
    );

    testWidgets('Material keeps title and actions around the scroll body', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => _fullModal(),
        ),
      );
      await _open(tester);

      final title = find.text('Title');
      final pinnedY = tester.getTopLeft(find.text('Pinned')).dy;
      final bodyY = tester.getTopLeft(find.text('Body')).dy;
      final bottomY = tester.getTopLeft(find.text('Bottom')).dy;
      final leadingY = tester.getTopLeft(find.text('Leading')).dy;
      final actionY = tester.getTopLeft(find.text('Action')).dy;

      expect(title, findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('adaptive-modal-app-bar')))
            .height,
        kToolbarHeight,
      );
      expect(find.byType(SliverAppBar), findsNothing);
      expect(leadingY, lessThan(pinnedY));
      expect(pinnedY, lessThan(bodyY));
      expect(bodyY, lessThan(bottomY));
      expect(bottomY, lessThan(actionY));
      expect(find.byType(Dialog), findsOneWidget);
      expect(
        tester.widget<Dialog>(find.byType(Dialog)).clipBehavior,
        Clip.antiAlias,
      );
    });

    testWidgets('Material modal keeps one themed surface color', (
      tester,
    ) async {
      const backgroundColor = Color(0xFF123456);
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.dialog,
          theme: ThemeData(
            dialogTheme: const DialogThemeData(
              backgroundColor: backgroundColor,
            ),
          ),
          modalBuilder: (_) =>
              const AdaptiveModal(title: Text('Title'), body: Text('Body')),
        ),
      );
      await _open(tester);

      expect(
        tester.widget<Dialog>(find.byType(Dialog)).backgroundColor,
        backgroundColor,
      );
      final appBarTheme = AppBarTheme.of(tester.element(find.byType(AppBar)));
      expect(appBarTheme.backgroundColor, backgroundColor);
      expect(appBarTheme.surfaceTintColor, Colors.transparent);
    });

    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} dialog does not stack bottom safe area', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(bottom: 34);
        tester.view.viewPadding = const FakeViewPadding(bottom: 34);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);

        await tester.pumpWidget(
          _buildTestApp(
            style: style,
            presentation: AdaptiveModalPresentation.dialog,
            modalBuilder: (_) => const AdaptiveModal(
              automaticallyImplyCloseButton: false,
              body: Text('Body'),
              actions: [Text('Action')],
            ),
          ),
        );
        await _open(tester);

        final frame = tester.getRect(
          find.byKey(const ValueKey('adaptive-modal-constraints')),
        );
        final actionBottom = switch (style) {
          AdaptiveStyle.material =>
            tester
                .getRect(
                  find.descendant(
                    of: find.byKey(const ValueKey('adaptive-modal-actions')),
                    matching: find.byType(OverflowBar),
                  ),
                )
                .bottom,
          AdaptiveStyle.apple =>
            tester
                .getRect(find.byKey(const ValueKey('adaptive-modal-actions')))
                .bottom,
        };
        expect(frame.bottom - actionBottom, switch (style) {
          AdaptiveStyle.material => 24,
          AdaptiveStyle.apple => 0,
        });
      });
    }

    testWidgets('automatic Material sheet removes the window top padding', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      tester.view.viewPadding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);

      await tester.pumpWidget(
        AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: EdgeInsets.zero,
          verticalAvoidance: const EdgeInsets.only(top: 24),
          owner: WindowControlLayoutOwner.appBar,
          child: MaterialApp(
            home: AdaptiveStyleScope(
              override: AdaptiveStyle.material,
              child: Builder(
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
          ),
        ),
      );
      await _open(tester);

      expect(
        tester
            .getRect(find.byKey(const ValueKey('adaptive-modal-app-bar')))
            .height,
        kToolbarHeight,
      );
    });

    testWidgets('Cupertino keeps navigation in app bar and actions vertical', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => _fullModal(),
        ),
      );
      await _open(tester);

      final leadingY = tester.getTopLeft(find.text('Leading')).dy;
      final titleY = tester.getTopLeft(find.text('Title')).dy;
      final pinnedY = tester.getTopLeft(find.text('Pinned')).dy;
      final bodyY = tester.getTopLeft(find.text('Body')).dy;
      final bottomY = tester.getTopLeft(find.text('Bottom')).dy;
      final appBarRect = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-app-bar')),
      );
      final actionRect = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-actions')),
      );

      expect(
        appBarRect.contains(tester.getCenter(find.text('Leading'))),
        isTrue,
      );
      expect(appBarRect.contains(tester.getCenter(find.text('Title'))), isTrue);
      expect(leadingY, lessThan(pinnedY));
      expect(titleY, lessThan(pinnedY));
      expect(pinnedY, lessThan(bodyY));
      expect(bodyY, lessThan(bottomY));
      expect(bottomY, lessThan(actionRect.top));
      expect(
        actionRect.contains(tester.getCenter(find.text('Action'))),
        isTrue,
      );
      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(find.byType(AdaptiveAppBar), findsOneWidget);
      final navigationBar = tester.widget<CupertinoNavigationBar>(
        find.byType(CupertinoNavigationBar),
      );
      expect(navigationBar.enableBackgroundFilterBlur, isTrue);
      expect(navigationBar.transitionBetweenRoutes, isFalse);
      expect(navigationBar.automaticBackgroundVisibility, isFalse);
      expect(navigationBar.backgroundColor!.a, 0);
      expect(navigationBar.border, isNull);
      final modalAppBarBackground = navigationBar.backgroundColor;

      final appBarBlur = find.descendant(
        of: find.byType(CupertinoNavigationBar),
        matching: find.byType(BackdropFilter),
      );
      expect(tester.widget<BackdropFilter>(appBarBlur).enabled, isTrue);
      _scrollControllerOf(tester)!.jumpTo(100);
      await tester.pumpAndSettle();
      expect(tester.widget<BackdropFilter>(appBarBlur).enabled, isTrue);
      expect(
        tester
            .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
            .backgroundColor,
        modalAppBarBackground,
      );
    });

    for (final presentation in AdaptiveModalPresentation.values) {
      testWidgets(
        'Cupertino ${presentation.name} uses its elevated dark background',
        (tester) async {
          await tester.pumpWidget(
            _buildTestApp(
              style: AdaptiveStyle.apple,
              presentation: presentation,
              theme: ThemeData(
                platform: TargetPlatform.iOS,
                brightness: Brightness.dark,
              ),
              modalBuilder: (_) =>
                  const AdaptiveModal(title: Text('Title'), body: Text('Body')),
            ),
          );
          await _open(tester);

          final appBarBackground = tester
              .widget<CupertinoNavigationBar>(
                find.byType(CupertinoNavigationBar),
              )
              .backgroundColor!;
          final navigationBar = tester.widget<CupertinoNavigationBar>(
            find.byType(CupertinoNavigationBar),
          );
          expect(navigationBar.automaticBackgroundVisibility, isFalse);
          expect(navigationBar.enableBackgroundFilterBlur, isTrue);
          expect(
            appBarBackground.toARGB32(),
            CupertinoColors.transparent.toARGB32(),
          );

          if (presentation == AdaptiveModalPresentation.sheet) {
            final sheetSurface = find.byKey(
              const ValueKey('adaptive-cupertino-sheet-surface'),
            );
            final popupSurface = find.byKey(
              const ValueKey('adaptive-cupertino-sheet-background'),
            );
            expect(
              tester
                  .widget<CupertinoPopupSurface>(popupSurface)
                  .isSurfacePainted,
              isTrue,
            );
            expect(
              tester.getBottomLeft(popupSurface).dy,
              tester.getBottomLeft(sheetSurface).dy + 13,
            );
          } else {
            expect(
              tester
                  .widget<CupertinoPopupSurface>(
                    find.byType(CupertinoPopupSurface).first,
                  )
                  .isSurfacePainted,
              isTrue,
            );
            expect(
              tester
                  .widget<CupertinoPageScaffoldBackgroundColor>(
                    find.byType(CupertinoPageScaffoldBackgroundColor),
                  )
                  .color
                  .toARGB32(),
              CupertinoColors.systemBackground.darkElevatedColor.toARGB32(),
            );
          }
        },
      );
    }

    testWidgets('Cupertino action region lays actions out vertically', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => const AdaptiveModal(
            automaticallyImplyCloseButton: false,
            body: Text('Body'),
            actions: [Text('First action'), Text('Second action')],
          ),
        ),
      );
      await _open(tester);

      expect(
        tester.getCenter(find.text('First action')).dy,
        lessThan(tester.getCenter(find.text('Second action')).dy),
      );
    });

    testWidgets(
      'Cupertino reserves leading for navigation and closes trailing',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            style: AdaptiveStyle.apple,
            presentation: AdaptiveModalPresentation.dialog,
            modalBuilder: (_) => const AdaptiveModal(
              title: Text('Title'),
              leadingAction: Text('Back'),
              body: Text('Body'),
            ),
          ),
        );
        await _open(tester);

        final titleX = tester.getCenter(find.text('Title')).dx;
        expect(tester.getCenter(find.text('Back')).dx, lessThan(titleX));
        expect(
          tester
              .getCenter(
                find.byKey(const ValueKey('adaptive-modal-implied-close')),
              )
              .dx,
          greaterThan(titleX),
        );
      },
    );

    testWidgets('Cupertino implied leading uses the shared back button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) =>
              const Navigator(onGenerateInitialRoutes: _modalInitialRoutes),
        ),
      );
      await _open(tester);

      final navigator = tester.state<NavigatorState>(
        find.descendant(
          of: find.byType(CupertinoPopupSurface),
          matching: find.byType(Navigator),
        ),
      );
      navigator.push<void>(
        CupertinoPageRoute<void>(
          builder: (_) => const AdaptiveModal(
            automaticallyImplyLeading: true,
            body: Text('Second'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveBackButton), findsOneWidget);
      expect(
        tester.getSize(find.byType(AdaptiveBackButton)),
        const Size.square(kMinInteractiveDimensionCupertino),
      );
      expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
    });

    testWidgets('Cupertino supplies its body text style', (tester) async {
      TextStyle? bodyStyle;
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => AdaptiveModal(
            body: Builder(
              builder: (context) {
                bodyStyle = DefaultTextStyle.of(context).style;
                return const Text('Body');
              },
            ),
          ),
        ),
      );
      await _open(tester);

      expect(bodyStyle?.fontSize, isNot(48));
      expect(bodyStyle?.decoration, isNot(TextDecoration.underline));
    });

    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} implied close dismisses the route', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildTestApp(
            style: style,
            presentation: AdaptiveModalPresentation.dialog,
            modalBuilder: (_) => const AdaptiveModal(body: Text('Body')),
          ),
        );
        await _open(tester);

        await tester.tap(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Body'), findsNothing);
      });
    }

    testWidgets('onCloseRequested takes over implied close', (tester) async {
      var closeRequests = 0;
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => AdaptiveModal(
            body: const Text('Body'),
            onCloseRequested: () => closeRequests += 1,
          ),
        ),
      );
      await _open(tester);

      await tester.tap(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
      );
      await tester.pumpAndSettle();

      expect(closeRequests, 1);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('dialog honors caller constraints', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.dialog,
          modalBuilder: (_) => const AdaptiveModal(
            constraints: BoxConstraints(maxWidth: 300, maxHeight: 250),
            body: Text('Body'),
          ),
        ),
      );
      await _open(tester);

      final size = tester.getSize(
        find.byKey(const ValueKey('adaptive-modal-constraints')),
      );
      expect(size.width, lessThanOrEqualTo(300));
      expect(size.height, lessThanOrEqualTo(250));
    });

    for (final testCase in <(AdaptiveStyle, AdaptiveModalPresentation)>[
      (AdaptiveStyle.material, AdaptiveModalPresentation.dialog),
      (AdaptiveStyle.apple, AdaptiveModalPresentation.dialog),
    ]) {
      testWidgets(
        '${testCase.$1.name} ${testCase.$2.name} uses the shared height cap',
        (tester) async {
          tester.view.physicalSize = const Size(1000, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            _buildTestApp(
              style: testCase.$1,
              presentation: testCase.$2,
              modalBuilder: (_) => const AdaptiveModal(
                body: SizedBox(height: 1200, child: Text('Body')),
              ),
            ),
          );
          await _open(tester);

          expect(
            tester
                .getSize(
                  find.byKey(const ValueKey('adaptive-modal-constraints')),
                )
                .height,
            AdaptiveModalConstraints.maxHeight,
          );
        },
      );
    }

    testWidgets('apple sheet uses the Cupertino default 8 percent top gap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.sheet,
          modalBuilder: (_) => const AdaptiveModal(
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);

      expect(
        tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .height,
        1200 * 0.92,
      );
    });

    testWidgets('material sheet returns to the shared height cap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.sheet,
          modalBuilder: (_) => const AdaptiveModal(
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);

      expect(
        tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .height,
        AdaptiveModalConstraints.maxHeight,
      );
    });
  });

  group('AdaptiveModal scrolling', () {
    for (final style in AdaptiveStyle.values) {
      testWidgets('${style.name} sheet supplies the body scroll controller', (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildTestApp(
            style: style,
            presentation: AdaptiveModalPresentation.sheet,
            modalBuilder: (_) => const AdaptiveModal(
              body: SizedBox(height: 1200, child: Text('Body')),
            ),
          ),
        );
        await _open(tester);

        final scrollController = _scrollControllerOf(tester);
        expect(scrollController, isNotNull);
        expect(scrollController!.hasClients, isTrue);
        if (style == AdaptiveStyle.material) {
          expect(find.byType(BottomSheet), findsOneWidget);
        } else {
          expect(
            scrollController.runtimeType.toString(),
            contains('CupertinoSheet'),
          );
        }
      });
    }

    testWidgets('pinned body remains fixed while the body scrolls', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.material,
          presentation: AdaptiveModalPresentation.sheet,
          modalBuilder: (_) => const AdaptiveModal(
            pinnedBody: Text('Pinned'),
            body: SizedBox(height: 1200, child: Text('Body')),
          ),
        ),
      );
      await _open(tester);

      final expandedPinnedY = tester.getTopLeft(find.text('Pinned')).dy;
      final scrollController = _scrollControllerOf(tester)!;
      scrollController.jumpTo(200);
      await tester.pump();
      final pinnedY = tester.getTopLeft(find.text('Pinned')).dy;
      expect(pinnedY, expandedPinnedY);
      scrollController.jumpTo(300);
      await tester.pump();

      expect(tester.getTopLeft(find.text('Pinned')).dy, pinnedY);
      expect(scrollController.offset, 300);
    });

    testWidgets('Cupertino sheet keeps actions visible at compact height', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          style: AdaptiveStyle.apple,
          presentation: AdaptiveModalPresentation.sheet,
          modalBuilder: (_) => AdaptiveModal(
            automaticallyImplyCloseButton: false,
            body: const SizedBox(height: 1200, child: Text('Body')),
            actions: [
              CupertinoButton(onPressed: () {}, child: const Text('Action')),
            ],
          ),
        ),
      );
      await _open(tester);

      final frame = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-constraints')),
      );
      final action = find.byKey(const ValueKey('adaptive-modal-actions'));
      final initialActionY = tester.getCenter(action).dy;
      expect(frame.contains(tester.getCenter(action)), isTrue);

      _scrollControllerOf(tester)!.jumpTo(200);
      await tester.pump();

      expect(tester.getCenter(action).dy, initialActionY);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('survives RTL, large text, keyboard, and a compact window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _buildTestApp(
        style: AdaptiveStyle.material,
        presentation: AdaptiveModalPresentation.sheet,
        modalBuilder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(3),
            viewInsets: const EdgeInsets.only(bottom: 120),
          ),
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: AdaptiveModal(
              title: Text('A very long modal title'),
              actions: [Text('A very long action')],
              pinnedBody: Text('Pinned controls'),
              body: SizedBox(height: 800, child: Text('Scrollable body')),
              bottomActions: [Text('Destructive action')],
            ),
          ),
        ),
      ),
    );
    await _open(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Scrollable body', skipOffstage: false), findsOneWidget);
  });
}

List<Route<dynamic>> _modalInitialRoutes(
  NavigatorState navigator,
  String initialRoute,
) => [
  CupertinoPageRoute<void>(
    builder: (_) => const AdaptiveModal(
      automaticallyImplyLeading: true,
      body: Text('First'),
    ),
  ),
];

ScrollController? _scrollControllerOf(WidgetTester tester) {
  final widget = tester.widget(
    find.byKey(const ValueKey('adaptive-modal-scroll-body')),
  );
  return switch (widget) {
    ScrollView() => widget.controller,
    SingleChildScrollView() => widget.controller,
    _ => throw StateError('Unsupported modal scroll view: $widget'),
  };
}
