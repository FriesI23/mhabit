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

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../models/habit_daily_record_form.dart';
import '../models/habit_date.dart';
import '../models/habit_detail.dart';
import '../models/habit_detail_chart.dart';
import '../models/habit_form.dart';
import '../models/habit_repo_actions.dart';
import '../models/habit_score.dart';
import '../models/habit_status.dart';
import '../models/habit_summary.dart';
import '../storage/db/handlers/habit.dart';
import 'commons.dart';
import 'habits_manager.dart';
import 'utils.dart';

const defaultHabitDetailFreqChardCombine = HabitDetailFreqChartCombine.monthly;
const defaultHabitDetailScoreChartCombine = HabitDetailScoreChartCombine.daily;

class HabitDetailViewModel extends ChangeNotifier
    with NotificationChannelDataMixin, HabitsManagerLoadedMixin
    implements ProviderMounted {
  // data
  HabitDetailData? _habitDetailData;
  final _heatmapDateToColorMap = <HabitDate, num>{};
  final _habitScoreChangedDateColl = <HabitDate, num>{};
  // status
  CancelableCompleter<void>? _loading;
  HabitDetailFreqChartCombine _freqChartCombine =
      defaultHabitDetailFreqChardCombine;
  HabitDetailScoreChartCombine _scoreChartCombine =
      defaultHabitDetailScoreChartCombine;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;

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

  HabitColorType? get habitColorType => _habitDetailData?.data.colorType;

  HabitDailyGoal? get habitDailyGoal => _habitDetailData?.data.dailyGoal;

  HabitDailyGoal? get habitDailyGoalExtra =>
      _habitDetailData?.data.dailyGoalExtra;

  int? get habitTargetDays => _habitDetailData?.data.targetDays;

  String? get habitDailyGoalUnit => _habitDetailData?.dailyGoalUnit;

  int get habitRecordsTotalNum => _habitDetailData?.data.recordsNum ?? 0;

  String get habitDesc => _habitDetailData?.data.desc ?? '';

  bool get isHabitCompleted =>
      _habitDetailData != null ? _habitDetailData!.data.isComplated : false;

  bool get isHabitArchived =>
      _habitDetailData != null ? _habitDetailData!.data.isArchived : false;

  bool get isHabitDeleted => _habitDetailData?.data.isDeleted ?? false;

  HabitUUID? get habitUUID => _habitDetailData?.data.uuid;

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
    _cancelLoading();
    super.dispose();
    _mounted = false;
  }

  void _updateHabitAutoCompleteStatistics() {
    _habitScoreChangedDateColl.clear();
    _habitDetailData?.data.reCalculateAutoComplateRecords(
      firstDay: firstday,
      onScoreChange: (fromDate, toDate, fromScore, toScore) {
        _habitScoreChangedDateColl.addEntries(HabitScoreChangedProtoData(
          fromDate: fromDate,
          toDate: toDate,
          fromScore: fromScore,
          toScore: toScore,
        ).expandToDate());
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
        ? habitsManager.updateHabitReminder(data)
        : Future.value();
  }

  void requestReload() {
    _cancelLoading();
    notifyListeners();
  }

  //#region loading
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

  CancelableCompleter<void>? get _effectiveLoading {
    final loading = _loading;
    return (loading != null && !loading.isCanceled) ? loading : null;
  }

  bool get isDataLoading => _effectiveLoading != null;

  Future<void> loadData(HabitUUID uuid, {bool listen = true}) async {
    final crtLoading = _effectiveLoading;
    if (crtLoading != null) {
      appLog.load.warn("$runtimeType.load",
          ex: ["data already loaded", uuid, crtLoading.isCompleted]);
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
          ex: ["loading data", loading.hashCode, listen]);

      // init habit
      final data = await habitsManager.loadHabitDetailData(uuid);
      if (data == null) return loadingFailed(["data load failed", uuid]);
      // if (data.data.isDeleted) return loadingFailed(["data deleted", uuid]);
      if (!mounted) return loadingFailed(["viewmodel disposed", uuid]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;
      _habitDetailData = data;
      _updateHabitAutoCompleteStatistics();
      _updateHabitReminder();
      // complete
      loading.complete();
      // reload
      if (listen) {
        notifyListeners();
      }
      appLog.load.debug("$runtimeType.load",
          ex: ["loaded", loading.hashCode, listen, data]);
    }

    loadingData().catchError((e, s) {
      if (loading.isCanceled) return loadingCancelled();
      loadingFailed(["unexpected error", e]);
      appLog.load.error("$runtimeType.load",
          ex: ["caught", e, loading.hashCode], stackTrace: s);
    }).whenComplete(() {
      if (!loading.isCompleted && !loading.isCanceled) {
        loading.complete();
      }
    });

    return loading.operation.valueOrCancellation();
  }

  Future<String?> loadRecordReason(HabitRecordDate date) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;
    return habitsManager.loadHabitRecordReason(data, date);
  }

  Future<HabitDBCell?> loadCurrentHabitDetail() async {
    final habitUUID = this.habitUUID;
    if (habitUUID == null) return null;
    return habitsManager.loadHabitDetail(habitUUID);
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

  void updateFreqChartCombine(HabitDetailFreqChartCombine newCombine,
      {bool listen = true}) {
    if (newCombine != _freqChartCombine) {
      _freqChartCombine = newCombine;
      if (listen) notifyListeners();
    }
  }

  Map<HabitDate, HabitDetailFreqChartData> getRecordFreqChartDatas() =>
      habitDetailData != null
          ? FreqChartCalculator(habitDetailData!,
                  firstday: firstday, combine: freqChartCombine)
              .calculate()
          : const {};
  //#endregion

  //#region score chart
  HabitDetailScoreChartCombine get scoreChartCombine => _scoreChartCombine;

  void updateScoreChartCombine(HabitDetailScoreChartCombine newCombine,
      {bool listen = true}) {
    if (newCombine != _scoreChartCombine) {
      _scoreChartCombine = newCombine;
      if (listen) notifyListeners();
    }
  }

  Map<HabitDate, HabitDetailScoreChartDate> getRecordScoreChartDatas() =>
      habitDetailData != null
          ? ScoreChartCalculator(habitDetailData!,
                  firstday: firstday,
                  combine: scoreChartCombine,
                  scoreOverride: (date) => _habitScoreChangedDateColl[date])
              .calculate()
          : const {};
  //#endregion

  //#region actions
  Future<HabitSummaryRecord?> changeRecordStatus(HabitRecordDate date,
      {bool listen = true}) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;

    final results = await habitsManager.changeHabitRecordStatus(
      preAction: AutoChangeRecordStatusAction(data: data, dateList: [date]),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info("HabitDetail.changeRecordStatus",
        beforeVal: result.origin,
        afterVal: result.data,
        ex: ["rst=$result", data.id, data.progress]);

    _updateHabitAutoCompleteStatistics();
    _updateHabitReminder();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordReason(
      HabitRecordDate date, String newReason,
      {bool listen = true}) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;

    final results = await habitsManager.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
          data: data,
          reason: newReason,
          status: HabitRecordStatus.skip,
          dateList: [date]),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info("HabitDetail.changeRecordReason",
        beforeVal: result.origin,
        afterVal: result.data,
        ex: ["rst=$result", data.id, data.progress]);

    _updateHabitAutoCompleteStatistics();
    _updateHabitReminder();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
      HabitRecordDate date, HabitDailyGoal newValue,
      {bool listen = true}) async {
    final data = _habitDetailData?.data;
    if (data == null) return null;

    final results = await habitsManager.changeHabitRecordStatus(
      preAction: ChangeMultiRecordStatusAction(
          data: data, goal: newValue, dateList: [date]),
      postActionBuilder: (results) =>
          ChangeRecordStatusPostAction(data: data, results: results),
    );
    final result = results.firstOrNull;
    if (result == null) return null;

    appLog.value.info("HabitDetail.changeRecordValue",
        beforeVal: result.origin,
        afterVal: result.data,
        ex: ["rst=$result", data.id, data.progress]);

    _updateHabitAutoCompleteStatistics();
    _updateHabitReminder();
    if (listen) notifyListeners();
    return result.data;
  }

  Future<HabitStatusChangedRecord?> _changeHabitsStatus(
      HabitStatus newStatus) async {
    final habitDetailData = this.habitDetailData;
    if (habitDetailData == null) return null;

    final results = await habitsManager.changeHabitStatus(
        action: ChangeMultiHabitStatusAction([habitDetailData.data],
            status: newStatus),
        extraResolver: (result) async {
          final t1 = _updateHabitReminder();
          _updateHabitAutoCompleteStatistics();
          await t1;
        });

    if (results.isEmpty || !mounted) return null;
    final result = results.first;
    return HabitStatusChangedRecord(
        habitUUID: result.data.uuid,
        newStatus: result.data.status,
        orgStatus: result.orgStatus);
  }

  Future<HabitStatusChangedRecord?> onConfirmToArchiveHabit(
      {bool listen = true}) async {
    appLog.habit.info("$runtimeType.onConfirmToArchiveHabit",
        ex: [listen, habitDetailData?.data]);
    if (habitDetailData?.data.status == HabitStatus.deleted) {
      return null;
    }
    final result = await _changeHabitsStatus(HabitStatus.archived);
    if (listen) requestReload();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToUnarchiveHabit(
      {bool listen = true}) async {
    appLog.habit.info("$runtimeType.onConfirmToUnarchiveHabit",
        ex: [listen, habitDetailData?.data]);
    if (habitDetailData?.data.status == HabitStatus.deleted) {
      return null;
    }
    final result = await _changeHabitsStatus(HabitStatus.activated);
    if (listen) requestReload();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToDeleteHabit(
      {bool listen = false}) async {
    appLog.habit.info("$runtimeType.onConfirmToDeleteHabit",
        ex: [listen, habitDetailData?.data]);
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

  const FreqChartCalculator(HabitDetailData data,
      {required this.firstday, required this.combine})
      : _data = data;

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
              overfulfilTotalValue: overfulfilTotalValue),
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
              tryAddToResult(record.date,
                  complate: 1, complateTotalValue: useVal);
              break;
            case HabitDailyComplateStatus.goodjob:
              tryAddToResult(record.date,
                  overfulfil: 1, overfulfilTotalValue: useVal);
              break;
            case HabitDailyComplateStatus.tryhard:
              tryAddToResult(record.date,
                  autoComplate: isAutoComplete ? 1 : 0,
                  autoComplateTotalValue: isAutoComplete ? useVal : 0,
                  partiallyCompleted: isAutoComplete ? 0 : 1,
                  partiallyCompletedTotalValue: isAutoComplete ? 0 : useVal);
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

  const ScoreChartCalculator(HabitDetailData data,
      {required this.firstday, required this.combine, this.scoreOverride})
      : _data = data;

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

enum DetailPageReturnOpr { unknown, deleted }

class DetailPageReturn {
  final DetailPageReturnOpr op;
  final String? habitName;
  final List<HabitStatusChangedRecord>? recordList;

  const DetailPageReturn({
    this.op = DetailPageReturnOpr.unknown,
    this.habitName,
    this.recordList,
  });
}
