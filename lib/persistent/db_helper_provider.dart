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

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

import '../common/async.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../logging/helper.dart';
import '../model/habit_summary.dart';
import '../provider/commons.dart';
import 'local/db_helper.dart';
import 'local/handler/habit.dart';
import 'local/handler/record.dart';

class DBHelperViewModel extends ChangeNotifier
    with ProviderMounted
    implements AsyncInitialization {
  final DBHelper local;

  Completer? _completer;
  bool _mounted = true;

  DBHelperViewModel() : local = DBHelper();

  @override
  Future init() async {
    if (_completer == null) {
      _completer = Completer();
      await local.init();
      _completer!.complete();
    }
    return _completer!.future;
  }

  @override
  void dispose() {
    _mounted = false;
    if (inited) local.dispose();
    if (_completer?.isCompleted != true) {
      CancelableOperation.fromFuture(_completer!.future).cancel();
      _completer = null;
    }
    super.dispose();
  }

  Future reload() async {
    if (_completer?.isCompleted != true) {
      CancelableOperation.fromFuture(_completer!.future).cancel();
      _completer = null;
    }
    await local.init(reinit: true);
    notifyListeners();
  }

  @override
  bool get mounted => _mounted;

  bool get inited => _completer?.isCompleted ?? false;

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
