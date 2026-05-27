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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data_saver/data_saver.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile/handlers/app_sync.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);
const _dataSaverChannel = MethodChannel('data_saver');

List<String> _serializeConnectivityResults(List<ConnectivityResult> results) {
  return results
      .map(
        (result) => switch (result) {
          ConnectivityResult.bluetooth => 'bluetooth',
          ConnectivityResult.wifi => 'wifi',
          ConnectivityResult.ethernet => 'ethernet',
          ConnectivityResult.mobile => 'mobile',
          ConnectivityResult.none => 'none',
          ConnectivityResult.vpn => 'vpn',
          ConnectivityResult.satellite => 'satellite',
          ConnectivityResult.other => 'other',
        },
      )
      .toList();
}

String _serializeDataSaverMode(DataSaverMode mode) {
  return switch (mode) {
    DataSaverMode.enabled => 'ENABLED',
    DataSaverMode.whitelisted => 'WHITELISTED',
    DataSaverMode.disabled => 'DISABLED',
  };
}

void _mockConnectivityResults(List<ConnectivityResult> results) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel, (call) async {
        if (call.method != 'check') return null;
        return _serializeConnectivityResults(results);
      });
}

void _mockDataSaverMode(DataSaverMode mode) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_dataSaverChannel, (call) async {
        if (call.method != 'checkMode') return null;
        return _serializeDataSaverMode(mode);
      });
}

class _TestDispatcherOwner extends AppSyncOwner {
  _TestDispatcherOwner({this.storedPassword});

  final String? storedPassword;
  String? lastReadPasswordIdentity;

  @override
  Future<List<String>> cleanExpiredSyncFailedLogs() async => const [];

  @override
  Future<String?> readPassword({String? identity}) async {
    lastReadPasswordIdentity = identity;
    return storedPassword;
  }

  @override
  void regrPeriodicSync({Duration? fireDelay}) {}

  @override
  Future<bool> writePassword({String? identity, required String? value}) async {
    return true;
  }
}

final class _DispatcherHarness {
  final ProfileViewModel profile;
  final DBHelperViewModel dbHelper;
  final _TestDispatcherOwner owner;
  final AppSyncTaskDispatcher dispatcher;

  const _DispatcherHarness({
    required this.profile,
    required this.dbHelper,
    required this.owner,
    required this.dispatcher,
  });

  void dispose() {
    dispatcher.dispose();
    owner.dispose();
    dbHelper.dispose();
    profile.dispose();
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

Future<_DispatcherHarness> _buildHarness({
  bool enabled = false,
  AppSyncServer? config,
  String? storedPassword,
}) async {
  final profile = await _buildProfile();
  final dbHelper = DBHelperViewModel();
  await dbHelper.init();
  final owner = _TestDispatcherOwner(storedPassword: storedPassword)
    ..updateProfile(profile)
    ..updateDBHelper(dbHelper);
  await profile.getHandler<AppSyncSwitchHandler>()!.set(enabled);
  if (config != null) {
    await profile.getHandler<AppSyncServerConfigHandler>()!.set(config);
  }
  final dispatcher = AppSyncTaskDispatcher(owner);
  return _DispatcherHarness(
    profile: profile,
    dbHelper: dbHelper,
    owner: owner,
    dispatcher: dispatcher,
  );
}

AppWebDavSyncServer _buildWebDavConfig({
  String password = 'secret',
  Duration? timeout,
  bool syncInLowData = true,
  Iterable<AppSyncServerMobileNetwork>? syncMobileNetworks,
}) {
  return AppWebDavSyncServer.newServer(
    identity: AppSyncServer.genNewIdentity(),
    path: 'https://example.com/webdav',
    username: 'tester',
    password: password,
    timeout: timeout,
    syncInLowData: syncInLowData,
    syncMobileNetworks: syncMobileNetworks,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_dataSaverChannel, null);
    messenger.setMockMethodCallHandler(_connectivityChannel, null);
  });

  group('AppSyncTaskDispatcher', () {
    test('shouldSync returns false when sync switch is off', () async {
      final harness = await _buildHarness(
        enabled: false,
        config: AppSyncServer.newServer(AppSyncServerType.fake),
      );
      addTearDown(harness.dispose);

      expect(await harness.dispatcher.shouldSync(), isFalse);
    });

    test('shouldSync returns false when config is absent', () async {
      final harness = await _buildHarness(enabled: true);
      addTearDown(harness.dispose);

      expect(await harness.dispatcher.shouldSync(), isFalse);
    });

    test('shouldSync keeps fake-server branch on dispatcher', () async {
      final harness = await _buildHarness(
        enabled: true,
        config: AppSyncServer.newServer(AppSyncServerType.fake),
      );
      addTearDown(harness.dispose);

      expect(await harness.dispatcher.shouldSync(), kDebugMode);
    });

    test('buildNewTask returns BasicAppSyncTask for fake server', () async {
      final harness = await _buildHarness();
      addTearDown(harness.dispose);
      final config = AppSyncServer.newServer(AppSyncServerType.fake)!;

      final task = await harness.dispatcher.buildNewTask(config);

      expect(task, isA<BasicAppSyncTask>());
      expect(task.config.isSameConfig(config), isTrue);
    });

    test(
      'buildNewTask hydrates webdav password and inflates timeout for first sync',
      () async {
        final config = _buildWebDavConfig(
          password: 'config-secret',
          timeout: const Duration(seconds: 3),
        );
        final harness = await _buildHarness(storedPassword: 'stored-secret');
        addTearDown(harness.dispose);

        final task =
            await harness.dispatcher.buildNewTask(config) as WebDavAppSyncTask;

        expect(task.config.password, 'stored-secret');
        expect(task.config.timeout, const Duration(seconds: 30));
        expect(harness.owner.lastReadPasswordIdentity, config.identity);
      },
    );

    test(
      'buildNewTask keeps configured timeout and config password after initial sync',
      () async {
        final config = _buildWebDavConfig(
          password: 'config-secret',
          timeout: const Duration(seconds: 3),
        ).copyWith(configed: true);
        final harness = await _buildHarness();
        addTearDown(harness.dispose);

        final task =
            await harness.dispatcher.buildNewTask(config) as WebDavAppSyncTask;

        expect(task.config.password, 'config-secret');
        expect(task.config.timeout, const Duration(seconds: 3));
        expect(harness.owner.lastReadPasswordIdentity, config.identity);
      },
    );

    test(
      'shouldSyncInWebDav returns false when connectivity is none',
      () async {
        final harness = await _buildHarness();
        addTearDown(harness.dispose);
        _mockDataSaverMode(DataSaverMode.disabled);
        _mockConnectivityResults([ConnectivityResult.none]);

        final result = await harness.dispatcher.shouldSyncInWebDav(
          _buildWebDavConfig(syncInLowData: false),
        );

        expect(result, isFalse);
      },
    );

    test(
      'shouldSyncInWebDav returns true on allowed wifi without low-data block',
      () async {
        final harness = await _buildHarness();
        addTearDown(harness.dispose);
        _mockDataSaverMode(DataSaverMode.disabled);
        _mockConnectivityResults([ConnectivityResult.wifi]);

        final result = await harness.dispatcher.shouldSyncInWebDav(
          _buildWebDavConfig(
            syncInLowData: false,
            syncMobileNetworks: const [AppSyncServerMobileNetwork.wifi],
          ),
        );

        expect(result, isTrue);
      },
    );

    test(
      'shouldSyncInWebDav blocks data saver when low-data sync is disabled',
      () async {
        final harness = await _buildHarness();
        addTearDown(harness.dispose);
        _mockDataSaverMode(DataSaverMode.enabled);
        _mockConnectivityResults([ConnectivityResult.wifi]);

        final result = await harness.dispatcher.shouldSyncInWebDav(
          _buildWebDavConfig(
            syncInLowData: false,
            syncMobileNetworks: const [AppSyncServerMobileNetwork.wifi],
          ),
        );

        expect(result, isFalse);
      },
    );

    test(
      'shouldSyncInWebDav allows mobile when config opts into low-data sync',
      () async {
        final harness = await _buildHarness();
        addTearDown(harness.dispose);
        _mockDataSaverMode(DataSaverMode.enabled);
        _mockConnectivityResults([ConnectivityResult.mobile]);

        final result = await harness.dispatcher.shouldSyncInWebDav(
          _buildWebDavConfig(
            syncInLowData: true,
            syncMobileNetworks: const [AppSyncServerMobileNetwork.mobile],
          ),
        );

        expect(result, isTrue);
      },
    );
  });
}
