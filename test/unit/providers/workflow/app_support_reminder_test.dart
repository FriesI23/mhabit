// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/stub/shared_preferences.dart';

final _today = DateTime.utc(2026, 11, 12);
const _dateKey = 'appSupport_minimumDate';
const _launchesKey = 'appSupport_launches';
const _closedKey = 'appSupport_doNotOpenAgain';

final class _ControlledPreferences extends InMemoryPreferencesStore {
  _ControlledPreferences(super.values) : super.withData();

  bool failWrites = false;
  bool failBooleanWrites = false;
  bool returnFalseOnWrite = false;
  bool persistBeforeWaiting = false;
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
  Future<bool> setValue(String type, String key, Object value) async {
    if (persistBeforeWaiting) {
      final saved = await super.setValue(type, key, value);
      await _beforeWrite();
      return saved;
    }
    await _beforeWrite();
    if (returnFalseOnWrite) return false;
    if (key == 'flutter.appSupportReminder' && failBooleanWrites) {
      throw StateError('boolean write failed');
    }
    return super.setValue(type, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final previous = PreferencesTestStore.instance;
    PreferencesTestStore.instance = InMemoryPreferencesStore.withData({
      _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
      _launchesKey: 9,
      _closedKey: false,
      'unrelated': 'keep',
    });
    addTearDown(() => PreferencesTestStore.instance = previous);
  });

  AppSupportOwner createOwner({DateTime Function()? now}) {
    final owner = createTestAppSupportOwner(now: now ?? () => _today);
    addTearDown(owner.dispose);
    return owner;
  }

  test(
    'profile and reminder writes preserve each other across reload',
    () async {
      final profile = await SharedPreferences.getInstance();
      final owner = createOwner();
      expect(await owner.init(), isTrue);
      await profile.setInt('themeType', 2);
      expect(await owner.recordSettingsSupportResult(), isTrue);
      await profile.setString('windowState', 'updated');
      await profile.reload();
      expect(profile.getInt('themeType'), 2);
      expect(profile.getString('windowState'), 'updated');
      expect(profile.reminderBool(_closedKey), isTrue);
      expect(profile.getString('unrelated'), 'keep');
    },
  );

  for (final result in [
    AppSupportResult.githubOpened,
    AppSupportResult.storeOpened,
  ]) {
    test('Settings $result uses fresh history after reset configs', () async {
      final profile = ProfileViewModel([AppSupportReminderProfileHandler.new]);
      addTearDown(profile.dispose);
      final owner = AppSupportOwner(profile: profile, now: () => _today);
      addTearDown(owner.dispose);
      final initialization = owner.init();
      expect(await initialization, isTrue);
      expect(await owner.recordSettingsSupportResult(), isTrue);
      expect(owner.reminderClosed, isTrue);

      // Reset configs clears preferences and replaces the profile handlers.
      expect(await profile.clear(), isTrue);
      await profile.reload();
      owner.updateProfile(profile);
      expect(identical(owner.init(), initialization), isTrue);
      expect(owner.reminderClosed, isFalse);
      expect(owner.checkReminderEligibility(canShowDialog: true), isFalse);
      final handler = profile.getHandler<AppSupportReminderProfileHandler>()!;
      expect(handler.get(), isNull);

      expect(await owner.recordSettingsSupportResult(result), isTrue);
      expect(handler.get(), (
        minimumDate: _today.add(const Duration(days: 7)),
        launches: result == AppSupportResult.storeOpened ? -10 : 0,
        closed: result == AppSupportResult.githubOpened,
      ));
    });
  }

  test(
    'deleted history is read immediately without profile rebinding',
    () async {
      final profile = ProfileViewModel([AppSupportReminderProfileHandler.new]);
      addTearDown(profile.dispose);
      final owner = AppSupportOwner(profile: profile, now: () => _today);
      addTearDown(owner.dispose);
      expect(await owner.init(), isTrue);
      expect(await owner.recordSettingsSupportResult(), isTrue);
      expect(owner.reminderClosed, isTrue);

      expect(await profile.clear(), isTrue);
      expect(owner.reminderClosed, isFalse);
      expect(
        await owner.recordSettingsSupportResult(AppSupportResult.storeOpened),
        isTrue,
      );
      expect(profile.getHandler<AppSupportReminderProfileHandler>()!.get(), (
        minimumDate: _today.add(const Duration(days: 7)),
        launches: -10,
        closed: false,
      ));
    },
  );

  test(
    'first install creates only the existing reminder keys and waits seven days',
    () async {
      PreferencesTestStore.instance = InMemoryPreferencesStore.empty();
      final owner = createOwner();
      expect(await owner.init(), isTrue);
      expect(owner.checkReminderEligibility(canShowDialog: true), isFalse);
      expect((await SharedPreferences.getInstance()).getAll(), {
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
        PreferencesTestStore.instance = InMemoryPreferencesStore.withData({
          _dateKey: date.millisecondsSinceEpoch,
          _launchesKey: launches,
          _closedKey: closed,
          'unrelated': 'keep',
        });
        final owner = createOwner();
        expect(await owner.init(), isTrue);
        expect(owner.checkReminderEligibility(canShowDialog: true), eligible);
        expect((await SharedPreferences.getInstance()).getAll(), {
          _dateKey: date.millisecondsSinceEpoch,
          _launchesKey: launches + 1,
          _closedKey: closed,
          'unrelated': 'keep',
        });
      },
    );
  }

  for (final result in [
    AppSupportResult.remindLater,
    AppSupportResult.storeOpened,
  ]) {
    test(
      '$result preserves legacy seven-day and ten-launch cooldown across owners',
      () async {
        final owner = createOwner();
        await owner.init();
        expect(await owner.recordReminderResult(result), isTrue);
        expect(owner.reminderClosed, isFalse);
        expect((await SharedPreferences.getInstance()).getAll(), {
          _dateKey: _today.add(const Duration(days: 7)).millisecondsSinceEpoch,
          _launchesKey: 0,
          _closedKey: false,
          'unrelated': 'keep',
        });
        final next = createOwner(
          now: () => _today.add(const Duration(days: 8)),
        );
        await next.init();
        expect(next.checkReminderEligibility(canShowDialog: true), isFalse);
        expect(
          (await SharedPreferences.getInstance()).reminderInt(_launchesKey),
          1,
        );
      },
    );
  }

  for (final result in [
    AppSupportResult.githubOpened,
    AppSupportResult.stopReminding,
  ]) {
    test('$result preserves permanent dismissal across owners', () async {
      final owner = createOwner();
      await owner.init();
      expect(await owner.recordReminderResult(result), isTrue);
      expect(owner.reminderClosed, isTrue);
      final next = createOwner();
      await next.init();
      expect(next.reminderClosed, isTrue);
      expect(next.checkReminderEligibility(canShowDialog: true), isFalse);
      expect(
        (await SharedPreferences.getInstance()).getString('unrelated'),
        'keep',
      );
    });
  }

  test(
    'store links retain an existing permanent dismissal while saving cooldown',
    () async {
      PreferencesTestStore.instance = InMemoryPreferencesStore.withData({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: -20,
        _closedKey: true,
      });
      final owner = createOwner();
      await owner.init();
      expect(
        await owner.recordSettingsSupportResult(AppSupportResult.storeOpened),
        isTrue,
      );
      expect(owner.reminderClosed, isTrue);
      expect((await SharedPreferences.getInstance()).getAll(), {
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
      expect(
        await owner.recordReminderResult(AppSupportResult.remindLater),
        isTrue,
      );
      expect(await owner.recordSettingsSupportResult(), isTrue);
      expect(owner.reminderClosed, isTrue);
      expect(
        (await SharedPreferences.getInstance()).reminderInt(_launchesKey),
        0,
      );
    },
  );

  test(
    'other actions, failures and cancellation allow a later reminder save',
    () async {
      final owner = createOwner();
      await owner.init();
      final before = (await SharedPreferences.getInstance()).getAll();
      for (final result in [
        AppSupportResult.otherActionCompleted,
        AppSupportResult.actionFailed,
        AppSupportResult.cancelled,
      ]) {
        expect(await owner.recordReminderResult(result), isFalse);
      }
      expect((await SharedPreferences.getInstance()).getAll(), before);
      expect(
        await owner.recordReminderResult(AppSupportResult.remindLater),
        isTrue,
      );
      expect(
        await owner.recordReminderResult(AppSupportResult.stopReminding),
        isFalse,
      );
    },
  );

  test('failed automatic persistence does not retry another result', () async {
    final preferences = _ControlledPreferences({
      _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
      _launchesKey: 9,
      _closedKey: false,
    });
    PreferencesTestStore.instance = preferences;
    final owner = createOwner();
    await owner.init();
    preferences.failWrites = true;
    expect(
      await owner.recordReminderResult(AppSupportResult.remindLater),
      isFalse,
    );
    preferences.failWrites = false;
    expect(
      await owner.recordReminderResult(AppSupportResult.stopReminding),
      isFalse,
    );
    expect(owner.reminderClosed, isFalse);
    expect((await preferences.saved)[_launchesKey], 10);
  });

  test(
    'failed Settings persistence reports failure and retries the write',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      PreferencesTestStore.instance = preferences;
      final owner = createOwner();
      await owner.init();
      var notifications = 0;
      owner.addListener(() => notifications++);
      preferences.failBooleanWrites = true;
      expect(await owner.recordSettingsSupportResult(), isFalse);
      expect(owner.reminderClosed, isTrue);
      expect((await preferences.saved)[_closedKey], isFalse);
      expect(notifications, 0);
      preferences.failBooleanWrites = false;
      expect(await owner.recordSettingsSupportResult(), isTrue);
      expect(owner.reminderClosed, isTrue);
      expect((await preferences.saved)[_closedKey], isTrue);
      expect(notifications, 1);
    },
  );

  for (final throwOnFailure in [false, true]) {
    test(
      'reset history retries a failed save and restores after cache recreation '
      'with throwOnFailure=$throwOnFailure',
      () async {
        final preferences = _ControlledPreferences({
          _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
          _launchesKey: 9,
          _closedKey: false,
        });
        PreferencesTestStore.instance = preferences;
        final profile = ProfileViewModel([
          AppSupportReminderProfileHandler.new,
        ]);
        addTearDown(() {
          if (profile.mounted) profile.dispose();
        });
        final owner = AppSupportOwner(profile: profile, now: () => _today);
        addTearDown(owner.dispose);
        expect(await owner.init(), isTrue);
        expect(await owner.recordSettingsSupportResult(), isTrue);
        expect(owner.reminderClosed, isTrue);

        expect(await profile.clear(), isTrue);
        await profile.reload();
        owner.updateProfile(profile);
        expect(owner.reminderClosed, isFalse);
        var notifications = 0;
        owner.addListener(() => notifications++);

        preferences
          ..failWrites = throwOnFailure
          ..returnFalseOnWrite = !throwOnFailure;
        expect(await owner.recordSettingsSupportResult(), isFalse);
        expect(owner.reminderClosed, isTrue);
        expect(await preferences.saved, isEmpty);
        expect(notifications, 0);

        preferences
          ..failWrites = false
          ..returnFalseOnWrite = false;
        expect(await owner.recordSettingsSupportResult(), isTrue);
        expect((await preferences.saved)[_closedKey], isTrue);
        expect(notifications, 1);

        final previousPreferences = await SharedPreferences.getInstance();
        owner.dispose();
        profile.dispose();
        // Preserve the platform backend while discarding the process-local cache.
        SharedPreferences.resetStatic();
        expect(
          identical(await SharedPreferences.getInstance(), previousPreferences),
          isFalse,
        );
        final restoredProfile = ProfileViewModel([
          AppSupportReminderProfileHandler.new,
        ]);
        addTearDown(restoredProfile.dispose);
        final restoredOwner = AppSupportOwner(
          profile: restoredProfile,
          now: () => _today.add(const Duration(days: 8)),
        );
        addTearDown(restoredOwner.dispose);
        expect(await restoredOwner.init(), isTrue);
        expect(restoredOwner.reminderClosed, isTrue);
        expect(
          restoredProfile.getHandler<AppSupportReminderProfileHandler>()!.get(),
          (
            minimumDate: _today.add(const Duration(days: 7)),
            launches: 1,
            closed: true,
          ),
        );
        expect(
          restoredOwner.checkReminderEligibility(canShowDialog: true),
          isFalse,
        );
      },
    );
  }

  test(
    'explicit store saves serialize and keep the legacy negative counter',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      PreferencesTestStore.instance = preferences;
      final owner = createOwner();
      await owner.init();
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      final first = owner.recordSettingsSupportResult(
        AppSupportResult.storeOpened,
      );
      await preferences.writeStarted!.future;
      final second = owner.recordSettingsSupportResult(
        AppSupportResult.storeOpened,
      );
      preferences.pendingWrite!.complete();
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(
        (await SharedPreferences.getInstance()).reminderInt(_launchesKey),
        -10,
      );
      expect(owner.reminderClosed, isFalse);
    },
  );

  test(
    'profile reload rejects a late save completion without publishing old state',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      PreferencesTestStore.instance = preferences;
      final profile = ProfileViewModel([AppSupportReminderProfileHandler.new]);
      addTearDown(profile.dispose);
      final owner = AppSupportOwner(profile: profile, now: () => _today);
      addTearDown(owner.dispose);
      expect(await owner.init(), isTrue);
      preferences
        ..persistBeforeWaiting = true
        ..pendingWrite = Completer<void>()
        ..writeStarted = Completer<void>();
      var notifications = 0;
      owner.addListener(() => notifications++);

      final save = owner.recordSettingsSupportResult();
      await preferences.writeStarted!.future;
      // The write has reached storage, but its completion is still pending.
      expect((await preferences.saved)[_closedKey], isTrue);
      expect(await profile.clear(), isTrue);
      await profile.reload();
      owner.updateProfile(profile);
      expect(owner.reminderClosed, isFalse);

      preferences.pendingWrite!.complete();
      expect(await save, isFalse);
      expect(owner.reminderClosed, isFalse);
      expect(notifications, 0);
      expect(await preferences.saved, isEmpty);
    },
  );

  test(
    'profile reload rejects writes queued against the previous handler',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      PreferencesTestStore.instance = preferences;
      final profile = ProfileViewModel([AppSupportReminderProfileHandler.new]);
      addTearDown(profile.dispose);
      final owner = AppSupportOwner(profile: profile, now: () => _today);
      addTearDown(owner.dispose);
      expect(await owner.init(), isTrue);
      preferences
        ..persistBeforeWaiting = true
        ..pendingWrite = Completer<void>()
        ..writeStarted = Completer<void>();

      final inFlight = owner.recordSettingsSupportResult(
        AppSupportResult.storeOpened,
      );
      await preferences.writeStarted!.future;
      final queued = owner.recordSettingsSupportResult();
      expect(await profile.clear(), isTrue);
      await profile.reload();
      owner.updateProfile(profile);

      preferences.pendingWrite!.complete();
      expect(await inFlight, isFalse);
      expect(await queued, isFalse);
      expect(owner.reminderClosed, isFalse);
      expect(await preferences.saved, isEmpty);
    },
  );

  test(
    'disposal during an in-flight history save prevents publication',
    () async {
      final preferences = _ControlledPreferences({
        _dateKey: DateTime.utc(2000).millisecondsSinceEpoch,
        _launchesKey: 9,
        _closedKey: false,
      });
      PreferencesTestStore.instance = preferences;
      final owner = createOwner();
      await owner.init();
      preferences.pendingWrite = Completer<void>();
      preferences.writeStarted = Completer<void>();
      var notifications = 0;
      owner.addListener(() => notifications++);
      final save = owner.recordSettingsSupportResult();
      await preferences.writeStarted!.future;
      owner.dispose();
      preferences.pendingWrite!.complete();
      expect(await save, isFalse);
      expect(owner.reminderClosed, isFalse);
      expect(notifications, 0);
      expect((await preferences.saved)[_closedKey], isTrue);
    },
  );

  test('a storage initialization write failure skips prompting', () async {
    final preferences = _ControlledPreferences({})..failWrites = true;
    PreferencesTestStore.instance = preferences;
    final owner = createOwner();
    expect(await owner.init(), isFalse);
    expect(owner.inited, isFalse);
    expect(owner.checkReminderEligibility(canShowDialog: true), isFalse);
  });
}
