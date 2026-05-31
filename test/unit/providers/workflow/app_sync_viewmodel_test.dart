// Copyright 2026 Fries_I23
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/reminders/providers/noti_app_sync_provider.dart';
import 'package:mhabit/storage/profile/handlers/app_sync.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAppSyncOwner extends AppSyncOwner {
  @override
  Future<List<String>> cleanExpiredSyncFailedLogs() async => const [];

  @override
  void regrPeriodicSync({Duration? fireDelay}) {}

  @override
  Future<bool> writePassword({String? identity, required String? value}) async {
    return true;
  }
}

class _TestAppSyncPasswordOwner extends _TestAppSyncOwner {
  final String? password;

  _TestAppSyncPasswordOwner(this.password);

  @override
  Future<String?> readPassword({String? identity}) async => password;
}

class _TrackingAppSyncPasswordOwner extends _TestAppSyncOwner {
  int writePasswordCallCount = 0;
  String? lastIdentity;
  String? lastPassword;

  @override
  Future<bool> writePassword({String? identity, required String? value}) async {
    writePasswordCallCount += 1;
    lastIdentity = identity;
    lastPassword = value;
    return true;
  }
}

final class _FakeNotiAppSyncProvider implements NotiAppSyncProvider {
  int readyToSyncCallCount = 0;
  int syncCompleteCallCount = 0;
  final syncingPercentages = <num?>[];
  AppSyncTaskResult? lastSyncCompleteResult;

  @override
  Future<bool> readyToSync() async {
    readyToSyncCallCount += 1;
    return true;
  }

  @override
  Future<bool> syncing({num? percentage}) async {
    syncingPercentages.add(percentage);
    return true;
  }

  @override
  Future<bool> syncComplete({AppSyncTaskResult? result}) async {
    syncCompleteCallCount += 1;
    lastSyncCompleteResult = result;
    return true;
  }
}

Future<ProfileViewModel> _buildProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([
    AppSyncSwitchHandler.new,
    AppSyncServerConfigHandler.new,
    AppSyncFetchIntervalHandler.new,
  ]);
  await profile.init();
  return profile;
}

void main() {
  group('AppSyncOwner', () {
    test('idle trigger and status surfaces stay safe', () {
      final vm = _TestAppSyncOwner();
      final trigger = vm as AppSyncTriggerAccess;
      final status = vm as AppSyncStatusSource;

      expect(status.syncStatus, isNull);
      expect(trigger.canStartSync, isFalse);
      expect(vm.syncProcessing, isNull);
      expect(vm.confirmEvents.isBroadcast, isTrue);
      expect(vm.startSyncEvents.isBroadcast, isTrue);
      expect(trigger.cancelSync, returnsNormally);

      vm.dispose();
    });

    test(
      'settings access persists switch interval and reflects config',
      () async {
        final profile = await _buildProfile();
        final vm = _TestAppSyncOwner()..updateProfile(profile);
        final settings = vm as AppSyncSettingsAccess;
        final trigger = vm as AppSyncTriggerAccess;
        final newInterval = AppSyncFetchInterval.values.firstWhere(
          (value) => value != settings.fetchInterval,
        );
        final fakeServer = AppSyncServer.newServer(AppSyncServerType.fake)!;
        final serverHandler = profile.getHandler<AppSyncServerConfigHandler>()!;

        expect(settings.enabled, isFalse);
        expect(trigger.canStartSync, isFalse);
        await settings.setSyncSwitch(true);
        await settings.setFetchInterval(newInterval);
        await serverHandler.set(fakeServer);

        expect(settings.enabled, isTrue);
        expect(trigger.canStartSync, isTrue);
        expect(settings.fetchInterval, newInterval);
        expect(settings.serverConfig?.isSameConfig(fakeServer), isTrue);
        expect(profile.getHandler<AppSyncSwitchHandler>()?.get(), isTrue);
        expect(
          profile.getHandler<AppSyncFetchIntervalHandler>()?.get(),
          newInterval,
        );
        expect(serverHandler.get()?.isSameConfig(fakeServer), isTrue);

        vm.dispose();
        profile.dispose();
      },
    );

    test('settings access saves and deletes server config', () async {
      final profile = await _buildProfile();
      final vm = _TestAppSyncOwner()..updateProfile(profile);
      final settings = vm as AppSyncSettingsAccess;

      final saved = await settings.saveServerConfigForm(
        AppSyncServer.newServer(AppSyncServerType.fake)!.toForm(),
      );

      expect(saved, isTrue);
      expect(settings.serverConfig, isA<AppFakeSyncServer>());
      expect(
        profile.getHandler<AppSyncServerConfigHandler>()?.get(),
        isA<AppFakeSyncServer>(),
      );

      final deleted = await settings.deleteServerConfig();

      expect(deleted, isTrue);
      expect(settings.serverConfig, isNull);
      expect(profile.getHandler<AppSyncServerConfigHandler>()?.get(), isNull);

      vm.dispose();
      profile.dispose();
    });

    test('settings access stores webdav password through owner seam', () async {
      final profile = await _buildProfile();
      final vm = _TrackingAppSyncPasswordOwner()..updateProfile(profile);
      final settings = vm as AppSyncSettingsAccess;
      final server = AppWebDavSyncServer.newServer(
        identity: AppSyncServer.genNewIdentity(),
        path: 'https://example.com/webdav',
        username: 'tester',
        password: 'secret',
      );

      final saved = await settings.saveServerConfigForm(server.toForm());
      final savedServer = settings.serverConfig as AppWebDavSyncServer;

      expect(saved, isTrue);
      expect(vm.writePasswordCallCount, 1);
      expect(vm.lastIdentity, savedServer.identity);
      expect(vm.lastPassword, 'secret');
      expect(savedServer.password, '');

      vm.dispose();
      profile.dispose();
    });

    test('debug access uses owner-side display formatting', () async {
      final vm = _TestAppSyncPasswordOwner('secret');
      final emptyVm = _TestAppSyncPasswordOwner(null);
      final debug = vm as AppSyncSettingsAccess;
      final emptyDebug = emptyVm as AppSyncSettingsAccess;

      expect(await debug.readPasswordDisplayText(), '******');
      expect(await emptyDebug.readPasswordDisplayText(), '');

      vm.dispose();
      emptyVm.dispose();
    });
  });

  group('AppSyncStatusSnapshot', () {
    test('captures task state and projected sync metadata', () async {
      final task = BasicAppSyncTask(
        config: AppSyncServer.newServer(AppSyncServerType.fake)!,
        onExec: (task) async {
          await Future.delayed(const Duration(milliseconds: 20));
          return const BasicAppSyncTaskResult.success();
        },
      );
      final startTime = DateTime(2026, 5, 25, 10);
      final endedTime = DateTime(2026, 5, 25, 11);
      final container = AppSyncContainer<BasicAppSyncTask, AppSyncTaskResult>(
        id: 'sync-id',
        task: task,
        startTime: startTime,
        endedTime: endedTime,
        result: const BasicAppSyncTaskResult.success(),
      )..percentage = 0.5;

      final running = task.run();
      final runningSnapshot = container.toStatusSnapshot();

      expect(runningSnapshot.id, 'sync-id');
      expect(runningSnapshot.sessionId, task.sessionId);
      expect(runningSnapshot.status, AppSyncTaskStatus.running);
      expect(runningSnapshot.isProcessing, isTrue);
      expect(runningSnapshot.startTime, startTime);
      expect(runningSnapshot.endedTime, endedTime);
      expect(runningSnapshot.result?.isSuccessed, isTrue);
      expect(runningSnapshot.percentage, 0.5);

      await running;

      final completedSnapshot = container.toStatusSnapshot();
      expect(completedSnapshot.status, AppSyncTaskStatus.completed);
      expect(completedSnapshot.isProcessing, isFalse);
    });

    test(
      'legacy container completion sequence preserves failure-log handoff',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mhabit-app-sync-container-',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final notification = _FakeNotiAppSyncProvider();
        final task = BasicAppSyncTask(
          config: AppSyncServer.newServer(AppSyncServerType.fake)!,
          onExec: (task) async =>
              BasicAppSyncTaskResult.error(error: StateError('sync failed')),
        );
        final container = AppSyncContainer.generate(
          task: task,
          filePath: '${tempDir.path}/sync.log',
          notification: notification,
        );

        await notification.readyToSync();
        container.startRecordSyncLog();
        await task.run();
        final completedContainer = container.copyWith(
          result: await task.result,
          endedTime: DateTime(2026, 5, 28, 12),
        );
        completedContainer.recordSyncFailureLog();
        completedContainer.stopRecordSyncLog();
        await notification.syncComplete(result: completedContainer.result);

        expect(completedContainer.result?.withError, isTrue);
        expect(completedContainer.loggerReplay?.isClosed, isTrue);
        expect(completedContainer.loggerStreamer, isNotNull);
        expect(notification.readyToSyncCallCount, 1);
        expect(notification.syncCompleteCallCount, 1);
        expect(
          identical(
            notification.lastSyncCompleteResult,
            completedContainer.result,
          ),
          isTrue,
        );
      },
    );
  });
}
