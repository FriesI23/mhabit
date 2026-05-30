// Copyright 2026 Fries_I23
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';

HabitDate _date(int day) => HabitDate(2026, 1, day);

HabitSummaryData _buildHabitSummaryData() => HabitSummaryData(
  id: 1,
  uuid: '11111111-1111-4111-8111-111111111111',
  type: HabitType.normal,
  name: 'Sample Habit',
  desc: '',
  colorType: HabitColorType.cc1,
  dailyGoal: 1,
  targetDays: 1,
  frequency: HabitFrequency.daily,
  startDate: _date(1),
  status: HabitStatus.activated,
  sortPostion: 1,
  createTime: DateTime.utc(2026, 1, 1),
);

HabitSummaryRecord _buildRecord({
  required String uuid,
  required int day,
  HabitRecordStatus status = HabitRecordStatus.done,
  num value = 1,
}) => HabitSummaryRecord(uuid, _date(day), status, value);

void main() {
  group('HabitSummaryData record storage', () {
    late HabitSummaryData data;

    setUp(() {
      data = _buildHabitSummaryData();
    });

    test('missing lookups return null and false on an empty store', () {
      expect(data.recordCount, 0);
      expect(data.getRecordByUUID('missing-uuid'), isNull);
      expect(data.getRecordByDate(_date(20)), isNull);
      expect(data.containsRecordUUID('missing-uuid'), isFalse);
      expect(data.containsRecordDate(_date(20)), isFalse);
      expect(data.removeRecordByUUID('missing-uuid'), isNull);
      expect(data.removeRecordByDate(_date(20)), isNull);
    });

    test('addRecord stores record in both lookup indexes', () {
      final record = _buildRecord(uuid: 'record-1', day: 2);

      expect(data.addRecord(record), isTrue);
      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(record.uuid), same(record));
      expect(data.getRecordByDate(record.date), same(record));
      expect(data.containsRecordUUID(record.uuid), isTrue);
      expect(data.containsRecordDate(record.date), isTrue);
      expect(data.records.toList(), [record]);
    });

    test('addRecord rejects duplicate uuid without replacement', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final duplicateUuid = _buildRecord(uuid: 'record-1', day: 3);

      expect(data.addRecord(original), isTrue);
      expect(data.addRecord(duplicateUuid), isFalse);

      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(original.uuid), same(original));
      expect(data.getRecordByDate(original.date), same(original));
      expect(data.getRecordByDate(duplicateUuid.date), isNull);
    });

    test('addRecord rejects duplicate date without replacement', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final duplicateDate = _buildRecord(uuid: 'record-2', day: 2);

      expect(data.addRecord(original), isTrue);
      expect(data.addRecord(duplicateDate), isFalse);

      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(original.uuid), same(original));
      expect(data.getRecordByUUID(duplicateDate.uuid), isNull);
      expect(data.getRecordByDate(original.date), same(original));
    });

    test('addRecord with replacement keeps uuid and date indexes aligned', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final replaceByUuid = _buildRecord(uuid: 'record-1', day: 3);
      final replaceByDate = _buildRecord(uuid: 'record-2', day: 3);

      expect(data.addRecord(original), isTrue);
      expect(data.addRecord(replaceByUuid, replaced: true), isTrue);
      expect(data.addRecord(replaceByDate, replaced: true), isTrue);

      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(original.uuid), isNull);
      expect(data.getRecordByDate(original.date), isNull);
      expect(data.getRecordByUUID(replaceByUuid.uuid), isNull);
      expect(data.getRecordByUUID(replaceByDate.uuid), same(replaceByDate));
      expect(data.getRecordByDate(replaceByDate.date), same(replaceByDate));
    });

    test('removeRecordByUUID removes both lookup entries', () {
      final record = _buildRecord(uuid: 'record-1', day: 2);

      data.addRecord(record);

      expect(data.removeRecordByUUID(record.uuid), same(record));
      expect(data.removeRecordByUUID(record.uuid), isNull);
      expect(data.recordCount, 0);
      expect(data.getRecordByUUID(record.uuid), isNull);
      expect(data.getRecordByDate(record.date), isNull);
    });

    test('removeRecordByDate removes both lookup entries', () {
      final record = _buildRecord(uuid: 'record-1', day: 2);

      data.addRecord(record);

      expect(data.removeRecordByDate(record.date), same(record));
      expect(data.removeRecordByDate(record.date), isNull);
      expect(data.recordCount, 0);
      expect(data.getRecordByUUID(record.uuid), isNull);
      expect(data.getRecordByDate(record.date), isNull);
    });

    test('clearRecords removes all cached records and lookups', () {
      final first = _buildRecord(uuid: 'record-1', day: 2);
      final second = _buildRecord(uuid: 'record-2', day: 3);

      data.addAllRecords([first, second]);
      data.clearRecords();

      expect(data.recordCount, 0);
      expect(data.records, isEmpty);
      expect(data.getRecordByUUID(first.uuid), isNull);
      expect(data.getRecordByDate(second.date), isNull);
      expect(data.containsRecordUUID(first.uuid), isFalse);
      expect(data.containsRecordDate(second.date), isFalse);
    });

    test('addAllRecords with failed behavior is atomic on conflicts', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final unique = _buildRecord(uuid: 'record-2', day: 3);
      final conflict = _buildRecord(uuid: 'record-1', day: 4);

      data.addRecord(original);

      expect(
        data.addAllRecords([
          unique,
          conflict,
        ], behaviour: HabitReocrdAddRepeatedBehaviour.failed),
        isFalse,
      );

      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(original.uuid), same(original));
      expect(data.getRecordByUUID(unique.uuid), isNull);
      expect(data.getRecordByDate(unique.date), isNull);
    });

    test('addAllRecords with failed behavior is atomic on date conflicts', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final unique = _buildRecord(uuid: 'record-2', day: 3);
      final conflict = _buildRecord(uuid: 'record-3', day: 2);

      data.addRecord(original);

      expect(
        data.addAllRecords([
          unique,
          conflict,
        ], behaviour: HabitReocrdAddRepeatedBehaviour.failed),
        isFalse,
      );

      expect(data.recordCount, 1);
      expect(data.getRecordByUUID(original.uuid), same(original));
      expect(data.getRecordByUUID(unique.uuid), isNull);
      expect(data.getRecordByUUID(conflict.uuid), isNull);
      expect(data.getRecordByDate(unique.date), isNull);
    });

    test(
      'addAllRecords with skipped behavior keeps originals and adds unique',
      () {
        final original = _buildRecord(uuid: 'record-1', day: 2);
        final unique = _buildRecord(uuid: 'record-2', day: 3);
        final conflict = _buildRecord(uuid: 'record-1', day: 4);

        data.addRecord(original);

        expect(
          data.addAllRecords([
            unique,
            conflict,
          ], behaviour: HabitReocrdAddRepeatedBehaviour.skipped),
          isTrue,
        );

        expect(data.recordCount, 2);
        expect(data.getRecordByUUID(original.uuid), same(original));
        expect(data.getRecordByUUID(unique.uuid), same(unique));
        expect(data.getRecordByDate(conflict.date), isNull);
        expect(data.records.map((record) => record.date.day).toList(), [2, 3]);
      },
    );

    test('addAllRecords with replaced behavior replaces conflicts', () {
      final original = _buildRecord(uuid: 'record-1', day: 2);
      final unique = _buildRecord(uuid: 'record-2', day: 3);
      final replacement = _buildRecord(uuid: 'record-3', day: 2);

      data.addRecord(original);

      expect(
        data.addAllRecords([
          unique,
          replacement,
        ], behaviour: HabitReocrdAddRepeatedBehaviour.replaced),
        isTrue,
      );

      expect(data.recordCount, 2);
      expect(data.getRecordByUUID(original.uuid), isNull);
      expect(data.getRecordByUUID(unique.uuid), same(unique));
      expect(data.getRecordByUUID(replacement.uuid), same(replacement));
      expect(data.getRecordByDate(original.date), same(replacement));
      expect(data.records.map((record) => record.uuid).toList(), [
        replacement.uuid,
        unique.uuid,
      ]);
    });

    test('initRecords clears stale records and keeps date order', () {
      final stale = _buildRecord(uuid: 'stale-record', day: 9);
      final later = _buildRecord(uuid: 'record-2', day: 5);
      final earlier = _buildRecord(uuid: 'record-1', day: 3);

      data.addRecord(stale);
      data.initRecords([later, earlier]);

      expect(data.recordCount, 2);
      expect(data.getRecordByUUID(stale.uuid), isNull);
      expect(data.getRecordByDate(stale.date), isNull);
      expect(data.records.map((record) => record.uuid).toList(), [
        earlier.uuid,
        later.uuid,
      ]);
    });
  });
}
