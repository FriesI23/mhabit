// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum AppSupportNativeStage { later, never }

/// Protects and restores reminder preferences used by the manual native host.
class AppSupportNativePreferences {
  AppSupportNativePreferences(this.preferences);

  final SharedPreferencesAsync preferences;
  static const reminderKeys = {
    'appSupport_minimumDate',
    'appSupport_launches',
    'appSupport_doNotOpenAgain',
  };
  static const _stageKey = 'appSupportProbe_stage';
  static const _snapshotKey = 'appSupportProbe_snapshot';

  /// Refuses storage mutation outside the separately identified development app.
  static void requireDevelopmentInstall({
    required String? flavor,
    required String packageName,
  }) {
    if (flavor != 'f_dev' || !packageName.endsWith('.dev')) {
      throw StateError(
        'Run the support probe only in an f_dev development install',
      );
    }
  }

  Future<AppSupportNativeStage?> readStage() async {
    final value = await preferences.getString(_stageKey);
    return value == null ? null : AppSupportNativeStage.values.byName(value);
  }

  Future<void> saveStage(AppSupportNativeStage stage) =>
      preferences.setString(_stageKey, stage.name);

  /// Recovers an interrupted first run before taking a new snapshot.
  Future<void> begin() async {
    await restore();
    await preferences.setString(
      _snapshotKey,
      jsonEncode(await preferences.getAll(allowList: reminderKeys)),
    );
    await preferences.clear(allowList: reminderKeys);
  }

  /// Leaves the snapshot in place if restoring a value fails, allowing retry.
  Future<void> restore() async {
    final raw = await preferences.getString(_snapshotKey);
    if (raw != null) {
      final Map<String, dynamic> snapshot = jsonDecode(raw);
      await preferences.clear(allowList: reminderKeys);
      for (final entry in snapshot.entries) {
        if (!reminderKeys.contains(entry.key)) {
          throw StateError('Unknown probe key');
        }
        switch (entry.value) {
          case final bool value:
            await preferences.setBool(entry.key, value);
          case final int value:
            await preferences.setInt(entry.key, value);
          case final double value:
            await preferences.setDouble(entry.key, value);
          case final String value:
            await preferences.setString(entry.key, value);
          case final List<dynamic> value:
            await preferences.setStringList(entry.key, value.cast<String>());
          default:
            throw StateError('Unsupported saved preference');
        }
      }
    }
    await preferences.clear(allowList: {_stageKey, _snapshotKey});
  }
}
