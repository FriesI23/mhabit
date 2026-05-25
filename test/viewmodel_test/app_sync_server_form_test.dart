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
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/providers/app_sync_server_form.dart';
import 'package:mhabit/providers/app_sync_server_form_owner.dart';

final class _FakeAppSyncServerFormOwner implements AppSyncServerFormOwner {
  final String? password;
  String? lastIdentity;

  _FakeAppSyncServerFormOwner({this.password});

  @override
  Future<String?> readPassword({String? identity}) async {
    lastIdentity = identity;
    return password;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSyncServerFormViewModel', () {
    test(
      'uses the narrow owner contract for config and password access',
      () async {
        final serverConfig = AppSyncServer.newServer(AppSyncServerType.webdav);
        final owner = _FakeAppSyncServerFormOwner(password: 'secret');
        final vm = AppSyncServerFormViewModel(initServerConfig: serverConfig)
          ..attachOwner(owner);

        expect(vm.serverConfig, same(serverConfig));

        final password = await vm.webdav!.readPassword();

        expect(owner.lastIdentity, vm.identity);
        expect(password.$1, vm.identity);
        expect(password.$2, 'secret');

        vm.dispose();
      },
    );
  });
}
