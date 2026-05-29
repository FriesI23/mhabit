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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/app_reminder_config.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_details.dart';
import '../../reminders/notification_service.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';
import '../support/commons.dart';
import 'app_notify_config.dart';

final class _AppReminderRuntime {
  final NotificationService _notificationService;

  _AppReminderRuntime({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  Future<bool?> requestNotificationPermissions() =>
      _notificationService.requestPermissions();

  Future<bool> applyReminder(
    AppReminderConfig reminder, {
    required L10n? l10n,
    required NotificationDetails details,
  }) async {
    if (!(reminder.enabled && l10n != null)) {
      await _notificationService.cancelAppReminder();
      return true;
    }

    switch (reminder.type) {
      case AppReminderConfigType.daily:
        if (reminder.timeOfDay != null) {
          await _notificationService.regrAppReminderInDaily(
            title: l10n.appReminder_dailyReminder_title,
            subtitle: l10n.appReminder_dailyReminder_body,
            timeOfDay: reminder.timeOfDay!,
            details: details,
          );
        }
        return true;
    }
  }
}

enum AppReminderTriggerReason { startup, settings }

final class AppReminderTrigger {
  final AppReminderTriggerReason reason;
  final AppReminderConfig? nextReminder;

  const AppReminderTrigger._({required this.reason, this.nextReminder});

  const AppReminderTrigger.startup()
    : this._(reason: AppReminderTriggerReason.startup);

  const AppReminderTrigger.settings(AppReminderConfig nextReminder)
    : this._(
        reason: AppReminderTriggerReason.settings,
        nextReminder: nextReminder,
      );
}

abstract interface class AppReminderAccess implements Listenable {
  AppReminderConfig get reminder;
  bool get isChannelEnabled;

  Future<bool?> requestReminderPermission();

  Future<void> processTrigger(AppReminderTrigger trigger, {L10n? l10n});

  // Keep L10n as a boundary input here until a real blocker proves reminder
  // content building must split from execution.
  Future<bool> processReminder(L10n? l10n);
}

final class AppReminderOwner extends ChangeNotifier
    with NotificationChannelDataMixin, ProfileHandlerLoadedMixin
    implements AppReminderAccess {
  AppReminderProfileHandler? _rmd;
  AppNotifyConfigAccess? _notifyConfig;
  final _AppReminderRuntime _reminderRuntime;

  AppReminderOwner({NotificationService? notificationService})
    : _reminderRuntime = _AppReminderRuntime(
        notificationService: notificationService,
      );

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _rmd = newProfile.getHandler<AppReminderProfileHandler>();
  }

  void attachNotifyConfig(AppNotifyConfigAccess access) {
    if (identical(_notifyConfig, access)) return;
    _notifyConfig?.removeListener(notifyListeners);
    _notifyConfig = access;
    access.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _notifyConfig?.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  AppReminderConfig get reminder => _rmd?.get() ?? defaultAppReminder;

  @override
  bool get isChannelEnabled =>
      _notifyConfig?.isChannelEnabled(NotificationChannelId.appReminder) ??
      true;

  @override
  Future<bool?> requestReminderPermission() =>
      _reminderRuntime.requestNotificationPermissions();

  @override
  Future<void> processTrigger(AppReminderTrigger trigger, {L10n? l10n}) async {
    switch (trigger.reason) {
      case AppReminderTriggerReason.startup:
        await processReminder(l10n);
      case AppReminderTriggerReason.settings:
        await _updateReminder(trigger.nextReminder!, l10n: l10n);
    }
  }

  Future<void> _updateReminder(
    AppReminderConfig newReminder, {
    L10n? l10n,
  }) async {
    final reminder = this.reminder;
    if (reminder == newReminder) return;
    appLog.value.info(
      '$runtimeType.updateReminder',
      beforeVal: reminder,
      afterVal: newReminder,
      ex: [l10n],
    );
    await _rmd?.set(newReminder);
    if (!await _handleChangeReminder(l10n)) notifyListeners();
  }

  Future<bool> _handleChangeReminder(L10n? l10n) async {
    if ((await processReminder(l10n)) != true) {
      appLog.value.info(
        '$runtimeType._handleChangeReminder',
        beforeVal: reminder.enabled,
        afterVal: false,
        ex: [l10n],
      );
      await _rmd?.set(reminder.copyWith(enabled: false));
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Future<bool> processReminder(L10n? l10n) async {
    final reminder = this.reminder;
    if (reminder.enabled && l10n != null) {
      if (!isChannelEnabled) return true;
      if (await requestReminderPermission() == false) return false;
    }

    return _reminderRuntime.applyReminder(
      reminder,
      l10n: l10n,
      details: channelData.appReminder,
    );
  }
}

class AppReminderViewModel extends ChangeNotifier {
  AppReminderAccess? _access;

  void attachAccess(AppReminderAccess access) {
    if (identical(_access, access)) return;
    _access?.removeListener(notifyListeners);
    _access = access;
    access.addListener(notifyListeners);
    notifyListeners();
  }

  @override
  void dispose() {
    _access?.removeListener(notifyListeners);
    super.dispose();
  }

  AppReminderConfig get reminder => _access?.reminder ?? defaultAppReminder;

  bool get isChannelEnabled => _access?.isChannelEnabled ?? true;

  Future<void> switchOff({L10n? l10n}) async {
    final reminder = this.reminder;
    if (reminder.enabled) {
      appLog.value.info(
        "$runtimeType.switchOff",
        beforeVal: reminder.enabled,
        afterVal: false,
        ex: [l10n],
      );
      await _access?.processTrigger(
        AppReminderTrigger.settings(reminder.copyWith(enabled: false)),
        l10n: l10n,
      );
    }
  }

  Future<void> switchOn({L10n? l10n}) async {
    final reminder = this.reminder;
    if (!reminder.enabled) {
      appLog.value.info(
        "$runtimeType.switchOn",
        beforeVal: reminder.enabled,
        afterVal: true,
        ex: [l10n],
      );
      await _access?.processTrigger(
        AppReminderTrigger.settings(reminder.copyWith(enabled: true)),
        l10n: l10n,
      );
    }
  }

  Future<void> switchToDaily({TimeOfDay? timeOfDay, L10n? l10n}) async {
    final reminder = this.reminder;
    final newReminder = AppReminderConfig.dailyNight.copyWith(
      timeOfDay: timeOfDay,
      enabled: reminder.enabled,
    );
    if (newReminder != reminder) {
      appLog.value.info(
        "$runtimeType.switchToDaily",
        beforeVal: reminder,
        afterVal: newReminder,
        ex: [timeOfDay, l10n],
      );
      await _access?.processTrigger(
        AppReminderTrigger.settings(newReminder),
        l10n: l10n,
      );
    }
  }
}
