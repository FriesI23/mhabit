// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../support/stub/about_info.dart';

class _Reminder extends RateMyApp {
  _Reminder() {
    for (final condition in conditions.whereType<ResetableCondition>()) {
      condition.reset();
    }
  }
  final ready = Completer<void>();
  int starts = 0;
  final events = <RateMyAppEventType>[];
  @override
  Future<void> init() {
    starts++;
    return ready.future;
  }

  @override
  bool get shouldOpenDialog => true;
  @override
  Future<void> callEvent(RateMyAppEventType event) async => events.add(event);
}

class _PresentationSafety extends ChangeNotifier {
  bool safe = true;
  void leave() {
    safe = false;
    notifyListeners();
  }

  void restore() {
    safe = true;
    notifyListeners();
  }
}

void main() {
  setUp(
    () => TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed),
  );

  testWidgets('one foreground startup across rebuild, remount and resume', (
    tester,
  ) async {
    final reminder = _Reminder();
    final owner = AppSupportOwner(
      reminder: reminder,
      loadInfo: () async => stubAboutInfo(),
    );
    var prompts = 0;
    Widget app({Key? key}) => MaterialApp(
      home: ChangeNotifierProvider<AppSupportOwner>.value(
        value: owner,
        child: AppSupportPrompt(
          key: key,
          canPresent: (_) => true,
          showPrompt: ({required context, required info, controller}) async {
            prompts++;
            return AppSupportPromptResult.later;
          },
          child: const Scaffold(),
        ),
      ),
    );
    await tester.pumpWidget(app());
    reminder.ready.complete();
    await tester.pumpAndSettle();
    expect(prompts, 1);
    expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
    await tester.pumpWidget(app());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(app(key: const ValueKey('remounted')));
    await tester.pumpAndSettle();
    expect(prompts, 1);
    expect(reminder.starts, 1);
  });

  testWidgets(
    'cold startup waits for first foreground activation without losing the prompt',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      final reminder = _Reminder()..ready.complete();
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async => stubAboutInfo(),
      );
      addTearDown(owner.dispose);
      await owner.init();
      var prompts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: owner,
            child: AppSupportPrompt(
              canPresent: (_) => true,
              showPrompt:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportPromptResult.later;
                  },
              child: const Scaffold(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(reminder.events, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(prompts, 1);
      expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(prompts, 1);
    },
  );

  for (final conflict in [
    'changelog',
    'pointer',
    'scroll',
    'keyboard',
    'background',
    'route',
    'dispose',
    'invalid-url',
    'config-error',
  ]) {
    testWidgets('$conflict skips without consuming and never catches up', (
      tester,
    ) async {
      final reminder = _Reminder();
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async {
          if (conflict == 'config-error') throw StateError('asset failed');
          if (conflict == 'invalid-url') return const AboutInfo.empty();
          return stubAboutInfo();
        },
      );
      var prompts = 0;
      final navigator = GlobalKey<NavigatorState>();
      final routes = AdaptiveBranchRouteObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          navigatorObservers: [routes],
          home: ChangeNotifierProvider<AppSupportOwner>.value(
            value: owner,
            child: AppSupportPrompt(
              canPresent: (_) => routes.depth == 1,
              showPrompt:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportPromptResult.never;
                  },
              child: const Scaffold(body: SizedBox.expand()),
            ),
          ),
        ),
      );
      switch (conflict) {
        case 'changelog':
          owner.skipPrompt();
        case 'pointer':
          await tester.tapAt(const Offset(100, 100));
        case 'scroll':
          tester.binding.handlePointerEvent(
            const PointerScrollEvent(
              position: Offset(100, 100),
              scrollDelta: Offset(0, 10),
            ),
          );
        case 'keyboard':
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
        case 'route':
          navigator.currentState!.push(
            MaterialPageRoute<void>(builder: (_) => const Scaffold()),
          );
        case 'dispose':
          await tester.pumpWidget(const SizedBox());
        case 'invalid-url' || 'config-error':
          break;
      }
      reminder.ready.complete();
      await tester.pumpAndSettle();
      if (conflict == 'route') navigator.currentState!.pop();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(reminder.events, isEmpty);
      expect(reminder.starts, 1);
    });
  }

  testWidgets(
    'state changes while config loads are checked before presentation',
    (tester) async {
      final reminder = _Reminder()..ready.complete();
      final info = Completer<AboutInfo>();
      var safe = true;
      var prompts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppSupportOwner>(
            create: (_) => AppSupportOwner(
              reminder: reminder,
              loadInfo: () => info.future,
            ),
            child: AppSupportPrompt(
              canPresent: (_) => safe,
              showPrompt:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportPromptResult.later;
                  },
              child: const Scaffold(),
            ),
          ),
        ),
      );
      await tester.pump();
      safe = false;
      info.complete(stubAboutInfo());
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(reminder.events, isEmpty);
    },
  );

  testWidgets(
    'Provider safety changes cancel even when restored before configuration completes',
    (tester) async {
      final reminder = _Reminder()..ready.complete();
      final info = Completer<AboutInfo>();
      final safety = _PresentationSafety();
      addTearDown(safety.dispose);
      var prompts = 0;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AppSupportOwner(
                reminder: reminder,
                loadInfo: () => info.future,
              ),
            ),
            ChangeNotifierProvider.value(value: safety),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final _ = context.select<_PresentationSafety, bool>(
                  (value) => value.safe,
                );
                return AppSupportPrompt(
                  canPresent: (context) =>
                      context.read<_PresentationSafety>().safe,
                  showPrompt:
                      ({required context, required info, controller}) async {
                        prompts++;
                        return AppSupportPromptResult.later;
                      },
                  child: const Scaffold(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      safety.leave();
      await tester.pump();
      safety.restore();
      await tester.pump();
      info.complete(stubAboutInfo());
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(reminder.events, isEmpty);
    },
  );

  testWidgets(
    'initial navigator attachment can finish during the first frame',
    (tester) async {
      final reminder = _Reminder()..ready.complete();
      var attached = false;
      var prompts = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppSupportOwner(
            reminder: reminder,
            loadInfo: () async => stubAboutInfo(),
          ),
          child: MaterialApp(
            home: AppSupportPrompt(
              canPresent: (_) => attached,
              showPrompt:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportPromptResult.later;
                  },
              child: Builder(
                builder: (_) {
                  attached = true;
                  return const Scaffold();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(prompts, 1);
      expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
    },
  );

  testWidgets(
    'disposing a real prompt host removes only its dialog and ignores a late link',
    (tester) async {
      final reminder = _Reminder()..ready.complete();
      final pending = Completer<bool>();
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async => stubAboutInfo(),
      );
      addTearDown(owner.dispose);
      final navigator = GlobalKey<NavigatorState>();
      var mountedHost = true;
      late StateSetter updateHost;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: owner,
          child: MaterialApp(
            navigatorKey: navigator,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: StatefulBuilder(
              builder: (context, setState) {
                updateHost = setState;
                return mountedHost
                    ? AppSupportPrompt(
                        canPresent: (_) => true,
                        showPrompt:
                            ({required context, required info, controller}) =>
                                showAppSupportDialog(
                                  context: context,
                                  info: info,
                                  controller: controller,
                                  openUrl: (_) => pending.future,
                                ),
                        child: const Scaffold(),
                      )
                    : const Scaffold();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to GitHub'));
      await tester.pump();
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Other route')),
        ),
      );
      await tester.pumpAndSettle();
      updateHost(() => mountedHost = false);
      await tester.pumpAndSettle();
      pending.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Other route'), findsOneWidget);
      expect(find.byType(AdaptiveDialog, skipOffstage: false), findsNothing);
      expect(reminder.events, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('host destruction discards an unfinished interaction', (
    tester,
  ) async {
    final reminder = _Reminder()..ready.complete();
    final result = Completer<AppSupportPromptResult>();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppSupportOwner>(
          create: (_) => AppSupportOwner(
            reminder: reminder,
            loadInfo: () async => stubAboutInfo(),
          ),
          child: AppSupportPrompt(
            canPresent: (_) => true,
            showPrompt: ({required context, required info, controller}) =>
                result.future,
            child: const Scaffold(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    result.complete(AppSupportPromptResult.later);
    await tester.pumpAndSettle();
    expect(reminder.events, isEmpty);
  });
}
