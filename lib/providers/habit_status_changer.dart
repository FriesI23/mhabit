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

import 'dart:collection';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../common/types.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../models/habit_daily_record_form.dart';
import '../models/habit_date.dart';
import '../models/habit_form.dart';
import '../models/habit_repo_actions.dart';
import '../models/habit_summary.dart';
import 'commons.dart';
import 'habits_manager.dart';

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
    with ChangeNotifier, HabitsManagerLoadedMixin
    implements ProviderMounted {
  // data
  final List<HabitUUID> _selectedUUIDList;
  late HabitStatusChangerForm _form;
  List<HabitSortCache> _currentHabitList = const [];
  // controller
  final _habitDataController = _HabitDataController();
  // status
  CancelableCompleter<void>? _loading;
  // inside status
  bool _mounted = true;
  bool _isSkipReasonEdited = false;
  // sync from setting
  int _firstday = defaultFirstDay;

  HabitStatusChangerViewModel({required List<HabitUUID> uuidList})
      : _selectedUUIDList = uuidList {
    _form = HabitStatusChangerForm(selectDate: HabitDate.now());
  }

  //#region loading data
  void _cancelLoading() {
    final loading = _loading;
    if (loading == null) return;

    if (!(loading.isCompleted || loading.isCanceled)) {
      appLog.load.info("$runtimeType._cancelLoading", ex: [loading.hashCode]);
      loading.operation.cancel();
    }
    if (_loading == loading) _loading = null;
    appLog.load.info("$runtimeType._cancelLoading",
        ex: ['cancelled', loading.hashCode]);
  }

  CancelableCompleter<void>? get _effectiveLoading {
    final loading = _loading;
    return (loading != null && !loading.isCanceled) ? loading : null;
  }

  bool get isDataLoading => _effectiveLoading != null;

  Future loadData({bool listen = true}) async {
    final currentLoading = _effectiveLoading;
    if (currentLoading != null) {
      appLog.load.warn("$runtimeType.loadData",
          ex: ["data is currently loading", currentLoading.isCompleted]);
      return currentLoading.operation.valueOrCancellation();
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
          ex: ["loading data", loading.hashCode, listen]);

      // init habits
      final collection = await habitsManager.loadHabitSummaryCollectionData(
          habitUUIDs: _selectedUUIDList);
      if (!mounted) return loadingFailed(const ["viewmodel disposed"]);
      if (loading.isCanceled) return loadingCancelled();
      if (loading.isCompleted) return;

      _habitDataController.replaceData(collection
        ..forEach((_, habit) =>
            habit.reCalculateAutoComplateRecords(firstDay: firstday)));
      _updateCurrentHabitList();
      _updateForm(_form, withDefaultChangerStatus: true);

      // complete
      loading.complete();
      // reload
      if (listen) {
        notifyListeners();
      }
      appLog.load
          .debug("$runtimeType.load", ex: ["loaded", loading.hashCode, listen]);
    }

    loadingData();
    return loading.operation.valueOrCancellation();
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

  UnmodifiableListView<HabitSortCache> get currentHabitList =>
      UnmodifiableListView(_currentHabitList);

  int get currentHabitCount => _currentHabitList.length;

  HabitSummaryData? fetchHabit(HabitUUID uuid) =>
      _habitDataController.getHabit(uuid);

  bool get canSave {
    if (_form.selectStatus == RecordStatusChangerStatus.skip &&
        _isSkipReasonEdited) {
      return true;
    }
    return _form.selectStatus != null &&
        _form.selectStatus != getDefaultChangerStatus(_form);
  }

  Iterable<HabitSummaryRecord> get selectDateRecords =>
      _habitDataController.habits
          .map((e) => e.getRecordByDate(_form.selectDate))
          .nonNulls
          .where((e) => e.status != HabitRecordStatus.unknown);

  HabitDate get selectDate => _form.selectDate;

  String get skipReason => _form.skipReason ?? '';
  set skipReason(String value) {
    if (value == skipReason) return;
    appLog.value.debug("HabitStatusChangerViewModel.startDate",
        beforeVal: _form.skipReason, afterVal: value);
    _form.skipReason = value;
    _isSkipReasonEdited = true;
    notifyListeners();
  }

  HabitDate get earlistStartDate {
    var startDate = selectDate;
    for (var d in _habitDataController.habits) {
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
    for (var d in _habitDataController.habits) {
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
      _habitDataController.habitCount <= 0
          ? null
          : _habitDataController.habits
              .map((e) => form.convertStatusFromHabit(e))
              .reduce((value, element) => value == element ? value : null);

  void updateSelectStatus(RecordStatusChangerStatus? newStatus,
      {ValueChanged? onStatusChanged, bool listen = true}) {
    if (newStatus == selectStatus) return;
    _updateForm(_form.copyWith(selectStatus: newStatus));
    onStatusChanged?.call(selectStatus);
    if (listen) notifyListeners();
  }

  void resetStatusForm({bool listen = true}) {
    _updateForm(_form.toDefault(), withDefaultChangerStatus: true);
    if (listen) notifyListeners();
  }

  Future<int> saveSelectStatus({bool listen = true}) async {
    if (!mounted || !canSave) return 0;
    final records = _habitDataController.habits
        .where((e) => e.startDate <= _form.selectDate)
        .map((e) {
          final record = _form.buildRecordFromHabit(e);
          return record != null ? (record: record, habit: e) : null;
        })
        .nonNulls
        .map((e) => ChangeRecordStatusResult.record(
            habit: e.habit,
            data: e.record,
            reason: selectStatus == RecordStatusChangerStatus.skip
                ? skipReason
                : null));
    await habitsManager.saveMultiHabitRecordToDB(records);
    if (!mounted) return 0;

    requestReloadData();
    if (listen) notifyListeners();
    return records.length;
  }

  void _updateCurrentHabitList() {
    if (!mounted) return;
    final newList = _habitDataController.habits
        .map((e) => HabitSummaryDataSortCache(data: e))
        .toList(growable: false);
    appLog.load.info("_updateCurrentHabitList",
        ex: [_currentHabitList.hashCode, newList.hashCode]);
    _currentHabitList = newList;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _cancelLoading();
    super.dispose();
    _mounted = false;
  }

  void requestReloadData() {
    _cancelLoading();
    notifyListeners();
  }

  @override
  String toString() => "$runtimeType(form=$_form,data=$_habitDataController)";
}

@CopyWith(skipFields: true)
final class HabitStatusChangerForm {
  final HabitDate selectDate;
  final RecordStatusChangerStatus? selectStatus;
  String? skipReason;

  HabitStatusChangerForm({
    required this.selectDate,
    this.selectStatus,
    this.skipReason,
  });

  HabitStatusChangerForm toNewDate(HabitDate newDate) =>
      copyWith(selectDate: newDate, selectStatus: null, skipReason: null);

  HabitStatusChangerForm toDefault() =>
      copyWith(selectStatus: null, skipReason: null);

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
      "skipReason=$skipReason)";
}

class _HabitDataController {
  HabitSummaryDataCollection _data = HabitSummaryDataCollection();

  _HabitDataController();

  Iterable<HabitSummaryData> get habits => _data.values;

  int get habitCount => _data.length;

  bool containsHabit(HabitUUID uuid) => _data.containsHabitUUID(uuid);

  HabitSummaryData? getHabit(HabitUUID uuid) => _data.getHabitByUUID(uuid);

  void replaceData(HabitSummaryDataCollection newData) {
    _data = newData;
  }

  @override
  String toString() => "_HabitDataController(data=$_data)";
}
