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
import 'package:flutter/foundation.dart';

import '../../../common/consts.dart';
import '../../../common/exceptions.dart';
import '../../../common/types.dart';
import '../../../common/utils.dart';
import '../../../logging/helper.dart';
import '../../../logging/logger_stack.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_daily_record_form.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_detail.dart';
import '../../../models/habit_detail_chart.dart';
import '../../../models/habit_form.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_repo_actions.dart';
import '../../../models/habit_score.dart';
import '../../../models/habit_status.dart';
import '../../../models/habit_summary.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/support/page_load_runtime.dart';
import '../../../providers/support/utils.dart';
import '../../../providers/workflow/habits_manager.dart';
import '../../../storage/db/handlers/habit.dart';

const defaultHabitDetailFreqChardCombine = HabitDetailFreqChartCombine.monthly;
const defaultHabitDetailScoreChartCombine = HabitDetailScoreChartCombine.daily;

class HabitDetailViewModel extends ChangeNotifier implements ProviderMounted {
  // data
  HabitDetailData? _habitDetailData;
  final _heatmapDateToColorMap = <HabitDate, num>{};
  final _habitScoreChangedDateColl = <HabitDate, num>{};
  HabitDetailFreqChartCombine _freqChartCombine =
      defaultHabitDetailFreqChardCombine;
  HabitDetailScoreChartCombine _scoreChartCombine =
      defaultHabitDetailScoreChartCombine;
  final _pageLoad = PageLoadRuntime();
  bool _nextForceReload = false;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;
  late HabitDetailAccess _access;

  HabitDetailViewModel();

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

  HabitDetailData? get habitDetailData => _habitDetailData;

  String get habitName =>
      _habitDetailData != null ? _habitDetailData!.name : '';

  num get habitProgress =>
      _habitDetailData != null ? _habitDetailData!.data.progress : 0.0;

  HabitDate get habitStartDate => _habitDetailData != null
      ? _habitDetailData!.data.startDate
      : HabitDate.now();

  Duration get duringFromStartDate =>
      HabitDate.now().difference(habitStartDate);

  HabitType? get habitType => _habitDetailData?.data.type;

  HabitDailyGoal? get habitOkValue => _habitDetailData?.data.habitOkValue;

  HabitColor? get habitColor => _habitDetailData?.data.color;

  HabitDailyGoal? get habitDailyGoal => _habitDetailData?.data.dailyGoal;

  HabitDailyGoal? get habitDailyGoalExtra =>
      _habitDetailData?.data.dailyGoalExtra;

  int? get habitTargetDays => _habitDetailData?.data.targetDays;

  String? get habitDailyGoalUnit => _habitDetailData?.dailyGoalUnit;

  int get habitRecordsTotalNum => _habitDetailData?.data.recordCount ?? 0;

  String get habitDesc => _habitDetailData?.data.desc ?? '';

  bool get isHabitCompleted =>
      _habitDetailData != null ? _habitDetailData!.data.isComplated : false;

  bool get isHabitArchived =>
      _habitDetailData != null ? _habitDetailData!.data.isArchived : false;

  bool get isHabitDeleted => _habitDetailData?.data.isDeleted ?? false;

  HabitUUID? get habitUUID => _habitDetailData?.data.uuid;

  /// Group UUID associated with this habit, or null if uncategorized.
  String? get habitGroupId => _habitDetailData?.data.groupId;

  Key getInsideVersion() {
    return _habitDetailData != null
        ? _habitDetailData!.diryMark
        : ValueKey(hashCode);
  }

  HabitSummaryRecord? getHabitRecordData(HabitDate date) {
    return _habitDetailData?.data.getRecordByDate(date);
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _pageLoad.cancel(logName: "$runtimeType._cancelLoading");
    super.dispose();
    _mounted = false;
  }

  void _updateHabitAutoCompleteStatistics() {
    _habitScoreChangedDateColl.clear();
    _habitDetailData?.data.reCalculateAutoComplateRecords(
      firstDay: firstday,
      onScoreChange: (fromDate, toDate, fromScore, toScore) {
        _habitScoreChangedDateColl.addEntries(
          HabitScoreChangedProtoData(
            fromDate: fromDate,
            toDate: toDate,
            fromScore: fromScore,
            toScore: toScore,
          ).expandToDate(),
        );
      },
    );
    if (habitDetailData != null) {
      _heatmapDateToColorMap
        ..clear()
        ..addAll(HeatmapColorsCalculator(habitDetailData!).calculate());
    }
  }

  Future<void> _updateHabitReminder() {
    final data = _habitDetailData?.data;
    return data != null
        ? _access.repairHabitReminders(
            params: HabitReminderRepairParams.loadedHabit(data),
          )
        : Future.value();
  }

  void attachAccess(HabitDetailAccess newAccess) {
    _access = newAccess;
  }

  HabitGroupData? get groupDisplayInfo => _habitDetailData?.groupData;

  void requestReload() {
    _nextForceReload = true;
    _pageLoad.cancel(logName: "$runtimeType._cancelLoading");
    notifyListeners();
  }

  bool consumeForceReloadFlag() {
    final result = _nextForceReload;
    _nextForceReload = false;
    return result;
  }

  bool get hasLoad => _pageLoad.hasLoad;

  bool get hasLoaded => _pageLoad.hasLoaded;

  //#region loading
  Future<void> loadData(HabitUUID uuid, {bool listen = true}) {
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
      logName: "$runtimeType.load",
      alreadyLoadingEx: ["data already loaded", uuid],
      loadData: (loading) async {
        if (!mounted) {
          return loadingFailed(loading, const ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        appLog.load.debug(
          "$runtimeType.load",
          ex: ["loading data", loading.hashCode, listen],
        );

        // init habit
        final data = await _access.loadHabitDetailData(uuid);
        if (data == null) {
          return loadingFailed(loading, ["data load failed", uuid]);
        }
        // if (data.data.isDeleted) return loadingFailed(["data deleted", uuid]);
        if (!mounted) {
          return loadingFailed(loading, ["viewmodel disposed", uuid]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;
        _habitDetailData = data;
        _updateHabitAutoCompleteStatistics();
        _updateHabitReminder();
        loading.complete();
        if (listen) notifyListeners();
        appLog.load.debug(
          "$runtimeType.load",
          ex: ["loaded", loading.hashCode, listen, data],
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

  Future<String?> loadRecordReason(HabitRecordDate date) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;
    return _access.loadHabitRecordReason(data, date);
  }

  Future<HabitDBCell?> loadCurrentHabitDetail() async {
    final habitUUID = this.habitUUID;
    if (habitUUID == null) return null;
    return _access.loadHabitDetail(habitUUID);
  }
  //#endregion

  //#region heatmap
  Map<HabitDate, num> get heatmapDateToColorMap => _heatmapDateToColorMap;

  HabitHeatmapCellStatus getHabitHeatmapCellStatus(HabitDate date) {
    final record = getHabitRecordData(date);
    return HabitHeatmapCellStatus(
      status: record?.status,
      value: record?.value,
      isAutoComplete: _habitDetailData?.data.isRecordAutoComplated(date),
    );
  }
  //#endregion

  //#region freq chart
  HabitDetailFreqChartCombine get freqChartCombine => _freqChartCombine;

  void updateFreqChartCombine(
    HabitDetailFreqChartCombine newCombine, {
    bool listen = true,
  }) {
    if (newCombine != _freqChartCombine) {
      _freqChartCombine = newCombine;
      if (listen) notifyListeners();
    }
  }

  Map<HabitDate, HabitDetailFreqChartData> getRecordFreqChartDatas() =>
      habitDetailData != null
      ? FreqChartCalculator(
          habitDetailData!,
          firstday: firstday,
          combine: freqChartCombine,
        ).calculate()
      : const {};
  //#endregion

  //#region score chart
  HabitDetailScoreChartCombine get scoreChartCombine => _scoreChartCombine;

  void updateScoreChartCombine(
    HabitDetailScoreChartCombine newCombine, {
    bool listen = true,
  }) {
    if (newCombine != _scoreChartCombine) {
      _scoreChartCombine = newCombine;
      if (listen) notifyListeners();
    }
  }

  Map<HabitDate, HabitDetailScoreChartDate> getRecordScoreChartDatas() =>
      habitDetailData != null
      ? ScoreChartCalculator(
          habitDetailData!,
          firstday: firstday,
          combine: scoreChartCombine,
          scoreOverride: (date) => _habitScoreChangedDateColl[date],
        ).calculate()
      : const {};
  //#endregion

  //#region actions
  Future<HabitSummaryRecord?> changeRecordStatus(
    HabitRecordDate date, {
    bool listen = true,
  }) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;

    final results = await _access.changeHabitRecordStatus(
      preAction: AutoChangeRecordStatusAction(data: data, dateList: [date]),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
      beforeReminderUpdate: (_, _) => _updateHabitAutoCompleteStatistics(),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitDetail.changeRecordStatus",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordReason(
    HabitRecordDate date,
    String newReason, {
    bool listen = true,
  }) async {
    final data = _habitDetailData?.data;
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
      beforeReminderUpdate: (_, _) => _updateHabitAutoCompleteStatistics(),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitDetail.changeRecordReason",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
    HabitRecordDate date,
    HabitDailyGoal newValue, {
    bool listen = true,
  }) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;

    final results = await _access.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
        data: data,
        goal: newValue,
        dateList: [date],
      ),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
      beforeReminderUpdate: (_, _) => _updateHabitAutoCompleteStatistics(),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info(
      "HabitDetail.changeRecordValue",
      beforeVal: result.origin,
      afterVal: result.data,
      ex: ["rst=$result", data.id, data.progress],
    );

    _updateHabitAutoCompleteStatistics();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitStatusChangedRecord?> _changeHabitsStatus(
    HabitStatus newStatus,
  ) async {
    final habitDetailData = this.habitDetailData;
    if (habitDetailData == null) return null;

    final results = await _access.changeHabitStatus(
      action: ChangeMultiHabitStatusAction([
        habitDetailData.data,
      ], status: newStatus),
      extraResolver: (result) => _updateHabitAutoCompleteStatistics(),
    );

    if (results.isEmpty || !mounted) return null;
    final result = results.first;
    return HabitStatusChangedRecord(
      habitUUID: result.data.uuid,
      newStatus: result.data.status,
      orgStatus: result.orgStatus,
    );
  }

  Future<HabitStatusChangedRecord?> onConfirmToArchiveHabit({
    bool listen = true,
  }) async {
    appLog.habit.info(
      "$runtimeType.onConfirmToArchiveHabit",
      ex: [listen, habitDetailData?.data],
    );
    if (habitDetailData?.data.status == HabitStatus.deleted) {
      return null;
    }
    final result = await _changeHabitsStatus(HabitStatus.archived);
    if (listen) requestReload();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToUnarchiveHabit({
    bool listen = true,
  }) async {
    appLog.habit.info(
      "$runtimeType.onConfirmToUnarchiveHabit",
      ex: [listen, habitDetailData?.data],
    );
    if (habitDetailData?.data.status == HabitStatus.deleted) {
      return null;
    }
    final result = await _changeHabitsStatus(HabitStatus.activated);
    if (listen) requestReload();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToDeleteHabit({
    bool listen = false,
  }) async {
    appLog.habit.info(
      "$runtimeType.onConfirmToDeleteHabit",
      ex: [listen, habitDetailData?.data],
    );
    if (habitDetailData?.data.status == HabitStatus.deleted) {
      return null;
    }
    final result = await _changeHabitsStatus(HabitStatus.deleted);
    if (listen) requestReload();
    return result;
  }
  //#endregion

  //#region debug
  String debugGetDataString() => _habitDetailData.toString();

  HabitDetailData? debugGetData() => _habitDetailData;
  //#endregion
}

class HeatmapColorsCalculator {
  const HeatmapColorsCalculator(HabitDetailData data) : _data = data;

  final HabitDetailData _data;

  num? _getNormalHeatmapColor(HabitSummaryRecord record) {
    switch (record.status) {
      case HabitRecordStatus.unknown:
        return null;
      case HabitRecordStatus.skip:
        return null;
      case HabitRecordStatus.done:
        final data = _data.data;
        final complateStatus = HabitDailyRecordForm.getImp(
          type: data.type,
          value: record.value,
          targetValue: data.dailyGoal,
          extraTargetValue: data.dailyGoalExtra,
        ).complateStatus;
        switch (complateStatus) {
          case HabitDailyComplateStatus.zero:
            return HabitHeatMapColorMapDefine.uncomplate;
          case HabitDailyComplateStatus.ok:
            return HabitHeatMapColorMapDefine.complate;
          case HabitDailyComplateStatus.goodjob:
            return HabitHeatMapColorMapDefine.overfulfil;
          case HabitDailyComplateStatus.tryhard:
            return HabitHeatMapColorMapDefine.partiallyCompleted;
          default:
            return null;
        }
    }
  }

  num? _getNegativeHeatmapColor(HabitSummaryRecord record) {
    switch (record.status) {
      case HabitRecordStatus.unknown:
        return null;
      case HabitRecordStatus.skip:
        return null;
      case HabitRecordStatus.done:
        final data = _data.data;
        final complateStatus = HabitDailyRecordForm.getImp(
          type: data.type,
          value: record.value,
          targetValue: data.dailyGoal,
          extraTargetValue: data.dailyGoalExtra,
        ).complateStatus;
        switch (complateStatus) {
          case HabitDailyComplateStatus.ok:
            return HabitHeatMapColorMapDefine.complate;
          case HabitDailyComplateStatus.goodjob:
            return HabitHeatMapColorMapDefine.overfulfil;
          case HabitDailyComplateStatus.tryhard:
            return HabitHeatMapColorMapDefine.partiallyCompleted;
          case HabitDailyComplateStatus.noeffect:
            return HabitHeatMapColorMapDefine.uncomplate;
          default:
            return null;
        }
    }
  }

  Map<HabitDate, num> calculate() {
    final Map<HabitDate, num> tmpMap = {};

    for (var date in _data.autoRecordsDate) {
      tmpMap[date] = HabitHeatMapColorMapDefine.autoComplate;
    }

    for (var record in _data.records) {
      num? colorNum;
      switch (_data.type) {
        case HabitType.unknown:
          break;
        case HabitType.normal:
          colorNum = _getNormalHeatmapColor(record);
          break;
        case HabitType.negative:
          colorNum = _getNegativeHeatmapColor(record);
          break;
      }
      if (colorNum != null) tmpMap[record.date] = colorNum;
    }

    return tmpMap;
  }
}

class FreqChartCalculator {
  final HabitDetailData _data;
  final HabitDetailFreqChartCombine combine;
  final int firstday;

  const FreqChartCalculator(
    HabitDetailData data, {
    required this.firstday,
    required this.combine,
  }) : _data = data;

  Map<HabitDate, HabitDetailFreqChartData> calculate() {
    final Map<HabitDate, HabitDetailFreqChartData> result = {};
    final data = _data.data;

    void tryAddToResult(
      HabitDate date, {
      int partiallyCompleted = 0,
      int autoComplate = 0,
      int complate = 0,
      int overfulfil = 0,
      num partiallyCompletedTotalValue = 0,
      num autoComplateTotalValue = 0,
      num complateTotalValue = 0,
      num overfulfilTotalValue = 0,
    }) {
      final firstDate = freqChartHelper.getProtoDate(date, firstday, combine);
      result.update(
        firstDate,
        (value) => value
          ..increasedOnly(
            partiallyCompleted: partiallyCompleted,
            autoComplate: autoComplate,
            complate: complate,
            overfulfil: overfulfil,
            partiallyCompletedTotalValue: partiallyCompletedTotalValue,
            autoComplateTotalValue: autoComplateTotalValue,
            complateTotalValue: complateTotalValue,
            overfulfilTotalValue: overfulfilTotalValue,
          ),
        ifAbsent: () => HabitDetailFreqChartData()
          ..increasedOnly(
            partiallyCompleted: partiallyCompleted,
            autoComplate: autoComplate,
            complate: complate,
            overfulfil: overfulfil,
            partiallyCompletedTotalValue: partiallyCompletedTotalValue,
            autoComplateTotalValue: autoComplateTotalValue,
            complateTotalValue: complateTotalValue,
            overfulfilTotalValue: overfulfilTotalValue,
          ),
      );
    }

    // Fixed #84
    // Use the user-entered value for auto-complete instead of using dailyGoal
    for (var record in _data.records) {
      final useVal = record.value;
      switch (record.status) {
        case HabitRecordStatus.unknown:
          break;
        case HabitRecordStatus.done:
          final status = HabitDailyRecordForm.getImp(
            type: data.type,
            value: record.value,
            targetValue: data.dailyGoal,
            extraTargetValue: data.dailyGoalExtra,
          ).complateStatus;
          final isAutoComplete = data.isRecordAutoComplated(record.date);
          switch (status) {
            case HabitDailyComplateStatus.noeffect:
            case HabitDailyComplateStatus.zero:
              tryAddToResult(record.date, autoComplate: isAutoComplete ? 1 : 0);
              break;
            case HabitDailyComplateStatus.ok:
              tryAddToResult(
                record.date,
                complate: 1,
                complateTotalValue: useVal,
              );
              break;
            case HabitDailyComplateStatus.goodjob:
              tryAddToResult(
                record.date,
                overfulfil: 1,
                overfulfilTotalValue: useVal,
              );
              break;
            case HabitDailyComplateStatus.tryhard:
              tryAddToResult(
                record.date,
                autoComplate: isAutoComplete ? 1 : 0,
                autoComplateTotalValue: isAutoComplete ? useVal : 0,
                partiallyCompleted: isAutoComplete ? 0 : 1,
                partiallyCompletedTotalValue: isAutoComplete ? 0 : useVal,
              );
              break;
          }
          break;
        case HabitRecordStatus.skip:
          final isAutoComplete = data.isRecordAutoComplated(record.date);
          tryAddToResult(record.date, autoComplate: isAutoComplete ? 1 : 0);
          break;
      }
    }

    for (var autoDate in _data.autoRecordsDate) {
      if (data.getRecordByDate(autoDate) != null) continue;
      final date = freqChartHelper.getProtoDate(autoDate, firstday, combine);
      tryAddToResult(date, autoComplate: 1);
    }

    return result;
  }
}

class ScoreChartCalculator {
  final HabitDetailData _data;
  final HabitDetailScoreChartCombine combine;
  final int firstday;
  final num? Function(HabitDate date)? scoreOverride;

  const ScoreChartCalculator(
    HabitDetailData data, {
    required this.firstday,
    required this.combine,
    this.scoreOverride,
  }) : _data = data;

  Map<HabitDate, HabitDetailScoreChartDate> calculate() {
    final Map<HabitDate, HabitDetailScoreChartDate> result = {};
    final endedDate = HabitDate.now();

    HabitDate crtDate = _data.data.startDate;
    num crtScore = 0.0;
    while (crtDate <= endedDate) {
      final key = scoreChartHelp.getProtoDate(crtDate, firstday, combine);
      crtScore = scoreOverride?.call(crtDate) ?? crtScore;
      result.update(
        key,
        (value) => value..addScore(crtScore),
        ifAbsent: () => HabitDetailScoreChartDate()..addScore(crtScore),
      );
      crtDate = crtDate.addDays(1);
    }
    return result;
  }
}
