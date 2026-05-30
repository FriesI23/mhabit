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
import 'package:mhabit/utils/app_clock.dart';
import 'package:quiver/time.dart';

HabitDate _date(int month, int day) => HabitDate(2026, month, day);

void _setNow(DateTime now) {
  AppClock().setClock(Clock(() => now));
}

HabitSummaryData _buildHabitSummaryData({
  HabitFrequency frequency = HabitFrequency.daily,
  HabitDate? startDate,
}) {
  final effectiveStartDate = startDate ?? _date(1, 1);
  return HabitSummaryData(
    id: effectiveStartDate.hashCode,
    uuid: '${effectiveStartDate.month}-${effectiveStartDate.day}',
    type: HabitType.normal,
    name: 'Sample Habit',
    desc: '',
    colorType: HabitColorType.cc1,
    dailyGoal: 1,
    targetDays: 1,
    frequency: frequency,
    startDate: effectiveStartDate,
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(
      effectiveStartDate.year,
      effectiveStartDate.month,
      effectiveStartDate.day,
    ),
  );
}

HabitSummaryRecord _buildRecord({
  required String uuid,
  required int month,
  required int day,
  HabitRecordStatus status = HabitRecordStatus.done,
  num value = 1,
}) => HabitSummaryRecord(uuid, _date(month, day), status, value);

List<HabitDate> _autoMarkedDates(HabitSummaryData data) =>
    data.getAllAutoComplateRecordDate().toList();

void main() {
  group('HabitSummaryData auto-complete', () {
    tearDown(() {
      AppClock().setClock(const Clock(systemTime));
    });

    test('daily frequency never creates auto-complete records', () {
      _setNow(DateTime.utc(2026, 1, 20));
      final data = _buildHabitSummaryData()
        ..addRecord(_buildRecord(uuid: 'record-1', month: 1, day: 10));

      data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

      expect(_autoMarkedDates(data), isEmpty);
      expect(data.isRecordAutoComplated(_date(1, 10)), isFalse);
      expect(data.getFirstUnTrackedDate(), _date(1, 11));
    });

    test('weekly frequency marks the full qualifying week', () {
      _setNow(DateTime.utc(2026, 1, 20));
      final data =
          _buildHabitSummaryData(
            frequency: const HabitFrequency.weekly(freq: 2),
          )..initRecords([
            _buildRecord(uuid: 'record-1', month: 1, day: 6),
            _buildRecord(uuid: 'record-2', month: 1, day: 8),
          ]);

      data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

      expect(_autoMarkedDates(data), [
        for (var day = 5; day <= 11; day++) _date(1, day),
      ]);
      expect(data.isRecordAutoComplated(_date(1, 9)), isTrue);
    });

    test(
      'weekly frequency ignores non-qualifying and future records when frequency is not met',
      () {
        _setNow(DateTime.utc(2026, 1, 20));
        final data =
            _buildHabitSummaryData(
              frequency: const HabitFrequency.weekly(freq: 2),
            )..initRecords([
              _buildRecord(uuid: 'record-1', month: 1, day: 6),
              _buildRecord(
                uuid: 'record-2',
                month: 1,
                day: 8,
                status: HabitRecordStatus.skip,
              ),
              _buildRecord(uuid: 'record-3', month: 1, day: 27),
            ]);

        data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

        expect(_autoMarkedDates(data), isEmpty);
        expect(data.isRecordAutoComplated(_date(1, 9)), isFalse);
      },
    );

    test(
      'monthly frequency marks the full qualifying month after start date',
      () {
        _setNow(DateTime.utc(2026, 2, 20));
        final data =
            _buildHabitSummaryData(
              frequency: const HabitFrequency.monthly(freq: 2),
              startDate: _date(1, 15),
            )..initRecords([
              _buildRecord(uuid: 'record-1', month: 1, day: 16),
              _buildRecord(uuid: 'record-2', month: 1, day: 28),
            ]);

        data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

        expect(_autoMarkedDates(data), [
          for (var day = 15; day <= 31; day++) _date(1, day),
        ]);
      },
    );

    test(
      'monthly frequency does not mark when qualifying records are insufficient',
      () {
        _setNow(DateTime.utc(2026, 2, 20));
        final data =
            _buildHabitSummaryData(
              frequency: const HabitFrequency.monthly(freq: 2),
              startDate: _date(1, 15),
            )..initRecords([
              _buildRecord(uuid: 'record-1', month: 1, day: 16),
              _buildRecord(
                uuid: 'record-2',
                month: 1,
                day: 28,
                status: HabitRecordStatus.skip,
              ),
            ]);

        data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

        expect(_autoMarkedDates(data), isEmpty);
        expect(data.isRecordAutoComplated(_date(1, 20)), isFalse);
      },
    );

    test('custom frequency extends the marking window within bounds', () {
      _setNow(DateTime.utc(2026, 1, 20));
      final data =
          _buildHabitSummaryData(
            frequency: HabitFrequency.custom(days: 4, freq: 2),
            startDate: _date(1, 10),
          )..initRecords([
            _buildRecord(uuid: 'record-1', month: 1, day: 10),
            _buildRecord(uuid: 'record-2', month: 1, day: 12),
          ]);

      data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

      expect(_autoMarkedDates(data), [
        for (var day = 10; day <= 13; day++) _date(1, day),
      ]);
      expect(data.getFirstUnTrackedDate(), _date(1, 14));
    });

    test(
      'custom frequency does not mark records outside the allowed window',
      () {
        _setNow(DateTime.utc(2026, 1, 20));
        final data =
            _buildHabitSummaryData(
              frequency: HabitFrequency.custom(days: 4, freq: 2),
              startDate: _date(1, 10),
            )..initRecords([
              _buildRecord(uuid: 'record-1', month: 1, day: 10),
              _buildRecord(uuid: 'record-2', month: 1, day: 15),
            ]);

        data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

        expect(_autoMarkedDates(data), isEmpty);
        expect(data.isRecordAutoComplated(_date(1, 12)), isFalse);
      },
    );

    test('getFirstUnTrackedDate returns today when there are no records', () {
      _setNow(DateTime.utc(2026, 1, 20));
      final data = _buildHabitSummaryData();

      expect(data.getFirstUnTrackedDate(), _date(1, 20));
    });

    test(
      'getFirstUnTrackedDate follows the last explicit record when there are no auto marks',
      () {
        _setNow(DateTime.utc(2026, 1, 20));
        final data = _buildHabitSummaryData()
          ..addRecord(_buildRecord(uuid: 'record-1', month: 1, day: 12));

        expect(data.getFirstUnTrackedDate(), _date(1, 13));
      },
    );

    test(
      'getFirstUnTrackedDate follows the latest explicit record when it is later than auto marks',
      () {
        _setNow(DateTime.utc(2026, 1, 20));
        final data =
            _buildHabitSummaryData(
              frequency: HabitFrequency.custom(days: 4, freq: 2),
              startDate: _date(1, 10),
            )..initRecords([
              _buildRecord(uuid: 'record-1', month: 1, day: 10),
              _buildRecord(uuid: 'record-2', month: 1, day: 12),
              _buildRecord(
                uuid: 'record-3',
                month: 1,
                day: 20,
                status: HabitRecordStatus.skip,
              ),
            ]);

        data.reCalculateAutoComplateRecords(firstDay: DateTime.monday);

        expect(_autoMarkedDates(data), [
          for (var day = 10; day <= 13; day++) _date(1, day),
        ]);
        expect(data.getFirstUnTrackedDate(), _date(1, 21));
      },
    );
  });
}
