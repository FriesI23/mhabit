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
import '../utils/habit_date.dart';
import 'utils.dart';

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

  HabitDate getCurrentChartLastDate(
          HabitDate? initDate, int limit) =>
      _reversedData
          ? freqChartHelper.getFirstDate(initDate ?? HabitDate.now(), offset,
              limit, firstday, chartCombine: chartCombine)
          : freqChartHelper.getLastDate(initDate ?? HabitDate.now(), offset,
              limit, firstday,
              chartCombine: chartCombine);

  HabitDate getCurrentChartFirstDate(HabitDate? initDate, int limit) =>
      _reversedData
          ? freqChartHelper.getLastDate(
              initDate ?? HabitDate.now(), offset, limit, firstday,
              chartCombine: chartCombine)
          : freqChartHelper.getFirstDate(
              initDate ?? HabitDate.now(), offset, limit, firstday,
              chartCombine: chartCombine);

  List<MapEntry<HabitDate, HabitDetailFreqChartData>>
      getCurrentOffsetChartData({
    HabitDate? initDate,
    HabitDate? firstDate,
    HabitDate? lastDate,
    int? limit,
  }) {
    assert(!(firstDate == null && limit == null));
    assert(!(lastDate == null && limit == null));

    initDate ??= HabitDate.now();
    firstDate ??= getCurrentChartFirstDate(initDate, limit!);
    lastDate ??= getCurrentChartLastDate(initDate, limit!);

    final existMap = Map.fromEntries(filterWithDateRange(
      firstDate: firstDate,
      lastDate: lastDate,
      data: _data.entries,
      reversed: _reversedData,
    ));
    return freqChartHelper
        .fetchDataByOffset(
          firstDate,
          lastDate,
          reversed: _reversedData,
          chartCombine: chartCombine,
          dataBuilder: (date) => existMap[date] ?? HabitDetailFreqChartData(),
        )
        .toList();
  }
}
