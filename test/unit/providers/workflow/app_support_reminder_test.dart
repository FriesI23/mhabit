// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final _today = DateTime.utc(2026, 11, 12);
const _dateKey = 'appSupport_minimumDate';
const _launchesKey = 'appSupport_launches';
const _closedKey = 'appSupport_doNotOpenAgain';

final class _ControlledPreferences extends InMemorySharedPreferencesAsync {
  _ControlledPreferences(super.values) : super.withData();

  bool failWrites = false;
  bool failBooleanWrites = false;
  Completer<void>? pendingWrite;
  Completer<void>? writeStarted;

  Future<void> _beforeWrite() async {
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
    if (failBooleanWrites) throw StateError('boolean write failed');
    return super.setBool(key, value, options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
          _launchesKey: 9,
          _closedKey: false,
          'unrelated': 'keep',
        });
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  });

  AppSupportOwner createOwner({DateTime Function()? now}) {
    final owner = AppSupportOwner(now: now ?? () => _today);
    addTearDown(owner.dispose);
    return owner;
  }

  test(
    'first install creates only the existing reminder keys and waits seven days',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final owner = createOwner();
      expect(await owner.init(), isTrue);
      expect(owner.claimPrompt(canPresent: true), isFalse);
      expect(await SharedPreferencesAsync().getAll(), {
        _dateKey: _today.add(const Duration(days: 7)).millisecondsSinceEpoch,
        _launchesKey: 1,
        _closedKey: false,
      });
    },
  );

  for (final (days, launches, closed, eligible) in [
    (-1, 9, false, true),
    (0, 9, false, false),
    (1, 9, false, false),
    (-1, 8, false, false),
    (-1, 9, true, false),
    (-1, -20, false, false),
    (-1, 100, false, true),
  ]) {
    test(
      'legacy eligibility date=$days launches=$launches closed=$closed',
      () async {
        final date = _today.add(Duration(days: days));
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              _dateKey: date.millisecondsSinceEpoch,
              _launchesKey: launches,
              _closedKey: closed,
              'unrelated': 'keep',
            });
        final owner = createOwner();
        expect(await owner.init(), isTrue);
        expect(owner.claimPrompt(canPresent: true), eligible);
        expect(await SharedPreferencesAsync().getAll(), {
          _dateKey: date.millisecondsSinceEpoch,
          _launchesKey: launches + 1,
          _closedKey: closed,
          'unrelated': 'keep',
        });
      },
    );
  }

  for (final result in [
    AppSupportPromptResult.later,
    AppSupportPromptResult.storeOpened,
  ]) {
    test(
      '$result preserves legacy seven-day and ten-launch cooldown across owners',
      () async {
        final owner = createOwner();
        await owner.init();
        expect(await owner.consume(result), isTrue);
        expect(owner.reminderClosed, isFalse);
        expect(await SharedPreferencesAsync().getAll(), {
          _dateKey: _today.add(const Duration(days: 7)).millisecondsSinceEpoch,
          _launchesKey: 0,
          _closedKey: false,
          'unrelated': 'keep',
        });
        final next = createOwner(
          now: () => _today.add(const Duration(days: 8)),
        );
        await next.init();
        expect(next.claimPrompt(canPresent: true), isFalse);
        expect(await SharedPreferencesAsync().getInt(_launchesKey), 1);
      },
    );
  }

  for (final result in [
    AppSupportPromptResult.supportOpened,
    AppSupportPromptResult.never,
  ]) {
    test('$result preserves permanent dismissal across owners', () async {
      final owner = createOwner();
      await owner.init();
      expect(await owner.consume(result), isTrue);
      expect(owner.reminderClosed, isTrue);
      final next = createOwner();
      await next.init();
      expect(next.reminderClosed, isTrue);
      expect(next.claimPrompt(canPresent: true), isFalse);
      expect(await SharedPreferencesAsync().getString('unrelated'), 'keep');
    });
  }

  test(
    'store links retain an existing permanent dismissal while saving cooldown',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
            _launchesKey: -20,
            _closedKey: true,
          });
      final owner = createOwner();
      await owner.init();
      expect(
        await owner.recordSupportOpened(AppSupportPromptResult.storeOpened),
        isTrue,
      );
      expect(owner.reminderClosed, isTrue);
      expect(await SharedPreferencesAsync().getAll(), {
        _dateKey: _today.add(const Duration(days: 7)).millisecondsSinceEpoch,
        _launchesKey: -29,
        _closedKey: true,
      });
    },
  );

  test(
    'explicit GitHub action can close reminders after an automatic later',
    () async {
      final owner = createOwner();
      await owner.init();
      expect(await owner.consume(AppSupportPromptResult.later), isTrue);
      expect(await owner.recordSupportOpened(), isTrue);
      expect(owner.reminderClosed, isTrue);
      expect(await SharedPreferencesAsync().getInt(_launchesKey), 0);
    },
  );

  test(
    'auxiliary, failure, and aborted results do not consume the one-event guard',
    () async {
      final owner = createOwner();
      await owner.init();
      final before = await SharedPreferencesAsync().getAll();
      for (final result in [
        AppSupportPromptResult.auxiliaryAction,
        AppSupportPromptResult.actionFailed,
        AppSupportPromptResult.aborted,
      ]) {
        expect(await owner.consume(result), isFalse);
      }
      expect(await SharedPreferencesAsync().getAll(), before);
      expect(await owner.consume(AppSupportPromptResult.later), isTrue);
      expect(await owner.consume(AppSupportPromptResult.never), isFalse);
    },
  );

  test('failed automatic persistence does not retry another result', () async {
    final preferences = _ControlledPreferences({
      _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
      _launchesKey: 9,
      _closedKey: false,
    });
    SharedPreferencesAsyncPlatform.instance = preferences;
    final owner = createOwner();
    await owner.init();
    preferences.failWrites = true;
    expect(await owner.consume(AppSupportPromptResult.later), isFalse);
    preferences.failWrites = false;
    expect(await owner.consume(AppSupportPromptResult.never), isFalse);
    expect(owner.reminderClosed, isFalse);
    expect(await SharedPreferencesAsync().getInt(_launchesKey), 10);
  });

  test(
    'failed Settings persistence can retry without publishing closure',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      SharedPreferencesAsyncPlatform.instance = preferences;
      final owner = createOwner();
      await owner.init();
      preferences.failBooleanWrites = true;
      expect(await owner.recordSupportOpened(), isFalse);
      expect(owner.reminderClosed, isFalse);
      expect(await SharedPreferencesAsync().getBool(_closedKey), isFalse);
      preferences.failBooleanWrites = false;
      expect(await owner.recordSupportOpened(), isTrue);
      expect(owner.reminderClosed, isTrue);
      expect(await SharedPreferencesAsync().getBool(_closedKey), isTrue);
    },
  );

  test(
    'explicit store saves serialize and keep the legacy negative counter',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      SharedPreferencesAsyncPlatform.instance = preferences;
      final owner = createOwner();
      await owner.init();
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      final first = owner.recordSupportOpened(
        AppSupportPromptResult.storeOpened,
      );
      await preferences.writeStarted!.future;
      final second = owner.recordSupportOpened(
        AppSupportPromptResult.storeOpened,
      );
      preferences.pendingWrite!.complete();
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(await SharedPreferencesAsync().getInt(_launchesKey), -10);
      expect(owner.reminderClosed, isFalse);
    },
  );

  test(
    'disposal during a save prevents later publication and remaining writes',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      SharedPreferencesAsyncPlatform.instance = preferences;
      final owner = createOwner();
      await owner.init();
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      var notifications = 0;
      owner.addListener(() => notifications++);
      final save = owner.recordSupportOpened();
      await preferences.writeStarted!.future;
      owner.dispose();
      preferences.pendingWrite!.complete();
      expect(await save, isFalse);
      expect(owner.reminderClosed, isFalse);
      expect(notifications, 0);
      expect(await SharedPreferencesAsync().getBool(_closedKey), isFalse);
    },
  );

  test(
    'a real async storage initialization write failure skips prompting',
    () async {
      final preferences = _ControlledPreferences({})..failWrites = true;
      SharedPreferencesAsyncPlatform.instance = preferences;
      final owner = createOwner();
      expect(await owner.init(), isFalse);
      expect(owner.initialized, isFalse);
      expect(owner.claimPrompt(canPresent: true), isFalse);
    },
  );
}
