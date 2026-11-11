// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoButton, CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../support/adaptive_ui_theme.dart';
import '../../../support/stub/about_info.dart';

void main() {
  testWidgets('aborting an unused dialog controller schedules no frame', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final controller = AppSupportDialogController();
    controller.abort();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final style in AdaptiveStyle.values) {
    for (final brightness in Brightness.values) {
      group('$style $brightness', () {
        late BuildContext context;
        late GlobalKey<NavigatorState> navigator;
        Future<void> mount(
          WidgetTester tester, {
          Locale locale = const Locale('en'),
          double scale = 1,
        }) async {
          navigator = GlobalKey<NavigatorState>();
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigator,
              theme: ThemeData(brightness: brightness),
              locale: locale,
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(scale),
                ),
                child: child!,
              ),
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
          await tester.pumpAndSettle();
        }

        Future<AppSupportPromptResult> open({
          Future<bool> Function(Uri)? action,
          AppSupportDialogController? controller,
          AboutInfo? info,
          Future<void> Function(AboutInfo)? donation,
        }) => showAppSupportDialog(
          context: context,
          info:
              info ??
              stubAboutInfo(
                sourceCodeUrl: 'https://github.com/FriesI23/mhabit',
              ),
          openUrl: action ?? (_) async => true,
          controller: controller,
          showDonation: donation,
          hideDonate: donation == null,
        );

        testWidgets('Tab and Enter activate the card support action', (
          tester,
        ) async {
          await mount(tester);
          final result = open();
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<AppSupportCarousel>(find.byType(AppSupportCarousel))
                .animateStars,
            isTrue,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.supportOpened);
        });

        testWidgets('business action closes before launching and runs once', (
          tester,
        ) async {
          await mount(tester);
          final pending = Completer<bool>();
          var calls = 0;
          var closedBeforeOpen = false;
          final result = open(
            action: (_) {
              calls++;
              closedBeforeOpen = find.byType(AdaptiveDialog).evaluate().isEmpty;
              return pending.future;
            },
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(
              style == AdaptiveStyle.apple ? CupertinoAlertDialog : AlertDialog,
            ),
            findsOneWidget,
          );
          expect(find.byType(BottomSheet), findsNothing);
          expect(find.byType(CloseButton), findsNothing);
          await tester.tap(find.text('Go to GitHub'));
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveDialog), findsNothing);
          expect(calls, 1);
          expect(closedBeforeOpen, isTrue);
          pending.complete(true);
          await tester.pumpAndSettle();
          expect(await result, AppSupportPromptResult.supportOpened);
        });

        for (final failsWithException in [false, true]) {
          testWidgets(
            'closed dialog reports link failure ($failsWithException)',
            (tester) async {
              await mount(tester);
              final result = open(
                action: (_) async {
                  if (failsWithException) throw StateError('launcher failed');
                  return false;
                },
              );
              await tester.pumpAndSettle();
              await tester.tap(find.text('Go to GitHub'));
              await tester.pumpAndSettle();
              expect(await result, AppSupportPromptResult.actionFailed);
              expect(find.byType(AdaptiveDialog), findsNothing);
              expect(
                find.text('Unable to open the link. Please try again.'),
                findsOneWidget,
              );
            },
          );
        }

        for (final close in [
          'never',
          'later',
          'barrier',
          'back',
          'escape',
          'remove',
          'abort',
          'earlyAbort',
        ]) {
          testWidgets('$close returns the correct reminder outcome', (
            tester,
          ) async {
            await mount(tester);
            final controller = AppSupportDialogController();
            addTearDown(controller.abort);
            final result = open(controller: controller);
            if (close == 'earlyAbort') controller.abort();
            await tester.pumpAndSettle();
            switch (close) {
              case 'never':
                final dialog = tester.widget<AdaptiveDialog>(
                  find.byType(AdaptiveDialog),
                );
                expect(dialog.actions.first.isDestructiveAction, isTrue);
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
                }
                await tester.tap(find.text("Don't remind me again"));
              case 'later':
                await tester.tap(find.text('Remind me later'));
              case 'barrier':
                await tester.tapAt(const Offset(4, 4));
              case 'back':
                await navigator.currentState!.maybePop();
              case 'escape':
                await tester.sendKeyEvent(LogicalKeyboardKey.escape);
              case 'remove':
                navigator.currentState!.removeRoute(
                  ModalRoute.of(tester.element(find.byType(AdaptiveDialog)))!,
                );
              case 'abort':
                controller.abort();
              case 'earlyAbort':
                break;
            }
            await tester.pumpAndSettle();
            expect(await result, switch (close) {
              'never' => AppSupportPromptResult.never,
              'remove' ||
              'abort' ||
              'earlyAbort' => AppSupportPromptResult.aborted,
              _ => AppSupportPromptResult.later,
            });
          });
        }

        testWidgets(
          'invalidation after selection drops late successful result',
          (tester) async {
            await mount(tester);
            final controller = AppSupportDialogController();
            addTearDown(controller.abort);
            final pending = Completer<bool>();
            final result = open(
              controller: controller,
              action: (_) => pending.future,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Go to GitHub'));
            await tester.pumpAndSettle();
            controller.abort();
            pending.complete(true);
            await tester.pumpAndSettle();
            expect(await result, AppSupportPromptResult.aborted);
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'auxiliary link and donation close before execution without rate',
          (tester) async {
            await mount(tester);
            final info = stubAboutInfo();
            final result = open(info: info);
            await tester.pumpAndSettle();
            await tester.drag(find.byType(PageView), const Offset(-500, 0));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Source code'));
            await tester.pumpAndSettle();
            expect(await result, AppSupportPromptResult.auxiliaryAction);
            var donated = false;
            var closedBeforeDonation = false;
            final second = open(
              info: info,
              donation: (_) async {
                closedBeforeDonation = find
                    .byType(AdaptiveDialog)
                    .evaluate()
                    .isEmpty;
                donated = true;
              },
            );
            await tester.pumpAndSettle();
            // Existing QR donation methods make a donation card available.
            await tester.drag(find.byType(PageView), const Offset(-500, 0));
            await tester.pumpAndSettle();
            await tester.drag(find.byType(PageView), const Offset(-500, 0));
            await tester.pumpAndSettle();
            await tester.tap(
              find.widgetWithText(
                style == AdaptiveStyle.apple ? CupertinoButton : TextButton,
                'Donate',
              ),
            );
            await tester.pumpAndSettle();
            expect(await second, AppSupportPromptResult.auxiliaryAction);
            expect(donated, isTrue);
            expect(closedBeforeDonation, isTrue);
          },
        );

        for (final locale in [
          const Locale('en'),
          const Locale('zh'),
          const Locale('de'),
        ]) {
          testWidgets('narrow window, large text and localized copy $locale', (
            tester,
          ) async {
            tester.view.physicalSize = const Size(320, 480);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await mount(tester, locale: locale, scale: 2);
            final result = open();
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final label = locale.languageCode == 'zh'
                ? '前往 GitHub'
                : 'Go to GitHub';
            await tester.ensureVisible(find.text(label));
            await tester.pumpAndSettle();
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(await result, AppSupportPromptResult.supportOpened);
          });
        }
      });
    }
  }
}
