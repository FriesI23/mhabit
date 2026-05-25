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
import 'package:mhabit/models/app_sync_server_form.dart';
import 'package:mhabit/providers/app_sync.dart';
import 'package:mhabit/providers/app_sync_server_form.dart';

final class _FakeAppSyncSettingsAccess implements AppSyncSettingsAccess {
  final String? password;
  String? lastIdentity;

  _FakeAppSyncSettingsAccess({this.password});

  @override
  bool get enabled => true;

  @override
  AppSyncFetchInterval get fetchInterval => AppSyncFetchInterval.minute30;

  @override
  AppSyncServer? get serverConfig => null;

  @override
  Future<String?> readPassword({String? identity}) async {
    lastIdentity = identity;
    return password;
  }

  @override
  Future<String> readDebugPasswordText() async => password ?? '';

  @override
  Future<bool> deleteServerConfig() async => false;

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  Future<bool> saveServerConfigForm(
    AppSyncServerForm form, {
    bool resetStatus = true,
  }) async => false;

  @override
  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  }) async {}

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSyncServerFormViewModel', () {
    test(
      'uses app sync settings access for config and password access',
      () async {
        final serverConfig = AppSyncServer.newServer(AppSyncServerType.webdav);
        final appSync = _FakeAppSyncSettingsAccess(password: 'secret');
        final vm = AppSyncServerFormViewModel(initServerConfig: serverConfig)
          ..attachSettings(appSync);

        expect(vm.serverConfig, same(serverConfig));

        final password = await vm.webdav!.readPassword();

        expect(appSync.lastIdentity, vm.identity);
        expect(password.$1, vm.identity);
        expect(password.$2, 'secret');

        vm.dispose();
      },
    );
  });
}
