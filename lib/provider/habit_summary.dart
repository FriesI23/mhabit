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

import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../extension/iterable_extensions.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../model/habit_date.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_score.dart';
import '../model/habit_stat.dart';
import '../model/habit_status.dart';
import '../model/habit_summary.dart';
import '../persistent/db_helper_provider.dart';
import '../reminders/notification_service.dart';
import 'app_sync.dart';
import 'commons.dart';
import 'utils.dart';

part 'habit_summary.g.dart';

class HabitSummaryViewModel extends ChangeNotifier
    with
        ScrollControllerChangeNotifierMixin,
        NotificationChannelDataMixin,
        DBHelperLoadedMixin,
        DBOperationsMixin
    implements ProviderMounted, HabitSummaryDirtyMarker {
  static final _fakeValueListenable = ValueNotifier(0);

  // scroll controller
  final LinkedScrollControllerGroup _horizonalScrollControllerGroup;
  // dispatcher
  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;
  late final DispatcherForHabitDetail forHabitDetail;
  late final DispatcherForHabitsStatusChanger forHabitsStatusChanger;
  // data
  final _data = HabitSummaryDataCollection();
  var _sortableCache = const _HabitsSortableCache(
    sortType: defaultSortType,
    sortDirection: defaultSortDirection,
    filter: HabitsDisplayFilter.withDefault(),
  );
  final _selectorData = _SelectedHabitsData();
  final _last30daysProgressChangeData = HabitLast30DaysProgressChangeData();
  // status
  CancelableCompleter<void>? _loading;
  bool _reloadDBToggleSwich = false;
  bool _nextRefreshClearSnackBar = false;
  bool _reloadUIToggleSwitch = false;
  bool _isCalandarExpanded = false;
  bool _isInEditMode = false;
  bool _canBeDragged = true;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;
  // sync from appsync
  late WeakReference<ValueListenable<num>> _onAutoSyncTick;
  // data

  HabitSummaryViewModel({
    required ScrollController verticalScrollController,
    required LinkedScrollControllerGroup horizonalScrollControllerGroup,
  }) : _horizonalScrollControllerGroup = horizonalScrollControllerGroup {
    initVerticalScrollController(notifyListeners, verticalScrollController);
    forHabitDetail = DispatcherForHabitDetail(this);
    forHabitsStatusChanger = DispatcherForHabitsStatusChanger(this);
    _onAutoSyncTick = WeakReference(_fakeValueListenable);
  }

  LinkedScrollControllerGroup get horizonalScrollControllerGroup =>
      _horizonalScrollControllerGroup;

  AnimatedListController get dispatcherLinkedController =>
      _dispatcher.controller;

  AnimatedListDiffBuilder<List<HabitSortCache>> get dispatcherLinkedBuilder =>
      _dispatcher.builder;

  @override
  bool get mounted => _mounted;

  int get firstday => _firstday;

  void updateFirstday(int newFirstDay) {
    final day = standardizeFirstDay(newFirstDay);
    if (kDebugMode && newFirstDay != day) {
      throw UnknownWeekdayNumber(newFirstDay);
    }
    _firstday = day;
  }

  HabitSummaryStatusCache get currentState => HabitSummaryStatusCache(
        isAppbarPinned: isAppbarPinned,
        reloadDBToggleSwich: reloadDBToggleSwich,
        reloadUIToggleSwitch: reloadUIToggleSwitch,
        isClandarExpanded: isCalendarExpanded,
        isInEditMode: isInEditMode,
      );

  bool get isCalendarExpanded => _isCalandarExpanded;

  Future<void> updateCalendarExpanedStatus(bool newValue,
      {Duration? scrollDuration,
      bool waitingScroll = false,
      bool listen = true}) async {
    if (newValue != _isCalandarExpanded) {
      _isCalandarExpanded = newValue;
      if (scrollDuration == Duration.zero) {
        _horizonalScrollControllerGroup.jumpTo(0);
      } else {
        final future = _horizonalScrollControllerGroup.animateTo(0,
            duration: scrollDuration ?? const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
        if (waitingScroll) await future;
      }
      if (listen) notifyListeners();
    }
  }

  bool get canBeDragged => _canBeDragged;

  bool get reloadDBToggleSwich => _reloadDBToggleSwich;

  bool get reloadUIToggleSwitch => _reloadUIToggleSwitch;

  int get habitCount => _data.length;

  @override
  Future<void> bumpHatbitVersion(HabitSummaryData data) async {
    data.bumpVersion();
    // add reminder
    await _regrHabitReminder(data);
  }

  Future<void> _regrHabitReminder(HabitSummaryData data) async {
    try {
      switch (data.status) {
        case HabitStatus.activated:
          if (data.reminder != null) {
            await NotificationService().regrHabitReminder(
              id: data.id,
              uuid: data.uuid,
              name: data.name,
              quest: data.reminderQuest,
              reminder: data.reminder!,
              lastUntrackDate: data.getFirstUnTrackedDate(),
              details: channelData.habitReminder,
            );
          }
          break;
        case HabitStatus.unknown:
        case HabitStatus.deleted:
        case HabitStatus.archived:
          await NotificationService().cancelHabitReminder(id: data.id);
          break;
      }
    } on Exception catch (e) {
      appLog.notify.error("$runtimeType._regrHabitReminder",
          ex: ["catch err when try regr reminder"], error: e);
    }
  }

  HabitSummaryData? get earliestSummaryDataStartDate {
    HabitSummaryData? result;
    _data.forEach((k, v) {
      if (result == null || (result!.startDate > v.startDate)) {
        result = v;
      }
    });
    return result;
  }

  void initDispatcher(
      AnimatedListDiffListDispatcher<HabitSortCache> dispatcher) {
    _dispatcher = dispatcher;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _onAutoSyncTick.target?.removeListener(onAutoSyncTick);
    _dispatcher.discard();
    disposeVerticalScrollController();
    _cancelLoading();
    super.dispose();
    _mounted = false;
  }

  bool rockReloadUIToggleSwitch() {
    _reloadUIToggleSwitch = !_reloadUIToggleSwitch;
    notifyListeners();
    return _reloadUIToggleSwitch;
  }

  bool rockreloadDBToggleSwich({bool clearSnackBar = true}) {
    _reloadDBToggleSwich = !_reloadDBToggleSwich;
    _nextRefreshClearSnackBar = clearSnackBar;
    _cancelLoading();
    notifyListeners();
    return _reloadDBToggleSwich;
  }

  bool consumeClearSnackBarFlag() {
    final tmp = _nextRefreshClearSnackBar;
    _nextRefreshClearSnackBar = false;
    return tmp;
  }

  UniqueKey getHabitInsideVersion(HabitUUID uuid) {
    final data = _data.getHabitByUUID(uuid);
    return data != null ? data.diryMark : UniqueKey();
  }

  void _calcHabitAutoComplateRecords(HabitSummaryData data) {
    final now = HabitDate.now();
    _last30daysProgressChangeData.clearStatistic(data.uuid);
    data.reCalculateAutoComplateRecords(
      firstDay: firstday,
      onScoreChange: (fromDate, toDate, fromScore, toScore) {
        if (!_isNeedIncludeInLast30DaysStatistic(data)) return;
        for (var entry in HabitScoreChangedProtoData(
          fromDate: fromDate,
          toDate: toDate,
          fromScore: fromScore,
          toScore: toScore,
        ).expandToDate()) {
          _last30daysProgressChangeData.addStatistic(
              data, now, entry.key, entry.value);
        }
      },
    );
  }

  void _cancelLoading() {
    final loading = _loading;
    if (loading == null) return;

    void onCancelled() {
      if (_loading == loading) _loading = null;
      appLog.load.info("$runtimeType._cancelLoading",
          ex: ['cancelled', loading.hashCode]);
    }

    appLog.load.info("$runtimeType._cancelLoading", ex: [loading.hashCode]);
    if (loading.isCompleted || loading.isCanceled) {
      onCancelled();
    } else {
      loading.operation.cancel();
      onCancelled();
    }
  }

  Future loadData({bool listen = true, bool inFutureBuilder = false}) async {
    final crtLoading = _loading;
    if (crtLoading != null && !crtLoading.isCanceled) {
      appLog.load.warn("$runtimeType.loadData",
          ex: ["data already loaded", crtLoading.isCompleted]);
      return crtLoading.operation.valueOrCancellation();
    }

    final loading = _loading = CancelableCompleter<void>();

    void loadingFailed(List errmsg) {
      appLog.load.error("$runtimeType.load",
          ex: [...errmsg, loading.hashCode],
          stackTrace: LoggerStackTrace.from(StackTrace.current));
      if (!loading.isCompleted) {
        loading.completeError(
            FlutterError(errmsg.join(" ")), StackTrace.current);
      }
    }

    void loadingCancelled() {
      appLog.load
          .info("$runtimeType.load", ex: ['cancelled', loading.hashCode]);
    }

    Future<void> loadingData() async {
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      appLog.load.debug("$runtimeType.load",
          ex: ["loading data", loading.hashCode, listen, inFutureBuilder]);

      // init habits
      final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection();
      final recordLoadTask = recordDBHelper.loadAllRecords();
      final habitLoaded = await habitLoadTask;
      final recordLoaded = await recordLoadTask;
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;

      _data.initDataFromDBQueuryResult(habitLoaded, recordLoaded);
      _data.forEach((_, habit) => _calcHabitAutoComplateRecords(habit));
      _resortData();

      // init reminders
      final futureList = <Future>[];
      _data.forEach((_, habit) => futureList.add(_regrHabitReminder(habit)));
      await Future.wait(futureList);
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;

      // complete
      loading.complete();
      // reload
      if (listen) {
        if (!inFutureBuilder) _reloadDBToggleSwich = !_reloadDBToggleSwich;
        notifyListeners();
      }
      appLog.load.debug("$runtimeType.load",
          ex: ["loaded", loading.hashCode, listen, inFutureBuilder]);
    }

    loadingData();
    return loading.operation.valueOrCancellation();
  }

  HabitSummaryData? getHabit(HabitUUID habitUUID) {
    return _data.getHabitByUUID(habitUUID);
  }

  bool addNewData(HabitSummaryData cell, {bool listen = false}) {
    final bool addResult = _data.addNewHabit(cell, forceAdd: false);
    final data = _data.getHabitByUUID(cell.uuid);
    if (data != null) _calcHabitAutoComplateRecords(data);
    resortData();
    if (listen) notifyListeners();
    return addResult;
  }

  //#region: edit mode
  bool get isInEditMode => _isInEditMode;

  void switchToEditMode(
      {bool clearAllSelected = true, bool listen = true}) async {
    _canBeDragged = false;
    _isInEditMode = true;
    if (clearAllSelected) clearAllSelectHabits();
    await updateCalendarExpanedStatus(false,
        scrollDuration: Duration.zero, waitingScroll: true, listen: false);
    if (listen) notifyListeners();
  }

  void exitEditMode({bool clearAllSelected = true, bool listen = true}) {
    if (clearAllSelected) clearAllSelectHabits();
    _canBeDragged = true;
    _isInEditMode = false;
    if (listen) notifyListeners();
  }

  void exitEditModeOnly({bool listen = true}) {
    _isInEditMode = false;
    if (listen) notifyListeners();
  }
  //#endregion

  //#region statistics
  HabitSummaryStatisticsData get statisticsData {
    int archivedCount = 0, complatedCount = 0, inProgressCount = 0;
    final now = HabitDate.now();
    _data.forEach((habitUUID, summaryData) {
      if (summaryData.status == HabitStatus.archived) {
        archivedCount++;
      } else if (summaryData.isComplated) {
        complatedCount++;
      } else if (!summaryData.startDate.isAfter(now)) {
        inProgressCount++;
      }
    });
    final firstThreeData = <HabitRangeDayStatistic>[];
    for (var entry in _last30daysProgressChangeData.iterable) {
      firstThreeData.add(entry);
      if (firstThreeData.length >= 3) break;
    }
    return HabitSummaryStatisticsData(
      currentArchivedCount: archivedCount,
      currentComplatedCount: complatedCount,
      currentInProgressCount: inProgressCount,
      currentPopularityData: firstThreeData,
    );
  }

  bool _isNeedIncludeInLast30DaysStatistic(HabitSummaryData data) {
    return data.isActived;
  }
  //#endregion

  //#region sortbale habits list
  List<HabitSortCache> get lastSortedDataCache =>
      _sortableCache.lastSortedDataCache;

  void updateSortOptions(HabitDisplaySortType sortType,
          HabitDisplaySortDirection sortDirection) =>
      _sortableCache = _sortableCache.copyWith(
          sortDirection: sortDirection, sortType: sortType);

  void updateHabitDisplayFilter(HabitsDisplayFilter newFilter) =>
      _sortableCache = _sortableCache.copyWith(filter: newFilter);

  HabitSortCache? getHabitBySortId(int index) =>
      _sortableCache.getSortCache(index);

  void resortData({bool listen = true}) {
    if (!(_loading?.isCompleted ?? false)) return;
    _resortData();
    if (listen) notifyListeners();
  }

  void _resortData() {
    final newObj = _sortableCache.copyWithSortableData(_data);
    _saveAndDispatch(newObj);
  }

  void _saveAndDispatch(_HabitsSortableCache newSortbaleData) {
    if (identical(newSortbaleData.lastSortedDataCache,
        _sortableCache.lastSortedDataCache)) {
      appLog.load.warn("$runtimeType._saveAndDispatch",
          ex: ["fixed cache", newSortbaleData, _sortableCache]);
      newSortbaleData = newSortbaleData.copyWith(
          lastSortedDataCache: List.of(newSortbaleData.lastSortedDataCache));
    }
    _dispatcher.dispatchNewList(newSortbaleData.lastSortedDataCache);
    _sortableCache = newSortbaleData;
  }
  //#endregion

  //#region exporter
  Iterable<HabitUUID> getExportUseSelectedHabitUUID() => getSelectedHabitsData()
      .where((element) => element != null)
      .map((e) => e!.uuid);
  //#endregion

  //#region: hasbits selector
  int get selectedHabitsCount => _selectorData.selecedCount;

  bool get isNoHabitSelected => _selectorData.nothingSelected;

  HabitSummarySelectedStatistic get selectStatistic {
    int activatedNum = 0;
    int archivedNum = 0;
    for (var data in _selectorData.selectedColl.map(getHabit)) {
      if (data == null) {
        continue;
      } else if (data.status == HabitStatus.activated) {
        activatedNum++;
      } else if (data.status == HabitStatus.archived) {
        archivedNum++;
      }
    }
    return HabitSummarySelectedStatistic(
        activated: activatedNum, archived: archivedNum);
  }

  bool isHabitSelected(HabitUUID uuid) => _selectorData.isSelected(uuid);

  void selectHabit(HabitUUID uuid, {bool listen = true}) {
    _selectorData.select(uuid);
    if (listen) notifyListeners();
  }

  void unselectHabit(HabitUUID uuid, {bool listen = true}) {
    _selectorData.unselect(uuid);
    if (isNoHabitSelected) exitEditMode(listen: false);
    if (listen) notifyListeners();
  }

  void clearAllSelectHabits() => _selectorData.clearAll();

  void selectAllHabit({bool listen = true}) {
    final results = _sortableCache.lastSortedDataCache
        .whereType<HabitSummaryDataSortCache>()
        .map((e) => selectHabit(e.uuid, listen: false))
        .toList();
    if (results.isNotEmpty && listen) notifyListeners();
  }

  Iterable<HabitSummaryData?> getSelectedHabitsData() =>
      _selectorData._selectUUIDColl.map(getHabit);
  //#endregion

  //#region: auto sync
  void updateFromAppSync(AppSyncViewModel appSync) {
    if (appSync.onAutoSyncTick != _onAutoSyncTick.target) {
      final oldTicker = _onAutoSyncTick.target?..removeListener(onAutoSyncTick);
      _onAutoSyncTick =
          WeakReference(appSync.onAutoSyncTick..addListener(onAutoSyncTick));
      appLog.habit.info("updateFromAppSync", ex: [
        "regr listener",
        _onAutoSyncTick.target.hashCode,
        oldTicker?.hashCode
      ]);
    }
  }

  void onAutoSyncTick() {
    appLog.habit.debug("onAutoSyncTick", ex: [reloadDBToggleSwich]);
    rockreloadDBToggleSwich(clearSnackBar: false);
  }
  //#endregion

  //#region actions
  Future<HabitSummaryRecord?> changeRecordStatus(
      HabitUUID habitUUID, HabitRecordDate date,
      {bool listen = true}) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;

    final util = ChangeRecordStatusHelper(date: date, data: data);
    final recordTuple = util.getNewRecordOnTap();
    if (recordTuple == null) return null;

    final orgRecord = recordTuple.item1;
    final record = recordTuple.item2;
    final isNew = recordTuple.item3;

    await saveHabitRecordToDB(data.id, data.uuid, record, isNew: isNew);

    final result = data.addRecord(record, replaced: true);
    _calcHabitAutoComplateRecords(data);

    appLog.value.info("$runtimeType.onTapToChangeRecordStatus",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);

    if (listen) notifyListeners();

    await bumpHatbitVersion(data);
    return record;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
      HabitUUID habitUUID, HabitRecordDate date, HabitDailyGoal newValue,
      {bool listen = true}) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;

    final util = ChangeRecordStatusHelper(date: date, data: data);
    final recordTuple = util.getNewRecordOnLongTap(newValue);
    if (recordTuple == null) return null;

    final orgRecord = recordTuple.item1;
    final record = recordTuple.item2;
    final isNew = recordTuple.item3;

    await saveHabitRecordToDB(data.id, data.uuid, record, isNew: isNew);

    final result = data.addRecord(record, replaced: true);
    _calcHabitAutoComplateRecords(data);

    appLog.value.info("onLongPressChangeRecordValue",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);

    if (listen) notifyListeners();
    await bumpHatbitVersion(data);
    return record;
  }

  Future<void> _writeChangedSortPositionToDB() async {
    final filteredlastSortedDataCache = lastSortedDataCache
        .whereType<HabitSummaryDataSortCache>()
        .where((e) => e.data != null)
        .toList();

    final posList = filteredlastSortedDataCache
        .map((e) => e.data!.sortPostion)
        .makeUniqueAndIncreasing(
          sortPositionConflictIncreaseStep,
          isSorted: false,
          decimalPlaces: sortPositionConflictDecimalPlaces,
        );

    final changedUUIDList = <HabitUUID>[];
    final changedPosList = <num>[];
    for (var i = 0; i < filteredlastSortedDataCache.length; i++) {
      final data = filteredlastSortedDataCache[i];
      final pos = posList[i];
      if (data.data!.sortPostion != pos) {
        data.data!.sortPostion = pos;
        changedUUIDList.add(data.uuid);
        changedPosList.add(pos);
      }
    }

    appLog.habit.debug("$runtimeType.rewriteAllHabitsSortPostion",
        ex: [changedUUIDList, changedPosList]);
    await habitDBHelper.updateSelectedHabitsSortPostion(
        changedUUIDList, changedPosList);
  }

  Future<HabitSummaryRecord?> changeRecordReason(
      HabitUUID habitUUID, HabitRecordDate date, String newReason,
      {bool listen = true}) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;
    final record = data.getRecordByDate(date);
    if (record == null) return null;

    await saveHabitRecordToDB(data.id, data.uuid, record,
        isNew: false, withReason: newReason);

    if (listen) notifyListeners();
    return record;
  }

  Future<void> onHabitReorderComplate(int index, int dropIndex) {
    lastSortedDataCache.insert(dropIndex, lastSortedDataCache.removeAt(index));
    return _writeChangedSortPositionToDB();
  }

  Future<List<HabitStatusChangedRecord>> _changeHabitsStatus(
      List<HabitUUID> uuidList, HabitStatus newStatus) async {
    appLog.habit
        .debug("$runtimeType.changeHabitsStatus", ex: [uuidList, newStatus]);
    await habitDBHelper.updateSelectedHabitStatus(uuidList, newStatus);

    final result = <HabitStatusChangedRecord>[];

    Future<void> aTask(HabitSummaryData data) async {
      final orgStatus = data.status;
      data.status = newStatus;
      bumpHatbitVersion(data);
      _calcHabitAutoComplateRecords(data);
      result.add(HabitStatusChangedRecord(
          habitUUID: data.uuid, newStatus: newStatus, orgStatus: orgStatus));
    }

    final futureList = <Future>[];
    for (var habitUUID in uuidList) {
      final data = getHabit(habitUUID);
      if (data == null) continue;
      futureList.add(aTask(data));
    }

    await Future.wait(futureList);
    return result;
  }

  Future<void> revertHabitsStatus(
      List<HabitStatusChangedRecord> recordList) async {
    appLog.habit.info("$runtimeType.revertHabitsStatus", ex: [recordList]);
    final recordMap = <HabitStatus, List<HabitUUID>>{};
    for (var record in recordList) {
      if (!recordMap.containsKey(record.orgStatus)) {
        recordMap[record.orgStatus] = [];
      }
      recordMap[record.orgStatus]!.add(record.habitUUID);
    }

    appLog.habit.debug("$runtimeType.revertHabitsStatus do",
        ex: [recordList, recordMap]);
    for (var r in recordMap.entries) {
      await _changeHabitsStatus(r.value, r.key);
    }

    resortData();
  }

  Future<List<HabitStatusChangedRecord>?> archivedSelectedHabits() async {
    final realNeedArchivedUUID = _selectorData.selectedColl
        .map(getHabit)
        .whereNotNull()
        .where((e) => e.status != HabitStatus.archived)
        .map((e) => e.uuid)
        .toList();

    if (realNeedArchivedUUID.isEmpty) {
      appLog.value.warn("$runtimeType.archivedSelectedHabits",
          beforeVal: _selectorData,
          afterVal: realNeedArchivedUUID,
          ex: ["real need archived habit uuid not found"]);
      return null;
    }

    final result =
        await _changeHabitsStatus(realNeedArchivedUUID, HabitStatus.archived);

    if (!_sortableCache.filter.allowArchivedHabits) {
      final filteredSortCache = lastSortedDataCache
          .where((element) => !(element is HabitSummaryDataSortCache &&
              realNeedArchivedUUID.contains(element.uuid)))
          .toList();
      _sortableCache =
          _sortableCache.copyWith(lastSortedDataCache: filteredSortCache);
      _saveAndDispatch(_sortableCache);
    }

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> unarchivedSelectedHabits() async {
    final realNeedUnarchivedUUID = _selectorData.selectedColl
        .map(getHabit)
        .whereNotNull()
        .where((e) => e.status == HabitStatus.archived)
        .map((e) => e.uuid)
        .toList();

    if (realNeedUnarchivedUUID.isEmpty) {
      appLog.value.warn("$runtimeType.unarchivedSelectedHabits",
          beforeVal: _selectorData,
          afterVal: realNeedUnarchivedUUID,
          ex: ["real need unarchived habit uuid not found"]);
      return null;
    }

    final result = await _changeHabitsStatus(
        realNeedUnarchivedUUID, HabitStatus.activated);

    if (_sortableCache.filter.allowArchivedHabits) {
      resortData(listen: false);
    }

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> deleteSelectedHabits() async {
    final realNeedDeletedUUID = _selectorData.selectedColl
        .map(getHabit)
        .whereNotNull()
        .where((e) => e.status != HabitStatus.deleted)
        .map((e) => e.uuid)
        .toList();

    if (realNeedDeletedUUID.isEmpty) {
      appLog.value.warn("$runtimeType.deleteSelectedHabits",
          beforeVal: _selectorData,
          afterVal: realNeedDeletedUUID,
          ex: ["real need deleted habit uuid not found"]);
      return null;
    }

    final result =
        await _changeHabitsStatus(realNeedDeletedUUID, HabitStatus.deleted);

    resortData(listen: false);

    exitEditMode();
    return result;
  }
  //#endregion

  //#region debug
  String debugGetDataString() {
    assert(kDebugMode, true);
    return _data.toString();
  }
  //#endregion
}

@CopyWith(skipFields: true)
class _HabitsSortableCache {
  final HabitDisplaySortType sortType;
  final HabitDisplaySortDirection sortDirection;
  final HabitsDisplayFilter filter;
  final List<HabitSortCache> lastSortedDataCache;

  const _HabitsSortableCache(
      {required this.sortType,
      required this.sortDirection,
      required this.filter,
      this.lastSortedDataCache = const []});

  HabitSortCache? getSortCache(int index) {
    if (index < 0 || index >= lastSortedDataCache.length) {
      return null;
    } else {
      return lastSortedDataCache[index];
    }
  }

  _HabitsSortableCache copyWithSortableData(HabitSummaryDataCollection data) =>
      copyWith(
        lastSortedDataCache: data
            .sort(sortType, sortDirection)
            .where(filter.getDisplayFilterFunction())
            .map((e) => HabitSummaryDataSortCache(data: e))
            .toList(),
      );

  @override
  String toString() =>
      "$runtimeType(st=$sortType,sd=$sortDirection,flt=$filter,"
      "cache=$lastSortedDataCache)";
}

class _SelectedHabitsData {
  final Set<HabitUUID> _selectUUIDColl = {};

  _SelectedHabitsData();

  Iterable<HabitUUID> get selectedColl => _selectUUIDColl;

  int get selecedCount => _selectUUIDColl.length;

  bool get nothingSelected => selecedCount <= 0;

  bool isSelected(HabitUUID uuid) => _selectUUIDColl.contains(uuid);

  void select(HabitUUID uuid) => _selectUUIDColl.add(uuid);

  void unselect(HabitUUID uuid) => _selectUUIDColl.remove(uuid);

  void clearAll() => _selectUUIDColl.clear();

  @override
  String toString() => "$runtimeType(data=$_selectUUIDColl)";
}

abstract class _ForSummaryDispatcher {
  final HabitSummaryViewModel _root;

  const _ForSummaryDispatcher(this._root);
}

final class DispatcherForHabitDetail extends _ForSummaryDispatcher {
  DispatcherForHabitDetail(super.root);

  String get _clsName => "${_root.runtimeType}.DispatcherForHabitDetail";

  Future<List<HabitStatusChangedRecord>?> onConfirmToArchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToArchiveHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    final habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        await _root._changeHabitsStatus([habitUUID], HabitStatus.archived);
    if (_root.mounted) _root.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToUnarchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToUnarchiveHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    final habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        await _root._changeHabitsStatus([habitUUID], HabitStatus.activated);
    if (_root.mounted) _root.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToDeleteHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToDeleteHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    final habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        await _root._changeHabitsStatus([habitUUID], HabitStatus.deleted);
    if (_root.mounted) _root.resortData();
    return recordList;
  }
}

final class DispatcherForHabitsStatusChanger extends _ForSummaryDispatcher {
  DispatcherForHabitsStatusChanger(super.root);

  String get _clsName => "${_root.runtimeType}.DispatcherForHabitsStausChanger";

  Future onHabitDataChanged() async {
    appLog.habit.info("$_clsName.onHabitDataChanged");
    if (!_root.mounted) return null;
    _root.exitEditMode();
    _root.rockreloadDBToggleSwich(clearSnackBar: false);
  }
}
