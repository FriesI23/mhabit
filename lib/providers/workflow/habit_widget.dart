// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/material.dart' show Brightness;

import '../../entries/habit_widget/habit_widget_api.g.dart'
    show HabitWidgetStringKey;
import '../../extensions/custom_color_extensions.dart';
import '../../logging/helper.dart';
import '../../models/habit_daily_record_form.dart';
import '../../models/habit_date.dart';
import '../../models/habit_form.dart';
import '../../models/habit_repo_actions.dart';
import '../../models/habit_summary.dart';
import '../../models/habit_widget.dart';
import '../../storage/db/db_helper.dart';
import '../../storage/db/handlers/record.dart';
import '../../storage/db/handlers/sync.dart';
import '../../storage/habit_widget.dart';
import '../../theme/color.dart' show lightCustomColors;
import '../../utils/app_clock.dart';
import 'habits_manager.dart';

/// Serializes snapshot publication and compare-and-set record operations.
///
/// Persistence and publication have separate outcomes:
///
/// ```text
/// request -> validate -> transaction commit -> refresh -> publish
///                            |                             |
///                            +------ action response ------+
/// ```
final class HabitWidgetService {
  final HabitsDisplayAccess _habitsAccess;
  final RecordDBHelper _records;
  final HabitWidgetPublisher _publisher;
  final DateTime Function() _now;
  Future<void> _pending = Future<void>.value();
  Map<HabitWidgetStringKey, String>? _strings;

  /// Creates a workflow bound to persistence, refresh, and publication owners.
  HabitWidgetService({
    required DBHelper database,
    required this._habitsAccess,
    HabitWidgetPublisher? publisher,
    DateTime Function()? now,
  }) : _records = RecordDBHelper(database),
       _publisher = publisher ?? HomeWidgetPublisher(),
       _now = now ?? AppClock().now;

  /// Runs work in order and keeps the queue usable after a rejected operation.
  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    // A failed publish must not permanently block later refreshes or actions.
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Publishes the current projection, optionally replacing localized values.
  Future<HabitWidgetSnapshot> publishSnapshot({
    Map<HabitWidgetStringKey, String>? strings,
  }) => _serialize(() async {
    if (strings != null) _strings = Map.unmodifiable(strings);
    return _publishSnapshot();
  });

  /// Executes a validated internal command and reports the committed outcome.
  Future<HabitWidgetActionResponse> perform(Uri uri) => _serialize(() async {
    if (uri.toString() == 'tablehabit-widget://refresh') {
      final published = await _publishAfterAction();
      return HabitWidgetActionResponse.result(
        published
            ? HabitWidgetActionResult.unchanged
            : HabitWidgetActionResult.failed,
        snapshotPublished: published,
      );
    }
    final command = HabitWidgetCommand.tryParse(uri);
    if (command == null) {
      return HabitWidgetActionResponse.result(HabitWidgetActionResult.invalid);
    }
    var outcome = HabitWidgetActionResult.stale;
    String? committedVersion;
    DateTime? committedAt;
    try {
      if (command.day == HabitDate.dateTime(_now())) {
        final committed = await _records.mutateCurrentHabitRecord(
          habitUUID: command.habitId,
          epochDay: command.day.epochDay,
          resolve: (cell, record, sync) {
            // Re-check the day after acquiring the SQLite write transaction.
            if (command.day != HabitDate.dateTime(_now())) return null;
            final habit = HabitSummaryData.fromDBQueryCell(cell);
            if ((!habit.isActived &&
                    !(command.source == HabitWidgetSource.fixed &&
                        habit.isArchived)) ||
                habit.startDate > command.day) {
              return null;
            }
            if (habitWidgetRecordRevision(record, sync: sync) !=
                command.expectedRecord) {
              return null;
            }
            if (record != null) {
              habit.initRecords([HabitSummaryRecord.fromDBQueryCell(record)]);
            }
            final current = habit.getRecordByDate(command.day);
            final completed = _isCompleted(habit, current);
            final ChangeRecordStatusAction<HabitDate> action;
            switch (command.action) {
              case HabitWidgetAction.complete:
                if (completed || current?.status == HabitRecordStatus.skip) {
                  outcome = HabitWidgetActionResult.unchanged;
                  return null;
                }
                action = ChangeMultiRecordStatusAction(
                  data: habit,
                  goal: habit.habitOkValue,
                  dateList: [command.day],
                );
              case HabitWidgetAction.undo:
                if (current?.status != HabitRecordStatus.done) {
                  outcome = HabitWidgetActionResult.unchanged;
                  return null;
                }
                action = DeleteRecordStatusAction(
                  data: habit,
                  dateList: [command.day],
                );
            }
            final result = action.resolve().single;
            outcome = HabitWidgetActionResult.applied;
            if (record != null) {
              return record.copyWith(
                recordType: result.data.status.dbCode,
                recordValue: result.data.value,
                isDeleted: const RecordDeletionCodec().encode(
                  result.data.isDeleted,
                ),
              );
            }
            return RecordDBCell.build(
              parentId: habit.id,
              parentUUID: habit.uuid,
              uuid: result.data.uuid,
              recordDate: result.date.epochDay,
              recordType: result.data.status.dbCode,
              recordValue: result.data.value,
              isDeleted: const RecordDeletionCodec().encode(
                result.data.isDeleted,
              ),
            );
          },
        );
        if (committed != null) {
          committedVersion = habitWidgetRecordRevision(
            committed.record,
            sync: committed.sync,
          );
          committedAt = _now(); // The transaction future has now committed.
        }
      }
    } catch (error, stackTrace) {
      appLog.habitWidget.error(
        'HabitWidgetService.commit',
        error: error,
        stackTrace: stackTrace,
      );
      return HabitWidgetActionResponse.result(HabitWidgetActionResult.failed);
    }
    if (outcome == HabitWidgetActionResult.applied) {
      try {
        await _habitsAccess.refreshHabitReminders(
          params: HabitReminderRefreshParams.habitUUID(command.habitId),
        );
      } catch (error, stackTrace) {
        // The committed record must remain visible if reminder repair fails.
        appLog.habitWidget.error(
          'HabitWidgetService.refreshHabitReminders',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    final published = await _publishAfterAction();
    return outcome == HabitWidgetActionResult.applied
        ? HabitWidgetActionResponse.applied(
            recordVersion: committedVersion!,
            committedAt: committedAt!,
            snapshotPublished: published,
          )
        : HabitWidgetActionResponse.result(
            outcome,
            snapshotPublished: published,
          );
  });

  /// Attempts publication without converting a committed write into failure.
  Future<bool> _publishAfterAction() async {
    try {
      await _publishSnapshot(reloadStrings: true);
      return true;
    } catch (error, stackTrace) {
      appLog.habitWidget.error(
        'HabitWidgetService.publishAfterAction',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Reads one consistent projection and saves it through the publisher.
  Future<HabitWidgetSnapshot> _publishSnapshot({
    bool reloadStrings = false,
  }) async {
    final now = _now();
    final day = HabitDate.dateTime(now);
    final data = await _records.loadHabitsAndRecordsInDateRange(
      fromEpochDay: day.subtractDays(6).epochDay,
      toEpochDay: day.epochDay,
    );
    final byHabit = <String, Map<int, RecordDBCell>>{};
    for (final record in data.records) {
      final parent = record.parentUUID;
      final date = record.recordDate;
      if (parent != null && date != null) {
        (byHabit[parent] ??= {})[date] = record;
      }
    }
    final habits =
        data.habits
            .where((cell) => cell.status != HabitStatus.deleted.dbCode)
            .map(HabitSummaryData.fromDBQueryCell)
            .toList()
          ..sort((left, right) {
            final position = left.sortPostion.compareTo(right.sortPostion);
            return position != 0 ? position : left.uuid.compareTo(right.uuid);
          });
    if (reloadStrings || _strings == null) {
      _strings = await _publisher.readStrings();
    }
    final snapshot = HabitWidgetSnapshot(
      generatedAt: now,
      day: day,
      // Construct tomorrow in local civil time; DST days need not be 24 hours.
      nextDayAt: DateTime(now.year, now.month, now.day + 1),
      strings: _strings!,
      catalog: [
        for (final habit in habits)
          _snapshotHabit(
            habit,
            day,
            byHabit[habit.uuid] ?? const {},
            data.recordSync,
          ),
      ],
    );
    await _publisher.publish(snapshot);
    return snapshot;
  }
}

/// Projects one entity and its current record versions into display metadata.
HabitWidgetHabit _snapshotHabit(
  HabitSummaryData habit,
  HabitDate day,
  Map<int, RecordDBCell> records,
  Map<String, SyncDBCell> recordSync,
) {
  HabitSummaryRecord? recordOn(HabitDate date) {
    if (date < habit.startDate) return null;
    final record = records[date.epochDay];
    return record == null || record.deleted
        ? null
        : HabitSummaryRecord.fromDBQueryCell(record);
  }

  final record = recordOn(day);
  final completed = _isCompleted(habit, record);
  final started = habit.startDate <= day;
  final skipped = record?.status == HabitRecordStatus.skip;
  final writable = started && (habit.isActived || habit.isArchived);
  return HabitWidgetHabit(
    id: habit.uuid,
    name: habit.name,
    color: lightCustomColors
        .getColor(habit.color, brightness: Brightness.light)!
        .toARGB32(),
    completed: completed,
    progress: _progress(habit, record),
    canComplete: writable && !completed && !skipped,
    canUndo: writable && record?.status == HabitRecordStatus.done,
    state: habit.isActived
        ? HabitWidgetHabitState.active
        : habit.isArchived
        ? HabitWidgetHabitState.archived
        : HabitWidgetHabitState.unknown,
    startDate: habit.startDate,
    started: started,
    skipped: skipped,
    automaticEligible: habit.isActived && started && !skipped,
    expectedRecord: habitWidgetRecordRevision(
      records[day.epochDay],
      sync: recordSync[records[day.epochDay]?.uuid],
    ),
    sevenDays: [
      for (var offset = 6; offset >= 0; offset--)
        HabitWidgetDayProgress(
          day.subtractDays(offset),
          _progress(habit, recordOn(day.subtractDays(offset))),
        ),
    ],
  );
}

/// Evaluates completion using the shared record-form calculation.
bool _isCompleted(HabitSummaryData habit, HabitSummaryRecord? record) {
  if (record == null || record.status != HabitRecordStatus.done) return false;
  final status = HabitDailyRecordForm.getImp(
    type: habit.type,
    value: record.value,
    targetValue: habit.dailyGoal,
    extraTargetValue: habit.dailyGoalExtra,
  ).complateStatus;
  return status == HabitDailyComplateStatus.ok ||
      status == HabitDailyComplateStatus.goodjob;
}

/// Normalizes a record into the display progress interval.
double _progress(HabitSummaryData habit, HabitSummaryRecord? record) {
  if (_isCompleted(habit, record)) return 1;
  if (record == null || record.status != HabitRecordStatus.done) return 0;
  // A negative habit has no monotonic amount-to-target progress: lower may
  // mean success or no effect. Its completion stays domain-defined above.
  if (habit.type != HabitType.normal || habit.dailyGoal <= 0) return 0;
  return (record.value / habit.dailyGoal).clamp(0.0, 1.0);
}
