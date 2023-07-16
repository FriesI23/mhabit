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

import '../habit_date.dart';

class HabitScoreChangedProtoData {
  final HabitDate fromDate;
  final HabitDate toDate;
  final num fromScore;
  final num toScore;

  const HabitScoreChangedProtoData({
    required this.fromDate,
    required this.toDate,
    required this.fromScore,
    required this.toScore,
  });

  num get dailyScoreChangedValue =>
      (toScore - fromScore) / toDate.difference(fromDate).inDays.abs();

  Iterable<MapEntry<HabitDate, num>> expandToDate() sync* {
    if (fromDate == toDate) {
      yield MapEntry(toDate, toScore);
      return;
    }

    var changed = dailyScoreChangedValue;
    var crtDate = fromDate;
    var crtScore = fromScore;

    yield MapEntry(crtDate, crtScore);
    while (crtDate <= toDate) {
      yield MapEntry(crtDate, crtScore);
      crtDate = crtDate.addDays(1);
      crtScore += changed;
    }
  }

  @override
  String toString() {
    return 'HabitScoreChangedProtoData('
        'fromDate: $fromDate, '
        'toDate: $toDate, '
        'fromScore: $fromScore, '
        'toScore: $toScore)';
  }
}
