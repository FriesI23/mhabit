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

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:quiver/core.dart';

import '../common/types.dart';
import 'habit_date.dart';
import 'habit_summary.dart';

part 'habit_stat.g.dart';

class HabitSummarySelectedStatistic {
  final int activated;
  final int archived;

  HabitSummarySelectedStatistic({this.activated = 0, this.archived = 0});

  int get selected => activated + archived;

  @override
  bool operator ==(Object other) {
    if (other is! HabitSummarySelectedStatistic) return false;
    return activated == other.activated && archived == other.archived;
  }

  @override
  int get hashCode => hash2(activated, archived);
}

@CopyWith(skipFields: true)
class HabitRangeDayStatistic {
  final HabitUUID uuid;
  final num startProgress;
  final HabitDate lastStartRecordData;
  final num enededProgress;
  final HabitDate lastEndedRecordDate;

  const HabitRangeDayStatistic({
    required this.uuid,
    required this.startProgress,
    required this.lastStartRecordData,
    required this.enededProgress,
    required this.lastEndedRecordDate,
  });

  num get changed => enededProgress - startProgress;

  num getLast30DaysChanged(HabitDate initDate) {
    final firstDate = initDate.subtractDays(30);
    if (firstDate <= lastStartRecordData) {
      return enededProgress - 0;
    } else {
      return changed;
    }
  }

  @override
  String toString() {
    return "HabitRangeDayStatisticsData($uuid|$changed| "
        "$startProgress $lastStartRecordData .. "
        "$enededProgress $lastEndedRecordDate)";
  }
}

class HabitLast30DaysProgressChangeData {
  final Map<HabitUUID, HabitRangeDayStatistic> _cacheData = {};
  final List<HabitRangeDayStatistic> _sortedCache = [];
  bool _dirty = true;

  Iterable<HabitRangeDayStatistic> get iterable {
    if (_dirty) genSortedCache(force: true);
    return _sortedCache;
  }

  void clearStatistic(HabitUUID uuid) {
    _dirty = true;
    _cacheData.remove(uuid);
  }

  HabitRangeDayStatistic? getStatistic(HabitUUID uuid) => _cacheData[uuid];

  void genSortedCache({bool force = false}) {
    if (!(_dirty || force)) return;
    _sortedCache.clear();
    _sortedCache.addAll(_cacheData.values.sorted((a, b) {
      int r;
      r = b.changed.compareTo(a.changed);
      if (r != 0) return r;
      r = b.lastEndedRecordDate.compareTo(a.lastEndedRecordDate);
      return r;
    }));
    _dirty = false;
  }

  void addStatistic(
      HabitSummaryData data, HabitDate initDate, HabitDate date, num score) {
    final firstDate = initDate.subtractDays(30);
    if (date < firstDate || date > initDate) return;
    _dirty = true;
    if (!_cacheData.containsKey(data.uuid)) {
      _cacheData[data.uuid] = HabitRangeDayStatistic(
        uuid: data.uuid,
        startProgress: score,
        lastStartRecordData: date,
        enededProgress: score,
        lastEndedRecordDate: date,
      );
      return;
    }

    final orgRecord = _cacheData[data.uuid]!;
    if (date < orgRecord.lastStartRecordData &&
        orgRecord.startProgress != score) {
      _cacheData[data.uuid] = _cacheData[data.uuid]!.copyWith(
        startProgress: score,
        lastStartRecordData: date,
      );
    } else if (date > orgRecord.lastEndedRecordDate &&
        orgRecord.enededProgress != score) {
      _cacheData[data.uuid] = _cacheData[data.uuid]!.copyWith(
        enededProgress: score,
        lastEndedRecordDate: date,
      );
    }
  }
}

@CopyWith()
class HabitSummaryStatisticsData {
  static const zero = HabitSummaryStatisticsData(
    currentArchivedCount: 0,
    currentComplatedCount: 0,
    currentInProgressCount: 0,
    currentPopularityData: [],
  );

  final int currentComplatedCount;
  final int currentInProgressCount;
  final int currentArchivedCount;
  final List<HabitRangeDayStatistic> currentPopularityData;

  const HabitSummaryStatisticsData({
    required this.currentComplatedCount,
    required this.currentInProgressCount,
    required this.currentArchivedCount,
    required this.currentPopularityData,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is HabitSummaryStatisticsData &&
        other.currentComplatedCount == currentComplatedCount &&
        other.currentInProgressCount == currentInProgressCount &&
        other.currentArchivedCount == currentArchivedCount &&
        other.currentPopularityData == currentPopularityData;
  }

  @override
  int get hashCode => hash3(
      currentArchivedCount, currentComplatedCount, currentInProgressCount);
}
