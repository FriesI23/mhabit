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
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
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
}) => HabitSummaryRecord(uuid, _date(month, day), HabitRecordStatus.done, 1);

HabitSummaryData _buildHabit({
  required String uuid,
  required String name,
  HabitStatus status = HabitStatus.activated,
  HabitDate? startDate,
  Iterable<HabitSummaryRecord> records = const [],
  bool recalculate = false,
}) {
  final effectiveStartDate = startDate ?? _date(1, 1);
  final data = HabitSummaryData(
    id: uuid.hashCode,
    uuid: uuid,
    type: HabitType.normal,
    name: name,
    desc: '',
    colorType: HabitColorType.cc1,
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: effectiveStartDate,
    status: status,
    sortPostion: 1,
    createTime: DateTime.utc(2026, 1, 1),
  );
  data.initRecords(records);
  if (recalculate) {
    data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);
  }
  return data;
}

void main() {
  group('Habit display enum DB code lookups', () {
    test('return matching values for known DB codes', () {
      expect(
        HabitDisplaySortType.getFromDBCode(1),
        HabitDisplaySortType.manual,
      );
      expect(
        HabitDisplaySortDirection.getFromDBCode(2),
        HabitDisplaySortDirection.desc,
      );
    });

    test('return provided defaults for unknown DB codes', () {
      expect(
        HabitDisplaySortType.getFromDBCode(
          99,
          withDefault: HabitDisplaySortType.progress,
        ),
        HabitDisplaySortType.progress,
      );
      expect(
        HabitDisplaySortDirection.getFromDBCode(
          99,
          withDefault: HabitDisplaySortDirection.desc,
        ),
        HabitDisplaySortDirection.desc,
      );
    });
  });

  group('HabitsDisplayFilter.displayFilterFunction', () {
    setUp(() {
      _setNow(DateTime.utc(2026, 1, 1));
    });

    tearDown(() {
      AppClock().setClock(const Clock(systemTime));
    });

    test('returns false for archived and in-progress habits when disabled', () {
      const filter = HabitsDisplayFilter(
        allowInProgressHabits: false,
        allowArchivedHabits: false,
        allowCompleteHabits: true,
      );
      final archived = _buildHabit(
        uuid: 'archived',
        name: 'Archived Habit',
        status: HabitStatus.archived,
      );
      final inProgress = _buildHabit(
        uuid: 'in-progress',
        name: 'In Progress Habit',
        startDate: _date(1, 1),
      )..reCalculateAutoComplateRecords(firstDay: DateTime.monday);

      final displayFilter = filter.displayFilterFunction;

      expect(displayFilter(archived), isFalse);
      expect(displayFilter(inProgress), isFalse);
    });

    test('returns true for completed and archived habits when enabled', () {
      const filter = HabitsDisplayFilter(
        allowInProgressHabits: false,
        allowArchivedHabits: true,
        allowCompleteHabits: true,
      );
      final archived = _buildHabit(
        uuid: 'archived',
        name: 'Archived Habit',
        status: HabitStatus.archived,
      );
      final completed = _buildHabit(
        uuid: 'completed',
        name: 'Completed Habit',
        startDate: _date(1, 1),
        records: [_buildRecord(uuid: 'record-1', month: 1, day: 1)],
        recalculate: true,
      );

      final displayFilter = filter.displayFilterFunction;

      expect(displayFilter(archived), isTrue);
      expect(displayFilter(completed), isTrue);
    });

    test(
      'keeps deleted habits visible as fallback even when all flags are off',
      () {
        const filter = HabitsDisplayFilter.allFalse;
        final deleted = _buildHabit(
          uuid: 'deleted',
          name: 'Deleted Habit',
          status: HabitStatus.deleted,
        );

        expect(filter.displayFilterFunction(deleted), isTrue);
      },
    );
  });
}
