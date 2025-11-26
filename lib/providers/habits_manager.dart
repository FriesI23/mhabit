// Copyright 2025 Fries_I23
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

import 'package:flutter/foundation.dart';

import '../common/types.dart';
import '../extensions/iterable_extensions.dart';
import '../logging/helper.dart';
import '../models/habit_date.dart';
import '../models/habit_detail.dart';
import '../models/habit_export.dart';
import '../models/habit_form.dart';
import '../models/habit_import.dart';
import '../models/habit_repo_actions.dart';
import '../models/habit_summary.dart';
import '../reminders/notification_id_range.dart';
import '../reminders/notification_service.dart';
import '../storage/db/handlers/habit.dart';
import '../storage/db/handlers/record.dart';
import '../storage/db_helper_provider.dart';
import 'commons.dart';

class HabitsManager with DBHelperLoadedMixin, NotificationChannelDataMixin {
  HabitsManager();

  //#region status
  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  }) async {
    await habitDBHelper.updateSelectedHabitStatus(
        action.data.map((e) => e.uuid).toList(), action.status);
    final result = action.resolve();
    if (extraResolver is Future) {
      await Future.wait(result.map((e) async => extraResolver?.call(e)));
    } else if (extraResolver != null) {
      for (var r in result) {
        extraResolver(r);
      }
    }
    return result;
  }

  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
            List<ChangeRecordStatusResult> results)?
        postActionBuilder,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  }) async {
    final preResults = preAction.resolve();
    if (preResults.length == 1) {
      final data = preAction.data;
      await saveHabitRecordToDB(data.id, data.uuid, preResults.first.data,
          isNew: preResults.first.isNew, withReason: preResults.first.reason);
    } else {
      await saveMultiHabitRecordToDB(preResults);
    }

    final results = postActionBuilder?.call(preResults).resolve() ?? preResults;
    if (extraResolver is Future) {
      await Future.wait(results.map((e) async => extraResolver?.call(e)));
    } else if (extraResolver != null) {
      for (var r in results) {
        extraResolver(r);
      }
    }
    return results;
  }
  //#endregion

  //#region write to db
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

  Future<void> saveMultiHabitRecordToDB(
          Iterable<ChangeRecordStatusResult> records) =>
      recordDBHelper.insertOrUpdateMultiRecords(
          records.map((record) => RecordDBCell.build(
                parentId: record.habit.id,
                parentUUID: record.habit.uuid,
                uuid: record.data.uuid,
                recordDate: record.data.date.epochDay,
                recordType: record.data.status.dbCode,
                recordValue: record.data.value,
                reason: record.reason,
              )));

  Future<HabitDBCell?> saveNewHabitToDB(HabitDBCell cell,
      {bool returnResult = false}) async {
    final dbid = await habitDBHelper.insertNewHabit(cell);
    final result =
        returnResult ? await habitDBHelper.queryHabitByDBID(dbid) : null;
    return result;
  }

  Future<HabitDBCell?> updateExistHabitToDB(HabitDBCell cell,
      {bool withReminder = true, bool returnResult = false}) async {
    assert(cell.uuid != null);
    final habitUUID = cell.uuid;
    if (habitUUID == null) return null;
    final count = await habitDBHelper.updateExistHabit(cell,
        includeNullKeys: withReminder
            ? const [
                HabitDBCellKey.remindCustom,
                HabitDBCellKey.remindQuestion,
                HabitDBCellKey.dailyGoalExtra,
              ]
            : const []);
    final result = (count > 0 && returnResult)
        ? await habitDBHelper.queryHabitByUUID(habitUUID)
        : null;
    return result;
  }
  //#endregion

  //#region load from db
  Future<String?> loadHabitRecordReason(
      HabitSummaryData data, HabitRecordDate date) async {
    final recordUUID = data.getRecordByDate(date)?.uuid;
    if (recordUUID == null) return null;
    final rcd = await recordDBHelper.loadSingleRecord(recordUUID);
    return rcd?.reason ?? '';
  }

  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData(
      {HabitSummaryDataCollection? initedCollection,
      List<String>? habitsColmns,
      List<HabitUUID>? habitUUIDs}) async {
    final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection(
        uuidFilter: habitUUIDs, columns: habitsColmns);
    final recordLoadTask =
        recordDBHelper.loadAllRecords(uuidFilter: habitUUIDs);
    final habitLoaded = await habitLoadTask;
    final recordLoaded = await recordLoadTask;
    if (initedCollection != null) {
      return initedCollection
        ..initDataFromDBQueuryResult(habitLoaded, recordLoaded);
    } else {
      return HabitSummaryDataCollection.fromDBQueryResult(
          habitLoaded, recordLoaded);
    }
  }

  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) async {
    final dataLoadTask = habitDBHelper.loadHabitDetail(uuid);
    final recordLoadTask = recordDBHelper.loadRecords(uuid);
    final cell = await dataLoadTask;
    if (cell == null) return null;
    final records = await recordLoadTask;
    final data = HabitDetailData.fromDBQueryCell(cell);
    data.data.initRecords(records.map(HabitSummaryRecord.fromDBQueryCell));
    return data;
  }

  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid) =>
      habitDBHelper.loadHabitDetail(uuid);
  //#endregion

  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) async {
    final posList = habits.map((e) => e.sortPostion).makeUniqueAndIncreasing(
          increaseStep,
          isSorted: false,
          decimalPlaces: decimalPlaces,
        );

    final changedUUIDs = <HabitUUID>[];
    final changedPositions = <num>[];

    for (var i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final pos = posList[i];
      if (habit.sortPostion != pos) {
        habit.sortPostion = pos;
        changedUUIDs.add(habit.uuid);
        changedPositions.add(pos);
      }
    }

    if (changedUUIDs.isNotEmpty) {
      await habitDBHelper.updateSelectedHabitsSortPostion(
          changedUUIDs, changedPositions);
    }

    return changedUUIDs;
  }

  Future<void> updateHabitReminder(HabitSummaryData data) async {
    final reminderId = getHabitReminderId(data.id);

    Future<bool> regr() => NotificationService().regrHabitReminder(
          id: reminderId,
          uuid: data.uuid,
          name: data.name,
          quest: data.reminderQuest,
          reminder: data.reminder!,
          lastUntrackDate: data.getFirstUnTrackedDate(),
          details: channelData.habitReminder,
        );

    Future<bool> unregr() =>
        NotificationService().cancelHabitReminder(id: reminderId);

    try {
      switch (data.status) {
        case HabitStatus.activated:
          await (data.reminder != null ? regr() : unregr());
        case HabitStatus.archived || HabitStatus.deleted || HabitStatus.unknown:
          await unregr();
      }
    } on Exception catch (e) {
      appLog.notify.error("HabitsManager._regrHabitReminder",
          ex: ["catch err when try regr reminder"], error: e);
    }
  }

  //#region import and export
  HabitExporter getExporter({List<HabitUUID>? uuidList}) =>
      HabitExporter(habitDBHelper, recordDBHelper, uuidList: uuidList);

  HabitImport getImporter(Iterable<Object?> jsonData) =>
      HabitImport(habitDBHelper, recordDBHelper, data: jsonData);
  //#endregion
}

mixin HabitsManagerLoadedMixin {
  bool _loaded = false;
  late HabitsManager _habitsManager;

  @protected
  HabitsManager get habitsManager => _habitsManager;

  void updateHabitManager(HabitsManager newManager) {
    if (!_loaded || _habitsManager != newManager) {
      _habitsManager = newManager;
      _loaded = true;
    }
  }
}
