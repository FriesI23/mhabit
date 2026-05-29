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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/workflow/app_settings.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile_provider.dart';

final class _FakeNotificationService implements NotificationService {
  int cancelAppReminderCallCount = 0;
  int cancelAllHabitRemindersCallCount = 0;

  @override
  Future<bool> cancelAppReminder({Duration? timeout}) async {
    cancelAppReminderCallCount += 1;
    return true;
  }

  @override
  Future<bool> cancelAllHabitReminders({Duration? timeout}) async {
    cancelAllHabitRemindersCallCount += 1;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeProfileViewModel extends ProfileViewModel {
  _FakeProfileViewModel() : super(const []);

  int clearCallCount = 0;
  int reloadCallCount = 0;

  @override
  Future<bool> clear() async {
    clearCallCount += 1;
    return true;
  }

  @override
  Future<void> reload() async {
    reloadCallCount += 1;
  }
}

final class _FakeDBHelperViewModel extends DBHelperViewModel {
  int reloadCallCount = 0;

  @override
  Future<void> reload() async {
    reloadCallCount += 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettingsOwner reminder cleanup routing', () {
    test(
      'resetConfigs routes through app reminder maintenance cleanup',
      () async {
        final notificationService = _FakeNotificationService();
        final profile = _FakeProfileViewModel();
        final dbHelper = _FakeDBHelperViewModel();
        final owner = AppSettingsOwner(notificationService: notificationService)
          ..updateProfile(profile)
          ..updateDBHelper(dbHelper);

        await owner.resetConfigs();

        expect(profile.clearCallCount, 1);
        expect(profile.reloadCallCount, 1);
        expect(dbHelper.reloadCallCount, 0);
        expect(notificationService.cancelAppReminderCallCount, 1);
        expect(notificationService.cancelAllHabitRemindersCallCount, 0);
      },
    );

    test(
      'clearDatabase routes through habit reminder maintenance cleanup',
      () async {
        final notificationService = _FakeNotificationService();
        final profile = _FakeProfileViewModel();
        final dbHelper = _FakeDBHelperViewModel();
        final owner = AppSettingsOwner(notificationService: notificationService)
          ..updateProfile(profile)
          ..updateDBHelper(dbHelper);

        await owner.clearDatabase();

        expect(profile.clearCallCount, 0);
        expect(profile.reloadCallCount, 0);
        expect(dbHelper.reloadCallCount, 1);
        expect(notificationService.cancelAppReminderCallCount, 0);
        expect(notificationService.cancelAllHabitRemindersCallCount, 1);
      },
    );
  });
}
