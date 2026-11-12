// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/adaptive_ui_theme.dart';

import '../../../support/stub/shared_preferences.dart';

const _info = AboutInfo(
  sourceCodeUrl: 'https://example.com/project',
  issueTrackerUrl: 'https://example.com/issues',
  contactEmail: '',
  donateBuyMeACoffeeToken: 'coffee',
  donatePaypalToken: '',
  donateCryptoBTCAddr: '',
  donateCryptoETHAddr: '',
  donateCryptoBNBAddr: '',
  donateCryptoAVAXAddr: '',
  donateCryptoFTMAddr: '',
);

class _PendingPreferences {
  final ready = Completer<SharedPreferences>();
}

class _FailingSavePreferences extends InMemoryPreferencesStore {
  _FailingSavePreferences(this._shouldFail) : super.empty();

  final bool Function() _shouldFail;

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (_shouldFail() && key == 'flutter.appSupportReminder') {
      return false;
    }
    return super.setValue(type, key, value);
  }
}

void main() {
  setUp(() {
    PreferencesTestStore.instance = InMemoryPreferencesStore.empty();
    TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    AdaptiveStyle style = AdaptiveStyle.material,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: TestAdaptiveUiTheme(
          update: (theme) => theme.copyWith(style: style),
          child: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder action(AppSupportAction value) =>
      find.byKey(ValueKey('app-support-action-${value.name}'));

  void expectActionEnabled(WidgetTester tester, AppSupportAction value) {
    final button = tester.widget(action(value));
    expect(switch (button) {
      FilledButton(:final onPressed) => onPressed,
      CupertinoButton(:final onPressed) => onPressed,
      _ => throw StateError('Unexpected support action button: $button'),
    }, isNotNull);
  }

  for (final platform in TargetPlatform.values) {
    for (final distribution in AppDistribution.values) {
      testWidgets(
        'Settings keeps GitHub and routes $distribution links on $platform',
        (tester) async {
          final owner = createTestAppSupportOwner()
            ..setDistribution(distribution);
          addTearDown(owner.dispose);
          await owner.init();
          final opened = <Uri>[];
          await mount(
            tester,
            ChangeNotifierProvider.value(
              value: owner,
              child: SingleChildScrollView(
                child: AppSettingSupportSection(
                  loadInfo: () async => _info,
                  hideDonate: true,
                  openUrl: (uri) async {
                    opened.add(uri);
                    return true;
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
          final target = owner.channelAction;
          for (final store in [
            AppSupportAction.googlePlay,
            AppSupportAction.appStore,
            AppSupportAction.microsoftStore,
            AppSupportAction.flathub,
          ]) {
            expect(
              action(store).hitTestable(),
              target == store ? findsOneWidget : findsNothing,
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
          if (target != AppSupportAction.githubStar) {
            await tester.tap(action(target));
            await tester.pumpAndSettle();
            expect(opened, [target.resolveUrl(_info)]);
            expect(owner.reminderClosed, isFalse);
            expect(
              (await SharedPreferences.getInstance()).reminderBool(
                'appSupport_doNotOpenAgain',
              ),
              isFalse,
            );
            expect(
              (await SharedPreferences.getInstance()).reminderInt(
                'appSupport_launches',
              ),
              -9,
            );
            expect(action(target).hitTestable(), findsOneWidget);
          }
          await tester.tap(action(AppSupportAction.githubStar));
          await tester.pumpAndSettle();
          expect(opened.last, Uri.parse(_info.sourceCodeUrl));
          expect(owner.reminderClosed, isTrue);
          expect(
            (await SharedPreferences.getInstance()).reminderBool(
              'appSupport_doNotOpenAgain',
            ),
            isTrue,
          );
          expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        variant: TargetPlatformVariant.only(platform),
      );
    }
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style mounted Settings follows channel changes without saving',
      (tester) async {
        final owner = createTestAppSupportOwner()
          ..setDistribution(AppDistribution.github);
        addTearDown(owner.dispose);
        await owner.init();
        final before = (await SharedPreferences.getInstance()).getAll();
        var loads = 0;
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async {
                  loads++;
                  return _info;
                },
                hideDonate: true,
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        final section = tester.element(find.byType(AppSettingSupportSection));
        for (final distribution in AppDistribution.values) {
          owner.setDistribution(distribution);
          await tester.pumpAndSettle();
          expect(
            action(AppSupportAction.githubStar).hitTestable(),
            findsOneWidget,
          );
          if (owner.channelAction != AppSupportAction.githubStar) {
            expect(action(owner.channelAction).hitTestable(), findsOneWidget);
          }
          expect(
            tester.element(find.byType(AppSettingSupportSection)),
            section,
          );
          expect((await SharedPreferences.getInstance()).getAll(), before);
        }
        expect(loads, 1);
        expect(tester.takeException(), isNull);
      },
    );

    for (final failsWithException in [false, true]) {
      testWidgets(
        '$style failed store link can retry and saves only after opening ($failsWithException)',
        (tester) async {
          final owner = createTestAppSupportOwner()
            ..setDistribution(AppDistribution.appStore);
          addTearDown(owner.dispose);
          await owner.init();
          final before = (await SharedPreferences.getInstance()).getAll();
          var calls = 0;
          await mount(
            tester,
            ChangeNotifierProvider.value(
              value: owner,
              child: SingleChildScrollView(
                child: AppSettingSupportSection(
                  loadInfo: () async => _info,
                  hideDonate: true,
                  openUrl: (_) async {
                    if (++calls == 1) {
                      if (failsWithException) throw StateError('launch failed');
                      return false;
                    }
                    return true;
                  },
                ),
              ),
            ),
            style: style,
          );
          await tester.pumpAndSettle();
          await tester.tap(action(AppSupportAction.appStore));
          await tester.pumpAndSettle();
          expect(
            find.text('Unable to complete this action. Please try again.'),
            findsOneWidget,
          );
          expect((await SharedPreferences.getInstance()).getAll(), before);
          expect(
            action(AppSupportAction.githubStar).hitTestable(),
            findsOneWidget,
          );
          await tester.tap(action(AppSupportAction.appStore));
          await tester.pumpAndSettle();
          expect(calls, 2);
          expect(
            find.text('Unable to complete this action. Please try again.'),
            findsNothing,
          );
          expect(owner.reminderClosed, isFalse);
          expect(
            (await SharedPreferences.getInstance()).reminderInt(
              'appSupport_launches',
            ),
            -9,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$style pending store link permits independent clicks and preserves dismissal',
      (tester) async {
        final owner = createTestAppSupportOwner()
          ..setDistribution(AppDistribution.googlePlay);
        addTearDown(owner.dispose);
        await owner.init();
        final before = (await SharedPreferences.getInstance()).getAll();
        final pending = Completer<bool>();
        var calls = 0;
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
                openUrl: (_) {
                  calls++;
                  return calls == 1 ? pending.future : Future.value(true);
                },
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        await tester.tap(action(AppSupportAction.googlePlay));
        await tester.pumpAndSettle();
        expectActionEnabled(tester, AppSupportAction.googlePlay);
        expectActionEnabled(tester, AppSupportAction.githubStar);
        expect((await SharedPreferences.getInstance()).getAll(), before);
        await tester.tap(action(AppSupportAction.googlePlay));
        await tester.tap(action(AppSupportAction.githubStar));
        await tester.pumpAndSettle();
        expect(calls, 3);
        expect(owner.reminderClosed, isTrue);
        expect(
          (await SharedPreferences.getInstance()).reminderInt(
            'appSupport_launches',
          ),
          -9,
        );
        pending.complete(true);
        await tester.pumpAndSettle();
        expect(calls, 3);
        expect(owner.reminderClosed, isTrue);
        expect(
          (await SharedPreferences.getInstance()).reminderBool(
            'appSupport_doNotOpenAgain',
          ),
          isTrue,
        );
        expect(
          (await SharedPreferences.getInstance()).reminderInt(
            'appSupport_launches',
          ),
          -19,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final fail in [false, true]) {
    testWidgets(
      'Settings card waits for initialization completion (failure=$fail)',
      (tester) async {
        final preferences = _PendingPreferences();
        final owner = createTestAppSupportOwner(
          loadPreferences: () => preferences.ready.future,
        );
        addTearDown(owner.dispose);
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('settings-support')), findsNothing);
        expect(find.byType(PageView), findsNothing);
        final initialization = owner.init();
        if (fail) {
          preferences.ready.completeError(StateError('initialization failed'));
        } else {
          preferences.ready.complete(await SharedPreferences.getInstance());
        }
        expect(await initialization, !fail);
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
        expect(find.text('Support Table Habit'), findsOneWidget);
        expect(
          tester
              .widget<AdaptiveListSection>(
                find.byKey(const ValueKey('settings-support')),
              )
              .header,
          isNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'configuration failure is handled while initialization is pending',
    (tester) async {
      final preferences = _PendingPreferences();
      final owner = createTestAppSupportOwner(
        loadPreferences: () => preferences.ready.future,
      );
      addTearDown(owner.dispose);
      await mount(
        tester,
        ChangeNotifierProvider.value(
          value: owner,
          child: AppSettingSupportSection(
            loadInfo: () async => throw StateError('configuration unavailable'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('settings-support')), findsNothing);
      final initialization = owner.init();
      preferences.ready.complete(await SharedPreferences.getInstance());
      await initialization;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('settings-support')), findsNothing);
    },
  );

  testWidgets('Settings disposal ignores a late success without saving rate', (
    tester,
  ) async {
    final owner = createTestAppSupportOwner();
    addTearDown(owner.dispose);
    await owner.init();
    final pending = Completer<bool>();
    await mount(
      tester,
      ChangeNotifierProvider.value(
        value: owner,
        child: SingleChildScrollView(
          child: AppSettingSupportSection(
            loadInfo: () async => _info,
            hideDonate: true,
            openUrl: (_) => pending.future,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Star on GitHub'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(owner.reminderClosed, isFalse);
    expect(
      (await SharedPreferences.getInstance()).reminderBool(
        'appSupport_doNotOpenAgain',
      ),
      isFalse,
    );
  });

  for (final fails in [false, true]) {
    testWidgets('disposed owner ignores a late link result (fails=$fails)', (
      tester,
    ) async {
      final owner = createTestAppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      final pending = Completer<bool>();
      await mount(
        tester,
        ChangeNotifierProvider.value(
          value: owner,
          child: SingleChildScrollView(
            child: AppSettingSupportSection(
              loadInfo: () async => _info,
              hideDonate: true,
              openUrl: (_) => pending.future,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = L10n.of(
        tester.element(find.byType(AppSettingSupportSection)),
      )!;
      await tester.tap(find.text('Star on GitHub'));
      await tester.pump();
      owner.dispose();
      if (fails) {
        pending.completeError(StateError('late launch failure'));
      } else {
        pending.complete(true);
      }
      await tester.pumpAndSettle();
      expect(find.text(l10n.appSupport_linkFailed), findsNothing);
      expect(find.text(l10n.appSupport_saveFailed), findsNothing);
      expect(
        (await SharedPreferences.getInstance()).reminderBool(
          'appSupport_doNotOpenAgain',
        ),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      'donation modal blocks enabled Settings actions until dismissed $style',
      (tester) async {
        final owner = createTestAppSupportOwner();
        addTearDown(owner.dispose);
        await owner.init();
        final before = (await SharedPreferences.getInstance()).getAll();
        var donations = 0;
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: false,
                showDonation: (info) async {
                  donations++;
                  await showDonateDialog(
                    tester.element(find.byType(AppSettingSupportSection)),
                    config: DonateConfig(info: info),
                  );
                },
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('app-support-page-1')));
        await tester.pumpAndSettle();
        await tester.tap(action(AppSupportAction.donate));
        await tester.pumpAndSettle();
        expect(find.byType(DonateContent), findsOneWidget);
        expect(donations, 1);
        expectActionEnabled(tester, AppSupportAction.donate);
        expect(action(AppSupportAction.donate).hitTestable(), findsNothing);
        // The sheet's barrier receives background taps without re-opening it.
        await tester.tapAt(const Offset(8, 8));
        await tester.pumpAndSettle();
        expect(find.byType(DonateContent), findsNothing);
        expect(donations, 1);
        expect(action(AppSupportAction.donate).hitTestable(), findsOneWidget);
        await tester.tap(action(AppSupportAction.donate));
        await tester.pumpAndSettle();
        expect(find.byType(DonateContent), findsOneWidget);
        expect(donations, 2);
        await tester.tapAt(const Offset(8, 8));
        await tester.pumpAndSettle();
        expect(find.byType(DonateContent), findsNothing);
        expect((await SharedPreferences.getInstance()).getAll(), before);
        expect(tester.takeException(), isNull);
      },
    );

    for (final width in [320.0, 1000.0]) {
      testWidgets('Settings card fits and centers at width $width $style', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final owner = createTestAppSupportOwner()
          ..setDistribution(AppDistribution.appStore);
        addTearDown(owner.dispose);
        await owner.init();
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        final section = tester.getRect(
          find.byKey(const ValueKey('settings-support')),
        );
        final pages = tester.getRect(find.byType(PageView));
        expect(section.width, width > 500 ? 500 : width);
        expect(section.center.dx, width / 2);
        expect(pages.left, greaterThan(section.left));
        expect(pages.right, lessThan(section.right));
        expect(pages.center.dx, section.center.dx);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(action(AppSupportAction.appStore).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Settings card order and filled actions are shared $style', (
      tester,
    ) async {
      final owner = createTestAppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      final opened = <Uri>[];
      var donations = 0;
      await mount(
        tester,
        ChangeNotifierProvider.value(
          value: owner,
          child: SingleChildScrollView(
            child: AppSettingSupportSection(
              loadInfo: () async => _info,
              hideDonate: false,
              openUrl: (uri) async {
                opened.add(uri);
                return true;
              },
              showDonation: (_) async {
                donations++;
              },
            ),
          ),
        ),
        style: style,
      );
      await tester.pumpAndSettle();
      final l10n = L10n.of(
        tester.element(find.byType(AppSettingSupportSection)),
      )!;
      Finder action(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) => style == AdaptiveStyle.material
              ? widget is FilledButton
              : widget is CupertinoButton,
        ),
      );
      expect(action(l10n.appSupport_starOnGitHub), findsOneWidget);
      expect(
        find.descendant(
          of: action(l10n.appSupport_starOnGitHub),
          matching: find.byIcon(Icons.star_rounded),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('app-support-page-1')));
      await tester.pumpAndSettle();
      expect(action(l10n.appAbout_donateTile_titleText), findsOneWidget);
      await tester.tap(action(l10n.appAbout_donateTile_titleText));
      await tester.pumpAndSettle();
      expect(donations, 1);
      await tester.tap(find.byKey(const ValueKey('app-support-page-2')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.appSupport_participateTitle), findsOneWidget);
      for (final label in [
        l10n.appAbout_sourceCodeTile_titleText,
        l10n.appAbout_issueTrackerTile_titleText,
      ]) {
        expect(action(label), findsOneWidget);
        expect(
          find.descendant(of: action(label), matching: find.byType(Icon)),
          findsOneWidget,
        );
        await tester.tap(action(label));
        await tester.pumpAndSettle();
      }
      expect(opened, [
        Uri.parse(_info.sourceCodeUrl),
        Uri.parse(_info.issueTrackerUrl),
      ]);
      expect(owner.reminderClosed, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'reminder dismissal and Reset keep the Settings card visible $style',
      (tester) async {
        final owner = createTestAppSupportOwner();
        addTearDown(owner.dispose);
        await owner.init();
        await owner.recordSettingsSupportResult();
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(await owner.resetReminderForNextLaunch(), isTrue);
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(
          await owner.recordReminderResult(AppSupportResult.stopReminding),
          isTrue,
        );
        await tester.pumpAndSettle();
        expect(owner.reminderClosed, isTrue);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
      },
    );

    testWidgets(
      'Settings actions use the current owner after replacement $style',
      (tester) async {
        final first = createTestAppSupportOwner();
        final second = createTestAppSupportOwner();
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        await first.init();
        await second.init();
        await first.recordSettingsSupportResult();
        final current = ValueNotifier(first);
        addTearDown(current.dispose);
        final section = SingleChildScrollView(
          child: AppSettingSupportSection(
            loadInfo: () async => _info,
            hideDonate: true,
            openUrl: (_) async => true,
          ),
        );
        await mount(
          tester,
          ValueListenableBuilder<AppSupportOwner>(
            valueListenable: current,
            builder: (_, owner, _) =>
                ChangeNotifierProvider.value(value: owner, child: section),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        current.value = second;
        await tester.pumpAndSettle();
        await first.resetReminderForNextLaunch();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Star on GitHub'));
        await tester.pumpAndSettle();
        expect(second.reminderClosed, isTrue);
        expect(first.reminderClosed, isFalse);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Settings success persists and the card stays visible after restart $style',
      (tester) async {
        final owner = createTestAppSupportOwner();
        addTearDown(owner.dispose);
        await owner.init();
        final action = Completer<bool>();
        var calls = 0;
        Widget section(AppSupportOwner owner) => ChangeNotifierProvider.value(
          value: owner,
          child: SingleChildScrollView(
            child: AppSettingSupportSection(
              loadInfo: () async => _info,
              hideDonate: true,
              openUrl: (_) {
                calls++;
                return action.future;
              },
            ),
          ),
        );
        await mount(tester, section(owner), style: style);
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Star on GitHub'));
        await tester.pump();
        await tester.tap(find.text('Star on GitHub'));
        expect(calls, 2);
        action.complete(true);
        await tester.pumpAndSettle();
        expect(
          (await SharedPreferences.getInstance()).reminderBool(
            'appSupport_doNotOpenAgain',
          ),
          isTrue,
        );
        expect(owner.reminderClosed, isTrue);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        final restored = createTestAppSupportOwner();
        addTearDown(restored.dispose);
        await restored.init();
        await mount(tester, section(restored), style: style);
        await tester.pumpAndSettle();
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
        expect(find.text('Support Table Habit').hitTestable(), findsOneWidget);
      },
    );

    testWidgets(
      'save failure keeps the Settings card visible and retryable $style',
      (tester) async {
        var failSave = false;
        final preferences = _FailingSavePreferences(() => failSave);
        PreferencesTestStore.instance = preferences;
        final owner = createTestAppSupportOwner();
        addTearDown(owner.dispose);
        expect(await owner.init(), isTrue);
        failSave = true;
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
                openUrl: (_) async => true,
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        final l10n = L10n.of(
          tester.element(find.byType(AppSettingSupportSection)),
        )!;
        await tester.tap(find.text('Star on GitHub'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.appSupport_saveFailed), findsOneWidget);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(owner.reminderClosed, isFalse);
        failSave = false;
        await tester.tap(find.text('Star on GitHub'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.appSupport_saveFailed), findsNothing);
        expect(find.text('Star on GitHub').hitTestable(), findsOneWidget);
        expect(owner.reminderClosed, isTrue);
      },
    );

    testWidgets(
      'Settings failure retries and other actions preserve reminder history $style',
      (tester) async {
        final owner = createTestAppSupportOwner();
        addTearDown(owner.dispose);
        await owner.init();
        var calls = 0;
        await mount(
          tester,
          ChangeNotifierProvider.value(
            value: owner,
            child: SingleChildScrollView(
              child: AppSettingSupportSection(
                loadInfo: () async => _info,
                hideDonate: true,
                openUrl: (_) async {
                  calls++;
                  if (calls == 2) throw StateError('failed');
                  return calls > 2;
                },
              ),
            ),
          ),
          style: style,
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 2; i++) {
          await tester.tap(find.text('Star on GitHub'));
          await tester.pumpAndSettle();
          expect(
            find.text('Unable to complete this action. Please try again.'),
            findsOneWidget,
          );
        }
        await tester.drag(find.byType(PageView), const Offset(-1000, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Source code'));
        await tester.pumpAndSettle();
        expect(calls, 3);
        expect(owner.reminderClosed, isFalse);
        expect(
          (await SharedPreferences.getInstance()).reminderBool(
            'appSupport_doNotOpenAgain',
          ),
          isFalse,
        );
      },
    );
  }
}
