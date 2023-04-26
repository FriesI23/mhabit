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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/db/db_helper/habits.dart';

void main() {
  group("HabitDBCell", () {
    var habit1 = const HabitDBCell(
        id: 1,
        type: 1,
        createT: 0,
        modifyT: 0,
        uuid: '',
        status: 0,
        name: 'name',
        desc: 'desc',
        color: 1,
        dailyGoal: 1.2,
        dailyGoalUnit: 'dailyGoalUnit',
        freqType: 2,
        freqCustom: "freqCustom",
        startDate: 123,
        targetDays: 1,
        remindCustom: "remindCustasdam",
        remindQuestion: "remindQuestion",
        sortPosition: 2);
    var habit2 = const HabitDBCell(
        name: 'name',
        desc: 'desc',
        color: 1,
        dailyGoal: 1.2,
        dailyGoalUnit: 'dailyGoalUnit',
        freqType: 2,
        freqCustom: "freqCustom",
        startDate: 123,
        targetDays: 1,
        remindCustom: "remindCustasdam",
        remindQuestion: "remindQuestion",
        sortPosition: 2);
    test("Constructor::fromMap", () {
      var data = {
        "id_": 1,
        "uuid": "31db76a6-da84-4eca-abc4-a419b4920a11",
        "name": "0 overleisured",
        "color": 0,
        "daily_goal": 1.0,
        "target_days": 100,
        "freq_type": 3,
        "freq_custom": "[1, 1]",
        "start_date": 19404,
        "status": 1,
        "sort_position": 1.0,
        "create_t": 1677550818,
      };
      HabitDBCell.fromMap(data);
    });
    test("toMap", () {
      var result1 = habit1.toMap();
      expect(result1[HabitDBCellKey.type], 1);
      expect(result1[HabitDBCellKey.id], 1);
      var result2 = habit2.toMap();
      expect(result2[HabitDBCellKey.name], 'name');
      expect(result2.containsKey(HabitDBCellKey.id), false);
    });
    test('toString', () {
      expect(habit1.toString().startsWith("HabitDB"), true);
    });
  });
}
