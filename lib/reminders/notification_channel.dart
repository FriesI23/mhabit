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

@JsonEnum(valueField: "id")
enum NotificationChannelId {
  debug(
    id: 1,
    channelName: "Debug channel",
    category: "debug",
  ),
  habitReminder(
    id: 2,
    channelName: "Habit reminder channel",
    category: "habit_reminder",
  ),
  appReminder(
    id: 3,
    channelName: "Prompt",
    category: "app_reminder",
  ),
  appDebugger(
    id: 4,
    channelName: "Debugger",
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
  final AndroidNotificationDetails? _debug;
  final AndroidNotificationDetails? _habitReminder;
  final AndroidNotificationDetails? _appReminder;
  final AndroidNotificationDetails? _appDebugger;

  const NotificationAndroidChannelData({
    AndroidNotificationDetails? debug,
    AndroidNotificationDetails? habitReminder,
    AndroidNotificationDetails? appReminder,
    AndroidNotificationDetails? appDebugger,
  })  : _debug = debug,
        _habitReminder = habitReminder,
        _appReminder = appReminder,
        _appDebugger = appDebugger;

  @override
  AndroidNotificationDetails get debug =>
      _debug ??
      AndroidNotificationDetails(
        _getChannelId(NotificationChannelId.debug.name),
        NotificationChannelId.debug.channelName,
        importance: Importance.min,
        priority: Priority.low,
      );

  @override
  AndroidNotificationDetails get habitReminder =>
      _habitReminder ??
      AndroidNotificationDetails(
        _getChannelId(NotificationChannelId.habitReminder.name),
        NotificationChannelId.habitReminder.channelName,
        importance: Importance.high,
        priority: Priority.defaultPriority,
      );

  @override
  AndroidNotificationDetails get appReminder =>
      _appReminder ??
      AndroidNotificationDetails(
        _getChannelId(NotificationChannelId.appReminder.name),
        NotificationChannelId.appReminder.channelName,
        importance: Importance.high,
        priority: Priority.high,
      );

  @override
  AndroidNotificationDetails get appDebugger =>
      _appDebugger ??
      AndroidNotificationDetails(
        _getChannelId(NotificationChannelId.appDebugger.name),
        NotificationChannelId.appDebugger.channelName,
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        autoCancel: false,
        showWhen: false,
        silent: true,
        color: Colors.red,
        colorized: true,
      );
}

class NotificationIosChannelData
    implements NotificationChannelDataABC<DarwinNotificationDetails> {
  final DarwinNotificationDetails? _debug;
  final DarwinNotificationDetails? _habitReminder;
  final DarwinNotificationDetails? _appReminder;
  final DarwinNotificationDetails? _appDebugger;

  const NotificationIosChannelData({
    DarwinNotificationDetails? debug,
    DarwinNotificationDetails? habitReminder,
    DarwinNotificationDetails? appReminder,
    DarwinNotificationDetails? appDebugger,
  })  : _debug = debug,
        _habitReminder = habitReminder,
        _appReminder = appReminder,
        _appDebugger = appDebugger;

  @override
  DarwinNotificationDetails get appReminder =>
      _appReminder ??
      DarwinNotificationDetails(
        categoryIdentifier: NotificationChannelId.appReminder.category,
      );

  @override
  DarwinNotificationDetails get debug =>
      _debug ??
      DarwinNotificationDetails(
          categoryIdentifier: NotificationChannelId.debug.category);

  @override
  DarwinNotificationDetails get habitReminder =>
      _habitReminder ??
      DarwinNotificationDetails(
          categoryIdentifier: NotificationChannelId.habitReminder.category);

  @override
  DarwinNotificationDetails get appDebugger =>
      _appDebugger ??
      DarwinNotificationDetails(
          presentSound: false,
          categoryIdentifier: NotificationChannelId.appDebugger.category,
          interruptionLevel: InterruptionLevel.passive);
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

class NotificationChannelData extends ChangeNotifier
    implements NotificationChannelDataABC<NotificationDetails> {
  final NotificationAndroidChannelData _androidChannel;
  final NotificationIosChannelData _iosChannel;
  final NotificationLinuxChannelData _linuxChannel;

  NotificationChannelData({
    NotificationAndroidChannelData? androidChannel,
    NotificationIosChannelData? iosChannel,
    NotificationLinuxChannelData? linuxChannel,
  })  : _androidChannel =
            androidChannel ?? const NotificationAndroidChannelData(),
        _iosChannel = iosChannel ?? const NotificationIosChannelData(),
        _linuxChannel = linuxChannel ?? const NotificationLinuxChannelData();

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
