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

import '../common/consts.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../model/app_reminder_config.dart';
import '../persistent/profile/handlers.dart';
import '../persistent/profile_provider.dart';
import '../reminders/notification_service.dart';
import 'commons.dart';

class AppReminderViewModel extends ChangeNotifier
    with NotificationChannelDataMixin, ProfileHandlerLoadedMixin {
  AppReminderProfileHandler? _rmd;

  AppReminderViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _rmd = newProfile.getHandler<AppReminderProfileHandler>();
  }

  AppReminderConfig get reminder => _rmd?.get() ?? defaultAppReminder;

  Future<void> switchOff({L10n? l10n}) async {
    final reminder = this.reminder;
    if (reminder.enabled) {
      appLog.value.info("$runtimeType.switchOff",
          beforeVal: reminder.enabled, afterVal: false, ex: [l10n]);
      await _rmd?.set(reminder.copyWith(enabled: false));
      if (!await _handleChangeReminder(l10n)) notifyListeners();
    }
  }

  Future<void> switchOn({L10n? l10n}) async {
    final reminder = this.reminder;
    if (!reminder.enabled) {
      appLog.value.info("$runtimeType.switchOn",
          beforeVal: reminder.enabled, afterVal: true, ex: [l10n]);
      await _rmd?.set(reminder.copyWith(enabled: true));
      if (!await _handleChangeReminder(l10n)) notifyListeners();
    }
  }

  Future<void> switchToDaily({TimeOfDay? timeOfDay, L10n? l10n}) async {
    final reminder = this.reminder;
    final newReminder = AppReminderConfig.dailyNight
        .copyWith(timeOfDay: timeOfDay, enabled: reminder.enabled);
    if (newReminder != reminder) {
      appLog.value.info("$runtimeType.switchToDaily",
          beforeVal: reminder, afterVal: newReminder, ex: [timeOfDay, l10n]);
      await _rmd?.set(newReminder);
      if (!await _handleChangeReminder(l10n)) notifyListeners();
    }
  }

  Future<bool> _handleChangeReminder(L10n? l10n) async {
    if ((await processAppReminder(l10n)) != true) {
      appLog.value.info("$runtimeType._handleChangeReminder",
          beforeVal: reminder.enabled, afterVal: false, ex: [l10n]);
      await _rmd?.set(reminder.copyWith(enabled: false));
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> processAppReminder(L10n? l10n) async {
    final reminder = this.reminder;
    if (reminder.enabled && l10n != null) {
      if (await NotificationService().requestPermissions() == false) {
        return false;
      }
      switch (reminder.type) {
        case AppReminderConfigType.daily:
          if (reminder.timeOfDay != null) {
            await NotificationService().regrAppReminderInDaily(
              title: l10n.appReminder_dailyReminder_title,
              subtitle: l10n.appReminder_dailyReminder_body,
              timeOfDay: reminder.timeOfDay!,
              details: channelData.appReminder,
            );
          }
          return true;
      }
    } else {
      await NotificationService().cancelAppReminder();
      return true;
    }
  }
}
