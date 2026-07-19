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

import '../../../common/consts.dart';
import '../../../common/exceptions.dart';
import '../../../common/types.dart';
import '../../../common/utils.dart';
import '../../../extensions/iterable_extensions.dart';
import '../../../logging/helper.dart';
import '../../../logging/logger_stack.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../models/habit_repo_actions.dart';
import '../../../models/habit_score.dart';
import '../../../models/habit_stat.dart';
import '../../../models/habit_status.dart';
import '../../../models/habit_summary.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/support/page_load_runtime.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/app_sync.dart';
import '../../../providers/workflow/group_manager.dart';
import '../../../providers/workflow/habits_manager.dart';
import '../../../storage/db/handlers/habit.dart';
import '../helpers.dart';
import 'habit_group_sorter.dart';
import 'habits_display_reload_bridge.dart';

part 'habit_summary.g.dart';

extension HabitSummaryDataExntesion on HabitSummaryData {
  HabitDailyGoal getEffectiveDailyValue(HabitRecordDate date) {
    final record = getRecordByDate(date);
    if (record != null && record.status == HabitRecordStatus.done) {
      return record.value;
    }
    return dailyGoal;
  }
}

class HabitSummaryViewModel extends ChangeNotifier
    with PinnedAppbarMixin
    implements ProviderMounted, AppEventLoaded {
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
  final _pageLoad = PageLoadRuntime();
  bool _nextRefreshClearSnackBar = false;
  bool _nextRefreshForceReload = false;
  bool _isCalandarExpanded = false;
  bool _isInEditMode = false;
  bool _canBeDragged = true;
  bool _groupingEnabled = false;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;
  late HabitsDisplayAccess _access;
  final _reloadBridge = HabitsDisplayReloadBridge();
  late GroupManager _groupManager;
  GroupCollection? _groupCollection;
  StreamSubscription<AppEvent>? _groupEventSubscription;
  final Set<String?> _collapsedGroupUUIDs = {};
  // listenable
  final StreamController<Duration?> _scrollCalendarToStartController =
      StreamController<Duration?>.broadcast();
  // delegates
  final _searchController = _HabitSummarySearchController();

  HabitSummaryViewModel();

  HabitDetailAdapter buildHabitDetailAdapter() =>
      HabitDetailAdapter(root: this);

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
    loadId: _pageLoad.currentLoadId,
    isClandarExpanded: isCalendarExpanded,
    isInEditMode: isInEditMode,
    isInSearchMode: isInSearchMode,
  );

  bool get isCalendarExpanded => _isCalandarExpanded;

  bool get canPop => !isInEditMode && !isInSearchMode && !isCalendarExpanded;

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

  int get habitCount => _data.length;

  HabitSummaryData? get earliestSummaryDataStartDate {
    HabitSummaryData? result;
    _data.forEach((k, v) {
      if (result == null || (result!.startDate > v.startDate)) {
        result = v;
      }
    });
    return result;
  }

  void attachGroupManager(GroupManager gm) {
    _groupManager = gm;
  }

  List<HabitGroupData> groupList() => _groupCollection?.toList() ?? [];

  String? getGroupName(GroupUUID? uuid) =>
      _groupCollection?.getByUUID(uuid)?.name;

  void updateGroupingEnabled(bool value) {
    _groupingEnabled = value;
  }

  bool isGroupCollapsed(String? groupUUID) =>
      _collapsedGroupUUIDs.contains(groupUUID);

  void toggleGroup(String? groupUUID) {
    if (_collapsedGroupUUIDs.contains(groupUUID)) {
      _collapsedGroupUUIDs.remove(groupUUID);
    } else {
      _collapsedGroupUUIDs.add(groupUUID);
    }
    resortData();
  }

  void expandGroup(String? groupUUID) {
    if (_collapsedGroupUUIDs.remove(groupUUID)) resortData();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _groupEventSubscription?.cancel();
    _reloadBridge.dispose();
    _scrollCalendarToStartController.close();
    _pageLoad.cancel(logName: "$runtimeType._cancelLoading");
    super.dispose();
    _mounted = false;
  }

  void requestReload({bool clearSnackBar = true}) {
    if (!_nextRefreshClearSnackBar && clearSnackBar) {
      _nextRefreshClearSnackBar = clearSnackBar;
    }
    _nextRefreshForceReload = true;
    _pageLoad.cancel(logName: "$runtimeType._cancelLoading");
    notifyListeners();
  }

  bool consumeClearSnackBarFlag() {
    final tmp = _nextRefreshClearSnackBar;
    _nextRefreshClearSnackBar = false;
    return tmp;
  }

  bool consumeForceReloadFlag() {
    final result = _nextRefreshForceReload;
    _nextRefreshForceReload = false;
    return result;
  }

  Key getHabitInsideVersion(HabitUUID uuid) {
    final data = _data.getHabitByUUID(uuid);
    return data != null ? data.diryMark : UniqueKey();
  }

  void attachAccess(HabitsDisplayAccess newAccess) {
    _access = newAccess;
  }

  void _updateHabitAutoCompleteStatistics(HabitSummaryData data) {
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
            data,
            now,
            entry.key,
            entry.value,
          );
        }
      },
    );
  }

  //#region loading
  bool get hasLoad => _pageLoad.hasLoad;

  bool get hasLoaded => _pageLoad.hasLoaded;

  Future<void> loadData({bool listen = true}) {
    void loadingFailed(
      CancelableCompleter<void> loading,
      List<Object?> errmsg,
    ) {
      appLog.load.error(
        "$runtimeType.load",
        ex: [...errmsg, loading.hashCode],
        stackTrace: LoggerStackTrace.from(StackTrace.current),
      );
      if (!loading.isCompleted) {
        loading.completeError(
          FlutterError(errmsg.join(" ")),
          StackTrace.current,
        );
      }
    }

    void loadingCancelled(CancelableCompleter<void> loading) {
      appLog.load.info(
        "$runtimeType.load",
        ex: ['cancelled', loading.hashCode],
      );
    }

    return _pageLoad.run(
      logName: "$runtimeType.loadData",
      alreadyLoadingEx: ["data already loaded"],
      loadData: (loading) async {
        if (!mounted) {
          return loadingFailed(loading, const ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        appLog.load.debug(
          "$runtimeType.load",
          ex: ["loading data", loading.hashCode, listen],
        );

        // init habits
        await _access.loadHabitSummaryCollectionData(initedCollection: _data);
        if (!mounted) {
          return loadingFailed(loading, const ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;
        _data.forEach((_, habit) => _updateHabitAutoCompleteStatistics(habit));

        // init groups
        _groupCollection = await _groupManager.tryLoadGroupCollection();
        if (!mounted) {
          return loadingFailed(loading, const ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;

        _resortData();

        await _access.repairHabitReminders(
          params: HabitReminderRepairParams.loadedHabits(_data.values),
        );
        if (!mounted) {
          return loadingFailed(loading, const ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;

        loading.complete();
        if (listen) notifyListeners();
        appLog.load.debug(
          "$runtimeType.load",
          ex: ["loaded", loading.hashCode, listen],
        );
      },
      onError: (loading, e, s) {
        if (loading.isCanceled) return loadingCancelled(loading);
        loadingFailed(loading, ["unexpected error", e]);
        appLog.load.error(
          "$runtimeType.load",
          ex: ["caught", e, loading.hashCode],
          stackTrace: s,
        );
      },
    );
  }

  HabitSummaryData? getHabit(HabitUUID habitUUID) {
    return _data.getHabitByUUID(habitUUID);
  }

  Future<String?> loadRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) => _access.loadHabitRecordReason(data, date);

  Future<HabitDBCell?> loadSelectedHabitDetail() async {
    final selectedData = getSelectedHabitsData().firstWhere(
      (element) => element != null,
      orElse: () => null,
    );
    if (selectedData == null) return null;
    return _access.loadHabitDetail(selectedData.uuid);
  }

  bool addNewData(HabitSummaryData cell, {bool listen = false}) {
    final bool addResult = _data.addHabit(cell, forceAdd: false);
    final data = _data.getHabitByUUID(cell.uuid);
    if (data != null) _updateHabitAutoCompleteStatistics(data);
    resortData();
    if (listen) notifyListeners();
    return addResult;
  }
  //#endregion

  //#region: edit mode
  bool get isInEditMode => _isInEditMode;

  void switchToEditMode({
    bool clearAllSelected = true,
    bool listen = true,
  }) async {
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

  void _onSeachOptionsChanged(
    HabitDisplaySearchOptions newOptions, {
    required bool listen,
  }) {
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
      _onSeachOptionsChanged(
        _searchController.options.copyWith(keyword: text),
        listen: listen,
      );

  void onSearchOngoingChanged(bool value, {bool listen = true}) =>
      _onSeachOptionsChanged(
        _searchController.options.copyWith(activated: value),
        listen: listen,
      );

  void onSearchCompletedChanged(bool value, {bool listen = true}) =>
      _onSeachOptionsChanged(
        _searchController.options.copyWith(completed: value),
        listen: listen,
      );

  void onSearchHabitTypeChanged(
    HabitType type,
    bool value, {
    bool listen = true,
  }) => _onSeachOptionsChanged(
    _searchController.options.copyWith(
      types: value
          ? {..._searchController.options.types, type}
          : ({..._searchController.options.types}..remove(type)),
    ),
    listen: listen,
  );

  void onClearSearchFilter({bool clearKeyboard = false, bool listen = true}) =>
      _onSeachOptionsChanged(
        clearKeyboard
            ? const HabitDisplaySearchOptions.empty()
            : HabitDisplaySearchOptions(
                keyword: _searchController.options.keyword,
              ),
        listen: listen,
      );

  void onSearchFilterChanged(
    HabitDisplaySearchOptions options, {
    bool listen = true,
  }) => _onSeachOptionsChanged(
    options.copyWith(keyword: _searchController.options.keyword),
    listen: listen,
  );
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

  void updateSortOptions(
    HabitDisplaySortType sortType,
    HabitDisplaySortDirection sortDirection,
  ) => _sortableCache = _sortableCache.copyWith(
    sortDirection: sortDirection,
    sortType: sortType,
  );

  void updateGroupOptions(
    HabitDisplayGroupType groupType,
    HabitDisplaySortDirection groupDirection,
  ) => _sortableCache = _sortableCache.copyWith(
    groupType: groupType,
    groupDirection: groupDirection,
  );

  void updateHabitDisplayFilter(HabitsDisplayFilter newFilter) =>
      _sortableCache = _sortableCache.copyWith(filter: newFilter);

  HabitSortCache? getHabitBySortId(int index) =>
      _sortableCache.getSortCache(index);

  void resortData({bool listen = true}) {
    if (!_pageLoad.hasLoaded) return;
    _resortData();
    if (listen) notifyListeners();
  }

  void _resortData() {
    final searchOpt = isInSearchMode ? searchOptions : null;
    final statusFilter = isInSearchMode
        ? HabitsDisplayFilter.allTrue
        : _sortableCache.filter;

    void replaceWithUngroupedData() => _replaceSortbaleCache(
      _sortableCache.copyWithData(
        _data,
        searchOptions: searchOpt,
        filter: statusFilter,
      ),
    );

    if (_groupingEnabled) {
      if (_groupCollection == null) {
        replaceWithUngroupedData();
        return;
      }
      final groups = _groupCollection!.toList();
      final grouped = buildGroupedSortCacheList(
        data: _data,
        groups: groups,
        collapsedUUIDs: _collapsedGroupUUIDs,
        filter: statusFilter,
        sortType: _sortableCache.sortType,
        sortDirection: _sortableCache.sortDirection,
        groupType: _sortableCache.groupType,
        groupDirection: _sortableCache.groupDirection,
      );

      // Degrade to ungrouped display when only the uncategorized
      // (no-group) section has habits after filtering.
      final headers = grouped.whereType<GroupHeaderSortCache>();
      if (headers.length == 1 && headers.first.groupUUID == null) {
        replaceWithUngroupedData();
        return;
      }

      _replaceSortbaleCache(
        _sortableCache.copyWithGroupedData(grouped, searchOptions: searchOpt),
      );
    } else {
      replaceWithUngroupedData();
    }
  }

  void _replaceSortbaleCache(_HabitsSortableCache newSortbaleCache) {
    if (identical(
      newSortbaleCache.lastSortedDataCache,
      _sortableCache.lastSortedDataCache,
    )) {
      appLog.load.warn(
        "$runtimeType._replaceSortbaleCache",
        ex: ["fixed cache", newSortbaleCache, _sortableCache],
      );
      newSortbaleCache = newSortbaleCache.copyWith(
        lastSortedDataCache: List.of(
          newSortbaleCache.lastSortedDataCache,
          growable: false,
        ),
      );
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
      activated: activatedNum,
      archived: archivedNum,
    );
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
  void attachWorkflow(AppSyncWorkflowAccess workflow) {
    _reloadBridge.attachWorkflow(
      workflow,
      onStartSync: (id) {
        appLog.habit.debug("onStartSyncEventTriggered", ex: [id]);
        requestReload(clearSnackBar: false);
      },
    );
  }
  //#endregion

  //#region: app event
  @override
  void updateAppEvent(AppEventBus newAppEvent) {
    _groupEventSubscription?.cancel();
    _groupEventSubscription = newAppEvent.on<GroupChangedEvent>().listen((_) {
      requestReload(clearSnackBar: false);
    });

    _reloadBridge.updateAppEvent(
      newAppEvent,
      onReloadData: (event) {
        if (event.isInTrace(AppEventPageSource.habitDisplay)) return;
        if (event.isInTrace(AppEventPageSource.habitEdit)) {
          appLog.habit.debug(
            "HabitSummary.skipped",
            ex: ["app event triggered", event],
          );
          return;
        }
        appLog.habit.debug("HabitSummary", ex: ["app event triggered", event]);
        if (event.exiEditMode) exitEditMode();
        requestReload(clearSnackBar: event.clearSnackBar);
      },
      onHabitStatusChanged: (event) {
        if (event.isInTrace(AppEventPageSource.habitDisplay)) return;
        appLog.habit.debug("HabitSummary", ex: ["app event triggered", event]);
        requestReload(clearSnackBar: false);
      },
      onHabitRecordsChanged: (event) {
        if (event.isInTrace(AppEventPageSource.habitDisplay)) return;
        appLog.habit.debug("HabitSummary", ex: ["app event triggered", event]);
        requestReload(clearSnackBar: false);
      },
    );
  }
  //#endregion

  //#region actions
  Future<HabitSummaryRecord?> changeRecordStatus(
    HabitUUID habitUUID,
    HabitRecordDate date, {
    bool listen = true,
  }) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;

    final results = await _access.changeHabitRecordStatus(
      preAction: AutoChangeRecordStatusAction(data: data, dateList: [date]),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
      beforeReminderUpdate: (habit, _) =>
          _updateHabitAutoCompleteStatistics(habit),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitSummary.changeRecordStatus",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics(data);
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
    HabitUUID habitUUID,
    HabitRecordDate date,
    HabitDailyGoal newValue, {
    bool listen = true,
  }) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;

    final results = await _access.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
        data: data,
        goal: newValue,
        dateList: [date],
      ),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
      beforeReminderUpdate: (habit, _) =>
          _updateHabitAutoCompleteStatistics(habit),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitSummary.changeRecordValue",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics(data);
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordReason(
    HabitUUID habitUUID,
    HabitRecordDate date,
    String newReason, {
    bool listen = true,
  }) async {
    final data = _data.getHabitByUUID(habitUUID);
    if (data == null) return null;

    final results = await _access.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
        data: data,
        reason: newReason,
        status: HabitRecordStatus.skip,
        dateList: [date],
      ),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
      beforeReminderUpdate: (habit, _) =>
          _updateHabitAutoCompleteStatistics(habit),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitSummary.changeRecordReason",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics(data);
    if (listen) notifyListeners();
    return result.data;
  }

  void _applyHabitReorder(int index, int dropIndex) {
    final moved = currentHabitList.removeAt(index);
    if (dropIndex > currentHabitList.length) {
      currentHabitList.add(moved);
    } else {
      currentHabitList.insert(dropIndex, moved);
    }
  }

  Future<void> _writeChangedSortPositionToDB({
    required int fromIndex,
    required int toIndex,
  }) async {
    List<HabitUUID> orderedUUIDs;
    if (_groupingEnabled) {
      final lo = fromIndex < toIndex ? fromIndex : toIndex;
      final hi = fromIndex < toIndex ? toIndex : fromIndex;
      orderedUUIDs = currentHabitList
          .sublist(lo, hi + 1)
          .whereType<HabitSummaryDataSortCache>()
          .map((e) => e.uuid)
          .toList();
    } else {
      orderedUUIDs = currentHabitList
          .whereType<HabitSummaryDataSortCache>()
          .map((e) => e.uuid)
          .toList();
    }

    final dataList = orderedUUIDs.map(_data.getHabitByUUID).nonNulls.toList();
    if (dataList.isEmpty) return;

    final changedUUIDs = await _access.fixAndSaveSortPositions(
      dataList,
      increaseStep: sortPositionConflictIncreaseStep,
      decimalPlaces: sortPositionConflictDecimalPlaces,
    );

    appLog.habit.debug(
      "HabitSummary._writeChangedSortPositionToDB",
      ex: [changedUUIDs],
    );
  }

  Future<void> onHabitReorderComplate(int index, int dropIndex) async {
    _applyHabitReorder(index, dropIndex);
    await _writeChangedSortPositionToDB(fromIndex: index, toIndex: dropIndex);
  }

  Future<void> onCrossGroupHabitMove(
    int sourceIndex,
    int targetIndex,
    String? targetGroupUUID,
  ) async {
    final movedCache = currentHabitList[sourceIndex];
    if (movedCache is! HabitSummaryDataSortCache) {
      if (kDebugMode) {
        throw StateError(
          'Expected HabitSummaryDataSortCache at sourceIndex=$sourceIndex, '
          'got ${movedCache.runtimeType}',
        );
      }
      return;
    }
    final movedData = movedCache.data;
    if (movedData == null) return;
    final movedUUID = movedData.uuid;
    final oldGroupId = movedData.groupId;

    _applyHabitReorder(sourceIndex, targetIndex);
    movedData.groupId = targetGroupUUID;

    final targetGroupData = currentHabitList
        .whereType<HabitSummaryDataSortCache>()
        .map((e) => e.data)
        .nonNulls
        .where((d) => d.groupId == targetGroupUUID)
        .toList();

    if (targetGroupData.isNotEmpty) {
      await _access.fixAndSaveSortPositions(
        targetGroupData,
        increaseStep: sortPositionConflictIncreaseStep,
        decimalPlaces: sortPositionConflictDecimalPlaces,
      );
    }

    if (oldGroupId != targetGroupUUID) {
      await _access.updateHabitGroupIds([movedUUID], [targetGroupUUID]);
    }
    resortData();
  }

  Future<List<HabitStatusChangedRecord>> _changeHabitsStatus(
    List<HabitUUID> uuidList,
    HabitStatus newStatus,
  ) async {
    appLog.habit.debug(
      "$runtimeType.changeHabitsStatus",
      ex: [uuidList, newStatus],
    );
    final dataList = uuidList.map(getHabit).nonNulls.toList();
    final results = await _access.changeHabitStatus(
      action: ChangeMultiHabitStatusAction(dataList, status: newStatus),
      extraResolver: (result) =>
          _updateHabitAutoCompleteStatistics(result.data),
    );
    return results
        .map(
          (e) => HabitStatusChangedRecord(
            habitUUID: e.data.uuid,
            newStatus: e.data.status,
            orgStatus: e.orgStatus,
          ),
        )
        .toList();
  }

  Future<void> revertHabitsStatus(
    List<HabitStatusChangedRecord> recordList,
  ) async {
    appLog.habit.info("$runtimeType.revertHabitsStatus", ex: [recordList]);
    final recordMap = <HabitStatus, List<HabitUUID>>{};
    for (var record in recordList) {
      if (!recordMap.containsKey(record.orgStatus)) {
        recordMap[record.orgStatus] = [];
      }
      recordMap[record.orgStatus]!.add(record.habitUUID);
    }

    appLog.habit.debug(
      "$runtimeType.revertHabitsStatus do",
      ex: [recordList, recordMap],
    );
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
      appLog.value.warn(
        "$runtimeType.archivedSelectedHabits",
        beforeVal: _selectorData,
        afterVal: realNeedArchivedUUID,
        ex: ["real need archived habit uuid not found"],
      );
      return null;
    }

    final result = await _changeHabitsStatus(
      realNeedArchivedUUID,
      HabitStatus.archived,
    );

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
      appLog.value.warn(
        "$runtimeType.unarchivedSelectedHabits",
        beforeVal: _selectorData,
        afterVal: realNeedUnarchivedUUID,
        ex: ["real need unarchived habit uuid not found"],
      );
      return null;
    }

    final result = await _changeHabitsStatus(
      realNeedUnarchivedUUID,
      HabitStatus.activated,
    );

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
      appLog.value.warn(
        "$runtimeType.deleteSelectedHabits",
        beforeVal: _selectorData,
        afterVal: realNeedDeletedUUID,
        ex: ["real need deleted habit uuid not found"],
      );
      return null;
    }

    final result = await _changeHabitsStatus(
      realNeedDeletedUUID,
      HabitStatus.deleted,
    );

    resortData(listen: false);
    exitEditMode();
    return result;
  }

  Future<int> executeBatchGroupModify({
    required List<HabitGroupModifyItem> affectedHabits,
    required GroupUUID? targetGroupId,
    bool listen = true,
  }) async {
    final changedUUIDs = <String>[];
    final changedGroupIds = <GroupUUID?>[];
    for (final h in affectedHabits) {
      if (h.oldGroupId != targetGroupId) {
        changedUUIDs.add(h.uuid);
        changedGroupIds.add(targetGroupId);
      }
    }

    if (changedUUIDs.isEmpty) return 0;

    await _access.updateHabitGroupIds(changedUUIDs, changedGroupIds);

    for (final h in affectedHabits) {
      if (h.oldGroupId != targetGroupId) {
        final data = getHabit(h.uuid);
        if (data != null) {
          data.groupId = targetGroupId;
        }
      }
    }
    resortData(listen: listen);

    return changedUUIDs.length;
  }

  Future<bool> undoBatchGroupModify({
    required Map<String, GroupUUID?> oldGroupIds,
    required Map<String, GroupUUID?> newGroupIds,
    bool listen = true,
  }) async {
    // Verify no concurrent modification has changed any habit's group.
    final currentHabits = await _access.loadHabitSummaryCollectionData(
      habitUUIDs: oldGroupIds.keys.toList(),
    );
    for (final data in currentHabits.values) {
      if (data.groupId != newGroupIds[data.uuid]) return false;
    }

    final revertUUIDs = <String>[];
    final revertGroupIds = <GroupUUID?>[];
    for (final entry in oldGroupIds.entries) {
      if (entry.value != newGroupIds[entry.key]) {
        revertUUIDs.add(entry.key);
        revertGroupIds.add(entry.value);
      }
    }

    if (revertUUIDs.isEmpty) return true;
    await _access.updateHabitGroupIds(revertUUIDs, revertGroupIds);

    for (final (i, uuid) in revertUUIDs.indexed) {
      final data = getHabit(uuid);
      if (data != null) {
        data.groupId = revertGroupIds[i];
      }
    }
    resortData(listen: listen);
    return true;
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
  final HabitDisplayGroupType groupType;
  final HabitDisplaySortDirection groupDirection;
  final List<HabitSortCache> lastSortedDataCache;

  const _HabitsSortableCache({
    required this.sortType,
    required this.sortDirection,
    required this.filter,
    this.groupType = defaultGroupType,
    this.groupDirection = defaultGroupSortDirection,
    this.lastSortedDataCache = const [],
  });

  HabitSortCache? getSortCache(int index) {
    if (index < 0 || index >= lastSortedDataCache.length) {
      return null;
    } else {
      return lastSortedDataCache[index];
    }
  }

  _HabitsSortableCache copyWithData(
    HabitSummaryDataCollection data, {
    HabitDisplaySearchOptions? searchOptions,
    HabitsDisplayFilter? filter,
  }) {
    var sorted = data
        .sort(sortType, sortDirection)
        .where((filter ?? this.filter).displayFilterFunction);
    if (searchOptions != null) {
      sorted = sorted.where(
        (e) => searchOptions.filter(
          e,
          caps: true,
          keywords: searchOptions.splitKeywords,
        ),
      );
    }
    return copyWith(lastSortedDataCache: sorted.toHabitSummarySortCacheList());
  }

  _HabitsSortableCache copyWithGroupedData(
    List<HabitSortCache<dynamic>> sorted, {
    HabitDisplaySearchOptions? searchOptions,
  }) {
    var result = sorted;
    if (searchOptions != null) {
      result = filterGroupedList(result, searchOptions);
      updateGroupHeaderCounts(result);
    }
    return copyWith(lastSortedDataCache: result);
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

  Future<HabitStatusChangedRecord?> _changeHabitsStatus(
    HabitUUID habitUUID,
    HabitStatus status,
  ) async {
    final root = _fetchRoot();
    if (root == null) return null;
    final habit = root.getHabit(habitUUID);
    if (habit == null || habit.status == HabitStatus.deleted) return null;
    final recordList = await root._changeHabitsStatus([habitUUID], status);
    _fetchRoot()?.resortData();
    return recordList.firstOrNull;
  }

  Future<HabitStatusChangedRecord?> onConfirmToArchiveHabit(
    HabitUUID habitUUID,
  ) async {
    appLog.habit.info(
      "HabitDetailAdapter.onConfirmToArchiveHabit",
      ex: [_root, habitUUID],
    );
    return _changeHabitsStatus(habitUUID, HabitStatus.archived);
  }

  Future<HabitStatusChangedRecord?> onConfirmToUnarchiveHabit(
    HabitUUID habitUUID,
  ) async {
    appLog.habit.info(
      "HabitDetailAdapter.onConfirmToUnarchiveHabit",
      ex: [_root, habitUUID],
    );
    return _changeHabitsStatus(habitUUID, HabitStatus.activated);
  }

  Future<HabitStatusChangedRecord?> onConfirmToDeleteHabit(
    HabitUUID habitUUID,
  ) async {
    appLog.habit.info(
      "HabitDetailAdapter.onConfirmToDeleteHabit",
      ex: [_root, habitUUID],
    );
    return _changeHabitsStatus(habitUUID, HabitStatus.deleted);
  }

  void onHabitDataChanged() {
    final root = _fetchRoot();
    if (root == null) return;
    root.collapseCalendar();
    root.requestReload();
  }
}
