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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/providers/app_sync.dart';
import 'package:mhabit/storage/profile/handlers/app_sync.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAppSyncViewModel extends AppSyncViewModel {
  @override
  Future<List<String>> cleanExpiredSyncFailedLogs() async => const [];

  @override
  void regrPeriodicSync({Duration? fireDelay}) {}

  @override
  Future<bool> writePassword({String? identity, required String? value}) async {
    return true;
  }
}

class _TestAppSyncPasswordViewModel extends _TestAppSyncViewModel {
  final String? password;

  _TestAppSyncPasswordViewModel(this.password);

  @override
  Future<String?> readPassword({String? identity}) async => password;
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSyncViewModel', () {
    test('idle trigger and event boundary stays safe', () {
      final vm = _TestAppSyncViewModel();

      expect(vm.syncStatus, isNull);
      expect(vm.syncProcessing, isNull);
      expect(vm.confirmEvents.isBroadcast, isTrue);
      expect(vm.startSyncEvents.isBroadcast, isTrue);
      expect(vm.cancelSync, returnsNormally);

      vm.dispose();
    });

    test(
      'settings boundary persists switch interval and reflects config',
      () async {
        final profile = await _buildProfile();
        final vm = _TestAppSyncViewModel()..updateProfile(profile);
        final newInterval = AppSyncFetchInterval.values.firstWhere(
          (value) => value != vm.fetchInterval,
        );
        final fakeServer = AppSyncServer.newServer(AppSyncServerType.fake)!;
        final serverHandler = profile.getHandler<AppSyncServerConfigHandler>()!;

        expect(vm.enabled, isFalse);
        await vm.setSyncSwitch(true);
        await vm.setFetchInterval(newInterval);
        await serverHandler.set(fakeServer);

        expect(vm.enabled, isTrue);
        expect(vm.fetchInterval, newInterval);
        expect(vm.serverConfig?.isSameConfig(fakeServer), isTrue);
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

    test('settings commands save and delete server config', () async {
      final profile = await _buildProfile();
      final vm = _TestAppSyncViewModel()..updateProfile(profile);

      final saved = await vm.saveServerConfigForm(
        AppSyncServer.newServer(AppSyncServerType.fake)!.toForm(),
      );

      expect(saved, isTrue);
      expect(vm.serverConfig, isA<AppFakeSyncServer>());
      expect(
        profile.getHandler<AppSyncServerConfigHandler>()?.get(),
        isA<AppFakeSyncServer>(),
      );

      final deleted = await vm.deleteServerConfig();

      expect(deleted, isTrue);
      expect(vm.serverConfig, isNull);
      expect(profile.getHandler<AppSyncServerConfigHandler>()?.get(), isNull);

      vm.dispose();
      profile.dispose();
    });

    test('debug password text uses owner-side display formatting', () async {
      final vm = _TestAppSyncPasswordViewModel('secret');
      final emptyVm = _TestAppSyncPasswordViewModel(null);

      expect(await vm.readDebugPasswordText(), 'secret');
      expect(await emptyVm.readDebugPasswordText(), '');

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
  });
}
