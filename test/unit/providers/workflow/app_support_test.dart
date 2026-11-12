// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/async.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/support/commons.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../support/stub/about_info.dart';

class _Reminder extends RateMyApp {
  _Reminder() {
    for (final condition in conditions.whereType<ResetableCondition>()) {
      condition.reset();
    }
  }
  final ready = Completer<void>();
  int starts = 0;
  bool eligible = true;
  bool failSave = false;
  final events = <RateMyAppEventType>[];

  @override
  Future<void> init() {
    starts++;
    return ready.future;
  }

  @override
  bool get shouldOpenDialog => eligible;
  @override
  Future<void> callEvent(RateMyAppEventType event) async {
    events.add(event);
    if (failSave) throw StateError('write failed');
  }
}

final class _FailingPreferences extends InMemorySharedPreferencesAsync {
  _FailingPreferences() : super.empty();
  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) => Future.error(StateError('write failed'));
}

final class _ToggleBoolPreferences extends InMemorySharedPreferencesAsync {
  _ToggleBoolPreferences() : super.empty();
  bool failWrites = false;
  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) {
    if (failWrites) return Future.error(StateError('write failed'));
    return super.setBool(key, value, options);
  }
}

void main() {
  test(
    'runtime channel changes notify once and preserve reminder data',
    () async {
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      final before = await SharedPreferencesAsync().getAll();
      var notifications = 0;
      owner.addListener(() => notifications++);
      expect(owner.distribution, defaultAppDistribution);

      final selected = owner.distribution == AppDistribution.googlePlay
          ? AppDistribution.appStore
          : AppDistribution.googlePlay;
      owner.setDistribution(selected);
      owner.setDistribution(selected);

      expect(owner.distribution, selected);
      expect(notifications, 1);
      expect(await SharedPreferencesAsync().getAll(), before);
    },
  );

  test('a new support owner restores the compiled channel', () {
    final owner = AppSupportOwner();
    owner.setDistribution(AppDistribution.custom);
    owner.dispose();
    owner.setDistribution(AppDistribution.github);
    expect(owner.distribution, AppDistribution.custom);

    final restored = AppSupportOwner();
    addTearDown(restored.dispose);
    expect(restored.distribution, defaultAppDistribution);
  });

  test(
    'explicit support persists after an automatic later and restores folded state',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      expect(await owner.consume(AppSupportPromptResult.later), isTrue);
      expect(owner.reminderClosed, isFalse);
      expect(await owner.recordSupportOpened(), isTrue);
      expect(owner.reminderClosed, isTrue);
      final restored = AppSupportOwner();
      addTearDown(restored.dispose);
      await restored.init();
      expect(restored.reminderClosed, isTrue);
      expect(restored.claimPrompt(canPresent: true), isFalse);
      expect(await restored.resetForNextLaunch(), isTrue);
      expect(restored.reminderClosed, isFalse);
    },
  );

  test(
    'failed event save does not publish closure and explicit action can retry',
    () async {
      final preferences = _ToggleBoolPreferences();
      SharedPreferencesAsyncPlatform.instance = preferences;
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      preferences.failWrites = true;
      expect(await owner.recordSupportOpened(), isFalse);
      expect(owner.reminderClosed, isFalse);
      preferences.failWrites = false;
      expect(await owner.recordSupportOpened(), isTrue);
      expect(owner.reminderClosed, isTrue);
      expect(
        await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
        isTrue,
      );
    },
  );

  test(
    'auxiliary and failed actions leave the reminder event guard untouched',
    () async {
      final reminder = _Reminder()..ready.complete();
      final owner = AppSupportOwner(reminder: reminder);
      addTearDown(owner.dispose);
      await owner.init();
      expect(
        await owner.consume(AppSupportPromptResult.auxiliaryAction),
        isFalse,
      );
      expect(await owner.consume(AppSupportPromptResult.actionFailed), isFalse);
      expect(reminder.events, isEmpty);
      expect(await owner.consume(AppSupportPromptResult.later), isTrue);
      expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
    },
  );

  test(
    'owner disposal during initialization cannot notify or consume later',
    () async {
      final reminder = _Reminder();
      final owner = AppSupportOwner(reminder: reminder);
      final ProviderMounted lifetime = owner;
      var notifications = 0;
      owner.addListener(() => notifications++);
      final result = owner.init();
      expect(lifetime.mounted, isTrue);
      owner.dispose();
      expect(lifetime.mounted, isFalse);
      reminder.ready.complete();
      expect(await result, isFalse);
      expect(owner.initialized, isFalse);
      expect(await owner.consume(AppSupportPromptResult.later), isFalse);
      expect(reminder.events, isEmpty);
      expect(notifications, 0);
    },
  );

  test('disposed owner rejects initialization before storage access', () async {
    final reminder = _Reminder();
    final owner = AppSupportOwner(reminder: reminder);
    final AsyncInitialization initialization = owner;
    owner.dispose();
    owner.dispose();
    final first = initialization.init();
    expect(identical(first, initialization.init()), isTrue);
    expect(await first, isFalse);
    expect(reminder.starts, 0);
    expect(await owner.recordSupportOpened(), isFalse);
    expect(await owner.resetForNextLaunch(), isFalse);
    expect(reminder.events, isEmpty);
  });

  test('preview accepts only configured http(s) destinations', () async {
    for (final value in [
      '',
      'github.com/project',
      'file:///tmp/test',
      'https://',
      'https://user:password@example.com',
      '::::',
      'https://github.com/FriesI23/mhabit',
      'http://example.com/project',
    ]) {
      final owner = AppSupportOwner(
        loadInfo: () async => stubAboutInfo(sourceCodeUrl: value),
      );
      final valid =
          value == 'https://github.com/FriesI23/mhabit' ||
          value == 'http://example.com/project';
      var presentations = 0;
      final shown = await owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (info) async {
          presentations++;
          expect(info.sourceCodeUrl, value);
          return AppSupportPromptResult.later;
        },
      );
      expect(shown, valid, reason: value);
      expect(presentations, valid ? 1 : 0, reason: value);
      owner.dispose();
    }
  });
  for (final skip in ['initialization', 'blocked', 'ineligible', 'unsafe']) {
    test('$skip startup does not read configuration or present UI', () async {
      final reminder = _Reminder();
      var loads = 0;
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async {
          loads++;
          return stubAboutInfo();
        },
      );
      if (skip == 'blocked') owner.skipPrompt();
      reminder.eligible = skip != 'ineligible';
      final check = owner.checkPrompt(
        canPresent: () => skip != 'unsafe',
        showPrompt: (_) async {
          fail('A skipped startup must not present a prompt');
        },
      );
      if (skip == 'initialization') {
        reminder.ready.completeError(StateError('read failed'));
      } else {
        reminder.ready.complete();
      }
      await check;
      expect(loads, 0);
      expect(reminder.events, isEmpty);
    });
  }

  test(
    'concurrent startup checks share configuration, presentation and result',
    () async {
      final reminder = _Reminder();
      var loads = 0;
      var presentations = 0;
      final result = Completer<AppSupportPromptResult>();
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async {
          loads++;
          return stubAboutInfo();
        },
      );
      Future<AppSupportPromptResult> present(AboutInfo info) {
        presentations++;
        expect(info.sourceCodeUrl, 'https://example.com/project');
        return result.future;
      }

      final first = owner.checkPrompt(
        canPresent: () => true,
        showPrompt: present,
      );
      expect(
        identical(
          first,
          owner.checkPrompt(canPresent: () => true, showPrompt: present),
        ),
        isTrue,
      );
      reminder.ready.complete();
      await pumpEventQueue();
      expect(loads, 1);
      expect(presentations, 1);
      expect(reminder.events, isEmpty);
      result.complete(AppSupportPromptResult.supportOpened);
      await first;
      await owner.checkPrompt(canPresent: () => true, showPrompt: present);
      expect(reminder.events, [RateMyAppEventType.rateButtonPressed]);
      expect(presentations, 1);
    },
  );

  test('owner blocks prompting for unconfirmed sync and ongoing work', () {
    final owner = AppSupportOwner();
    addTearDown(owner.dispose);
    final server = AppWebDavSyncServer.newServer(
      identity: 'test',
      path: 'https://example.com',
    );
    expect(
      owner.canPromptWithSync(enabled: true, server: server, processing: false),
      isFalse,
    );
    expect(
      owner.canPromptWithSync(
        enabled: false,
        server: server,
        processing: false,
      ),
      isTrue,
    );
    expect(
      owner.canPromptWithSync(
        enabled: true,
        server: server.copyWith(configed: true),
        processing: false,
      ),
      isTrue,
    );
    expect(
      owner.canPromptWithSync(enabled: false, server: null, processing: true),
      isFalse,
    );
  });

  test('sync policy cannot reopen a cancelled or disposed session', () {
    final owner = AppSupportOwner();
    owner.skipPrompt();
    expect(
      owner.canPromptWithSync(enabled: false, server: null, processing: false),
      isFalse,
    );
    owner.dispose();
    final disposed = AppSupportOwner()..dispose();
    expect(
      disposed.canPromptWithSync(
        enabled: false,
        server: null,
        processing: false,
      ),
      isFalse,
    );
  });

  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    final platform = debugDefaultTargetPlatformOverride;
    addTearDown(() {
      SharedPreferencesAsyncPlatform.instance = previous;
      debugDefaultTargetPlatformOverride = platform;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('rate_my_app'), null);
    });
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'appSupport_minimumDate': DateTime.utc(2000).millisecondsSinceEpoch,
          'appSupport_launches': 9,
          'appSupport_doNotOpenAgain': false,
          'unrelated': 'keep',
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('rate_my_app'), (
          _,
        ) async {
          fail('Native review must not be called');
        });
  });

  test(
    'initialization is shared and one startup can claim only once',
    () async {
      final reminder = _Reminder();
      final owner = AppSupportOwner(reminder: reminder);
      final AsyncInitialization initialization = owner;
      final first = initialization.init();
      expect(identical(first, owner.init()), isTrue);
      expect(reminder.starts, 1);
      reminder.ready.complete();
      expect(await first, isTrue);
      expect(owner.claimPrompt(canPresent: true), isTrue);
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );

  test('initialization failure is cached without a retry', () async {
    final reminder = _Reminder();
    final owner = AppSupportOwner(reminder: reminder);
    final initialized = owner.init();
    reminder.ready.completeError(StateError('read failed'));
    expect(await initialized, isFalse);
    expect(await owner.init(), isFalse);
    expect(reminder.starts, 1);
    expect(owner.claimPrompt(canPresent: true), isFalse);
  });

  for (final blocked in [true, false]) {
    test('startup conflict is final blocked=$blocked', () async {
      final owner = AppSupportOwner();
      await owner.init();
      if (blocked) owner.skipPrompt();
      expect(owner.claimPrompt(canPresent: blocked), isFalse);
      expect(owner.claimPrompt(canPresent: true), isFalse);
    });
  }

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    test(
      'real package restores counts without review channel: $platform',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        final owner = AppSupportOwner();
        expect(await owner.init(), isTrue);
        expect(
          await SharedPreferencesAsync().getInt('appSupport_launches'),
          10,
        );
        expect(owner.claimPrompt(canPresent: true), isTrue);
        expect(await owner.consume(AppSupportPromptResult.never), isTrue);
        final restored = AppSupportOwner();
        expect(await restored.init(), isTrue);
        expect(restored.claimPrompt(canPresent: true), isFalse);
        expect(await SharedPreferencesAsync().getString('unrelated'), 'keep');
      },
    );
  }

  test(
    'developer reset arms next launch after permanent dismissal without prompting now',
    () async {
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      await owner.consume(AppSupportPromptResult.never);
      expect(await owner.resetForNextLaunch(), isTrue);
      final prefs = SharedPreferencesAsync();
      expect(await prefs.getBool('appSupport_doNotOpenAgain'), isFalse);
      expect(await prefs.getInt('appSupport_launches'), 9);
      expect(
        await prefs.getInt('appSupport_minimumDate'),
        DateTime.utc(1970).millisecondsSinceEpoch,
      );
      expect(await prefs.getString('unrelated'), 'keep');
      expect(owner.claimPrompt(canPresent: true), isFalse);
      final next = AppSupportOwner();
      addTearDown(next.dispose);
      await next.init();
      expect(next.claimPrompt(canPresent: true), isTrue);
    },
  );

  test(
    'developer reset bypasses later cooldown and reports save failures',
    () async {
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      await owner.init();
      await owner.consume(AppSupportPromptResult.later);
      expect(await owner.resetForNextLaunch(), isTrue);
      final next = AppSupportOwner();
      addTearDown(next.dispose);
      await next.init();
      expect(next.claimPrompt(canPresent: true), isTrue);
      SharedPreferencesAsyncPlatform.instance = _FailingPreferences();
      expect(await owner.resetForNextLaunch(), isFalse);
      expect(owner.developerActionInProgress, isFalse);
    },
  );

  test(
    'developer preview repeats without events, initialization, or disturbing an armed reset',
    () async {
      final reminder = _Reminder()..ready.complete();
      final owner = AppSupportOwner(
        reminder: reminder,
        loadInfo: () async => stubAboutInfo(),
      );
      addTearDown(owner.dispose);
      final prefs = SharedPreferencesAsync();
      final before = await prefs.getAll();
      var shows = 0;
      for (final result in AppSupportPromptResult.values) {
        expect(
          await owner.previewPrompt(
            canPresent: () => true,
            showPrompt: (info) async {
              shows++;
              return result;
            },
          ),
          result != AppSupportPromptResult.aborted,
        );
      }
      expect(shows, AppSupportPromptResult.values.length);
      expect(reminder.starts, 0);
      expect(reminder.events, isEmpty);
      expect(await prefs.getAll(), before);
      await owner.init();
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );

  test(
    'owner disposal invalidates an in-flight developer preview result',
    () async {
      final started = Completer<void>();
      final result = Completer<AppSupportPromptResult>();
      final owner = AppSupportOwner(loadInfo: () async => stubAboutInfo());
      final before = await SharedPreferencesAsync().getAll();
      var notifications = 0;
      owner.addListener(() => notifications++);
      final preview = owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (_) {
          started.complete();
          return result.future;
        },
      );
      await started.future;
      owner.dispose();
      result.complete(AppSupportPromptResult.later);
      expect(await preview, isFalse);
      expect(notifications, 1);
      expect(await SharedPreferencesAsync().getAll(), before);
    },
  );

  test('pending developer preview blocks duplicates and reset', () async {
    final ready = Completer<AppSupportPromptResult>();
    final owner = AppSupportOwner(loadInfo: () async => stubAboutInfo());
    addTearDown(owner.dispose);
    var shows = 0;
    final preview = owner.previewPrompt(
      canPresent: () => true,
      showPrompt: (_) {
        shows++;
        return ready.future;
      },
    );
    await pumpEventQueue();
    expect(owner.developerActionInProgress, isTrue);
    expect(
      await owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (_) async {
          fail('duplicate');
        },
      ),
      isFalse,
    );
    expect(await owner.resetForNextLaunch(), isFalse);
    expect(shows, 1);
    ready.complete(AppSupportPromptResult.later);
    expect(await preview, isTrue);
    expect(owner.developerActionInProgress, isFalse);
  });

  for (final conflict in ['invalid', 'load-error', 'unsafe', 'disposed']) {
    test('developer preview $conflict does not present or write', () async {
      final info = Completer<AboutInfo>();
      final owner = AppSupportOwner(loadInfo: () => info.future);
      final before = await SharedPreferencesAsync().getAll();
      final preview = owner.previewPrompt(
        canPresent: () => conflict != 'unsafe',
        showPrompt: (_) async {
          fail('preview is unavailable');
        },
      );
      if (conflict == 'disposed') owner.dispose();
      if (conflict == 'load-error') {
        info.completeError(StateError('asset failed'));
      } else {
        info.complete(
          conflict == 'invalid' ? const AboutInfo.empty() : stubAboutInfo(),
        );
      }
      expect(await preview, isFalse);
      expect(await SharedPreferencesAsync().getAll(), before);
      if (conflict != 'disposed') owner.dispose();
    });
  }

  test('first launch persists but is not eligible', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final owner = AppSupportOwner();
    expect(await owner.init(), isTrue);
    expect(owner.claimPrompt(canPresent: true), isFalse);
    expect(await SharedPreferencesAsync().getInt('appSupport_launches'), 1);
  });

  test(
    'later survives a new owner with package date and count semantics',
    () async {
      final owner = AppSupportOwner();
      await owner.init();
      final before = DateTime.now().add(const Duration(days: 7));
      expect(await owner.consume(AppSupportPromptResult.later), isTrue);
      final after = DateTime.now().add(const Duration(days: 7));
      final saved = (await SharedPreferencesAsync().getInt(
        'appSupport_minimumDate',
      ))!;
      expect(
        saved,
        inInclusiveRange(
          before.millisecondsSinceEpoch,
          after.millisecondsSinceEpoch,
        ),
      );
      expect(await SharedPreferencesAsync().getInt('appSupport_launches'), 0);
      final restored = AppSupportOwner();
      await restored.init();
      expect(restored.claimPrompt(canPresent: true), isFalse);
    },
  );

  for (final result in [
    AppSupportPromptResult.supportOpened,
    AppSupportPromptResult.never,
  ]) {
    test('$result persists permanent dismissal', () async {
      final owner = AppSupportOwner();
      await owner.init();
      await owner.consume(result);
      expect(
        await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
        isTrue,
      );
    });
  }

  test('events are consumed once and failure does not retry', () async {
    final reminder = _Reminder()..failSave = true;
    final owner = AppSupportOwner(reminder: reminder);
    reminder.ready.complete();
    await owner.init();
    expect(await owner.consume(AppSupportPromptResult.aborted), isFalse);
    expect(reminder.events, isEmpty);
    expect(await owner.consume(AppSupportPromptResult.later), isFalse);
    expect(await owner.consume(AppSupportPromptResult.never), isFalse);
    expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
  });

  test('real async storage write failure skips startup', () async {
    SharedPreferencesAsyncPlatform.instance = _FailingPreferences();
    final owner = AppSupportOwner();
    expect(await owner.init(), isFalse);
    expect(owner.claimPrompt(canPresent: true), isFalse);
  });
}
