// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/async.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/support/commons.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../../../support/stub/about_info.dart';

final _today = DateTime.utc(2026, 11, 12);

Map<String, Object> _eligibleValues({bool closed = false}) => {
  'appSupport_minimumDate': DateTime.utc(2000).millisecondsSinceEpoch,
  'appSupport_launches': 9,
  'appSupport_doNotOpenAgain': closed,
  'unrelated': 'keep',
};

final class _ControlledPreferences extends InMemorySharedPreferencesAsync {
  _ControlledPreferences() : super.withData(_eligibleValues());

  int reads = 0;
  int writes = 0;
  bool failReads = false;
  bool failWrites = false;
  Completer<void>? pendingRead;
  Completer<void>? pendingWrite;
  Completer<void>? writeStarted;

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    reads++;
    await pendingRead?.future;
    if (failReads) throw StateError('read failed');
    return super.getPreferences(parameters, options);
  }

  Future<void> _beforeWrite() async {
    writes++;
    if (writeStarted case final started? when !started.isCompleted) {
      started.complete();
    }
    await pendingWrite?.future;
    if (failWrites) throw StateError('write failed');
  }

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    await _beforeWrite();
    return super.setInt(key, value, options);
  }

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    await _beforeWrite();
    return super.setBool(key, value, options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _ControlledPreferences preferences;

  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    preferences = _ControlledPreferences();
    SharedPreferencesAsyncPlatform.instance = preferences;
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  });

  AppSupportOwner createOwner({
    Future<AboutInfo> Function()? loadInfo,
    SharedPreferencesAsync? storage,
  }) {
    final owner = AppSupportOwner(
      preferences: storage,
      now: () => _today,
      loadInfo: loadInfo ?? () async => stubAboutInfo(),
    );
    addTearDown(owner.dispose);
    return owner;
  }

  test(
    'channel changes notify once without touching reminder storage',
    () async {
      final owner = createOwner();
      var notifications = 0;
      owner.addListener(() => notifications++);
      final selected = owner.distribution == AppDistribution.googlePlay
          ? AppDistribution.appStore
          : AppDistribution.googlePlay;
      owner.setDistribution(selected);
      owner.setDistribution(selected);
      expect(owner.distribution, selected);
      expect(notifications, 1);
      expect(preferences.reads, 0);
      expect(preferences.writes, 0);
    },
  );

  test('a new owner restores the compiled channel', () {
    final owner = createOwner();
    owner.setDistribution(AppDistribution.custom);
    owner.dispose();
    owner.setDistribution(AppDistribution.github);
    expect(owner.distribution, AppDistribution.custom);
    expect(createOwner().distribution, defaultAppDistribution);
  });

  test('store preview can work without a GitHub target', () async {
    final owner = createOwner(loadInfo: () async => const AboutInfo.empty())
      ..setDistribution(AppDistribution.appStore);
    expect(
      await owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (_) async => AppSupportPromptResult.storeOpened,
      ),
      isTrue,
    );
    expect(preferences.reads, 0);
    expect(preferences.writes, 0);
    expect(owner.initializationComplete, isFalse);
  });

  test(
    'initialization shares one read and counts one foreground launch',
    () async {
      preferences.pendingRead = Completer<void>();
      final owner = createOwner();
      final AsyncInitialization initialization = owner;
      final first = initialization.init();
      expect(identical(first, owner.init()), isTrue);
      expect(preferences.reads, 1);
      expect(preferences.writes, 0);
      preferences.pendingRead!.complete();
      expect(await first, isTrue);
      expect(await SharedPreferencesAsync().getInt('appSupport_launches'), 10);
      expect(owner.claimPrompt(canPresent: true), isTrue);
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );

  test(
    'initialization failure is cached without retry or presentation',
    () async {
      preferences.failReads = true;
      final owner = createOwner();
      expect(await owner.init(), isFalse);
      expect(await owner.init(), isFalse);
      expect(preferences.reads, 1);
      expect(preferences.writes, 0);
      expect(owner.initializationComplete, isTrue);
      expect(owner.initialized, isFalse);
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );

  test(
    'initialization waits for persistence before publishing eligibility',
    () async {
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      final owner = createOwner();
      final result = owner.init();
      await preferences.writeStarted!.future;
      expect(owner.initialized, isFalse);
      expect(owner.initializationComplete, isFalse);
      preferences.pendingWrite!.complete();
      expect(await result, isTrue);
      expect(owner.initialized, isTrue);
    },
  );

  test(
    'owner disposal during initialization skips writes and notification',
    () async {
      preferences.pendingRead = Completer<void>();
      final owner = createOwner();
      final ProviderMounted lifetime = owner;
      var notifications = 0;
      owner.addListener(() => notifications++);
      final result = owner.init();
      expect(lifetime.mounted, isTrue);
      owner.dispose();
      preferences.pendingRead!.complete();
      expect(await result, isFalse);
      expect(lifetime.mounted, isFalse);
      expect(owner.initialized, isFalse);
      expect(preferences.writes, 0);
      expect(notifications, 0);
      expect(await owner.consume(AppSupportPromptResult.later), isFalse);
    },
  );

  test('disposed owner rejects work before storage access', () async {
    final owner = createOwner();
    final AsyncInitialization initialization = owner;
    owner.dispose();
    owner.dispose();
    final first = initialization.init();
    expect(identical(first, initialization.init()), isTrue);
    expect(await first, isFalse);
    expect(await owner.recordSupportOpened(), isFalse);
    expect(await owner.resetForNextLaunch(), isFalse);
    expect(preferences.reads, 0);
    expect(preferences.writes, 0);
  });

  test('injected preferences keep their selected storage backend', () async {
    final storage = SharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final owner = createOwner(storage: storage);
    expect(await owner.init(), isTrue);
    expect(owner.claimPrompt(canPresent: true), isTrue);
    expect(preferences.reads, 1);
    expect(await SharedPreferencesAsync().getAll(), isEmpty);
  });

  test(
    'preview accepts configured HTTP destinations on GitHub channel',
    () async {
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
        final owner = createOwner(
          loadInfo: () async => stubAboutInfo(sourceCodeUrl: value),
        )..setDistribution(AppDistribution.github);
        final valid =
            value == 'https://github.com/FriesI23/mhabit' ||
            value == 'http://example.com/project';
        var presentations = 0;
        expect(
          await owner.previewPrompt(
            canPresent: () => true,
            showPrompt: (_) async {
              presentations++;
              return AppSupportPromptResult.later;
            },
          ),
          valid,
          reason: value,
        );
        expect(presentations, valid ? 1 : 0);
      }
      expect(preferences.reads, 0);
      expect(preferences.writes, 0);
    },
  );

  for (final skip in ['initialization', 'blocked', 'ineligible', 'unsafe']) {
    test('$skip startup avoids configuration and UI', () async {
      var loads = 0;
      var presentations = 0;
      if (skip == 'initialization') preferences.failReads = true;
      if (skip == 'ineligible') {
        await SharedPreferencesAsync().setInt('appSupport_launches', 0);
      }
      final owner = createOwner(
        loadInfo: () async {
          loads++;
          return stubAboutInfo();
        },
      );
      if (skip == 'blocked') owner.skipPrompt();
      await owner.checkPrompt(
        canPresent: () => skip != 'unsafe',
        showPrompt: (_) async {
          presentations++;
          return AppSupportPromptResult.aborted;
        },
      );
      expect(loads, 0);
      expect(presentations, 0);
    });
  }

  test(
    'concurrent checks share configuration, presentation, and one result',
    () async {
      var loads = 0;
      var presentations = 0;
      final ready = Completer<AppSupportPromptResult>();
      final owner = createOwner(
        loadInfo: () async {
          loads++;
          return stubAboutInfo();
        },
      );
      Future<AppSupportPromptResult> show(AboutInfo _) {
        presentations++;
        return ready.future;
      }

      final first = owner.checkPrompt(canPresent: () => true, showPrompt: show);
      expect(
        identical(
          first,
          owner.checkPrompt(canPresent: () => true, showPrompt: show),
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(loads, 1);
      expect(presentations, 1);
      expect(owner.reminderClosed, isFalse);
      ready.complete(AppSupportPromptResult.supportOpened);
      await first;
      await owner.checkPrompt(canPresent: () => true, showPrompt: show);
      expect(owner.reminderClosed, isTrue);
      expect(presentations, 1);
    },
  );

  for (final interruption in ['blocked', 'unsafe', 'disposed']) {
    test(
      '$interruption during configuration loading prevents presentation',
      () async {
        final info = Completer<AboutInfo>();
        var safe = true;
        var presentations = 0;
        final owner = createOwner(loadInfo: () => info.future);
        final check = owner.checkPrompt(
          canPresent: () => safe,
          showPrompt: (_) async {
            presentations++;
            return AppSupportPromptResult.never;
          },
        );
        await pumpEventQueue();
        if (interruption == 'blocked') owner.skipPrompt();
        if (interruption == 'unsafe') safe = false;
        if (interruption == 'disposed') owner.dispose();
        info.complete(stubAboutInfo());
        await check;
        expect(presentations, 0);
        expect(
          await SharedPreferencesAsync().getBool('appSupport_doNotOpenAgain'),
          isFalse,
        );
      },
    );
  }

  test('owner blocks prompting for unconfirmed sync and ongoing work', () {
    final owner = createOwner();
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
    owner.skipPrompt();
    expect(
      owner.canPromptWithSync(enabled: false, server: null, processing: false),
      isFalse,
    );
    owner.dispose();
    expect(
      owner.canPromptWithSync(enabled: false, server: null, processing: false),
      isFalse,
    );
  });

  for (final blocked in [true, false]) {
    test(
      'a failed startup claim cannot reopen with blocked=$blocked',
      () async {
        final owner = createOwner();
        await owner.init();
        if (blocked) owner.skipPrompt();
        expect(owner.claimPrompt(canPresent: blocked), isFalse);
        expect(owner.claimPrompt(canPresent: true), isFalse);
      },
    );
  }

  test(
    'developer reset restores next-launch eligibility after dismissal',
    () async {
      final owner = createOwner();
      await owner.init();
      await owner.consume(AppSupportPromptResult.never);
      expect(await owner.resetForNextLaunch(), isTrue);
      final storage = SharedPreferencesAsync();
      expect(await storage.getBool('appSupport_doNotOpenAgain'), isFalse);
      expect(await storage.getInt('appSupport_launches'), 9);
      expect(await storage.getInt('appSupport_minimumDate'), 0);
      expect(await storage.getString('unrelated'), 'keep');
      expect(owner.claimPrompt(canPresent: true), isFalse);
      final next = createOwner();
      await next.init();
      expect(next.claimPrompt(canPresent: true), isTrue);
    },
  );

  test('reset can bypass cooldown and reports a failed write', () async {
    final owner = createOwner();
    await owner.init();
    await owner.consume(AppSupportPromptResult.later);
    expect(await owner.resetForNextLaunch(), isTrue);
    final next = createOwner();
    await next.init();
    expect(next.claimPrompt(canPresent: true), isTrue);
    preferences.failWrites = true;
    expect(await owner.resetForNextLaunch(), isFalse);
    expect(owner.developerActionInProgress, isFalse);
  });

  test(
    'reset waits for an existing explicit save instead of racing its state',
    () async {
      final owner = createOwner();
      await owner.init();
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      final close = owner.recordSupportOpened();
      await preferences.writeStarted!.future;
      final reset = owner.resetForNextLaunch();
      expect(owner.developerActionInProgress, isTrue);
      preferences.pendingWrite!.complete();
      expect(await close, isTrue);
      expect(await reset, isTrue);
      expect(owner.reminderClosed, isFalse);
      expect(await SharedPreferencesAsync().getInt('appSupport_launches'), 9);
    },
  );

  test(
    'developer preview repeats without initialization or preference writes',
    () async {
      final owner = createOwner();
      final before = await SharedPreferencesAsync().getAll();
      final reads = preferences.reads;
      var shows = 0;
      for (final result in AppSupportPromptResult.values) {
        expect(
          await owner.previewPrompt(
            canPresent: () => true,
            showPrompt: (_) async {
              shows++;
              return result;
            },
          ),
          result != AppSupportPromptResult.aborted,
        );
      }
      expect(shows, AppSupportPromptResult.values.length);
      expect(preferences.reads, reads);
      expect(preferences.writes, 0);
      expect(await SharedPreferencesAsync().getAll(), before);
      await owner.init();
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );

  test('pending preview blocks duplicates and reset without writes', () async {
    final ready = Completer<AppSupportPromptResult>();
    final owner = createOwner();
    var shows = 0;
    var notifications = 0;
    owner.addListener(() => notifications++);
    final preview = owner.previewPrompt(
      canPresent: () => true,
      showPrompt: (_) {
        shows++;
        return ready.future;
      },
    );
    await pumpEventQueue();
    expect(owner.developerActionInProgress, isTrue);
    expect(notifications, 0);
    expect(
      await owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (_) async => AppSupportPromptResult.later,
      ),
      isFalse,
    );
    expect(await owner.resetForNextLaunch(), isFalse);
    expect(shows, 1);
    expect(preferences.writes, 0);
    expect(notifications, 0);
    ready.complete(AppSupportPromptResult.later);
    expect(await preview, isTrue);
    expect(owner.developerActionInProgress, isFalse);
    expect(notifications, 0);
  });

  test(
    'disposal invalidates an in-flight preview without late notification',
    () async {
      final started = Completer<void>();
      final ready = Completer<AppSupportPromptResult>();
      final owner = createOwner();
      var notifications = 0;
      owner.addListener(() => notifications++);
      final preview = owner.previewPrompt(
        canPresent: () => true,
        showPrompt: (_) {
          started.complete();
          return ready.future;
        },
      );
      await started.future;
      owner.dispose();
      ready.complete(AppSupportPromptResult.later);
      expect(await preview, isFalse);
      expect(notifications, 0);
      expect(preferences.writes, 0);
    },
  );

  for (final conflict in ['invalid', 'load-error', 'unsafe', 'disposed']) {
    test('preview $conflict does not present or persist', () async {
      final info = Completer<AboutInfo>();
      final owner = createOwner(loadInfo: () => info.future)
        ..setDistribution(AppDistribution.github);
      var presentations = 0;
      final preview = owner.previewPrompt(
        canPresent: () => conflict != 'unsafe',
        showPrompt: (_) async {
          presentations++;
          return AppSupportPromptResult.later;
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
      expect(presentations, 0);
      expect(preferences.writes, 0);
    });
  }

  for (final result in [
    AppSupportPromptResult.supportOpened,
    AppSupportPromptResult.storeOpened,
    AppSupportPromptResult.later,
    AppSupportPromptResult.never,
  ]) {
    test(
      'startup reports persistence failure for $result exactly once',
      () async {
        final owner = createOwner();
        var failures = 0;
        var shows = 0;
        await owner.checkPrompt(
          canPresent: () => true,
          showPrompt: (_) async {
            shows++;
            preferences.failWrites = true;
            return result;
          },
          onSaveFailed: () => failures++,
        );
        await owner.checkPrompt(
          canPresent: () => true,
          showPrompt: (_) async {
            shows++;
            return result;
          },
          onSaveFailed: () => failures++,
        );
        expect(shows, 1);
        expect(failures, 1);
        expect(owner.reminderClosed, isFalse);
      },
    );
  }
}
