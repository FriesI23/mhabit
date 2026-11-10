// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'native_preferences.dart';

final class _Preferences extends InMemorySharedPreferencesAsync {
  _Preferences(super.data) : super.withData();
  bool failNextInt = false;

  @override
  Future<bool> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    if (failNextInt) {
      failNextInt = false;
      throw StateError('interrupted restore');
    }
    return super.setInt(key, value, options);
  }
}

void main() {
  const original = <String, Object>{
    'appSupport_launches': 42,
    'appSupport_doNotOpenAgain': true,
    'unrelated': 'keep',
  };
  late _Preferences backend;
  late SharedPreferencesAsync preferences;
  late AppSupportNativePreferences fixture;
  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
    backend = _Preferences(original);
    SharedPreferencesAsyncPlatform.instance = backend;
    preferences = SharedPreferencesAsync();
    fixture = AppSupportNativePreferences(preferences);
  });

  test('requires both development flavor and package identity', () {
    for (final pair in [
      (null, 'app.dev'),
      ('f_generic', 'app.dev'),
      ('f_dev', 'app'),
    ]) {
      expect(
        () => AppSupportNativePreferences.requireDevelopmentInstall(
          flavor: pair.$1,
          packageName: pair.$2,
        ),
        throwsStateError,
      );
    }
    AppSupportNativePreferences.requireDevelopmentInstall(
      flavor: 'f_dev',
      packageName: 'app.dev',
    );
  });

  test(
    'three-run fixture restores original values and removes its metadata',
    () async {
      await fixture.begin();
      expect(await preferences.getInt('appSupport_launches'), isNull);
      await preferences.setInt('appSupport_launches', 10);
      await fixture.saveStage(AppSupportNativeStage.later);
      final nextProcess = AppSupportNativePreferences(SharedPreferencesAsync());
      expect(await nextProcess.readStage(), AppSupportNativeStage.later);
      await nextProcess.saveStage(AppSupportNativeStage.never);
      await nextProcess.restore();
      expect(await preferences.getAll(), original);
    },
  );

  test(
    'interrupted first run cannot overwrite the original snapshot',
    () async {
      await fixture.begin();
      await preferences.setInt('appSupport_launches', 99);
      expect(await fixture.readStage(), isNull);
      await fixture.begin();
      await fixture.restore();
      expect(await preferences.getAll(), original);
    },
  );

  test('failed restoration retains a recoverable original snapshot', () async {
    await fixture.begin();
    backend.failNextInt = true;
    await expectLater(fixture.restore(), throwsStateError);
    await fixture.restore();
    expect(await preferences.getAll(), original);
  });
}
