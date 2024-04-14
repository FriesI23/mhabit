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

import 'package:flutter/material.dart';

import '../model/habit_date.dart';
import '../model/habit_form.dart';
import '../model/habit_summary.dart';
import 'commons.dart';

abstract interface class PageHabitsStatusChangerResult {
  int get changedCount;

  factory PageHabitsStatusChangerResult.empty() =>
      const PageHabitsStatusChangerNumberResult(0);

  factory PageHabitsStatusChangerResult.fromNum(int num) =>
      PageHabitsStatusChangerNumberResult(num);
}

enum RecordStatusChangerStatus {
  skip,
  ok,
  goodjob,
  zero; // only for normal habit

  static const normalStatus = {
    RecordStatusChangerStatus.skip,
    RecordStatusChangerStatus.ok,
    RecordStatusChangerStatus.goodjob,
    RecordStatusChangerStatus.zero,
  };

  static const negativeStatus = {
    RecordStatusChangerStatus.skip,
    RecordStatusChangerStatus.ok,
    RecordStatusChangerStatus.goodjob,
  };
}

final class PageHabitsStatusChangerNumberResult
    implements PageHabitsStatusChangerResult {
  @override
  final int changedCount;

  const PageHabitsStatusChangerNumberResult(this.changedCount)
      : assert(changedCount >= 0);
}

class HabitStatusChangerViewModel
    with ChangeNotifier
    implements ProviderMounted {
  // data
  HabitSummaryDataCollection _dataColl = HabitSummaryDataCollection();
  // status
  HabitDate _selectDate = HabitDate.now();
  RecordStatusChangerStatus? _selectStatus;
  // controller
  late final ScrollController mainScrollController;
  final TextEditingController skipInputController = TextEditingController();
  // inside status
  bool _mounted = true;

  Duration get mainScrollAnimatedDuration => const Duration(milliseconds: 300);
  Curve get mainScrollAnimatedCurve => Curves.fastOutSlowIn;

  HabitStatusChangerViewModel(
      {ScrollController? mainScrollController,
      List<HabitSummaryData>? dataList}) {
    this.mainScrollController = mainScrollController ?? ScrollController();
    if (dataList != null && dataList.isNotEmpty) {
      updateDataColl(dataList, listen: false);
    }
  }

  HabitDate get selectDate => _selectDate;

  HabitDate get earlistStartDate {
    var startDate = _selectDate;
    _dataColl.forEach((k, v) {
      if (v.startDate.isBefore(startDate)) startDate = v.startDate;
    });
    return startDate;
  }

  void updateSelectDate(HabitDate newDate, {bool listen = true}) {
    if (newDate.isAfter(HabitDate.now())) return;
    _selectDate = newDate;
    skipInputController.clear();
    _clearSelectedStatus();
    if (listen) notifyListeners();
  }

  RecordStatusChangerStatus? get selectStatus => _selectStatus;

  Set<RecordStatusChangerStatus> get selectDateAllowedStatus {
    Set<RecordStatusChangerStatus> statusColl =
        Set.from(RecordStatusChangerStatus.values);
    _dataColl.forEach((k, data) {
      switch (data.type) {
        case HabitType.unknown:
          return;
        case HabitType.normal:
          statusColl =
              statusColl.intersection(RecordStatusChangerStatus.normalStatus);
          break;
        case HabitType.negative:
          statusColl =
              statusColl.intersection(RecordStatusChangerStatus.negativeStatus);
          break;
      }
    });
    return statusColl;
  }

  void updateSelectStatus(RecordStatusChangerStatus? newStatus,
      {bool listen = true}) {
    if (newStatus == _selectStatus) return;
    _selectStatus = newStatus;
    if (_selectStatus == RecordStatusChangerStatus.skip) {
      mainScrollController.animateTo(0,
          duration: mainScrollAnimatedDuration, curve: mainScrollAnimatedCurve);
    }
    if (listen) notifyListeners();
  }

  void _clearSelectedStatus() {
    updateSelectStatus(null);
  }

  void updateDataColl(List<HabitSummaryData> dataList,
      {bool needClear = false, bool listen = true}) {
    final newDataColl = needClear ? HabitSummaryDataCollection() : _dataColl;
    for (var data in dataList) {
      newDataColl.addNewHabit(data);
    }
    _dataColl = newDataColl;
    if (listen) notifyListeners();
  }

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  String toString() =>
      "$runtimeType(select=$_selectDate|$_selectStatus,data=$_dataColl)";
}
