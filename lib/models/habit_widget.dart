// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../storage/db/handlers/record.dart';
import '../storage/db/handlers/sync.dart';
import 'habit_date.dart';

/// Record operations accepted by the widget workflow.
enum HabitWidgetAction {
  complete('complete'),
  undo('undo'),
  markIncomplete('mark-incomplete');

  /// The stable URI host, independent of Dart and transport enum names.
  final String uriHost;

  const HabitWidgetAction(this.uriHost);

  /// Resolves only defined hosts; URI host normalization cannot encode camelCase.
  static HabitWidgetAction? fromUriHost(String host) {
    for (final action in values) {
      if (action.uriHost == host) return action;
    }
    return null;
  }
}

/// The persistence outcome of a validated widget operation.
enum HabitWidgetActionResult { applied, unchanged, stale, invalid, failed }

/// The selection mode that produced the displayed entity.
enum HabitWidgetSource { automatic, fixed }

/// Describes a completed operation and its independent publication result.
///
/// Only [HabitWidgetActionResult.applied] includes a committed version and time.
final class HabitWidgetActionResponse {
  /// The persistence outcome of the operation.
  final HabitWidgetActionResult outcome;

  /// The committed compare-and-set version, present only for an applied result.
  final String? recordVersion;

  /// The UTC acknowledgement time, sampled after the transaction committed.
  final DateTime? committedAt;

  /// Whether publishing the resulting display snapshot succeeded.
  final bool snapshotPublished;

  const HabitWidgetActionResponse._(
    this.outcome,
    this.recordVersion,
    this.committedAt,
    this.snapshotPublished,
  );

  /// Creates a response without a record commit.
  ///
  /// Throws [ArgumentError] when [outcome] requires committed metadata.
  factory HabitWidgetActionResponse.result(
    HabitWidgetActionResult outcome, {
    bool snapshotPublished = false,
  }) {
    if (outcome == HabitWidgetActionResult.applied) {
      throw ArgumentError('Applied requires a committed version and timestamp');
    }
    return HabitWidgetActionResponse._(outcome, null, null, snapshotPublished);
  }

  /// Creates an applied response with committed metadata.
  HabitWidgetActionResponse.applied({
    required String recordVersion,
    required DateTime committedAt,
    required bool snapshotPublished,
  }) : this._(
         HabitWidgetActionResult.applied,
         recordVersion,
         committedAt.toUtc(),
         snapshotPublished,
       );
}

/// Supported lifecycle states exposed by the shared display projection.
enum HabitWidgetHabitState { active, archived, unknown }

/// Today's record result, independent of progress and action capabilities.
enum HabitWidgetRecordState {
  unknown,
  unrecorded,
  notAchieved,
  achieved,
  skipped,
}

/// An operation bound to the entity, date, and version that were displayed.
final class HabitWidgetCommand {
  /// The requested record operation.
  final HabitWidgetAction action;

  /// How the entity was selected in the originating configuration.
  final HabitWidgetSource source;

  /// The stable entity identifier.
  final String habitId;

  /// The displayed local calendar date.
  final HabitDate day;

  /// The displayed compare-and-set version.
  final String expectedRecord;

  /// Creates a command for the displayed entity state.
  const HabitWidgetCommand({
    required this.action,
    this.source = HabitWidgetSource.automatic,
    required this.habitId,
    required this.day,
    required this.expectedRecord,
  });

  /// Parses the internal URI format, rejecting ambiguous or malformed inputs.
  static HabitWidgetCommand? tryParse(Uri uri) {
    if (uri.scheme != 'tablehabit-widget' ||
        uri.path.isNotEmpty ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return null;
    }
    final action = HabitWidgetAction.fromUriHost(uri.host);
    final query = uri.queryParametersAll;
    if ((query.length != 3 && query.length != 4) ||
        query.keys.any(
          (key) => !const {
            'habitId',
            'day',
            'expectedRecord',
            'source',
          }.contains(key),
        ) ||
        query.values.any((values) => values.length != 1)) {
      return null;
    }
    final source = switch (uri.queryParameters['source']) {
      null || 'automatic' => HabitWidgetSource.automatic,
      'fixed' => HabitWidgetSource.fixed,
      _ => null,
    };
    final id = uri.queryParameters['habitId'];
    final dateText = uri.queryParameters['day'];
    final revision = uri.queryParameters['expectedRecord'];
    if (action == null ||
        source == null ||
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
      source: source,
      habitId: id,
      day: day,
      expectedRecord: revision,
    );
  }

  /// Encodes this command in the internal URI format.
  Uri toUri() => Uri(
    scheme: 'tablehabit-widget',
    host: action.uriHost,
    queryParameters: {
      'source': source.name,
      'habitId': habitId,
      'day': _habitWidgetDay(day),
      'expectedRecord': expectedRecord,
    },
  );
}

/// Formats a local calendar date without time or timezone conversion.
String _habitWidgetDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Creates an opaque compare-and-set token from record and sync versions.
///
/// Sync counters distinguish successive writes with identical record values
/// and timestamps. A missing record uses the stable sentinel `none`.
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

/// Progress projected onto one local calendar date.
final class HabitWidgetDayProgress {
  /// The local calendar date represented by this sample.
  final HabitDate date;

  /// Normalized progress between zero and one.
  final double progress;

  /// Creates a daily progress sample.
  const HabitWidgetDayProgress(this.date, this.progress);

  /// Encodes the shared snapshot representation.
  Map<String, Object?> toJson() => {
    'date': _habitWidgetDay(date),
    'progress': progress,
  };
}

/// Display and action metadata for one catalog entity.
final class HabitWidgetHabit {
  /// Stable entity identifier used by configuration and actions.
  final String id;

  /// Display name.
  final String name;

  /// Packed ARGB display color.
  final int color;

  /// Whether the projected daily target is complete.
  final bool completed;

  /// Distinguishes missing records from recorded results, including valid zero.
  final HabitWidgetRecordState recordState;

  /// Normalized progress between zero and one.
  final double progress;

  /// Whether the complete operation is available.
  final bool canComplete;

  /// Whether an ordinary habit can be explicitly recorded as incomplete.
  final bool canMarkIncomplete;

  /// Whether the undo operation is available.
  final bool canUndo;

  /// Compare-and-set version for the projected record.
  final String expectedRecord;

  /// Daily progress samples ending on the snapshot date.
  final List<HabitWidgetDayProgress> sevenDays;

  /// The projected lifecycle state.
  final HabitWidgetHabitState state;

  /// The first local calendar date on which the entity applies.
  final HabitDate startDate;

  /// Whether the snapshot date is on or after [startDate].
  final bool started;

  /// Whether the projected daily record is skipped.
  final bool skipped;

  /// Whether the entity is eligible for automatic slot selection.
  final bool automaticEligible;

  /// Whether today's record still needs a result, independently of eligibility.
  final bool automaticPending;

  /// Creates a catalog entry from the authoritative record projection.
  const HabitWidgetHabit({
    required this.id,
    required this.name,
    required this.color,
    required this.completed,
    required this.recordState,
    required this.progress,
    required this.canComplete,
    required this.canMarkIncomplete,
    required this.canUndo,
    required this.expectedRecord,
    required this.sevenDays,
    required this.state,
    required this.startDate,
    required this.started,
    required this.skipped,
    required this.automaticEligible,
    required this.automaticPending,
  });

  /// Encodes the shared snapshot representation.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'completed': completed,
    'recordState': recordState.name,
    'progress': progress,
    'canComplete': canComplete,
    'canMarkIncomplete': canMarkIncomplete,
    'canUndo': canUndo,
    'expectedRecord': expectedRecord,
    'sevenDays': sevenDays.map((day) => day.toJson()).toList(),
    'state': state.name,
    'startDate': _habitWidgetDay(startDate),
    'started': started,
    'skipped': skipped,
    'automaticEligible': automaticEligible,
    'automaticPending': automaticPending,
  };
}

/// A complete, versioned display projection written to shared storage.
final class HabitWidgetSnapshot {
  /// Time at which this projection was sampled.
  final DateTime generatedAt;

  /// Local calendar date represented by the projection.
  final HabitDate day;

  /// Next local calendar boundary expressed as an absolute time.
  final DateTime nextDayAt;

  /// The complete ordered catalog of non-deleted entities.
  final List<HabitWidgetHabit> catalog;

  /// The app language used by native widget localization and date formatting.
  final String? locale;

  /// Copies the catalog into an unmodifiable collection.
  HabitWidgetSnapshot({
    required this.generatedAt,
    required this.day,
    required this.nextDayAt,
    required List<HabitWidgetHabit> catalog,
    this.locale,
  }) : catalog = List.unmodifiable(catalog);

  /// Selects the population used for the shared summary counters.
  Iterable<HabitWidgetHabit> get _activeStarted => catalog.where(
    (habit) => habit.state == HabitWidgetHabitState.active && habit.started,
  );

  /// Number of active entities whose start date has been reached.
  int get activeCount => _activeStarted.length;

  /// Number of completed entities included in [activeCount].
  int get completedCount =>
      _activeStarted.where((habit) => habit.completed).length;

  /// Encodes v2 JSON with the app locale and no runtime translation payload.
  Map<String, Object?> toJson() => {
    'version': 2,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'day': _habitWidgetDay(day),
    'nextDayAt': nextDayAt.toUtc().toIso8601String(),
    'catalog': catalog.map((habit) => habit.toJson()).toList(),
    'activeCount': activeCount,
    'completedCount': completedCount,
    'locale': locale,
  };
}
