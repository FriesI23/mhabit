// Copyright 2024 Fries_I23
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

import '../../models/habit_date.dart';
import '../../models/habit_detail_chart.dart';
import '../../utils/habit_date.dart';

typedef HabitDetailChartHelperDateFetcherCb<T> =
    HabitDate Function(HabitDate initDate, int firstday);

typedef HabitDetailChartHelperDateBuilderCb<T> =
    HabitDate Function(HabitDateRangeCalculator calc, bool isLast);

typedef HabitDetailChartHelperDataOffsetCb =
    HabitDate Function(HabitDate date, bool reversed);

const HabitDetailChartHelper scoreChartHelp = HabitDetailScoreChartHelper();

const HabitDetailChartHelper freqChartHelper = HabitDetailFreqChartHelper();

abstract class HabitDetailChartHelper<T> {
  const HabitDetailChartHelper();

  Map<T, HabitDetailChartHelperDateFetcherCb<T>> get _fetchDateHandlers;
  Map<T, HabitDetailChartHelperDateBuilderCb<T>> get _buildDateHandlers;

  HabitDate _getDate(
    HabitDate initDate,
    int offset,
    int limit,
    int firstday, {
    required T chartCombine,
    required bool isLast,
  }) {
    assert(_fetchDateHandlers.containsKey(chartCombine));
    assert(_buildDateHandlers.containsKey(chartCombine));
    final protoDate = getProtoDate(initDate, firstday, chartCombine);
    return _buildDateHandlers[chartCombine]!(
      HabitDateRangeCalculator(date: protoDate, offset: offset, limit: limit),
      isLast,
    );
  }

  Map<T, HabitDetailChartHelperDataOffsetCb> get _dataOffsetHandlers;

  HabitDate getFirstDate(
    HabitDate initDate,
    int offset,
    int limit,
    int firstday, {
    required T chartCombine,
  }) => _getDate(
    initDate,
    offset,
    limit,
    firstday,
    chartCombine: chartCombine,
    isLast: false,
  );

  HabitDate getLastDate(
    HabitDate initDate,
    int offset,
    int limit,
    int firstday, {
    required T chartCombine,
  }) => _getDate(
    initDate,
    offset,
    limit,
    firstday,
    chartCombine: chartCombine,
    isLast: true,
  );

  HabitDate getProtoDate(HabitDate date, int firstDay, T combine) =>
      _fetchDateHandlers[combine]!.call(date, firstDay);

  Iterable<MapEntry<HabitDate, V>> fetchDataByOffset<V>(
    HabitDate firstDate,
    HabitDate lastDate, {
    required bool reversed,
    required T chartCombine,
    required V Function(HabitDate date) dataBuilder,
  }) sync* {
    HabitDate currentDate = firstDate;
    while (reversed
        ? !lastDate.isAfter(currentDate)
        : !lastDate.isBefore(currentDate)) {
      yield MapEntry(currentDate, dataBuilder(currentDate));
      currentDate = _dataOffsetHandlers[chartCombine]!(currentDate, reversed);
    }
  }
}

final class HabitDetailScoreChartHelper
    extends HabitDetailChartHelper<HabitDetailScoreChartCombine> {
  static final _fetchersMap =
      <HabitDetailScoreChartCombine, HabitDetailChartHelperDateFetcherCb>{
        HabitDetailScoreChartCombine.yearly: (date, firstday) =>
            date.copyWith(month: 1, day: 1),
        HabitDetailScoreChartCombine.monthly: (date, firstday) =>
            date.firstDayOfMonth,
        HabitDetailScoreChartCombine.weekly: (date, firstday) => date.subtract(
          Duration(days: date.weekDayWithStartDay(firstday) - 1),
        ),
        HabitDetailScoreChartCombine.daily: (date, firstday) => date,
      };

  static final _buildersMap =
      <HabitDetailScoreChartCombine, HabitDetailChartHelperDateBuilderCb>{
        HabitDetailScoreChartCombine.yearly: (calc, isLast) =>
            isLast ? calc.lastDateYearly() : calc.firstDateYearly(),
        HabitDetailScoreChartCombine.monthly: (calc, isLast) =>
            isLast ? calc.lastDateMonthly() : calc.firstDateMonthly(),
        HabitDetailScoreChartCombine.weekly: (calc, isLast) =>
            isLast ? calc.lastDateWeekly() : calc.firstDateWeekly(),
        HabitDetailScoreChartCombine.daily: (calc, isLast) =>
            isLast ? calc.lastDateDaily() : calc.firstDateDaily(),
      };

  static final _offsetsMap =
      <HabitDetailScoreChartCombine, HabitDetailChartHelperDataOffsetCb>{
        HabitDetailScoreChartCombine.yearly: (date, reversed) => reversed
            ? date.copyWith(year: date.year - 1)
            : date.copyWith(year: date.year + 1),
        HabitDetailScoreChartCombine.monthly: (date, reversed) => reversed
            ? date.copyWith(month: date.month - 1)
            : date.copyWith(month: date.month + 1),
        HabitDetailScoreChartCombine.weekly: (date, reversed) =>
            reversed ? date.subtractDays(7) : date.addDays(7),
        HabitDetailScoreChartCombine.daily: (date, reversed) =>
            reversed ? date.subtractDays(1) : date.addDays(1),
      };

  const HabitDetailScoreChartHelper();

  @override
  Map<HabitDetailScoreChartCombine, HabitDetailChartHelperDateFetcherCb>
  get _fetchDateHandlers => _fetchersMap;

  @override
  Map<HabitDetailScoreChartCombine, HabitDetailChartHelperDateBuilderCb>
  get _buildDateHandlers => _buildersMap;

  @override
  Map<HabitDetailScoreChartCombine, HabitDetailChartHelperDataOffsetCb>
  get _dataOffsetHandlers => _offsetsMap;
}

final class HabitDetailFreqChartHelper
    extends HabitDetailChartHelper<HabitDetailFreqChartCombine> {
  static final _fetchersMap =
      <HabitDetailFreqChartCombine, HabitDetailChartHelperDateFetcherCb>{
        HabitDetailFreqChartCombine.yearly: (date, firstday) =>
            date.copyWith(month: 1, day: 1),
        HabitDetailFreqChartCombine.monthly: (date, firstday) =>
            date.firstDayOfMonth,
        HabitDetailFreqChartCombine.weekly: (date, firstday) => date.subtract(
          Duration(days: date.weekDayWithStartDay(firstday) - 1),
        ),
      };

  static final _buildersMap =
      <HabitDetailFreqChartCombine, HabitDetailChartHelperDateBuilderCb>{
        HabitDetailFreqChartCombine.yearly: (calc, isLast) =>
            isLast ? calc.lastDateYearly() : calc.firstDateYearly(),
        HabitDetailFreqChartCombine.monthly: (calc, isLast) =>
            isLast ? calc.lastDateMonthly() : calc.firstDateMonthly(),
        HabitDetailFreqChartCombine.weekly: (calc, isLast) =>
            isLast ? calc.lastDateWeekly() : calc.firstDateWeekly(),
      };

  static final _offsetsMap =
      <HabitDetailFreqChartCombine, HabitDetailChartHelperDataOffsetCb>{
        HabitDetailFreqChartCombine.yearly: (date, reversed) => reversed
            ? date.copyWith(year: date.year - 1)
            : date.copyWith(year: date.year + 1),
        HabitDetailFreqChartCombine.monthly: (date, reversed) => reversed
            ? date.copyWith(month: date.month - 1)
            : date.copyWith(month: date.month + 1),
        HabitDetailFreqChartCombine.weekly: (date, reversed) =>
            reversed ? date.subtractDays(7) : date.addDays(7),
      };

  const HabitDetailFreqChartHelper();

  @override
  Map<HabitDetailFreqChartCombine, HabitDetailChartHelperDateFetcherCb>
  get _fetchDateHandlers => _fetchersMap;

  @override
  Map<HabitDetailFreqChartCombine, HabitDetailChartHelperDateBuilderCb>
  get _buildDateHandlers => _buildersMap;

  @override
  Map<HabitDetailFreqChartCombine, HabitDetailChartHelperDataOffsetCb>
  get _dataOffsetHandlers => _offsetsMap;
}
