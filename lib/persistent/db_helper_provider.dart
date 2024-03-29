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

import 'package:flutter/foundation.dart';

import '../common/abc.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../logging/helper.dart';
import '../model/habit_summary.dart';
import '../provider/commons.dart';
import 'local/db_helper.dart';
import 'local/handler/habit.dart';
import 'local/handler/record.dart';

class DBHelperViewModel extends ChangeNotifier
    with FutureInitializationABC, ProviderMounted {
  DBHelper local;
  Future? waitingInit;
  bool _inited = false;
  bool _mounted = true;

  DBHelperViewModel() : local = DBHelper();

  @override
  Future init() async {
    Future initAll() async {
      await local.init();
    }

    if (inited) {
      appLog.load.error("$runtimeType.init",
          ex: ["already inited", local, _inited, _mounted]);
      return;
    }

    waitingInit = initAll()..whenComplete(() => _inited = true);
    await waitingInit;
  }

  @override
  void dispose() {
    _mounted = false;
    local.dispose();
    super.dispose();
  }

  Future reload() async {
    await local.init(reinit: true);
    notifyListeners();
  }

  @override
  bool get mounted => _mounted;

  bool get inited => _inited;

  @override
  String toString() {
    return "$runtimeType[$hashCode](local=$local,mounted=$mounted,"
        "inited=$inited)";
  }
}

abstract mixin class DBHelperLoadedMixin {
  late HabitDBHelper habitDBHelper;
  late RecordDBHelper recordDBHelper;

  void updateDBHelper(DBHelperViewModel newHelper) {
    appLog.load.info("$runtimeType.updateDBHelper", ex: [newHelper]);
    habitDBHelper = HabitDBHelper(newHelper.local);
    recordDBHelper = RecordDBHelper(newHelper.local);
  }
}

mixin DBOperationsMixin on DBHelperLoadedMixin {
  Future<RecordDBCell> saveHabitRecordToDB(
      DBID parendId, HabitUUID parendUUID, HabitSummaryRecord record,
      {bool isNew = false, String? withReason}) async {
    final int dbid;
    final RecordDBCell dbCell;
    if (isNew) {
      dbCell = RecordDBCell(
        parentId: parendId,
        parentUUID: parendUUID,
        uuid: record.uuid,
        recordDate: record.date.epochDay,
        recordType: record.status.dbCode,
        recordValue: record.value,
        reason: withReason,
      );
      dbid = await recordDBHelper.insertNewRecord(dbCell);
    } else {
      dbCell = RecordDBCell(
        uuid: record.uuid,
        recordType: record.status.dbCode,
        recordValue: record.value,
        reason: withReason,
      );
      dbid = await recordDBHelper.updateRecord(dbCell);
    }

    return dbCell.copyWith(id: dbid);
  }

  Future<HabitSummaryData?> loadSingleHabitSummaryFromDB(HabitUUID uuid,
      {int firstDay = defaultFirstDay}) async {
    final dataLoadTask = habitDBHelper.loadHabitDetail(uuid);
    final recordLoadTask = recordDBHelper.loadRecords(uuid);
    final cell = await dataLoadTask;
    final records = await recordLoadTask;
    if (cell == null) return null;
    final habit = HabitSummaryData.fromDBQueryCell(cell);
    habit.initRecords(
      records.map((e) => HabitSummaryRecord.fromDBQueryCell(e)),
    );
    habit.reCalculateAutoComplateRecords(firstDay: firstDay);
    return habit;
  }
}
