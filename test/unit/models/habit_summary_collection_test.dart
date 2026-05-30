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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/db/handlers/record.dart';
import 'package:mhabit/utils/app_clock.dart';
import 'package:quiver/time.dart';

HabitDate _date(int month, int day) => HabitDate(2026, month, day);

void _setNow(DateTime now) {
  AppClock().setClock(Clock(() => now));
}

HabitSummaryRecord _buildRecord({
  required String uuid,
  required int month,
  required int day,
  HabitRecordStatus status = HabitRecordStatus.done,
  num value = 1,
}) => HabitSummaryRecord(uuid, _date(month, day), status, value);

HabitSummaryData _buildHabitSummaryData({
  required String uuid,
  required String name,
  HabitType type = HabitType.normal,
  HabitColorType colorType = HabitColorType.cc1,
  HabitFrequency frequency = HabitFrequency.daily,
  HabitStatus status = HabitStatus.activated,
  num dailyGoal = 1,
  num? dailyGoalExtra,
  int targetDays = 1,
  HabitDate? startDate,
  num sortPostion = 1,
  DateTime? createTime,
  Iterable<HabitSummaryRecord> records = const [],
  bool recalculate = false,
}) {
  final effectiveStartDate = startDate ?? _date(1, 1);
  final data = HabitSummaryData(
    id: uuid.hashCode,
    uuid: uuid,
    type: type,
    name: name,
    desc: '',
    colorType: colorType,
    dailyGoal: dailyGoal,
    dailyGoalExtra: dailyGoalExtra,
    targetDays: targetDays,
    frequency: frequency,
    startDate: effectiveStartDate,
    status: status,
    sortPostion: sortPostion,
    createTime:
        createTime ??
        DateTime.utc(
          effectiveStartDate.year,
          effectiveStartDate.month,
          effectiveStartDate.day,
        ),
  );
  data.initRecords(records);
  if (recalculate) {
    data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
  }
  return data;
}

HabitSummaryDataCollection _buildCollection(Iterable<HabitSummaryData> habits) {
  final collection = HabitSummaryDataCollection();
  for (final habit in habits) {
    collection.addNewHabit(habit, forceAdd: true);
  }
  return collection;
}

List<String> _uuids(Iterable<HabitSummaryData> habits) =>
    habits.map((habit) => habit.uuid).toList();

HabitDBCell _buildHabitDBCell({
  required String uuid,
  String name = 'DB Habit',
  HabitDate? startDate,
}) {
  final effectiveStartDate = startDate ?? _date(1, 1);
  return HabitDBCell(
    id: uuid.hashCode,
    type: HabitType.normal.dbCode,
    createT: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ onSecondMS,
    uuid: uuid,
    status: HabitStatus.activated.dbCode,
    name: name,
    desc: '',
    color: HabitColorType.cc1.dbCode,
    dailyGoal: 1,
    dailyGoalUnit: defaultHabitDailyGoalUnit,
    freqType: HabitFrequency.daily.type.dbCode,
    freqCustom: jsonEncode(HabitFrequency.daily.toJson()['args']),
    startDate: effectiveStartDate.epochDay,
    targetDays: 1,
    sortPosition: 1,
  );
}

RecordDBCell _buildRecordDBCell({
  required String uuid,
  required String parentUUID,
  required HabitDate date,
  HabitRecordStatus status = HabitRecordStatus.done,
  num value = 1,
}) => RecordDBCell(
  uuid: uuid,
  parentUUID: parentUUID,
  recordDate: date.epochDay,
  recordType: status.dbCode,
  recordValue: value,
);

void main() {
  tearDown(() {
    AppClock().setClock(const Clock(systemTime));
  });

  group('HabitSummaryDataCollection sorting', () {
    test('sortDataByName uses newer start date as tie breaker', () {
      final collection = _buildCollection([
        _buildHabitSummaryData(
          uuid: 'alpha-older',
          name: 'Alpha',
          startDate: _date(1, 1),
        ),
        _buildHabitSummaryData(
          uuid: 'alpha-newer',
          name: 'Alpha',
          startDate: _date(1, 3),
        ),
        _buildHabitSummaryData(
          uuid: 'zulu',
          name: 'Zulu',
          startDate: _date(1, 2),
        ),
      ]);

      expect(_uuids(collection.sortDataByName(HabitDisplaySortDirection.asc)), [
        'alpha-newer',
        'alpha-older',
        'zulu',
      ]);
      expect(
        _uuids(collection.sortDataByName(HabitDisplaySortDirection.desc)),
        ['zulu', 'alpha-older', 'alpha-newer'],
      );
    });

    test('sortDataByManual uses sort position then create time', () {
      final collection = _buildCollection([
        _buildHabitSummaryData(
          uuid: 'late-manual',
          name: 'Late Manual',
          sortPostion: 2,
          createTime: DateTime.utc(2026, 1, 3),
        ),
        _buildHabitSummaryData(
          uuid: 'manual-newer',
          name: 'Manual Newer',
          sortPostion: 1,
          createTime: DateTime.utc(2026, 1, 2),
        ),
        _buildHabitSummaryData(
          uuid: 'manual-older',
          name: 'Manual Older',
          sortPostion: 1,
          createTime: DateTime.utc(2026, 1, 1),
        ),
      ]);

      expect(_uuids(collection.sortDataByManual()), [
        'manual-older',
        'manual-newer',
        'late-manual',
      ]);
    });

    test('sortDataByProgress orders by progress and then start date', () {
      _setNow(DateTime.utc(2026, 1, 2));
      final collection = _buildCollection([
        _buildHabitSummaryData(
          uuid: 'stalled-newer',
          name: 'Stalled Newer',
          startDate: _date(1, 2),
          recalculate: true,
        ),
        _buildHabitSummaryData(
          uuid: 'stalled-older',
          name: 'Stalled Older',
          startDate: _date(1, 1),
          recalculate: true,
        ),
        _buildHabitSummaryData(
          uuid: 'complete',
          name: 'Complete',
          startDate: _date(1, 2),
          records: [_buildRecord(uuid: 'record-1', month: 1, day: 2)],
          recalculate: true,
        ),
      ]);

      expect(
        _uuids(collection.sortDataByProgress(HabitDisplaySortDirection.asc)),
        ['complete', 'stalled-newer', 'stalled-older'],
      );
      expect(
        _uuids(collection.sortDataByProgress(HabitDisplaySortDirection.desc)),
        ['stalled-older', 'stalled-newer', 'complete'],
      );
    });

    test('sortDataBySatus keeps activated habits first', () {
      final collection = _buildCollection([
        _buildHabitSummaryData(
          uuid: 'activated-older',
          name: 'Activated Older',
          status: HabitStatus.activated,
          startDate: _date(1, 1),
        ),
        _buildHabitSummaryData(
          uuid: 'deleted',
          name: 'Deleted',
          status: HabitStatus.deleted,
          startDate: _date(1, 2),
        ),
        _buildHabitSummaryData(
          uuid: 'archived',
          name: 'Archived',
          status: HabitStatus.archived,
          startDate: _date(1, 4),
        ),
        _buildHabitSummaryData(
          uuid: 'activated-newer',
          name: 'Activated Newer',
          status: HabitStatus.activated,
          startDate: _date(1, 3),
        ),
      ]);

      expect(
        _uuids(collection.sortDataBySatus(HabitDisplaySortDirection.asc)),
        ['activated-newer', 'activated-older', 'archived', 'deleted'],
      );
      expect(
        _uuids(collection.sortDataBySatus(HabitDisplaySortDirection.desc)),
        ['deleted', 'archived', 'activated-older', 'activated-newer'],
      );
    });

    test('sort dispatches color and start-date strategies', () {
      final collection = _buildCollection([
        _buildHabitSummaryData(
          uuid: 'older-cc1',
          name: 'Older CC1',
          colorType: HabitColorType.cc1,
          startDate: _date(1, 1),
        ),
        _buildHabitSummaryData(
          uuid: 'newer-cc1',
          name: 'Newer CC1',
          colorType: HabitColorType.cc1,
          startDate: _date(1, 3),
        ),
        _buildHabitSummaryData(
          uuid: 'cc2',
          name: 'CC2',
          colorType: HabitColorType.cc2,
          startDate: _date(1, 2),
        ),
      ]);

      expect(
        _uuids(
          collection.sort(
            HabitDisplaySortType.colorType,
            HabitDisplaySortDirection.asc,
          ),
        ),
        ['newer-cc1', 'older-cc1', 'cc2'],
      );
      expect(
        _uuids(
          collection.sort(
            HabitDisplaySortType.startT,
            HabitDisplaySortDirection.desc,
          ),
        ),
        ['newer-cc1', 'cc2', 'older-cc1'],
      );
    });
  });

  group('HabitSummaryDataCollection mutation and materialization', () {
    test('addNewHabit rejects duplicates unless forceAdd is true', () {
      final collection = HabitSummaryDataCollection();
      final original = _buildHabitSummaryData(
        uuid: 'habit-1',
        name: 'Original Habit',
      );
      final replacement = _buildHabitSummaryData(
        uuid: 'habit-1',
        name: 'Replacement Habit',
      );

      expect(collection.addNewHabit(original), isTrue);
      expect(collection.addNewHabit(replacement), isFalse);
      expect(collection.length, 1);
      expect(collection.getHabitByUUID(original.uuid), same(original));

      expect(collection.addNewHabit(replacement, forceAdd: true), isTrue);
      expect(collection.length, 1);
      expect(collection.getHabitByUUID(original.uuid), same(replacement));
    });

    test('removeHabitByUUID updates lookup and containment state', () {
      final collection = HabitSummaryDataCollection();
      final habit = _buildHabitSummaryData(uuid: 'habit-1', name: 'Habit');

      collection.addNewHabit(habit);

      expect(collection.containsHabitUUID(habit.uuid), isTrue);
      expect(collection.removeHabitByUUID(habit.uuid), same(habit));
      expect(collection.removeHabitByUUID(habit.uuid), isNull);
      expect(collection.containsHabitUUID(habit.uuid), isFalse);
      expect(collection.getHabitByUUID(habit.uuid), isNull);
    });

    test(
      'fromDBQueryResult keeps valid records and ignores orphan or pre-start-date records',
      () {
        final collection = HabitSummaryDataCollection.fromDBQueryResult(
          [_buildHabitDBCell(uuid: 'habit-1', startDate: _date(1, 10))],
          [
            _buildRecordDBCell(
              uuid: 'record-before-start',
              parentUUID: 'habit-1',
              date: _date(1, 9),
            ),
            _buildRecordDBCell(
              uuid: 'record-valid',
              parentUUID: 'habit-1',
              date: _date(1, 12),
            ),
            _buildRecordDBCell(
              uuid: 'record-orphan',
              parentUUID: 'habit-missing',
              date: _date(1, 12),
            ),
          ],
        );

        final loaded = collection.getHabitByUUID('habit-1');

        expect(collection.length, 1);
        expect(loaded, isNotNull);
        expect(loaded!.recordsNum, 1);
        expect(loaded.getRecordByUUID('record-valid')?.date, _date(1, 12));
        expect(loaded.getRecordByUUID('record-before-start'), isNull);
        expect(loaded.getRecordByUUID('record-orphan'), isNull);
      },
    );
  });

  group('HabitSummaryData derived state', () {
    test('habitOkValue uses extra goal only for negative habits', () {
      final positive = _buildHabitSummaryData(
        uuid: 'positive',
        name: 'Positive Habit',
      );
      final negative = _buildHabitSummaryData(
        uuid: 'negative',
        name: 'Negative Habit',
        type: HabitType.negative,
        dailyGoal: 1,
        dailyGoalExtra: 3,
      );

      expect(positive.habitOkValue, 1);
      expect(negative.habitOkValue, 3);
    });

    test(
      'status helpers distinguish active archived deleted and completed states',
      () {
        _setNow(DateTime.utc(2026, 1, 1));
        final inProgress = _buildHabitSummaryData(
          uuid: 'in-progress',
          name: 'In Progress',
          startDate: _date(1, 1),
        )..reCalculateAutoComplateRecords(firstDay: DateTime.monday);
        final completed = _buildHabitSummaryData(
          uuid: 'completed',
          name: 'Completed',
          startDate: _date(1, 1),
          records: [_buildRecord(uuid: 'record-1', month: 1, day: 1)],
          recalculate: true,
        );
        final archived = _buildHabitSummaryData(
          uuid: 'archived',
          name: 'Archived',
          status: HabitStatus.archived,
        );
        final deleted = _buildHabitSummaryData(
          uuid: 'deleted',
          name: 'Deleted',
          status: HabitStatus.deleted,
        );

        expect(inProgress.isActived, isTrue);
        expect(inProgress.isInProgress, isTrue);
        expect(inProgress.isComplated, isFalse);

        expect(completed.isComplated, isTrue);
        expect(completed.isInProgress, isFalse);

        expect(archived.isArchived, isTrue);
        expect(archived.isActived, isFalse);
        expect(archived.isDeleted, isFalse);

        expect(deleted.isDeleted, isTrue);
        expect(deleted.isActived, isFalse);
        expect(deleted.isArchived, isFalse);
      },
    );
  });

  group('HabitSummary value objects', () {
    test('HabitSummaryDataSortCache compares entries by uuid', () {
      final habit = _buildHabitSummaryData(uuid: 'cache-1', name: 'Cache');
      final sameUuid = _buildHabitSummaryData(
        uuid: 'cache-1',
        name: 'Same UUID',
      );
      final otherHabit = _buildHabitSummaryData(
        uuid: 'cache-2',
        name: 'Other Habit',
      );
      final cache = HabitSummaryDataSortCache(data: habit);

      expect(cache.data, same(habit));
      expect(
        cache.isSameItem(HabitSummaryDataSortCache(data: sameUuid)),
        isTrue,
      );
      expect(
        cache.isSameItem(HabitSummaryDataSortCache(data: otherHabit)),
        isFalse,
      );
      expect(cache.isSameItem(null), isFalse);
      expect(cache.isSameContent(null), isFalse);
    });

    test('HabitSummaryStatusCache equality includes search mode', () {
      const base = HabitSummaryStatusCache(
        isAppbarPinned: true,
        loadId: 1,
        isClandarExpanded: false,
        isInEditMode: true,
        isInSearchMode: false,
      );
      const same = HabitSummaryStatusCache(
        isAppbarPinned: true,
        loadId: 1,
        isClandarExpanded: false,
        isInEditMode: true,
        isInSearchMode: false,
      );
      const differentSearchMode = HabitSummaryStatusCache(
        isAppbarPinned: true,
        loadId: 1,
        isClandarExpanded: false,
        isInEditMode: true,
        isInSearchMode: true,
      );

      expect(base, same);
      expect(base.hashCode, same.hashCode);
      expect(base == differentSearchMode, isFalse);
    });
  });
}
