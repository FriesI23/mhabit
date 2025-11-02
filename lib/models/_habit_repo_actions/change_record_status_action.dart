// Copyright 2025 Fries_I23
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

import 'package:copy_with_extension/copy_with_extension.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../habit_daily_record_form.dart';
import '../habit_form.dart';
import '../habit_repo_actions.dart';
import '../habit_summary.dart';

part 'change_record_status_action.g.dart';

@CopyWith(skipFields: true)
class ChangeRecordStatusResult {
  final HabitSummaryRecord? origin;
  final HabitSummaryRecord data;
  final String? reason;
  final bool added;

  const ChangeRecordStatusResult({
    this.origin,
    required this.data,
    this.reason,
    this.added = false,
  });

  bool get isNew => origin == null;

  @override
  String toString() => 'ChangeRecordStatusResult('
      'origin=$origin,data=$data,'
      'reason=$reason,added=$added'
      ')';
}

abstract interface class ChangeRecordStatusAction<T>
    implements HabitRepoAction<List<ChangeRecordStatusResult>> {
  HabitSummaryData get data;

  List<T> get valueList;

  ChangeRecordStatusResult resolveSingle(T value);
}

final class ChangeRecordStatusPostAction
    implements ChangeRecordStatusAction<ChangeRecordStatusResult> {
  @override
  final HabitSummaryData data;
  final List<ChangeRecordStatusResult> _preResults;

  const ChangeRecordStatusPostAction({
    required this.data,
    required List<ChangeRecordStatusResult> results,
  }) : _preResults = results;

  @override
  List<ChangeRecordStatusResult> get valueList => _preResults;

  @override
  List<ChangeRecordStatusResult> resolve() {
    final result = _preResults.map(resolveSingle).toList();
    data.bumpVersion();
    return result;
  }

  @override
  ChangeRecordStatusResult resolveSingle(ChangeRecordStatusResult value) {
    return value.copyWith(added: data.addRecord(value.data, replaced: true));
  }
}

final class AutoChangeRecordStatusAction
    implements ChangeRecordStatusAction<HabitRecordDate> {
  @override
  final HabitSummaryData data;
  final List<HabitRecordDate> _dateList;

  const AutoChangeRecordStatusAction({
    required this.data,
    required List<HabitRecordDate> dateList,
  }) : _dateList = dateList;

  @override
  List<HabitRecordDate> get valueList => _dateList;

  @override
  List<ChangeRecordStatusResult> resolve() =>
      _dateList.map(resolveSingle).toList();

  @override
  ChangeRecordStatusResult resolveSingle(HabitRecordDate date) {
    final HabitSummaryRecord orgRecord;
    final HabitSummaryRecord record;
    final bool isNew;

    if (data.containsRecordDate(date)) {
      orgRecord = data.getRecordByDate(date)!;
      isNew = false;
    } else {
      orgRecord = HabitSummaryRecord.generate(date, parentUUID: data.uuid);
      isNew = true;
    }

    // status changed: unknown -> (done(ok), done(zero), skip)
    // status changed(with valued): unknown -> (done(value), skip)
    final habitRecordForm = HabitDailyRecordForm.getImp(
      type: data.type,
      value: orgRecord.value,
      targetValue: data.dailyGoal,
      extraTargetValue: data.dailyGoalExtra,
    );
    final completeStatus = habitRecordForm.complateStatus;
    final valued = habitRecordForm.isValued;
    switch (orgRecord.status) {
      case HabitRecordStatus.unknown:
      case HabitRecordStatus.skip:
        record = orgRecord.copyWith(
            status: HabitRecordStatus.done,
            value: valued ? orgRecord.value : data.habitOkValue);
        break;
      case HabitRecordStatus.done:
        if (valued) {
          record = orgRecord.copyWith(status: HabitRecordStatus.skip);
        } else {
          if (completeStatus == HabitDailyComplateStatus.ok &&
              orgRecord.value != minHabitDailyGoal) {
            record = orgRecord.copyWith(value: minHabitDailyGoal);
          } else {
            record = orgRecord.copyWith(status: HabitRecordStatus.skip);
          }
        }
        break;
    }

    return ChangeRecordStatusResult(
        origin: isNew ? null : orgRecord, data: record);
  }
}
