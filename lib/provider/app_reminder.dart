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

import '../l10n/localizations.dart';
import '../model/app_reminder_config.dart';
import '../model/global.dart';
import '../reminders/notification_channel.dart';
import '../reminders/notification_service.dart';
import 'commons.dart';

class AppReminderViewModel extends ChangeNotifier
    with NotificationChannelDataMixin
    implements GlobalProxyProviderInterface {
  Global _g;

  AppReminderViewModel({required Global global}) : _g = global;

  @override
  Global get g => _g;

  @override
  void updateGlobal(Global newGloal) => _g = newGloal;

  @override
  void setNotificationChannelData(NotificationChannelData newData,
      {L10n? l10n}) {
    super.setNotificationChannelData(newData);
    _handleChangeReminder(l10n);
  }

  AppReminderConfig get reminder => _g.appReminderConfig;

  Future<void> switchOff({L10n? l10n}) async {
    final reminder = this.reminder;
    if (reminder.enabled) {
      await _g.profile.setAppReminder(reminder.copyWith(enabled: false));
      notifyListeners();
      await _handleChangeReminder(l10n);
    }
  }

  Future<void> switchOn({L10n? l10n}) async {
    final reminder = this.reminder;
    if (!reminder.enabled) {
      await _g.profile.setAppReminder(reminder.copyWith(enabled: true));
      notifyListeners();
      await _handleChangeReminder(l10n);
    }
  }

  Future<void> switchToDaily({TimeOfDay? timeOfDay, L10n? l10n}) async {
    final reminder = this.reminder;
    final newReminder = AppReminderConfig.dailyNight
        .copyWith(timeOfDay: timeOfDay, enabled: reminder.enabled);
    if (newReminder != reminder) {
      await _g.profile.setAppReminder(newReminder);
      notifyListeners();
      await _handleChangeReminder(l10n);
    }
  }

  Future<void> _handleChangeReminder(L10n? l10n) async {
    if ((l10n != null ? await processAppReminder(l10n) : true) != true) {
      await _g.profile.setAppReminder(reminder.copyWith(enabled: false));
      notifyListeners();
    }
  }

  Future<bool> processAppReminder(L10n l10n) async {
    final reminder = this.reminder;
    if (reminder.enabled) {
      if (await NotificationService().requestPermissions() != true) {
        return false;
      }
      switch (reminder.type) {
        case AppReminderConfigType.daily:
          if (reminder.timeOfDay != null) {
            await NotificationService().regreAppReminderInDaily(
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
