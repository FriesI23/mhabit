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

import '../common/consts.dart';
import '../extension/datetime_extensions.dart';

class HabitDate implements DateTime, DateTimeExtensionsABC {
  late final DateTime _date;

  HabitDate(int year, [int month = 1, int day = 1])
      : _date = DateTime.utc(year, month, day);

  HabitDate.now() {
    var now = DateTime.now();
    _date = DateTime.utc(now.year, now.month, now.day);
  }

  HabitDate.fromEpochDay(int epochDay)
      : _date = DateTime.fromMillisecondsSinceEpoch(
            epochDay * oneDayMilliseconds,
            isUtc: true);

  HabitDate.dateTime(DateTime dateTime)
      : _date = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);

  @override
  HabitDate add(Duration duration) {
    return HabitDate.dateTime(_date.add(duration));
  }

  HabitDate addDays(int days) {
    return add(Duration(days: days));
  }

  @override
  int compareTo(DateTime other) {
    return _date.compareTo(other);
  }

  @override
  int get day => _date.day;

  @override
  Duration difference(DateTime other) {
    return _date.difference(other);
  }

  @override
  int get hour => _date.hour;

  @override
  bool isAfter(DateTime other) {
    return _date.isAfter(other);
  }

  @override
  bool isAtSameMomentAs(DateTime other) {
    return _date.isAtSameMomentAs(other);
  }

  @override
  bool isBefore(DateTime other) {
    return _date.isBefore(other);
  }

  @override
  bool get isUtc => true;

  @override
  int get microsecond => _date.microsecond;

  @override
  int get microsecondsSinceEpoch => _date.microsecondsSinceEpoch;

  @override
  int get millisecond => _date.millisecond;

  @override
  int get millisecondsSinceEpoch => _date.millisecondsSinceEpoch;

  int get epochDay => millisecondsSinceEpoch ~/ oneDayMilliseconds;

  @override
  int get minute => _date.minute;

  @override
  int get month => _date.month;

  @override
  int get second => _date.second;

  @override
  HabitDate subtract(Duration duration) {
    return HabitDate.dateTime(_date.subtract(duration));
  }

  HabitDate subtractDays(int days) {
    return subtract(Duration(days: days));
  }

  @override
  String get timeZoneName => _date.timeZoneName;

  @override
  Duration get timeZoneOffset => _date.timeZoneOffset;

  @override
  String toIso8601String() {
    return _date.toIso8601String();
  }

  @override
  DateTime toLocal() {
    return _date.toLocal();
  }

  @override
  HabitDate toUtc() {
    return this;
  }

  @override
  int get weekday => _date.weekday;

  @override
  int get year => _date.year;

  @override
  bool operator ==(Object other) {
    if (other is! DateTime) return false;
    return isSameDate(other);
  }

  @override
  int get hashCode => _date.hashCode;

  @override
  String toString() {
    return _date.toString();
  }

  @override
  bool operator <(DateTime other) => _date < other;

  @override
  bool operator <=(DateTime other) => _date <= other;

  @override
  bool operator >(DateTime other) => _date > other;

  @override
  bool operator >=(DateTime other) => _date >= other;

  @override
  HabitDate get firstDayOfWeek => HabitDate.dateTime(_date.firstDayOfWeek);

  @override
  HabitDate get lastDayOfWeek => HabitDate.dateTime(_date.lastDayOfWeek);

  @override
  HabitDate get firstDayOfMonth => HabitDate.dateTime(_date.firstDayOfMonth);

  @override
  HabitDate get lastDayOfMonth => HabitDate.dateTime(_date.lastDayOfMonth);

  @override
  bool isSameDate(DateTime other) => _date.isSameDate(other);

  HabitDate copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return HabitDate.dateTime(
        _date.copyWith(year: year, month: month, day: day));
  }

  @override
  bool get isFirstWeekOfMonth => _date.isFirstWeekOfMonth;

  @override
  bool get isFirstWeekOfYear => _date.isFirstWeekOfYear;

  @override
  int weekDayWithStartDay(int firstDay) => _date.weekDayWithStartDay(firstDay);

  @override
  HabitDate getFirstDayOfWeekWithStartDay(int firstDay) =>
      HabitDate.dateTime(_date.getFirstDayOfWeekWithStartDay(firstDay));

  @override
  HabitDate getLastDayOfWeekWithStartDay(int firstDay) =>
      HabitDate.dateTime(_date.getLastDayOfWeekWithStartDay(firstDay));
}
