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
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/logging.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../db/db_helper/habits.dart';
import '../db/db_helper/records.dart';
import '../model/habit_date.dart';
import '../model/habit_detail.dart';
import '../model/habit_detail_chart.dart';
import '../model/habit_form.dart';
import '../model/habit_summary.dart';
import '../model/score.dart';
import '../reminders/notification_service.dart';
import 'commons.dart';

const defaultHabitDetailFreqChardCombine = HabitDetailFreqChartCombine.monthly;
const defaultHabitDetailScoreChartCombine = HabitDetailScoreChartCombine.daily;

enum HabitDetailLoadDataResult {
  done,
  alreadyLoaded,
  habitMissing,
}

mixin _HabitDetailHeatmapColorMixin {
  HabitDetailData? habitDetailData;
  final Map<HabitDate, num> _heatmapDateToColorMap = {};

  Map<HabitDate, num> get heatmapDateToColorMap => _heatmapDateToColorMap;

  void calcRecordsHeatmapColorMap() {
    if (habitDetailData == null) return;
    Map<HabitDate, num> tmpMap = {};

    for (var date in habitDetailData!.autoRecordsDate) {
      tmpMap[date] = HabitHeatMapColorMapDefine.autoComplate;
    }

    for (var record in habitDetailData!.records) {
      switch (record.status) {
        case HabitRecordStatus.unknown:
          break;
        case HabitRecordStatus.skip:
          break;
        case HabitRecordStatus.done:
          var complateStatus = HabitDailyRecordForm.getComplateStatus(
              record.value, habitDetailData!.data.dailyGoal);
          switch (complateStatus) {
            case HabitDailyComplateStatus.zero:
              tmpMap[record.date] = HabitHeatMapColorMapDefine.uncomplate;
              break;
            case HabitDailyComplateStatus.ok:
              tmpMap[record.date] = HabitHeatMapColorMapDefine.complate;
              break;
            case HabitDailyComplateStatus.goodjob:
              tmpMap[record.date] = HabitHeatMapColorMapDefine.overfulfil;
              break;
            case HabitDailyComplateStatus.tryhard:
              tmpMap[record.date] =
                  HabitHeatMapColorMapDefine.partiallyCompleted;
              break;
          }
          break;
      }
    }

    _heatmapDateToColorMap
      ..clear()
      ..addAll(tmpMap);
  }
}

mixin _HabitDetailFreqChartMixin {
  HabitDetailData? habitDetailData;
  HabitDetailFreqChartCombine _freqChartCombine =
      defaultHabitDetailFreqChardCombine;

  HabitDetailFreqChartCombine get freqChartCombine => _freqChartCombine;

  int get firstday;

  set freqChartCombine(HabitDetailFreqChartCombine newCombine) {
    _freqChartCombine = newCombine;
  }

  Map<HabitDate, HabitDetailFreqChartData> getRecordFreqChartDatas() {
    Map<HabitDate, HabitDetailFreqChartData> result = {};

    void tryAddRecordToResult(
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
      HabitDetailFreqChartData data;

      var firstDate =
          getProtoDateByFreqChartCombine(date, freqChartCombine, firstday);
      if (result.containsKey(firstDate)) {
        data = result[firstDate]!;
      } else {
        data = HabitDetailFreqChartData();
        result[firstDate] = data;
      }

      data.increasedOnly(
        partiallyCompleted: partiallyCompleted,
        autoComplate: autoComplate,
        complate: complate,
        overfulfil: overfulfil,
        partiallyCompletedTotalValue: partiallyCompletedTotalValue,
        autoComplateTotalValue: autoComplateTotalValue,
        complateTotalValue: complateTotalValue,
        overfulfilTotalValue: overfulfilTotalValue,
      );
    }

    if (habitDetailData == null) return result;

    var defVal = habitDetailData!.data.dailyGoal;
    for (var record in habitDetailData!.records) {
      var useVal = record.value;
      switch (record.status) {
        case HabitRecordStatus.unknown:
          break;
        case HabitRecordStatus.done:
          var status = HabitDailyRecordForm.getComplateStatus(
              record.value, habitDetailData!.data.dailyGoal);
          switch (status) {
            case HabitDailyComplateStatus.zero:
              if (habitDetailData!.data.isRecordAutoComplated(record.date)) {
                tryAddRecordToResult(record.date,
                    autoComplate: 1, autoComplateTotalValue: defVal);
              }
              break;
            case HabitDailyComplateStatus.ok:
              tryAddRecordToResult(record.date,
                  complate: 1, complateTotalValue: useVal);
              break;
            case HabitDailyComplateStatus.goodjob:
              tryAddRecordToResult(record.date,
                  overfulfil: 1, overfulfilTotalValue: useVal);
              break;
            case HabitDailyComplateStatus.tryhard:
              if (habitDetailData!.data.isRecordAutoComplated(record.date)) {
                tryAddRecordToResult(record.date,
                    autoComplate: 1, autoComplateTotalValue: defVal);
              } else {
                tryAddRecordToResult(record.date,
                    partiallyCompleted: 1,
                    partiallyCompletedTotalValue: useVal);
              }
              break;
          }
          break;
        case HabitRecordStatus.skip:
          if (habitDetailData!.data.isRecordAutoComplated(record.date)) {
            tryAddRecordToResult(record.date,
                autoComplate: 1, autoComplateTotalValue: defVal);
          }
          break;
      }
    }

    for (var autoDate in habitDetailData!.autoRecordsDate) {
      if (habitDetailData?.data.getRecordByDate(autoDate) != null) continue;

      tryAddRecordToResult(
          getProtoDateByFreqChartCombine(autoDate, freqChartCombine, firstday),
          autoComplate: 1,
          autoComplateTotalValue: defVal);
    }

    return result;
  }
}

mixin _HabitDetailScoreChartMixin {
  HabitDetailData? habitDetailData;
  final Map<HabitDate, num> habitScoreChangedDateColl = {};
  HabitDetailScoreChartCombine _scoreChartCombine =
      defaultHabitDetailScoreChartCombine;

  HabitDetailScoreChartCombine get scoreChartCombine => _scoreChartCombine;

  int get firstday;

  set scoreChartCombine(HabitDetailScoreChartCombine newCombine) {
    _scoreChartCombine = newCombine;
  }

  Map<HabitDate, HabitDetailScoreChartDate> getRecordScoreChartDatas() {
    Map<HabitDate, HabitDetailScoreChartDate> result = {};
    if (habitDetailData == null) return result;

    var crtDate = habitDetailData!.data.startDate;
    num crtScore = 0.0;
    var endedDate = HabitDate.now();
    while (crtDate <= endedDate) {
      HabitDetailScoreChartDate data;

      var key = getProtoDateByScoreChartCombine(
          crtDate, _scoreChartCombine, firstday);
      if (result.containsKey(key)) {
        data = result[key]!;
      } else {
        data = HabitDetailScoreChartDate();
        result[key] = data;
      }

      crtScore = habitScoreChangedDateColl[crtDate] ?? crtScore;
      data.addScore(crtScore);
      crtDate = crtDate.addDays(1);
    }
    return result;
  }
}

class HabitDetailViewModel extends ChangeNotifier
    with
        _HabitDetailHeatmapColorMixin,
        _HabitDetailFreqChartMixin,
        _HabitDetailScoreChartMixin,
        NotificationChannelDataMixin,
        DBOperationsMixin
    implements ProviderMounted, HabitSummaryDirtyMarkABC {
  // data
  HabitDetailData? _habitDetailData;
  // status
  bool _reloadDBToggleSwich = false;
  Future<HabitDetailLoadDataResult>? dataloadingFutureCache;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;

  HabitDetailViewModel();

  @override
  bool get mounted => _mounted;

  @override
  int get firstday => _firstday;

  void updateFirstday(int newFirstDay) {
    final day = standardizeFirstDay(newFirstDay);
    if (kDebugMode && newFirstDay != day) {
      throw UnknownWeekdayNumber(newFirstDay);
    }
    _firstday = day;
  }

  @override
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

  HabitColorType? get habitColorType => _habitDetailData?.data.colorType;

  HabitDailyGoal? get habitDailyGoal => _habitDetailData?.data.dailyGoal;

  int? get habitTargetDays => _habitDetailData?.data.targetDays;

  String? get habitDailyGoalUnit => _habitDetailData?.dailyGoalUint;

  int get habitRecordsTotalNum => _habitDetailData?.data.recordsNum ?? 0;

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

  HabitHeatmapCellStatus getHabitHeatmapCellStatus(HabitDate date) {
    var record = getHabitRecordData(date);
    return HabitHeatmapCellStatus(
      status: record?.status,
      value: record?.value,
      isAutoComplete: _habitDetailData?.data.isRecordAutoComplated(date),
    );
  }

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  set freqChartCombine(HabitDetailFreqChartCombine newCombine) {
    if (newCombine != _freqChartCombine) {
      super.freqChartCombine = newCombine;
      notifyListeners();
    }
  }

  @override
  set scoreChartCombine(HabitDetailScoreChartCombine newCombine) {
    if (newCombine != _freqChartCombine) {
      super.scoreChartCombine = newCombine;
      notifyListeners();
    }
  }

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
      ErrorLog.notify(
        "HabitDetailViewModel:: catch err when try regr reminder",
        error: e,
      );
    }
  }

  bool rockreloadDBToggleSwich() {
    _reloadDBToggleSwich = !_reloadDBToggleSwich;
    dataloadingFutureCache = null;
    notifyListeners();
    return _reloadDBToggleSwich;
  }

  void calcHabitInfo() {
    habitScoreChangedDateColl.clear();
    _habitDetailData?.data.reCalculateAutoComplateRecords(
      firstDay: firstday,
      onScoreChange: (fromDate, toDate, fromScore, toScore) {
        habitScoreChangedDateColl.addEntries(HabitScoreChangedProtoData(
          fromDate: fromDate,
          toDate: toDate,
          fromScore: fromScore,
          toScore: toScore,
        ).expandToDate());
      },
    );
    calcRecordsHeatmapColorMap();
  }

  Future<HabitDetailLoadDataResult> loadData(HabitUUID uuid,
      {bool listen = true, bool inFutureBuilder = false}) async {
    if (dataloadingFutureCache != null) {
      WarnLog.load("loadData:: data already loaded $uuid");
      return HabitDetailLoadDataResult.alreadyLoaded;
    }
    // debugPrint('------ loadData:: $listen $_isDataLoaded');
    var dataFutureOf = loadHabitDetailFromDB(uuid);
    var recordFutureOf = loadRecordDataFromDB(uuid);
    var cell = await dataFutureOf;
    var records = await recordFutureOf;
    if (cell == null) {
      WarnLog.load("loadData:: data load failed $uuid");
      return HabitDetailLoadDataResult.habitMissing;
    }
    _habitDetailData = HabitDetailData.fromDBQueryCell(cell);
    _habitDetailData!.data
        .initRecords(records.map((e) => HabitSummaryRecord.fromDBQueryCell(e)));

    calcHabitInfo();
    if (listen) {
      if (!inFutureBuilder) _reloadDBToggleSwich = !_reloadDBToggleSwich;
      notifyListeners();
    }
    return HabitDetailLoadDataResult.done;
  }

  Future<HabitSummaryRecord?> onTapToChangeRecordStatus(HabitRecordDate date,
      {bool listen = true}) async {
    if (_habitDetailData == null) return null;

    HabitSummaryRecord orgRecord;
    final HabitSummaryRecord? record;
    bool isNew;
    HabitSummaryData data = _habitDetailData!.data;

    if (data.containsRecordDate(date)) {
      orgRecord = data.getRecordByDate(date)!;
      isNew = false;
    } else {
      orgRecord = HabitSummaryRecord.generate(date);
      isNew = true;
    }

    // status changed: unknown -> (done(ok), done(zero), skip)
    // status changed(with valued): unknown -> (done(value), skip)
    var completeStatus =
        HabitDailyRecordForm(orgRecord.value, data.dailyGoal).complateStatus;
    bool valued = (completeStatus != HabitDailyComplateStatus.zero) &&
        (completeStatus != HabitDailyComplateStatus.ok);
    switch (orgRecord.status) {
      case HabitRecordStatus.unknown:
      case HabitRecordStatus.skip:
        record = orgRecord.copyWith(
            status: HabitRecordStatus.done,
            value: valued ? orgRecord.value : data.dailyGoal);
        break;
      case HabitRecordStatus.done:
        if (valued) {
          record = orgRecord.copyWith(status: HabitRecordStatus.skip);
        } else {
          if (completeStatus == HabitDailyComplateStatus.ok) {
            record = orgRecord.copyWith(value: 0.0);
          } else {
            record = orgRecord.copyWith(status: HabitRecordStatus.skip);
          }
        }
        break;
    }

    await saveHabitRecord(data.id, data.uuid, record, isNew: isNew);

    var result = data.addRecord(record, replaced: true);
    calcHabitInfo();
    DebugLog.setValue("onTapToChangeRecordStatus:: "
        "${data.id} $result score=${data.progress} isNew=$isNew "
        "$orgRecord -> $record");
    if (listen) notifyListeners();
    await bumpHatbitVersion(data);
    return record;
  }

  Future<HabitSummaryRecord?> onLongPressChangeReason(
      HabitRecordDate date, String newReason,
      {bool listen = true}) async {
    if (_habitDetailData == null) return null;

    final data = _habitDetailData!.data;

    final record = data.getRecordByDate(date);
    if (record == null) return null;

    await saveHabitRecord(data.id, data.uuid, record,
        isNew: false, withReason: newReason);

    if (listen) notifyListeners();
    return record;
  }

  Future<HabitSummaryRecord?> onLongPressChangeRecordValue(
      HabitRecordDate date, HabitDailyGoal newValue,
      {bool listen = true}) async {
    if (_habitDetailData == null) return null;

    HabitSummaryRecord orgRecord;
    final HabitSummaryRecord? record;
    bool isNew;

    final data = _habitDetailData!.data;

    if (data.containsRecordDate(date)) {
      orgRecord = data.getRecordByDate(date)!;
      isNew = false;
    } else {
      orgRecord = HabitSummaryRecord.generate(date);
      isNew = true;
    }

    newValue =
        math.max(math.min(newValue, maxHabitdailyGoal), minHabitDailyGoal);
    record =
        orgRecord.copyWith(value: newValue, status: HabitRecordStatus.done);

    await saveHabitRecord(data.id, data.uuid, record, isNew: isNew);

    var result = data.addRecord(record, replaced: true);
    calcHabitInfo();
    DebugLog.setValue("onChangeRecordValue:: "
        "${data.id} $result score=${data.progress} isNew=$isNew "
        "$orgRecord -> $record");
    if (listen) notifyListeners();
    await bumpHatbitVersion(data);
    return record;
  }

  String debugGetDataString() => _habitDetailData.toString();

  HabitDetailData? debugGetData() => _habitDetailData;
}
