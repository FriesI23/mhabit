import 'dart:ui' show Tristate;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

class _Observer extends NavigatorObserver {
  final List<Route<dynamic>> dialogs = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == '/dialog') dialogs.add(route);
  }
}

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style modal focus, semantics and focus restoration', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                focusNode: focus,
                child: const Text('Open'),
                onPressed: () => showAdaptiveModalDialog<void>(
                  context: context,
                  styleOverride: style,
                  barrierDismissible: true,
                  builder: (context) => AdaptiveDialog(
                    title: const Text('Question'),
                    actions: [
                      AdaptiveDialogAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const AdaptiveDialogAction(
                        label: 'Unavailable',
                        enabled: false,
                      ),
                      AdaptiveDialogAction(
                        label: 'Delete',
                        isDestructiveAction: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
      final cancelSemantics = tester
          .getSemantics(find.text('Cancel'))
          .getSemanticsData();
      expect(cancelSemantics.label, 'Cancel');
      expect(cancelSemantics.flagsCollection.isButton, isTrue);
      expect(cancelSemantics.hasAction(SemanticsAction.tap), isTrue);
      final disabledSemantics = tester
          .getSemantics(find.text('Unavailable'))
          .getSemanticsData();
      expect(disabledSemantics.hasAction(SemanticsAction.tap), isFalse);
      expect(disabledSemantics.flagsCollection.isEnabled, Tristate.isFalse);
      for (final key in List.filled(5, LogicalKeyboardKey.tab)) {
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect(focus.hasFocus, isFalse);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Question'), findsNothing);
      expect(focus.hasFocus, isTrue);
      semantics.dispose();
    });

    for (final root in [true, false]) {
      testWidgets('$style root=$root scope, themes and typed result', (
        tester,
      ) async {
        final rootObserver = _Observer();
        final nestedObserver = _Observer();
        String? result;
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [rootObserver],
            home: Navigator(
              observers: [nestedObserver],
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => Theme(
                  data: ThemeData.dark(),
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(primaryColor: Colors.orange),
                    child: AdaptiveStyleScope(
                      override: style,
                      child: Builder(
                        builder: (context) => Scaffold(
                          body: TextButton(
                            child: const Text('Open'),
                            onPressed: () async {
                              result = await showAdaptiveModalDialog<String>(
                                context: context,
                                useRootNavigator: root,
                                barrierDismissible: true,
                                routeSettings: const RouteSettings(
                                  name: '/dialog',
                                ),
                                builder: (context) {
                                  expect(AdaptiveStyle.of(context), style);
                                  expect(
                                    Theme.of(context).brightness,
                                    Brightness.dark,
                                  );
                                  expect(
                                    CupertinoTheme.of(context).primaryColor,
                                    Colors.orange,
                                  );
                                  return AdaptiveDialog(
                                    title: const Text('Title'),
                                    actions: [
                                      AdaptiveDialogAction(
                                        label: 'Choose',
                                        onPressed: () =>
                                            Navigator.of(context).pop('chosen'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(rootObserver.dialogs.length, root ? 1 : 0);
        expect(nestedObserver.dialogs.length, root ? 0 : 1);
        expect(
          find.byType(
            style == AdaptiveStyle.apple ? CupertinoAlertDialog : AlertDialog,
          ),
          findsOneWidget,
        );
        expect(
          find.byType(
            style == AdaptiveStyle.apple
                ? CupertinoAdaptiveDialog
                : MaterialAdaptiveDialog,
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Choose'));
        await tester.pumpAndSettle();
        expect(result, 'chosen');
        expect(find.text('Open'), findsOneWidget);
      });
    }
    testWidgets('$style dismissals, disabled actions and repeated opening', (
      tester,
    ) async {
      Object? result = 'pending';
      var calls = 0;
      var dismissible = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Open'),
                onPressed: () async {
                  result = await showAdaptiveModalDialog<bool>(
                    context: context,
                    styleOverride: style,
                    barrierDismissible: dismissible,
                    builder: (_) => AdaptiveDialog(
                      title: const Text('Title'),
                      actions: [
                        AdaptiveDialogAction(
                          label: 'Disabled',
                          enabled: false,
                          onPressed: () => calls++,
                        ),
                        const AdaptiveDialogAction(label: 'No callback'),
                        AdaptiveDialogAction(
                          label: 'Delete',
                          isDestructiveAction: true,
                          onPressed: () => calls++,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      Future<void> open() async {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
      }

      await open();
      await tester.tap(find.text('Disabled'));
      await tester.tap(find.text('No callback'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isNull);
      await open();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsNothing);
      dismissible = false;
      await open();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsNothing);
      expect(result, isNull);
    });
    testWidgets('$style long content, RTL, resize and keyboard insets', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 900);
      addTearDown(tester.view.reset);
      final observer = _Observer();
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Open'),
                onPressed: () => showAdaptiveModalDialog<void>(
                  context: context,
                  styleOverride: style,
                  barrierDismissible: true,
                  routeSettings: const RouteSettings(name: '/dialog'),
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(2)),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: StatefulBuilder(
                        builder: (context, setState) => AdaptiveDialog(
                          title: Text('Count $count'),
                          content: Text(
                            List.filled(
                              80,
                              'Long explanation for this choice.',
                            ).join(' '),
                          ),
                          actions: [
                            AdaptiveDialogAction(
                              label: 'Action',
                              onPressed: () => setState(() => count++),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Action'));
      await tester.pump();
      for (final size in [const Size(360, 700), const Size(700, 360)]) {
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 80);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Count 1'), findsOneWidget);
        expect(find.text('Action').hitTestable(), findsOneWidget);
        expect(observer.dialogs, hasLength(1));
      }
    });
  }
}
