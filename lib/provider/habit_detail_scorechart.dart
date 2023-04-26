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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/utils.dart';
import '../model/habit_date.dart';
import '../model/habit_detail_chart.dart';

class HabitDetailScoreChartViewModel extends ChangeNotifier {
  late final UniqueKey _parentVersion;
  late final HabitDetailScoreChartCombine _chartCombine;
  late final SplayTreeMap<HabitDate, HabitDetailScoreChartDate> _data;
  late final bool _reversedData;
  bool _inited = false;
  AxisDirection? _cachedScrollDirection;
  // sync from settings
  int _firstday = defaultFirstDay;

  HabitDetailScoreChartViewModel();

  UniqueKey get parentVersion => _parentVersion;

  bool get isInited => _inited;

  HabitDetailScoreChartCombine get chartCombine => _chartCombine;

  int get offset => 0;

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
    required HabitDetailScoreChartCombine chartCombine,
    Iterable<MapEntry<HabitDate, HabitDetailScoreChartDate>>? iter,
    bool reversedData = true,
    int? firstday,
  }) {
    if (_inited) return;
    _parentVersion = parentVersion;
    _chartCombine = chartCombine;
    _data = SplayTreeMap(
        reversedData ? (a, b) => b.compareTo(a) : (a, b) => a.compareTo(b));
    if (iter != null) _data.addEntries(iter);
    _reversedData = reversedData;
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
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.monthly, firstday);
    return protoDate.copyWith(month: protoDate.month - offset * limit);
  }

  static HabitDate getChartFirstDateInMonthly(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.monthly, firstday);
    return protoDate.copyWith(
        month: protoDate.month - (offset + 1) * limit + 1);
  }

  static HabitDate getChartLastDateInYearly(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.yearly, firstday);
    return protoDate.copyWith(year: protoDate.year - offset * limit);
  }

  static HabitDate getChartFirstDateInYearly(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.yearly, firstday);
    return protoDate.copyWith(year: protoDate.year - (offset + 1) * limit + 1);
  }

  static HabitDate getChartLastDateInWeekly(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.weekly, firstday);
    return protoDate.subtractDays(offset * limit * 7);
  }

  static HabitDate getChartFirstDateInWeekly(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.weekly, firstday);
    return protoDate.subtractDays(((offset + 1) * limit + 1) * 7);
  }

  static HabitDate getChartLastDateInDaily(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.daily, firstday);
    return protoDate.subtractDays(offset * limit);
  }

  static HabitDate getChartFirstDateInDaily(
      HabitDate initDate, int offset, int limit, int firstday) {
    var protoDate = getProtoDateByScoreChartCombine(
        initDate, HabitDetailScoreChartCombine.daily, firstday);
    return protoDate.subtractDays((offset + 1) * limit + 1);
  }

  HabitDate getCurrentChartLastDate(HabitDate? initDate, int limit) {
    initDate ??= HabitDate.now();
    switch (chartCombine) {
      case HabitDetailScoreChartCombine.monthly:
        return _reversedData
            ? getChartFirstDateInMonthly(initDate, offset, limit, firstday)
            : getChartLastDateInMonthly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.yearly:
        return _reversedData
            ? getChartFirstDateInYearly(initDate, offset, limit, firstday)
            : getChartLastDateInYearly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.weekly:
        return _reversedData
            ? getChartFirstDateInWeekly(initDate, offset, limit, firstday)
            : getChartLastDateInWeekly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.daily:
        return _reversedData
            ? getChartFirstDateInDaily(initDate, offset, limit, firstday)
            : getChartLastDateInDaily(initDate, offset, limit, firstday);
    }
  }

  HabitDate getCurrentChartFirstDate(HabitDate? initDate, int limit) {
    initDate ??= HabitDate.now();
    switch (chartCombine) {
      case HabitDetailScoreChartCombine.monthly:
        return _reversedData
            ? getChartLastDateInMonthly(initDate, offset, limit, firstday)
            : getChartFirstDateInMonthly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.yearly:
        return _reversedData
            ? getChartLastDateInYearly(initDate, offset, limit, firstday)
            : getChartFirstDateInYearly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.weekly:
        return _reversedData
            ? getChartLastDateInWeekly(initDate, offset, limit, firstday)
            : getChartFirstDateInWeekly(initDate, offset, limit, firstday);
      case HabitDetailScoreChartCombine.daily:
        return _reversedData
            ? getChartLastDateInDaily(initDate, offset, limit, firstday)
            : getChartFirstDateInDaily(initDate, offset, limit, firstday);
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

  Iterable<MapEntry<HabitDate, HabitDetailScoreChartDate>>
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

  List<MapEntry<HabitDate, HabitDetailScoreChartDate>>
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

    var result = <MapEntry<HabitDate, HabitDetailScoreChartDate>>[];
    var currentDate = firstDate;
    while (_reversedData
        ? !lastDate.isAfter(currentDate)
        : !lastDate.isBefore(currentDate)) {
      if (existMap.containsKey(currentDate)) {
        result.add(MapEntry(currentDate, existMap[currentDate]!));
      } else {
        result.add(MapEntry(currentDate, HabitDetailScoreChartDate()));
      }

      switch (chartCombine) {
        case HabitDetailScoreChartCombine.monthly:
          currentDate = _reversedData
              ? currentDate.copyWith(month: currentDate.month - 1)
              : currentDate.copyWith(month: currentDate.month + 1);
          break;
        case HabitDetailScoreChartCombine.yearly:
          currentDate = _reversedData
              ? currentDate.copyWith(year: currentDate.year - 1)
              : currentDate.copyWith(year: currentDate.year + 1);
          break;
        case HabitDetailScoreChartCombine.weekly:
          currentDate = _reversedData
              ? currentDate.subtractDays(7)
              : currentDate.addDays(7);
          break;
        case HabitDetailScoreChartCombine.daily:
          currentDate = _reversedData
              ? currentDate.subtractDays(1)
              : currentDate.addDays(1);
          break;
      }
    }

    return result;
  }
}
