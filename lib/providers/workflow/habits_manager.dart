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

import '../../common/types.dart';
import '../../extensions/iterable_extensions.dart';
import '../../logging/helper.dart';
import '../../models/habit_date.dart';
import '../../models/habit_detail.dart';
import '../../models/habit_export.dart';
import '../../models/habit_form.dart';
import '../../models/habit_import.dart';
import '../../models/habit_repo_actions.dart';
import '../../models/habit_summary.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_id_range.dart';
import '../../reminders/notification_service.dart';
import '../../storage/db/handlers/habit.dart';
import '../../storage/db/handlers/record.dart';
import '../../storage/db_helper_provider.dart';
import '../support/commons.dart';
import 'app_notify_config.dart';

typedef BeforeHabitRecordReminderUpdateCb =
    FutureOr<void> Function(
      HabitSummaryData habit,
      List<ChangeRecordStatusResult> records,
    );

abstract interface class HabitsDisplayAccess {
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  });

  Future<String?> loadHabitRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  );

  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid);

  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  });

  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
      List<ChangeRecordStatusResult> results,
    )?
    postActionBuilder,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  });

  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  });

  Future<void> updateHabitReminders(Iterable<HabitSummaryData> habits);
}

abstract interface class HabitDetailAccess implements HabitsDisplayAccess {
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid);
}

abstract interface class HabitFormAccess {
  Future<bool?> requestReminderPermission();

  Future<HabitDBCell?> saveNewHabitAndUpdateReminder(HabitDBCell cell);

  Future<HabitDBCell?> updateExistHabitAndUpdateReminder(
    HabitDBCell cell, {
    bool withReminder = true,
  });
}

abstract interface class HabitStatusChangerAccess
    implements HabitsDisplayAccess {
  Future<void> saveChangedHabitRecords({
    required Iterable<ChangeRecordStatusResult> records,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  });
}

abstract interface class HabitExportAccess {
  Future<Iterable<HabitExportData>> loadHabitExportData({
    List<HabitUUID>? uuidList,
    bool withRecords = true,
  });
}

abstract interface class HabitImportAccess {
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
  });

  int getImportHabitsCount(Iterable<Object?> jsonData);
}

class _HabitReminderRuntime {
  final NotificationService _notificationService;

  _HabitReminderRuntime({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  Future<bool?> requestNotificationPermissions() =>
      _notificationService.requestPermissions();

  Future<void> updateHabitReminder(
    HabitSummaryData data, {
    required NotificationChannelData channelData,
  }) async {
    final reminderId = getHabitReminderId(data.id);

    Future<bool> registerReminder() => _notificationService.regrHabitReminder(
      id: reminderId,
      uuid: data.uuid,
      name: data.name,
      quest: data.reminderQuest,
      reminder: data.reminder!,
      lastUntrackDate: data.getFirstUnTrackedDate(),
      details: channelData.habitReminder,
    );

    Future<bool> cancelReminder() =>
        _notificationService.cancelHabitReminder(id: reminderId);

    try {
      switch (data.status) {
        case HabitStatus.activated:
          await (data.reminder != null ? registerReminder() : cancelReminder());
        case HabitStatus.archived || HabitStatus.deleted || HabitStatus.unknown:
          await cancelReminder();
      }
    } on Exception catch (e) {
      appLog.notify.error(
        '$runtimeType.updateHabitReminder',
        ex: ["catch err when try regr reminder"],
        error: e,
      );
    }
  }
}

class HabitsManager
    with DBHelperLoadedMixin, NotificationChannelDataMixin
    implements
        HabitsDisplayAccess,
        HabitDetailAccess,
        HabitFormAccess,
        HabitStatusChangerAccess,
        HabitExportAccess,
        HabitImportAccess {
  final _HabitReminderRuntime _reminderRuntime;
  AppNotifyConfigAccess? _notifyConfig;

  HabitsManager({NotificationService? notificationService})
    : _reminderRuntime = _HabitReminderRuntime(
        notificationService: notificationService,
      );

  void attachNotifyConfig(AppNotifyConfigAccess access) {
    _notifyConfig = access;
  }

  bool get _isReminderChannelEnabled =>
      _notifyConfig?.isChannelEnabled(NotificationChannelId.habitReminder) ??
      true;

  //#region status
  @override
  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  }) async {
    await habitDBHelper.updateSelectedHabitStatus(
      action.data.map((e) => e.uuid).toList(),
      action.status,
    );
    final result = action.resolve();
    final updatedHabits = {
      for (final item in result) item.data.uuid: item.data,
    }.values;
    await updateHabitReminders(updatedHabits);
    if (extraResolver is Future) {
      await Future.wait(result.map((e) async => extraResolver?.call(e)));
    } else if (extraResolver != null) {
      for (var r in result) {
        extraResolver(r);
      }
    }
    return result;
  }

  @override
  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
      List<ChangeRecordStatusResult> results,
    )?
    postActionBuilder,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  }) async {
    final preResults = preAction.resolve();
    if (preResults.length == 1) {
      final data = preAction.data;
      await saveHabitRecordToDB(
        data.id,
        data.uuid,
        preResults.first.data,
        isNew: preResults.first.isNew,
        withReason: preResults.first.reason,
      );
    } else {
      await saveMultiHabitRecordToDB(preResults);
    }

    final results = postActionBuilder?.call(preResults).resolve() ?? preResults;
    await _updateChangedHabitRecordReminders(
      results,
      beforeReminderUpdate: beforeReminderUpdate,
    );
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
    DBID parentId,
    HabitUUID parentUUID,
    HabitSummaryRecord record, {
    bool isNew = false,
    String? withReason,
  }) async {
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
    Iterable<ChangeRecordStatusResult> records,
  ) => recordDBHelper.insertOrUpdateMultiRecords(
    records.map(
      (record) => RecordDBCell.build(
        parentId: record.habit.id,
        parentUUID: record.habit.uuid,
        uuid: record.data.uuid,
        recordDate: record.data.date.epochDay,
        recordType: record.data.status.dbCode,
        recordValue: record.data.value,
        reason: record.reason,
      ),
    ),
  );

  @override
  Future<void> saveChangedHabitRecords({
    required Iterable<ChangeRecordStatusResult> records,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  }) async {
    final recordList = records.toList(growable: false);
    if (recordList.isEmpty) return;

    await saveMultiHabitRecordToDB(recordList);
    await _updateChangedHabitRecordReminders(
      recordList,
      beforeReminderUpdate: beforeReminderUpdate,
    );
  }

  Future<HabitDBCell?> _saveNewHabitToDB(
    HabitDBCell cell, {
    bool returnResult = false,
  }) async {
    final dbid = await habitDBHelper.insertNewHabit(cell);
    final result = returnResult
        ? await habitDBHelper.queryHabitByDBID(dbid)
        : null;
    return result;
  }

  @override
  Future<bool?> requestReminderPermission() =>
      _reminderRuntime.requestNotificationPermissions();

  @override
  Future<HabitDBCell?> saveNewHabitAndUpdateReminder(HabitDBCell cell) async {
    final result = await _saveNewHabitToDB(cell, returnResult: true);
    await _updateSavedHabitReminder(result);
    return result;
  }

  Future<HabitDBCell?> _updateExistHabitToDB(
    HabitDBCell cell, {
    bool withReminder = true,
    bool returnResult = false,
  }) async {
    assert(cell.uuid != null);
    final habitUUID = cell.uuid;
    if (habitUUID == null) return null;
    final count = await habitDBHelper.updateExistHabit(
      cell,
      includeNullKeys: withReminder
          ? const [
              HabitDBCellKey.remindCustom,
              HabitDBCellKey.remindQuestion,
              HabitDBCellKey.dailyGoalExtra,
            ]
          : const [],
    );
    final result = (count > 0 && returnResult)
        ? await habitDBHelper.queryHabitByUUID(habitUUID)
        : null;
    return result;
  }

  @override
  Future<HabitDBCell?> updateExistHabitAndUpdateReminder(
    HabitDBCell cell, {
    bool withReminder = true,
  }) async {
    final result = await _updateExistHabitToDB(
      cell,
      withReminder: withReminder,
      returnResult: true,
    );
    await _updateSavedHabitReminder(result);
    return result;
  }
  //#endregion

  //#region load from db
  @override
  Future<String?> loadHabitRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) async {
    final recordUUID = data.getRecordByDate(date)?.uuid;
    if (recordUUID == null) return null;
    final rcd = await recordDBHelper.loadSingleRecord(recordUUID);
    return rcd?.reason ?? '';
  }

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection(
      uuidFilter: habitUUIDs,
      columns: habitsColmns,
    );
    final recordLoadTask = recordDBHelper.loadAllRecords(
      uuidFilter: habitUUIDs,
    );
    final habitLoaded = await habitLoadTask;
    final recordLoaded = await recordLoadTask;
    if (initedCollection != null) {
      return initedCollection
        ..initDataFromDBQueuryResult(habitLoaded, recordLoaded);
    } else {
      return HabitSummaryDataCollection.fromDBQueryResult(
        habitLoaded,
        recordLoaded,
      );
    }
  }

  @override
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

  @override
  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid) =>
      habitDBHelper.loadHabitDetail(uuid);
  //#endregion

  @override
  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) async {
    final posList = habits
        .map((e) => e.sortPostion)
        .makeUniqueAndIncreasing(
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
        changedUUIDs,
        changedPositions,
      );
    }

    return changedUUIDs;
  }

  Future<void> _updateHabitReminder(HabitSummaryData data) {
    if (!_isReminderChannelEnabled) return Future.value();
    return _reminderRuntime.updateHabitReminder(data, channelData: channelData);
  }

  @override
  Future<void> updateHabitReminders(Iterable<HabitSummaryData> habits) =>
      Future.wait(habits.map(_updateHabitReminder));

  Future<void> _updateChangedHabitRecordReminders(
    Iterable<ChangeRecordStatusResult> records, {
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  }) async {
    final updatedHabits = <HabitUUID, HabitSummaryData>{};
    final recordsByHabit = <HabitUUID, List<ChangeRecordStatusResult>>{};

    for (final record in records) {
      final habitUUID = record.habit.uuid;
      updatedHabits[habitUUID] = record.habit;
      (recordsByHabit[habitUUID] ??= []).add(record);
    }

    if (beforeReminderUpdate != null) {
      await Future.wait(
        updatedHabits.entries.map(
          (entry) async =>
              beforeReminderUpdate(entry.value, recordsByHabit[entry.key]!),
        ),
      );
    }
    await updateHabitReminders(updatedHabits.values);
  }

  Future<void> _updateSavedHabitReminder(HabitDBCell? cell) async {
    if (cell == null) return;
    await _updateHabitReminder(HabitSummaryData.fromDBQueryCell(cell));
  }

  //#region import and export
  HabitExporter getExporter({List<HabitUUID>? uuidList}) =>
      HabitExporter(habitDBHelper, recordDBHelper, uuidList: uuidList);

  HabitImport getImporter(Iterable<Object?> jsonData) =>
      HabitImport(habitDBHelper, recordDBHelper, data: jsonData);

  @override
  Future<Iterable<HabitExportData>> loadHabitExportData({
    List<HabitUUID>? uuidList,
    bool withRecords = true,
  }) => getExporter(uuidList: uuidList).exportData(withRecords: withRecords);

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
  }) => getImporter(jsonData).importData(withRecords: withRecords);

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) =>
      getImporter(jsonData).habitsCount;
  //#endregion
}
