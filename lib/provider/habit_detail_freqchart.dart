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
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/utils.dart';
import '../model/habit_date.dart';
import '../model/habit_detail_chart.dart';

class HabitDetailFreqChartViewModel extends ChangeNotifier {
  late final UniqueKey _parentVersion;
  late final HabitDetailFreqChartCombine _chartCombine;
  late final SplayTreeMap<HabitDate, HabitDetailFreqChartData> _data;
  late final bool _reversedData;
  late bool _isFreqChartExpanded;
  int _offset = 0;
  bool _inited = false;
  AxisDirection? _cachedScrollDirection;
  // sync from settings
  int _firstday = defaultFirstDay;

  HabitDetailFreqChartViewModel();

  UniqueKey get parentVersion => _parentVersion;

  bool get isInited => _inited;

  HabitDetailFreqChartCombine get chartCombine => _chartCombine;

  bool get isChartExpanded => _isFreqChartExpanded;

  set isChartExpanded(bool newStatus) {
    if (newStatus != _isFreqChartExpanded) {
      _isFreqChartExpanded = newStatus;
      notifyListeners();
    }
  }

  int get offset => _offset;

  set offset(int newOffset) {
    if (kDebugMode) assert(newOffset >= 0);
    if (newOffset != _offset) {
      _cachedScrollDirection =
          newOffset > _offset ? AxisDirection.right : AxisDirection.left;
      _offset = math.max(0, newOffset);
      notifyListeners();
    }
  }

  int get firstday => _firstday;

  void updateFirstday(int newFirstDay) {
    final day = standardizeFirstDay(newFirstDay);
    if (kDebugMode && newFirstDay != day) {
      throw UnknownWeekdayNumber(newFirstDay);
    }
    _firstday = day;
  }

  void initState({
    required UniqueKey parentVersion,
    required HabitDetailFreqChartCombine chartCombine,
    Iterable<MapEntry<HabitDate, HabitDetailFreqChartData>>? iter,
    bool reversedData = true,
    required bool isFreqChartExpanded,
    int? offset,
    int? firstday,
  }) {
    if (_inited) return;
    _parentVersion = parentVersion;
    _chartCombine = chartCombine;
    _data = SplayTreeMap(
        reversedData ? (a, b) => b.compareTo(a) : (a, b) => a.compareTo(b));
    if (iter != null) _data.addEntries(iter);
    _reversedData = reversedData;
    _isFreqChartExpanded = isFreqChartExpanded;
    if (offset != null && offset >= 0) _offset = offset;
    if (firstday != null) updateFirstday(firstday);
    _inited = true;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _data.clear();
  }

  AxisDirection? consumeCachedAnimateDirection() {
    var tmp = _cachedScrollDirection;
    _cachedScrollDirection = null;
    return tmp;
  }

  static HabitDate getChartLastDateInMonthly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.monthly, firstDay);
    return protoDate.copyWith(month: protoDate.month - offset * limit);
  }

  static HabitDate getChartFirstDateInMonthly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.monthly, firstDay);
    return protoDate.copyWith(
        month: protoDate.month - (offset + 1) * limit + 1);
  }

  static HabitDate getChartLastDateInYearly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.yearly, firstDay);
    return protoDate.copyWith(year: protoDate.year - offset * limit);
  }

  static HabitDate getChartFirstDateInYearly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.yearly, firstDay);
    return protoDate.copyWith(year: protoDate.year - (offset + 1) * limit + 1);
  }

  static HabitDate getChartLastDateInWeekly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.weekly, firstDay);
    return protoDate.subtractDays(offset * limit * 7);
  }

  static HabitDate getChartFirstDateInWeekly(
      HabitDate initDate, int offset, int limit, int firstDay) {
    var protoDate = getProtoDateByFreqChartCombine(
        initDate, HabitDetailFreqChartCombine.weekly, firstDay);
    return protoDate.subtractDays(((offset + 1) * limit - 1) * 7);
  }

  HabitDate getCurrentChartLastDate(HabitDate? initDate, int limit) {
    initDate ??= HabitDate.now();
    switch (chartCombine) {
      case HabitDetailFreqChartCombine.monthly:
        return _reversedData
            ? getChartFirstDateInMonthly(initDate, offset, limit, firstday)
            : getChartLastDateInMonthly(initDate, offset, limit, firstday);
      case HabitDetailFreqChartCombine.yearly:
        return _reversedData
            ? getChartFirstDateInYearly(initDate, offset, limit, firstday)
            : getChartLastDateInYearly(initDate, offset, limit, firstday);
      case HabitDetailFreqChartCombine.weekly:
        return _reversedData
            ? getChartFirstDateInWeekly(initDate, offset, limit, firstday)
            : getChartLastDateInWeekly(initDate, offset, limit, firstday);
    }
  }

  HabitDate getCurrentChartFirstDate(HabitDate? initDate, int limit) {
    initDate ??= HabitDate.now();
    switch (chartCombine) {
      case HabitDetailFreqChartCombine.monthly:
        return _reversedData
            ? getChartLastDateInMonthly(initDate, offset, limit, firstday)
            : getChartFirstDateInMonthly(initDate, offset, limit, firstday);
      case HabitDetailFreqChartCombine.yearly:
        return _reversedData
            ? getChartLastDateInYearly(initDate, offset, limit, firstday)
            : getChartFirstDateInYearly(initDate, offset, limit, firstday);
      case HabitDetailFreqChartCombine.weekly:
        return _reversedData
            ? getChartLastDateInWeekly(initDate, offset, limit, firstday)
            : getChartFirstDateInWeekly(initDate, offset, limit, firstday);
    }
  }

  bool isOutOfDataRange(
      HabitDate date, HabitDate firstDate, HabitDate lastDate) {
    if (_reversedData) {
      return date.isAfter(firstDate) || date.isBefore(lastDate);
    } else {
      return date.isBefore(firstDate) || date.isAfter(lastDate);
    }
  }

  Iterable<MapEntry<HabitDate, HabitDetailFreqChartData>>
      _getCurrentOffsetChartData({
    required HabitDate initDate,
    required HabitDate firstDate,
    required HabitDate lastDate,
  }) sync* {
    bool outRangeBreaked = false;
    for (var e in _data.entries) {
      var date = e.key;
      if (isOutOfDataRange(date, firstDate, lastDate)) {
        if (outRangeBreaked) {
          return;
        } else {
          continue;
        }
      } else {
        if (!outRangeBreaked) outRangeBreaked = true;
        yield e;
      }
    }
  }

  List<MapEntry<HabitDate, HabitDetailFreqChartData>>
      getCurrentOffsetChartData({
    HabitDate? initDate,
    HabitDate? firstDate,
    HabitDate? lastDate,
    int? limit,
  }) {
    initDate ??= HabitDate.now();
    firstDate ??= getCurrentChartFirstDate(initDate, limit!);
    lastDate ??= getCurrentChartLastDate(initDate, limit!);
    var existMap = Map.fromEntries(_getCurrentOffsetChartData(
      initDate: initDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ));

    var result = <MapEntry<HabitDate, HabitDetailFreqChartData>>[];
    var currentDate = firstDate;
    while (_reversedData
        ? !lastDate.isAfter(currentDate)
        : !lastDate.isBefore(currentDate)) {
      if (existMap.containsKey(currentDate)) {
        result.add(MapEntry(currentDate, existMap[currentDate]!));
      } else {
        result.add(MapEntry(currentDate, HabitDetailFreqChartData()));
      }

      switch (chartCombine) {
        case HabitDetailFreqChartCombine.monthly:
          currentDate = _reversedData
              ? currentDate.copyWith(month: currentDate.month - 1)
              : currentDate.copyWith(month: currentDate.month + 1);
          break;
        case HabitDetailFreqChartCombine.yearly:
          currentDate = _reversedData
              ? currentDate.copyWith(year: currentDate.year - 1)
              : currentDate.copyWith(year: currentDate.year + 1);
          break;
        case HabitDetailFreqChartCombine.weekly:
          currentDate = _reversedData
              ? currentDate.subtractDays(7)
              : currentDate.addDays(7);
          break;
      }
    }

    return result;
  }
}
