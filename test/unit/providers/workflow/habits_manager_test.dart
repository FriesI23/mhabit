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
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationDetails;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_reminder.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/providers/workflow/app_notify_config.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class _FakeNotificationService implements NotificationService {
  int cancelHabitReminderCallCount = 0;
  int regrHabitReminderCallCount = 0;
  NotificationDetails? lastReminderDetails;

  @override
  Future<bool> cancelHabitReminder({required int id, Duration? timeout}) async {
    cancelHabitReminderCallCount += 1;
    return true;
  }

  @override
  Future<bool> regrHabitReminder<T>({
    required int id,
    required String uuid,
    required String name,
    String? quest,
    required HabitReminder reminder,
    required HabitDate? lastUntrackDate,
    required NotificationDetails details,
    DateTime? crtDate,
    Duration? timeout,
  }) async {
    regrHabitReminderCallCount += 1;
    lastReminderDetails = details;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeAppNotifyConfigAccess extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  _FakeAppNotifyConfigAccess({required this.notifyConfig});

  @override
  AppNotifyConfig notifyConfig;

  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool isChannelEnabled(NotificationChannelId channelId) =>
      notifyConfig.isChannelEnabled(channelId);

  @override
  Future<void> updateConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  }) async {
    notifyConfig = newConfig;
    if (listen) notifyListeners();
  }
}

HabitSummaryData _buildHabitSummaryData() => HabitSummaryData(
  id: 1,
  uuid: 'habit-1',
  type: HabitType.normal,
  name: 'Test habit',
  desc: '',
  colorType: HabitColorType.cc1,
  dailyGoal: 1,
  targetDays: 1,
  frequency: HabitFrequency.daily,
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)),
  status: HabitStatus.activated,
  reminder: HabitReminder.dailyMidnight,
  reminderQuest: 'Stay on track',
  sortPostion: 1,
  createTime: DateTime(2026, 1, 1),
);

Future<void> _initAppInfo() async {
  PackageInfo.setMockInitialValues(
    appName: 'mhabit',
    packageName: 'io.github.friesi23.mhabit',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await AppInfo().init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_initAppInfo);

  group('HabitsManager reminder channel gating', () {
    test(
      'updateHabitReminders skips notification service when habit channel is disabled',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(
            channels: {NotificationChannelId.habitReminder: false},
          ),
        );
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(NotificationChannelData());

        await manager.updateHabitReminders([_buildHabitSummaryData()]);

        expect(notificationService.regrHabitReminderCallCount, 0);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'updateHabitReminders routes enabled habit reminder through notification service',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final channelData = NotificationChannelData();
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(channelData);

        await manager.updateHabitReminders([_buildHabitSummaryData()]);

        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);
        expect(
          notificationService.lastReminderDetails?.android?.channelId,
          channelData.habitReminder.android?.channelId,
        );

        notifyConfig.dispose();
      },
    );
  });
}
