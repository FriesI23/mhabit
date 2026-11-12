// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoButton, CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/adaptive_ui_theme.dart';
import '../../../support/stub/about_info.dart';

import '../../../support/stub/shared_preferences.dart';

void main() {
  Future<BuildContext> mountOwner(
    WidgetTester tester,
    AppSupportOwner owner, {
    AdaptiveStyle style = AdaptiveStyle.material,
    double scale = 1,
  }) async {
    late BuildContext caller;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: ChangeNotifierProvider.value(
          value: owner,
          child: TestAdaptiveUiTheme(
            update: (theme) => theme.copyWith(style: style),
            child: Builder(
              builder: (context) {
                caller = context;
                return const Scaffold();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return caller;
  }

  Finder action(AppSupportAction value) =>
      find.byKey(ValueKey('app-support-action-${value.name}'));

  for (final style in AdaptiveStyle.values) {
    for (final storeSelection in [false, true]) {
      testWidgets(
        '$style open preview keeps GitHub and follows every channel before store=$storeSelection',
        (tester) async {
          final previous = PreferencesTestStore.instance;
          PreferencesTestStore.instance = InMemoryPreferencesStore.empty();
          addTearDown(() => PreferencesTestStore.instance = previous);
          final owner = createTestAppSupportOwner(
            loadInfo: () async => stubAboutInfo(),
          )..setDistribution(AppDistribution.github);
          addTearDown(owner.dispose);
          final controller = AppSupportDialogController();
          addTearDown(controller.cancel);
          final caller = await mountOwner(tester, owner, style: style);
          final before = (await SharedPreferences.getInstance()).getAll();
          final destinations = <Uri>[];
          AppSupportResult? result;
          final preview = owner.previewDialog(
            canShowDialog: () => true,
            showSupportDialog: (info) async {
              result = await showAppSupportDialog(
                context: caller,
                info: info,
                controller: controller,
                hideDonate: true,
                openUrl: (uri) async {
                  destinations.add(uri);
                  return true;
                },
              );
              return result!;
            },
          );
          await tester.pumpAndSettle();
          final dialog = tester.element(find.byType(AdaptiveDialog));
          for (final distribution in AppDistribution.values) {
            owner.setDistribution(distribution);
            await tester.pumpAndSettle();
            final target = owner.channelAction;
            expect(
              action(AppSupportAction.githubStar).hitTestable(),
              findsOneWidget,
            );
            for (final store in [
              AppSupportAction.googlePlay,
              AppSupportAction.appStore,
              AppSupportAction.microsoftStore,
              AppSupportAction.flathub,
            ]) {
              expect(
                action(store).hitTestable(),
                store == target ? findsOneWidget : findsNothing,
              );
            }
            if (distribution == AppDistribution.fdroid) {
              expect(target, AppSupportAction.githubStar);
              expect(find.text('Open F-Droid'), findsNothing);
            }
            if (distribution == AppDistribution.flathub) {
              expect(
                find.text('Favorite on Flathub').hitTestable(),
                findsOneWidget,
              );
              expect(find.text('Open Flathub'), findsNothing);
            }
            expect(tester.element(find.byType(AdaptiveDialog)), dialog);
            expect((await SharedPreferences.getInstance()).getAll(), before);
          }
          owner.setDistribution(AppDistribution.appStore);
          await tester.pumpAndSettle();
          final selected = storeSelection
              ? AppSupportAction.appStore
              : AppSupportAction.githubStar;
          await tester.tap(action(selected));
          await tester.pumpAndSettle();
          expect(await preview, isTrue);
          expect(
            result,
            storeSelection
                ? AppSupportResult.storeOpened
                : AppSupportResult.githubOpened,
          );
          expect(destinations, [selected.resolveUrl(stubAboutInfo())]);
          expect(owner.initializationComplete, isFalse);
          expect((await SharedPreferences.getInstance()).getAll(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final outcome in ['opened', 'false', 'exception']) {
      testWidgets(
        '$style store preview closes before link $outcome and never saves history',
        (tester) async {
          final previous = PreferencesTestStore.instance;
          PreferencesTestStore.instance = InMemoryPreferencesStore.empty();
          addTearDown(() => PreferencesTestStore.instance = previous);
          final owner = createTestAppSupportOwner(
            loadInfo: () async => stubAboutInfo(),
          )..setDistribution(AppDistribution.googlePlay);
          addTearDown(owner.dispose);
          final caller = await mountOwner(tester, owner, style: style);
          final before = (await SharedPreferences.getInstance()).getAll();
          final destinations = <Uri>[];
          var closedBeforeOpen = false;
          AppSupportResult? result;
          final preview = owner.previewDialog(
            canShowDialog: () => true,
            showSupportDialog: (info) async {
              result = await showAppSupportDialog(
                context: caller,
                info: info,
                hideDonate: true,
                openUrl: (target) async {
                  closedBeforeOpen = find
                      .byType(AdaptiveDialog)
                      .evaluate()
                      .isEmpty;
                  destinations.add(target);
                  if (outcome == 'exception') throw StateError('launch failed');
                  return outcome == 'opened';
                },
              );
              return result!;
            },
          );
          await tester.pumpAndSettle();
          expect(
            action(AppSupportAction.githubStar).hitTestable(),
            findsOneWidget,
          );
          await tester.tap(action(AppSupportAction.googlePlay));
          await tester.pumpAndSettle();
          expect(await preview, isTrue);
          expect(closedBeforeOpen, isTrue);
          expect(destinations, [
            AppSupportAction.googlePlay.resolveUrl(stubAboutInfo()),
          ]);
          expect(
            result,
            outcome == 'opened'
                ? AppSupportResult.storeOpened
                : AppSupportResult.actionFailed,
          );
          expect(
            find.text(L10n.of(caller)!.appSupport_linkFailed),
            outcome == 'opened' ? findsNothing : findsOneWidget,
          );
          expect((await SharedPreferences.getInstance()).getAll(), before);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$style two support actions remain reachable in a narrow large-text dialog',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final previous = PreferencesTestStore.instance;
        PreferencesTestStore.instance = InMemoryPreferencesStore.empty();
        addTearDown(() => PreferencesTestStore.instance = previous);
        final owner = createTestAppSupportOwner()
          ..setDistribution(AppDistribution.microsoftStore);
        addTearDown(owner.dispose);
        final caller = await mountOwner(
          tester,
          owner,
          style: style,
          scale: 1.8,
        );
        for (final target in [
          AppSupportAction.githubStar,
          AppSupportAction.microsoftStore,
        ]) {
          final controller = AppSupportDialogController();
          addTearDown(controller.cancel);
          final opened = <Uri>[];
          final result = showAppSupportDialog(
            context: caller,
            info: stubAboutInfo(),
            controller: controller,
            hideDonate: true,
            openUrl: (uri) async {
              opened.add(uri);
              return true;
            },
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(action(target));
          await tester.pumpAndSettle();
          expect(action(target).hitTestable(), findsOneWidget);
          final viewport = tester.getRect(find.byType(AppSupportCarousel));
          final rect = tester.getRect(action(target));
          expect(rect.left, greaterThanOrEqualTo(viewport.left));
          expect(rect.right, lessThanOrEqualTo(viewport.right));
          await tester.tap(action(target));
          await tester.pumpAndSettle();
          expect(
            await result,
            target == AppSupportAction.githubStar
                ? AppSupportResult.githubOpened
                : AppSupportResult.storeOpened,
          );
          expect(opened, [target.resolveUrl(stubAboutInfo())]);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('aborting an unused dialog controller schedules no frame', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final controller = AppSupportDialogController();
    controller.cancel();
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

        Future<AppSupportResult> open({
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
          expect(find.byType(AppSupportCarousel), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(await result, AppSupportResult.githubOpened);
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
          await tester.tap(find.text('Star on GitHub'));
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveDialog), findsNothing);
          expect(calls, 1);
          expect(closedBeforeOpen, isTrue);
          pending.complete(true);
          await tester.pumpAndSettle();
          expect(await result, AppSupportResult.githubOpened);
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
              await tester.tap(find.text('Star on GitHub'));
              await tester.pumpAndSettle();
              expect(await result, AppSupportResult.actionFailed);
              expect(find.byType(AdaptiveDialog), findsNothing);
              expect(
                find.text('Unable to complete this action. Please try again.'),
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
            addTearDown(controller.cancel);
            final result = open(controller: controller);
            if (close == 'earlyAbort') controller.cancel();
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
                controller.cancel();
              case 'earlyAbort':
                break;
            }
            await tester.pumpAndSettle();
            expect(await result, switch (close) {
              'never' => AppSupportResult.stopReminding,
              'remove' || 'abort' || 'earlyAbort' => AppSupportResult.cancelled,
              _ => AppSupportResult.remindLater,
            });
          });
        }

        testWidgets(
          'invalidation after selection drops late successful result',
          (tester) async {
            await mount(tester);
            final controller = AppSupportDialogController();
            addTearDown(controller.cancel);
            final pending = Completer<bool>();
            final result = open(
              controller: controller,
              action: (_) => pending.future,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Star on GitHub'));
            await tester.pumpAndSettle();
            controller.cancel();
            pending.complete(true);
            await tester.pumpAndSettle();
            expect(await result, AppSupportResult.cancelled);
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
            expect(await result, AppSupportResult.otherActionCompleted);
            var donationShown = false;
            var closedBeforeDonation = false;
            final second = open(
              info: info,
              donation: (_) async {
                closedBeforeDonation = find
                    .byType(AdaptiveDialog)
                    .evaluate()
                    .isEmpty;
                donationShown = true;
              },
            );
            await tester.pumpAndSettle();
            // Existing QR donation methods make page one the donation card.
            await tester.tap(find.byKey(const ValueKey('app-support-page-1')));
            await tester.pumpAndSettle();
            await tester.tap(
              find.widgetWithText(
                style == AdaptiveStyle.apple ? CupertinoButton : FilledButton,
                'Donate',
              ),
            );
            await tester.pumpAndSettle();
            expect(await second, AppSupportResult.otherActionCompleted);
            expect(donationShown, isTrue);
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
                ? 'GitHub Star'
                : 'Star on GitHub';
            await tester.ensureVisible(find.text(label));
            await tester.pumpAndSettle();
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(await result, AppSupportResult.githubOpened);
          });
        }
      });
    }
  }
}
