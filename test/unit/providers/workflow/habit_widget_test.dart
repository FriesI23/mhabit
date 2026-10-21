// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

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
  Map<String, String> storedStrings = const {'today': 'Сегодня'};

  @override
  Future<Map<String, String>> readStrings() async => storedStrings;

  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    this.snapshot = snapshot;
    storedStrings = snapshot.strings;
  }
}

class _Manager extends HabitsManager {
  int reminderRefreshCount = 0;

  @override
  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  }) async {
    reminderRefreshCount++;
  }
}

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

  Future<Uri> command(String id, HabitWidgetAction action) async =>
      HabitWidgetCommand(
        action: action,
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
      expect(await service.perform(complete), HabitWidgetActionResult.applied);
      final first = (await current('binary'))!;
      expect(first.recordValue, 1);
      expect(first.deleted, isFalse);
      expect(await recordDirty(first.uuid!), 1);
      expect(publisher.snapshot!.habits.single.completed, isTrue);
      expect(
        publisher.snapshot!.habits.single.expectedRecord,
        await revision('binary'),
      );

      expect(await service.perform(complete), HabitWidgetActionResult.stale);
      expect(await recordDirty(first.uuid!), 1);
      expect(
        await service.perform(
          await command('binary', HabitWidgetAction.complete),
        ),
        HabitWidgetActionResult.unchanged,
      );

      expect(
        await service.perform(await command('binary', HabitWidgetAction.undo)),
        HabitWidgetActionResult.applied,
      );
      final deleted = (await current('binary'))!;
      expect(deleted.uuid, first.uuid);
      expect(deleted.deleted, isTrue);
      expect(await recordDirty(first.uuid!), 2);
      expect(publisher.snapshot!.habits.single.completed, isFalse);
      expect(publisher.snapshot!.habits.single.canUndo, isFalse);

      expect(
        await service.perform(
          await command('binary', HabitWidgetAction.complete),
        ),
        HabitWidgetActionResult.applied,
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

    expect(await service.perform(staleUndo), HabitWidgetActionResult.stale);
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

      expect(await service.perform(staleUndo), HabitWidgetActionResult.stale);
      expect((await current('synced'))!.deleted, isFalse);
      expect(await recordDirty(first.uuid!), 1);
      expect(
        publisher.snapshot!.habits.single.expectedRecord,
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

      expect(await service.perform(staleUndo), HabitWidgetActionResult.stale);
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
        HabitWidgetActionResult.unchanged,
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
      expect(snapshot.habits.single.progress, 0.3);
      expect(snapshot.habits.single.completed, isFalse);
      expect(snapshot.habits.single.canComplete, isTrue);

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
        publisher.snapshot!.habits.every((habit) => habit.completed),
        isTrue,
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
        HabitWidgetActionResult.stale,
      );
      expect(await current(id), isNull);
    }
    final old = await command('active', HabitWidgetAction.complete);
    now = DateTime(2026, 10, 18);
    expect(await service.perform(old), HabitWidgetActionResult.stale);
    expect(await current('active'), isNull);
    expect(publisher.snapshot!.day, today.addDays(1));
  });

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
        HabitWidgetActionResult.unchanged,
      );
    }
    expect((await current('skip'))!.recordType, HabitRecordStatus.skip.dbCode);
    expect(publisher.snapshot!.habits.single.canComplete, isFalse);
    expect(publisher.snapshot!.habits.single.canUndo, isFalse);
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
      expect(results, contains(HabitWidgetActionResult.applied));
      expect(results, contains(HabitWidgetActionResult.stale));
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
      await expectLater(service.perform(uri), throwsA(anything));
      expect(await current('rollback'), isNull);
      await helper.local.db.execute('DROP TRIGGER reject_widget_sync');
      expect(await service.perform(uri), HabitWidgetActionResult.applied);
    },
  );

  test(
    'snapshot has stable order, seven civil days and retained localization',
    () async {
      await addHabit('last', position: 9);
      await addHabit('first', position: 1);
      await addHabit('hidden', status: HabitStatus.deleted);
      final snapshot = await service.publishSnapshot();
      expect(snapshot.habits.map((habit) => habit.name), ['first', 'last']);
      expect(snapshot.strings['today'], 'Сегодня');
      expect(snapshot.habits.first.sevenDays.length, 7);
      expect(snapshot.habits.first.sevenDays.first.date, today.subtractDays(6));
      expect(snapshot.habits.first.sevenDays.last.date, today);
      expect(snapshot.nextDayAt, DateTime(2026, 10, 18));
      expect(jsonDecode(jsonEncode(snapshot.toJson()))['version'], 1);
    },
  );

  test('command parser rejects malformed or ambiguous actions', () {
    final valid = HabitWidgetCommand(
      action: HabitWidgetAction.complete,
      habitId: 'id',
      day: today,
      expectedRecord: 'none',
    ).toUri();
    expect(HabitWidgetCommand.tryParse(valid), isNotNull);
    for (final invalid in [
      valid.replace(scheme: 'tablehabit'),
      valid.replace(host: 'toggle'),
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
        HabitWidgetActionResult.unchanged,
      );
      expect(publisher.snapshot!.day, today.addDays(1));
      expect(await current('refresh'), isNull);
      expect(manager.reminderRefreshCount, 0);
      expect(
        await service.perform(
          Uri.parse('tablehabit-widget://refresh?unexpected=1'),
        ),
        HabitWidgetActionResult.invalid,
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
        HabitWidgetActionResult.applied,
      );
      expect((await current('note'))!.reason, 'Note' * 2000);
    },
  );

  test(
    'retained background owner reloads a locale changed by the app',
    () async {
      await addHabit('locale');
      await service.publishSnapshot(strings: {'today': 'Today'});
      publisher.storedStrings = {'today': 'Сегодня'};
      await service.perform(Uri.parse('tablehabit-widget://refresh'));
      expect(publisher.snapshot!.strings['today'], 'Сегодня');
    },
  );
}
