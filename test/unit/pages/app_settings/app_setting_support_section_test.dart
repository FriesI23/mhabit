// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../support/adaptive_ui_theme.dart';

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

class _PendingReminder extends RateMyApp {
  _PendingReminder() {
    for (final condition in conditions.whereType<ResetableCondition>()) {
      condition.reset();
    }
  }
  final ready = Completer<void>();
  @override
  Future<void> init() => ready.future;
}

class _FailingSaveReminder extends RateMyApp {
  _FailingSaveReminder() : super(preferencesPrefix: 'appSupport_');

  bool failSave = true;

  @override
  Future<void> callEvent(RateMyAppEventType event) async {
    if (failSave && event == RateMyAppEventType.rateButtonPressed) {
      throw StateError('save failed');
    }
    await super.callEvent(event);
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    AdaptiveStyle style = AdaptiveStyle.material,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
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

  for (final fail in [false, true]) {
    testWidgets(
      'Settings card waits for initialization completion (failure=$fail)',
      (tester) async {
        final reminder = _PendingReminder();
        final owner = AppSupportOwner(reminder: reminder);
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
          reminder.ready.completeError(StateError('initialization failed'));
        } else {
          reminder.ready.complete();
        }
        expect(await initialization, !fail);
        await tester.pumpAndSettle();
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
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
      final reminder = _PendingReminder();
      final owner = AppSupportOwner(reminder: reminder);
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
      reminder.ready.complete();
      await initialization;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('settings-support')), findsNothing);
    },
  );

  testWidgets('Settings disposal ignores a late success without saving rate', (
    tester,
  ) async {
    final owner = AppSupportOwner();
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
    await tester.tap(find.text('Go to GitHub'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(owner.reminderClosed, isFalse);
    expect(
      await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
      isFalse,
    );
  });

  for (final fails in [false, true]) {
    testWidgets('disposed owner ignores a late link result (fails=$fails)', (
      tester,
    ) async {
      final owner = AppSupportOwner();
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
      await tester.tap(find.text('Go to GitHub'));
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
        await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      'reminder dismissal and Reset keep the Settings card visible $style',
      (tester) async {
        final owner = AppSupportOwner();
        addTearDown(owner.dispose);
        await owner.init();
        await owner.recordSupportOpened();
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
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(await owner.resetForNextLaunch(), isTrue);
        await tester.pumpAndSettle();
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(await owner.consume(AppSupportPromptResult.never), isTrue);
        await tester.pumpAndSettle();
        expect(owner.reminderClosed, isTrue);
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
      },
    );

    testWidgets(
      'Settings actions use the current owner after replacement $style',
      (tester) async {
        final first = AppSupportOwner();
        final second = AppSupportOwner();
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        await first.init();
        await second.init();
        await first.recordSupportOpened();
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
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        current.value = second;
        await tester.pumpAndSettle();
        await first.resetForNextLaunch();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Go to GitHub'));
        await tester.pumpAndSettle();
        expect(second.reminderClosed, isTrue);
        expect(first.reminderClosed, isFalse);
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Settings success persists and the card stays visible after restart $style',
      (tester) async {
        final owner = AppSupportOwner();
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
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Go to GitHub'));
        await tester.pump();
        await tester.tap(find.text('Go to GitHub'));
        expect(calls, 1);
        action.complete(true);
        await tester.pumpAndSettle();
        expect(
          await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
          isTrue,
        );
        expect(owner.reminderClosed, isTrue);
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        final restored = AppSupportOwner();
        addTearDown(restored.dispose);
        await restored.init();
        await mount(tester, section(restored), style: style);
        await tester.pumpAndSettle();
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
        expect(find.text('Support Table Habit').hitTestable(), findsOneWidget);
      },
    );

    testWidgets(
      'save failure keeps the Settings card visible and retryable $style',
      (tester) async {
        final reminder = _FailingSaveReminder();
        final owner = AppSupportOwner(reminder: reminder);
        addTearDown(owner.dispose);
        expect(await owner.init(), isTrue);
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
        await tester.tap(find.text('Go to GitHub'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.appSupport_saveFailed), findsOneWidget);
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(owner.reminderClosed, isFalse);
        reminder.failSave = false;
        await tester.tap(find.text('Go to GitHub'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.appSupport_saveFailed), findsNothing);
        expect(find.text('Go to GitHub').hitTestable(), findsOneWidget);
        expect(owner.reminderClosed, isTrue);
      },
    );

    testWidgets(
      'Settings failure retries and auxiliary actions do not consume reminders $style',
      (tester) async {
        final owner = AppSupportOwner();
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
          await tester.tap(find.text('Go to GitHub'));
          await tester.pumpAndSettle();
          expect(
            find.text('Unable to open the link. Please try again.'),
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
          await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
          isFalse,
        );
      },
    );
  }
}
