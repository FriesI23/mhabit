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
import 'habit_color.dart';
import 'habit_daily_record_form.dart';
import 'habit_date.dart';
import 'habit_display.dart';
import 'habit_form.dart';
import 'habit_freq.dart';
import 'habit_group.dart';
import 'habit_reminder.dart';
import 'habit_score.dart';

part 'habit_summary.g.dart';

enum HabitReocrdAddRepeatedBehaviour { failed, skipped, replaced }

sealed class HabitSortCache<T> {
  bool isSameItem(HabitSortCache? other);
  bool isSameContent(T? other);
}

@CopyWith(skipFields: true)
class HabitSummaryRecord {
  final HabitRecordUUID uuid;
  final HabitRecordDate date;
  final HabitRecordStatus status;
  final HabitDailyGoal value;

  const HabitSummaryRecord(this.uuid, this.date, this.status, this.value);

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
  }) : uuid =
           uuid ??
           genRecordUUID(
             parentUUID!,
             const EpochHabitDateConverter().toJson(date),
           );

  @override
  String toString() {
    return "Rcd($date: $status $value)";
  }
}

final class _HabitSummaryRecordIndex {
  final Map<HabitRecordUUID, HabitSummaryRecord> _recordMap = {};
  final SplayTreeMap<HabitRecordDate, HabitSummaryRecord> _recordDateCacheMap =
      SplayTreeMap((a, b) => a.compareTo(b));

  void initRecords(Iterable<HabitSummaryRecord> records) {
    clearRecords();
    addAll(records, behaviour: HabitReocrdAddRepeatedBehaviour.skipped);
  }

  int get length => _recordDateCacheMap.length;

  bool get isEmpty => _recordDateCacheMap.isEmpty;

  Iterable<HabitSummaryRecord> get records => _recordDateCacheMap.values;

  Iterable<MapEntry<HabitRecordDate, HabitSummaryRecord>> get datedEntries =>
      _recordDateCacheMap.entries;

  Iterable<HabitRecordDate> get dates => _recordDateCacheMap.keys;

  HabitRecordDate? get lastDate => _recordDateCacheMap.lastKey();

  void clearRecords() {
    _recordMap.clear();
    _recordDateCacheMap.clear();
  }

  HabitSummaryRecord? removeByUUID(HabitRecordUUID uuid) {
    final result = _recordMap.remove(uuid);
    if (result != null) _recordDateCacheMap.remove(result.date);
    return result;
  }

  HabitSummaryRecord? removeByDate(HabitRecordDate date) {
    final result = _recordDateCacheMap.remove(date);
    if (result != null) _recordMap.remove(result.uuid);
    return result;
  }

  bool add(HabitSummaryRecord record, {bool replaced = false}) {
    if ((_recordMap.containsKey(record.uuid) ||
            _recordDateCacheMap.containsKey(record.date)) &&
        !replaced) {
      return false;
    }
    removeByUUID(record.uuid);
    removeByDate(record.date);
    _recordMap[record.uuid] = record;
    _recordDateCacheMap[record.date] = record;
    return true;
  }

  bool addAll(
    Iterable<HabitSummaryRecord> records, {
    HabitReocrdAddRepeatedBehaviour behaviour =
        HabitReocrdAddRepeatedBehaviour.failed,
  }) {
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
      add(r, replaced: true);
    }
    return true;
  }

  HabitSummaryRecord? getByUUID(HabitRecordUUID uuid) => _recordMap[uuid];

  HabitSummaryRecord? getByDate(HabitRecordDate date) =>
      _recordDateCacheMap[date];

  bool containsUUID(HabitRecordUUID uuid) => _recordMap.containsKey(uuid);

  bool containsDate(HabitRecordDate date) =>
      _recordDateCacheMap.containsKey(date);
}

class _HabitSummaryAutoComplateCalculator {
  final HabitType type;
  final HabitDailyGoal dailyGoal;
  final HabitDailyGoal? dailyGoalExtra;
  final HabitFrequency frequency;
  final HabitStartDate startDate;
  final Iterable<MapEntry<HabitRecordDate, HabitSummaryRecord>> records;

  const _HabitSummaryAutoComplateCalculator({
    required this.type,
    required this.dailyGoal,
    required this.dailyGoalExtra,
    required this.frequency,
    required this.startDate,
    required this.records,
  });

  Iterable<HabitRecordDate> calculate({
    required int firstDay,
    required HabitDate dateNow,
  }) {
    if (frequency.isDaily) return const <HabitRecordDate>[];

    switch (frequency.type) {
      case HabitFrequencyType.weekly:
        return _calculateWeekly(firstDay, dateNow);
      case HabitFrequencyType.monthly:
        return _calculateMonthly(dateNow);
      case HabitFrequencyType.custom:
        return _calculateCustom(dateNow);
      case HabitFrequencyType.unknown:
        return const <HabitRecordDate>[];
    }
  }

  Iterable<HabitRecordDate> _calculateCustom(HabitDate dateNow) {
    final markedDateSet = <HabitRecordDate>{};
    final window = Queue<HabitRecordDate>();

    if (records.isEmpty) return markedDateSet;

    for (final element in records) {
      final crtDate = element.key;
      final crtRecord = element.value;

      if (crtDate > dateNow) break;
      if (!_isQualifiedRecord(crtRecord)) continue;

      window.add(crtDate);
      if (window.length < frequency.freq) continue;

      final insideDays = window.last.epochDay - window.first.epochDay + 1;
      if (insideDays > frequency.days) {
        window.removeFirst();
        continue;
      }

      for (var i = 0; i < insideDays; i++) {
        markedDateSet.add(window.first.addDays(i));
      }

      var lastDays = frequency.days - insideDays;
      final leftLastDays = lastDays;
      for (var i = 1; i <= leftLastDays; i++) {
        final leftMarkDate = window.first.subtractDays(i);
        if (markedDateSet.contains(leftMarkDate) || leftMarkDate < startDate) {
          break;
        }
        markedDateSet.add(leftMarkDate);
        lastDays -= 1;
      }

      for (var i = 1; i <= lastDays; i++) {
        markedDateSet.add(window.last.addDays(i));
      }
      window.removeFirst();
    }

    return markedDateSet;
  }

  Iterable<HabitRecordDate> _calculateWeekly(
    int firstDay,
    HabitDate dateNow,
  ) sync* {
    final yearWeekRecordMap = <HabitRecordDate, int>{};

    for (final entry in records) {
      final crtDate = entry.key;
      final crtRecord = entry.value;

      if (crtDate > dateNow) break;
      if (!_isQualifiedRecord(crtRecord)) continue;

      yearWeekRecordMap.update(
        crtDate.getFirstDayOfWeekWithStartDay(firstDay),
        (value) => ++value,
        ifAbsent: () => 1,
      );
    }

    for (final entry in yearWeekRecordMap.entries) {
      final crtFirstDate = entry.key;
      final crtCount = entry.value;
      if (crtCount < frequency.freq) continue;
      for (var i = DateTime.daysPerWeek - 1; i >= 0; i--) {
        final result = crtFirstDate.add(Duration(days: i));
        if (result < startDate) break;
        yield result;
      }
    }
  }

  Iterable<HabitRecordDate> _calculateMonthly(HabitDate dateNow) sync* {
    final yearMonthRecordMap = <HabitRecordDate, int>{};

    for (final entry in records) {
      final crtDate = entry.key;
      final crtRecord = entry.value;

      if (crtDate > dateNow) break;
      if (!_isQualifiedRecord(crtRecord)) continue;

      yearMonthRecordMap.update(
        crtDate.lastDayOfMonth,
        (value) => ++value,
        ifAbsent: () => 1,
      );
    }

    for (final entry in yearMonthRecordMap.entries) {
      final crtLastDate = entry.key;
      final crtCount = entry.value;
      if (crtCount < frequency.freq) continue;
      for (var i = 0; i < crtLastDate.day; i++) {
        final result = crtLastDate.subtract(Duration(days: i));
        if (result < startDate) break;
        yield result;
      }
    }
  }

  bool _isQualifiedRecord(HabitSummaryRecord record) {
    final completeStatus = HabitDailyRecordForm.getImp(
      type: type,
      value: record.value,
      targetValue: dailyGoal,
      extraTargetValue: dailyGoalExtra,
    ).complateStatus;
    return record.status == HabitRecordStatus.done &&
        (completeStatus == HabitDailyComplateStatus.goodjob ||
            completeStatus == HabitDailyComplateStatus.ok);
  }
}

class HabitSummaryData with DirtyMarkMixin {
  final DBID id;
  final HabitUUID uuid;
  final HabitType type;
  String name;
  String desc;

  /// The only color property on this model. There is no separate
  /// `colorType`/`customColor` pair here: those are raw persistence fields
  /// owned by `HabitDBCell`, and only [HabitColor.fromRaw]/the
  /// `dbColorType`/`dbCustomColor` getters are allowed to unpack [color]
  /// back into that shape, at the DB conversion boundary.
  HabitColor color;
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
  String? groupId;

  final _records = _HabitSummaryRecordIndex();
  num _progress = 0.0;
  final SplayTreeSet<HabitRecordDate> _autoMarkedRecords = SplayTreeSet(
    (a, b) => a.compareTo(b),
  );

  void initRecords(Iterable<HabitSummaryRecord> records) =>
      _records.initRecords(records);

  int get recordCount => _records.length;

  void clearRecords() => _records.clearRecords();

  Iterable<HabitSummaryRecord> get records => _records.records;

  HabitSummaryRecord? removeRecordByUUID(HabitRecordUUID uuid) =>
      _records.removeByUUID(uuid);

  HabitSummaryRecord? removeRecordByDate(HabitRecordDate date) =>
      _records.removeByDate(date);

  bool addRecord(HabitSummaryRecord record, {bool replaced = false}) =>
      _records.add(record, replaced: replaced);

  bool addAllRecords(
    Iterable<HabitSummaryRecord> records, {
    HabitReocrdAddRepeatedBehaviour behaviour =
        HabitReocrdAddRepeatedBehaviour.failed,
  }) => _records.addAll(records, behaviour: behaviour);

  HabitSummaryRecord? getRecordByUUID(HabitRecordUUID uuid) =>
      _records.getByUUID(uuid);

  HabitSummaryRecord? getRecordByDate(HabitRecordDate date) =>
      _records.getByDate(date);

  bool containsRecordUUID(HabitRecordUUID uuid) => _records.containsUUID(uuid);

  bool containsRecordDate(HabitRecordDate date) => _records.containsDate(date);

  HabitSummaryData({
    required this.id,
    required this.uuid,
    required this.type,
    required this.name,
    required this.desc,
    required this.color,
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
    this.groupId,
  });

  HabitSummaryData.fromDBQueryCell(HabitDBCell cell)
    : id = cell.id!,
      uuid = cell.uuid!,
      type = HabitType.getFromDBCode(cell.type!)!,
      name = cell.name!,
      desc = cell.desc ?? '',
      color = HabitColor.fromRaw(
        colorType: HabitColorType.getFromDBCode(cell.color!)!,
        customColor: cell.customColor,
        customColorTinted: cell.customColorTinted,
      ),
      dailyGoal = cell.dailyGoal!,
      dailyGoalExtra = cell.dailyGoalExtra,
      targetDays = cell.targetDays!,
      frequency = HabitFrequency.fromJson({
        "type": cell.freqType,
        "args": jsonDecode(cell.freqCustom!),
      }),
      startDate = HabitStartDate.fromEpochDay(cell.startDate!),
      status = HabitStatus.getFromDBCode(cell.status!)!,
      reminder = cell.remindCustom != null
          ? HabitReminder.fromJson(jsonDecode(cell.remindCustom!))
          : null,
      reminderQuest = cell.remindQuestion,
      sortPostion = cell.sortPosition!,
      createTime = DateTime.fromMillisecondsSinceEpoch(
        cell.createT! * onSecondMS,
      ),
      groupId = cell.groupId;

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

  Iterable<HabitRecordDate> get autoCompletedDates => _autoMarkedRecords;

  Set<HabitRecordDate> debugGetAutoMarkedRecordsCopy() {
    assert(kDebugMode);
    return {}..addAll(_autoMarkedRecords);
  }

  num debugCalcTotalScore({HabitRecordDate? endDate}) {
    assert(kDebugMode);
    return _calculateTotalScore();
  }

  void reCalculateAutoComplateRecords({
    OnScoreChangeCallback? onScoreChange,
    required int firstDay,
  }) {
    _autoMarkedRecords
      ..clear()
      ..addAll(
        _HabitSummaryAutoComplateCalculator(
          type: type,
          dailyGoal: dailyGoal,
          dailyGoalExtra: dailyGoalExtra,
          frequency: frequency,
          startDate: startDate,
          records: _records.datedEntries,
        ).calculate(firstDay: firstDay, dateNow: HabitDate.now()),
      );

    _progress = _calculateTotalScore(onScoreChange: onScoreChange);

    // debugPrint('debug: last untrack date: $firstUntrackedDate');
  }

  HabitScoreCalculator getCalculator() => _createScoreCalculator();

  bool isRecordAutoComplated(HabitRecordDate date) =>
      _autoMarkedRecords.contains(date);

  HabitDate get firstUntrackedDate {
    final lastAutoMarkDate = _autoMarkedRecords.lastOrNull;
    final lastRecordDate = _records.lastDate;
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
      final iterable = records;
      return iterable.length > 10
          ? [
              ...iterable.take(5),
              '... [ignore ${iterable.length - 10} records] ...',
              ...iterable.skip(iterable.length - 5),
            ].join("|")
          : iterable.join("|");
    }

    return "HabitAboutData(id=$id,uuid=$uuid,type=${type.dbCode},name=$name,"
        "color=$color,dailyGoal=$dailyGoal,freq=$frequency,"
        "startDate=$startDate,status=$status,sort=$sortPostion,score=$progress,"
        "version=$diryMark,records={${getRecordsString()}})";
  }
}

class HabitSummaryDataCollection {
  final Map<HabitUUID, HabitSummaryData> _dataMap = {};

  HabitSummaryDataCollection();

  HabitSummaryDataCollection.fromDBQueryResult(
    Iterable<HabitDBCell> result,
    Iterable<RecordDBCell> recordResult,
  ) {
    loadFromDBQueryResult(result, recordResult);
  }

  void loadFromDBQueryResult(
    Iterable<HabitDBCell> result,
    Iterable<RecordDBCell> recordResult,
  ) => _loadFromDBQueryResult(result, recordResult);

  int get length => _dataMap.length;

  Iterable<HabitUUID> get keys => _dataMap.keys;

  Iterable<HabitSummaryData> get values => _dataMap.values;

  Iterable<MapEntry<HabitUUID, HabitSummaryData>> get entries =>
      _dataMap.entries;

  void forEach(Function(HabitUUID k, HabitSummaryData v) action) =>
      _dataMap.forEach(action);

  bool containsHabitUUID(HabitUUID uuid) => _dataMap.containsKey(uuid);

  HabitSummaryData? getHabitByUUID(HabitUUID uuid) => _dataMap[uuid];

  bool addHabit(HabitSummaryData cell, {bool forceAdd = false}) {
    if (_dataMap.containsKey(cell.uuid) && !forceAdd) {
      return false;
    }
    _dataMap[cell.uuid] = cell;
    return true;
  }

  HabitSummaryData? removeHabitByUUID(HabitUUID uuid) => _dataMap.remove(uuid);

  //#region: sort
  List<HabitSummaryData> sortByName(HabitDisplaySortDirection sortDirecton) =>
      _dataMap.values.sortByName(sortDirecton);

  List<HabitSummaryData> sortByColorType(
    HabitDisplaySortDirection sortDirecton,
  ) => _dataMap.values.sortByColorType(sortDirecton);

  List<HabitSummaryData> sortByProgress(
    HabitDisplaySortDirection sortDirecton,
  ) => _dataMap.values.sortByProgress(sortDirecton);

  List<HabitSummaryData> sortByStartDate(
    HabitDisplaySortDirection sortDirecton,
  ) => _dataMap.values.sortByStartDate(sortDirecton);

  List<HabitSummaryData> sortByStatus(HabitDisplaySortDirection sortDirecton) =>
      _dataMap.values.sortByStatus(sortDirecton);

  List<HabitSummaryData> sortByManual() => _dataMap.values.sortByManual();

  List<HabitSummaryData> sort(
    HabitDisplaySortType sortType,
    HabitDisplaySortDirection sortDirection,
  ) => _dataMap.values.sortedBy(sortType, sortDirection);
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

extension on HabitSummaryData {
  HabitScoreCalculator _createScoreCalculator() {
    final habitScore = HabitScore.getImp(
      type: type,
      targetDays: targetDays,
      dailyGoal: dailyGoal,
      dailGoalExtra: dailyGoalExtra,
    );
    final iterable = combineIterables(
      _autoMarkedRecords,
      _records.dates,
      compare: (a, b) => a.compareTo(b),
    );

    if (isArchived) {
      return ArchivedHabitScoreCalculator(
        habitScore: habitScore,
        startDate: startDate,
        iterable: iterable,
        isAutoComplated: _autoMarkedRecords.contains,
        getHabitRecord: _records.getByDate,
      );
    }

    return HabitScoreCalculator(
      habitScore: habitScore,
      startDate: startDate,
      iterable: iterable,
      isAutoComplated: _autoMarkedRecords.contains,
      getHabitRecord: _records.getByDate,
    );
  }

  num _calculateTotalScore({OnScoreChangeCallback? onScoreChange}) {
    num result = 0.0;
    _createScoreCalculator().calculate(
      onTotalScoreCalculated: (score) {
        result = math.min(math.max(score, 0), 100);
      },
      onScoreChanged: onScoreChange,
    );
    return result;
  }
}

extension on HabitSummaryDataCollection {
  void _loadFromDBQueryResult(
    Iterable<HabitDBCell> result,
    Iterable<RecordDBCell> recordResult,
  ) {
    _dataMap.clear();

    for (final cell in result) {
      final data = HabitSummaryData.fromDBQueryCell(cell);
      _dataMap[data.uuid] = data;
    }

    for (final cell in recordResult) {
      final habitData = _dataMap[cell.parentUUID!];
      if (habitData == null) continue;

      final record = HabitSummaryRecord.fromDBQueryCell(cell);
      if (record.date.isBefore(habitData.startDate)) continue;

      // Memory optimization: Don't cache records before start date.
      // When the StartDate changes, it is necessary to reload the data from
      // database to ensure that the cache is complete.
      habitData.addRecord(record);
    }
  }
}

extension HabitSummarySortExtension on Iterable<HabitSummaryData> {
  List<HabitSummaryData> sortedBy(
    HabitDisplaySortType sortType,
    HabitDisplaySortDirection sortDirection,
  ) {
    switch (sortType) {
      case HabitDisplaySortType.manual:
        return sortByManual();
      case HabitDisplaySortType.name:
        return sortByName(sortDirection);
      case HabitDisplaySortType.colorType:
        return sortByColorType(sortDirection);
      case HabitDisplaySortType.progress:
        return sortByProgress(sortDirection);
      case HabitDisplaySortType.startT:
        return sortByStartDate(sortDirection);
      case HabitDisplaySortType.status:
        return sortByStatus(sortDirection);
    }
  }

  List<HabitSummaryData> sortByName(HabitDisplaySortDirection direction) =>
      _sort(direction, _compareByName);

  List<HabitSummaryData> sortByColorType(HabitDisplaySortDirection direction) =>
      _sort(direction, _compareByColorType);

  List<HabitSummaryData> sortByProgress(HabitDisplaySortDirection direction) =>
      _sort(direction, _compareByProgress);

  List<HabitSummaryData> sortByStartDate(HabitDisplaySortDirection direction) =>
      _sort(direction, _compareByStartDate);

  List<HabitSummaryData> sortByStatus(HabitDisplaySortDirection direction) =>
      _sort(direction, _compareByStatus);

  List<HabitSummaryData> sortByManual() {
    final result = toList();
    result.sort(_compareByManual);
    return result;
  }

  List<HabitSummaryData> _sort(
    HabitDisplaySortDirection direction,
    Comparator<HabitSummaryData> comparator,
  ) {
    final result = toList();
    switch (direction) {
      case HabitDisplaySortDirection.asc:
        result.sort(comparator);
        break;
      case HabitDisplaySortDirection.desc:
        result.sort((a, b) => comparator(b, a));
        break;
    }
    return result;
  }

  int _compareByName(HabitSummaryData a, HabitSummaryData b) =>
      _compareWithFallback(
        a,
        b,
        primaryResult: a.name.compareTo(b.name),
        fallbackComparator: _compareByDescendingStartDate,
      );

  int _compareByColorType(HabitSummaryData a, HabitSummaryData b) =>
      _compareWithFallback(
        a,
        b,
        primaryResult: a.color.compareTo(b.color),
        fallbackComparator: _compareByDescendingStartDate,
      );

  int _compareByProgress(HabitSummaryData a, HabitSummaryData b) =>
      _compareWithFallback(
        a,
        b,
        primaryResult: b.progress.compareTo(a.progress),
        fallbackComparator: _compareByDescendingStartDate,
      );

  int _compareByStartDate(HabitSummaryData a, HabitSummaryData b) =>
      a.startDate.compareTo(b.startDate);

  int _compareByStatus(HabitSummaryData a, HabitSummaryData b) =>
      _compareWithFallback(
        a,
        b,
        primaryResult: _compareActivatedStatus(a, b),
        fallbackComparator: _compareByProgress,
      );

  int _compareByManual(HabitSummaryData a, HabitSummaryData b) =>
      _compareWithFallback(
        a,
        b,
        primaryResult: a.sortPostion.compareTo(b.sortPostion),
        fallbackComparator: _compareByCreateTime,
      );

  int _compareByCreateTime(HabitSummaryData a, HabitSummaryData b) =>
      a.createTime.compareTo(b.createTime);

  int _compareActivatedStatus(HabitSummaryData a, HabitSummaryData b) {
    if (a.status == HabitStatus.activated &&
        b.status != HabitStatus.activated) {
      return -1;
    }
    if (a.status != HabitStatus.activated &&
        b.status == HabitStatus.activated) {
      return 1;
    }
    return 0;
  }

  int _compareWithFallback(
    HabitSummaryData a,
    HabitSummaryData b, {
    required int primaryResult,
    required Comparator<HabitSummaryData> fallbackComparator,
  }) {
    if (primaryResult != 0) return primaryResult;
    return fallbackComparator(a, b);
  }

  int _compareByDescendingStartDate(HabitSummaryData a, HabitSummaryData b) {
    return b.startDate.compareTo(a.startDate);
  }
}

/// Reassigns [HabitSummaryData.sortPostion] to match iteration order.
///
/// Collects all existing weights, sorts them, then assigns them in
/// ascending order following the iteration order of [this].  The
/// pre-existing [sortPostion] multiset is preserved; only the mapping
/// from values to positions changes.
///
/// Group-agnostic: this operates on a flat list of habits regardless of
/// group membership.  Both grouped and ungrouped reorder paths use the
/// same algorithm — the caller is responsible for providing the habits
/// in the desired flat order.
extension HabitSortReassignmentExtension on Iterable<HabitSummaryData> {
  void reassignSortPositions() {
    final list = toList();
    if (list.isEmpty) return;

    final weights = list.map((h) => h.sortPostion).toList()..sort();
    for (final (i, h) in list.indexed) {
      h.sortPostion = weights[i];
    }
  }
}

final class GroupHeaderSortCache extends HabitSortCache<GroupHeaderSortCache> {
  final String? groupUUID;
  final String name;
  final GroupIcon? icon;
  final HabitColor? color;
  int count;

  GroupHeaderSortCache({
    required this.groupUUID,
    required this.name,
    this.icon,
    this.color,
    this.count = 0,
  });

  bool get isUncategorized => groupUUID == null;

  @override
  bool isSameItem(HabitSortCache? other) {
    if (other == null || other is! GroupHeaderSortCache) return false;
    return groupUUID == other.groupUUID;
  }

  @override
  bool isSameContent(GroupHeaderSortCache? other) {
    if (other == null) return false;
    return name == other.name &&
        count == other.count &&
        icon == other.icon &&
        color == other.color;
  }
}

final class HabitSummaryDataSortCache
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
  final int? loadId;
  final bool isClandarExpanded;
  final bool isInEditMode;
  final bool isInSearchMode;

  const HabitSummaryStatusCache({
    required this.isAppbarPinned,
    required this.loadId,
    required this.isClandarExpanded,
    required this.isInEditMode,
    required this.isInSearchMode,
  });

  @override
  String toString() {
    return "HabitSummaryStatusCache($isAppbarPinned|$loadId|"
        "$isClandarExpanded|$isInEditMode|$isInSearchMode)";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitSummaryStatusCache &&
        isAppbarPinned == other.isAppbarPinned &&
        loadId == other.loadId &&
        isClandarExpanded == other.isClandarExpanded &&
        isInEditMode == other.isInEditMode &&
        isInSearchMode == other.isInSearchMode;
  }

  @override
  int get hashCode {
    return hashObjects([
      isAppbarPinned,
      loadId,
      isClandarExpanded,
      isInEditMode,
    ]);
  }
}
