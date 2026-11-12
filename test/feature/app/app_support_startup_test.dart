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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../../support/stub/about_info.dart';

final _now = DateTime.utc(2026, 11, 12);
final _initialDate = DateTime.utc(2000).millisecondsSinceEpoch;

Map<String, Object> _initializedValues() => {
  'appSupport_minimumDate': _initialDate,
  'appSupport_launches': 10,
  'appSupport_doNotOpenAgain': false,
};

Map<String, Object> _laterValues() => {
  'appSupport_minimumDate': _now
      .add(const Duration(days: 7))
      .millisecondsSinceEpoch,
  'appSupport_launches': 0,
  'appSupport_doNotOpenAgain': false,
};

final class _Preferences extends InMemorySharedPreferencesAsync {
  _Preferences()
    : super.withData({
        'appSupport_minimumDate': _initialDate,
        'appSupport_launches': 9,
        'appSupport_doNotOpenAgain': false,
      });

  final ready = Completer<void>();
  int starts = 0;

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    starts++;
    await ready.future;
    return super.getPreferences(parameters, options);
  }

  Future<Map<String, Object>> get saved => super.getPreferences(
    const GetPreferencesParameters(filter: PreferencesFilters()),
    const SharedPreferencesOptions(),
  );
}

_Preferences _preferences() {
  final preferences = _Preferences();
  SharedPreferencesAsyncPlatform.instance = preferences;
  return preferences;
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
  late SharedPreferencesAsyncPlatform? previousPreferences;
  setUp(() => previousPreferences = SharedPreferencesAsyncPlatform.instance);
  tearDown(() => SharedPreferencesAsyncPlatform.instance = previousPreferences);
  setUp(
    () => TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed),
  );

  testWidgets('one foreground startup across rebuild, remount and resume', (
    tester,
  ) async {
    final preferences = _preferences();
    final owner = AppSupportOwner(
      preferences: SharedPreferencesAsync(),
      now: () => _now,
      loadInfo: () async => stubAboutInfo(),
    );
    addTearDown(owner.dispose);
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
    preferences.ready.complete();
    await tester.pumpAndSettle();
    expect(prompts, 1);
    expect(await preferences.saved, _laterValues());
    await tester.pumpWidget(app());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(app(key: const ValueKey('remounted')));
    await tester.pumpAndSettle();
    expect(prompts, 1);
    expect(preferences.starts, 1);
  });

  testWidgets(
    'cold startup waits for first foreground activation without losing the prompt',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      final preferences = _preferences()..ready.complete();
      final owner = AppSupportOwner(
        preferences: SharedPreferencesAsync(),
        now: () => _now,
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
      expect(await preferences.saved, _initializedValues());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(prompts, 1);
      expect(await preferences.saved, _laterValues());
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
      final preferences = _preferences();
      final owner = AppSupportOwner(
        preferences: SharedPreferencesAsync(),
        now: () => _now,
        loadInfo: () async {
          if (conflict == 'config-error') throw StateError('asset failed');
          if (conflict == 'invalid-url') return const AboutInfo.empty();
          return stubAboutInfo();
        },
      );
      addTearDown(owner.dispose);
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
      preferences.ready.complete();
      await tester.pumpAndSettle();
      if (conflict == 'route') navigator.currentState!.pop();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(await preferences.saved, _initializedValues());
      expect(preferences.starts, 1);
    });
  }

  testWidgets(
    'state changes while config loads are checked before presentation',
    (tester) async {
      final preferences = _preferences()..ready.complete();
      final info = Completer<AboutInfo>();
      var safe = true;
      var prompts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppSupportOwner>(
            create: (_) => AppSupportOwner(
              preferences: SharedPreferencesAsync(),
              now: () => _now,
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
      expect(await preferences.saved, _initializedValues());
    },
  );

  testWidgets(
    'Provider safety changes cancel even when restored before configuration completes',
    (tester) async {
      final preferences = _preferences()..ready.complete();
      final info = Completer<AboutInfo>();
      final safety = _PresentationSafety();
      addTearDown(safety.dispose);
      var prompts = 0;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => AppSupportOwner(
                preferences: SharedPreferencesAsync(),
                now: () => _now,
                loadInfo: () => info.future,
              ),
            ),
            ChangeNotifierProvider.value(value: safety),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                context.select<_PresentationSafety, bool>(
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
      expect(await preferences.saved, _initializedValues());
    },
  );

  testWidgets(
    'initial navigator attachment can finish during the first frame',
    (tester) async {
      final preferences = _preferences()..ready.complete();
      var attached = false;
      var prompts = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppSupportOwner(
            preferences: SharedPreferencesAsync(),
            now: () => _now,
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
      expect(await preferences.saved, _laterValues());
    },
  );

  testWidgets(
    'disposing a real prompt host removes only its dialog and ignores a late link',
    (tester) async {
      final preferences = _preferences()..ready.complete();
      final pending = Completer<bool>();
      final owner = AppSupportOwner(
        preferences: SharedPreferencesAsync(),
        now: () => _now,
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
      await tester.tap(find.text('Star on GitHub'));
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
      expect(await preferences.saved, _initializedValues());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('host destruction discards an unfinished interaction', (
    tester,
  ) async {
    final preferences = _preferences()..ready.complete();
    final result = Completer<AppSupportPromptResult>();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppSupportOwner>(
          create: (_) => AppSupportOwner(
            preferences: SharedPreferencesAsync(),
            now: () => _now,
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
    expect(await preferences.saved, _initializedValues());
  });
}
