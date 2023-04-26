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

abstract class DateTimeExtensionsABC {
  bool isSameDate(DateTime other);
  bool operator >(DateTime other);
  bool operator <(DateTime other);
  bool operator >=(DateTime other);
  bool operator <=(DateTime other);
  DateTime get firstDayOfWeek;
  DateTime get lastDayOfWeek;
  DateTime get firstDayOfMonth;
  DateTime get lastDayOfMonth;
  bool get isFirstWeekOfMonth;
  bool get isFirstWeekOfYear;
  int weekDayWithStartDay(int firstDay);
  DateTime getFirstDayOfWeekWithStartDay(int firstDay);
  DateTime getLastDayOfWeekWithStartDay(int firstDay);
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return difference(other).inDays == 0;
  }
}

extension DateTimeExtended on DateTime {
  bool operator >(DateTime other) {
    return isAfter(other);
  }

  bool operator <(DateTime other) {
    return isBefore(other);
  }

  bool operator >=(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  bool operator <=(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  DateTime get firstDayOfWeek => subtract(Duration(days: weekday - 1));

  DateTime get lastDayOfWeek =>
      add(Duration(days: DateTime.daysPerWeek - weekday));

  DateTime get firstDayOfMonth => copyWith(day: 1);

  DateTime get lastDayOfMonth => month < 12
      ? copyWith(month: month + 1, day: 0)
      : copyWith(year: year + 1, month: 1, day: 0);

  bool get isFirstWeekOfMonth => day <= 7;

  bool get isFirstWeekOfYear => month == 1 && isFirstWeekOfMonth;

  int weekDayWithStartDay(int firstDay) {
    return (weekday + 7 - firstDay) % 7 + 1;
  }

  DateTime getFirstDayOfWeekWithStartDay(int firstDay) {
    return subtract(Duration(days: weekDayWithStartDay(firstDay) - 1));
  }

  DateTime getLastDayOfWeekWithStartDay(int firstDay) {
    return add(
        Duration(days: DateTime.daysPerWeek - weekDayWithStartDay(firstDay)));
  }
}

extension DateTimeWeekday on DateTime {
  DateTime next(int day) {
    return copyWith(
      day: this.day +
          (day == weekday ? 7 : (day - weekday) % DateTime.daysPerWeek),
    );
  }

  DateTime previous(int day) {
    return copyWith(
      day: this.day -
          (day == weekday ? 7 : (weekday - day) % DateTime.daysPerWeek),
    );
  }
}
