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
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db/handlers/sync_group.dart';
import 'package:mhabit/storage/db_helper_provider.dart';

void main() {
  group('SyncGroupDBHelper.loadGroupDataFromDb', () {
    late DBHelperViewModel viewModel;
    late SyncGroupDBHelper syncHelper;

    Future<void> seedGroupWithSync({
      required String uuid,
      required String etag,
      required String lastConfigUUID,
      int dirty = 0,
      int dirtyTotal = 0,
    }) async {
      await viewModel.local.db.insert('mh_groups', {
        GroupDBCellKey.uuid: uuid,
        GroupDBCellKey.name: 'Test Group',
        GroupDBCellKey.status: 1,
      });
      await viewModel.local.db.insert('mh_sync', {
        SyncDbCellKey.groupUUID: uuid,
        SyncDbCellKey.dirty: dirty,
        SyncDbCellKey.dirtyTotal: dirtyTotal,
        SyncDbCellKey.lastMark2: etag,
        SyncDbCellKey.lastConfigUUID: lastConfigUUID,
      });
    }

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      viewModel = DBHelperViewModel();
      await viewModel.init();
      syncHelper = SyncGroupDBHelper(viewModel.local);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      viewModel.dispose();
    });

    // Regression test: when the sync config changes (different configId),
    // the old etag MUST be nulled out.  Otherwise UploadDataToServerTask
    // attaches a stale If-Match header and the PUT fails with 412 on the
    // new server, silently losing the group upload.
    test(
      'etag is null when configId differs from stored lastConfigUUID',
      () async {
        const groupUuid = 'g-config-change';
        const oldConfigId = 'old-cfg-1';
        const oldEtag = '"old-etag-123"';

        await seedGroupWithSync(
          uuid: groupUuid,
          etag: oldEtag,
          lastConfigUUID: oldConfigId,
        );

        final result = await syncHelper.loadGroupDataFromDb(
          groupUuid,
          configId: 'new-cfg-2',
          sessionId: 'sid-1',
        );

        expect(result, isNotNull);
        expect(result!.uuid, groupUuid);
        // Key assertion: etag must be null so upload won't use stale If-Match
        expect(result.etag, isNull);
        // sessionId should be refreshed because config changed
        expect(result.sessionId, 'sid-1');
      },
    );

    test(
      'etag is preserved when configId matches stored lastConfigUUID',
      () async {
        const groupUuid = 'g-same-config';
        const sameConfigId = 'cfg-1';
        const storedEtag = '"etag-456"';

        await seedGroupWithSync(
          uuid: groupUuid,
          etag: storedEtag,
          lastConfigUUID: sameConfigId,
        );

        final result = await syncHelper.loadGroupDataFromDb(
          groupUuid,
          configId: sameConfigId,
          sessionId: 'sid-1',
        );

        expect(result, isNotNull);
        expect(result!.uuid, groupUuid);
        // Same config: etag should be preserved for If-Match conflict detection
        expect(result.etag, storedEtag);
        // sessionId should stay unchanged (not dirty, same config)
        expect(result.sessionId, isNull);
      },
    );

    test(
      'sessionId is refreshed when group is dirty regardless of config',
      () async {
        const groupUuid = 'g-dirty';
        const sameConfigId = 'cfg-1';
        const storedEtag = '"etag-dirty"';

        await seedGroupWithSync(
          uuid: groupUuid,
          etag: storedEtag,
          lastConfigUUID: sameConfigId,
          dirty: 1,
          dirtyTotal: 1,
        );

        final result = await syncHelper.loadGroupDataFromDb(
          groupUuid,
          configId: sameConfigId,
          sessionId: 'sid-dirty',
        );

        expect(result, isNotNull);
        expect(result!.uuid, groupUuid);
        // dirty -> etag preserved (still same server, just dirty locally)
        expect(result.etag, storedEtag);
        // dirty -> sessionId refreshed
        expect(result.sessionId, 'sid-dirty');
      },
    );

    test('returns null when group does not exist', () async {
      final result = await syncHelper.loadGroupDataFromDb(
        'nonexistent',
        configId: 'cfg-1',
        sessionId: 'sid-1',
      );

      expect(result, isNull);
    });

    test('returns null when sync row is missing (INNER JOIN)', () async {
      const groupUuid = 'g-no-sync';
      await viewModel.local.db.insert('mh_groups', {
        GroupDBCellKey.uuid: groupUuid,
        GroupDBCellKey.name: 'Orphan Group',
        GroupDBCellKey.status: 1,
      });
      // No sync row inserted

      final result = await syncHelper.loadGroupDataFromDb(
        groupUuid,
        configId: 'cfg-1',
        sessionId: 'sid-1',
      );

      expect(result, isNull);
    });
  });
}
