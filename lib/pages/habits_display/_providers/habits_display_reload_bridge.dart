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
