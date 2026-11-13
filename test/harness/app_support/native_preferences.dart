// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum AppSupportNativeStage { later, never }

/// Protects and restores reminder preferences used by the manual native host.
class AppSupportNativePreferences {
  AppSupportNativePreferences(this.preferences);

  final SharedPreferences preferences;
  static const reminderKeys = {'appSupportReminder'};
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
    await preferences.reload();
    final value = preferences.getString(_stageKey);
    return value == null ? null : AppSupportNativeStage.values.byName(value);
  }

  /// Saves progress, throwing if the stage could not be persisted.
  Future<void> saveStage(AppSupportNativeStage stage) =>
      _requireSaved(_stageKey, preferences.setString(_stageKey, stage.name));

  Future<void> _requireSaved(String key, Future<bool> operation) async {
    if (!await operation) {
      throw StateError('Could not persist probe preference "$key"');
    }
  }

  /// Recovers an interrupted first run before taking a new snapshot.
  Future<void> begin() async {
    await restore();
    await _requireSaved(
      _snapshotKey,
      preferences.setString(
        _snapshotKey,
        jsonEncode({
          for (final key in reminderKeys)
            if (preferences.containsKey(key)) key: preferences.get(key),
        }),
      ),
    );
    for (final key in reminderKeys) {
      await _requireSaved(key, preferences.remove(key));
    }
  }

  /// Leaves the snapshot in place if restoring a value fails, allowing retry.
  Future<void> restore() async {
    // Failed writes and removals already changed the Dart cache. A retry must
    // read the persisted snapshot before attempting recovery again.
    await preferences.reload();
    final raw = preferences.getString(_snapshotKey);
    if (raw != null) {
      final Map<String, dynamic> snapshot = jsonDecode(raw);
      for (final key in reminderKeys) {
        await _requireSaved(key, preferences.remove(key));
      }
      for (final entry in snapshot.entries) {
        if (!reminderKeys.contains(entry.key)) {
          throw StateError('Unknown probe key');
        }
        final saved = switch (entry.value) {
          final bool value => preferences.setBool(entry.key, value),
          final int value => preferences.setInt(entry.key, value),
          final double value => preferences.setDouble(entry.key, value),
          final String value => preferences.setString(entry.key, value),
          final List<dynamic> value => preferences.setStringList(
            entry.key,
            value.cast<String>(),
          ),
          _ => throw StateError('Unsupported saved preference'),
        };
        await _requireSaved(entry.key, saved);
      }
    }
    await _requireSaved(_stageKey, preferences.remove(_stageKey));
    await _requireSaved(_snapshotKey, preferences.remove(_snapshotKey));
  }
}
