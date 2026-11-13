// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
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
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../support/stub/about_info.dart';

import '../../support/stub/shared_preferences.dart';

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

final class _Preferences extends InMemoryPreferencesStore {
  _Preferences()
    : super.withData({
        'appSupport_minimumDate': _initialDate,
        'appSupport_launches': 9,
        'appSupport_doNotOpenAgain': false,
      });

  final ready = Completer<void>();
  int starts = 0;

  @override
  Future<Map<String, Object>> getAll() async {
    starts++;
    await ready.future;
    return super.getAll();
  }
}

_Preferences _preferences() {
  final preferences = _Preferences();
  PreferencesTestStore.instance = preferences;
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

class _Foreground extends ValueNotifier<bool> {
  _Foreground(super.value);

  bool get isObserved => hasListeners;
}

void main() {
  late SharedPreferencesStorePlatform previousPreferences;
  setUp(() => previousPreferences = PreferencesTestStore.instance);
  tearDown(() => PreferencesTestStore.instance = previousPreferences);
  setUp(
    () => TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed),
  );

  testWidgets('one foreground startup across rebuild, remount and resume', (
    tester,
  ) async {
    final preferences = _preferences();
    final owner = createTestAppSupportOwner(
      loadPreferences: SharedPreferences.getInstance,
      now: () => _now,
      loadInfo: () async => stubAboutInfo(),
    );
    addTearDown(owner.dispose);
    var prompts = 0;
    Widget app({Key? key}) => MaterialApp(
      home: ChangeNotifierProvider<AppSupportOwner>.value(
        value: owner,
        child: AppSupportReminder(
          key: key,
          canShowDialog: (_) => true,
          showSupportDialog:
              ({required context, required info, controller}) async {
                prompts++;
                return AppSupportResult.remindLater;
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
      final owner = createTestAppSupportOwner(
        loadPreferences: SharedPreferences.getInstance,
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
            child: AppSupportReminder(
              canShowDialog: (_) => true,
              showSupportDialog:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportResult.remindLater;
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

  group('native foreground fallback', () {
    setUp(() {
      // Reproduce a desktop engine that has not sent any lifecycle message.
      TestWidgetsFlutterBinding.ensureInitialized().resetInternalState();
    });

    Widget app(
      AppSupportOwner owner,
      VoidCallback onPrompt, {
      ValueListenable<bool>? foreground,
    }) => MaterialApp(
      home: ChangeNotifierProvider.value(
        value: owner,
        child: AppSupportReminder(
          fallbackForeground: foreground,
          canShowDialog: (_) => true,
          showSupportDialog:
              ({required context, required info, controller}) async {
                onPrompt();
                return AppSupportResult.remindLater;
              },
          child: const Scaffold(),
        ),
      ),
    );

    for (final initialForeground in [null, false, true]) {
      testWidgets('unknown lifecycle with native $initialForeground', (
        tester,
      ) async {
        expect(tester.binding.lifecycleState, isNull);
        final preferences = _preferences()..ready.complete();
        final foreground = initialForeground == null
            ? null
            : ValueNotifier(initialForeground);
        if (foreground != null) addTearDown(foreground.dispose);
        var infoLoads = 0;
        final owner = createTestAppSupportOwner(
          loadPreferences: SharedPreferences.getInstance,
          now: () => _now,
          loadInfo: () async {
            infoLoads++;
            return stubAboutInfo();
          },
        );
        addTearDown(owner.dispose);
        var prompts = 0;
        await tester.pumpWidget(
          app(owner, () => prompts++, foreground: foreground),
        );
        await tester.pumpAndSettle();
        expect(prompts, initialForeground == true ? 1 : 0);
        expect(infoLoads, initialForeground == true ? 1 : 0);
        if (initialForeground != true) {
          expect(await preferences.saved, _initializedValues());
          if (foreground == null) {
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.resumed,
            );
          } else {
            foreground.value = true;
          }
          await tester.pumpAndSettle();
        }
        expect(prompts, 1);
        expect(infoLoads, 1);
        expect(await preferences.saved, _laterValues());
        expect(
          tester.binding.lifecycleState,
          initialForeground == null ? AppLifecycleState.resumed : isNull,
        );
      });
    }

    for (final loading in ['preferences', 'configuration']) {
      testWidgets('native blur while $loading load never catches up', (
        tester,
      ) async {
        final preferences = _preferences();
        if (loading == 'configuration') preferences.ready.complete();
        final info = Completer<AboutInfo>();
        final foreground = ValueNotifier(true);
        addTearDown(foreground.dispose);
        var infoLoads = 0;
        final owner = createTestAppSupportOwner(
          loadPreferences: SharedPreferences.getInstance,
          now: () => _now,
          loadInfo: () {
            infoLoads++;
            return info.future;
          },
        );
        addTearDown(owner.dispose);
        var prompts = 0;
        await tester.pumpWidget(
          app(owner, () => prompts++, foreground: foreground),
        );
        await tester.pumpAndSettle();
        expect(infoLoads, loading == 'configuration' ? 1 : 0);
        foreground.value = false;
        foreground.value = true;
        if (!preferences.ready.isCompleted) preferences.ready.complete();
        info.complete(stubAboutInfo());
        await tester.pumpAndSettle();
        expect(prompts, 0);
        expect(await preferences.saved, _initializedValues());
      });
    }

    for (final lifecycle in AppLifecycleState.values) {
      testWidgets('real $lifecycle takes priority over native foreground', (
        tester,
      ) async {
        tester.binding.handleAppLifecycleStateChanged(lifecycle);
        final preferences = _preferences()..ready.complete();
        final info = Completer<AboutInfo>();
        final foreground = ValueNotifier(true);
        addTearDown(foreground.dispose);
        final owner = createTestAppSupportOwner(
          loadPreferences: SharedPreferences.getInstance,
          now: () => _now,
          loadInfo: () => info.future,
        );
        addTearDown(owner.dispose);
        var prompts = 0;
        await tester.pumpWidget(
          app(owner, () => prompts++, foreground: foreground),
        );
        // Mount the host even when the real lifecycle has disabled frames.
        tester.binding.scheduleForcedFrame();
        await tester.pump();
        foreground.value = false;
        foreground.value = true;
        info.complete(stubAboutInfo());
        await tester.pump();
        expect(prompts, lifecycle == AppLifecycleState.resumed ? 1 : 0);
        expect(
          await preferences.saved,
          lifecycle == AppLifecycleState.resumed
              ? _laterValues()
              : _initializedValues(),
        );
      });
    }

    testWidgets('real lifecycle takes over an active native fallback', (
      tester,
    ) async {
      final preferences = _preferences()..ready.complete();
      final info = Completer<AboutInfo>();
      final foreground = ValueNotifier(true);
      addTearDown(foreground.dispose);
      var infoLoads = 0;
      final owner = createTestAppSupportOwner(
        loadPreferences: SharedPreferences.getInstance,
        now: () => _now,
        loadInfo: () {
          infoLoads++;
          return info.future;
        },
      );
      addTearDown(owner.dispose);
      var prompts = 0;
      await tester.pumpWidget(
        app(owner, () => prompts++, foreground: foreground),
      );
      await tester.pumpAndSettle();
      expect(infoLoads, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      info.complete(stubAboutInfo());
      await tester.pumpAndSettle();
      expect(prompts, 0);
      expect(await preferences.saved, _initializedValues());
    });

    testWidgets('replacing the native source ignores the old source', (
      tester,
    ) async {
      final preferences = _preferences()..ready.complete();
      final info = Completer<AboutInfo>();
      final first = _Foreground(false);
      final current = _Foreground(true);
      addTearDown(first.dispose);
      addTearDown(current.dispose);
      final owner = createTestAppSupportOwner(
        loadPreferences: SharedPreferences.getInstance,
        now: () => _now,
        loadInfo: () => info.future,
      );
      addTearDown(owner.dispose);
      var prompts = 0;
      await tester.pumpWidget(app(owner, () => prompts++, foreground: first));
      await tester.pumpAndSettle();
      await tester.pumpWidget(app(owner, () => prompts++, foreground: current));
      await tester.pumpAndSettle();
      expect(first.isObserved, isFalse);
      first.value = true;
      first.value = false;
      info.complete(stubAboutInfo());
      await tester.pumpAndSettle();
      expect(prompts, 1);
      expect(await preferences.saved, _laterValues());
      await tester.pumpWidget(const SizedBox());
      expect(current.isObserved, isFalse);
      current.value = false;
      expect(tester.takeException(), isNull);
    });

    for (final replacement in [false, null]) {
      testWidgets('replacing active native source with $replacement skips', (
        tester,
      ) async {
        final preferences = _preferences()..ready.complete();
        final info = Completer<AboutInfo>();
        final first = _Foreground(true);
        final current = replacement == null ? null : _Foreground(replacement);
        addTearDown(first.dispose);
        if (current != null) addTearDown(current.dispose);
        final owner = createTestAppSupportOwner(
          loadPreferences: SharedPreferences.getInstance,
          now: () => _now,
          loadInfo: () => info.future,
        );
        addTearDown(owner.dispose);
        var prompts = 0;
        await tester.pumpWidget(app(owner, () => prompts++, foreground: first));
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          app(owner, () => prompts++, foreground: current),
        );
        if (current != null) {
          current.value = true;
        } else {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        }
        info.complete(stubAboutInfo());
        await tester.pumpAndSettle();
        expect(first.isObserved, isFalse);
        expect(prompts, 0);
        expect(await preferences.saved, _initializedValues());
      });
    }
  });

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
      final owner = createTestAppSupportOwner(
        loadPreferences: SharedPreferences.getInstance,
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
            child: AppSupportReminder(
              canShowDialog: (_) => routes.depth == 1,
              showSupportDialog:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportResult.stopReminding;
                  },
              child: const Scaffold(body: SizedBox.expand()),
            ),
          ),
        ),
      );
      switch (conflict) {
        case 'changelog':
          owner.skipReminderForSession();
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
            create: (_) => createTestAppSupportOwner(
              loadPreferences: SharedPreferences.getInstance,
              now: () => _now,
              loadInfo: () => info.future,
            ),
            child: AppSupportReminder(
              canShowDialog: (_) => safe,
              showSupportDialog:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportResult.remindLater;
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
              create: (_) => createTestAppSupportOwner(
                loadPreferences: SharedPreferences.getInstance,
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
                return AppSupportReminder(
                  canShowDialog: (context) =>
                      context.read<_PresentationSafety>().safe,
                  showSupportDialog:
                      ({required context, required info, controller}) async {
                        prompts++;
                        return AppSupportResult.remindLater;
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
          create: (_) => createTestAppSupportOwner(
            loadPreferences: SharedPreferences.getInstance,
            now: () => _now,
            loadInfo: () async => stubAboutInfo(),
          ),
          child: MaterialApp(
            home: AppSupportReminder(
              canShowDialog: (_) => attached,
              showSupportDialog:
                  ({required context, required info, controller}) async {
                    prompts++;
                    return AppSupportResult.remindLater;
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
      final owner = createTestAppSupportOwner(
        loadPreferences: SharedPreferences.getInstance,
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
                    ? AppSupportReminder(
                        canShowDialog: (_) => true,
                        showSupportDialog:
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
    final result = Completer<AppSupportResult>();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppSupportOwner>(
          create: (_) => createTestAppSupportOwner(
            loadPreferences: SharedPreferences.getInstance,
            now: () => _now,
            loadInfo: () async => stubAboutInfo(),
          ),
          child: AppSupportReminder(
            canShowDialog: (_) => true,
            showSupportDialog:
                ({required context, required info, controller}) =>
                    result.future,
            child: const Scaffold(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    result.complete(AppSupportResult.remindLater);
    await tester.pumpAndSettle();
    expect(await preferences.saved, _initializedValues());
  });
}
