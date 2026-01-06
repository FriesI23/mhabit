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
import 'dart:collection';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../models/app_event.dart';
import '../models/habit_date.dart';
import '../models/habit_display.dart';
import '../models/habit_form.dart';
import '../models/habit_repo_actions.dart';
import '../models/habit_summary.dart';
import '../storage/db/handlers/habit.dart';
import 'app_event.dart';
import 'app_sync.dart';
import 'commons.dart';
import 'habits_manager.dart';

class HabitsTodayViewModel extends ChangeNotifier
    with HabitsManagerLoadedMixin
    implements ProviderMounted, AppEventLoaded {
  static const _loadHabitDataCollectionColumns = [
    HabitDBCellKey.id,
    HabitDBCellKey.uuid,
    HabitDBCellKey.type,
    HabitDBCellKey.name,
    HabitDBCellKey.color,
    HabitDBCellKey.dailyGoal,
    HabitDBCellKey.dailyGoalExtra,
    HabitDBCellKey.targetDays,
    HabitDBCellKey.freqType,
    HabitDBCellKey.freqCustom,
    HabitDBCellKey.startDate,
    HabitDBCellKey.remindCustom,
    HabitDBCellKey.remindQuestion,
    HabitDBCellKey.status,
    HabitDBCellKey.sortPosition,
    HabitDBCellKey.createT,
    HabitDBCellKey.desc,
  ];

  // data
  final _data = HabitSummaryDataCollection();
  List<HabitSortCache> _lastSortedDataCache = const [];
  // status
  CancelableCompleter<void>? _loading;
  bool _nextRefreshForceReload = false;
  final LinkedHashMap<HabitUUID, bool> _expandStatus;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;
  HabitDisplaySortType _sortType = defaultSortType;
  HabitDisplaySortDirection _sortDirection = defaultSortDirection;
  // subscriptions
  StreamSubscription<String>? _startSyncSub;
  StreamSubscription<ReloadDataEvent>? _reloadDataSub;
  StreamSubscription<HabitStatusChangedEvent>? _habitStatusChangedSub;
  StreamSubscription<HabitRecordsChangedEvents>? _habitRecordStatusChangedSub;

  HabitsTodayViewModel() : _expandStatus = LinkedHashMap();

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
  void dispose() {
    if (!_mounted) return;
    _startSyncSub?.cancel();
    super.dispose();
    _mounted = false;
  }

  void requestReload() {
    _nextRefreshForceReload = true;
    _cancelLoading();
    notifyListeners();
  }

  bool consumeForceReloadFlag() {
    final result = _nextRefreshForceReload;
    _nextRefreshForceReload = false;
    return result;
  }

  Future<void> _updateHabitReminder(HabitSummaryData data) =>
      habitsManager.updateHabitReminder(data);

  void _updateHabitAutoCompleteStatistics(HabitSummaryData data) =>
      data.reCalculateAutoComplateRecords(firstDay: firstday);

  //#region loading
  void _cancelLoading() {
    final loading = _loading;
    if (loading == null) return;

    void onCancelled() {
      if (_loading == loading) _loading = null;
      appLog.load.info(
        "$runtimeType._cancelLoading",
        ex: ['cancelled', loading.hashCode],
      );
    }

    appLog.load.info("$runtimeType._cancelLoading", ex: [loading.hashCode]);
    if (loading.isCompleted || loading.isCanceled) {
      onCancelled();
    } else {
      loading.operation.cancel();
      onCancelled();
    }
  }

  CancelableCompleter<void>? get _effectiveLoading {
    final loading = _loading;
    return (loading != null && !loading.isCanceled) ? loading : null;
  }

  bool get isDataLoading => _effectiveLoading != null;

  bool get isDataLoaded => _effectiveLoading?.isCompleted == true;

  Future loadData({bool listen = true}) async {
    final crtLoading = _effectiveLoading;
    if (crtLoading != null) {
      appLog.load.warn(
        "$runtimeType.loadData",
        ex: ["data already loaded", crtLoading.isCompleted],
      );
      return crtLoading.operation.valueOrCancellation();
    }

    final loading = _loading = CancelableCompleter<void>();

    void loadingFailed(List errmsg) {
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

    void loadingCancelled() {
      appLog.load.info(
        "$runtimeType.load",
        ex: ['cancelled', loading.hashCode],
      );
    }

    Future<void> loadingData() async {
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      appLog.load.debug(
        "$runtimeType.load",
        ex: ["loading data", loading.hashCode, listen],
      );

      // init habits
      await habitsManager.loadHabitSummaryCollectionData(
        initedCollection: _data,
        habitsColmns: _loadHabitDataCollectionColumns,
      );
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;
      _data.forEach((_, habit) => _updateHabitAutoCompleteStatistics(habit));
      _resortData();

      // init reminders
      final futureList = <Future>[];
      _data.forEach((_, habit) => futureList.add(_updateHabitReminder(habit)));
      await Future.wait(futureList);
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;

      // complete
      loading.complete();
      // reload
      if (listen) {
        notifyListeners();
      }
      appLog.load.debug(
        "$runtimeType.load",
        ex: ["loaded", loading.hashCode, listen],
      );
    }

    loadingData()
        .catchError((e, s) {
          if (loading.isCanceled) return loadingCancelled();
          loadingFailed(["unexpected error", e]);
          appLog.load.error(
            "$runtimeType.load",
            ex: ["caught", e, loading.hashCode],
            stackTrace: s,
          );
        })
        .whenComplete(() {
          if (!loading.isCompleted && !loading.isCanceled) {
            loading.complete();
          }
        });

    return loading.operation.valueOrCancellation();
  }

  HabitSummaryData? getHabit(HabitUUID habitUUID) {
    return _data.getHabitByUUID(habitUUID);
  }

  Future<String?> loadRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) => habitsManager.loadHabitRecordReason(data, date);
  //#endregion

  //#region sortbale habits list
  List<HabitSortCache> get currentHabitList => _lastSortedDataCache;

  void updateSortOptions(
    HabitDisplaySortType sortType,
    HabitDisplaySortDirection sortDirection,
  ) {
    _sortType = sortType;
    _sortDirection = _sortDirection;
  }

  HabitSortCache? getHabitBySortId(int index) => _lastSortedDataCache[index];

  void resortData({bool listen = true}) {
    if (!(_loading?.isCompleted ?? false)) return;
    _resortData();
    if (listen) notifyListeners();
  }

  void _resortData() {
    final now = HabitDate.now();
    final newData = _data
        .sort(_sortType, _sortDirection)
        .where((e) {
          if (!e.isActived) return false;
          if (e.startDate > now) return false;
          if (e.getRecordByDate(now) != null) return false;
          return true;
        })
        .map((e) => HabitSummaryDataSortCache(data: e))
        .toList();
    _replaceSortbaleCache(newData);
  }

  void _replaceSortbaleCache(List<HabitSortCache> cache) {
    if (identical(cache, _lastSortedDataCache)) {
      appLog.load.warn(
        "$runtimeType._replaceSortbaleCache",
        ex: ["fixed cache", cache, _lastSortedDataCache],
      );
      cache = List.of(cache, growable: false);
    }
    _lastSortedDataCache = cache;
  }
  //#endregion

  //#region: auto sync
  void updateAppSync(AppSyncViewModel appSync) {
    _startSyncSub?.cancel();
    _startSyncSub = appSync.appSyncTask.startSyncEvents.listen((id) {
      appLog.habit.debug("onStartSyncEventTriggered", ex: [id]);
      requestReload();
    });
  }
  //#endregion

  //#region: app event
  @override
  void updateAppEvent(AppEventViewModel newAppEvent) {
    _reloadDataSub?.cancel();
    _habitStatusChangedSub?.cancel();
    _habitRecordStatusChangedSub?.cancel();
    _reloadDataSub = newAppEvent.on<ReloadDataEvent>().listen((event) {
      if (event.isInTrace(AppEventPageSource.habitToday)) return;
      appLog.habit.debug("HabitsTody", ex: ["app event triggered", event]);
      requestReload();
    });
    _habitStatusChangedSub = newAppEvent.on<HabitStatusChangedEvent>().listen((
      event,
    ) {
      if (event.isInTrace(AppEventPageSource.habitToday)) return;
      appLog.habit.debug("HabitsTody", ex: ["app event triggered", event]);
      requestReload();
    });
    _habitRecordStatusChangedSub = newAppEvent
        .on<HabitRecordsChangedEvents>()
        .listen((event) {
          if (event.isInTrace(AppEventPageSource.habitToday)) return;
          final now = HabitDate.now();
          if (!event.dateList.contains(now)) return;
          final allHabitCheckedIn = event.uuidList
              .map((e) => getHabit(e)?.getRecordByDate(now))
              .every((e) => e != null);
          if (allHabitCheckedIn) return;
          appLog.habit.debug("HabitsTody", ex: ["app event triggered", event]);
          requestReload();
        });
  }
  //#endregion

  //#region expand
  void updateHabitExpandStatus(
    HabitUUID uuid,
    bool newStatus, {
    bool force = false,
    bool exclusive = false,
    bool listen = true,
  }) {
    if (newStatus == _expandStatus[uuid] && !force) return;
    if (exclusive) _expandStatus.clear();
    _expandStatus.remove(uuid);
    _expandStatus[uuid] = newStatus;
    if (listen) notifyListeners();
  }

  void toggleHabitExpandStatus(HabitUUID uuid, {bool listen = true}) {
    final (lastUUID, lastStatus) = getLastHabitExpandStatus();
    final bool status;
    if (lastUUID == uuid) {
      status = !(lastStatus ?? false);
    } else {
      status = true;
    }
    updateHabitExpandStatus(
      uuid,
      status,
      force: true,
      exclusive: true,
      listen: listen,
    );
  }

  (HabitUUID?, bool?) getLastHabitExpandStatus({bool onlySucc = false}) {
    final uuid = _expandStatus.entries
        .lastWhereOrNull((e) => onlySucc ? e.value : true)
        ?.key;
    if (uuid == null) return (uuid, null);
    final status = getHabitExpandStatus(uuid);
    return (uuid, status);
  }

  bool? getHabitExpandStatus(HabitUUID uuid) => _expandStatus[uuid];
  //#endregion

  //#region actions
  Future<HabitSummaryRecord?> changeRecordStatus(
    HabitUUID uuid, {
    String? reason,
    bool listen = true,
  }) async {
    final data = getHabit(uuid);
    if (data == null) return null;

    final date = HabitDate.now();
    final results = await habitsManager.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
        data: data,
        status: HabitRecordStatus.skip,
        reason: reason,
        dateList: [date],
      ),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitDetail.changeRecordStatus",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics(data);
    _updateHabitReminder(data);
    _resortData();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
    HabitUUID uuid,
    HabitDailyGoal newValue, {
    bool listen = true,
  }) async {
    final data = getHabit(uuid);
    if (data == null) return null;

    final date = HabitDate.now();
    final results = await habitsManager.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
        data: data,
        goal: newValue,
        dateList: [date],
      ),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitsToday.changeRecordValue",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics(data);
    _updateHabitReminder(data);
    _resortData();
    if (listen) notifyListeners();
    return result.data;
  }
  //#endregion

  String toDebugString() {
    final sb = StringBuffer("$runtimeType(");
    for (var habit in _lastSortedDataCache) {
      sb.writeln(habit.toString());
    }
    sb.writeln(")");
    return sb.toString();
  }
}
