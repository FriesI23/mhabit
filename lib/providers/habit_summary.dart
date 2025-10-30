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

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../extensions/iterable_extensions.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../models/habit_date.dart';
import '../models/habit_display.dart';
import '../models/habit_form.dart';
import '../models/habit_score.dart';
import '../models/habit_stat.dart';
import '../models/habit_status.dart';
import '../models/habit_summary.dart';
import '../reminders/notification_service.dart';
import '../storage/db_helper_provider.dart';
import 'app_sync.dart';
import 'commons.dart';
import 'utils.dart';

part 'habit_summary.g.dart';

class HabitSummaryViewModel extends ChangeNotifier
    with
        NotificationChannelDataMixin,
        DBHelperLoadedMixin,
        DBOperationsMixin,
        PinnedAppbarMixin
    implements ProviderMounted, HabitSummaryDirtyMarker {
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
  StreamSubscription<String>? _startSyncSub;
  // listenable
  final StreamController<Duration?> _scrollCalendarToStartController =
      StreamController<Duration?>.broadcast();
  // delegates
  final _searchController = _HabitSummarySearchController();

  HabitSummaryViewModel();

  HabitDetailAdapter buildHabitDetailAdapter() =>
      HabitDetailAdapter(root: this);

  HabitsStatusChangerAdapter buildHabitStatusCHangerAdapter() =>
      HabitsStatusChangerAdapter(root: this);

  AppSettingAdapter buildAppSettingAdapter() => AppSettingAdapter(root: this);

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

  Stream<Duration?> get scrollCalendarToStartEvent =>
      _scrollCalendarToStartController.stream;

  HabitSummaryStatusCache get currentState => HabitSummaryStatusCache(
        isAppbarPinned: isAppbarPinned,
        reloadDBToggleSwich: reloadDBToggleSwich,
        reloadUIToggleSwitch: reloadUIToggleSwitch,
        isClandarExpanded: isCalendarExpanded,
        isInEditMode: isInEditMode,
        isInSearchMode: isInSearchMode,
      );

  bool get isCalendarExpanded => _isCalandarExpanded;

  void toggleCalendarStatus({bool listen = true}) => isCalendarExpanded
      ? collapseCalendar(listen: listen)
      : expandCalendar(listen: listen);

  void collapseCalendar({bool listen = true}) {
    if (!isCalendarExpanded) return;
    _isCalandarExpanded = false;
    if (!listen) return;
    notifyListeners();
    _scrollCalendarToStartController.add(null);
  }

  void expandCalendar({bool listen = true}) {
    if (isCalendarExpanded) return;
    _isCalandarExpanded = true;
    if (!listen) return;
    notifyListeners();
    _scrollCalendarToStartController.add(null);
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

  @override
  void dispose() {
    if (!_mounted) return;
    _startSyncSub?.cancel();
    _scrollCalendarToStartController.close();
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

  CancelableCompleter<void>? get _isDataLoaded {
    final loading = _loading;
    return (loading != null && !loading.isCanceled) ? loading : null;
  }

  bool get isDataLoaded => _isDataLoaded != null;

  Future loadData({bool listen = true, bool inFutureBuilder = false}) async {
    final crtLoading = _isDataLoaded;
    if (crtLoading != null) {
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
    collapseCalendar(listen: false);
    if (!listen) return;
    notifyListeners();
    _scrollCalendarToStartController.add(Duration.zero);
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

  //#region: search mode
  bool get isInSearchMode => _searchController.enabled;

  HabitDisplaySearchOptions get searchOptions => _searchController.options;

  void enterSearchMode({bool listen = true}) {
    if (isInSearchMode) return;
    _searchController.enable();
    _resortData();
    if (listen) notifyListeners();
  }

  void exitSearchMode({bool listen = true}) {
    if (!isInSearchMode) return;
    _searchController
      ..disable()
      ..clearOptions();
    _resortData();
    if (listen) notifyListeners();
  }

  void _onSeachOptionsChanged(HabitDisplaySearchOptions newOptions,
      {required bool listen}) {
    final lastKeyword = _searchController.options.keyword;
    final result = _searchController.updateOptions(newOptions);
    if (!result && newOptions.isNotEmpty) return;
    if (_searchController.options.isEmpty) {
      if (_searchController.enabled && lastKeyword.isEmpty) {
        _searchController.disable();
      }
    } else {
      if (!_searchController.enabled) _searchController.enable();
    }
    _resortData();
    if (listen) notifyListeners();
  }

  void onSeachKeywordChanged(String text, {bool listen = true}) =>
      _onSeachOptionsChanged(_searchController.options.copyWith(keyword: text),
          listen: listen);

  void onSearchOngoingChanged(bool value, {bool listen = true}) =>
      _onSeachOptionsChanged(
          _searchController.options.copyWith(activated: value),
          listen: listen);

  void onSearchCompletedChanged(bool value, {bool listen = true}) =>
      _onSeachOptionsChanged(
          _searchController.options.copyWith(completed: value),
          listen: listen);

  void onSearchHabitTypeChanged(HabitType type, bool value,
          {bool listen = true}) =>
      _onSeachOptionsChanged(
          _searchController.options.copyWith(
            types: value
                ? {..._searchController.options.types, type}
                : ({..._searchController.options.types}..remove(type)),
          ),
          listen: listen);

  void onClearSearchFilter({bool clearKeyboard = false, bool listen = true}) =>
      _onSeachOptionsChanged(
          clearKeyboard
              ? const HabitDisplaySearchOptions.empty()
              : HabitDisplaySearchOptions(
                  keyword: _searchController.options.keyword),
          listen: listen);

  void onSearchFilterChanged(HabitDisplaySearchOptions options,
          {bool listen = true}) =>
      _onSeachOptionsChanged(
          options.copyWith(keyword: _searchController.options.keyword),
          listen: listen);
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
  List<HabitSortCache> get currentHabitList =>
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
    _replaceSortbaleCache(isInSearchMode
        ? _sortableCache.copyWithData(_data,
            searchOptions: searchOptions, filter: HabitsDisplayFilter.allTrue)
        : _sortableCache.copyWithData(_data));
  }

  void _replaceSortbaleCache(_HabitsSortableCache newSortbaleCache) {
    if (identical(newSortbaleCache.lastSortedDataCache,
        _sortableCache.lastSortedDataCache)) {
      appLog.load.warn("$runtimeType._replaceSortbaleCache",
          ex: ["fixed cache", newSortbaleCache, _sortableCache]);
      newSortbaleCache = newSortbaleCache.copyWith(
          lastSortedDataCache:
              List.of(newSortbaleCache.lastSortedDataCache, growable: false));
    }
    _sortableCache = newSortbaleCache;
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
    _startSyncSub?.cancel();
    _startSyncSub = appSync.appSyncTask.startSyncEvents.listen((id) {
      appLog.habit
          .debug("onStartSyncEventTriggered", ex: [reloadDBToggleSwich]);
      rockreloadDBToggleSwich(clearSnackBar: false);
    });
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
    final filteredlastSortedDataCache = currentHabitList
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
    currentHabitList.insert(dropIndex, currentHabitList.removeAt(index));
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
        .nonNulls
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

    resortData(listen: false);

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> unarchivedSelectedHabits() async {
    final realNeedUnarchivedUUID = _selectorData.selectedColl
        .map(getHabit)
        .nonNulls
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

    resortData(listen: false);

    exitEditMode();
    return result;
  }

  Future<List<HabitStatusChangedRecord>?> deleteSelectedHabits() async {
    final realNeedDeletedUUID = _selectorData.selectedColl
        .map(getHabit)
        .nonNulls
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

  _HabitsSortableCache copyWithData(HabitSummaryDataCollection data,
      {HabitDisplaySearchOptions? searchOptions, HabitsDisplayFilter? filter}) {
    var sorted = data
        .sort(sortType, sortDirection)
        .where((filter ?? this.filter).getDisplayFilterFunction());
    if (searchOptions != null) {
      final keywords = searchOptions.keyword
          .toUpperCase()
          .split(' ')
          .whereNot((e) => e.isEmpty);
      sorted = sorted.where(
          (e) => searchOptions.filter(e, caps: true, keywords: keywords));
    }
    return copyWith(
      lastSortedDataCache:
          sorted.map((e) => HabitSummaryDataSortCache(data: e)).toList(),
    );
  }

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

class _HabitSummarySearchController {
  bool _active = false;
  HabitDisplaySearchOptions _options;

  _HabitSummarySearchController()
      : _options = const HabitDisplaySearchOptions.empty();

  bool get enabled => _active;

  HabitDisplaySearchOptions get options => _options;

  void enable() => _active = true;

  void disable() => _active = false;

  void clearOptions() => _options = const HabitDisplaySearchOptions.empty();

  bool updateOptions(HabitDisplaySearchOptions newOptions) {
    if (newOptions == _options) return false;
    _options = newOptions;
    return true;
  }
}

final class HabitDetailAdapter implements ProviderMounted {
  late final WeakReference<HabitSummaryViewModel> _root;

  HabitDetailAdapter({required HabitSummaryViewModel root}) {
    _root = WeakReference(root);
  }

  @override
  bool get mounted => _root.target?.mounted == true;

  HabitSummaryViewModel? _fetchRoot() {
    final root = _root.target;
    if (root == null || !root.mounted) return null;
    return root;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToArchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("HabitDetailAdapter.onConfirmToArchiveHabit",
        ex: [_root, habitUUID]);
    final root = _fetchRoot();
    if (root == null) return null;
    final habit = root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        root._changeHabitsStatus([habitUUID], HabitStatus.archived);
    _fetchRoot()?.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToUnarchiveHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("HabitDetailAdapter.onConfirmToUnarchiveHabit",
        ex: [_root, habitUUID]);
    final root = _fetchRoot();
    if (root == null) return null;
    final habit = root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        await root._changeHabitsStatus([habitUUID], HabitStatus.activated);
    _fetchRoot()?.resortData();
    return recordList;
  }

  Future<List<HabitStatusChangedRecord>?> onConfirmToDeleteHabit(
      HabitUUID habitUUID) async {
    appLog.habit.info("HabitDetailAdapter.onConfirmToDeleteHabit",
        ex: [_root, habitUUID]);
    final root = _fetchRoot();
    if (root == null) return null;
    final habit = root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList =
        await root._changeHabitsStatus([habitUUID], HabitStatus.deleted);
    _fetchRoot()?.resortData();
    return recordList;
  }

  void onHabitDataChanged() {
    final root = _fetchRoot();
    if (root == null) return;
    root.collapseCalendar();
    root.rockreloadDBToggleSwich();
  }
}

final class HabitsStatusChangerAdapter implements ProviderMounted {
  late final WeakReference<HabitSummaryViewModel> _root;

  HabitsStatusChangerAdapter({required HabitSummaryViewModel root}) {
    _root = WeakReference(root);
  }

  @override
  bool get mounted => _root.target?.mounted == true;

  void onHabitDataChanged() {
    final root = _root.target;
    if (root == null || !root.mounted) return;
    appLog.habit
        .info("HabitsStatusChangerAdapter.onHabitDataChanged", ex: [_root]);
    root.exitEditMode();
    root.rockreloadDBToggleSwich(clearSnackBar: false);
  }
}

final class AppSettingAdapter implements ProviderMounted {
  late final WeakReference<HabitSummaryViewModel> _root;

  AppSettingAdapter({required HabitSummaryViewModel root}) {
    _root = WeakReference(root);
  }

  @override
  bool get mounted => _root.target?.mounted == true;

  void onDatabaseCleared() {
    final root = _root.target;
    if (root == null || !root.mounted) return;
    appLog.habit
        .info("HabitsStatusChangerAdapter.onDatabaseCleared", ex: [_root]);
    root.rockreloadDBToggleSwich(clearSnackBar: false);
  }
}
