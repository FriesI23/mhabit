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

import 'package:collection/collection.dart';

import '../../common/types.dart';
import '../../extensions/iterable_extensions.dart';
import '../../logging/helper.dart';
import '../../models/habit_date.dart';
import '../../models/habit_detail.dart';
import '../../models/habit_export.dart';
import '../../models/habit_form.dart';
import '../../models/habit_group.dart';
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

enum HabitReminderTriggerReason {
  /// Full refresh from the app startup production path.
  startup,

  /// Full refresh after the app returns from a paused lifecycle state.
  restart,

  /// Full refresh after a desktop day rollover or timezone change.
  dateChange,

  /// Owner-local refresh that reuses already loaded habits after a mutation.
  mutation,

  /// Explicit targeted refresh for a specific set of habit UUIDs.
  reconcile,
}

sealed class HabitReminderTrigger {
  final HabitReminderTriggerReason reason;

  const HabitReminderTrigger._(this.reason);

  const factory HabitReminderTrigger.startup() = _HabitReminderStartupTrigger;

  const factory HabitReminderTrigger.restart() = _HabitReminderRestartTrigger;

  const factory HabitReminderTrigger.dateChange() =
      _HabitReminderDateChangeTrigger;

  factory HabitReminderTrigger.mutation({
    required Iterable<HabitSummaryData> loadedHabits,
  }) => _HabitReminderMutationTrigger(
    List<HabitSummaryData>.unmodifiable(loadedHabits),
  );

  factory HabitReminderTrigger.reconcile({
    required Iterable<HabitUUID> habitUUIDs,
  }) =>
      _HabitReminderReconcileTrigger(List<HabitUUID>.unmodifiable(habitUUIDs));
}

final class _HabitReminderStartupTrigger extends HabitReminderTrigger {
  const _HabitReminderStartupTrigger()
    : super._(HabitReminderTriggerReason.startup);

  @override
  bool operator ==(Object other) => other is _HabitReminderStartupTrigger;

  @override
  int get hashCode => Object.hash(runtimeType, reason);
}

final class _HabitReminderRestartTrigger extends HabitReminderTrigger {
  const _HabitReminderRestartTrigger()
    : super._(HabitReminderTriggerReason.restart);

  @override
  bool operator ==(Object other) => other is _HabitReminderRestartTrigger;

  @override
  int get hashCode => Object.hash(runtimeType, reason);
}

final class _HabitReminderDateChangeTrigger extends HabitReminderTrigger {
  const _HabitReminderDateChangeTrigger()
    : super._(HabitReminderTriggerReason.dateChange);

  @override
  bool operator ==(Object other) => other is _HabitReminderDateChangeTrigger;

  @override
  int get hashCode => Object.hash(runtimeType, reason);
}

final class _HabitReminderMutationTrigger extends HabitReminderTrigger {
  final List<HabitSummaryData> loadedHabits;

  const _HabitReminderMutationTrigger(this.loadedHabits)
    : super._(HabitReminderTriggerReason.mutation);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HabitReminderMutationTrigger &&
          const ListEquality().equals(loadedHabits, other.loadedHabits);

  @override
  int get hashCode =>
      Object.hash(reason, const ListEquality().hash(loadedHabits));
}

final class _HabitReminderReconcileTrigger extends HabitReminderTrigger {
  final List<HabitUUID> habitUUIDs;

  const _HabitReminderReconcileTrigger(this.habitUUIDs)
    : super._(HabitReminderTriggerReason.reconcile);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HabitReminderReconcileTrigger &&
          const ListEquality().equals(habitUUIDs, other.habitUUIDs);

  @override
  int get hashCode =>
      Object.hash(reason, const ListEquality().hash(habitUUIDs));
}

sealed class HabitReminderRepairParams {
  const HabitReminderRepairParams._();

  factory HabitReminderRepairParams.loadedHabit(HabitSummaryData habit) =>
      _HabitReminderLoadedHabitsRepairParams([habit]);

  factory HabitReminderRepairParams.loadedHabits(
    Iterable<HabitSummaryData> habits,
  ) => _HabitReminderLoadedHabitsRepairParams(
    List<HabitSummaryData>.unmodifiable(habits),
  );
}

final class _HabitReminderLoadedHabitsRepairParams
    extends HabitReminderRepairParams {
  final List<HabitSummaryData> loadedHabits;

  const _HabitReminderLoadedHabitsRepairParams(this.loadedHabits) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HabitReminderLoadedHabitsRepairParams &&
          const ListEquality().equals(loadedHabits, other.loadedHabits);

  @override
  int get hashCode => const ListEquality().hash(loadedHabits);
}

sealed class HabitReminderRefreshParams {
  const HabitReminderRefreshParams();

  const factory HabitReminderRefreshParams.startup() =
      _HabitReminderStartupRefreshParams;

  const factory HabitReminderRefreshParams.restart() =
      _HabitReminderRestartRefreshParams;

  const factory HabitReminderRefreshParams.dateChange() =
      _HabitReminderDateChangeRefreshParams;

  factory HabitReminderRefreshParams.habitUUID(HabitUUID habitUUID) =>
      _HabitReminderRefreshUuidParams([habitUUID]);

  factory HabitReminderRefreshParams.habitUUIDs(
    Iterable<HabitUUID> habitUUIDs,
  ) =>
      _HabitReminderRefreshUuidParams(List<HabitUUID>.unmodifiable(habitUUIDs));
}

final class _HabitReminderStartupRefreshParams
    extends HabitReminderRefreshParams {
  const _HabitReminderStartupRefreshParams();

  @override
  bool operator ==(Object other) => other is _HabitReminderStartupRefreshParams;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class _HabitReminderRestartRefreshParams
    extends HabitReminderRefreshParams {
  const _HabitReminderRestartRefreshParams();

  @override
  bool operator ==(Object other) => other is _HabitReminderRestartRefreshParams;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class _HabitReminderDateChangeRefreshParams
    extends HabitReminderRefreshParams {
  const _HabitReminderDateChangeRefreshParams();

  @override
  bool operator ==(Object other) =>
      other is _HabitReminderDateChangeRefreshParams;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class _HabitReminderRefreshUuidParams extends HabitReminderRefreshParams {
  final List<HabitUUID> habitUUIDs;

  const _HabitReminderRefreshUuidParams(this.habitUUIDs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HabitReminderRefreshUuidParams &&
          const ListEquality().equals(habitUUIDs, other.habitUUIDs);

  @override
  int get hashCode => const ListEquality().hash(habitUUIDs);
}

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

  /// Batch-updates [HabitDBCellKey.groupId] for the given habits.
  ///
  /// [uuids] and [groupIds] must have the same length.
  /// Pass `null` entries in [groupIds] to clear the column
  /// (uncategorized). Each row also bumps the sync dirty flag.
  Future<void> updateHabitGroupIds(
    List<HabitUUID> uuids,
    List<String?> groupIds,
  );

  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  });

  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  });
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
    Map<String, GroupUUID>? groupUuidMapping,
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
      lastUntrackDate: data.firstUntrackedDate,
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

  ReminderStatus _resolveReminderStatus() =>
      _notifyConfig?.getReminderStatus(NotificationChannelId.habitReminder) ??
      const ReminderStatus.ready();

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
    }.values.toList(growable: false);
    await _processHabitReminderTrigger(
      HabitReminderTrigger.mutation(loadedHabits: updatedHabits),
    );
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
      includeNullKeys: [
        ...HabitDBCellKey.nullableColorKeys,
        HabitDBCellKey.groupId,
        if (withReminder) ...[
          HabitDBCellKey.remindCustom,
          HabitDBCellKey.remindQuestion,
          HabitDBCellKey.dailyGoalExtra,
        ],
      ],
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
      return initedCollection..loadFromDBQueryResult(habitLoaded, recordLoaded);
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

    // Resolve group display info from the habit's groupId FK.
    final groupTask = cell.groupId != null
        ? groupDBHelper.loadGroupByUUID(cell.groupId!)
        : null;

    final records = await recordLoadTask;
    final group = await groupTask;
    final data = HabitDetailData.fromDBQueryCell(
      cell,
      groupData: group != null ? HabitGroupData.fromDBQueryCell(group) : null,
    );
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

  @override
  Future<void> updateHabitGroupIds(
    List<HabitUUID> uuids,
    List<String?> groupIds,
  ) => habitDBHelper.updateSelectedHabitsGroupId(uuids, groupIds);

  Future<void> _updateHabitReminder(HabitSummaryData data) {
    if (!_resolveReminderStatus().isReady) return Future.value();
    return _reminderRuntime.updateHabitReminder(data, channelData: channelData);
  }

  Future<void> _processHabitReminderTrigger(
    HabitReminderTrigger trigger,
  ) async {
    final loadedHabits = switch (trigger) {
      _HabitReminderStartupTrigger() ||
      _HabitReminderRestartTrigger() ||
      _HabitReminderDateChangeTrigger() =>
        await _loadHabitReminderTriggerHabits(),
      _HabitReminderMutationTrigger(:final loadedHabits) => loadedHabits,
      _HabitReminderReconcileTrigger(:final habitUUIDs) =>
        await _loadHabitReminderTriggerHabits(habitUUIDs: habitUUIDs),
    };
    await updateHabitReminders(loadedHabits);
  }

  Future<void> _repairHabitReminders(HabitReminderRepairParams params) async {
    final loadedHabits = switch (params) {
      _HabitReminderLoadedHabitsRepairParams(:final loadedHabits) =>
        loadedHabits,
    };
    await updateHabitReminders(loadedHabits);
  }

  @override
  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  }) => _repairHabitReminders(params);

  Future<Iterable<HabitSummaryData>> _loadHabitReminderTriggerHabits({
    List<HabitUUID>? habitUUIDs,
  }) async {
    final loadedHabits = await loadHabitSummaryCollectionData(
      habitUUIDs: habitUUIDs,
    );
    return loadedHabits.values;
  }

  @override
  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  }) async {
    final trigger = switch (params) {
      _HabitReminderStartupRefreshParams() =>
        const HabitReminderTrigger.startup(),
      _HabitReminderRestartRefreshParams() =>
        const HabitReminderTrigger.restart(),
      _HabitReminderDateChangeRefreshParams() =>
        const HabitReminderTrigger.dateChange(),
      _HabitReminderRefreshUuidParams(:final habitUUIDs) =>
        HabitReminderTrigger.reconcile(habitUUIDs: habitUUIDs),
    };
    await _processHabitReminderTrigger(trigger);
  }

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
    final changedHabits = updatedHabits.values.toList(growable: false);
    await _processHabitReminderTrigger(
      HabitReminderTrigger.mutation(loadedHabits: changedHabits),
    );
  }

  Future<void> _updateSavedHabitReminder(HabitDBCell? cell) async {
    if (cell == null) return;
    final habit = HabitSummaryData.fromDBQueryCell(cell);
    await _processHabitReminderTrigger(
      HabitReminderTrigger.mutation(loadedHabits: [habit]),
    );
  }

  //#region import and export
  HabitExporter getExporter({List<HabitUUID>? uuidList}) =>
      HabitExporter(habitDBHelper, recordDBHelper, uuidList: uuidList);

  HabitImport getHabitImporter(
    Iterable<Object?> jsonData, {
    Map<String, GroupUUID>? groupUuidMapping,
  }) => HabitImport(
    habitDBHelper,
    recordDBHelper,
    data: jsonData,
    groupUuidMapping: groupUuidMapping,
  );

  @override
  Future<Iterable<HabitExportData>> loadHabitExportData({
    List<HabitUUID>? uuidList,
    bool withRecords = true,
  }) => getExporter(uuidList: uuidList).exportData(withRecords: withRecords);

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) => getHabitImporter(
    jsonData,
    groupUuidMapping: groupUuidMapping,
  ).importData(withRecords: withRecords);

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) =>
      getHabitImporter(jsonData).habitsCount;
  //#endregion
}
