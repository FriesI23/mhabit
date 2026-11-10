// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../support/adaptive_ui_theme.dart';

void main() {
  testWidgets(
    'host invalidation removes only the prompt route without a user result',
    (tester) async {
      final controller = AppSupportDialogController();
      addTearDown(controller.dispose);
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Builder(
            builder: (value) {
              context = value;
              return const Scaffold();
            },
          ),
        ),
      );
      final result = showAppSupportDialog(
        context: context,
        target: Uri.parse('https://github.com/FriesI23/mhabit'),
        controller: controller,
      );
      await tester.pumpAndSettle();
      controller.abort();
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveDialog), findsNothing);
      expect(await result, AppSupportPromptResult.aborted);
      expect(tester.takeException(), isNull);
    },
  );
  for (final copy in [
    (
      const Locale('en'),
      'Support Table Habit',
      'Your support helps improve Table Habit and reach more people.',
      'Go to Google Play',
    ),
    (
      const Locale('zh'),
      '支持 Table Habit',
      '你的支持能帮助 Table Habit 持续改进，让更多人发现它。',
      '前往 Google Play',
    ),
    (
      const Locale('de'),
      'Support Table Habit',
      'Your support helps improve Table Habit and reach more people.',
      'Go to Google Play',
    ),
  ]) {
    testWidgets('shared copy and parameterized destination for ${copy.$1}', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          locale: copy.$1,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Builder(
            builder: (value) {
              context = value;
              return const Scaffold();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final target = Uri.parse('https://example.com/support');
      Uri? opened;
      final result = showAppSupportDialog(
        context: context,
        target: target,
        platformName: 'Google Play',
        openUrl: (uri) async {
          opened = uri;
          return true;
        },
      );
      await tester.pumpAndSettle();
      expect(find.text(copy.$2), findsOneWidget);
      expect(find.text(copy.$3), findsOneWidget);
      expect(find.text(copy.$4), findsOneWidget);
      expect(find.text('Go to GitHub'), findsNothing);
      await tester.tap(find.text(copy.$4));
      await tester.pumpAndSettle();
      expect(opened, target);
      expect(await result, AppSupportPromptResult.githubOpened);
    });
  }
  for (final style in AdaptiveStyle.values) {
    for (final brightness in Brightness.values) {
      group('$style $brightness', () {
        late BuildContext context;
        late GlobalKey<NavigatorState> navigator;
        Future<void> mount(WidgetTester tester) async {
          navigator = GlobalKey<NavigatorState>();
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigator,
              theme: ThemeData(brightness: brightness),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              locale: const Locale('en'),
              home: TestAdaptiveUiTheme(
                update: (theme) => theme.copyWith(style: style),
                child: Builder(
                  builder: (value) {
                    context = value;
                    return const Scaffold();
                  },
                ),
              ),
            ),
          );
        }

        Future<AppSupportPromptResult> open(
          Future<bool> Function(Uri) action,
        ) => showAppSupportDialog(
          context: context,
          target: Uri.parse('https://github.com/FriesI23/mhabit'),
          openUrl: action,
        );

        testWidgets(
          'desktop keyboard chooses bottom actions in a fixed dialog',
          (tester) async {
            tester.view.physicalSize = const Size(1280, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await mount(tester);
            for (var index = 0; index < 3; index++) {
              final result = open((_) async => true);
              await tester.pumpAndSettle();
              expect(
                find.byType(
                  style == AdaptiveStyle.apple
                      ? CupertinoAlertDialog
                      : AlertDialog,
                ),
                findsOneWidget,
              );
              expect(find.byType(BottomSheet), findsNothing);
              expect(find.byType(CloseButton), findsNothing);
              for (var tab = 0; tab <= index; tab++) {
                await tester.sendKeyEvent(LogicalKeyboardKey.tab);
                await tester.pump();
              }
              await tester.sendKeyEvent(LogicalKeyboardKey.enter);
              await tester.pumpAndSettle();
              expect(find.byType(AdaptiveDialog), findsNothing);
              expect(
                await result,
                [
                  AppSupportPromptResult.never,
                  AppSupportPromptResult.later,
                  AppSupportPromptResult.githubOpened,
                ][index],
              );
            }
          },
        );

        testWidgets('never uses destructive appearance', (tester) async {
          await mount(tester);
          final result = open((_) async => true);
          await tester.pumpAndSettle();
          final dialog = tester.widget<AdaptiveDialog>(
            find.byType(AdaptiveDialog),
          );
          expect(dialog.actions.first.isDestructiveAction, isTrue);
          expect(
            dialog.actions
                .skip(1)
                .every((action) => !action.isDestructiveAction),
            isTrue,
          );
          if (style == AdaptiveStyle.apple) {
            expect(
              tester
                  .widget<CupertinoDialogAction>(
                    find.widgetWithText(
                      CupertinoDialogAction,
                      "Don't remind me again",
                    ),
                  )
                  .isDestructiveAction,
              isTrue,
            );
          } else {
            final button = tester.widget<TextButton>(
              find.widgetWithText(TextButton, "Don't remind me again"),
            );
            final color = Theme.of(
              tester.element(find.byType(AdaptiveDialog)),
            ).colorScheme.error;
            expect(button.style!.foregroundColor!.resolve({}), color);
          }
          await tester.tap(find.text("Don't remind me again"));
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.never);
        });

        testWidgets('three actions return distinct results', (tester) async {
          await mount(tester);
          for (final pair in [
            ('Remind me later', AppSupportPromptResult.later),
            ("Don't remind me again", AppSupportPromptResult.never),
            ('Go to GitHub', AppSupportPromptResult.githubOpened),
          ]) {
            final result = open((_) async => true);
            await tester.pumpAndSettle();
            await tester.tap(find.text(pair.$1));
            await tester.pumpAndSettle();
            expect(await result, pair.$2);
          }
        });

        testWidgets('false and exception keep dialog open for retry', (
          tester,
        ) async {
          await mount(tester);
          var attempts = 0;
          final result = open((_) async {
            attempts++;
            if (attempts == 1) return false;
            if (attempts == 2) throw StateError('launcher unavailable');
            return true;
          });
          await tester.pumpAndSettle();
          for (var i = 0; i < 2; i++) {
            await tester.tap(find.text('Go to GitHub'));
            await tester.pumpAndSettle();
            expect(
              find.text('Unable to open the link. Please try again.'),
              findsOneWidget,
            );
          }
          await tester.tap(find.text('Go to GitHub'));
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.githubOpened);
          expect(attempts, 3);
        });

        for (final close in ['barrier', 'back', 'escape', 'remove']) {
          testWidgets('$close distinguishes dismiss from removal', (
            tester,
          ) async {
            await mount(tester);
            final result = open((_) async => true);
            await tester.pumpAndSettle();
            switch (close) {
              case 'barrier':
                await tester.tapAt(const Offset(4, 4));
              case 'back':
                await navigator.currentState!.maybePop();
              case 'escape':
                await tester.sendKeyEvent(LogicalKeyboardKey.escape);
              case 'remove':
                final route = ModalRoute.of(
                  tester.element(find.byType(AdaptiveDialog)),
                )!;
                navigator.currentState!.removeRoute(route);
            }
            await tester.pumpAndSettle();
            expect(
              await result,
              close == 'remove'
                  ? AppSupportPromptResult.aborted
                  : AppSupportPromptResult.later,
            );
          });
        }

        testWidgets('double click and late completion after dismiss', (
          tester,
        ) async {
          await mount(tester);
          final pending = Completer<bool>();
          var calls = 0;
          final result = open((_) {
            calls++;
            return pending.future;
          });
          await tester.pumpAndSettle();
          await tester.tap(find.text('Go to GitHub'));
          await tester.pump();
          await tester.tap(find.text('Go to GitHub'));
          await tester.pump();
          expect(calls, 1);
          final dialog = tester.widget<AdaptiveDialog>(
            find.byType(AdaptiveDialog),
          );
          expect(dialog.actions.every((action) => !action.enabled), isTrue);
          await navigator.currentState!.maybePop();
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.later);
          pending.complete(true);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('small window remains operable', (tester) async {
          tester.view.physicalSize = const Size(320, 480);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await mount(tester);
          final result = open((_) async => true);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(BottomSheet), findsNothing);
          expect(find.byType(CloseButton), findsNothing);
          await tester.ensureVisible(find.text('Go to GitHub'));
          await tester.tap(find.text('Go to GitHub'));
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.githubOpened);
        });
      });
    }
  }
}
