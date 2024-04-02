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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../model/habit_date.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_score.dart';
import '../model/habit_stat.dart';
import '../model/habit_status.dart';
import '../model/habit_summary.dart';
import '../persistent/db_helper_provider.dart';
import '../reminders/notification_service.dart';
import '_utils/habit_record_utils.dart';
import 'commons.dart';

mixin _HabitSummarySortableMixin on _HabitSummaryViewModel {
  List<HabitSortCache> _lastSortedDataCache = [];
  late HabitDisplaySortType _sortType;
  late HabitDisplaySortDirection _sortDirection;
  late HabitsDisplayFilter _habitDisplayFilter;

  AnimatedListController get dispatcherLinkedController =>
      _dispatcher.controller;

  AnimatedListDiffBuilder<List<HabitSortCache>> get dispatcherLinkedBuilder =>
      _dispatcher.builder;

  List<HabitSortCache> get lastSortedDataCache => _lastSortedDataCache;

  void updateSortOptions(
      HabitDisplaySortType sortType, HabitDisplaySortDirection sortDirection) {
    _sortType = sortType;
    _sortDirection = sortDirection;
  }

  void updateHabitDisplayFilter(HabitsDisplayFilter newFilter) {
    _habitDisplayFilter = newFilter;
  }

  HabitSortCache? getHabitBySortId(int index) {
    if (index < 0 || index >= _lastSortedDataCache.length) {
      return null;
    } else {
      return _lastSortedDataCache[index];
    }
  }

  void resortData() {
    var result = _data.sort(_sortType, _sortDirection);
    var newSortCache = result
        .where(_habitDisplayFilter.getDisplayFilterFunction())
        .map((e) => HabitSummaryDataSortCache(data: e))
        .toList();

    saveAndDispatchLastSortedData(newSortCache);
  }

  void saveAndDispatchLastSortedData(List<HabitSortCache> result) {
    _lastSortedDataCache = result;
    _dispatcher.dispatchNewList(_lastSortedDataCache);
  }
}

mixin _HabitSummarySelectorMixin on _HabitSummaryViewModel {
  final Set<HabitUUID> _selectUUIDColl = {};

  int get selectedHabitsCount => _selectUUIDColl.length;

  bool get isNoHabitSelected => selectedHabitsCount <= 0;

  bool isHabitSelected(HabitUUID uuid) => _selectUUIDColl.contains(uuid);

  void selectHabit(HabitUUID uuid) {
    // debugPrint('selectHabit:: $uuid $_selectUUIDColl');
    _selectUUIDColl.add(uuid);
  }

  void unselectHabit(HabitUUID uuid) {
    // debugPrint('unselectHabit:: $uuid $_selectUUIDColl');
    _selectUUIDColl.remove(uuid);
  }

  void clearAllSelectHabits() {
    _selectUUIDColl.clear();
  }
}

mixin _HabitSummaryStatisticsMixin on _HabitSummaryViewModel {
  HabitSummaryStatisticsData _statisticsData = HabitSummaryStatisticsData.zero;
  final HabitLast30DaysProgressChangeData _last30daysProgressChangeData =
      HabitLast30DaysProgressChangeData();

  HabitSummaryStatisticsData get statisticsData => _statisticsData;
  set statisticsData(HabitSummaryStatisticsData newData) {
    _statisticsData = newData;
  }

  Iterable<HabitRangeDayStatistic> getLast30DaysProgressChangeData() =>
      _last30daysProgressChangeData.iterable;

  bool isNeedIncludeInLast30DaysStatistic(HabitSummaryData data) {
    return data.isActived;
  }

  void addLast30DaysScoreChangeStatistic(
      HabitSummaryData data, HabitDate initDate, HabitDate date, num score) {
    _last30daysProgressChangeData.addStatistic(data, initDate, date, score);
  }
}

abstract class _HabitSummaryViewModel extends ChangeNotifier {
  // scroll controller
  final LinkedScrollControllerGroup _horizonalScrollControllerGroup;
  // dispatcher
  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;
  late final DispatcherForHabitDetail forHabitDetail;
  // data
  final HabitSummaryDataCollection _data = HabitSummaryDataCollection();
  // status
  Future? dataloadingFutureCache;
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

  _HabitSummaryViewModel({
    required LinkedScrollControllerGroup horizonalScrollControllerGroup,
  }) : _horizonalScrollControllerGroup = horizonalScrollControllerGroup;

  bool get _isDataLoaded => dataloadingFutureCache != null;
}

class HabitSummaryViewModel extends _HabitSummaryViewModel
    with
        ScrollControllerChangeNotifierMixin,
        _HabitSummarySortableMixin,
        _HabitSummarySelectorMixin,
        _HabitSummaryStatisticsMixin,
        NotificationChannelDataMixin,
        DBHelperLoadedMixin,
        DBOperationsMixin
    implements ProviderMounted, HabitSummaryDirtyMarkABC {
  HabitSummaryViewModel({
    required ScrollController verticalScrollController,
    required super.horizonalScrollControllerGroup,
  }) {
    initVerticalScrollController(notifyListeners, verticalScrollController);
    forHabitDetail = DispatcherForHabitDetail(this);
  }

  void initDispatcher(
      AnimatedListDiffListDispatcher<HabitSortCache> dispatcher) {
    _dispatcher = dispatcher;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _dispatcher.discard();
    disposeVerticalScrollController();
    super.dispose();
    _mounted = false;
  }

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

  @override
  HabitSummaryStatisticsData get statisticsData {
    int archivedCount = 0, complatedCount = 0, inProgressCount = 0;
    var now = HabitDate.now();
    _data.forEach((habitUUID, summaryData) {
      if (summaryData.status == HabitStatus.archived) {
        archivedCount++;
      } else if (summaryData.isComplated) {
        complatedCount++;
      } else if (!summaryData.startDate.isAfter(now)) {
        inProgressCount++;
      }
    });
    var firstThreeData = <HabitRangeDayStatistic>[];
    for (var entry in getLast30DaysProgressChangeData()) {
      firstThreeData.add(entry);
      if (firstThreeData.length >= 3) break;
    }
    return super.statisticsData.copyWith(
          currentArchivedCount: archivedCount,
          currentComplatedCount: complatedCount,
          currentInProgressCount: inProgressCount,
          currentPopularityData: firstThreeData,
        );
  }

  LinkedScrollControllerGroup get horizonalScrollControllerGroup =>
      _horizonalScrollControllerGroup;

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
        var future = _horizonalScrollControllerGroup.animateTo(0,
            duration: scrollDuration ?? const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
        if (waitingScroll) await future;
      }
      if (listen) notifyListeners();
    }
  }

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

  HabitSummarySelectedStatistic get selectStatistic {
    int activatedNum = 0;
    int archivedNum = 0;
    for (var data in _selectUUIDColl.map((habitUUID) => getHabit(habitUUID))) {
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

  HabitSummaryData? get earliestSummaryDataStartDate {
    HabitSummaryData? result;
    _data.forEach((k, v) {
      if (result == null || (result!.startDate > v.startDate)) {
        result = v;
      }
    });
    return result;
  }

  bool rockReloadUIToggleSwitch() {
    _reloadUIToggleSwitch = !_reloadUIToggleSwitch;
    notifyListeners();
    return _reloadUIToggleSwitch;
  }

  bool rockreloadDBToggleSwich({bool clearSnackBar = true}) {
    _reloadDBToggleSwich = !_reloadDBToggleSwich;
    dataloadingFutureCache = null;
    _nextRefreshClearSnackBar = clearSnackBar;
    notifyListeners();
    return _reloadDBToggleSwich;
  }

  bool consumeClearSnackBarFlag() {
    final tmp = _nextRefreshClearSnackBar;
    _nextRefreshClearSnackBar = false;
    return tmp;
  }

  UniqueKey getHabitInsideVersion(HabitUUID uuid) {
    var data = _data.getHabitByUUID(uuid);
    return data != null ? data.diryMark : UniqueKey();
  }

  @override
  void selectHabit(HabitUUID uuid, {bool listen = true}) {
    super.selectHabit(uuid);
    if (listen) notifyListeners();
  }

  @override
  void unselectHabit(HabitUUID uuid, {bool listen = true}) {
    super.unselectHabit(uuid);
    if (isNoHabitSelected) {
      exitEditMode(listen: false);
    }
    if (listen) notifyListeners();
  }

  void selectAllHabit({bool listen = true}) {
    _data.forEach((k, _) => selectHabit(k, listen: false));
    if (listen) notifyListeners();
  }

  Iterable<HabitSummaryData?> getSelectedHabitsData() sync* {
    for (var habitUUID in _selectUUIDColl) {
      yield getHabit(habitUUID);
    }
  }

  Iterable<HabitUUID> getExportUseSelectedHabitUUID() => getSelectedHabitsData()
      .where((element) => element != null)
      .map((e) => e!.uuid);

  void calcHabitAutoComplateRecords(HabitSummaryData data) {
    final now = HabitDate.now();
    _last30daysProgressChangeData.clearStatistic(data.uuid);
    data.reCalculateAutoComplateRecords(
      firstDay: firstday,
      onScoreChange: (fromDate, toDate, fromScore, toScore) {
        if (!isNeedIncludeInLast30DaysStatistic(data)) return;
        for (var entry in HabitScoreChangedProtoData(
          fromDate: fromDate,
          toDate: toDate,
          fromScore: fromScore,
          toScore: toScore,
        ).expandToDate()) {
          addLast30DaysScoreChangeStatistic(data, now, entry.key, entry.value);
        }
      },
    );
  }

  Future loadData({bool listen = true, bool inFutureBuilder = false}) async {
    if (_isDataLoaded) {
      appLog.load.warn("$runtimeType.loadData", ex: ["data already loaded"]);
      return;
    }
    // debugPrint('------ loadData:: $listen $_isDataLoaded');
    final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection();
    final recordLoadTask = recordDBHelper.loadAllRecords();
    _data.initDataFromDBQueuryResult(await habitLoadTask, await recordLoadTask);
    _data.forEach((_, habit) => calcHabitAutoComplateRecords(habit));
    super.resortData();
    if (listen) {
      if (!inFutureBuilder) _reloadDBToggleSwich = !_reloadDBToggleSwich;
      notifyListeners();
    }
    // init reminders
    final futureList = <Future>[];
    _data.forEach((_, habit) => futureList.add(_regrHabitReminder(habit)));
    await Future.wait(futureList);
  }

  @override
  void resortData({bool listen = true}) {
    // debugPrint('resortData:: listen=$listen, isDataLoaded=$_isDataLoaded');
    if (!_isDataLoaded) return;
    super.resortData();
    if (listen) notifyListeners();
  }

  HabitSummaryData? getHabit(HabitUUID habitUUID) {
    return _data.getHabitByUUID(habitUUID);
  }

  bool addNewData(HabitSummaryData cell, {bool listen = false}) {
    bool addResult = _data.addNewHabit(cell, forceAdd: false);
    final data = _data.getHabitByUUID(cell.uuid);
    if (data != null) calcHabitAutoComplateRecords(data);
    resortData();
    if (listen) notifyListeners();
    return addResult;
  }

  Future<HabitSummaryRecord?> onTapToChangeRecordStatus(
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

    var result = data.addRecord(record, replaced: true);
    calcHabitAutoComplateRecords(data);

    appLog.value.info("$runtimeType.onTapToChangeRecordStatus",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);

    if (listen) notifyListeners();

    await bumpHatbitVersion(data);
    return record;
  }

  Future<HabitSummaryRecord?> onLongPressChangeRecordValue(
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

    var result = data.addRecord(record, replaced: true);
    calcHabitAutoComplateRecords(data);

    appLog.value.info("onLongPressChangeRecordValue",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);

    if (listen) notifyListeners();
    await bumpHatbitVersion(data);
    return record;
  }

  Future<void> rewriteAllHabitsSortPostion() async {
    var posList = <num>[];
    for (var e in lastSortedDataCache) {
      if (e is HabitSummaryDataSortCache && e.data != null) {
        posList.add(e.data!.sortPostion);
      }
    }
    posList.sort();

    var changedUUIDList = <HabitUUID>[];
    var changedPosList = <num>[];
    var currentIndex = 0;
    for (var e in lastSortedDataCache) {
      if (e is HabitSummaryDataSortCache && e.data != null) {
        var currentPos = posList[currentIndex++];
        if (e.data!.sortPostion != currentPos) {
          e.data!.sortPostion = currentPos;
          changedUUIDList.add(e.uuid);
          changedPosList.add(currentPos);
        }
      }
    }

    appLog.habit.debug("$runtimeType.rewriteAllHabitsSortPostion",
        ex: [changedUUIDList, changedPosList]);
    await habitDBHelper.updateSelectedHabitsSortPostion(
        changedUUIDList, changedPosList);
  }

  Future<HabitSummaryRecord?> onLongPressChangeReason(
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

  void onHabitReorderComplate(int index, int dropIndex) async {
    lastSortedDataCache.insert(dropIndex, lastSortedDataCache.removeAt(index));
    await rewriteAllHabitsSortPostion();
  }

  Future<List<HabitStatusChangedRecord>> changeHabitsStatus(
      List<HabitUUID> uuidList, HabitStatus newStatus) async {
    appLog.habit
        .debug("$runtimeType.changeHabitsStatus", ex: [uuidList, newStatus]);
    await habitDBHelper.updateSelectedHabitStatus(uuidList, newStatus);

    final result = <HabitStatusChangedRecord>[];

    Future<void> aTask(HabitSummaryData data) async {
      final orgStatus = data.status;
      data.status = newStatus;
      bumpHatbitVersion(data);
      calcHabitAutoComplateRecords(data);
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

    appLog.habit.debug("$runtimeType.revertHabitsStatus do", ex: [recordList]);
    for (var r in recordMap.entries) {
      await changeHabitsStatus(r.value, r.key);
    }

    resortData();
  }

  Future<List<HabitStatusChangedRecord>?> archivedSelectedHabits() async {
    var realNeedArchivedUUID = <HabitUUID>[];
    for (var habitUUID in _selectUUIDColl) {
      if (getHabit(habitUUID)?.status != HabitStatus.archived) {
        realNeedArchivedUUID.add(habitUUID);
      }
    }

    if (realNeedArchivedUUID.isEmpty) {
      appLog.value.warn("$runtimeType.archivedSelectedHabits",
          beforeVal: _selectUUIDColl,
          afterVal: realNeedArchivedUUID,
          ex: ["real need archived habit uuid not found"]);
      return null;
    }

    var result =
        await changeHabitsStatus(realNeedArchivedUUID, HabitStatus.archived);

    if (!_habitDisplayFilter.allowArchivedHabits) {
      var filteredSortCache = List.of(
        lastSortedDataCache.where(
          (element) => element is HabitSummaryDataSortCache &&
                  realNeedArchivedUUID.contains(element.uuid)
              ? false
              : true,
        ),
      );
      saveAndDispatchLastSortedData(filteredSortCache);
    }

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> unarchivedSelectedHabits() async {
    var realNeedUnarchivedUUID = <HabitUUID>[];
    for (var habitUUID in _selectUUIDColl) {
      if (getHabit(habitUUID)?.status == HabitStatus.archived) {
        realNeedUnarchivedUUID.add(habitUUID);
      }
    }

    if (realNeedUnarchivedUUID.isEmpty) {
      appLog.value.warn("$runtimeType.unarchivedSelectedHabits",
          beforeVal: _selectUUIDColl,
          afterVal: realNeedUnarchivedUUID,
          ex: ["real need unarchived habit uuid not found"]);
      return null;
    }

    var result =
        await changeHabitsStatus(realNeedUnarchivedUUID, HabitStatus.activated);

    if (_habitDisplayFilter.allowArchivedHabits) {
      resortData(listen: false);
    }

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> deleteSelectedHabits() async {
    var result =
        await changeHabitsStatus(_selectUUIDColl.toList(), HabitStatus.deleted);

    resortData(listen: false);

    exitEditMode();
    return result;
  }

  String debugGetDataString() {
    assert(kDebugMode, true);
    return _data.toString();
  }
}

class DispatcherForHabitDetail {
  final HabitSummaryViewModel _root;

  const DispatcherForHabitDetail(this._root);

  String get _clsName => "${_root.runtimeType}.$runtimeType";

  Future<List<HabitStatusChangedRecord>?> onConfirmToArchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToArchiveHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    var habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    var recordList =
        await _root.changeHabitsStatus([habitUUID], HabitStatus.archived);
    if (_root.mounted) _root.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToUnarchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToUnarchiveHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    var habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    var recordList =
        await _root.changeHabitsStatus([habitUUID], HabitStatus.activated);
    if (_root.mounted) _root.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToDeleteHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("$_clsName.onConfirmToDeleteHabit", ex: [habitUUID]);
    if (!_root.mounted) return null;
    var habit = _root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    var recordList =
        await _root.changeHabitsStatus([habitUUID], HabitStatus.deleted);
    if (_root.mounted) _root.resortData();
    return recordList;
  }
}
