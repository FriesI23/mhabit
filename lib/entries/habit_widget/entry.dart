// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import '../../common/app_info.dart';
import '../../logging/helper.dart';
import '../../logging/logger_manager.dart';
import '../../models/habit_widget.dart';
import '../../providers/workflow/app_notify_config.dart';
import '../../providers/workflow/habit_widget.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_service.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/profile/handlers/app_notify_config.dart';
import '../../storage/profile_provider.dart';
import '../../utils/local_timezone.dart';
import 'habit_widget_api.g.dart';

/// Initializes the dedicated background engine and installs its action channel.
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

/// Adapts typed native requests to the serialized Dart workflow.
final class HabitWidgetBackgroundChannel implements HabitWidgetBackgroundApi {
  final Future<HabitWidgetActionResponse> Function(Uri uri) _perform;
  final HabitWidgetHostApi _hostApi;

  /// Creates a channel using [hostApi] for the readiness handshake.
  HabitWidgetBackgroundChannel(this._perform, {HabitWidgetHostApi? hostApi})
    : _hostApi = hostApi ?? HabitWidgetHostApi();

  /// Installs the request handler before acknowledging native readiness.
  Future<void> start() async {
    HabitWidgetBackgroundApi.setUp(this);
    await _hostApi.ready();
  }

  /// Validates transport input and returns the completed workflow outcome.
  @override
  Future<HabitWidgetResponse> perform(HabitWidgetRequest request) async {
    final uri = _widgetRequestUri(request);
    if (uri == null) {
      return HabitWidgetResponse(
        outcome: HabitWidgetResult.invalid,
        snapshotPublished: false,
      );
    }
    try {
      final response = await _perform(uri);
      final outcome = switch (response.outcome) {
        HabitWidgetActionResult.applied => HabitWidgetResult.applied,
        HabitWidgetActionResult.unchanged => HabitWidgetResult.unchanged,
        HabitWidgetActionResult.stale => HabitWidgetResult.stale,
        HabitWidgetActionResult.invalid => HabitWidgetResult.invalid,
        HabitWidgetActionResult.failed => HabitWidgetResult.failed,
      };
      return HabitWidgetResponse(
        outcome: outcome,
        snapshotPublished: response.snapshotPublished,
        recordVersion: response.recordVersion,
        committedAt: response.committedAt?.toUtc().toIso8601String(),
      );
    } catch (error, stackTrace) {
      appLog.habitWidget.error(
        'HabitWidgetBackgroundChannel.perform',
        error: error,
        stackTrace: stackTrace,
      );
      return HabitWidgetResponse(
        outcome: HabitWidgetResult.failed,
        snapshotPublished: false,
      );
    }
  }

  /// Removes the background request handler from its messenger.
  void dispose() => HabitWidgetBackgroundApi.setUp(null);
}

/// Converts validated transport fields into the internal command format.
Uri? _widgetRequestUri(HabitWidgetRequest request) {
  switch (request.operation) {
    case HabitWidgetOperation.refresh:
      if (request.source != null ||
          request.habitId != null ||
          request.day != null ||
          request.expectedRecord != null) {
        return null;
      }
      return Uri(scheme: 'tablehabit-widget', host: 'refresh');
    case HabitWidgetOperation.complete || HabitWidgetOperation.undo:
      final habitId = request.habitId;
      final day = request.day;
      final expectedRecord = request.expectedRecord;
      if (habitId == null ||
          day == null ||
          expectedRecord == null ||
          request.source == null) {
        return null;
      }
      final uri = Uri(
        scheme: 'tablehabit-widget',
        host: request.operation.name,
        queryParameters: {
          'source': request.source!.name,
          'habitId': habitId,
          'day': day,
          'expectedRecord': expectedRecord,
        },
      );
      return HabitWidgetCommand.tryParse(uri)?.toUri();
  }
}
