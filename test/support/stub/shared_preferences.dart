// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile/profile_helper.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Installs isolated preference backends for lifecycle and failure tests.
class PreferencesTestStore {
  static SharedPreferencesStorePlatform get instance =>
      SharedPreferencesStorePlatform.instance;

  static set instance(SharedPreferencesStorePlatform? value) {
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = value!;
  }
}

class InMemoryPreferencesStore extends InMemorySharedPreferencesStore {
  InMemoryPreferencesStore.withData(Map<String, Object> values)
    : super.withData({
        for (final entry in _encodeHistory(values).entries)
          'flutter.${entry.key}': entry.value,
      });

  InMemoryPreferencesStore.empty() : super.empty();

  Future<Map<String, Object>> get saved async => _decodeHistory({
    for (final entry in (await super.getAll()).entries)
      entry.key.substring('flutter.'.length): entry.value,
  });
}

extension SharedPreferencesSnapshot on SharedPreferences {
  Map<String, Object?> getAll({Set<String>? allowList}) => _decodeHistory({
    for (final key in getKeys())
      if (allowList == null || allowList.contains(key)) key: get(key)!,
  });

  int? reminderInt(String key) => getAll()[key] as int?;
  bool? reminderBool(String key) => getAll()[key] as bool?;
}

// Keep eligibility fixtures readable while persisting through the real codec.
Map<String, Object> _encodeHistory(Map<String, Object> values) {
  final history = {
    'minimumDate': values['appSupport_minimumDate'],
    'launches': values['appSupport_launches'],
    'closed': values['appSupport_doNotOpenAgain'],
  };
  return {
    for (final entry in values.entries)
      if (!entry.key.startsWith('appSupport_')) entry.key: entry.value,
    if (history.values.any((value) => value != null))
      'appSupportReminder': jsonEncode({
        'minimumDate': history['minimumDate'] ?? 0,
        'launches': history['launches'] ?? 0,
        'closed': history['closed'] ?? false,
      }),
  };
}

Map<String, Object> _decodeHistory(Map<String, Object> values) {
  final raw = values['appSupportReminder'] as String?;
  final Map<String, dynamic>? history = raw == null ? null : jsonDecode(raw);
  return {
    for (final entry in values.entries)
      if (entry.key != 'appSupportReminder') entry.key: entry.value,
    if (history != null) ...{
      'appSupport_minimumDate': history['minimumDate'] as int,
      'appSupport_launches': history['launches'] as int,
      'appSupport_doNotOpenAgain': history['closed'] as bool,
    },
  };
}

AppSupportOwner createTestAppSupportOwner({
  Future<SharedPreferences> Function()? loadPreferences,
  DateTime Function()? now,
  Future<AboutInfo> Function()? loadInfo,
}) => AppSupportOwner(
  profile: _SupportProfile(loadPreferences ?? SharedPreferences.getInstance),
  now: now,
  loadInfo: loadInfo,
);

class _SupportProfile extends ProfileViewModel {
  _SupportProfile(this._loadPreferences) : super(const []);

  final Future<SharedPreferences> Function() _loadPreferences;
  Future<bool>? _initialization;
  AppSupportReminderProfileHandler? _handler;

  @override
  Future<bool> init() => _initialization ??= _init();

  Future<bool> _init() async {
    _handler = AppSupportReminderProfileHandler(await _loadPreferences());
    return true;
  }

  @override
  T? getHandler<T extends ProfileHelperHandler>() => _handler as T?;
}
