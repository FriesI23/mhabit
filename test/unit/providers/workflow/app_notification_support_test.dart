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

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationDetails;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/providers/workflow/app_notify_config.dart';
import 'package:mhabit/providers/workflow/app_reminder.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/profile/handlers/app_notify_config.dart';
import 'package:mhabit/storage/profile/handlers/app_reminder.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeNotificationService implements NotificationService {
  int cancelAppReminderCallCount = 0;
  int requestPermissionsCallCount = 0;
  int regrAppReminderCallCount = 0;
  String? lastReminderTitle;
  String? lastReminderSubtitle;
  NotificationDetails? lastReminderDetails;
  final syncedConfigs = <AppNotifyConfig?>[];

  @override
  Future<bool> cancelAppReminder({Duration? timeout}) async {
    cancelAppReminderCallCount += 1;
    return true;
  }

  @override
  void onAppNotiConfigUpdate(AppNotifyConfig? config) {
    syncedConfigs.add(config);
  }

  @override
  Future<bool?> requestPermissions() async {
    requestPermissionsCallCount += 1;
    return true;
  }

  @override
  Future<bool> regrAppReminderInDaily({
    required String title,
    required String subtitle,
    required TimeOfDay timeOfDay,
    required NotificationDetails details,
    Duration? timeout,
  }) async {
    lastReminderTitle = title;
    lastReminderSubtitle = subtitle;
    lastReminderDetails = details;
    regrAppReminderCallCount += 1;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _TrackingAppReminderAccess extends ChangeNotifier
    implements AppReminderAccess {
  _TrackingAppReminderAccess({required this.reminder});

  @override
  AppReminderConfig reminder;
  final triggers = <AppReminderTrigger>[];
  L10n? lastL10n;

  @override
  Future<void> processReminderTrigger(
    AppReminderTrigger trigger, {
    L10n? l10n,
  }) async {
    triggers.add(trigger);
    lastL10n = l10n;
    if (trigger.reason == AppReminderTriggerReason.settings) {
      reminder = trigger.nextReminder!;
      notifyListeners();
    }
  }

  @override
  Future<bool> processAppReminder(L10n? l10n) async => true;
}

Future<ProfileViewModel> _loadAppReminderProfile({
  AppReminderConfig? initialReminder,
}) async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([AppReminderProfileHandler.new]);
  await profile.init();
  if (initialReminder != null) {
    await profile.getHandler<AppReminderProfileHandler>()!.set(initialReminder);
  }
  return profile;
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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_initAppInfo);

  group('AppReminderOwner notification routing', () {
    test(
      'processAppReminder routes enabled reminder through notification service',
      () async {
        final profile = await _loadAppReminderProfile(
          initialReminder: AppReminderConfig.dailyNight,
        );
        final notificationService = _FakeNotificationService();
        final channelData = NotificationChannelData();
        final owner = AppReminderOwner(notificationService: notificationService)
          ..updateProfile(profile)
          ..setNotificationChannelData(channelData);

        final result = await owner.processAppReminder(
          lookupL10n(const Locale('en')),
        );

        expect(result, isTrue);
        expect(notificationService.cancelAppReminderCallCount, 0);
        expect(notificationService.requestPermissionsCallCount, 1);
        expect(notificationService.regrAppReminderCallCount, 1);
        expect(notificationService.lastReminderTitle, isNotEmpty);
        expect(notificationService.lastReminderSubtitle, isNotEmpty);
        expect(
          notificationService.lastReminderDetails?.android?.channelId,
          channelData.appReminder.android?.channelId,
        );

        owner.dispose();
        profile.dispose();
      },
    );
  });

  group('AppReminderViewModel settings routing', () {
    test(
      'switchOn routes through the shared settings trigger contract',
      () async {
        final access = _TrackingAppReminderAccess(
          reminder: AppReminderConfig.off,
        );
        final viewModel = AppReminderViewModel()..attachAccess(access);
        final l10n = lookupL10n(const Locale('en'));

        await viewModel.switchOn(l10n: l10n);

        expect(access.triggers, hasLength(1));
        expect(
          access.triggers.single.reason,
          AppReminderTriggerReason.settings,
        );
        expect(access.triggers.single.nextReminder?.enabled, isTrue);
        expect(access.lastL10n, l10n);

        viewModel.dispose();
        access.dispose();
      },
    );

    test(
      'switchOff routes through the shared settings trigger contract',
      () async {
        final access = _TrackingAppReminderAccess(
          reminder: AppReminderConfig.dailyNight,
        );
        final viewModel = AppReminderViewModel()..attachAccess(access);
        final l10n = lookupL10n(const Locale('en'));

        await viewModel.switchOff(l10n: l10n);

        expect(access.triggers, hasLength(1));
        expect(
          access.triggers.single.reason,
          AppReminderTriggerReason.settings,
        );
        expect(access.triggers.single.nextReminder?.enabled, isFalse);
        expect(access.lastL10n, l10n);

        viewModel.dispose();
        access.dispose();
      },
    );

    test(
      'switchToDaily routes through the shared settings trigger contract',
      () async {
        final access = _TrackingAppReminderAccess(
          reminder: AppReminderConfig.off,
        );
        final viewModel = AppReminderViewModel()..attachAccess(access);
        const timeOfDay = TimeOfDay(hour: 8, minute: 30);
        final l10n = lookupL10n(const Locale('en'));

        await viewModel.switchToDaily(timeOfDay: timeOfDay, l10n: l10n);

        expect(access.triggers, hasLength(1));
        expect(
          access.triggers.single.reason,
          AppReminderTriggerReason.settings,
        );
        expect(
          access.triggers.single.nextReminder,
          AppReminderConfig.dailyNight.copyWith(
            timeOfDay: timeOfDay,
            enabled: false,
          ),
        );
        expect(access.lastL10n, l10n);

        viewModel.dispose();
        access.dispose();
      },
    );
  });

  group('AppNotifyConfigOwner notification routing', () {
    test(
      'updateProfile and dispose sync through notification service',
      () async {
        const config = AppNotifyConfig(
          channels: {NotificationChannelId.appSyncing: false},
        );
        final profile = await _loadAppNotifyConfigProfile(
          initialConfig: config,
        );
        final notificationService = _FakeNotificationService();
        final owner = AppNotifyConfigOwner(
          notificationService: notificationService,
        );

        owner.updateProfile(profile);
        owner.dispose();

        expect(
          notificationService.syncedConfigs.map(
            (item) => item?.isChannelEnabled(NotificationChannelId.appSyncing),
          ),
          orderedEquals([false, null]),
        );

        profile.dispose();
      },
    );

    test(
      'updateNotifyConfig syncs latest config through NotificationService',
      () async {
        final profile = await _loadAppNotifyConfigProfile();
        final notificationService = _FakeNotificationService();
        final owner = AppNotifyConfigOwner(
          notificationService: notificationService,
        )..updateProfile(profile);

        notificationService.syncedConfigs.clear();
        const config = AppNotifyConfig(
          channels: {NotificationChannelId.appSyncFailed: false},
        );

        await owner.updateNotifyConfig(config);

        expect(owner.notifyConfig.toJson(), config.toJson());
        expect(
          notificationService.syncedConfigs.map(
            (item) =>
                item?.isChannelEnabled(NotificationChannelId.appSyncFailed),
          ),
          orderedEquals([false]),
        );

        owner.dispose();
        profile.dispose();
      },
    );
  });
}
