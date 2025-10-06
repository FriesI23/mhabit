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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_reminder.dart';

void main() {
  group("Test HabitReminder getNextRemindDate Per Month", () {
    late HabitReminder habitReminder;

    setUp(() {
      habitReminder = HabitReminder.monthly(
        time: const TimeOfDay(hour: 8, minute: 0),
        extra: [5, 10, 20],
      );
    });

    test('Next remind date after current date with 5th, 10th, and 20th extra',
        () {
      final crtDate = DateTime(2022, 1, 2, 0, 0); // Jan 2, 2022
      final expectedDate = DateTime(2022, 1, 5, 8, 0); // Jan 5, 2022, 8am
      final actualDate = habitReminder.getNextRemindDate(crtDate: crtDate);
      expect(actualDate, expectedDate);
    });

    test('Next remind date after current date with 20th extra only', () {
      final crtDate = DateTime(2023, 3, 15, 9, 0); // Mar 15, 2023, 9am
      final expectedDate = DateTime(2023, 3, 20, 8, 0); // Mar 20, 2023, 8am
      final actualDate = habitReminder.getNextRemindDate(crtDate: crtDate);
      expect(actualDate, expectedDate);
    });

    test('Next remind date after current date with no extra', () {
      final habitReminder = HabitReminder.monthly(
        time: const TimeOfDay(hour: 12, minute: 0),
        extra: [],
      );
      final crtDate = DateTime(2023, 4, 7, 13, 0); // Apr 7, 2023, 1pm
      final actualDate = habitReminder.getNextRemindDate(crtDate: crtDate);
      expect(actualDate, null);
    });

    test(
        'Next remind date after current date '
        'is the same day as current date', () {
      final habitReminder = HabitReminder.monthly(
        time: const TimeOfDay(hour: 7, minute: 0),
        extra: [7],
      );
      final crtDate = DateTime(2023, 5, 7, 8, 0); // May 7, 2023, 8am
      final expectedDate = DateTime(2023, 6, 7, 7, 0); // Jun 7, 2023, 7am
      final actualDate = habitReminder.getNextRemindDate(crtDate: crtDate);
      expect(actualDate, expectedDate);
    });

    test(
        'Creating HabitReminder with invalid extra day '
        'should throw assertion error [<=0]', () {
      expect(
        () => HabitReminder.monthly(
          time: const TimeOfDay(hour: 12, minute: 0),
          extra: [0, 31],
        ),
        throwsAssertionError,
      );
    });

    test(
        'Creating HabitReminder with invalid extra day '
        'should throw assertion error [>31]', () {
      expect(
        () => HabitReminder.monthly(
          time: const TimeOfDay(hour: 12, minute: 0),
          extra: [1, 32],
        ),
        throwsAssertionError,
      );
    });
  });

  group('Test HabitReminder getNextRemindDate Per Week', () {
    test('weekly reminder without extra days', () {
      final reminder = HabitReminder.weekly(
          time: const TimeOfDay(hour: 8, minute: 0), extra: []);
      final nextDate =
          reminder.getNextRemindDate(crtDate: DateTime(2023, 4, 7));
      expect(nextDate, isNull);
    });

    test('weekly reminder with extra days', () {
      final reminder = HabitReminder.weekly(
        time: const TimeOfDay(hour: 8, minute: 0),
        extra: [1, 3, 5],
      ); // Monday, Wednesday, Friday
      final nextDate =
          reminder.getNextRemindDate(crtDate: DateTime(2023, 4, 7, 0, 0));
      expect(nextDate, DateTime(2023, 4, 7, 8, 0)); // Monday
    });

    test('weekly reminder with extra days, time passed', () {
      final reminder = HabitReminder.weekly(
        time: const TimeOfDay(hour: 8, minute: 0),
        extra: [1, 3, 5],
      ); // Monday, Wednesday, Friday
      final nextDate = reminder.getNextRemindDate(
          crtDate: DateTime(2023, 4, 7, 10, 0)); // Time passed 2 hours
      expect(nextDate, DateTime(2023, 4, 10, 8, 0)); // Monday
    });

    test('weekly reminder with extra days, same day', () {
      final reminder = HabitReminder.weekly(
        time: const TimeOfDay(hour: 8, minute: 0),
        extra: [1, 3, 5, 7],
      ); // Monday, Wednesday, Friday, Sunday
      final nextDate = reminder.getNextRemindDate(
          crtDate: DateTime(2023, 4, 9, 7, 0)); // Sunday
      expect(nextDate, DateTime(2023, 4, 9, 8, 0)); // Same day, Sunday
    });

    test('weekly reminder with extra days, same day after time', () {
      final reminder = HabitReminder.weekly(
        time: const TimeOfDay(hour: 8, minute: 0),
        extra: [1, 3, 5, 7],
      ); // Monday, Wednesday, Friday
      final nextDate = reminder.getNextRemindDate(
          crtDate: DateTime(2023, 4, 9, 9, 0)); // Sunday
      expect(nextDate, DateTime(2023, 4, 10, 8, 0)); // Next Monday
    });

    test('weekly reminder with invalid extra day [<=0]', () {
      expect(
          () => HabitReminder.weekly(
              time: const TimeOfDay(hour: 8, minute: 0), extra: [0]),
          throwsAssertionError); // Sunday is not valid
    });

    test('weekly reminder with invalid extra day [>7]', () {
      expect(
          () => HabitReminder.weekly(
              time: const TimeOfDay(hour: 8, minute: 0), extra: [8]),
          throwsAssertionError); // Sunday is not valid
    });
  });

  group('Test HabitReminder getNextRemindDate Daily', () {
    test('daily reminder should return next date', () {
      const reminder = HabitReminder.daily(time: TimeOfDay(hour: 9, minute: 0));
      final today = DateTime(2022, 1, 1, 18);
      final nextRemindDate = reminder.getNextRemindDate(crtDate: today);
      final expectedDate = DateTime(today.year, today.month, today.day, 9, 0)
          .add(const Duration(days: 1));
      expect(nextRemindDate, equals(expectedDate));
    });

    test('daily reminder should return next date with extra field', () {
      const reminder =
          HabitReminder.daily(time: TimeOfDay(hour: 12, minute: 30));
      final today = DateTime.now().copyWith(hour: 12, minute: 40);
      final nextRemindDate = reminder.getNextRemindDate(crtDate: today);
      final expectedDate = DateTime(today.year, today.month, today.day, 12, 30)
          .add(const Duration(days: 1));
      expect(nextRemindDate, equals(expectedDate));
    });

    test('daily reminder should return today date if time has not passed', () {
      const reminder =
          HabitReminder.daily(time: TimeOfDay(hour: 13, minute: 0));
      final today = DateTime.now().copyWith(hour: 12, minute: 50);
      final nextRemindDate = reminder.getNextRemindDate(crtDate: today);
      final expectedDate = DateTime(today.year, today.month, today.day, 13, 0);
      expect(nextRemindDate, equals(expectedDate));
    });

    test('daily reminder should return tomorrow date if time has passed', () {
      const reminder = HabitReminder.daily(time: TimeOfDay(hour: 8, minute: 0));
      final today = DateTime(2022, 1, 1, 18);
      final nextRemindDate = reminder.getNextRemindDate(crtDate: today);
      final expectedDate = DateTime(today.year, today.month, today.day, 8, 0)
          .add(const Duration(days: 1));
      expect(nextRemindDate, equals(expectedDate));
    });
  });

  group('Test HabitReminder getNextRemindDate when Needed', () {
    test('getNextRemindDateWithNeeded should return the correct date', () {
      const reminder =
          HabitReminder.whenNeeded(time: TimeOfDay(hour: 8, minute: 30));
      final lastUntrackDate = HabitDate(2023, 4, 4);

      final today = DateTime(2023, 4, 7);
      final nextRemindDate = reminder.getNextRemindDate(
          crtDate: today, lastUntrackDate: lastUntrackDate);
      expect(nextRemindDate, DateTime(2023, 4, 7, 8, 30));

      final tomorrow = DateTime(2023, 4, 8);
      final nextRemindDate2 = reminder.getNextRemindDate(
          crtDate: tomorrow, lastUntrackDate: lastUntrackDate);
      expect(nextRemindDate2, DateTime(2023, 4, 8, 8, 30));

      final lastUntrackDate2 = HabitDate(2023, 4, 6);
      final nextRemindDate3 = reminder.getNextRemindDate(
          crtDate: today, lastUntrackDate: lastUntrackDate2);
      expect(nextRemindDate3, DateTime(2023, 4, 7, 8, 30));

      final today2 = DateTime(2023, 4, 7, 10, 30);
      final lastUntrackDate3 = HabitDate(2023, 4, 6);
      final nextRemindDate4 = reminder.getNextRemindDate(
          crtDate: today2, lastUntrackDate: lastUntrackDate3);
      expect(nextRemindDate4, DateTime(2023, 4, 8, 8, 30));
    });

    test('whenNeeded reminder should have correct type and extra data', () {
      const reminder =
          HabitReminder.whenNeeded(time: TimeOfDay(hour: 12, minute: 0));
      expect(reminder.type, HabitReminderType.whenNeeded);
      expect(reminder.extra, []);
    });

    test(
        'getNextRemindDateWithNeeded should return null '
        'when lastUntrackDate is null', () {
      const reminder =
          HabitReminder.whenNeeded(time: TimeOfDay(hour: 8, minute: 30));
      final today = DateTime(2023, 4, 7);
      expect(
        () => reminder.getNextRemindDate(crtDate: today, lastUntrackDate: null),
        throwsAssertionError,
      );
    });

    test(
        'getNextRemindDateWithNeeded should handle lastUntrackDate '
        'and current date with different timezones', () {
      const reminder =
          HabitReminder.whenNeeded(time: TimeOfDay(hour: 10, minute: 0));
      final lastUntrackDate = HabitDate(2023, 4, 7); // UTC-04:00
      final today = DateTime(2023, 4, 8, 2, 0); // UTC+02:00
      final nextRemindDate = reminder.getNextRemindDate(
          crtDate: today, lastUntrackDate: lastUntrackDate);
      expect(nextRemindDate, DateTime(2023, 4, 8, 10, 0)); // UTC+02:00
    });
  });
}
