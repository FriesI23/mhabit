// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/stub/shared_preferences.dart';
import 'native_preferences.dart';

final class _Preferences extends InMemoryPreferencesStore {
  _Preferences(super.data) : super.withData();
  String? failNextSet;
  String? failNextRemove;
  bool throwOnFailure = false;

  bool _fail() {
    if (throwOnFailure) throw StateError('interrupted preference update');
    return false;
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key == failNextSet) {
      failNextSet = null;
      return _fail();
    }
    return super.setValue(type, key, value);
  }

  @override
  Future<bool> remove(String key) async {
    if (key == failNextRemove) {
      failNextRemove = null;
      return _fail();
    }
    return super.remove(key);
  }
}

void main() {
  const original = <String, Object>{
    'appSupport_minimumDate': 0,
    'appSupport_launches': 42,
    'appSupport_doNotOpenAgain': true,
    'unrelated': 'keep',
  };
  late _Preferences backend;
  late SharedPreferences preferences;
  late AppSupportNativePreferences fixture;
  setUp(() async {
    final previous = PreferencesTestStore.instance;
    addTearDown(() => PreferencesTestStore.instance = previous);
    backend = _Preferences(original);
    PreferencesTestStore.instance = backend;
    preferences = (await SharedPreferences.getInstance());
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
      expect(
        AppSupportReminderProfileHandler(preferences).get()?.launches,
        isNull,
      );
      await AppSupportReminderProfileHandler(
        preferences,
      ).set((minimumDate: DateTime.utc(1970), launches: 10, closed: false));
      await fixture.saveStage(AppSupportNativeStage.later);
      final nextProcess = AppSupportNativePreferences(
        (await SharedPreferences.getInstance()),
      );
      expect(await nextProcess.readStage(), AppSupportNativeStage.later);
      await nextProcess.saveStage(AppSupportNativeStage.never);
      await nextProcess.restore();
      expect(preferences.getAll(), original);
    },
  );

  test(
    'interrupted first run cannot overwrite the original snapshot',
    () async {
      await fixture.begin();
      await AppSupportReminderProfileHandler(
        preferences,
      ).set((minimumDate: DateTime.utc(1970), launches: 99, closed: false));
      expect(await fixture.readStage(), isNull);
      await fixture.begin();
      await fixture.restore();
      expect(preferences.getAll(), original);
    },
  );

  for (final failure in ['false', 'exception']) {
    test('snapshot write $failure preserves original preferences', () async {
      backend
        ..failNextSet = 'flutter.appSupportProbe_snapshot'
        ..throwOnFailure = failure == 'exception';
      await expectLater(fixture.begin(), throwsStateError);
      expect(await backend.saved, original);
      await fixture.restore();
      expect(await backend.saved, original);
    });

    test('initial removal $failure retains the recovery snapshot', () async {
      backend
        ..failNextRemove = 'flutter.appSupportReminder'
        ..throwOnFailure = failure == 'exception';
      await expectLater(fixture.begin(), throwsStateError);
      expect(
        await backend.saved,
        containsPair('appSupportProbe_snapshot', isA<String>()),
      );
      await fixture.restore();
      expect(await backend.saved, original);
    });

    test('stage write $failure cannot publish cached progress', () async {
      await fixture.begin();
      backend
        ..failNextSet = 'flutter.appSupportProbe_stage'
        ..throwOnFailure = failure == 'exception';
      await expectLater(
        fixture.saveStage(AppSupportNativeStage.later),
        throwsStateError,
      );
      expect(await fixture.readStage(), isNull);
      await fixture.restore();
      expect(await backend.saved, original);
    });

    for (final (operation, key) in [
      ('remove', 'flutter.appSupportReminder'),
      ('set', 'flutter.appSupportReminder'),
      ('remove', 'flutter.appSupportProbe_stage'),
      ('remove', 'flutter.appSupportProbe_snapshot'),
    ]) {
      test('restore $operation $key $failure remains recoverable', () async {
        await fixture.begin();
        await AppSupportReminderProfileHandler(
          preferences,
        ).set((minimumDate: DateTime.utc(1970), launches: 99, closed: false));
        await fixture.saveStage(AppSupportNativeStage.later);
        backend.throwOnFailure = failure == 'exception';
        if (operation == 'set') {
          backend.failNextSet = key;
        } else {
          backend.failNextRemove = key;
        }
        await expectLater(fixture.restore(), throwsStateError);
        expect(
          await backend.saved,
          containsPair('appSupportProbe_snapshot', isA<String>()),
        );
        // Retry with the same SharedPreferences cache after the failed update.
        await fixture.restore();
        expect(await backend.saved, original);
      });
    }

    test('restart recovers a pending snapshot after write $failure', () async {
      await fixture.begin();
      backend
        ..failNextSet = 'flutter.appSupportReminder'
        ..throwOnFailure = failure == 'exception';
      await expectLater(fixture.restore(), throwsStateError);
      SharedPreferences.resetStatic();
      final restarted = AppSupportNativePreferences(
        await SharedPreferences.getInstance(),
      );
      await restarted.restore();
      expect(await backend.saved, original);
    });
  }
}
