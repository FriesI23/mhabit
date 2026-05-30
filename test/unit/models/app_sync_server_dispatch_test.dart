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

void main() {
  group('AppSyncServer dispatch', () {
    test('fromJson dispatches to concrete server types', () {
      final webdav = AppWebDavSyncServer.newServer(
        identity: 'webdav-id',
        path: 'https://example.com/webdav',
      );
      final fake = AppFakeSyncServer.newServer(identity: 'fake-id', path: '');

      final restoredWebdav = AppSyncServer.fromJson(webdav.toJson());
      final restoredFake = AppSyncServer.fromJson(fake.toJson());

      expect(restoredWebdav, isA<AppWebDavSyncServer>());
      expect(restoredWebdav?.identity, webdav.identity);
      expect(restoredFake, isA<AppFakeSyncServer>());
      expect(restoredFake?.identity, fake.identity);
    });

    test('fromJson returns null for unknown type', () {
      final restored = AppSyncServer.fromJson({AppSyncServer.typeJsonKey: -1});

      expect(restored, isNull);
    });

    test('newServer dispatches to concrete server types', () {
      final webdav = AppSyncServer.newServer(AppSyncServerType.webdav);
      final fake = AppSyncServer.newServer(AppSyncServerType.fake);

      expect(webdav, isA<AppWebDavSyncServer>());
      expect(fake, isA<AppFakeSyncServer>());
    });

    test('newServer returns null for unknown type', () {
      final server = AppSyncServer.newServer(AppSyncServerType.unknown);

      expect(server, isNull);
    });
  });
}
