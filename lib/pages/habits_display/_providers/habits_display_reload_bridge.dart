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

import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/app_sync.dart';

/// Manages sync-workflow and app-event subscriptions shared by
/// habits-display VMs.
final class HabitsDisplayReloadBridge {
  AppSyncWorkflowAccess? _workflow;
  StreamSubscription<String>? _startSyncSub;
  AppEventSubscriptions? _eventSubs;

  /// The shared [AppEventSubscriptions] created by the last call to
  /// [updateAppEvent].
  AppEventSubscriptions? get eventSubs => _eventSubs;

  void attachWorkflow(
    AppSyncWorkflowAccess workflow, {
    required void Function(String id) onStartSync,
  }) {
    if (identical(workflow, _workflow)) return;
    _workflow = workflow;
    _startSyncSub?.cancel();
    _startSyncSub = workflow.startSyncEvents.listen(onStartSync);
  }

  /// Replaces the current event subscriptions with a new set backed by
  /// [bus] and filtered by [subscriber].
  void updateAppEvent(AppEventBus bus, AppEventSubscriber subscriber) {
    _eventSubs?.cancelAll();
    _eventSubs = AppEventSubscriptions(subscriber, bus);
  }

  void dispose() {
    _startSyncSub?.cancel();
    _eventSubs?.cancelAll();
  }
}
