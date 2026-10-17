// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:flutter/material.dart' show Brightness;
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
import '../../theme/color.dart' show lightCustomColors;
import '../../utils/app_clock.dart';
import 'habits_manager.dart';

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

/// Owns the compact native snapshot and compare-and-set record actions.
/// SQLite remains authoritative; the App Group contains display data only.
final class HabitWidgetService {
  final HabitsManager _habitsManager;
  final RecordDBHelper _records;
  final HabitWidgetPublisher _publisher;
  final DateTime Function() _now;
  Future<void> _pending = Future<void>.value();
  Map<String, String>? _strings;

  HabitWidgetService({
    required DBHelper database,
    required this._habitsManager,
    HabitWidgetPublisher? publisher,
    DateTime Function()? now,
  }) : _records = RecordDBHelper(database),
       _publisher = publisher ?? HomeWidgetPublisher(),
       _now = now ?? AppClock().now;

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    // A failed publish must not permanently block later refreshes or actions.
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<HabitWidgetSnapshot> publishSnapshot({Map<String, String>? strings}) =>
      _serialize(() async {
        if (strings != null) _strings = Map.unmodifiable(strings);
        return _publishSnapshot();
      });

  Future<HabitWidgetActionResult> perform(Uri uri) => _serialize(() async {
    if (uri.toString() == 'tablehabit-widget://refresh') {
      await _publishSnapshot(reloadStrings: true);
      return HabitWidgetActionResult.unchanged;
    }
    final command = HabitWidgetCommand.tryParse(uri);
    if (command == null) return HabitWidgetActionResult.invalid;
    var outcome = HabitWidgetActionResult.stale;
    if (command.day == HabitDate.dateTime(_now())) {
      await _records.mutateCurrentHabitRecord(
        habitUUID: command.habitId,
        epochDay: command.day.epochDay,
        resolve: (cell, record, sync) {
          // Re-check the day after acquiring the SQLite write transaction.
          if (command.day != HabitDate.dateTime(_now())) return null;
          final habit = HabitSummaryData.fromDBQueryCell(cell);
          if (!habit.isActived || habit.startDate > command.day) return null;
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
    }
    if (outcome == HabitWidgetActionResult.applied) {
      try {
        await _habitsManager.refreshHabitReminders(
          params: HabitReminderRefreshParams.habitUUID(command.habitId),
        );
      } catch (error, stackTrace) {
        // The committed record must remain visible if reminder repair fails.
        appLog.notify.error(
          'HabitWidgetService.refreshHabitReminders',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    await _publishSnapshot(reloadStrings: true);
    return outcome;
  });

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
            .where((cell) => cell.status == HabitStatus.activated.dbCode)
            .map(HabitSummaryData.fromDBQueryCell)
            .where((habit) => habit.isActived && habit.startDate <= day)
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
      habits: [
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
  return HabitWidgetHabit(
    id: habit.uuid,
    name: habit.name,
    color: lightCustomColors
        .getColor(habit.color, brightness: Brightness.light)!
        .toARGB32(),
    completed: completed,
    progress: _progress(habit, record),
    canComplete: !completed && record?.status != HabitRecordStatus.skip,
    canUndo: record?.status == HabitRecordStatus.done,
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

double _progress(HabitSummaryData habit, HabitSummaryRecord? record) {
  if (_isCompleted(habit, record)) return 1;
  if (record == null || record.status != HabitRecordStatus.done) return 0;
  // A negative habit has no monotonic amount-to-target progress: lower may
  // mean success or no effect. Its completion stays domain-defined above.
  if (habit.type != HabitType.normal || habit.dailyGoal <= 0) return 0;
  return (record.value / habit.dailyGoal).clamp(0.0, 1.0);
}
