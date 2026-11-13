// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/stub/shared_preferences.dart';

final class _FailingPreferences extends InMemoryPreferencesStore {
  _FailingPreferences({required this.throwOnFailure}) : super.empty();

  final bool throwOnFailure;
  bool failWrites = false;
  int reads = 0;

  @override
  Future<Map<String, Object>> getAll() {
    reads++;
    return super.getAll();
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (failWrites) {
      if (throwOnFailure) throw StateError('write failed');
      return false;
    }
    return super.setValue(type, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reminder history round trips in a single profile value', () async {
    final preferences = await SharedPreferences.getInstance();
    final handler = AppSupportReminderProfileHandler(preferences);
    expect(handler.get(), isNull);
    final history = (
      minimumDate: DateTime.utc(2026, 11, 12),
      launches: -10,
      closed: true,
    );
    expect(await handler.set(history), isTrue);
    expect(preferences.getKeys(), {handler.key});
    expect(jsonDecode(preferences.getString(handler.key)!), {
      'minimumDate': history.minimumDate.millisecondsSinceEpoch,
      'launches': -10,
      'closed': true,
    });
    await preferences.reload();
    expect(handler.get(), history);
    expect(await handler.remove(), isTrue);
    expect(handler.get(), isNull);
  });

  for (final throwOnFailure in [false, true]) {
    for (final hasHistory in [false, true]) {
      test(
        'failed write preserves backend with history=$hasHistory and retries '
        'with throwOnFailure=$throwOnFailure',
        () async {
          final previousStore = PreferencesTestStore.instance;
          final store = _FailingPreferences(throwOnFailure: throwOnFailure);
          PreferencesTestStore.instance = store;
          addTearDown(() => PreferencesTestStore.instance = previousStore);
          final preferences = await SharedPreferences.getInstance();
          final handler = AppSupportReminderProfileHandler(preferences);
          final previousHistory = (
            minimumDate: DateTime.utc(2026, 11, 12),
            launches: 10,
            closed: false,
          );
          if (hasHistory) {
            expect(await handler.set(previousHistory), isTrue);
          }
          final newHistory = (
            minimumDate: DateTime.utc(2026, 11, 19),
            launches: 0,
            closed: true,
          );
          final previousBackend = await store.getAll();
          final readsBeforeFailure = store.reads;

          store.failWrites = true;
          if (throwOnFailure) {
            await expectLater(handler.set(newHistory), throwsStateError);
          } else {
            expect(await handler.set(newHistory), isFalse);
          }
          expect(handler.get(), newHistory);
          expect(store.reads, readsBeforeFailure);
          expect(await store.getAll(), previousBackend);

          store.failWrites = false;
          expect(await handler.set(newHistory), isTrue);
          await preferences.reload();
          expect(handler.get(), newHistory);
        },
      );
    }
  }

  test(
    'owner uses the registered handler alongside other profile settings',
    () async {
      final profile = ProfileViewModel([
        AppSupportReminderProfileHandler.new,
        AppLaunchEntryProfileHandler.new,
      ]);
      addTearDown(profile.dispose);
      expect(await profile.init(), isTrue);
      final owner = AppSupportOwner(
        profile: profile,
        now: () => DateTime.utc(2026, 11, 12),
      );
      addTearDown(owner.dispose);
      expect(await owner.init(), isTrue);
      final handler = profile.getHandler<AppSupportReminderProfileHandler>()!;
      expect(handler.get()!.launches, 1);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('themeType', 2);
      expect(await owner.recordSettingsSupportResult(), isTrue);
      await preferences.setString('windowState', 'updated');
      await profile.reload();
      expect(
        profile.getHandler<AppSupportReminderProfileHandler>()!.get()!.closed,
        isTrue,
      );
      expect(preferences.getInt('themeType'), 2);
      expect(preferences.getString('windowState'), 'updated');
    },
  );

  test('missing registered handler disables the automatic reminder', () async {
    final profile = ProfileViewModel(const []);
    addTearDown(profile.dispose);
    final owner = AppSupportOwner(profile: profile);
    addTearDown(owner.dispose);
    expect(await owner.init(), isFalse);
    expect(owner.initializationComplete, isTrue);
    expect(owner.checkReminderEligibility(canShowDialog: true), isFalse);
  });
}
