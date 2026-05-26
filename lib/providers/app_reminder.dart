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

import '../common/consts.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../models/app_reminder_config.dart';
import '../reminders/notification_details.dart';
import '../reminders/notification_service.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import 'commons.dart';

class AppReminderExecutor {
  final NotificationService _notificationService;

  AppReminderExecutor({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  Future<bool> applyReminder(
    AppReminderConfig reminder, {
    required L10n? l10n,
    required NotificationDetails details,
  }) async {
    if (!(reminder.enabled && l10n != null)) {
      await _notificationService.cancelAppReminder();
      return true;
    }

    if (await _notificationService.requestPermissions() == false) {
      return false;
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

// TODO: Move this reminder family into the role-based provider subtree when
// provider files are split by role.
abstract interface class AppReminderAccess implements Listenable {
  AppReminderConfig get reminder;

  Future<void> updateReminder(AppReminderConfig newReminder, {L10n? l10n});

  Future<bool> processAppReminder(L10n? l10n);
}

final class AppReminderOwner extends ChangeNotifier
    with NotificationChannelDataMixin, ProfileHandlerLoadedMixin
    implements AppReminderAccess {
  AppReminderProfileHandler? _rmd;
  final AppReminderExecutor _executor;

  AppReminderOwner({AppReminderExecutor? executor})
    : _executor = executor ?? AppReminderExecutor();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _rmd = newProfile.getHandler<AppReminderProfileHandler>();
  }

  @override
  AppReminderConfig get reminder => _rmd?.get() ?? defaultAppReminder;

  @override
  Future<void> updateReminder(
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
    if ((await processAppReminder(l10n)) != true) {
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
  Future<bool> processAppReminder(L10n? l10n) async {
    return _executor.applyReminder(
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

  Future<void> switchOff({L10n? l10n}) async {
    final reminder = this.reminder;
    if (reminder.enabled) {
      appLog.value.info(
        "$runtimeType.switchOff",
        beforeVal: reminder.enabled,
        afterVal: false,
        ex: [l10n],
      );
      await _access?.updateReminder(
        reminder.copyWith(enabled: false),
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
      await _access?.updateReminder(
        reminder.copyWith(enabled: true),
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
      await _access?.updateReminder(newReminder, l10n: l10n);
    }
  }
}
