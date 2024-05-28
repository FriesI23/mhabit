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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../common/async.dart';
import '../common/types.dart';
import '../logging/helper.dart';
import '../model/habit_date.dart';
import '../model/habit_reminder.dart';
import '../reminders/notification_id_range.dart' as notifyid;
import 'notification_channel.dart';
import 'notification_data.dart';
import 'notification_id_range.dart';
import 'notification_tap_handler.dart';

abstract interface class NotificationService implements AsyncInitialization {
  static NotificationService? _instance;

  Future<bool?> requestPermissions();

  Future<List<ActiveNotification>> getActiveNotifications();

  Future<List<PendingNotificationRequest>> pendingNotificationRequests();

  Future<bool> show(
      {required int id,
      required String title,
      String? body,
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

  factory NotificationService() {
    if (_instance != null) return _instance!;
    if (Platform.isWindows) return _instance = const FakeNotificationService();
    if (Platform.isLinux) return _instance = const LinuxNotificationService();
    return _instance = const NotificationServiceImpl();
  }
}

final class NotificationServiceImpl implements NotificationService {
  static const androidIconPath = "@mipmap/ic_notification";
  static const defaultTimeout = Duration(seconds: 2);

  const NotificationServiceImpl();

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
    final darwinSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          NotificationChannelId.debug.category,
        ),
        DarwinNotificationCategory(
          NotificationChannelId.habitReminder.category,
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
        DarwinNotificationCategory(
          NotificationChannelId.appReminder.category,
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.allowAnnouncement,
          },
        ),
        DarwinNotificationCategory(
          NotificationChannelId.appDebugger.category,
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            DarwinNotificationCategoryOption.hiddenPreviewShowSubtitle,
          },
        ),
      ],
    );

    // linux setting
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: "Open notification");

    // combine settings
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
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
      required NotificationDataType type,
      required NotificationChannelId channelId,
      required NotificationDetails details,
      Duration? timeout = defaultTimeout}) async {
    final data = NotificationData(
      id: id,
      title: title,
      body: body,
      type: type,
      channelId: channelId,
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

      appLog.notify.debug("$runtimeType.show", ex: [appReminderNotifyId, data]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$runtimeType.show",
          ex: ["show notification failed"], error: e);
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
      final now = DateTime.now();
      final scheduledDate = DateTime(
          now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

      final future = plugin.zonedSchedule(
        appReminderNotifyId,
        title,
        subtitle,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$runtimeType.regreAppReminderInDaily",
          ex: [appReminderNotifyId, title, subtitle, scheduledDate]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$runtimeType.regreAppReminderInDaily",
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: data.toPayload(),
      );
      timeout == null
          ? await future
          : await future.timeout(timeout, onTimeout: () => null);

      appLog.notify.debug("$runtimeType.regrHabitReminder",
          ex: [data.id, scheduledDate, uuid, name, quest, data]);
    } on PlatformException catch (e) {
      appLog.notify.warn("$runtimeType.regrHabitReminder",
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
}

final class LinuxNotificationService extends NotificationServiceImpl {
  const LinuxNotificationService();

  //TODO: Lame implementation; plugin doesn't support scheduling on Linux,
  //      need to find some solutions.
  @override
  Future<bool> regrAppReminderInDaily(
          {required String title,
          required String subtitle,
          required TimeOfDay timeOfDay,
          required NotificationDetails details,
          Duration? timeout = NotificationServiceImpl.defaultTimeout}) =>
      Future.value(false);

  //TODO: Lame implementation; plugin doesn't support scheduling on Linux,
  //      need to find some solutions.
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
          Duration? timeout = NotificationServiceImpl.defaultTimeout}) =>
      Future.value(false);
}

final class FakeNotificationService implements NotificationService {
  const FakeNotificationService();

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
}
