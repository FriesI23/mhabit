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

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../annotation/_json_annotation.dart';
import '../common/enums.dart';
import '../common/utils.dart';
import '../extension/datetime_extensions.dart';
import '../l10n/localizations.dart';
import 'common.dart';
import 'habit_date.dart';

part 'habit_reminder.g.dart';

@JsonEnum(valueField: 'code')
enum HabitReminderType implements EnumWithDBCodeABC<HabitReminderType> {
  unknown(code: 0),
  whenNeeded(code: 1),
  day(code: 2),
  week(code: 3),
  month(code: 4);

  final int code;

  const HabitReminderType({required this.code});

  @override
  int get dbCode => code;
}

@JsonSerializable()
@CopyWith(skipFields: true)
class HabitReminder implements JsonAdaptor {
  static const weeklyExtraAll = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];
  static const monthlyExtraAll = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
  ];

  static const dailyMidnight =
      HabitReminder.daily(time: TimeOfDay(hour: 0, minute: 0));

  final HabitReminderType type;
  @TimeOfDayConverter()
  final TimeOfDay time;
  final List<int> extra;

  const HabitReminder(
      {required this.type, required this.extra, required this.time});

  const HabitReminder.daily({required this.time})
      : type = HabitReminderType.day,
        extra = const [];

  const HabitReminder.whenNeeded({required this.time})
      : type = HabitReminderType.whenNeeded,
        extra = const [];

  factory HabitReminder.weekly({required TimeOfDay time, List<int>? extra}) {
    if (extra != null) assert(!extra.any((e) => e <= 0 || e > 7));
    return HabitReminder(
      type: HabitReminderType.week,
      time: time,
      extra: extra ?? weeklyExtraAll,
    );
  }

  factory HabitReminder.monthly({required TimeOfDay time, List<int>? extra}) {
    if (extra != null) assert(!extra.any((e) => e <= 0 || e > 31));
    return HabitReminder(
      type: HabitReminderType.month,
      time: time,
      extra: extra ?? monthlyExtraAll,
    );
  }

  factory HabitReminder.fromJson(Map<String, dynamic> json) =>
      _$HabitReminderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HabitReminderToJson(this);

  String getReminderTypeHelperText(L10n? l10n) {
    if (l10n == null) return '';
    switch (type) {
      case HabitReminderType.unknown:
        return '';
      case HabitReminderType.whenNeeded:
        return l10n.habitEdit_reminder_dialogType_whenNeeded;
      case HabitReminderType.day:
        return l10n.habitEdit_reminder_dialogType_daily;
      case HabitReminderType.week:
        if (extra.length >= weeklyExtraAll.length) {
          return l10n.habitEdit_reminder_freq_weekHelpText;
        } else {
          return [
            l10n.habitEdit_reminder_freq_weekPrefixText,
            extra
                .sorted((a, b) => a.compareTo(b))
                .map((e) => l10n.getHabitEditReminderWeekDayText(e))
                .join(', '),
            l10n.habitEdit_reminder_freq_weekSubfixText,
          ].join();
        }
      case HabitReminderType.month:
        if (extra.length >= monthlyExtraAll.length) {
          return l10n.habitEdit_reminder_freq_monthHelpText;
        } else {
          return [
            l10n.habitEdit_reminder_freq_monthPrefixText,
            getContinuousRanges(extra.sorted((a, b) => a.compareTo(b)))
                .map((e) {
              if (e.item1 == e.item2) {
                return e.item1.toString();
              } else {
                return "${e.item1}-${e.item2}";
              }
            }).join(', '),
            l10n.habitEdit_reminder_freq_monthSubfixText,
          ].join();
        }
    }
  }

  String getReminderTypeText(L10n? l10n) =>
      getReminderTypeTextByType(type, l10n: l10n);

  static String getReminderTypeTextByType(HabitReminderType type,
      {L10n? l10n}) {
    if (l10n == null) return '';
    switch (type) {
      case HabitReminderType.whenNeeded:
        return l10n.habitEdit_reminder_dialogType_whenNeeded;
      case HabitReminderType.day:
        return l10n.habitEdit_reminder_dialogType_daily;
      case HabitReminderType.week:
        return l10n.habitEdit_reminder_dialogType_week;
      case HabitReminderType.month:
        return l10n.habitEdit_reminder_dialogType_month;
      case HabitReminderType.unknown:
        return '';
    }
  }

  DateTime? getNextRemindDate({DateTime? crtDate, HabitDate? lastUntrackDate}) {
    crtDate = crtDate ?? DateTime.now();
    switch (type) {
      case HabitReminderType.unknown:
        return null;
      case HabitReminderType.whenNeeded:
        return _getNextRemindDateWithNeeded(crtDate, lastUntrackDate);
      case HabitReminderType.day:
        return _getNextRemindDateByDay(crtDate);
      case HabitReminderType.week:
        return _getNextRemindDateByWeek(crtDate);
      case HabitReminderType.month:
        return _getNextRemindDateByMonth(crtDate);
    }
  }

  DateTime? _getNextRemindDateWithNeeded(
      DateTime crtDate, HabitDate? lastUntrackDate) {
    if (kDebugMode) assert(lastUntrackDate != null);
    if (lastUntrackDate == null) return null;
    final lastUntrackRemindDate = DateTime(lastUntrackDate.year,
        lastUntrackDate.month, lastUntrackDate.day, time.hour, time.minute);
    final crtRemindDate = DateTime(
        crtDate.year, crtDate.month, crtDate.day, time.hour, time.minute);
    final nextRemindDate = lastUntrackRemindDate > crtRemindDate
        ? lastUntrackRemindDate
        : crtRemindDate;
    return nextRemindDate <= crtDate
        ? nextRemindDate.add(const Duration(days: 1))
        : nextRemindDate;
  }

  DateTime? _getNextRemindDateByDay(DateTime crtDate) {
    final crtRemindDate = DateTime(
        crtDate.year, crtDate.month, crtDate.day, time.hour, time.minute);
    return crtRemindDate <= crtDate
        ? crtRemindDate.add(const Duration(days: 1))
        : crtRemindDate;
  }

  DateTime? _getNextRemindDateByWeek(DateTime crtDate) {
    DateTime? result;
    if (extra.isEmpty) return result;

    final crtRemindDate = DateTime(
        crtDate.year, crtDate.month, crtDate.day, time.hour, time.minute);
    for (var wd in extra) {
      final DateTime nextDate;
      if (wd != crtDate.weekday) {
        nextDate = crtRemindDate.next(wd);
      } else {
        nextDate =
            crtRemindDate <= crtDate ? crtRemindDate.next(wd) : crtRemindDate;
      }
      if (result == null ||
          result.difference(crtDate).abs() >
              nextDate.difference(crtDate).abs()) {
        result = nextDate;
        if (result == crtRemindDate) break;
      }
    }
    return result;
  }

  DateTime? _getNextRemindDateByMonth(DateTime crtDate) {
    DateTime? result;
    if (extra.isEmpty) return result;

    final crtRemindDate = DateTime(
        crtDate.year, crtDate.month, crtDate.day, time.hour, time.minute);
    for (var d in extra) {
      final DateTime nextDate;
      if (d < crtDate.day) {
        nextDate = crtRemindDate.copyWith(month: crtDate.month + 1, day: d);
      } else if (d > crtDate.day) {
        nextDate = crtRemindDate.copyWith(day: d);
      } else {
        nextDate = crtRemindDate <= crtDate
            ? crtRemindDate.copyWith(month: crtDate.month + 1)
            : crtRemindDate;
      }
      if (result == null ||
          result.difference(crtDate).abs() >
              nextDate.difference(crtDate).abs()) {
        result = nextDate;
        if (result == crtRemindDate) break;
      }
    }
    return result;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
