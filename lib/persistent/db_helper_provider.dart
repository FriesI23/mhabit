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
import 'package:flutter/material.dart';

import '../common/async.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../logging/helper.dart';
import '../model/habit_summary.dart';
import '../provider/commons.dart';
import 'local/db_helper.dart';
import 'local/handler/habit.dart';
import 'local/handler/record.dart';
import 'local/handler/sync.dart';

class DBHelperViewModel extends ChangeNotifier
    implements ProviderMounted, AsyncInitialization {
  final DBHelper local;

  CancelableCompleter<bool?>? _completer;
  bool _mounted = true;

  DBHelperViewModel() : local = DBHelper();

  CancelableCompleter<bool?> doInit(
      {required bool reinit, Duration timeout = const Duration(seconds: 5)}) {
    final completer = CancelableCompleter<bool>();
    local
        .init(reinit: reinit)
        .timeout(timeout)
        .then((_) => completer.complete(true))
        .onError((e, s) {
      if (!completer.isCompleted) {
        e != null ? completer.completeError(e, s) : completer.complete(false);
      }
      if (e != null) return Future.error(e, s);
    });
    return completer;
  }

  @override
  Future<bool> init() {
    if (_completer != null) {
      return _completer!.operation.value.then((value) => value ?? false);
    }
    _completer = doInit(reinit: false);
    return _completer?.operation.value.then((value) => value ?? false) ??
        Future.value(false);
  }

  @override
  void dispose() {
    _mounted = false;
    if (inited) local.dispose();
    if (_completer?.isCompleted != true) _completer?.operation.cancel();
    super.dispose();
  }

  Future<void> reload() async {
    if (_completer?.isCompleted != true) await _completer?.operation.cancel();
    _completer = doInit(reinit: true);
    await _completer?.operation.value;
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
  late SyncDBHelper syncDBHelper;

  void updateDBHelper(DBHelperViewModel newHelper) {
    appLog.load.info("$runtimeType.updateDBHelper", ex: [newHelper]);
    habitDBHelper = HabitDBHelper(newHelper.local);
    recordDBHelper = RecordDBHelper(newHelper.local);
    syncDBHelper = SyncDBHelper(newHelper.local);
  }
}

mixin DBOperationsMixin on DBHelperLoadedMixin {
  Future<RecordDBCell> saveHabitRecordToDB(
      DBID parentId, HabitUUID parentUUID, HabitSummaryRecord record,
      {bool isNew = false, String? withReason}) async {
    final int dbid;
    final RecordDBCell dbCell;
    if (isNew) {
      dbCell = RecordDBCell.build(
        parentId: parentId,
        parentUUID: parentUUID,
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
        parentUUID: parentUUID,
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
      records.map(HabitSummaryRecord.fromDBQueryCell),
    );
    habit.reCalculateAutoComplateRecords(firstDay: firstDay);
    return habit;
  }
}
