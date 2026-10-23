// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../entries/habit_widget/habit_widget_api.g.dart';
import '../models/habit_widget.dart';

/// Reads the app locale and publishes shared display snapshots.
abstract interface class HabitWidgetPublisher {
  /// Reads the latest app locale from the shared snapshot.
  Future<String?> readLocale();

  /// Saves [snapshot] and acknowledges its native reconciliation request.
  Future<void> publish(HabitWidgetSnapshot snapshot);
}

/// Publishes snapshots through the platform App Group storage bridge.
final class HomeWidgetPublisher implements HabitWidgetPublisher {
  /// Storage key shared with the native snapshot reader.
  static const snapshotKey = 'habit_widget_snapshot';

  /// Selects the current flavor's shared container before accessing it.
  Future<void> _configure() async {
    final package = await PackageInfo.fromPlatform();
    if (await HomeWidget.setAppGroupId(
          'group.${package.packageName}.widgets',
        ) !=
        true) {
      throw StateError('Could not configure widget shared storage');
    }
  }

  @override
  Future<String?> readLocale() async {
    await _configure();
    final raw = await HomeWidget.getWidgetData<String>(snapshotKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['locale'] case final String locale) return locale;
      return null;
    } on FormatException {
      return null;
    }
  }

  /// Saves before enqueueing reconciliation; the native queue owns reloading.
  ///
  /// ```text
  /// save snapshot -> enqueue publication -> acknowledge Dart
  ///                        |
  ///                        v
  ///                 reconcile -> reload
  /// ```
  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    await _configure();
    if (await HomeWidget.saveWidgetData<String>(
          snapshotKey,
          jsonEncode(snapshot.toJson()),
        ) !=
        true) {
      throw StateError('Could not publish widget snapshot');
    }
    // Both foreground and background publications enter the same native queue.
    // The host acknowledges enqueueing, not completion, to avoid a deadlock
    // while the background action itself is waiting to publish its snapshot.
    await HabitWidgetDisplayHostApi().published();
    // Runner reloads after this queued publication and any current action's
    // applied response/hold. A direct reload here could publish a completion
    // before its shared hold exists in the app process.
  }
}
