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

class NotificationService implements AsyncInitialization {
  //#region singleton
  static final NotificationService _singleton = NotificationService._internal();

  NotificationService._internal();

  factory NotificationService() => _singleton;
  //#endregion

  static const androidIconPath = "@mipmap/ic_launcher";

  FlutterLocalNotificationsPlugin get plugin =>
      FlutterLocalNotificationsPlugin();

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
      ],
    );

    // combine settings
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await plugin.initialize(initializationSettings);
  }

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

  Future<void> show({
    required int id,
    required String title,
    String? body,
    required NotificationDataType type,
    required NotificationChannelId channelId,
    required NotificationDetails details,
  }) async {
    final data = NotificationData(
      id: id,
      title: title,
      body: body,
      type: type,
      channelId: channelId,
    );

    return plugin.show(
      data.id,
      data.title,
      data.body,
      details,
      payload: data.toPayload(),
    );
  }
}

extension NotificationServiceWithApp on NotificationService {
  static const _kDefaultTimeout = Duration(seconds: 2);

  Future<bool> regreAppReminderInDaily({
    required String title,
    required String subtitle,
    required TimeOfDay timeOfDay,
    required NotificationDetails details,
    Duration? timeout = _kDefaultTimeout,
  }) async {
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

  Future<bool> cancelAppReminder({Duration? timeout = _kDefaultTimeout}) async {
    final future = plugin.cancel(appReminderNotifyId);
    timeout == null
        ? await future
        : future.timeout(timeout, onTimeout: () => null);
    return true;
  }
}

extension NotificationServiceWithHabits on NotificationService {
  static const _kDefaultTimeout = Duration(seconds: 2);

  Future<bool> regrHabitReminder<T>({
    required DBID id,
    required HabitUUID uuid,
    required String name,
    String? quest,
    required HabitReminder reminder,
    required HabitDate? lastUntrackDate,
    required NotificationDetails details,
    DateTime? crtDate,
    Duration? timeout = _kDefaultTimeout,
  }) async {
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

  Future<bool> cancelHabitReminder({
    required DBID id,
    Duration? timeout = _kDefaultTimeout,
  }) async {
    final future = plugin.cancel(id);
    timeout == null
        ? await future
        : future.timeout(timeout, onTimeout: () => null);
    return true;
  }

  Future<bool> cancelAllHabitReminders({
    Duration? eachTimeout = _kDefaultTimeout,
  }) async {
    final futureList = <Future>[];
    for (var pendingReqeust in await plugin.pendingNotificationRequests()) {
      if (notifyid.isValidHabitReminderId(pendingReqeust.id)) {
        futureList.add(
          cancelHabitReminder(id: pendingReqeust.id, timeout: eachTimeout),
        );
      }
    }
    await Future.wait(futureList);
    return true;
  }
}
