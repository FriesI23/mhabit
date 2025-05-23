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

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/app_info.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import 'notification_service.dart';

@JsonEnum(valueField: "id")
enum NotificationChannelId {
  debug(
    id: 1,
    channelName: "_Dev",
    category: "debug",
  ),
  habitReminder(
    id: 2,
    channelName: "Habit Reminder Channel",
    category: "habit_reminder",
  ),
  appReminder(
    id: 3,
    channelName: "Prompt Channel",
    category: "app_reminder",
  ),
  appDebugger(
    id: 4,
    channelName: "Debugger Channel",
    category: "app_debugger",
  );

  final int id;
  final String channelName;
  final String category;

  const NotificationChannelId({
    required this.id,
    required this.channelName,
    required this.category,
  });
}

String _getChannelId(String channelId) {
  return [AppInfo().packageName, 'notifications', channelId].join('.');
}

abstract class NotificationChannelDataABC<T> {
  T get debug;
  T get habitReminder;
  T get appReminder;
  T get appDebugger;
}

class NotificationAndroidChannelData
    implements NotificationChannelDataABC<AndroidNotificationDetails> {
  @override
  final AndroidNotificationDetails debug;
  @override
  final AndroidNotificationDetails habitReminder;
  @override
  final AndroidNotificationDetails appReminder;
  @override
  final AndroidNotificationDetails appDebugger;

  final L10n? l10n;

  NotificationAndroidChannelData({
    this.l10n,
    AndroidNotificationDetails? debug,
    AndroidNotificationDetails? habitReminder,
    AndroidNotificationDetails? appReminder,
    AndroidNotificationDetails? appDebugger,
  })  : debug = debug ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.debug.name),
              NotificationChannelId.debug.channelName,
              importance: Importance.min,
              priority: Priority.low,
            ),
        habitReminder = habitReminder ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.habitReminder.name),
              l10n?.channelName_habitReminder ??
                  NotificationChannelId.habitReminder.channelName,
              importance: Importance.high,
              priority: Priority.defaultPriority,
            ),
        appReminder = appReminder ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.appReminder.name),
              l10n?.channelName_appReminder ??
                  NotificationChannelId.appReminder.channelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
        appDebugger = appDebugger ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.appDebugger.name),
              l10n?.channelName_appDebugger ??
                  NotificationChannelId.appDebugger.channelName,
              importance: Importance.max,
              priority: Priority.max,
              playSound: false,
              autoCancel: false,
              showWhen: false,
              ongoing: true,
              silent: true,
              color: Colors.red,
              colorized: true,
            );

  Iterable<AndroidNotificationDetails> get channels => [
        // debug,
        habitReminder,
        appReminder,
        appDebugger,
      ];

  @override
  String toString() => "NotificationAndroidChannelData("
      "debug: $debug, "
      "habitReminder: $habitReminder, "
      "appReminder: $appReminder, "
      "appDebugger: $appDebugger, "
      "l10n: $l10n"
      ")";
}

class NotificationIosChannelData
    implements NotificationChannelDataABC<DarwinNotificationDetails> {
  @override
  final DarwinNotificationDetails debug;
  @override
  final DarwinNotificationDetails habitReminder;
  @override
  final DarwinNotificationDetails appReminder;
  @override
  final DarwinNotificationDetails appDebugger;

  NotificationIosChannelData({
    DarwinNotificationDetails? debug,
    DarwinNotificationDetails? habitReminder,
    DarwinNotificationDetails? appReminder,
    DarwinNotificationDetails? appDebugger,
  })  : debug = debug ??
            DarwinNotificationDetails(
              categoryIdentifier: NotificationChannelId.debug.category,
            ),
        habitReminder = habitReminder ??
            DarwinNotificationDetails(
              categoryIdentifier: NotificationChannelId.habitReminder.category,
            ),
        appReminder = appReminder ??
            DarwinNotificationDetails(
              categoryIdentifier: NotificationChannelId.appReminder.category,
            ),
        appDebugger = appDebugger ??
            DarwinNotificationDetails(
              presentSound: false,
              categoryIdentifier: NotificationChannelId.appDebugger.category,
              interruptionLevel: InterruptionLevel.passive,
            );
}

class NotificationLinuxChannelData
    implements NotificationChannelDataABC<LinuxNotificationDetails> {
  final LinuxNotificationDetails? _debug;
  final LinuxNotificationDetails? _habitReminder;
  final LinuxNotificationDetails? _appReminder;
  final LinuxNotificationDetails? _appDebugger;

  const NotificationLinuxChannelData({
    LinuxNotificationDetails? debug,
    LinuxNotificationDetails? habitReminder,
    LinuxNotificationDetails? appReminder,
    LinuxNotificationDetails? appDebugger,
  })  : _debug = debug,
        _habitReminder = habitReminder,
        _appReminder = appReminder,
        _appDebugger = appDebugger;

  @override
  LinuxNotificationDetails get debug =>
      _debug ?? const LinuxNotificationDetails();

  @override
  LinuxNotificationDetails get habitReminder =>
      _habitReminder ?? const LinuxNotificationDetails();

  @override
  LinuxNotificationDetails get appReminder =>
      _appReminder ?? const LinuxNotificationDetails();

  @override
  LinuxNotificationDetails get appDebugger =>
      _appDebugger ?? const LinuxNotificationDetails();
}

class NotificationChannelData
    implements NotificationChannelDataABC<NotificationDetails> {
  NotificationAndroidChannelData _androidChannel;
  final NotificationIosChannelData _iosChannel;
  final NotificationLinuxChannelData _linuxChannel;

  NotificationChannelData({
    NotificationAndroidChannelData? androidChannel,
    NotificationIosChannelData? iosChannel,
    NotificationLinuxChannelData? linuxChannel,
  })  : _androidChannel = androidChannel ?? NotificationAndroidChannelData(),
        _iosChannel = iosChannel ?? NotificationIosChannelData(),
        _linuxChannel = linuxChannel ?? const NotificationLinuxChannelData();

  void onL10nUpdate(L10n? l10n) async {
    appLog.notify.info("NotificationChannelData.onL10nUpdate",
        ex: [_androidChannel.l10n, l10n]);
    if (_androidChannel.l10n == l10n) return;

    final oldAndroidChannelData = _androidChannel;
    _androidChannel = NotificationAndroidChannelData(l10n: l10n);

    await NotificationService().createAllChannels(_androidChannel);
    appLog.value.info("NotificationChannelData.onL10nUpdate",
        beforeVal: oldAndroidChannelData,
        afterVal: _androidChannel,
        ex: ["Done: Android", l10n]);
  }

  @override
  NotificationDetails get debug => NotificationDetails(
        android: _androidChannel.debug,
        iOS: _iosChannel.debug,
        linux: _linuxChannel.debug,
        macOS: _iosChannel.debug,
      );

  @override
  NotificationDetails get habitReminder => NotificationDetails(
        android: _androidChannel.habitReminder,
        iOS: _iosChannel.habitReminder,
        linux: _linuxChannel.habitReminder,
        macOS: _iosChannel.debug,
      );

  @override
  NotificationDetails get appReminder => NotificationDetails(
        android: _androidChannel.appReminder,
        iOS: _iosChannel.appReminder,
        linux: _linuxChannel.appReminder,
        macOS: _iosChannel.appReminder,
      );

  @override
  NotificationDetails get appDebugger => NotificationDetails(
        android: _androidChannel.appDebugger,
        iOS: _iosChannel.appDebugger,
        linux: _linuxChannel.appReminder,
        macOS: _iosChannel.appDebugger,
      );
}
