// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';

import '../../reminders/notification_service.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/profile_provider.dart';

abstract interface class AppSettingsAccess implements Listenable {
  Future<void> resetConfigs();

  Future<void> clearDatabase();
}

final class AppSettingsOwner extends ChangeNotifier
    implements AppSettingsAccess {
  late ProfileViewModel _profile;
  late DBHelperViewModel _dbHelper;
  final NotificationService _notificationService;

  AppSettingsOwner({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  void updateProfile(ProfileViewModel newProfile) {
    _profile = newProfile;
  }

  void updateDBHelper(DBHelperViewModel newHelper) {
    _dbHelper = newHelper;
  }

  @override
  Future<void> resetConfigs() async {
    await Future.wait([
      _profile.clear(),
      _notificationService.cancelAppReminder(),
    ]);
    await _profile.reload();
  }

  @override
  Future<void> clearDatabase() async {
    await _dbHelper.reload();
    await _notificationService.cancelAllHabitReminders();
  }
}
