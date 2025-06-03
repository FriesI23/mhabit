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
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide
        AndroidNotificationDetails,
        DarwinNotificationDetails,
        LinuxNotificationDetails,
        WindowsNotificationDetails;
import 'package:json_annotation/json_annotation.dart';

import '../common/app_info.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import 'notification_details.dart';
import 'notification_service.dart';

@JsonEnum(valueField: "id")
enum NotificationChannelId {
  debug(
    id: 1,
    channelName: "_Dev",
    identity: "debug",
  ),
  habitReminder(
    id: 2,
    channelName: "Habit Reminder Channel",
    identity: "habit_reminder",
  ),
  appReminder(
    id: 3,
    channelName: "Prompt Channel",
    identity: "app_reminder",
  ),
  appDebugger(
    id: 4,
    channelName: "Debugger Channel",
    identity: "app_debugger",
  ),
  appSyncing(
    id: 5,
    channelName: "App Syncing Channel",
    identity: "app_syncing",
  ),
  appSyncFailed(
    id: 6,
    channelName: "App Sync Failed",
    identity: "app_sync_failed",
  );

  final int id;
  final String channelName;
  final String identity;

  const NotificationChannelId({
    required this.id,
    required this.channelName,
    required this.identity,
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
  T get appSyncing;
  T get appSyncFailed;
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
  @override
  final AndroidNotificationDetails appSyncing;
  @override
  final AndroidNotificationDetails appSyncFailed;

  final L10n? l10n;

  NotificationAndroidChannelData({
    this.l10n,
    AndroidNotificationDetails? debug,
    AndroidNotificationDetails? habitReminder,
    AndroidNotificationDetails? appReminder,
    AndroidNotificationDetails? appDebugger,
    AndroidNotificationDetails? appSyncing,
    AndroidNotificationDetails? appSyncFailed,
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
            ),
        appSyncing = appSyncing ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.appSyncing.name),
              l10n?.channelName_appSyncing ??
                  NotificationChannelId.appSyncing.channelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
        appSyncFailed = appSyncFailed ??
            AndroidNotificationDetails(
              _getChannelId(NotificationChannelId.appSyncFailed.name),
              l10n?.channelName_appSyncFailed ??
                  NotificationChannelId.appSyncFailed.channelName,
              importance: Importance.high,
              priority: Priority.high,
            );

  Iterable<AndroidNotificationDetails> get channels => [
        // debug,
        habitReminder,
        appReminder,
        appDebugger,
        appSyncing,
        appSyncFailed,
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
  @override
  final DarwinNotificationDetails appSyncing;
  @override
  final DarwinNotificationDetails appSyncFailed;

  NotificationIosChannelData({
    DarwinNotificationDetails? debug,
    DarwinNotificationDetails? habitReminder,
    DarwinNotificationDetails? appReminder,
    DarwinNotificationDetails? appDebugger,
    DarwinNotificationDetails? appSyncing,
    DarwinNotificationDetails? appSyncFailed,
  })  : debug = debug ??
            DarwinNotificationDetails(
              threadIdentifier: NotificationChannelId.debug.identity,
            ),
        habitReminder = habitReminder ??
            DarwinNotificationDetails(
              threadIdentifier: NotificationChannelId.habitReminder.identity,
            ),
        appReminder = appReminder ??
            DarwinNotificationDetails(
              threadIdentifier: NotificationChannelId.appReminder.identity,
            ),
        appDebugger = appDebugger ??
            DarwinNotificationDetails(
              presentSound: false,
              threadIdentifier: NotificationChannelId.appDebugger.identity,
              interruptionLevel: InterruptionLevel.passive,
            ),
        appSyncing = appSyncing ??
            DarwinNotificationDetails(
              presentSound: false,
              threadIdentifier: NotificationChannelId.appSyncing.identity,
              interruptionLevel: InterruptionLevel.passive,
            ),
        appSyncFailed = appSyncFailed ??
            DarwinNotificationDetails(
              presentSound: false,
              threadIdentifier: NotificationChannelId.appSyncFailed.identity,
            );
}

class NotificationLinuxChannelData
    implements NotificationChannelDataABC<LinuxNotificationDetails> {
  @override
  final LinuxNotificationDetails debug;
  @override
  final LinuxNotificationDetails habitReminder;
  @override
  final LinuxNotificationDetails appReminder;
  @override
  final LinuxNotificationDetails appDebugger;
  @override
  final LinuxNotificationDetails appSyncing;
  @override
  final LinuxNotificationDetails appSyncFailed;

  const NotificationLinuxChannelData({
    LinuxNotificationDetails? debug,
    LinuxNotificationDetails? habitReminder,
    LinuxNotificationDetails? appReminder,
    LinuxNotificationDetails? appDebugger,
    LinuxNotificationDetails? appSyncing,
    LinuxNotificationDetails? appSyncFailed,
  })  : debug = debug ?? const LinuxNotificationDetails(),
        habitReminder = habitReminder ?? const LinuxNotificationDetails(),
        appReminder = appReminder ?? const LinuxNotificationDetails(),
        appDebugger = appDebugger ?? const LinuxNotificationDetails(),
        appSyncing = appSyncing ?? const LinuxNotificationDetails(),
        appSyncFailed = appSyncFailed ?? const LinuxNotificationDetails();
}

class NotificationWindowsChannelData
    implements NotificationChannelDataABC<WindowsNotificationDetails> {
  @override
  final WindowsNotificationDetails debug;
  @override
  final WindowsNotificationDetails habitReminder;
  @override
  final WindowsNotificationDetails appReminder;
  @override
  final WindowsNotificationDetails appDebugger;
  @override
  final WindowsNotificationDetails appSyncing;
  @override
  final WindowsNotificationDetails appSyncFailed;

  const NotificationWindowsChannelData({
    WindowsNotificationDetails? debug,
    WindowsNotificationDetails? habitReminder,
    WindowsNotificationDetails? appReminder,
    WindowsNotificationDetails? appDebugger,
    WindowsNotificationDetails? appSyncing,
    WindowsNotificationDetails? appSyncFailed,
  })  : debug = debug ?? const WindowsNotificationDetails(),
        habitReminder = habitReminder ?? const WindowsNotificationDetails(),
        appReminder = appReminder ?? const WindowsNotificationDetails(),
        appDebugger = appDebugger ?? const WindowsNotificationDetails(),
        appSyncing = appSyncing ?? const WindowsNotificationDetails(),
        appSyncFailed = appSyncFailed ?? const WindowsNotificationDetails();
}

class NotificationChannelData
    implements NotificationChannelDataABC<NotificationDetails> {
  NotificationAndroidChannelData _androidChannel;
  final NotificationIosChannelData _iosChannel;
  final NotificationLinuxChannelData _linuxChannel;
  final NotificationWindowsChannelData _windowsChannel;

  NotificationChannelData({
    NotificationAndroidChannelData? androidChannel,
    NotificationIosChannelData? iosChannel,
    NotificationLinuxChannelData? linuxChannel,
    NotificationWindowsChannelData? windowsChannel,
  })  : _androidChannel = androidChannel ?? NotificationAndroidChannelData(),
        _iosChannel = iosChannel ?? NotificationIosChannelData(),
        _linuxChannel = linuxChannel ?? const NotificationLinuxChannelData(),
        _windowsChannel =
            windowsChannel ?? const NotificationWindowsChannelData();

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
        windows: _windowsChannel.debug,
      );

  @override
  NotificationDetails get habitReminder => NotificationDetails(
        android: _androidChannel.habitReminder,
        iOS: _iosChannel.habitReminder,
        linux: _linuxChannel.habitReminder,
        macOS: _iosChannel.habitReminder,
        windows: _windowsChannel.habitReminder,
      );

  @override
  NotificationDetails get appReminder => NotificationDetails(
        android: _androidChannel.appReminder,
        iOS: _iosChannel.appReminder,
        linux: _linuxChannel.appReminder,
        macOS: _iosChannel.appReminder,
        windows: _windowsChannel.appReminder,
      );

  @override
  NotificationDetails get appDebugger => NotificationDetails(
        android: _androidChannel.appDebugger,
        iOS: _iosChannel.appDebugger,
        linux: _linuxChannel.appDebugger,
        macOS: _iosChannel.appDebugger,
        windows: _windowsChannel.appDebugger,
      );

  @override
  NotificationDetails get appSyncing => NotificationDetails(
        android: _androidChannel.appSyncing,
        iOS: _iosChannel.appSyncing,
        linux: _linuxChannel.appSyncing,
        macOS: _iosChannel.appSyncing,
        windows: _windowsChannel.appSyncing,
      );

  @override
  NotificationDetails get appSyncFailed => NotificationDetails(
        android: _androidChannel.appSyncFailed,
        iOS: _iosChannel.appSyncFailed,
        linux: _linuxChannel.appSyncFailed,
        macOS: _iosChannel.appSyncFailed,
        windows: _windowsChannel.appSyncFailed,
      );
}
