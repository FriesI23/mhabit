// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../support/stub/about_info.dart';

class _Reminder extends RateMyApp {
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

void main() {
  test(
    'owner disposal during initialization cannot notify or consume later',
    () async {
      final reminder = _Reminder();
      final owner = AppSupportOwner(reminder: reminder);
      final result = owner.initialize();
      owner.dispose();
      reminder.ready.complete();
      expect(await result, isFalse);
      expect(owner.initialized, isFalse);
      expect(await owner.consume(AppSupportPromptResult.later), isFalse);
      expect(reminder.events, isEmpty);
    },
  );

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
        showPrompt: (target) async {
          presentations++;
          expect(target.toString(), value);
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
      Future<AppSupportPromptResult> present(Uri target) {
        presentations++;
        expect(target, Uri.parse('https://example.com/project'));
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
      result.complete(AppSupportPromptResult.githubOpened);
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
      final first = owner.initialize();
      expect(identical(first, owner.initialize()), isTrue);
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
    final initialized = owner.initialize();
    reminder.ready.completeError(StateError('read failed'));
    expect(await initialized, isFalse);
    expect(await owner.initialize(), isFalse);
    expect(reminder.starts, 1);
    expect(owner.claimPrompt(canPresent: true), isFalse);
  });

  for (final blocked in [true, false]) {
    test('startup conflict is final blocked=$blocked', () async {
      final owner = AppSupportOwner();
      await owner.initialize();
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
        expect(await owner.initialize(), isTrue);
        expect(
          await SharedPreferencesAsync().getInt('appSupport_launches'),
          10,
        );
        expect(owner.claimPrompt(canPresent: true), isTrue);
        expect(await owner.consume(AppSupportPromptResult.never), isTrue);
        final restored = AppSupportOwner();
        expect(await restored.initialize(), isTrue);
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
      await owner.initialize();
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
      await next.initialize();
      expect(next.claimPrompt(canPresent: true), isTrue);
    },
  );

  test(
    'developer reset bypasses later cooldown and reports save failures',
    () async {
      final owner = AppSupportOwner();
      addTearDown(owner.dispose);
      await owner.initialize();
      await owner.consume(AppSupportPromptResult.later);
      expect(await owner.resetForNextLaunch(), isTrue);
      final next = AppSupportOwner();
      addTearDown(next.dispose);
      await next.initialize();
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
            showPrompt: (target) async {
              shows++;
              return result;
            },
          ),
          result != AppSupportPromptResult.aborted,
        );
      }
      expect(shows, 4);
      expect(reminder.starts, 0);
      expect(reminder.events, isEmpty);
      expect(await prefs.getAll(), before);
      await owner.initialize();
      expect(owner.claimPrompt(canPresent: true), isFalse);
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
    expect(await owner.initialize(), isTrue);
    expect(owner.claimPrompt(canPresent: true), isFalse);
    expect(await SharedPreferencesAsync().getInt('appSupport_launches'), 1);
  });

  test(
    'later survives a new owner with package date and count semantics',
    () async {
      final owner = AppSupportOwner();
      await owner.initialize();
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
      await restored.initialize();
      expect(restored.claimPrompt(canPresent: true), isFalse);
    },
  );

  for (final result in [
    AppSupportPromptResult.githubOpened,
    AppSupportPromptResult.never,
  ]) {
    test('$result persists permanent dismissal', () async {
      final owner = AppSupportOwner();
      await owner.initialize();
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
    await owner.initialize();
    expect(await owner.consume(AppSupportPromptResult.aborted), isFalse);
    expect(reminder.events, isEmpty);
    expect(await owner.consume(AppSupportPromptResult.later), isFalse);
    expect(await owner.consume(AppSupportPromptResult.never), isFalse);
    expect(reminder.events, [RateMyAppEventType.laterButtonPressed]);
  });

  test('real async storage write failure skips startup', () async {
    SharedPreferencesAsyncPlatform.instance = _FailingPreferences();
    final owner = AppSupportOwner();
    expect(await owner.initialize(), isFalse);
    expect(owner.claimPrompt(canPresent: true), isFalse);
  });
}
