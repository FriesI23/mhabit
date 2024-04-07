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
import '../model/habit_daily_record_form.dart';
import '../model/habit_date.dart';
import '../model/habit_detail.dart';
import '../model/habit_detail_chart.dart';
import '../model/habit_form.dart';
import '../model/habit_score.dart';
import '../model/habit_status.dart';
import '../model/habit_summary.dart';
import '../persistent/db_helper_provider.dart';
import '../reminders/notification_service.dart';
import 'commons.dart';
import 'utils.dart';

const defaultHabitDetailFreqChardCombine = HabitDetailFreqChartCombine.monthly;
const defaultHabitDetailScoreChartCombine = HabitDetailScoreChartCombine.daily;

class HabitDetailViewModel extends ChangeNotifier
    with NotificationChannelDataMixin, DBHelperLoadedMixin, DBOperationsMixin
    implements ProviderMounted, HabitSummaryDirtyMarker {
  // data
  HabitDetailData? _habitDetailData;
  final _heatmapDateToColorMap = <HabitDate, num>{};
  final _habitScoreChangedDateColl = <HabitDate, num>{};
  // status
  bool _reloadDBToggleSwich = false;
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

  bool get reloadDBToggleSwich => _reloadDBToggleSwich;

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

  HabitUUID? get habitUUID => _habitDetailData?.data.uuid;

  UniqueKey getInsideVersion() {
    return _habitDetailData != null ? _habitDetailData!.diryMark : UniqueKey();
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

  @override
  Future<void> bumpHatbitVersion(HabitSummaryData data) async {
    data.bumpVersion();
    // add reminder
    await _regrHabitReminder(data);
  }

  bool rockreloadDBToggleSwich() {
    _reloadDBToggleSwich = !_reloadDBToggleSwich;
    _cancelLoading();
    notifyListeners();
    return _reloadDBToggleSwich;
  }

  void _cancelLoading() {
    if (_loading?.isCompleted != true) {
      appLog.load.info("$runtimeType._cancelLoading", ex: [_loading]);
      _loading?.operation.cancel();
    }
    _loading = null;
  }

  Future<void> loadData(HabitUUID uuid,
      {bool listen = true, bool inFutureBuilder = false}) async {
    if (_loading != null) {
      appLog.load.warn("$runtimeType.load", ex: ["data already loaded", uuid]);
      return _loading!.operation.value;
    }

    void loadingFailed(List errmsg) {
      appLog.load.warn("$runtimeType.load", ex: errmsg);
      _loading?.completeError(errmsg);
    }

    Future<void> loadingData() async {
      appLog.load.debug("$runtimeType.load",
          ex: ["loading data", listen, inFutureBuilder]);
      if (!mounted) {
        loadingFailed(["viewmodel disposed"]);
        return;
      }
      // init habit
      final dataLoadTask = habitDBHelper.loadHabitDetail(uuid);
      final recordLoadTask = recordDBHelper.loadRecords(uuid);
      final cell = await dataLoadTask;
      final records = await recordLoadTask;
      if (cell == null) {
        loadingFailed(["data load failed", uuid]);
        return;
      }
      if (!mounted) {
        loadingFailed(["viewmodel disposed", uuid]);
        return;
      }
      final data = HabitDetailData.fromDBQueryCell(cell);
      data.data.initRecords(
          records.map((e) => HabitSummaryRecord.fromDBQueryCell(e)));
      _habitDetailData = data;
      _calcHabitInfo();
      appLog.load.debug("$runtimeType.load",
          ex: ["loaded", listen, inFutureBuilder, data]);
      // complete
      _loading?.complete();
      // reload
      if (listen) {
        if (!inFutureBuilder) _reloadDBToggleSwich = !_reloadDBToggleSwich;
        notifyListeners();
      }
    }

    _loading = CancelableCompleter<void>();
    loadingData();
    return _loading?.operation.value;
  }

  void _calcHabitInfo() {
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

  Future<void> _regrHabitReminder(HabitSummaryData data) async {
    try {
      switch (data.status) {
        case HabitStatus.activated:
          if (data.reminder != null) {
            NotificationService().regrHabitReminder(
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
          NotificationService().cancelHabitReminder(id: data.id);
          break;
      }
    } on Exception catch (e) {
      appLog.notify.error("$runtimeType._regrHabitReminder",
          ex: ["catch err when try regr reminder"], error: e);
    }
  }

  //#region heatmap
  Map<HabitDate, num> get heatmapDateToColorMap => _heatmapDateToColorMap;

  HabitHeatmapCellStatus getHabitHeatmapCellStatus(HabitDate date) {
    var record = getHabitRecordData(date);
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
    if (_habitDetailData == null) return null;

    final data = _habitDetailData!.data;
    final util = ChangeRecordStatusHelper(date: date, data: data);
    final recordTuple = util.getNewRecordOnTap();
    if (recordTuple == null) return null;

    final orgRecord = recordTuple.item1;
    final record = recordTuple.item2;
    final isNew = recordTuple.item3;

    await saveHabitRecordToDB(data.id, data.uuid, record, isNew: isNew);

    final result = data.addRecord(record, replaced: true);
    _calcHabitInfo();

    appLog.value.info("$runtimeType.onTapToChangeRecordStatus",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);
    if (listen) notifyListeners();

    await bumpHatbitVersion(data);
    return record;
  }

  Future<HabitSummaryRecord?> changeRecordReason(
      HabitRecordDate date, String newReason,
      {bool listen = true}) async {
    if (_habitDetailData == null) return null;

    final data = _habitDetailData!.data;

    final record = data.getRecordByDate(date);
    if (record == null) return null;

    await saveHabitRecordToDB(data.id, data.uuid, record,
        isNew: false, withReason: newReason);

    if (listen) notifyListeners();
    return record;
  }

  Future<HabitSummaryRecord?> changeRecordValue(
      HabitRecordDate date, HabitDailyGoal newValue,
      {bool listen = true}) async {
    if (_habitDetailData == null) return null;

    final data = _habitDetailData!.data;
    final util = ChangeRecordStatusHelper(date: date, data: data);
    final recordTuple = util.getNewRecordOnLongTap(newValue);
    if (recordTuple == null) return null;

    final orgRecord = recordTuple.item1;
    final record = recordTuple.item2;
    final isNew = recordTuple.item3;

    await saveHabitRecordToDB(data.id, data.uuid, record, isNew: isNew);

    var result = data.addRecord(record, replaced: true);
    _calcHabitInfo();

    appLog.value.info("$runtimeType.onLongPressChangeRecordValue",
        beforeVal: orgRecord,
        afterVal: record,
        ex: ["rst=$result", data.id, data.progress, isNew]);

    if (listen) notifyListeners();
    await bumpHatbitVersion(data);
    return record;
  }

  Future<HabitStatusChangedRecord?> _changeHabitsStatus(
      HabitUUID habitUUID, HabitStatus newStatus) async {
    if (habitDetailData == null) return null;
    final orgStatus = habitDetailData!.data.status;
    final changes =
        await habitDBHelper.updateSelectedHabitStatus([habitUUID], newStatus);
    if (changes < 1 || !mounted) return null;
    return HabitStatusChangedRecord(
        habitUUID: habitUUID, newStatus: newStatus, orgStatus: orgStatus);
  }

  Future<HabitStatusChangedRecord?> onConfirmToArchiveHabit(
      {bool listen = true}) async {
    appLog.habit.info("$runtimeType.onConfirmToArchiveHabit",
        ex: [listen, habitDetailData?.data]);
    if (!(habitDetailData != null &&
        habitDetailData?.data.status != HabitStatus.deleted)) {
      return null;
    }
    final result = await _changeHabitsStatus(habitUUID!, HabitStatus.archived);
    if (listen) rockreloadDBToggleSwich();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToUnarchiveHabit(
      {bool listen = true}) async {
    appLog.habit.info("$runtimeType.onConfirmToUnarchiveHabit",
        ex: [listen, habitDetailData?.data]);
    if (!(habitDetailData != null &&
        habitDetailData?.data.status != HabitStatus.deleted)) {
      return null;
    }
    final result = await _changeHabitsStatus(habitUUID!, HabitStatus.activated);
    if (listen) rockreloadDBToggleSwich();
    return result;
  }

  Future<HabitStatusChangedRecord?> onConfirmToDeleteHabit(
      {bool listen = false}) async {
    appLog.habit.info("$runtimeType.onConfirmToDeleteHabit",
        ex: [listen, habitDetailData?.data]);
    if (!(habitDetailData != null &&
        habitDetailData?.data.status != HabitStatus.deleted)) {
      return null;
    }
    final result = await _changeHabitsStatus(habitUUID!, HabitStatus.deleted);
    if (listen) rockreloadDBToggleSwich();
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
    Map<HabitDate, num> tmpMap = {};

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
