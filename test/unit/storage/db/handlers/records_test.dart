// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/db/handlers/record.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _TestDBHelper implements DBHelper {
  _TestDBHelper(this.db);

  @override
  final Database db;

  @override
  Future<void> init({bool reinit = false}) async {}

  @override
  void dispose() {}
}

void main() {
  test('record deletion marker converts only at the DB boundary', () {
    const codec = RecordDeletionCodec();
    expect(codec.decode(0), isFalse);
    expect(codec.decode(1), isTrue);
    expect(codec.encode(false), 0);
    expect(codec.encode(true), 1);
    expect(RecordDBCell().deleted, isFalse);
  });

  group("RecordDBCell", () {
    final record1 = RecordDBCell(
      id: 1,
      parentId: 1,
      recordDate: 1,
      recordType: 1,
      recordValue: 1.2,
      createT: 1,
      modifyT: 1,
      uuid: 'xxx',
    );
    final record2 = RecordDBCell(
      parentId: 1,
      recordDate: 1,
      recordValue: 1.2,
      createT: 1,
      modifyT: 1,
      uuid: 'xxx',
    );
    test("toMap", () {
      final result1 = record1.toJson();
      expect(result1[RecordDBCellKey.parentId], 1);
      expect(result1[RecordDBCellKey.id], 1);
      expect(result1[RecordDBCellKey.recordType], 1);
      final result2 = record2.toJson();
      expect(result2[RecordDBCellKey.parentId], 1);
      expect(result2.containsKey(RecordDBCellKey.id), false);
    });
    test('toString', () {
      expect(record1.toString().startsWith("RecordDB"), true);
    });
  });

  group('mutateCurrentHabitRecord', () {
    const habitUUID = "habit-'quoted-value";
    const recordUUID = "record-'quoted-value";
    const epochDay = 42;
    late DBHelperViewModel helper;
    late RecordDBHelper records;
    late int habitId;

    RecordDBCell newRecord() => RecordDBCell(
      parentId: habitId,
      parentUUID: habitUUID,
      uuid: recordUUID,
      recordDate: epochDay,
      recordType: 1,
      recordValue: 1,
      createT: 100,
      modifyT: 100,
    );

    Future<({RecordDBCell record, SyncDBCell sync})?> mutate(
      RecordDBCell? Function(
        HabitDBCell habit,
        RecordDBCell? record,
        SyncDBCell? sync,
      )
      resolve,
    ) => records.mutateCurrentHabitRecord(
      habitUUID: habitUUID,
      epochDay: epochDay,
      resolve: resolve,
    );

    Future<Map<String, Object>> state() async => {
      'records': await helper.local.db.query('mh_records', orderBy: 'id_'),
      'sync': await helper.local.db.query('mh_sync', orderBy: 'id_'),
    };

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      helper = DBHelperViewModel();
      await helper.init();
      records = RecordDBHelper(helper.local);
      habitId = await HabitDBHelper(helper.local).insertNewHabit(
        const HabitDBCell(
          uuid: habitUUID,
          type: 0,
          status: 1,
          dailyGoal: 1,
          dailyGoalUnit: 'times',
          startDate: epochDay - 1,
        ),
      );
    });

    tearDown(() async {
      await helper.local.db.close();
      helper.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    test('missing habit does not invoke the resolver or mutate rows', () async {
      final before = await state();
      var resolved = false;
      final result = await records.mutateCurrentHabitRecord(
        habitUUID: 'missing',
        epochDay: epochDay,
        resolve: (_, _, _) {
          resolved = true;
          return newRecord();
        },
      );
      expect(result, isNull);
      expect(resolved, isFalse);
      expect(await state(), before);
    });

    test(
      'batched reads bind identifiers and return inserted metadata',
      () async {
        final result = await mutate((habit, record, sync) {
          expect(habit.uuid, habitUUID);
          expect(record, isNull);
          expect(sync, isNull);
          return newRecord();
        });
        expect(result, isNotNull);
        expect(result!.record.uuid, recordUUID);
        expect(result.record.id, isNotNull);
        expect(result.sync.recordUUID, recordUUID);
        expect(result.sync.dirty, 1);
        expect(result.sync.createT, isNotNull);
        expect(
          result.record.toJson(),
          RecordDBCell.fromJson(
            (await helper.local.db.query('mh_records')).single,
          ).toJson(),
        );
        expect(
          result.sync.toJson(),
          SyncDBCell.fromJson(
            (await helper.local.db.query(
              'mh_sync',
              where: 'record_uuid = ?',
              whereArgs: [recordUUID],
            )).single,
          ).toJson(),
        );
      },
    );

    test('a declined change preserves the record and sync counters', () async {
      await records.insertNewRecord(newRecord());
      final before = await state();
      final result = await mutate((habit, record, sync) {
        expect(record!.uuid, recordUUID);
        expect(sync!.recordUUID, recordUUID);
        expect(sync.dirty, 1);
        return null;
      });
      expect(result, isNull);
      expect(await state(), before);
    });

    test('a resolver exception leaves the transaction unchanged', () async {
      await records.insertNewRecord(newRecord());
      final before = await state();
      await expectLater(
        mutate((_, _, _) => throw StateError('resolver failed')),
        throwsStateError,
      );
      expect(await state(), before);
      expect(await mutate((_, _, _) => null), isNull);
    });

    test(
      'sync insertion failure rolls back the record and allows retry',
      () async {
        final before = await state();
        await helper.local.db.execute('''
CREATE TRIGGER reject_record_sync BEFORE INSERT ON mh_sync
WHEN NEW.record_uuid IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'test sync insertion failure'); END
''');
        await expectLater(
          mutate((_, _, _) => newRecord()),
          throwsA(isA<DatabaseException>()),
        );
        expect(await state(), before);
        await helper.local.db.execute('DROP TRIGGER reject_record_sync');
        final retried = await mutate((_, _, _) => newRecord());
        expect(retried!.sync.dirty, 1);
        expect((await helper.local.db.query('mh_records')).length, 1);
      },
    );

    test('record sync update failure rolls back the changed record', () async {
      await records.insertNewRecord(newRecord());
      final before = await state();
      await helper.local.db.execute('''
CREATE TRIGGER reject_record_dirty BEFORE UPDATE OF dirty ON mh_sync
WHEN NEW.record_uuid IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'test record dirty failure'); END
''');
      await expectLater(
        mutate((_, record, _) => record!.copyWith(recordValue: 2)),
        throwsA(isA<DatabaseException>()),
      );
      expect(await state(), before);
    });

    test('habit counter failure rolls back record and sync updates', () async {
      await records.insertNewRecord(newRecord());
      final before = await state();
      await helper.local.db.execute('''
CREATE TRIGGER reject_habit_dirty BEFORE UPDATE OF dirty_total ON mh_sync
WHEN NEW.habit_uuid IS NOT NULL
BEGIN SELECT RAISE(ABORT, 'test habit dirty failure'); END
''');
      await expectLater(
        mutate((_, record, _) => record!.copyWith(recordValue: 2)),
        throwsA(isA<DatabaseException>()),
      );
      expect(await state(), before);
    });

    test('missing committed sync metadata aborts the record update', () async {
      await records.insertNewRecord(newRecord());
      await helper.local.db.delete(
        'mh_sync',
        where: 'record_uuid = ?',
        whereArgs: [recordUUID],
      );
      final before = await state();
      await expectLater(
        mutate((_, record, sync) {
          expect(sync, isNull);
          return record!.copyWith(recordValue: 2);
        }),
        throwsStateError,
      );
      expect(await state(), before);
    });

    test('a missing post-trigger record aborts all changes', () async {
      await records.insertNewRecord(newRecord());
      final before = await state();
      await helper.local.db.execute('''
CREATE TRIGGER remove_updated_record AFTER UPDATE ON mh_records
BEGIN
  DELETE FROM mh_sync WHERE record_uuid = NEW.uuid;
  DELETE FROM mh_records WHERE uuid = NEW.uuid;
END
''');
      await expectLater(
        mutate((_, record, _) => record!.copyWith(recordValue: 2)),
        throwsStateError,
      );
      expect(await state(), before);
    });

    test('queued mutations each return their own committed revision', () async {
      await records.insertNewRecord(newRecord());
      final results = await Future.wait([
        mutate((_, record, sync) {
          expect(sync!.dirty, 1);
          return record!.copyWith(recordValue: 2);
        }),
        mutate((_, record, sync) {
          expect(record!.recordValue, 2);
          expect(sync!.dirty, 2);
          return record.copyWith(recordValue: 3);
        }),
      ]);
      expect(results[0]!.record.recordValue, 2);
      expect(results[0]!.sync.dirty, 2);
      expect(results[0]!.record.modifyT, greaterThan(100));
      expect(results[1]!.record.recordValue, 3);
      expect(results[1]!.sync.dirty, 3);
      expect((await records.loadSingleRecord(recordUUID))!.recordValue, 3);
    });
  });

  test('loadRecords binds the habit UUID as a query argument', () async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE mh_habits (
        uuid TEXT PRIMARY KEY,
        start_date INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE mh_records (
        parent_uuid TEXT NOT NULL,
        uuid TEXT PRIMARY KEY,
        record_date INTEGER NOT NULL,
        record_type INTEGER NOT NULL,
        record_value REAL NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    const habitUUID = "habit-'quoted-value";
    await db.insert('mh_habits', {'uuid': habitUUID, 'start_date': 10});
    await db.insert('mh_records', {
      'parent_uuid': habitUUID,
      'uuid': 'record-uuid',
      'record_date': 11,
      'record_type': 1,
      'record_value': 1,
    });

    final records = await RecordDBHelper(
      _TestDBHelper(db),
    ).loadRecords(habitUUID);

    expect(records.single.uuid, 'record-uuid');
  });
}
