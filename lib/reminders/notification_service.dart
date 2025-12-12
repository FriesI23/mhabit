// Copyright 2023 Fries_I23
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
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../common/async.dart';
import '../common/consts.dart';
import '../common/types.dart';
import '../extensions/notification_extensions.dart';
import '../logging/helper.dart';
import '../models/app_notify_config.dart';
import '../models/habit_date.dart';
import '../models/habit_reminder.dart';
import '../reminders/notification_id_range.dart' as notifyid;
import '../utils/app_clock.dart';
import 'notification_channel.dart';
import 'notification_data.dart';
import 'notification_id_range.dart';
import 'notification_tap_handler.dart';

abstract interface class NotificationService implements AsyncInitialization {
  static NotificationService? _instance;

  FlutterLocalNotificationsPlugin get plugin;

  void onAppNotiConfigUpdate(AppNotifyConfig? config);

  Future<bool?> requestPermissions();

  Future<List<ActiveNotification>> getActiveNotifications();

  Future<List<PendingNotificationRequest>> pendingNotificationRequests();

  Future<bool> show(
      {required int id,
      required String title,
      String? body,
      String? extra,
      required NotificationDataType type,
      required NotificationChannelId channelId,
      required NotificationDetails details,
      Duration? timeout});

  Future<bool> cancel({required int id, Duration? timeout});

  Future<bool> regrAppReminderInDaily(
      {required String title,
      required String subtitle,
      required TimeOfDay timeOfDay,
      required NotificationDetails details,
      Duration? timeout});

  Future<bool> cancelAppReminder({Duration? timeout});

  Future<bool> regrHabitReminder<T>(
      {required DBID id,
      required HabitUUID uuid,
      required String name,
      String? quest,
      required HabitReminder reminder,
      required HabitDate? lastUntrackDate,
      required NotificationDetails details,
      DateTime? crtDate,
      Duration? timeout});

  Future<bool> cancelHabitReminder({required DBID id, Duration? timeout});

  Future<bool> cancelAllHabitReminders({Duration? timeout});

  Future<void> createAllChannels(NotificationAndroidChannelData data);

  factory NotificationService() {
    if (_instance != null) return _instance!;
    if (Platform.isWindows) return _instance = WindowsNotificationService();
    if (Platform.isLinux) return _instance = LinuxNotificationService();
    return _instance = NotificationServiceImpl();
  }
}

final class NotificationServiceImpl implements NotificationService {
  static const androidIconPath = "@mipmap/ic_notification";
  static const defaultTimeout = Duration(seconds: 2);

  AppNotifyConfig? _appNotifyConfig;
  late final String _logTag;

  String get logTag => _logTag;

  NotificationServiceImpl() {
    _logTag = runtimeType.toString(); // capture concrete runtime type once
  }

  @protected
  DateTime nextDailySchedule(TimeOfDay timeOfDay, DateTime now) {
    final baseDate = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final isNearToday =
        now.isAfter(baseDate) || now.difference(baseDate).inSeconds.abs() <= 5;
    return isNearToday ? baseDate.add(const Duration(days: 1)) : baseDate;
  }

  @override
  void onAppNotiConfigUpdate(AppNotifyConfig? config) =>
      _appNotifyConfig = config;

  @override
  FlutterLocalNotificationsPlugin get plugin =>
      FlutterLocalNotificationsPlugin();

  @override
  Future<List<ActiveNotification>> getActiveNotifications() =>
      plugin.getActiveNotifications();

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      plugin.pendingNotificationRequests();

  @override
  Future<void> init() async {
    // android setting
    const androidSettings = AndroidInitializationSettings(androidIconPath);

    // iOS & macOS setting
    const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false);

    // linux setting
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: "Open notification");

    // Windows setting
    WindowsInitializationSettings buildWindowsSettings() {
      switch (appFlavor) {
        case appFlavorDev:
          const appName = "Table Habit (Dev)";
          return WindowsInitializationSettings(
            appName: appName,
            appUserModelId: "Github.FriesI23.TableHabit.Dev",
            guid: const Uuid().v5(appID, appName),
          );
        // Configs Share the same value as specified in `scripts\build_msix_store.cmd`:
        // - `appName`: `pubspec.yaml#msix_config#display_name`
        // - `appUserModelId`: `dart run msix:create --identity-name`
        // - 'guid': `dart run msix:create --toast-activator-clsid`
        case appFlaborStore:
          return const WindowsInitializationSettings(
            appName: "Table Habit",
            appUserModelId: "Friesi23.TableHabit",
            guid: "b945836b-7d0d-4c60-b3fa-df184e2a9893",
          );
        default:
          // Configs Share the same value as specified in `pubspec.yaml#msix_config`:
          // - `appName`: `msix_config#display_name`
          // - `appUserModelId`: `msix_config#identity_name`
          // - `guid`: `msix_config#toast_activator#clsid`
          return const WindowsInitializationSettings(
            appName: "Table Habit",
            appUserModelId: "Github.FriesI23.TableHabit",
            guid: "03eef6f9-f653-5273-a0d6-111e2a8945b9",
          );
      }
    }

    final windowsSettins = buildWindowsSettings();

    // combine settings
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettins,
    );

    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTap,
    );
  }

  @override
  Future<bool?> requestPermissions() async {
    if (Platform.isIOS) {
      return plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: false,
            badge: true,
            sound: true,
          );
    } else if (Platform.isMacOS) {
      return plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: false,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    } else {
      return null;
    }
  }

  Future<bool?> _requestAndroidPermissions() async {
    if (!Platform.isAndroid) return false;
    final notifyPermissionRequestResult = await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (notifyPermissionRequestResult != true) return false;

    return true;
  }

  @override
  Future<bool> show(
      {required int id,
      required String title,
      String? body,
      String? extra,
      required NotificationDataType type,
      required NotificationChannelId channelId,
      required NotificationDetails details,
      Duration? timeout = defaultTimeout}) async {
    if (_appNotifyConfig?.isChannelEnabled(channelId) == false) return true;

    final data = NotificationData<String>(
      id: id,
      title: title,
      body: body,
      type: type,
      channelId: channelId,
      child: extra,
    );

    try {
      final future = plugin.show(
        data.id,
        data.title,
        data.body,
        details,
        payload: data.toPayload(),
      );

      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$logTag.show", ex: [appReminderNotifyId, data]);
    } on PlatformException catch (e) {
      appLog.notify
          .warn("$logTag.show", ex: ["show notification failed"], error: e);
      return false;
    }
    return true;
  }

  @override
  Future<bool> cancel(
      {required int id, Duration? timeout = defaultTimeout}) async {
    final future = plugin.cancel(id);
    timeout == null
        ? await future
        : future.timeout(timeout, onTimeout: () => null);
    return true;
  }

  @override
  Future<bool> regrAppReminderInDaily(
      {required String title,
      required String subtitle,
      required TimeOfDay timeOfDay,
      required NotificationDetails details,
      Duration? timeout = defaultTimeout}) async {
    try {
      if (_appNotifyConfig
              ?.isChannelEnabled(NotificationChannelId.appReminder) ==
          false) {
        return true;
      }

      final now = AppClock().now();
      final scheduledDate = nextDailySchedule(timeOfDay, now);

      final future = plugin.zonedSchedule(
        appReminderNotifyId,
        title,
        subtitle,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$logTag.regreAppReminderInDaily",
          ex: [appReminderNotifyId, title, subtitle, scheduledDate]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regreAppReminderInDaily",
          ex: ["regr app reminder failed"], error: e);
      return false;
    }

    return true;
  }

  @override
  Future<bool> cancelAppReminder({Duration? timeout = defaultTimeout}) async {
    final future = plugin.cancel(appReminderNotifyId);
    timeout == null
        ? await future
        : future.timeout(timeout, onTimeout: () => null);
    return true;
  }

  @override
  Future<bool> regrHabitReminder<T>(
      {required DBID id,
      required HabitUUID uuid,
      required String name,
      String? quest,
      required HabitReminder reminder,
      required HabitDate? lastUntrackDate,
      required NotificationDetails details,
      DateTime? crtDate,
      Duration? timeout = defaultTimeout}) async {
    try {
      final scheduledDate = reminder.getNextRemindDate(
          crtDate: crtDate, lastUntrackDate: lastUntrackDate);
      if (scheduledDate == null) return false;

      final data = NotificationData<T>(
        id: id,
        type: NotificationDataType.habitReminder,
        title: name,
        body: quest,
        channelId: NotificationChannelId.habitReminder,
        scheduledDate: scheduledDate,
      );

      final future = plugin.zonedSchedule(
        data.id,
        data.title,
        data.body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: data.toPayload(),
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$logTag.regrHabitReminder",
          ex: [data.id, scheduledDate, uuid, name, quest, data]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regrHabitReminder",
          ex: ["regr reminder failed"], error: e);
      return false;
    }

    return true;
  }

  @override
  Future<bool> cancelHabitReminder(
      {required DBID id, Duration? timeout = defaultTimeout}) async {
    final future = plugin.cancel(id);
    timeout == null
        ? await future
        : future.timeout(timeout, onTimeout: () => null);
    return true;
  }

  @override
  Future<bool> cancelAllHabitReminders(
      {Duration? timeout = defaultTimeout}) async {
    final futureList = <Future>[];
    for (var pendingReqeust in await plugin.pendingNotificationRequests()) {
      if (notifyid.isValidHabitReminderId(pendingReqeust.id)) {
        futureList.add(
          cancelHabitReminder(id: pendingReqeust.id, timeout: timeout),
        );
      }
    }
    await Future.wait(futureList);
    return true;
  }

  @override
  Future<void> createAllChannels(NotificationAndroidChannelData data) async {
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    await Future.wait(
        data.channels.map(androidPlugin.createNotificationChannelByDetail));
  }
}

/// Linux relies on in-process polling (plugin lacks native scheduling),
/// keeping an ordered queue and firing notifications on each tick.
final class LinuxNotificationService extends NotificationServiceImpl {
  static const _defaultMaxProcessPerTick = 16;
  static const _tickInterval = Duration(seconds: 1);

  LinuxNotificationService({int maxProcessPerTick = _defaultMaxProcessPerTick})
      : _maxProcessPerTick = maxProcessPerTick;

  final SplayTreeSet<_LinuxPendingNotification> _pendingQueue =
      SplayTreeSet(_LinuxPendingNotification.compare);
  final Map<int, _LinuxPendingNotification> _pendingById = {};
  final int _maxProcessPerTick;

  Timer? _ticker;

  void _cancelPending(int id) {
    final pending = _pendingById.remove(id);
    if (pending != null) _pendingQueue.remove(pending);
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _stopTickerIfIdle() {
    if (_pendingQueue.isEmpty) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  Future<void> _trigger(_LinuxPendingNotification pending) async {
    try {
      await plugin.show(
        pending.data.id,
        pending.data.title,
        pending.data.body,
        pending.details,
        payload: pending.data.toPayload(),
      );
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.show",
          ex: ["linux ticker show failed", pending.data], error: e);
    }
  }

  Future<bool> _scheduleOnce({
    required int id,
    required NotificationDetails details,
    required DateTime scheduledDate,
    required NotificationData data,
  }) async {
    final now = AppClock().now();
    if (scheduledDate.isBefore(now)) return false;

    _cancelPending(id);

    final pending = _LinuxPendingNotification(
      details: details,
      data: data,
      scheduledDate: scheduledDate,
    );

    _pendingById[id] = pending;
    _pendingQueue.add(pending);

    _ensureTicker();
    return true;
  }

  void _onTick() {
    final now = AppClock().now();
    var processed = 0;
    while (_pendingQueue.isNotEmpty && processed < _maxProcessPerTick) {
      final next = _pendingQueue.first;
      if (next.scheduledDate.isAfter(now)) break;

      _pendingQueue.remove(next);
      _pendingById.remove(next.data.id);
      _trigger(next);
      processed++;
    }

    _stopTickerIfIdle();
  }

  @override
  Future<bool> regrAppReminderInDaily(
      {required String title,
      required String subtitle,
      required TimeOfDay timeOfDay,
      required NotificationDetails details,
      Duration? timeout = NotificationServiceImpl.defaultTimeout}) async {
    try {
      if (_appNotifyConfig
              ?.isChannelEnabled(NotificationChannelId.appReminder) ==
          false) {
        return true;
      }

      final scheduledDate = nextDailySchedule(timeOfDay, AppClock().now());

      final data = NotificationData<String>(
        id: appReminderNotifyId,
        title: title,
        body: subtitle,
        type: NotificationDataType.appReminder,
        channelId: NotificationChannelId.appReminder,
      );

      final ok = await _scheduleOnce(
        id: data.id,
        details: details,
        scheduledDate: scheduledDate,
        data: data,
      );

      appLog.notify.debug("$logTag.regreAppReminderInDaily",
          ex: [data.id, title, subtitle, scheduledDate, ok]);
      return ok;
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regreAppReminderInDaily",
          ex: ["regr app reminder failed"], error: e);
      return false;
    }
  }

  @override
  Future<bool> regrHabitReminder<T>(
      {required DBID id,
      required HabitUUID uuid,
      required String name,
      String? quest,
      required HabitReminder reminder,
      required HabitDate? lastUntrackDate,
      required NotificationDetails details,
      DateTime? crtDate,
      Duration? timeout = NotificationServiceImpl.defaultTimeout}) async {
    try {
      final scheduledDate = reminder.getNextRemindDate(
          crtDate: crtDate, lastUntrackDate: lastUntrackDate);
      if (scheduledDate == null) return false;

      final data = NotificationData<T>(
        id: id,
        type: NotificationDataType.habitReminder,
        title: name,
        body: quest,
        channelId: NotificationChannelId.habitReminder,
        scheduledDate: scheduledDate,
      );

      final ok = await _scheduleOnce(
        id: data.id,
        details: details,
        scheduledDate: scheduledDate,
        data: data,
      );

      appLog.notify.debug("$logTag.regrHabitReminder",
          ex: [data.id, scheduledDate, uuid, name, quest, ok]);
      return ok;
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regrHabitReminder",
          ex: ["regr reminder failed"], error: e);
      return false;
    }
  }

  @override
  Future<bool> cancel({required int id, Duration? timeout}) async {
    _cancelPending(id);
    return super.cancel(id: id, timeout: timeout);
  }

  @override
  Future<bool> cancelAppReminder({Duration? timeout}) async {
    _cancelPending(appReminderNotifyId);
    return super.cancelAppReminder(timeout: timeout);
  }

  @override
  Future<bool> cancelHabitReminder(
      {required DBID id, Duration? timeout}) async {
    _cancelPending(id);
    return super.cancelHabitReminder(id: id, timeout: timeout);
  }

  @override
  Future<bool> cancelAllHabitReminders({Duration? timeout}) async {
    final toRemove = _pendingById.values
        .where((pending) => notifyid.isValidHabitReminderId(pending.data.id))
        .toList(growable: false);
    for (final pending in toRemove) {
      _pendingQueue.remove(pending);
      _pendingById.remove(pending.data.id);
    }
    _stopTickerIfIdle();
    return super.cancelAllHabitReminders(timeout: timeout);
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final linux = plugin.resolvePlatformSpecificImplementation<
        LinuxFlutterLocalNotificationsPlugin>();
    final map = await linux?.getSystemIdMap();
    if (map == null || map.isEmpty) return const [];
    return map.entries
        .map((e) => ActiveNotification(
            id: e.value, title: 'system:${e.key}', body: null, payload: null))
        .toList(growable: false);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      Future.value(_pendingById.values
          .map((p) => PendingNotificationRequest(
                p.data.id,
                p.data.title,
                p.data.body,
                p.data.toPayload(),
              ))
          .toList());
}

class _LinuxPendingNotification {
  _LinuxPendingNotification({
    required this.details,
    required this.data,
    required this.scheduledDate,
  });

  final NotificationDetails details;
  final NotificationData data;
  final DateTime scheduledDate;

  static int compare(_LinuxPendingNotification a, _LinuxPendingNotification b) {
    final dateDiff = a.scheduledDate.compareTo(b.scheduledDate);
    if (dateDiff != 0) return dateDiff;
    return a.data.id.compareTo(b.data.id);
  }
}

/// Use Windows-specific plugin methods for scheduling/canceling
/// to ensure toast activation works.
final class WindowsNotificationService extends NotificationServiceImpl {
  WindowsNotificationService();

  FlutterLocalNotificationsWindows get _windowsPlugin =>
      plugin.resolvePlatformSpecificImplementation<
          FlutterLocalNotificationsWindows>()!;

  /// Plugin doesn't fully support scheduling on Windows
  ///
  /// - Unsupported option arg [matchDateTimeComponents] on
  ///   [FlutterLocalNotificationsPlugin.zonedSchedule]
  /// - [id] on [FlutterLocalNotificationsPlugin.zonedSchedule] be implemented
  ///   as a tag in Windows FFI, which causes messages with same [id] can be
  ///   registered multiple times.
  ///
  /// Override uses Windows plugin APIs and pre-cancel to avoid duplicate tags.
  @override
  Future<bool> regrAppReminderInDaily(
      {required String title,
      required String subtitle,
      required TimeOfDay timeOfDay,
      required NotificationDetails details,
      Duration? timeout = NotificationServiceImpl.defaultTimeout}) async {
    try {
      if (_appNotifyConfig
              ?.isChannelEnabled(NotificationChannelId.appReminder) ==
          false) {
        return true;
      }

      final scheduledDate = nextDailySchedule(timeOfDay, AppClock().now());

      await cancel(id: appReminderNotifyId, timeout: timeout);

      final future = _windowsPlugin.zonedSchedule(
        appReminderNotifyId,
        title,
        subtitle,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details.windows,
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$logTag.regreAppReminderInDaily",
          ex: [appReminderNotifyId, title, subtitle, scheduledDate]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regreAppReminderInDaily",
          ex: ["regr app reminder failed"], error: e);
      return false;
    }

    return true;
  }

  /// Plugin doesn't fully support scheduling on Windows
  ///
  /// - Unsupported option arg [matchDateTimeComponents] on
  ///   [FlutterLocalNotificationsPlugin.zonedSchedule]
  /// - [id] on [FlutterLocalNotificationsPlugin.zonedSchedule] be implemented
  ///   as a tag in Windows FFI, which causes messages with same [id] can be
  ///   registered multiple times.
  ///
  /// Override uses Windows plugin APIs and pre-cancel to avoid duplicate tags.
  @override
  Future<bool> regrHabitReminder<T>(
      {required DBID id,
      required HabitUUID uuid,
      required String name,
      String? quest,
      required HabitReminder reminder,
      required HabitDate? lastUntrackDate,
      required NotificationDetails details,
      DateTime? crtDate,
      Duration? timeout = NotificationServiceImpl.defaultTimeout}) async {
    try {
      final scheduledDate = reminder.getNextRemindDate(
          crtDate: crtDate, lastUntrackDate: lastUntrackDate);
      if (scheduledDate == null) return false;

      final data = NotificationData<T>(
        id: id,
        type: NotificationDataType.habitReminder,
        title: name,
        body: quest,
        channelId: NotificationChannelId.habitReminder,
        scheduledDate: scheduledDate,
      );

      await cancel(id: id, timeout: timeout);

      final future = _windowsPlugin.zonedSchedule(
        data.id,
        data.title,
        data.body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details.windows,
        payload: data.toPayload(),
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$logTag.regrHabitReminder",
          ex: [data.id, scheduledDate, uuid, name, quest, data]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$logTag.regrHabitReminder",
          ex: ["regr reminder failed"], error: e);
      return false;
    }

    return true;
  }
}

final class FakeNotificationService implements NotificationService {
  const FakeNotificationService();

  @override
  FlutterLocalNotificationsPlugin get plugin =>
      throw UnsupportedError("Plugin unsupport in fake service");

  @override
  Future init() => Future.value();

  @override
  Future<List<ActiveNotification>> getActiveNotifications() => Future.value([]);

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      Future.value([]);

  @override
  Future<bool?> requestPermissions() => Future.value(false);

  @override
  Future<bool> show(
          {required int id,
          required String title,
          String? body,
          String? extra,
          required NotificationDataType type,
          required NotificationChannelId channelId,
          required NotificationDetails details,
          Duration? timeout}) =>
      Future.value(false);

  @override
  Future<bool> cancel({required int id, Duration? timeout}) =>
      Future.value(false);

  @override
  Future<bool> cancelAllHabitReminders({Duration? timeout}) =>
      Future.value(false);

  @override
  Future<bool> cancelAppReminder({Duration? timeout}) => Future.value(false);

  @override
  Future<bool> cancelHabitReminder({required DBID id, Duration? timeout}) =>
      Future.value(false);

  @override
  Future<bool> regrHabitReminder<T>(
          {required DBID id,
          required HabitUUID uuid,
          required String name,
          String? quest,
          required HabitReminder reminder,
          required HabitDate? lastUntrackDate,
          required NotificationDetails details,
          DateTime? crtDate,
          Duration? timeout}) =>
      Future.value(false);

  @override
  Future<bool> regrAppReminderInDaily(
          {required String title,
          required String subtitle,
          required TimeOfDay timeOfDay,
          required NotificationDetails details,
          Duration? timeout}) =>
      Future.value(false);

  @override
  Future<void> createAllChannels(NotificationAndroidChannelData data) =>
      Future.value(null);

  @override
  void onAppNotiConfigUpdate(AppNotifyConfig? config) {}
}
