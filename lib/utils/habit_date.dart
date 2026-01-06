// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../models/habit_date.dart';

class HabitDateRangeCalculator {
  final HabitDate date;
  final int offset;
  final int limit;

  const HabitDateRangeCalculator({
    required this.date,
    required this.offset,
    required this.limit,
  });

  HabitDate lastDateMonthly() =>
      date.copyWith(month: date.month - offset * limit);

  HabitDate firstDateMonthly() =>
      date.copyWith(month: date.month - (offset + 1) * limit + 1);

  HabitDate lastDateYearly() => date.copyWith(year: date.year - offset * limit);

  HabitDate firstDateYearly() =>
      date.copyWith(year: date.year - (offset + 1) * limit + 1);

  HabitDate lastDateWeekly() => date.subtractDays(offset * limit * 7);

  HabitDate firstDateWeekly() =>
      date.subtractDays(((offset + 1) * limit - 1) * 7);

  HabitDate lastDateDaily() => date.subtractDays(offset * limit);

  HabitDate firstDateDaily() => date.subtractDays((offset + 1) * limit + 1);
}

bool isOutOfDateRange(
  HabitDate date,
  HabitDate firstDate,
  HabitDate lastDate, {
  bool reversedDate = false,
}) {
  if (reversedDate) {
    return date.isAfter(firstDate) || date.isBefore(lastDate);
  } else {
    return date.isBefore(firstDate) || date.isAfter(lastDate);
  }
}

bool isInDateRange(
  HabitDate date,
  HabitDate firstDate,
  HabitDate lastDate, {
  bool reversedDate = false,
}) => !isOutOfDateRange(date, firstDate, lastDate, reversedDate: reversedDate);

Iterable<MapEntry<HabitDate, T>> filterWithDateRange<T>({
  required HabitDate firstDate,
  required HabitDate lastDate,
  required Iterable<MapEntry<HabitDate, T>> data,
  required bool reversed,
  int limit = 1,
}) sync* {
  assert(limit >= 1);
  int founded = 0;
  for (var e in data) {
    if (isOutOfDateRange(e.key, firstDate, lastDate, reversedDate: reversed)) {
      if (founded >= limit) {
        return;
      } else {
        continue;
      }
    } else {
      founded += 1;
      yield e;
    }
  }
}
