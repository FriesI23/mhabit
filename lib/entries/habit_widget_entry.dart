// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../common/app_info.dart';
import '../extensions/context_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../logging/logger_manager.dart';
import '../models/app_event.dart';
import '../models/habit_widget.dart';
import '../providers/workflow/app_event.dart';
import '../providers/workflow/app_notify_config.dart';
import '../providers/workflow/habit_widget.dart';
import '../providers/workflow/habits_manager.dart';
import '../reminders/notification_channel.dart';
import '../reminders/notification_service.dart';
import '../storage/db_helper_provider.dart';
import '../storage/profile/handlers/app_notify_config.dart';
import '../storage/profile_provider.dart';
import '../utils/local_timezone.dart';
import '../widgets/_widgets/date_change.dart';
import 'habit_widget_api.g.dart';

/// Runs in the app's private container, on the dedicated native widget engine.
/// Neither runApp nor the foreground app's sync workflow is started here.
Future<void> runHabitWidgetBackground() async {
  await AppLoggerMananger().init();
  await AppInfo().init();
  await NotificationService().init();
  await LocalTimeZoneManager().init();

  final profile = ProfileViewModel([AppNotifyConfigProfileHandler.new]);
  if (!await profile.init()) throw StateError('Could not load widget settings');
  final notifyConfig = AppNotifyConfigAccess()..updateProfile(profile);

  await HabitWidgetBackgroundChannel((uri) async {
    // The headless engine can outlive a foreground settings/timezone change.
    await profile.reload();
    notifyConfig.updateProfile(profile);
    await LocalTimeZoneManager().updateTimeZone();

    // Settings can replace the database file while this engine stays alive.
    // Keep a connection only for the action so a later tap cannot use the old,
    // unlinked database after the user clears their data in the foreground.
    final database = DBHelperViewModel();
    var opened = false;
    try {
      opened = await database.init();
      if (!opened) throw StateError('Could not initialize widget persistence');
      final habits = HabitsManager()
        ..attachNotifyConfig(notifyConfig)
        ..updateDBHelper(database)
        ..setNotificationChannelData(NotificationChannelData());
      final service = HabitWidgetService(
        database: database.local,
        habitsAccess: habits,
      );
      return await service.perform(uri);
    } finally {
      if (opened) await database.local.db.close();
      database.dispose();
    }
  }).start();
}

/// Acknowledges native intents only after their database operation completes.
final class HabitWidgetBackgroundChannel implements HabitWidgetBackgroundApi {
  final Future<HabitWidgetActionResult> Function(Uri uri) _perform;
  final HabitWidgetHostApi _hostApi;

  HabitWidgetBackgroundChannel(this._perform, {HabitWidgetHostApi? hostApi})
    : _hostApi = hostApi ?? HabitWidgetHostApi();

  Future<void> start() async {
    HabitWidgetBackgroundApi.setUp(this);
    await _hostApi.ready();
  }

  @override
  Future<HabitWidgetResult> perform(HabitWidgetRequest request) async {
    final uri = _widgetRequestUri(request);
    if (uri == null) return HabitWidgetResult.invalid;
    try {
      return switch (await _perform(uri)) {
        HabitWidgetActionResult.applied => HabitWidgetResult.applied,
        HabitWidgetActionResult.unchanged => HabitWidgetResult.unchanged,
        HabitWidgetActionResult.stale => HabitWidgetResult.stale,
        HabitWidgetActionResult.invalid => HabitWidgetResult.invalid,
      };
    } catch (error, stackTrace) {
      appLog.habit.error(
        'HabitWidgetBackgroundChannel.perform',
        error: error,
        stackTrace: stackTrace,
      );
      return HabitWidgetResult.failed;
    }
  }

  void dispose() => HabitWidgetBackgroundApi.setUp(null);
}

Uri? _widgetRequestUri(HabitWidgetRequest request) {
  switch (request.operation) {
    case HabitWidgetOperation.refresh:
      if (request.habitId != null ||
          request.day != null ||
          request.expectedRecord != null) {
        return null;
      }
      return Uri(scheme: 'tablehabit-widget', host: 'refresh');
    case HabitWidgetOperation.complete || HabitWidgetOperation.undo:
      final habitId = request.habitId;
      final day = request.day;
      final expectedRecord = request.expectedRecord;
      if (habitId == null || day == null || expectedRecord == null) return null;
      final uri = Uri(
        scheme: 'tablehabit-widget',
        host: request.operation.name,
        queryParameters: {
          'habitId': habitId,
          'day': day,
          'expectedRecord': expectedRecord,
        },
      );
      return HabitWidgetCommand.tryParse(uri)?.toUri();
  }
}

/// Connects the widget workflow to foreground app events and lifecycle.
final class HabitWidgetPostInitBridge
    implements AppEventSubscriber, HabitWidgetForegroundApi {
  HabitWidgetService? _service;
  AppEventBus? _events;
  DateChangeNotifier? _dateChanges;
  AppEventSubscriptions? _eventSubs;
  AppLifecycleListener? _lifecycle;
  Map<String, String>? _strings;
  bool _publishing = false;
  bool _publishPending = false;

  void sync(BuildContext context, {required L10n? l10n}) {
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

    final strings = l10n == null
        ? null
        : <String, String>{
            'today': l10n.habitDisplay_tab_today_label,
            'complete': l10n.habitDisplay_doneButton_label,
            'undo': l10n.snackbar_undoText,
            'empty': l10n.habitDisplay_emptyImage_text_01,
            'allDone': l10n.habitToday_image_desc,
            'habits': l10n.habitDisplay_tab_habits_label,
            'locale': l10n.localeName,
          };
    final stringsChanged = !mapEquals(_strings, strings);
    _strings = strings;
    if (changed || stringsChanged) _publish();
  }

  @override
  bool shouldReceive(AppEvent event) => true;

  @override
  void changed() => _onExternalChange();

  @override
  void handleEvent(AppEvent event) => switch (event) {
    ReloadDataEvent() ||
    HabitStatusChangedEvent() ||
    HabitRecordsChangedEvent() ||
    HabitDataChangedEvent() ||
    GroupChangedEvent() => _publish(),
  };

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

  void _publish() {
    if (_service == null) return;
    _publishPending = true;
    if (!_publishing) unawaited(_drainPublish());
  }

  Future<void> _drainPublish() async {
    _publishing = true;
    try {
      while (_publishPending && _service != null) {
        _publishPending = false;
        try {
          await _service!.publishSnapshot(strings: _strings);
        } catch (error, stackTrace) {
          appLog.habit.warn(
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

  void _detach() {
    _eventSubs?.cancelAll();
    _eventSubs = null;
    _dateChanges?.removeListener(_publish);
    _lifecycle?.dispose();
    _lifecycle = null;
    if (_service != null) HabitWidgetForegroundApi.setUp(null);
  }

  void dispose() {
    _detach();
    _service = null;
    _events = null;
    _dateChanges = null;
    _publishPending = false;
  }
}
