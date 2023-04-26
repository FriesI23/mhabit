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

import '../common/logging.dart';
import '../common/utils.dart';
import '../db/db_helper/habits.dart';
import '../db/db_helper/records.dart';
import 'habit_export.dart';
import 'habit_form.dart';

class HabitImport {
  final Iterable<Object?> _jsonData;

  const HabitImport({Iterable<Object?> data = const []}) : _jsonData = data;

  int get habitsCount => _jsonData.length;

  Future<void> _importHabitData(HabitExportData habitExportData,
      {bool withRecords = true}) async {
    var habitDBCell = habitExportData.toHabitDBCell();
    habitDBCell = habitDBCell.copyWith(
        uuid: genHabitUUID(), type: HabitType.normal.dbCode);
    final dbid = await insertNewHabitCellToDB(habitDBCell);
    if (withRecords) {
      final results = await insertMultiRecordsCellToDB(
        habitExportData.getRecordDBCells().map(
              (e) => e.copyWith(
                parentId: dbid,
                parentUUID: habitDBCell.uuid,
                uuid: genRecordUUID(),
              ),
            ),
      );
      InfoLog.import("dbid=$dbid, cell=$habitDBCell, records=$results");
    } else {
      InfoLog.import("dbid=$dbid, cell=$habitDBCell");
    }
  }

  List<Future> importData({bool withRecords = true}) {
    final futures = <Future>[];
    for (var json in _jsonData) {
      final habit = HabitExportData.fromJson(json);
      futures.add(_importHabitData(habit, withRecords: withRecords));
    }
    return futures;
  }
}
