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

import '../../common/types.dart';
import '../../models/app_event.dart';
import '../../models/habit_form.dart';
import '../../models/habit_status.dart';
import '../../models/habit_summary.dart';
import '../../providers/app_event.dart';

extension AppEventViewModelExtension on AppEventViewModel {
  void pushHabitsChangeStatus(List<HabitStatusChangedRecord> recordList,
      {String? msg, AppEventPageSource? source}) {
    recordList.fold<Map<HabitStatus, List<HabitUUID>>>({}, (acc, r) {
      (acc[r.newStatus] ??= []).add(r.habitUUID);
      return acc;
    }).forEach((status, uuids) {
      push(HabitStatusChangedEvent(
        msg: msg,
        uuidList: uuids,
        status: status,
        trace: {
          if (source != null)
            source: const {AppEventFunctionSource.habitChanged}
        },
      ));
    });
  }

  void pushHabitRecordChangeStatus(HabitUUID uuid, HabitSummaryRecord record,
      {String? reason, String? msg, AppEventPageSource? source}) {
    push(HabitRecordsChangedEvents(
      msg: msg,
      uuidList: [uuid],
      dateList: [record.date],
      status: record.status,
      reason: reason,
      trace: {
        if (source != null) source: const {AppEventFunctionSource.recordChanged}
      },
    ));
  }
}
