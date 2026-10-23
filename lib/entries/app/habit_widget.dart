// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../extensions/context_extensions.dart';
import '../../logging/helper.dart';
import '../../models/app_event.dart';
import '../../providers/workflow/app_event.dart';
import '../../providers/workflow/habit_widget.dart';
import '../../widgets/_widgets/date_change.dart';
import '../habit_widget/habit_widget_api.g.dart';

/// Connects the widget workflow to foreground app events and lifecycle.
final class HabitWidgetPostInitBridge
    implements AppEventSubscriber, HabitWidgetForegroundApi {
  HabitWidgetService? _service;
  AppEventBus? _events;
  DateChangeNotifier? _dateChanges;
  AppEventSubscriptions? _eventSubs;
  AppLifecycleListener? _lifecycle;
  String? _locale;
  bool _publishing = false;
  bool _publishPending = false;

  /// Updates subscriptions and the app language from the current scope.
  void sync(BuildContext context, {required String? locale}) {
    final service = context.maybeRead<HabitWidgetService>();
    final events = context.maybeRead<AppEventBus>();
    final dateChanges = context.maybeRead<DateChangeNotifier>();
    final changed =
        !identical(_service, service) ||
        !identical(_events, events) ||
        !identical(_dateChanges, dateChanges);
    if (changed) {
      _detach();
      _service = service;
      _events = events;
      _dateChanges = dateChanges;
      if (service != null) {
        if (events != null) {
          _eventSubs = AppEventSubscriptions(this, events)
            ..subscribe<AppEvent>();
        }
        dateChanges?.addListener(_publish);
        _lifecycle = AppLifecycleListener(onResume: _onExternalChange);
        HabitWidgetForegroundApi.setUp(this);
      }
    }

    final localeChanged = _locale != locale;
    _locale = locale;
    if (changed || localeChanged) _publish();
  }

  /// Accepts events from the subscribed application event bus.
  @override
  bool shouldReceive(AppEvent event) => true;

  /// Invalidates foreground caches after a native background operation.
  @override
  void changed() => _onExternalChange();

  /// Requests publication for events that can change the display projection.
  @override
  void handleEvent(AppEvent event) => switch (event) {
    ReloadDataEvent() ||
    HabitStatusChangedEvent() ||
    HabitRecordsChangedEvent() ||
    HabitDataChangedEvent() ||
    GroupChangedEvent() => _publish(),
  };

  /// Refreshes isolate-local caches before requesting a new projection.
  void _onExternalChange() {
    if (_service == null) return;
    final events = _events;
    if (events == null) {
      _publish();
    } else {
      // A separate Flutter engine cannot notify this isolate's cached VMs.
      events.push(const ReloadDataEvent(msg: 'habit_widget.changed'));
    }
  }

  /// Coalesces publication requests without overlapping publisher calls.
  void _publish() {
    if (_service == null) return;
    _publishPending = true;
    if (!_publishing) unawaited(_drainPublish());
  }

  /// Drains pending refreshes and contains individual publication failures.
  Future<void> _drainPublish() async {
    _publishing = true;
    try {
      while (_publishPending && _service != null) {
        _publishPending = false;
        try {
          await _service!.publishSnapshot(locale: _locale);
        } catch (error, stackTrace) {
          appLog.habitWidget.warn(
            'HabitWidgetPostInitBridge.publish',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    } finally {
      _publishing = false;
    }
  }

  /// Releases subscriptions associated with the previous app scope.
  void _detach() {
    _eventSubs?.cancelAll();
    _eventSubs = null;
    _dateChanges?.removeListener(_publish);
    _lifecycle?.dispose();
    _lifecycle = null;
    if (_service != null) HabitWidgetForegroundApi.setUp(null);
  }

  /// Releases subscriptions and prevents pending work from being rescheduled.
  void dispose() {
    _detach();
    _service = null;
    _events = null;
    _dateChanges = null;
    _publishPending = false;
  }
}
