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
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/providers/app_notify_config.dart';
import 'package:mhabit/providers/app_reminder.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_details.dart';
import 'package:mhabit/storage/profile/handlers/app_notify_config.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeAppReminderExecutor extends AppReminderExecutor {
  AppReminderConfig? reminder;
  L10n? l10n;
  NotificationDetails? details;
  int callCount = 0;

  @override
  Future<bool> applyReminder(
    AppReminderConfig reminder, {
    required L10n? l10n,
    required NotificationDetails details,
  }) async {
    this.reminder = reminder;
    this.l10n = l10n;
    this.details = details;
    callCount += 1;
    return true;
  }
}

final class _FakeAppNotifyConfigUpdater extends AppNotifyConfigUpdater {
  final syncedConfigs = <AppNotifyConfig?>[];

  @override
  void sync(AppNotifyConfig? config) {
    syncedConfigs.add(config);
  }
}

Future<ProfileViewModel> _loadAppNotifyConfigProfile({
  AppNotifyConfig? initialConfig,
}) async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([AppNotifyConfigProfileHandler.new]);
  await profile.init();
  if (initialConfig != null) {
    await profile.getHandler<AppNotifyConfigProfileHandler>()!.set(
      initialConfig,
    );
  }
  return profile;
}

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
  setUpAll(_initAppInfo);

  group('AppReminderViewModel collaborator routing', () {
    test('processAppReminder delegates current reminder to executor', () async {
      final executor = _FakeAppReminderExecutor();
      final channelData = NotificationChannelData();
      final viewModel = AppReminderViewModel(executor: executor)
        ..setNotificationChannelData(channelData);

      final result = await viewModel.processAppReminder(null);

      expect(result, isTrue);
      expect(executor.callCount, 1);
      expect(executor.reminder, defaultAppReminder);
      expect(executor.l10n, isNull);
      expect(
        executor.details?.android?.channelId,
        channelData.appReminder.android?.channelId,
      );

      viewModel.dispose();
    });
  });

  group('AppNotifyConfigViewModelImpl collaborator routing', () {
    test('updateProfile and dispose sync through updater', () async {
      const config = AppNotifyConfig(
        channels: {NotificationChannelId.appSyncing: false},
      );
      final profile = await _loadAppNotifyConfigProfile(initialConfig: config);
      final updater = _FakeAppNotifyConfigUpdater();
      final viewModel = AppNotifyConfigViewModelImpl(updater: updater);

      viewModel.updateProfile(profile);
      viewModel.dispose();

      expect(
        updater.syncedConfigs.map(
          (item) => item?.isChannelEnabled(NotificationChannelId.appSyncing),
        ),
        orderedEquals([false, null]),
      );

      profile.dispose();
    });

    test('updateNotifyConfig syncs latest config through updater', () async {
      final profile = await _loadAppNotifyConfigProfile();
      final updater = _FakeAppNotifyConfigUpdater();
      final viewModel = AppNotifyConfigViewModelImpl(updater: updater)
        ..updateProfile(profile);

      updater.syncedConfigs.clear();
      const config = AppNotifyConfig(
        channels: {NotificationChannelId.appSyncFailed: false},
      );

      await viewModel.updateNotifyConfig(config);

      expect(viewModel.notifyConfig.toJson(), config.toJson());
      expect(
        updater.syncedConfigs.map(
          (item) => item?.isChannelEnabled(NotificationChannelId.appSyncFailed),
        ),
        orderedEquals([false]),
      );

      viewModel.dispose();
      profile.dispose();
    });
  });
}
