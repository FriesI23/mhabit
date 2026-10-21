// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/habit_widget.dart';

abstract interface class HabitWidgetPublisher {
  Future<Map<String, String>> readStrings();
  Future<void> publish(HabitWidgetSnapshot snapshot);
}

final class HomeWidgetPublisher implements HabitWidgetPublisher {
  static const snapshotKey = 'habit_widget_snapshot';
  static const widgetKind = 'HabitWidget';

  Future<void> _configure() async {
    final package = await PackageInfo.fromPlatform();
    await HomeWidget.setAppGroupId('group.${package.packageName}.widgets');
  }

  @override
  Future<Map<String, String>> readStrings() async {
    await _configure();
    final raw = await HomeWidget.getWidgetData<String>(snapshotKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      final strings = decoded['strings'];
      if (strings is! Map<String, dynamic>) return const {};
      return {
        for (final entry in strings.entries)
          if (entry.value is String) entry.key: entry.value as String,
      };
    } on FormatException {
      return const {};
    }
  }

  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    await _configure();
    await HomeWidget.saveWidgetData<String>(
      snapshotKey,
      jsonEncode(snapshot.toJson()),
    );
    await HomeWidget.updateWidget(iOSName: widgetKind);
  }
}
