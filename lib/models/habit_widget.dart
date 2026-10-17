// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../storage/db/handlers/record.dart';
import '../storage/db/handlers/sync.dart';
import 'habit_date.dart';

enum HabitWidgetAction { complete, undo }

enum HabitWidgetActionResult { applied, unchanged, stale, invalid }

/// The date and revision belong to the displayed row, not the time of the tap.
final class HabitWidgetCommand {
  final HabitWidgetAction action;
  final String habitId;
  final HabitDate day;
  final String expectedRecord;

  const HabitWidgetCommand({
    required this.action,
    required this.habitId,
    required this.day,
    required this.expectedRecord,
  });

  static HabitWidgetCommand? tryParse(Uri uri) {
    if (uri.scheme != 'tablehabit-widget' ||
        uri.path.isNotEmpty ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return null;
    }
    final action = switch (uri.host) {
      'complete' => HabitWidgetAction.complete,
      'undo' => HabitWidgetAction.undo,
      _ => null,
    };
    final query = uri.queryParametersAll;
    if (query.length != 3 || query.values.any((values) => values.length != 1)) {
      return null;
    }
    final id = uri.queryParameters['habitId'];
    final dateText = uri.queryParameters['day'];
    final revision = uri.queryParameters['expectedRecord'];
    if (action == null ||
        id == null ||
        id.isEmpty ||
        id.length > 256 ||
        revision == null ||
        revision.isEmpty ||
        revision.length > 2048 ||
        dateText == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateText)) {
      return null;
    }
    final parsed = DateTime.tryParse(dateText);
    if (parsed == null) return null;
    final day = HabitDate.dateTime(parsed);
    if (_habitWidgetDay(day) != dateText) return null;
    return HabitWidgetCommand(
      action: action,
      habitId: id,
      day: day,
      expectedRecord: revision,
    );
  }

  Uri toUri() => Uri(
    scheme: 'tablehabit-widget',
    host: action.name,
    queryParameters: {
      'habitId': habitId,
      'day': _habitWidgetDay(day),
      'expectedRecord': expectedRecord,
    },
  );
}

String _habitWidgetDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Opaque compare-and-set token. Include the reason so undo never silently
/// deletes a note added in the app after the widget was rendered.
/// Dirty count and sync session markers distinguish edits within the same
/// second even when an undo/redo restores exactly the previous record values.
String habitWidgetRecordRevision(
  RecordDBCell? record, {
  required SyncDBCell? sync,
}) => record == null
    ? 'none'
    : sha256
          .convert(
            utf8.encode(
              jsonEncode([
                record.uuid,
                record.recordType,
                record.recordValue?.toDouble(),
                record.deleted,
                record.modifyT,
                record.reason,
                sync?.id,
                sync?.dirty,
                sync?.lastSesionUUID,
                sync?.lastConfigUUID,
                sync?.lastMark,
              ]),
            ),
          )
          .toString();

final class HabitWidgetDayProgress {
  final HabitDate date;
  final double progress;

  const HabitWidgetDayProgress(this.date, this.progress);

  Map<String, Object?> toJson() => {
    'date': _habitWidgetDay(date),
    'progress': progress,
  };
}

final class HabitWidgetHabit {
  final String id;
  final String name;
  final int color;
  final bool completed;
  final double progress;
  final bool canComplete;
  final bool canUndo;
  final String expectedRecord;
  final List<HabitWidgetDayProgress> sevenDays;

  const HabitWidgetHabit({
    required this.id,
    required this.name,
    required this.color,
    required this.completed,
    required this.progress,
    required this.canComplete,
    required this.canUndo,
    required this.expectedRecord,
    required this.sevenDays,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'completed': completed,
    'progress': progress,
    'canComplete': canComplete,
    'canUndo': canUndo,
    'expectedRecord': expectedRecord,
    'sevenDays': sevenDays.map((day) => day.toJson()).toList(),
  };
}

final class HabitWidgetSnapshot {
  final DateTime generatedAt;
  final HabitDate day;
  final DateTime nextDayAt;
  final List<HabitWidgetHabit> habits;
  final Map<String, String> strings;

  const HabitWidgetSnapshot({
    required this.generatedAt,
    required this.day,
    required this.nextDayAt,
    required this.habits,
    this.strings = const {},
  });

  Map<String, Object?> toJson() => {
    'version': 1,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'day': _habitWidgetDay(day),
    'nextDayAt': nextDayAt.toUtc().toIso8601String(),
    'habits': habits.map((habit) => habit.toJson()).toList(),
    'strings': strings,
  };
}
