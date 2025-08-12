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

import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../model/habit_daily_record_form.dart';
import '../model/habit_date.dart';
import '../model/habit_form.dart';
import '../model/habit_summary.dart';
import '../persistent/db_helper_provider.dart';
import '../persistent/local/handler/record.dart';
import 'commons.dart';

part 'habit_status_changer.g.dart';

enum RecordStatusChangerStatus {
  skip,
  ok,
  dual,
  zero; // only for normal habit

  static const normalStatus = {
    RecordStatusChangerStatus.skip,
    RecordStatusChangerStatus.ok,
    RecordStatusChangerStatus.dual,
    RecordStatusChangerStatus.zero,
  };

  static const negativeStatus = {
    RecordStatusChangerStatus.skip,
    RecordStatusChangerStatus.ok,
    RecordStatusChangerStatus.dual,
  };
}

class HabitStatusChangerViewModel
    with ChangeNotifier, DBHelperLoadedMixin
    implements ProviderMounted {
  // data
  final List<HabitUUID> _selectedUUIDList;
  HabitSummaryDataCollection _data = HabitSummaryDataCollection();
  late HabitsDataDelagate _dataDelate;
  late HabitStatusChangerForm _form;
  // status
  CancelableCompleter<void>? _loading;
  // controller
  late final ScrollController mainScrollController;
  // dispatcher
  final Map<Key?, AnimatedListDiffListDispatcher<HabitSortCache>> _dispatchers =
      {};
  // inside status
  bool _mounted = true;
  bool _isSkipReasonEdited = false;
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
    _form.skipInputController.addListener(() {
      _isSkipReasonEdited = true;
      notifyListeners();
    });
    _dataDelate = HabitsDataDelagate(this);
  }

  //#region loading data
  void _cancelLoading() {
    final loading = _loading;
    if (loading == null) return;

    void onCancelled() {
      if (_loading == loading) _loading = null;
      appLog.load.info("$runtimeType._cancelLoading",
          ex: ['cancelled', loading.hashCode]);
    }

    appLog.load.info("$runtimeType._cancelLoading", ex: [loading.hashCode]);
    if (loading.isCompleted || loading.isCanceled) {
      onCancelled();
    } else {
      loading.operation.cancel();
      onCancelled();
    }
  }

  Future loadData({bool listen = true, bool inFutureBuilder = false}) async {
    final crtLoading = _loading;
    if (crtLoading != null && !crtLoading.isCanceled) {
      appLog.load.warn("$runtimeType.loadData",
          ex: ["data already loaded", crtLoading.isCompleted]);
      return crtLoading.operation.valueOrCancellation();
    }

    final loading = _loading = CancelableCompleter<void>();

    void loadingFailed(List errmsg) {
      appLog.load.error("$runtimeType.load",
          ex: [...errmsg, loading.hashCode],
          stackTrace: LoggerStackTrace.from(StackTrace.current));
      if (!loading.isCompleted) {
        loading.completeError(
            FlutterError(errmsg.join(" ")), StackTrace.current);
      }
    }

    void loadingCancelled() {
      appLog.load
          .info("$runtimeType.load", ex: ['cancelled', loading.hashCode]);
    }

    Future<void> loadingData() async {
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      appLog.load.debug("$runtimeType.load",
          ex: ["loading data", loading.hashCode, listen, inFutureBuilder]);

      // init habits
      final habitLoadTask = habitDBHelper.loadHabitAboutDataCollection(
          uuidFilter: _selectedUUIDList);
      final recordLoadTask =
          recordDBHelper.loadAllRecords(uuidFilter: _selectedUUIDList);
      final habitLoaded = await habitLoadTask;
      final recordLoaded = await recordLoadTask;
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;

      _data.initDataFromDBQueuryResult(habitLoaded, recordLoaded);
      _data.forEach((_, habit) =>
          habit.reCalculateAutoComplateRecords(firstDay: firstday));
      _reDispached();
      _updateForm(_form, withDefaultChangerStatus: true);
      // complete
      loading.complete();
      // reload
      if (listen) {
        if (inFutureBuilder) _dataDelate = HabitsDataDelagate(this);
        notifyListeners();
      }
      appLog.load.debug("$runtimeType.load",
          ex: ["loaded", loading.hashCode, listen, inFutureBuilder]);
    }

    loadingData();
    return loading.operation.valueOrCancellation();
  }
  //#endregion

  //#region dispatcher
  @visibleForTesting
  Map<Key?, AnimatedListDiffListDispatcher<HabitSortCache>>
      get debugDispatchers => _dispatchers;

  AnimatedListDiffListDispatcher<HabitSortCache>? getDispatcher(Key? key) =>
      _dispatchers[key];

  void regDispatcher(
      Key? key, AnimatedListDiffListDispatcher<HabitSortCache> dispatcher) {
    assert(!_dispatchers.containsKey(key));
    _dispatchers[key] = dispatcher;
  }

  void unRegDispatcher(Key? key) => _dispatchers.remove(key)?.discard();

  void _reDispached({List<Key>? keys}) {
    for (var key in _dispatchers.keys) {
      if (keys != null && !keys.contains(key)) continue;
      _dispatchers[key]!
          .dispatchNewList(dataDelegate.habitsSortableCache.toList());
    }
  }
  //#endregion

  //#region: firstday
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
  //#endregion

  TextEditingController get skipInputController => _form.skipInputController;

  HabitsDataDelagate get dataDelegate => _dataDelate;

  bool get canSave {
    if (_form.selectStatus == RecordStatusChangerStatus.skip &&
        _isSkipReasonEdited) {
      return true;
    }
    return _form.selectStatus != null &&
        _form.selectStatus != getDefaultChangerStatus(_form);
  }

  Iterable<HabitSummaryRecord> get selectDateRecords => dataDelegate.habits
      .map((e) => e.getRecordByDate(_form.selectDate))
      .whereNotNull()
      .where((e) => e.status != HabitRecordStatus.unknown);

  HabitDate get selectDate => _form.selectDate;

  String get skipReason => skipInputController.text;

  HabitDate get earlistStartDate {
    var startDate = selectDate;
    for (var d in _data.values) {
      if (d.startDate.isBefore(startDate)) startDate = d.startDate;
    }
    return startDate;
  }

  void updateSelectDate(HabitDate newDate, {bool listen = true}) {
    if (newDate.isAfter(HabitDate.now())) return;
    _updateForm(_form.toNewDate(newDate), withDefaultChangerStatus: true);
    if (listen) notifyListeners();
  }

  void _updateForm(HabitStatusChangerForm newForm,
      {bool withDefaultChangerStatus = false}) {
    _form = withDefaultChangerStatus
        ? newForm.copyWith(selectStatus: getDefaultChangerStatus(newForm))
        : newForm;
    _isSkipReasonEdited = false;
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

  RecordStatusChangerStatus? getDefaultChangerStatus(
          HabitStatusChangerForm form) =>
      _data.length <= 0
          ? null
          : _data.values
              .map((e) => form.convertStatusFromHabit(e))
              .reduce((value, element) => value == element ? value : null);

  void updateSelectStatus(RecordStatusChangerStatus? newStatus,
      {bool listen = true}) {
    if (newStatus == selectStatus) return;
    _updateForm(_form.copyWith(selectStatus: newStatus));
    if (selectStatus == RecordStatusChangerStatus.skip) {
      mainScrollController.animateTo(0,
          duration: mainScrollAnimatedDuration, curve: mainScrollAnimatedCurve);
    }
    if (listen) notifyListeners();
  }

  void resetStatusForm({bool listen = true}) {
    _updateForm(_form.toDefault(), withDefaultChangerStatus: true);
    if (listen) notifyListeners();
  }

  Future<int> saveSelectStatus({bool listen = true}) async {
    if (!mounted || !canSave) return 0;
    final records = dataDelegate.habits
        .where((e) => e.startDate <= _form.selectDate)
        .map((e) => Tuple2(_form.buildRecordFromHabit(e), e))
        .where((e) => e.item1 != null)
        .map((e) {
      final record = e.item1!;
      final habit = e.item2;
      return RecordDBCell.build(
          parentId: habit.id,
          parentUUID: habit.uuid,
          recordDate: record.date.epochDay,
          recordType: record.status.dbCode,
          recordValue: record.value,
          uuid: record.uuid,
          reason: selectStatus == RecordStatusChangerStatus.skip
              ? skipReason
              : null);
    }).toList();
    await recordDBHelper.insertOrUpdateMultiRecords(records);
    if (!mounted) return 0;

    regToReloadData();
    if (listen) notifyListeners();
    return records.length;
  }

  void updateDataColl(List<HabitSummaryData> dataList,
      {bool needClear = false, bool listen = true}) {
    _data = needClear ? HabitSummaryDataCollection() : _data;
    _dataDelate.updateData(dataList, listen: listen);
  }

  void _onUpdateDataColl({required bool listen}) {
    if (listen) notifyListeners();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    for (var dispatcher in _dispatchers.values) {
      dispatcher.discard();
    }
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

  HabitSummaryRecord? buildRecordFromHabit(HabitSummaryData data) {
    final uuid = data.getRecordByDate(selectDate)?.uuid;
    switch (selectStatus) {
      case RecordStatusChangerStatus.skip:
        return HabitSummaryRecord.generate(selectDate,
            parentUUID: data.uuid, status: HabitRecordStatus.skip, uuid: uuid);
      case RecordStatusChangerStatus.ok:
        return HabitSummaryRecord.generate(selectDate,
            status: HabitRecordStatus.done,
            value: data.habitOkValue,
            parentUUID: data.uuid,
            uuid: uuid);
      case RecordStatusChangerStatus.dual:
        switch (data.type) {
          case HabitType.normal:
            return HabitSummaryRecord.generate(selectDate,
                status: HabitRecordStatus.done,
                value: data.dailyGoalExtra != null
                    ? math.max(data.dailyGoalExtra!, data.habitOkValue * 2)
                    : data.habitOkValue * 2,
                parentUUID: data.uuid,
                uuid: uuid);
          case HabitType.negative:
            return HabitSummaryRecord.generate(selectDate,
                status: HabitRecordStatus.done,
                value: data.dailyGoal,
                parentUUID: data.uuid,
                uuid: uuid);
          case HabitType.unknown:
            return null;
        }
      case RecordStatusChangerStatus.zero:
        return HabitSummaryRecord.generate(selectDate,
            status: HabitRecordStatus.done,
            value: 0,
            parentUUID: data.uuid,
            uuid: uuid);
      case null:
        return null;
    }
  }

  RecordStatusChangerStatus? convertStatusFromHabit(HabitSummaryData data) {
    final record = data.getRecordByDate(selectDate);
    switch (record?.status) {
      case null:
      case HabitRecordStatus.unknown:
        return null;
      case HabitRecordStatus.done:
        final recordForm = HabitDailyRecordForm.getImp(
            type: data.type,
            value: record!.value,
            targetValue: data.dailyGoal,
            extraTargetValue: data.dailyGoalExtra);
        switch (recordForm.complateStatus) {
          case HabitDailyComplateStatus.zero:
            return RecordStatusChangerStatus.zero;
          case HabitDailyComplateStatus.ok:
            return RecordStatusChangerStatus.ok;
          case HabitDailyComplateStatus.goodjob:
            switch (recordForm.habitType) {
              case HabitType.unknown:
                return null;
              case HabitType.normal:
                return (record.value == data.dailyGoalExtra ||
                        record.value == data.habitOkValue * 2)
                    ? RecordStatusChangerStatus.dual
                    : null;
              case HabitType.negative:
                return record.value == data.dailyGoal
                    ? RecordStatusChangerStatus.dual
                    : null;
            }
          case HabitDailyComplateStatus.tryhard:
          case HabitDailyComplateStatus.noeffect:
            return null;
        }
      case HabitRecordStatus.skip:
        return RecordStatusChangerStatus.skip;
    }
  }

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
