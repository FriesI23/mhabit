// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
