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
import '../common/utils.dart';
import '../logging/helper.dart';
import '../storage/db/handlers/habit.dart';
import '../storage/db/handlers/record.dart';
import 'habit_export.dart';

class HabitImport {
  final HabitDBHelper helper;
  final RecordDBHelper recordDBHelper;

  final Iterable<Object?> _jsonData;

  const HabitImport(this.helper, this.recordDBHelper,
      {Iterable<Object?> data = const []})
      : _jsonData = data;

  int get habitsCount => _jsonData.length;

  Future<void> _importHabitData(HabitExportData habitExportData,
      {bool withRecords = true}) async {
    final habitUUID = genHabitUUID();
    var habitDBCell = habitExportData.toHabitDBCell();
    habitDBCell = habitDBCell.copyWith(
        uuid: habitUUID, type: habitDBCell.type ?? defaultHabitType.dbCode);
    final dbid = await helper.insertNewHabit(habitDBCell);
    if (withRecords) {
      await recordDBHelper.insertOrUpdateMultiRecords(
        habitExportData.getRecordDBCells().map(
              (e) => e.copyWith(
                parentId: dbid,
                parentUUID: habitDBCell.uuid,
                uuid: genRecordUUID(habitUUID, e.recordDate),
              ),
            ),
      );
      appLog.import.info("$runtimeType._importHabitData",
          ex: ["with records", dbid, habitDBCell]);
    } else {
      appLog.import.info("$runtimeType._importHabitData",
          ex: ["without records", dbid, habitDBCell]);
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
