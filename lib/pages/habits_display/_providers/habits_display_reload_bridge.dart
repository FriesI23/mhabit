// Copyright 2026 Fries_I23
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

import 'dart:async';

import '../../../models/app_event.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/app_sync.dart';

final class HabitsDisplayReloadBridge {
  AppSyncWorkflowAccess? _workflow;
  StreamSubscription<String>? _startSyncSub;
  StreamSubscription<ReloadDataEvent>? _reloadDataSub;
  StreamSubscription<HabitStatusChangedEvent>? _habitStatusChangedSub;
  StreamSubscription<HabitRecordsChangedEvents>? _habitRecordsChangedSub;

  void attachWorkflow(
    AppSyncWorkflowAccess workflow, {
    required void Function(String id) onStartSync,
  }) {
    if (identical(workflow, _workflow)) return;
    _workflow = workflow;
    _startSyncSub?.cancel();
    _startSyncSub = workflow.startSyncEvents.listen(onStartSync);
  }

  void updateAppEvent(
    AppEventBus newAppEvent, {
    required void Function(ReloadDataEvent event) onReloadData,
    required void Function(HabitStatusChangedEvent event) onHabitStatusChanged,
    required void Function(HabitRecordsChangedEvents event)
    onHabitRecordsChanged,
  }) {
    _reloadDataSub?.cancel();
    _habitStatusChangedSub?.cancel();
    _habitRecordsChangedSub?.cancel();
    _reloadDataSub = newAppEvent.on<ReloadDataEvent>().listen(onReloadData);
    _habitStatusChangedSub = newAppEvent.on<HabitStatusChangedEvent>().listen(
      onHabitStatusChanged,
    );
    _habitRecordsChangedSub = newAppEvent
        .on<HabitRecordsChangedEvents>()
        .listen(onHabitRecordsChanged);
  }

  void dispose() {
    _startSyncSub?.cancel();
    _reloadDataSub?.cancel();
    _habitStatusChangedSub?.cancel();
    _habitRecordsChangedSub?.cancel();
  }
}
