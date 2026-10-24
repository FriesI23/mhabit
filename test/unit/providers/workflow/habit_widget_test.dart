// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_widget.dart';
import 'package:mhabit/providers/workflow/habit_widget.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/db/handlers/record.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/habit_widget.dart';
import 'package:uuid/uuid.dart';

class _Publisher implements HabitWidgetPublisher {
  HabitWidgetSnapshot? snapshot;
  bool failPublish = false;
  bool failRead = false;
  Future<void> Function(HabitWidgetSnapshot snapshot)? onPublish;
  String? storedLocale = 'ru';
  int localeReads = 0;

  @override
  Future<String?> readLocale() async {
    localeReads++;
    if (failRead) throw StateError('test snapshot locale read failure');
    return storedLocale;
  }

  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    await onPublish?.call(snapshot);
    if (failPublish) throw StateError('test publication failure');
    this.snapshot = snapshot;
    storedLocale = snapshot.locale;
  }
}

class _Manager extends HabitsManager {
  int reminderRefreshCount = 0;
  Future<void> Function()? onRefresh;

  @override
  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  }) async {
    reminderRefreshCount++;
    await onRefresh?.call();
  }
}

Matcher _hasOutcome(HabitWidgetActionResult outcome) =>
    isA<HabitWidgetActionResponse>().having(
      (value) => value.outcome,
      'outcome',
      outcome,
    );

void main() {
  final today = HabitDate(2026, 10, 17);
  late DateTime now;
  late DBHelperViewModel helper;
  late HabitDBHelper habits;
  late RecordDBHelper records;
  late _Publisher publisher;
  late _Manager manager;
  late HabitWidgetService service;

  String habitId(String name) =>
      const Uuid().v5('6ba7b810-9dad-11d1-80b4-00c04fd430c8', name);

  Future<void> addHabit(
    String id, {
    num goal = 1,
    num? extraGoal,
    HabitType type = HabitType.normal,
    HabitStatus status = HabitStatus.activated,
    HabitDate? start,
    num position = 0,
  }) async {
    await habits.insertNewHabit(
      HabitDBCell(
        uuid: habitId(id),
        type: type.dbCode,
        name: id,
        color: 1,
        dailyGoal: goal,
        dailyGoalUnit: 'times',
        dailyGoalExtra: extraGoal,
        targetDays: 100,
        freqType: 3,
        freqCustom: '[1,1]',
        startDate: (start ?? today.subtractDays(10)).epochDay,
        status: status.dbCode,
        sortPosition: position,
      ),
    );
  }

  Future<RecordDBCell?> current(String id) async =>
      (await records.loadRecordsExportData([
        habitId(id),
      ])).where((record) => record.recordDate == today.epochDay).firstOrNull;

  Future<void> saveRecord(
    String id,
    num value, {
    HabitRecordStatus status = HabitRecordStatus.done,
    bool deleted = false,
  }) async {
    final existing = await current(id);
    if (existing != null) {
      await records.updateRecord(
        existing.copyWith(
          recordValue: value,
          recordType: status.dbCode,
          isDeleted: deleted ? 1 : 0,
        ),
      );
      return;
    }
    final habit = (await habits.queryHabitByUUID(habitId(id)))!;
    await records.insertNewRecord(
      RecordDBCell.build(
        parentId: habit.id,
        parentUUID: habit.uuid,
        uuid: habitId('$id-record'),
        recordDate: today.epochDay,
        recordType: status.dbCode,
        recordValue: value,
        isDeleted: deleted ? 1 : 0,
      ),
    );
  }

  Future<String> revision(String id) async {
    final record = await current(id);
    if (record == null) return habitWidgetRecordRevision(null, sync: null);
    final rows = await helper.local.db.query(
      'mh_sync',
      where: 'record_uuid = ?',
      whereArgs: [record.uuid],
    );
    return habitWidgetRecordRevision(
      record,
      sync: rows.isEmpty ? null : SyncDBCell.fromJson(rows.single),
    );
  }

  Future<Uri> command(
    String id,
    HabitWidgetAction action, {
    HabitWidgetSource source = HabitWidgetSource.automatic,
  }) async => HabitWidgetCommand(
    action: action,
    source: source,
    habitId: habitId(id),
    day: today,
    expectedRecord: await revision(id),
  ).toUri();

  Future<int> recordDirty(String uuid) async {
    final rows = await helper.local.db.query(
      'mh_sync',
      columns: ['dirty'],
      where: 'record_uuid = ?',
      whereArgs: [uuid],
    );
    return rows.single['dirty'] as int;
  }

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    now = DateTime(2026, 10, 17, 12);
    helper = DBHelperViewModel();
    await helper.init();
    habits = HabitDBHelper(helper.local);
    records = RecordDBHelper(helper.local);
    publisher = _Publisher();
    manager = _Manager()..updateDBHelper(helper);
    service = HabitWidgetService(
      database: helper.local,
      habitsAccess: manager,
      publisher: publisher,
      now: () => now,
    );
  });

  tearDown(() async {
    await helper.local.db.close();
    helper.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'complete, duplicate, undo and restore retain UUID and sync tombstone',
    () async {
      await addHabit('binary');
      final complete = await command('binary', HabitWidgetAction.complete);
      expect(
        await service.perform(complete),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
      final first = (await current('binary'))!;
      expect(first.recordValue, 1);
      expect(first.deleted, isFalse);
      expect(await recordDirty(first.uuid!), 1);
      expect(publisher.snapshot!.catalog.single.completed, isTrue);
      expect(
        publisher.snapshot!.catalog.single.expectedRecord,
        await revision('binary'),
      );

      expect(
        await service.perform(complete),
        _hasOutcome(HabitWidgetActionResult.stale),
      );
      expect(await recordDirty(first.uuid!), 1);
      expect(
        await service.perform(
          await command('binary', HabitWidgetAction.complete),
        ),
        _hasOutcome(HabitWidgetActionResult.unchanged),
      );

      expect(
        await service.perform(await command('binary', HabitWidgetAction.undo)),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
      final deleted = (await current('binary'))!;
      expect(deleted.uuid, first.uuid);
      expect(deleted.deleted, isTrue);
      expect(await recordDirty(first.uuid!), 2);
      expect(publisher.snapshot!.catalog.single.completed, isFalse);
      expect(publisher.snapshot!.catalog.single.canUndo, isFalse);

      expect(
        await service.perform(
          await command('binary', HabitWidgetAction.complete),
        ),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
      expect((await current('binary'))!.uuid, first.uuid);
      expect((await current('binary'))!.deleted, isFalse);
      expect(await recordDirty(first.uuid!), 3);
      expect(manager.reminderRefreshCount, 3);
    },
  );

  test('same-second undo and redo invalidate an older undo command', () async {
    await addHabit('aba');
    await service.perform(await command('aba', HabitWidgetAction.complete));
    // Model the production trigger's one-second resolution deterministically.
    await helper.local.db.execute(
      'DROP TRIGGER auto_update_mh_records_modify_t',
    );
    final first = (await current('aba'))!;
    final staleUndo = await command('aba', HabitWidgetAction.undo);
    await records.updateRecord(first.copyWith(isDeleted: 1));
    await records.updateRecord(first);
    expect((await current('aba'))!.modifyT, first.modifyT);

    expect(
      await service.perform(staleUndo),
      _hasOutcome(HabitWidgetActionResult.stale),
    );
    expect((await current('aba'))!.deleted, isFalse);
    expect(await recordDirty(first.uuid!), 3);
  });

  test(
    'dirty count reuse after synchronization cannot revive an old undo',
    () async {
      await addHabit('synced');
      await service.perform(
        await command('synced', HabitWidgetAction.complete),
      );
      await helper.local.db.execute(
        'DROP TRIGGER auto_update_mh_records_modify_t',
      );
      final first = (await current('synced'))!;
      final staleUndo = await command('synced', HabitWidgetAction.undo);
      // A successful upload clears dirty and records its unique sync session.
      await helper.local.db.update(
        'mh_sync',
        {'dirty': 0, 'last_session_uuid': 'completed-upload-session'},
        where: 'record_uuid = ?',
        whereArgs: [first.uuid],
      );
      await records.updateRecord(first);
      expect(await recordDirty(first.uuid!), 1);

      expect(
        await service.perform(staleUndo),
        _hasOutcome(HabitWidgetActionResult.stale),
      );
      expect((await current('synced'))!.deleted, isFalse);
      expect(await recordDirty(first.uuid!), 1);
      expect(
        publisher.snapshot!.catalog.single.expectedRecord,
        await revision('synced'),
      );
    },
  );

  test(
    'numeric completion uses goal; stale undo preserves newer manual edit',
    () async {
      await addHabit('numeric', goal: 10);
      await service.perform(
        await command('numeric', HabitWidgetAction.complete),
      );
      final saved = (await current('numeric'))!;
      expect(saved.recordValue, 10);
      final staleUndo = await command('numeric', HabitWidgetAction.undo);
      await records.updateRecord(
        saved.copyWith(recordValue: 20, reason: 'Personal best'),
      );

      expect(
        await service.perform(staleUndo),
        _hasOutcome(HabitWidgetActionResult.stale),
      );
      final retained = (await current('numeric'))!;
      expect(retained.recordValue, 20);
      expect(retained.reason, 'Personal best');
      expect(retained.deleted, isFalse);
      final latestComplete = await command(
        'numeric',
        HabitWidgetAction.complete,
      );
      expect(
        await service.perform(latestComplete),
        _hasOutcome(HabitWidgetActionResult.unchanged),
      );
      expect((await current('numeric'))!.recordValue, 20);
    },
  );

  test(
    'partial numeric progress completes to target and retains note/extras',
    () async {
      await addHabit('numeric', goal: 10);
      await service.perform(
        await command('numeric', HabitWidgetAction.complete),
      );
      await records.updateRecord(
        (await current('numeric'))!.copyWith(
          recordValue: 3,
          reason: 'Keep this note',
          syncExtras: '{"futureField":true}',
        ),
      );
      final snapshot = await service.publishSnapshot();
      expect(snapshot.catalog.single.progress, 0.3);
      expect(snapshot.catalog.single.completed, isFalse);
      expect(snapshot.catalog.single.canComplete, isTrue);

      await service.perform(
        await command('numeric', HabitWidgetAction.complete),
      );
      final saved = (await current('numeric'))!;
      expect(saved.recordValue, 10);
      expect(saved.reason, 'Keep this note');
      expect(saved.syncExtras, '{"futureField":true}');
    },
  );

  test(
    'negative and zero targets use the existing completion semantics',
    () async {
      await addHabit(
        'negative',
        type: HabitType.negative,
        goal: 0,
        extraGoal: 3,
      );
      await addHabit('zero', type: HabitType.negative, goal: 0, extraGoal: 0);
      for (final id in ['negative', 'zero']) {
        await service.perform(await command(id, HabitWidgetAction.complete));
      }
      expect((await current('negative'))!.recordValue, 3);
      expect((await current('zero'))!.recordValue, 0);
      expect(
        publisher.snapshot!.catalog.every((habit) => habit.completed),
        isTrue,
      );
    },
  );

  for (final (name, type, goal, extra, values) in [
    ('normal', HabitType.normal, 10, 10, {0: false, 4: false, 10: true}),
    ('negative-zero', HabitType.negative, 0, 0, {0: true, 1: false}),
    (
      'negative-range',
      HabitType.negative,
      0,
      3,
      {0: true, 2: true, 3: true, 4: false},
    ),
    (
      'negative-minimum',
      HabitType.negative,
      2,
      3,
      {0: false, 1: false, 2: true, 3: true, 4: false},
    ),
  ]) {
    test('$name projects record presence and domain goal boundaries', () async {
      await addHabit(name, type: type, goal: goal, extraGoal: extra);
      var snapshot = await service.publishSnapshot();
      expect(
        snapshot.catalog.single.recordState,
        HabitWidgetRecordState.unrecorded,
      );
      expect(snapshot.catalog.single.progress, 0);
      for (final entry in values.entries) {
        await saveRecord(name, entry.key);
        final version = await revision(name);
        snapshot = await service.publishSnapshot();
        final habit = snapshot.catalog.single;
        expect(
          habit.recordState,
          entry.value
              ? HabitWidgetRecordState.achieved
              : HabitWidgetRecordState.notAchieved,
          reason: 'value=${entry.key}',
        );
        expect(habit.toJson()['recordState'], habit.recordState.name);
        expect(habit.completed, entry.value);
        expect(snapshot.completedCount, entry.value ? 1 : 0);
        final markedIncomplete = type == HabitType.normal && entry.key == 0;
        expect(habit.canComplete, !entry.value && !markedIncomplete);
        expect(
          habit.canMarkIncomplete,
          type == HabitType.normal && !entry.value && !markedIncomplete,
        );
        expect(habit.automaticPending, !entry.value && !markedIncomplete);
        expect(habit.canUndo, isTrue);
        // Stable eligibility remains independent of today's processed result.
        expect(habit.automaticEligible, isTrue);
        expect(habit.expectedRecord, version);
        expect(await revision(name), version);
        expect(habit.toJson()['automaticPending'], habit.automaticPending);
        expect(habit.toJson()['canMarkIncomplete'], habit.canMarkIncomplete);
        if (type == HabitType.negative) {
          expect(habit.progress, entry.value ? 1 : 0);
        }
      }
      await saveRecord(name, 0, deleted: true);
      snapshot = await service.publishSnapshot();
      expect(
        snapshot.catalog.single.recordState,
        HabitWidgetRecordState.unrecorded,
      );
      expect(snapshot.catalog.single.canUndo, isFalse);
      await saveRecord(name, 0, status: HabitRecordStatus.skip);
      snapshot = await service.publishSnapshot();
      expect(
        snapshot.catalog.single.recordState,
        HabitWidgetRecordState.skipped,
      );
      expect(snapshot.catalog.single.automaticEligible, isFalse);
      expect(snapshot.catalog.single.canComplete, isFalse);
      expect(snapshot.catalog.single.canUndo, isFalse);
      await saveRecord(name, 0, status: HabitRecordStatus.unknown);
      snapshot = await service.publishSnapshot();
      expect(
        snapshot.catalog.single.recordState,
        HabitWidgetRecordState.unknown,
      );
    });
  }

  test(
    'record states respect lifecycle and undo preserves missing-record semantics',
    () async {
      await addHabit(
        'archived-negative',
        type: HabitType.negative,
        goal: 0,
        extraGoal: 3,
        status: HabitStatus.archived,
      );
      await addHabit(
        'future-negative',
        type: HabitType.negative,
        goal: 0,
        extraGoal: 3,
        start: today.addDays(1),
      );
      await addHabit(
        'unknown-negative',
        type: HabitType.negative,
        goal: 0,
        extraGoal: 3,
        status: HabitStatus.unknown,
      );
      for (final name in [
        'archived-negative',
        'future-negative',
        'unknown-negative',
      ]) {
        await saveRecord(name, 0);
      }
      final snapshot = await service.publishSnapshot();
      final byName = {for (final habit in snapshot.catalog) habit.name: habit};
      expect(
        byName['archived-negative']!.recordState,
        HabitWidgetRecordState.achieved,
      );
      expect(byName['archived-negative']!.canUndo, isTrue);
      expect(byName['archived-negative']!.automaticEligible, isFalse);
      expect(
        byName['future-negative']!.recordState,
        HabitWidgetRecordState.unknown,
      );
      expect(byName['future-negative']!.canComplete, isFalse);
      expect(byName['future-negative']!.canUndo, isFalse);
      expect(
        byName['unknown-negative']!.recordState,
        HabitWidgetRecordState.unknown,
      );
      expect(byName['unknown-negative']!.canComplete, isFalse);
      expect(byName['unknown-negative']!.canUndo, isFalse);
      expect(snapshot.activeCount, 0);
      expect(snapshot.completedCount, 0);
      expect(
        await service.perform(
          await command(
            'archived-negative',
            HabitWidgetAction.undo,
            source: HabitWidgetSource.fixed,
          ),
        ),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
      expect((await current('archived-negative'))!.deleted, isTrue);
      expect(
        publisher.snapshot!.catalog
            .firstWhere((habit) => habit.name == 'archived-negative')
            .recordState,
        HabitWidgetRecordState.unrecorded,
      );
    },
  );

  test('stale day, archived and future habits cannot be mutated', () async {
    await addHabit('active');
    await addHabit('archived', status: HabitStatus.archived);
    await addHabit('future', start: today.addDays(1));
    for (final id in ['archived', 'future']) {
      expect(
        await service.perform(await command(id, HabitWidgetAction.complete)),
        _hasOutcome(HabitWidgetActionResult.stale),
      );
      expect(await current(id), isNull);
    }
    final old = await command('active', HabitWidgetAction.complete);
    now = DateTime(2026, 10, 18);
    expect(
      await service.perform(old),
      _hasOutcome(HabitWidgetActionResult.stale),
    );
    expect(await current('active'), isNull);
    expect(publisher.snapshot!.day, today.addDays(1));
  });

  test(
    'fixed archived completion and undo preserve archive and reminder ownership',
    () async {
      await addHabit('archive', status: HabitStatus.archived);
      final receipt = await service.perform(
        await command(
          'archive',
          HabitWidgetAction.complete,
          source: HabitWidgetSource.fixed,
        ),
      );
      expect(receipt.outcome, HabitWidgetActionResult.applied);
      expect(receipt.recordVersion, await revision('archive'));
      expect(receipt.committedAt, now.toUtc());
      expect(receipt.snapshotPublished, isTrue);
      final done = (await current('archive'))!;
      final undo = await service.perform(
        await command(
          'archive',
          HabitWidgetAction.undo,
          source: HabitWidgetSource.fixed,
        ),
      );
      expect(undo.outcome, HabitWidgetActionResult.applied);
      expect(undo.recordVersion, await revision('archive'));
      expect(undo.recordVersion, isNot(receipt.recordVersion));
      expect((await current('archive'))!.deleted, isTrue);
      expect((await current('archive'))!.uuid, done.uuid);
      expect(
        publisher.snapshot!.catalog.single.state,
        HabitWidgetHabitState.archived,
      );
      expect(manager.reminderRefreshCount, 2);
    },
  );

  test(
    'fixed sources still reject future, deleted, unknown and missing targets',
    () async {
      await addHabit('future', start: today.addDays(1));
      await addHabit('deleted', status: HabitStatus.deleted);
      await addHabit('unknown', status: HabitStatus.unknown);
      for (final id in ['future', 'deleted', 'unknown', 'missing']) {
        for (final action in HabitWidgetAction.values) {
          final receipt = await service.perform(
            await command(id, action, source: HabitWidgetSource.fixed),
          );
          expect(receipt.outcome, HabitWidgetActionResult.stale);
          expect(receipt.recordVersion, isNull);
          expect(receipt.committedAt, isNull);
          expect(await current(id), isNull);
        }
      }
    },
  );

  test(
    'receipt contains the exact committed record and sync version before another edit',
    () async {
      await addHabit('race');
      String? committedVersion;
      manager.onRefresh = () async {
        committedVersion = await revision('race');
        await records.updateRecord(
          (await current('race'))!.copyWith(reason: 'external edit'),
        );
      };
      final receipt = await service.perform(
        await command('race', HabitWidgetAction.complete),
      );
      expect(receipt.outcome, HabitWidgetActionResult.applied);
      expect(receipt.recordVersion, committedVersion);
      expect(receipt.recordVersion, isNot(await revision('race')));
      expect(
        publisher.snapshot!.catalog.single.expectedRecord,
        await revision('race'),
      );
    },
  );

  test(
    'publication failure retains the commit and cannot cause duplicate completion',
    () async {
      await addHabit('publish');
      final request = await command('publish', HabitWidgetAction.complete);
      publisher.failPublish = true;
      final receipt = await service.perform(request);
      expect(receipt.outcome, HabitWidgetActionResult.applied);
      expect(receipt.recordVersion, await revision('publish'));
      expect(receipt.committedAt, now.toUtc());
      expect(receipt.snapshotPublished, isFalse);
      final duplicate = await service.perform(request);
      expect(duplicate.outcome, HabitWidgetActionResult.stale);
      expect(duplicate.recordVersion, isNull);
      expect(duplicate.committedAt, isNull);
      expect(await recordDirty((await current('publish'))!.uuid!), 1);
      publisher.failPublish = false;
      final refreshed = await service.perform(
        Uri.parse('tablehabit-widget://refresh'),
      );
      expect(refreshed.outcome, HabitWidgetActionResult.unchanged);
      expect(refreshed.snapshotPublished, isTrue);
      expect(publisher.snapshot!.catalog.single.completed, isTrue);
    },
  );

  test(
    'a queued action continues after a failed snapshot publication',
    () async {
      await addHabit('queue-recovery');
      final uri = await command('queue-recovery', HabitWidgetAction.complete);
      var publications = 0;
      publisher.onPublish = (_) async {
        if (publications++ == 0) throw StateError('first publication failed');
      };

      final rejected = expectLater(service.publishSnapshot(), throwsStateError);
      final response = service.perform(uri);
      await rejected;
      expect((await response).outcome, HabitWidgetActionResult.applied);
      expect((await current('queue-recovery'))!.deleted, isFalse);
      expect(publisher.snapshot!.catalog.single.completed, isTrue);
      expect(publications, 2);
    },
  );

  test('a clock change before record resolution rejects the write', () async {
    await addHabit('midnight');
    final uri = await command('midnight', HabitWidgetAction.complete);
    var clockReads = 0;
    final crossingMidnight = HabitWidgetService(
      database: helper.local,
      habitsAccess: manager,
      publisher: publisher,
      now: () => clockReads++ == 0 ? now : now.add(const Duration(days: 1)),
    );
    final response = await crossingMidnight.perform(uri);
    expect(response.outcome, HabitWidgetActionResult.stale);
    expect(response.recordVersion, isNull);
    expect(await current('midnight'), isNull);
    expect(manager.reminderRefreshCount, 0);
    expect(publisher.snapshot!.day, today.addDays(1));
  });

  test(
    'post-commit refresh and publication failures retain committed metadata',
    () async {
      await addHabit('post-commit');
      final uri = await command('post-commit', HabitWidgetAction.complete);
      manager.onRefresh = () async => throw StateError('refresh failed');
      publisher.failRead = true;

      final response = await service.perform(uri);
      expect(response.outcome, HabitWidgetActionResult.applied);
      expect(response.recordVersion, await revision('post-commit'));
      expect(response.committedAt, now.toUtc());
      expect(response.snapshotPublished, isFalse);
      final duplicate = await service.perform(uri);
      expect(duplicate.outcome, HabitWidgetActionResult.stale);
      expect(duplicate.recordVersion, isNull);
      expect(manager.reminderRefreshCount, 1);
      expect(await recordDirty((await current('post-commit'))!.uuid!), 1);

      publisher.failRead = false;
      final refreshed = await service.perform(
        Uri.parse('tablehabit-widget://refresh'),
      );
      expect(refreshed.outcome, HabitWidgetActionResult.unchanged);
      expect(refreshed.snapshotPublished, isTrue);
      expect(publisher.snapshot!.catalog.single.completed, isTrue);
    },
  );

  test(
    'same-second widget undo and redo acknowledge different committed revisions',
    () async {
      await addHabit('receipts');
      await helper.local.db.execute(
        'DROP TRIGGER auto_update_mh_records_modify_t',
      );
      final first = await service.perform(
        await command('receipts', HabitWidgetAction.complete),
      );
      final oldUndo = await command('receipts', HabitWidgetAction.undo);
      final undo = await service.perform(oldUndo);
      final redo = await service.perform(
        await command('receipts', HabitWidgetAction.complete),
      );
      expect(
        {first.recordVersion, undo.recordVersion, redo.recordVersion}.length,
        3,
      );
      expect([
        first.committedAt,
        undo.committedAt,
        redo.committedAt,
      ], everyElement(now.toUtc()));
      expect(
        (await service.perform(oldUndo)).outcome,
        HabitWidgetActionResult.stale,
      );
    },
  );

  test('skipped records are not silently completed or removed', () async {
    await addHabit('skip');
    await service.perform(await command('skip', HabitWidgetAction.complete));
    await records.updateRecord(
      (await current(
        'skip',
      ))!.copyWith(recordType: HabitRecordStatus.skip.dbCode),
    );
    for (final action in HabitWidgetAction.values) {
      expect(
        await service.perform(await command('skip', action)),
        _hasOutcome(HabitWidgetActionResult.unchanged),
      );
    }
    expect((await current('skip'))!.recordType, HabitRecordStatus.skip.dbCode);
    expect(publisher.snapshot!.catalog.single.canComplete, isFalse);
    expect(publisher.snapshot!.catalog.single.canUndo, isFalse);
  });

  test(
    'two owners concurrently applying the same revision commit once',
    () async {
      await addHabit('shared');
      final other = HabitWidgetService(
        database: helper.local,
        habitsAccess: manager,
        publisher: publisher,
        now: () => now,
      );
      final uri = await command('shared', HabitWidgetAction.complete);
      final results = await Future.wait([
        service.perform(uri),
        other.perform(uri),
      ]);
      expect(results, contains(_hasOutcome(HabitWidgetActionResult.applied)));
      expect(results, contains(_hasOutcome(HabitWidgetActionResult.stale)));
      expect(await recordDirty((await current('shared'))!.uuid!), 1);
    },
  );

  test(
    'sync failure rolls back record and service can process the next action',
    () async {
      await addHabit('rollback');
      final uri = await command('rollback', HabitWidgetAction.complete);
      await helper.local.db.execute('''
CREATE TRIGGER reject_widget_sync BEFORE INSERT ON mh_sync
WHEN NEW.record_uuid IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'test sync failure'); END
''');
      expect(
        await service.perform(uri),
        _hasOutcome(HabitWidgetActionResult.failed),
      );
      expect(await current('rollback'), isNull);
      await helper.local.db.execute('DROP TRIGGER reject_widget_sync');
      expect(
        await service.perform(uri),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
    },
  );

  test('missing sync metadata cannot produce an applied receipt', () async {
    await addHabit('missing-sync');
    await service.perform(
      await command('missing-sync', HabitWidgetAction.complete),
    );
    final record = (await current('missing-sync'))!;
    await helper.local.db.delete(
      'mh_sync',
      where: 'record_uuid = ?',
      whereArgs: [record.uuid],
    );
    final receipt = await service.perform(
      await command('missing-sync', HabitWidgetAction.undo),
    );
    expect(receipt.outcome, HabitWidgetActionResult.failed);
    expect(receipt.recordVersion, isNull);
    expect(receipt.committedAt, isNull);
    expect((await current('missing-sync'))!.deleted, isFalse);
  });

  test(
    'snapshot has stable order, seven civil days and retained localization',
    () async {
      await addHabit('last', position: 9);
      await addHabit('first', position: 1);
      await addHabit('hidden', status: HabitStatus.deleted);
      final snapshot = await service.publishSnapshot();
      expect(snapshot.catalog.map((habit) => habit.name), ['first', 'last']);
      expect(snapshot.locale, 'ru');
      expect(snapshot.catalog.first.sevenDays.length, 7);
      expect(
        snapshot.catalog.first.sevenDays.first.date,
        today.subtractDays(6),
      );
      expect(snapshot.catalog.first.sevenDays.last.date, today);
      expect(snapshot.nextDayAt, DateTime(2026, 10, 18));
      expect(jsonDecode(jsonEncode(snapshot.toJson()))['version'], 2);
    },
  );

  test('v2 directory matches the shared native contract fixture', () async {
    await addHabit('first');
    await addHabit('archived', status: HabitStatus.archived, position: 1);
    await addHabit('future', start: today.addDays(1), position: 2);
    await addHabit('unknown', status: HabitStatus.unknown, position: 3);
    await addHabit('deleted', status: HabitStatus.deleted, position: 4);
    final snapshot = await service.publishSnapshot();
    final expected =
        jsonDecode(
              File(
                'test/fixtures/habit_widget/snapshot-v2.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    // Civil-day boundaries follow the host timezone; all remaining bytes of
    // the projection use the same fixture that XCTest decodes.
    expected['generatedAt'] = now.toUtc().toIso8601String();
    expected['nextDayAt'] = DateTime(2026, 10, 18).toUtc().toIso8601String();
    expected['locale'] = 'ru';
    expect(snapshot.toJson(), expected);
    expect(snapshot.activeCount, 1);
    expect(snapshot.completedCount, 0);
    expect(snapshot.catalog.clear, throwsUnsupportedError);
  });

  test(
    'directory counts and stable eligibility retain Dart goal rules',
    () async {
      await addHabit('done', position: 2);
      await addHabit('partial', goal: 10, position: 1);
      await addHabit('skip', position: 3);
      await addHabit('archived', status: HabitStatus.archived);
      await addHabit('future', start: today.addDays(1));
      await service.perform(await command('done', HabitWidgetAction.complete));
      await service.perform(
        await command('partial', HabitWidgetAction.complete),
      );
      await records.updateRecord(
        (await current('partial'))!.copyWith(recordValue: 4),
      );
      await service.perform(await command('skip', HabitWidgetAction.complete));
      await records.updateRecord(
        (await current(
          'skip',
        ))!.copyWith(recordType: HabitRecordStatus.skip.dbCode),
      );
      final snapshot = await service.publishSnapshot();
      final byName = {for (final habit in snapshot.catalog) habit.name: habit};
      expect(snapshot.activeCount, 3);
      expect(snapshot.completedCount, 1);
      expect(byName['done']!.automaticEligible, isTrue);
      expect(byName['done']!.completed, isTrue);
      expect(byName['partial']!.automaticEligible, isTrue);
      expect(byName['partial']!.completed, isFalse);
      expect(byName['partial']!.progress, 0.4);
      expect(byName['skip']!.skipped, isTrue);
      expect(byName['skip']!.automaticEligible, isFalse);
      expect(byName['archived']!.state, HabitWidgetHabitState.archived);
      expect(byName['archived']!.canComplete, isTrue);
      expect(byName['archived']!.automaticEligible, isFalse);
      expect(byName['future']!.started, isFalse);
      expect(byName['future']!.canComplete, isFalse);
      expect(byName['future']!.canUndo, isFalse);
    },
  );

  test(
    'incomplete writes zero, preserves metadata, and requires undo before replacing it',
    () async {
      await addHabit('incomplete', goal: 10);
      await saveRecord('incomplete', 4);
      await records.updateRecord(
        (await current(
          'incomplete',
        ))!.copyWith(reason: 'Keep note', syncExtras: '{"futureField":true}'),
      );
      final original = (await current('incomplete'))!;
      final request = await command(
        'incomplete',
        HabitWidgetAction.markIncomplete,
      );
      final response = await service.perform(request);
      expect(response.outcome, HabitWidgetActionResult.applied);
      final saved = (await current('incomplete'))!;
      expect(saved.uuid, original.uuid);
      expect(saved.recordValue, 0);
      expect(saved.recordType, HabitRecordStatus.done.dbCode);
      expect(saved.deleted, isFalse);
      expect(saved.reason, original.reason);
      expect(saved.syncExtras, original.syncExtras);
      final projected = publisher.snapshot!.catalog.single;
      expect(projected.recordState, HabitWidgetRecordState.notAchieved);
      expect(projected.automaticEligible, isTrue);
      expect(projected.automaticPending, isFalse);
      expect(projected.canComplete, isFalse);
      expect(projected.canMarkIncomplete, isFalse);
      expect(projected.canUndo, isTrue);
      expect(publisher.snapshot!.completedCount, 0);
      expect(response.recordVersion, await revision('incomplete'));
      expect(
        (await service.perform(request)).outcome,
        HabitWidgetActionResult.stale,
      );
      final version = await revision('incomplete');
      for (final action in [
        HabitWidgetAction.markIncomplete,
        HabitWidgetAction.complete,
      ]) {
        expect(
          (await service.perform(await command('incomplete', action))).outcome,
          HabitWidgetActionResult.unchanged,
        );
        expect(await revision('incomplete'), version);
      }
      expect(
        (await service.perform(
          await command('incomplete', HabitWidgetAction.undo),
        )).outcome,
        HabitWidgetActionResult.applied,
      );
      expect((await current('incomplete'))!.deleted, isTrue);
      expect(publisher.snapshot!.catalog.single.automaticPending, isTrue);
      expect(
        (await service.perform(
          await command('incomplete', HabitWidgetAction.markIncomplete),
        )).outcome,
        HabitWidgetActionResult.applied,
      );
      expect((await current('incomplete'))!.uuid, original.uuid);
      expect((await current('incomplete'))!.recordValue, 0);
      expect((await current('incomplete'))!.deleted, isFalse);
    },
  );

  test(
    'incomplete permissions and existing results are checked inside the transaction',
    () async {
      await addHabit('new-zero', goal: 10);
      await addHabit('archived-zero', goal: 10, status: HabitStatus.archived);
      await addHabit(
        'negative-zero',
        type: HabitType.negative,
        goal: 0,
        extraGoal: 3,
      );
      await addHabit('future-zero', start: today.addDays(1));
      await addHabit('deleted-zero', status: HabitStatus.deleted);
      await addHabit('unknown-zero', status: HabitStatus.unknown);
      await addHabit('skip-zero');
      await addHabit('done-zero');
      await saveRecord('skip-zero', 0, status: HabitRecordStatus.skip);
      await saveRecord('done-zero', 1);
      for (final name in ['new-zero', 'archived-zero']) {
        final source = name == 'archived-zero'
            ? HabitWidgetSource.fixed
            : HabitWidgetSource.automatic;
        expect(
          (await service.perform(
            await command(
              name,
              HabitWidgetAction.markIncomplete,
              source: source,
            ),
          )).outcome,
          HabitWidgetActionResult.applied,
        );
        expect((await current(name))!.recordValue, 0);
        expect(
          publisher.snapshot!.catalog.firstWhere((h) => h.name == name).canUndo,
          isTrue,
        );
      }
      for (final name in [
        'archived-zero',
        'future-zero',
        'deleted-zero',
        'unknown-zero',
        'missing-zero',
      ]) {
        expect(
          (await service.perform(
            await command(name, HabitWidgetAction.markIncomplete),
          )).outcome,
          HabitWidgetActionResult.stale,
        );
      }
      expect(
        (await service.perform(
          await command('negative-zero', HabitWidgetAction.markIncomplete),
        )).outcome,
        HabitWidgetActionResult.invalid,
      );
      expect(await current('negative-zero'), isNull);
      for (final name in ['skip-zero', 'done-zero']) {
        final version = await revision(name);
        expect(
          (await service.perform(
            await command(name, HabitWidgetAction.markIncomplete),
          )).outcome,
          HabitWidgetActionResult.unchanged,
        );
        expect(await revision(name), version);
      }
      expect(manager.reminderRefreshCount, 2);
    },
  );

  test(
    'incomplete commit survives publication failure and concurrent duplicates commit once',
    () async {
      await addHabit('zero-race', goal: 10);
      final request = await command(
        'zero-race',
        HabitWidgetAction.markIncomplete,
      );
      final other = HabitWidgetService(
        database: helper.local,
        habitsAccess: manager,
        publisher: publisher,
        now: () => now,
      );
      publisher.failPublish = true;
      final results = await Future.wait([
        service.perform(request),
        other.perform(request),
      ]);
      expect(
        results.map((r) => r.outcome),
        unorderedEquals([
          HabitWidgetActionResult.applied,
          HabitWidgetActionResult.stale,
        ]),
      );
      final applied = results.singleWhere(
        (r) => r.outcome == HabitWidgetActionResult.applied,
      );
      expect(applied.snapshotPublished, isFalse);
      expect(applied.recordVersion, await revision('zero-race'));
      expect(applied.committedAt, isNotNull);
      expect(await recordDirty((await current('zero-race'))!.uuid!), 1);
      publisher.failPublish = false;
      expect(
        (await service.perform(
          await command('zero-race', HabitWidgetAction.markIncomplete),
        )).outcome,
        HabitWidgetActionResult.unchanged,
      );
      expect(publisher.snapshot!.catalog.single.automaticPending, isFalse);
    },
  );

  test('command parser rejects malformed or ambiguous actions', () {
    final valid = HabitWidgetCommand(
      action: HabitWidgetAction.complete,
      source: HabitWidgetSource.automatic,
      habitId: 'id',
      day: today,
      expectedRecord: 'none',
    ).toUri();
    expect(HabitWidgetCommand.tryParse(valid), isNotNull);
    for (final invalid in [
      valid.replace(query: 'habitId=id&day=2026-10-17&expectedRecord=none'),
      valid.replace(scheme: 'tablehabit'),
      valid.replace(host: 'toggle'),
      valid.replace(
        query: valid.query.replaceFirst('source=automatic', 'source=other'),
      ),
      valid.replace(path: '/extra'),
      valid.replace(query: '${valid.query}&habitId=other'),
      valid.replace(
        query: valid.query.replaceFirst('2026-10-17', '2026-02-30'),
      ),
      valid.replace(query: 'habitId=id&day=2026-10-17'),
    ]) {
      expect(HabitWidgetCommand.tryParse(invalid), isNull, reason: '$invalid');
    }
  });

  test(
    'refresh after midnight publishes today without writing records',
    () async {
      await addHabit('refresh');
      now = DateTime(2026, 10, 18);
      expect(
        await service.perform(Uri.parse('tablehabit-widget://refresh')),
        _hasOutcome(HabitWidgetActionResult.unchanged),
      );
      expect(publisher.snapshot!.day, today.addDays(1));
      expect(await current('refresh'), isNull);
      expect(manager.reminderRefreshCount, 0);
      expect(
        await service.perform(
          Uri.parse('tablehabit-widget://refresh?unexpected=1'),
        ),
        _hasOutcome(HabitWidgetActionResult.invalid),
      );
    },
  );

  test(
    'long notes produce compact revisions and do not block widget actions',
    () async {
      await addHabit('note');
      await service.perform(await command('note', HabitWidgetAction.complete));
      await records.updateRecord(
        (await current('note'))!.copyWith(reason: 'Note' * 2000),
      );
      final token = await revision('note');
      expect(token.length, 64);
      expect(
        await service.perform(await command('note', HabitWidgetAction.undo)),
        _hasOutcome(HabitWidgetActionResult.applied),
      );
      expect((await current('note'))!.reason, 'Note' * 2000);
    },
  );

  test(
    'background complete undo and refresh read the latest shared locale',
    () async {
      await addHabit('locale');
      await service.publishSnapshot(locale: 'en');
      expect(publisher.localeReads, 0);
      for (final (locale, action) in [
        ('zh_Hant', HabitWidgetAction.complete),
        ('ar', HabitWidgetAction.undo),
        ('en', null),
      ]) {
        // The foreground app can change language while a background service
        // remains alive with its previous publication in memory.
        publisher.storedLocale = locale;
        final previousReads = publisher.localeReads;
        final response = await service.perform(
          action == null
              ? Uri.parse('tablehabit-widget://refresh')
              : await command('locale', action),
        );
        expect(
          response.outcome,
          action == null
              ? HabitWidgetActionResult.unchanged
              : HabitWidgetActionResult.applied,
        );
        expect(response.snapshotPublished, isTrue);
        expect(publisher.localeReads, previousReads + 1);
        expect(publisher.snapshot!.locale, locale);
        expect(publisher.snapshot!.toJson(), isNot(contains('strings')));
        expect(
          publisher.snapshot!.catalog.single.completed,
          action == HabitWidgetAction.complete,
        );
      }
    },
  );

  test(
    'null locale inherits shared state without an isolate language cache',
    () async {
      await service.publishSnapshot(locale: 'en');
      publisher.storedLocale = 'zh_Hant';
      expect((await service.publishSnapshot()).locale, 'zh_Hant');
      publisher.storedLocale = 'ar';
      expect((await service.publishSnapshot(locale: null)).locale, 'ar');
      publisher.storedLocale = null;
      expect((await service.publishSnapshot()).locale, isNull);
      expect(publisher.localeReads, 3);
    },
  );

  test(
    'locale read and publication failures preserve shared language',
    () async {
      await addHabit('locale-error');
      await service.publishSnapshot(locale: 'en');
      final previousSnapshot = publisher.snapshot;
      publisher.storedLocale = 'ar';
      publisher.failRead = true;
      await expectLater(service.publishSnapshot(), throwsStateError);
      expect(publisher.snapshot, same(previousSnapshot));
      expect(publisher.storedLocale, 'ar');
      final readFailure = await service.perform(
        Uri.parse('tablehabit-widget://refresh'),
      );
      expect(readFailure.outcome, HabitWidgetActionResult.failed);
      expect(readFailure.snapshotPublished, isFalse);
      expect(publisher.snapshot, same(previousSnapshot));
      expect(publisher.storedLocale, 'ar');

      publisher.failRead = false;
      publisher.failPublish = true;
      final publishFailure = await service.perform(
        Uri.parse('tablehabit-widget://refresh'),
      );
      expect(publishFailure.outcome, HabitWidgetActionResult.failed);
      expect(publishFailure.snapshotPublished, isFalse);
      expect(publisher.snapshot, same(previousSnapshot));
      expect(publisher.storedLocale, 'ar');
      expect(await current('locale-error'), isNull);
      expect(manager.reminderRefreshCount, 0);

      publisher.failPublish = false;
      final recovered = await service.perform(
        Uri.parse('tablehabit-widget://refresh'),
      );
      expect(recovered.outcome, HabitWidgetActionResult.unchanged);
      expect(recovered.snapshotPublished, isTrue);
      expect(publisher.snapshot!.locale, 'ar');
    },
  );
}
