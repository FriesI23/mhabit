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

import 'package:async/async.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../model/habit_date.dart';
import '../model/habit_form.dart';
import '../model/habit_summary.dart';
import '../persistent/db_helper_provider.dart';
import 'commons.dart';

part 'habit_status_changer.g.dart';

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
    with ChangeNotifier, DBHelperLoadedMixin
    implements ProviderMounted {
  // data
  List<HabitUUID> _selectedUUIDList;
  HabitSummaryDataCollection _data = HabitSummaryDataCollection();
  late HabitsDataDelagate _dataDelate;
  late HabitStatusChangerForm _form;
  // status
  CancelableCompleter<void>? _loading;
  // controller
  late final ScrollController mainScrollController;
  // dispatcher
  late final AnimatedListDiffListDispatcher<HabitSortCache> _dispatcher;
  // inside status
  bool _mounted = true;
  // sync from setting
  int _firstday = defaultFirstDay;

  Duration get mainScrollAnimatedDuration => const Duration(milliseconds: 300);
  Curve get mainScrollAnimatedCurve => Curves.fastOutSlowIn;

  HabitStatusChangerViewModel(
      {ScrollController? mainScrollController,
      required List<HabitUUID> uuidList})
      : _selectedUUIDList = uuidList {
    this.mainScrollController = mainScrollController ?? ScrollController();
    _form = HabitStatusChangerForm(
        selectDate: HabitDate.now(),
        skipInputController: TextEditingController());
    _dataDelate = HabitsDataDelagate(this);
  }

  //#region loading data
  void _cancelLoading() {
    if (_loading?.isCompleted != true) {
      appLog.load.info("$runtimeType._cancelLoading", ex: [_loading]);
      _loading?.operation.cancel();
    }
    _loading = null;
  }

  Future loadData({bool listen = true, bool inFutureBuilder = false}) async {
    if (_loading != null) {
      appLog.load.warn("$runtimeType.loadData", ex: ["data already loaded"]);
      return _loading?.operation.value;
    }

    void loadingFailed(List errmsg) {
      appLog.load.error("$runtimeType.load",
          ex: errmsg, stackTrace: LoggerStackTrace.from(StackTrace.current));
      _loading?.completeError(
          FlutterError(errmsg.join(" ")), StackTrace.current);
    }

    Future<void> loadingData() async {
      appLog.load.debug("$runtimeType.load",
          ex: ["loading data", _loading.hashCode, listen]);
      if (!mounted) {
        loadingFailed(["viewmodel disposed"]);
        return;
      }
      // init habits
      final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection(
          uuidFilter: _selectedUUIDList);
      final recordLoadTask =
          recordDBHelper.loadAllRecords(uuidFilter: _selectedUUIDList);
      _data.initDataFromDBQueuryResult(
          await habitLoadTask, await recordLoadTask);
      if (!mounted) {
        loadingFailed(["viewmodel disposed"]);
        return;
      }
      _data.forEach((_, habit) =>
          habit.reCalculateAutoComplateRecords(firstDay: firstday));
      _redispach();
      // complete
      _loading?.complete();
      // reload
      if (listen) {
        if (inFutureBuilder) _dataDelate = HabitsDataDelagate(this);
        notifyListeners();
      }
      appLog.load.debug("$runtimeType.load",
          ex: ["loaded", _loading.hashCode, listen]);
    }

    _loading = CancelableCompleter<void>();
    loadingData();
    return _loading?.operation.value;
  }
  //#endregion

  //#region dispatcher
  AnimatedListController get dispatcherLinkedController =>
      _dispatcher.controller;

  AnimatedListDiffBuilder<List<HabitSortCache>> get dispatcherLinkedBuilder =>
      _dispatcher.builder;

  List<HabitSortCache> get lastSortedDataCache => _dispatcher.currentList;

  void initDispatcher(
      AnimatedListDiffListDispatcher<HabitSortCache> dispatcher) {
    _dispatcher = dispatcher;
  }

  void _redispach() {
    _dispatcher.dispatchNewList(dataDelegate.habitsSortableCache.toList());
  }
  //#endregion

  TextEditingController get skipInputController => _form.skipInputController;

  HabitsDataDelagate get dataDelegate => _dataDelate;

  bool get canSave => selectStatus != null;

  HabitDate get selectDate => _form.selectDate;

  HabitDate get earlistStartDate {
    var startDate = selectDate;
    for (var d in _data.values) {
      if (d.startDate.isBefore(startDate)) startDate = d.startDate;
    }
    return startDate;
  }

  void updateSelectDate(HabitDate newDate, {bool listen = true}) {
    if (newDate.isAfter(HabitDate.now())) return;
    _form = _form.toNewDate(newDate);
    if (listen) notifyListeners();
  }

  RecordStatusChangerStatus? get selectStatus => _form.selectStatus;

  Set<RecordStatusChangerStatus> get selectDateAllowedStatus {
    Set<RecordStatusChangerStatus> statusColl =
        Set.from(RecordStatusChangerStatus.values);
    for (var d in _data.values) {
      switch (d.type) {
        case HabitType.normal:
          statusColl =
              statusColl.intersection(RecordStatusChangerStatus.normalStatus);
          break;
        case HabitType.negative:
          statusColl =
              statusColl.intersection(RecordStatusChangerStatus.negativeStatus);
          break;
        case HabitType.unknown:
          continue;
      }
    }
    return statusColl;
  }

  void updateSelectStatus(RecordStatusChangerStatus? newStatus,
      {bool listen = true}) {
    if (newStatus == selectStatus) return;
    _form = _form.copyWith(selectStatus: newStatus);
    if (selectStatus == RecordStatusChangerStatus.skip) {
      mainScrollController.animateTo(0,
          duration: mainScrollAnimatedDuration, curve: mainScrollAnimatedCurve);
    }
    if (listen) notifyListeners();
  }

  void resetStatusForm({bool listen = true}) {
    _form = _form.toDefault();
    if (listen) notifyListeners();
  }

  void updateDataColl(List<HabitSummaryData> dataList,
      {bool needClear = false, bool listen = true}) {
    _data = needClear ? HabitSummaryDataCollection() : _data;
    _dataDelate.updateData(dataList, listen: listen);
  }

  void _onUpdateDataColl({required bool listen}) {
    if (listen) notifyListeners();
  }

  int get firstday => _firstday;

  void updateFirstday(int newFirstDay) {
    final day = standardizeFirstDay(newFirstDay);
    if (kDebugMode && newFirstDay != day) {
      throw UnknownWeekdayNumber(newFirstDay);
    }
    _firstday = day;
  }

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    if (!_mounted) return;
    _dispatcher.discard();
    _cancelLoading();
    super.dispose();
    _mounted = false;
  }

  void regToReloadData() {
    _dataDelate = HabitsDataDelagate(this);
    _cancelLoading();
    notifyListeners();
  }

  @override
  String toString() => "$runtimeType(form=$_form,data=$_dataDelate)";
}

@CopyWith(skipFields: true)
final class HabitStatusChangerForm {
  final HabitDate selectDate;
  final RecordStatusChangerStatus? selectStatus;
  final TextEditingController skipInputController;

  const HabitStatusChangerForm({
    required this.selectDate,
    this.selectStatus,
    required this.skipInputController,
  });

  HabitStatusChangerForm toNewDate(HabitDate newDate) => copyWith(
      selectDate: newDate,
      selectStatus: null,
      skipInputController: skipInputController..clear());

  HabitStatusChangerForm toDefault() => copyWith(
      selectStatus: null, skipInputController: skipInputController..clear());

  @override
  String toString() =>
      "HabitStatusChangerForm(date=$selectDate,status=$selectStatus,"
      "skipInputController=$skipInputController)";
}

final class HabitsDataDelagate {
  final WeakReference<HabitStatusChangerViewModel> _vm;
  UniqueKey _updateFlag;

  HabitsDataDelagate(HabitStatusChangerViewModel vm)
      : _vm = WeakReference(vm),
        _updateFlag = UniqueKey();

  Iterable<HabitSummaryData> get habits => _vm.target?._data.values ?? const [];

  Iterable<HabitSortCache> get habitsSortableCache =>
      _vm.target?._data.values.map((e) => HabitSummaryDataSortCache(data: e)) ??
      const [];

  int get habitCount => _vm.target?._data.length ?? 0;

  bool containsHabitUUID(HabitUUID uuid) =>
      _vm.target?._data.containsHabitUUID(uuid) ?? false;

  HabitSummaryData? getHabitByUUID(HabitUUID uuid) =>
      _vm.target?._data.getHabitByUUID(uuid);

  void _reUpdateFlag() => _updateFlag = UniqueKey();

  void updateData(List<HabitSummaryData> dataList, {bool listen = false}) {
    if (_vm.target == null) return;
    final vm = _vm.target!;
    for (var data in dataList) {
      vm._data.addNewHabit(data, forceAdd: true);
    }
    _reUpdateFlag();
    vm._onUpdateDataColl(listen: listen);
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabitsDataDelagate) return false;
    return _updateFlag == other._updateFlag;
  }

  @override
  int get hashCode => _updateFlag.hashCode;

  @override
  String toString() =>
      "HabitsDataDelagate(upflag=$_updateFlag,data=${_vm.target?._data})";
}
