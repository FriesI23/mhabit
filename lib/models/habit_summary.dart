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

import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import '../annotations/json_annotations.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../storage/db/handlers/habit.dart';
import '../storage/db/handlers/record.dart';
import 'common.dart';
import 'habit_daily_record_form.dart';
import 'habit_date.dart';
import 'habit_display.dart';
import 'habit_form.dart';
import 'habit_freq.dart';
import 'habit_reminder.dart';
import 'habit_score.dart';

part 'habit_summary.g.dart';

enum HabitReocrdAddRepeatedBehaviour { failed, skipped, replaced }

abstract class HabitSortCache<T> {
  bool isSameItem(HabitSortCache? other);
  bool isSameContent(T? other);
}

@CopyWith(skipFields: true)
class HabitSummaryRecord {
  final HabitRecordUUID uuid;
  final HabitRecordDate date;
  final HabitRecordStatus status;
  final HabitDailyGoal value;

  const HabitSummaryRecord(
    this.uuid,
    this.date,
    this.status,
    this.value,
  );

  HabitSummaryRecord.fromDBQueryCell(RecordDBCell cell)
      : uuid = cell.uuid!,
        date = HabitRecordDate.fromEpochDay(cell.recordDate!),
        status = HabitRecordStatus.getFromDBCode(cell.recordType!)!,
        value = cell.recordValue!;

  HabitSummaryRecord.generate(
    this.date, {
    this.status = HabitRecordStatus.unknown,
    this.value = 0.0,
    required HabitUUID? parentUUID,
    HabitRecordUUID? uuid,
  }) : uuid = uuid ??
            genRecordUUID(
                parentUUID!, const EpochHabitDateConverter().toJson(date));

  @override
  String toString() {
    return "Rcd($date: $status $value)";
  }
}

mixin _HabitSummaryDataRecordsMixin {
  final Map<HabitRecordUUID, HabitSummaryRecord> _recordMap = {};
  final SplayTreeMap<HabitRecordDate, HabitSummaryRecord> _recordDateCacheMap =
      SplayTreeMap((a, b) => a.compareTo(b));

  void initRecords(Iterable<HabitSummaryRecord> records) {
    clearRecords();
    addAllRecords(records, behaviour: HabitReocrdAddRepeatedBehaviour.skipped);
  }

  int get recordsNum => _recordDateCacheMap.length;

  void clearRecords() {
    _recordMap.clear();
    _recordDateCacheMap.clear();
  }

  Iterable<HabitSummaryRecord> getAllRecord() =>
      _recordDateCacheMap.entries.map((e) => e.value);

  HabitSummaryRecord? removeRecordWithUUID(HabitRecordUUID uuid) {
    final result = _recordMap.remove(uuid);
    if (result != null) _recordDateCacheMap.remove(result.date);
    return result;
  }

  HabitSummaryRecord? removeRecordWithDate(HabitRecordDate date) {
    final result = _recordDateCacheMap.remove(date);
    if (result != null) _recordMap.remove(result.uuid);
    return result;
  }

  bool addRecord(HabitSummaryRecord record, {bool replaced = false}) {
    if ((_recordMap.containsKey(record.uuid) ||
            _recordDateCacheMap.containsKey(record.date)) &&
        !replaced) {
      return false;
    }
    removeRecordWithUUID(record.uuid);
    removeRecordWithDate(record.date);
    _recordMap[record.uuid] = record;
    _recordDateCacheMap[record.date] = record;
    return true;
  }

  bool addAllRecords(Iterable<HabitSummaryRecord> records,
      {HabitReocrdAddRepeatedBehaviour behaviour =
          HabitReocrdAddRepeatedBehaviour.failed}) {
    final tmpList = <HabitSummaryRecord>[];
    for (final r in records) {
      if (_recordMap.containsKey(r.uuid) ||
          _recordDateCacheMap.containsKey(r.date)) {
        if (behaviour == HabitReocrdAddRepeatedBehaviour.failed) {
          return false;
        } else if (behaviour == HabitReocrdAddRepeatedBehaviour.skipped) {
          continue;
        }
      }
      tmpList.add(r);
    }
    for (final r in tmpList) {
      addRecord(r, replaced: true);
    }
    return true;
  }

  HabitSummaryRecord? getRecordByUUID(HabitRecordUUID uuid) => _recordMap[uuid];

  HabitSummaryRecord? getRecordByDate(HabitRecordDate date) =>
      _recordDateCacheMap[date];

  bool containsRecordUUID(HabitRecordUUID uuid) => _recordMap.containsKey(uuid);

  bool containsRecordDate(HabitRecordDate date) =>
      _recordDateCacheMap.containsKey(date);
}

class HabitSummaryData with _HabitSummaryDataRecordsMixin, DirtyMarkMixin {
  final DBID id;
  final HabitUUID uuid;
  final HabitType type;
  String name;
  String desc;
  HabitColorType colorType;
  HabitDailyGoal dailyGoal;
  HabitDailyGoal? dailyGoalExtra;
  int targetDays;
  HabitFrequency frequency;
  HabitStartDate startDate;
  HabitStatus status;
  HabitReminder? reminder;
  String? reminderQuest;
  HabitSortPostion sortPostion;
  DateTime createTime;

  num _progress = 0.0;
  final SplayTreeSet<HabitRecordDate> _autoMarkedRecords =
      SplayTreeSet((a, b) => a.compareTo(b));

  HabitSummaryData({
    required this.id,
    required this.uuid,
    required this.type,
    required this.name,
    required this.desc,
    required this.colorType,
    required this.dailyGoal,
    this.dailyGoalExtra,
    required this.targetDays,
    required this.frequency,
    required this.startDate,
    required this.status,
    this.reminder,
    this.reminderQuest,
    required this.sortPostion,
    required this.createTime,
  });

  HabitSummaryData.fromDBQueryCell(HabitDBCell cell)
      : id = cell.id!,
        uuid = cell.uuid!,
        type = HabitType.getFromDBCode(cell.type!)!,
        name = cell.name!,
        desc = cell.desc ?? '',
        colorType = HabitColorType.getFromDBCode(cell.color!)!,
        dailyGoal = cell.dailyGoal!,
        dailyGoalExtra = cell.dailyGoalExtra,
        targetDays = cell.targetDays!,
        frequency = HabitFrequency.fromJson(
            {"type": cell.freqType, "args": jsonDecode(cell.freqCustom!)}),
        startDate = HabitStartDate.fromEpochDay(cell.startDate!),
        status = HabitStatus.getFromDBCode(cell.status!)!,
        reminder = cell.remindCustom != null
            ? HabitReminder.fromJson(jsonDecode(cell.remindCustom!))
            : null,
        reminderQuest = cell.remindQuestion,
        sortPostion = cell.sortPosition!,
        createTime =
            DateTime.fromMillisecondsSinceEpoch(cell.createT! * onSecondMS);

  num get progress => _progress.isFinite ? _progress : -1.0;

  bool get isComplated => _progress >= 100.0;

  bool get isArchived => status == HabitStatus.archived;

  bool get isActived => status == HabitStatus.activated;

  bool get isDeleted => status == HabitStatus.deleted;

  bool get isInProgress => isActived && !isComplated;

  Duration get duringFromStartDate => HabitDate.now().difference(startDate);

  HabitDailyGoal get habitOkValue {
    switch (type) {
      case HabitType.unknown:
      case HabitType.normal:
        return dailyGoal;
      case HabitType.negative:
        return dailyGoalExtra ?? dailyGoal;
    }
  }

  Iterable<HabitRecordDate> getAllAutoComplateRecordDate() =>
      _autoMarkedRecords;

  Set<HabitRecordDate> debugGetAutoMarkedRecordsCopy() {
    assert(kDebugMode);
    return {}..addAll(_autoMarkedRecords);
  }

  num debugCalcTotalScore({HabitRecordDate? endDate}) {
    assert(kDebugMode);
    num result = 0.0;
    final calculator = getCalculator();
    calculator.calculate(
      onTotalScoreCalculated: (score) {
        result = math.min(math.max(score, 0), 100);
      },
    );
    return result;
  }

  void reCalculateAutoComplateRecords({
    OnScoreChangeCallback? onScoreChange,
    required int firstDay,
  }) {
    _autoMarkedRecords.clear();
    if (!frequency.isDaily) {
      switch (frequency.type) {
        case HabitFrequencyType.weekly:
          _autoMarkedRecords
              .addAll(_calculateAutoComplateRecordsWeekly(firstDay));
          break;
        case HabitFrequencyType.monthly:
          _autoMarkedRecords.addAll(_calculateAutoComplateRecordsMonthly());
          break;
        case HabitFrequencyType.custom:
          _autoMarkedRecords.addAll(_calculateAutoComplateRecordsCustom());
          break;
        default:
          break;
      }
    }

    final calculator = getCalculator();
    calculator.calculate(
      onTotalScoreCalculated: (score) {
        _progress = math.min(math.max(score, 0), 100);
      },
      onScoreChanged: onScoreChange,
    );

    // debugPrint('debug: last untrack date: ${getFirstUnTrackedDate()}');
  }

  HabitScoreCalculator getCalculator() {
    HabitScore createHabitScore() => HabitScore.getImp(
          type: type,
          targetDays: targetDays,
          dailyGoal: dailyGoal,
          dailGoalExtra: dailyGoalExtra,
        );

    Iterable<HabitDate> createIterable() => combineIterables(
          _autoMarkedRecords,
          _recordDateCacheMap.keys,
          compare: (a, b) => a.compareTo(b),
        );

    if (isArchived) {
      return ArchivedHabitScoreCalculator(
        habitScore: createHabitScore(),
        startDate: startDate,
        iterable: createIterable(),
        isAutoComplated: _autoMarkedRecords.contains,
        getHabitRecord: (date) => _recordDateCacheMap[date],
      );
    } else {
      return HabitScoreCalculator(
        habitScore: createHabitScore(),
        startDate: startDate,
        iterable: createIterable(),
        isAutoComplated: _autoMarkedRecords.contains,
        getHabitRecord: (date) => _recordDateCacheMap[date],
      );
    }
  }

  Iterable<HabitRecordDate> _calculateAutoComplateRecordsCustom() {
    assert(frequency.type == HabitFrequencyType.custom);

    final markedDateSet = <HabitRecordDate>{};
    final window = Queue<HabitRecordDate>();
    final dateNow = HabitDate.now();

    HabitRecordDate crtDate;
    HabitSummaryRecord crtRecord;

    if (_recordDateCacheMap.isEmpty) return markedDateSet;

    for (var element in _recordDateCacheMap.entries) {
      crtDate = element.key;
      crtRecord = element.value;

      if (crtDate > dateNow) break;

      final completeStatus = HabitDailyRecordForm.getImp(
        type: type,
        value: crtRecord.value,
        targetValue: dailyGoal,
        extraTargetValue: dailyGoalExtra,
      ).complateStatus;
      // debugPrint("----------------- $crtRecord  $completeStatus");
      if (crtRecord.status != HabitRecordStatus.done ||
          !(completeStatus == HabitDailyComplateStatus.goodjob ||
              completeStatus == HabitDailyComplateStatus.ok)) {
        continue;
      }

      window.add(crtDate);
      // debugPrint("window: $window");
      if (window.length < frequency.freq) continue;

      final insideDays = window.last.epochDay - window.first.epochDay + 1;
      if (insideDays > frequency.days) {
        window.removeFirst();
        continue;
      }

      for (var i = 0; i < insideDays; i++) {
        final insideMarkDate = window.first.addDays(i);
        // debugPrint("inside add [$insideDays]: $insideMarkDate");
        markedDateSet.add(insideMarkDate);
      }

      int lastDays = frequency.days - insideDays;

      final leftLastDays = lastDays;
      for (var i = 1; i <= leftLastDays; i++) {
        final leftMarkDate = window.first.subtractDays(i);
        if (markedDateSet.contains(leftMarkDate) || leftMarkDate < startDate) {
          break;
        }
        // debugPrint("left add [$lastDays]: $leftMarkDate");
        markedDateSet.add(leftMarkDate);
        lastDays -= 1;
      }

      for (var i = 1; i <= lastDays; i++) {
        final rightMarkDate = window.last.addDays(i);
        // debugPrint("right add[$lastDays]: $rightMarkDate");
        // calculate full automarks
        // if (rightMarkDate > dateNow) break;
        markedDateSet.add(rightMarkDate);
      }
      window.removeFirst();
    }

    // debugPrint("result: ${markedDateSet.sorted((a, b) => a.compareTo(b))}");
    return markedDateSet;
  }

  Iterable<HabitRecordDate> _calculateAutoComplateRecordsWeekly(
      int firstDay) sync* {
    assert(frequency.type == HabitFrequencyType.weekly);

    final yearWeekRecordMap = <HabitRecordDate, int>{};
    final dateNow = HabitDate.now();

    for (var e in _recordDateCacheMap.entries) {
      final crtDate = e.key;
      final crtRecord = e.value;

      if (crtDate > dateNow) break;

      final completeStatus = HabitDailyRecordForm.getImp(
        type: type,
        value: crtRecord.value,
        targetValue: dailyGoal,
        extraTargetValue: dailyGoalExtra,
      ).complateStatus;

      if (crtRecord.status != HabitRecordStatus.done ||
          !(completeStatus == HabitDailyComplateStatus.goodjob ||
              completeStatus == HabitDailyComplateStatus.ok)) {
        continue;
      }

      yearWeekRecordMap.update(
        crtDate.getFirstDayOfWeekWithStartDay(firstDay),
        (value) => ++value,
        ifAbsent: () => 1,
      );
    }

    HabitDate crtFirstDate;
    int crtCount;
    for (var e in yearWeekRecordMap.entries) {
      crtFirstDate = e.key;
      crtCount = e.value;
      if (crtCount < frequency.freq) continue;
      for (var i = DateTime.daysPerWeek - 1; i >= 0; i--) {
        final result = crtFirstDate.add(Duration(days: i));
        // calculate full automarks
        // if (result > dateNow) continue;
        if (result < startDate) break;
        yield result;
      }
    }
  }

  Iterable<HabitRecordDate> _calculateAutoComplateRecordsMonthly() sync* {
    assert(frequency.type == HabitFrequencyType.monthly);

    final yearMonthRecordMap = <HabitRecordDate, int>{};
    final dateNow = HabitDate.now();

    for (var e in _recordDateCacheMap.entries) {
      final crtDate = e.key;
      final crtRecord = e.value;

      if (crtDate > dateNow) break;

      final completeStatus = HabitDailyRecordForm.getImp(
        type: type,
        value: crtRecord.value,
        targetValue: dailyGoal,
        extraTargetValue: dailyGoalExtra,
      ).complateStatus;
      if (crtRecord.status != HabitRecordStatus.done ||
          !(completeStatus == HabitDailyComplateStatus.goodjob ||
              completeStatus == HabitDailyComplateStatus.ok)) {
        continue;
      }

      yearMonthRecordMap.update(
        crtDate.lastDayOfMonth,
        (value) => ++value,
        ifAbsent: () => 1,
      );
    }

    HabitDate crtLastDate;
    int crtCount;
    for (var e in yearMonthRecordMap.entries) {
      crtLastDate = e.key;
      crtCount = e.value;
      if (crtCount < frequency.freq) continue;
      for (var i = 0; i < crtLastDate.day; i++) {
        final result = crtLastDate.subtract(Duration(days: i));
        // calculate full automarks
        // if (result > dateNow) continue;
        if (result < startDate) break;
        yield result;
      }
    }
  }

  bool isRecordAutoComplated(HabitRecordDate date) =>
      _autoMarkedRecords.contains(date);

  HabitDate getFirstUnTrackedDate() {
    final lastAutoMarkDate = _autoMarkedRecords.lastOrNull;
    final lastRecordDate = _recordDateCacheMap.lastKey();
    final now = HabitDate.now().subtract(const Duration(days: 1));

    return (lastAutoMarkDate != null &&
                lastAutoMarkDate.isAfter(lastRecordDate ?? now)
            ? lastAutoMarkDate
            : lastRecordDate ?? now)
        .add(const Duration(days: 1));
  }

  @override
  String toString() {
    String getRecordsString() {
      final iterable = getAllRecord();
      return iterable.length > 10
          ? [
              ...iterable.take(5),
              '... [ignore ${iterable.length - 10} records] ...',
              ...iterable.skip(iterable.length - 5)
            ].join("|")
          : iterable.join("|");
    }

    return "HabitAboutData(id=$id,uuid=$uuid,type=${type.dbCode},name=$name,"
        "color=$colorType,dailyGoal=$dailyGoal,freq=$frequency,"
        "startDate=$startDate,status=$status,sort=$sortPostion,score=$progress,"
        "version=$diryMark,records={${getRecordsString()}})";
  }
}

class HabitSummaryDataCollection {
  final Map<HabitUUID, HabitSummaryData> _dataMap = {};

  HabitSummaryDataCollection();

  HabitSummaryDataCollection.fromDBQueryResult(
      Iterable<HabitDBCell> result, Iterable<RecordDBCell> recordResult) {
    initDataFromDBQueuryResult(result, recordResult);
  }

  void initDataFromDBQueuryResult(
      Iterable<HabitDBCell> result, Iterable<RecordDBCell> recordResult) {
    _dataMap.clear();
    for (final cell in result) {
      final data = HabitSummaryData.fromDBQueryCell(cell);
      _dataMap[data.uuid] = data;
    }
    for (final cell in recordResult) {
      final habitCell = getHabitByUUID(cell.parentUUID!);
      if (habitCell == null) continue;
      // Memory optimization: Don't cache records before start date.
      // When the StartDate changes, it is necessary to reload the data from
      // database to ensure that the cache is complete.
      final record = HabitSummaryRecord.fromDBQueryCell(cell);
      if (record.date.isBefore(habitCell.startDate)) continue;
      habitCell.addRecord(record);
    }
  }

  int get length => _dataMap.length;

  Iterable<HabitUUID> get keys => _dataMap.keys;

  Iterable<HabitSummaryData> get values => _dataMap.values;

  Iterable<MapEntry<HabitUUID, HabitSummaryData>> get entries =>
      _dataMap.entries;

  void forEach(Function(HabitUUID k, HabitSummaryData v) action) {
    _dataMap.forEach(action);
  }

  bool containsHabitUUID(HabitUUID uuid) => _dataMap.containsKey(uuid);

  HabitSummaryData? getHabitByUUID(HabitUUID uuid) => _dataMap[uuid];

  bool addNewHabit(HabitSummaryData cell, {bool forceAdd = false}) {
    if (_dataMap.containsKey(cell.uuid) && !forceAdd) {
      return false;
    }
    _dataMap[cell.uuid] = cell;
    return true;
  }

  HabitSummaryData? removeHabitByUUID(HabitUUID uuid) => _dataMap.remove(uuid);

  //#region: sort
  List<HabitSummaryData> _sortDataBy(HabitDisplaySortDirection sortDirecton,
      int Function(HabitSummaryData a, HabitSummaryData b) compareble) {
    final List<HabitSummaryData> result;
    switch (sortDirecton) {
      case HabitDisplaySortDirection.asc:
        result = List.from(_dataMap.values.toList()..sort(compareble));
        break;
      case HabitDisplaySortDirection.desc:
        result = List.from(
            _dataMap.values.toList()..sort((a, b) => compareble(b, a)));
        break;
    }
    return result;
  }

  List<HabitSummaryData> sortDataByName(
      HabitDisplaySortDirection sortDirecton) {
    int compareble(HabitSummaryData a, HabitSummaryData b) {
      final r1 = a.name.compareTo(b.name);
      if (r1 != 0) {
        return r1;
      } else {
        return b.startDate.compareTo(a.startDate);
      }
    }

    return _sortDataBy(sortDirecton, compareble);
  }

  List<HabitSummaryData> sortDataByColorType(
      HabitDisplaySortDirection sortDirecton) {
    int compareble(HabitSummaryData a, HabitSummaryData b) {
      final r1 = a.colorType.dbCode.compareTo(b.colorType.dbCode);
      if (r1 != 0) {
        return r1;
      } else {
        return b.startDate.compareTo(a.startDate);
      }
    }

    return _sortDataBy(sortDirecton, compareble);
  }

  List<HabitSummaryData> sortDataByProgress(
      HabitDisplaySortDirection sortDirecton) {
    int compareble(HabitSummaryData a, HabitSummaryData b) {
      final r1 = b.progress.compareTo(a.progress);
      if (r1 != 0) {
        return r1;
      } else {
        return b.startDate.compareTo(a.startDate);
      }
    }

    return _sortDataBy(sortDirecton, compareble);
  }

  List<HabitSummaryData> sortDataByStartT(
      HabitDisplaySortDirection sortDirecton) {
    int compareble(HabitSummaryData a, HabitSummaryData b) {
      return a.startDate.compareTo(b.startDate);
    }

    return _sortDataBy(sortDirecton, compareble);
  }

  List<HabitSummaryData> sortDataBySatus(
      HabitDisplaySortDirection sortDirecton) {
    int statusCoparable(HabitSummaryData a, HabitSummaryData b) {
      if (a.status == HabitStatus.activated &&
          b.status != HabitStatus.activated) {
        return -1;
      } else if (a.status != HabitStatus.activated &&
          b.status == HabitStatus.activated) {
        return 1;
      } else {
        return 0;
      }
    }

    int compareble(HabitSummaryData a, HabitSummaryData b) {
      int result;
      result = statusCoparable(a, b);
      if (result != 0) return result;
      result = b.progress.compareTo(a.progress);
      if (result != 0) return result;
      return b.startDate.compareTo(a.startDate);
    }

    return _sortDataBy(sortDirecton, compareble);
  }

  List<HabitSummaryData> sortDataByManual() {
    final List<HabitSummaryData> result;
    result = List.from(
      _dataMap.values.toList()
        ..sort((a, b) {
          final r1 = a.sortPostion.compareTo(b.sortPostion);
          if (r1 != 0) {
            return r1;
          } else {
            return a.createTime.compareTo(b.createTime);
          }
        }),
    );
    return result;
  }

  List<HabitSummaryData> sort(
      HabitDisplaySortType sortType, HabitDisplaySortDirection sortDirection) {
    switch (sortType) {
      case HabitDisplaySortType.manual:
        return sortDataByManual();
      case HabitDisplaySortType.name:
        return sortDataByName(sortDirection);
      case HabitDisplaySortType.colorType:
        return sortDataByColorType(sortDirection);
      case HabitDisplaySortType.progress:
        return sortDataByProgress(sortDirection);
      case HabitDisplaySortType.startT:
        return sortDataByStartT(sortDirection);
      case HabitDisplaySortType.status:
        return sortDataBySatus(sortDirection);
    }
  }
  //#endregion

  @override
  String toString() {
    final List<String> dataStringList = [];
    _dataMap.forEach((key, value) {
      final valueStr = truncateString(value.toString(), 120, 100, 10);
      dataStringList.add("    $valueStr");
    });
    String dataString = dataStringList.join('\n');
    dataString = dataString.isEmpty ? "" : "\n$dataString\n  ";
    return """HabitAboutDataCollection(
  dataMap=${_dataMap.length} {$dataString}
)""";
  }
}

class HabitSummaryDataSortCache
    extends HabitSortCache<HabitSummaryDataSortCache> {
  final HabitUUID uuid;
  final WeakReference<HabitSummaryData> _data;

  HabitSummaryDataSortCache({required HabitSummaryData data})
      : uuid = data.uuid,
        _data = WeakReference(data);

  HabitSummaryData? get data => _data.target;

  @override
  bool isSameItem(HabitSortCache? other) {
    if (other == null || other is! HabitSummaryDataSortCache) {
      return false;
    } else {
      return uuid == other.uuid;
    }
  }

  @override
  bool isSameContent(HabitSummaryDataSortCache? other) {
    return other == null ? false : true;
  }

  @override
  String toString() {
    return "HabitSummaryDataSortCache(uuid=$uuid,weakrefData=$data)";
  }
}

class HabitSummaryStatusCache {
  final bool isAppbarPinned;
  final int reloadHashcode;
  final bool isClandarExpanded;
  final bool isInEditMode;
  final bool isInSearchMode;

  const HabitSummaryStatusCache({
    required this.isAppbarPinned,
    required this.reloadHashcode,
    required this.isClandarExpanded,
    required this.isInEditMode,
    required this.isInSearchMode,
  });

  @override
  String toString() {
    return "HabitSummaryStatusCache($isAppbarPinned|$reloadHashcode|"
        "$isClandarExpanded|$isInEditMode|$isInSearchMode)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitSummaryStatusCache &&
        isAppbarPinned == other.isAppbarPinned &&
        reloadHashcode == other.reloadHashcode &&
        isClandarExpanded == other.isClandarExpanded &&
        isInEditMode == other.isInEditMode &&
        isInSearchMode == other.isInSearchMode;
  }

  @override
  int get hashCode {
    return hashObjects([
      isAppbarPinned,
      reloadHashcode,
      isClandarExpanded,
      isInEditMode,
    ]);
  }
}
