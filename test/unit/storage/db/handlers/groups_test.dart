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
import 'package:mhabit/storage/db/handlers/group.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db/handlers/sync_group.dart';
import 'package:mhabit/storage/db_helper_provider.dart';

void main() {
  group('GroupDBCell', () {
    const group = GroupDBCell(
      id: 1,
      uuid: 'test-group-uuid',
      name: 'Health',
      desc: 'Health related habits',
      icon: 0xE001,
      color: 0xFF00FF00,
      customColor: 0x11223344,
      customColorTinted: 1,
      status: 1,
    );

    test('toJson produces all fields', () {
      final json = group.toJson();
      expect(json[GroupDBCellKey.id], 1);
      expect(json[GroupDBCellKey.uuid], 'test-group-uuid');
      expect(json[GroupDBCellKey.name], 'Health');
      expect(json[GroupDBCellKey.desc], 'Health related habits');
      expect(json[GroupDBCellKey.icon], 0xE001);
      expect(json[GroupDBCellKey.color], 0xFF00FF00);
      expect(json[GroupDBCellKey.customColor], 0x11223344);
      expect(json[GroupDBCellKey.customColorTinted], 1);
      expect(json[GroupDBCellKey.status], 1);
    });

    test('fromJson round-trips correctly', () {
      final json = group.toJson();
      final restored = GroupDBCell.fromJson(json);
      expect(restored.id, group.id);
      expect(restored.uuid, group.uuid);
      expect(restored.name, group.name);
      expect(restored.desc, group.desc);
      expect(restored.icon, group.icon);
      expect(restored.color, group.color);
      expect(restored.customColor, group.customColor);
      expect(restored.customColorTinted, group.customColorTinted);
      expect(restored.status, group.status);
    });

    test('fromJson tolerates missing optional fields', () {
      final cell = GroupDBCell.fromJson({'uuid': 'minimal', 'name': 'Minimal'});
      expect(cell.uuid, 'minimal');
      expect(cell.name, 'Minimal');
      expect(cell.desc, isNull);
      expect(cell.icon, isNull);
      expect(cell.color, isNull);
      expect(cell.customColor, isNull);
      expect(cell.customColorTinted, isNull);
      expect(cell.status, isNull);
    });

    test('toString includes runtime type', () {
      expect(group.toString(), contains('GroupDBCell'));
    });
  });

  group('GroupDBHelper', () {
    late DBHelperViewModel viewModel;
    late GroupDBHelper helper;
    late SyncGroupDBHelper syncHelper;

    Future<Map<String, Object?>> loadSyncRow(String uuid) async {
      final rows = await viewModel.local.db.query(
        'mh_sync',
        where: '${SyncDbCellKey.groupUUID} = ?',
        whereArgs: [uuid],
      );
      expect(rows, hasLength(1));
      return rows.first;
    }

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      viewModel = DBHelperViewModel();
      await viewModel.init();
      helper = GroupDBHelper(viewModel.local);
      syncHelper = SyncGroupDBHelper(viewModel.local);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      viewModel.dispose();
    });

    test('insertNewGroup writes group row and sync row', () async {
      const group = GroupDBCell(
        uuid: 'insert-test-uuid',
        name: 'Insert Test',
        status: 1,
      );
      final id = await helper.insertNewGroup(group);
      expect(id, greaterThan(0));

      final sync = await loadSyncRow('insert-test-uuid');
      expect(sync[SyncDbCellKey.groupUUID], 'insert-test-uuid');
      expect(sync[SyncDbCellKey.dirty], 1);
      expect(sync[SyncDbCellKey.dirtyTotal], 1);
    });

    test('loadAllActiveGroups returns only active groups', () async {
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'active-1', name: 'Active 1', status: 1),
      );
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'active-2', name: 'Active 2', status: 1),
      );
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'deleted-1', name: 'Deleted 1', status: 2),
      );

      final groups = await helper.loadAllActiveGroups();
      expect(groups.length, 2);
    });

    test('loadAllActiveGroups orders by createT', () async {
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'order-2', name: 'Second', status: 1),
      );
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'order-1', name: 'First', status: 1),
      );

      final groups = await helper.loadAllActiveGroups();
      expect(groups.length, 2);
      expect(groups[0].uuid, 'order-2');
      expect(groups[1].uuid, 'order-1');
    });

    test('loadGroupByUUID returns correct group', () async {
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'find-me', name: 'Find Me', status: 1),
      );
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'not-me', name: 'Not Me', status: 1),
      );

      final found = await helper.loadGroupByUUID('find-me');
      expect(found, isNotNull);
      expect(found!.name, 'Find Me');

      final missing = await helper.loadGroupByUUID('nonexistent');
      expect(missing, isNull);
    });

    test('updateExistGroup updates fields', () async {
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'update-me', name: 'Original', status: 1),
      );
      await helper.updateExistGroup(
        const GroupDBCell(
          uuid: 'update-me',
          name: 'Updated',
          desc: 'New desc',
          status: 1,
        ),
      );

      final updated = await helper.loadGroupByUUID('update-me');
      expect(updated!.name, 'Updated');
      expect(updated.desc, 'New desc');
    });

    test('deleteGroup soft-deletes (status=2)', () async {
      await helper.insertNewGroup(
        const GroupDBCell(uuid: 'delete-me', name: 'To Delete', status: 1),
      );

      await helper.deleteGroup('delete-me');

      // Active query should not find it
      final active = await helper.loadAllActiveGroups();
      expect(active.any((g) => g.uuid == 'delete-me'), isFalse);

      // But loadGroupByUUID should still find it (soft delete)
      final softDeleted = await helper.loadGroupByUUID('delete-me');
      expect(softDeleted, isNotNull);
      expect(softDeleted!.status, 2);
    });

    test('update/delete increment group dirty counters', () async {
      await helper.insertNewGroup(
        const GroupDBCell(
          uuid: 'dirty-inc',
          name: 'Dirty Increment',
          status: 1,
        ),
      );

      var sync = await loadSyncRow('dirty-inc');
      expect(sync[SyncDbCellKey.dirty], 1);
      expect(sync[SyncDbCellKey.dirtyTotal], 1);

      await helper.updateExistGroup(
        const GroupDBCell(
          uuid: 'dirty-inc',
          name: 'Dirty Increment v2',
          status: 1,
        ),
      );
      sync = await loadSyncRow('dirty-inc');
      expect(sync[SyncDbCellKey.dirty], 2);
      expect(sync[SyncDbCellKey.dirtyTotal], 2);

      await helper.updateExistGroup(
        const GroupDBCell(
          uuid: 'dirty-inc',
          name: 'Dirty Increment v3',
          desc: 'desc',
          status: 1,
        ),
      );
      sync = await loadSyncRow('dirty-inc');
      expect(sync[SyncDbCellKey.dirty], 3);
      expect(sync[SyncDbCellKey.dirtyTotal], 3);

      await helper.deleteGroup('dirty-inc');
      sync = await loadSyncRow('dirty-inc');
      expect(sync[SyncDbCellKey.dirty], 4);
      expect(sync[SyncDbCellKey.dirtyTotal], 4);
    });

    test('updateExistGroup rolls back when sync row is missing', () async {
      await helper.insertNewGroup(
        const GroupDBCell(
          uuid: 'tx-update-rollback',
          name: 'Before',
          status: 1,
        ),
      );
      await viewModel.local.db.delete(
        'mh_sync',
        where: '${SyncDbCellKey.groupUUID} = ?',
        whereArgs: ['tx-update-rollback'],
      );

      await expectLater(
        helper.updateExistGroup(
          const GroupDBCell(
            uuid: 'tx-update-rollback',
            name: 'After',
            status: 1,
          ),
        ),
        throwsA(isA<StateError>()),
      );

      final group = await helper.loadGroupByUUID('tx-update-rollback');
      expect(group, isNotNull);
      expect(group!.name, 'Before');
    });

    test('deleteGroup rolls back when sync row is missing', () async {
      await helper.insertNewGroup(
        const GroupDBCell(
          uuid: 'tx-delete-rollback',
          name: 'Before',
          status: 1,
        ),
      );
      await viewModel.local.db.delete(
        'mh_sync',
        where: '${SyncDbCellKey.groupUUID} = ?',
        whereArgs: ['tx-delete-rollback'],
      );

      await expectLater(
        helper.deleteGroup('tx-delete-rollback'),
        throwsA(isA<StateError>()),
      );

      final group = await helper.loadGroupByUUID('tx-delete-rollback');
      expect(group, isNotNull);
      expect(group!.status, 1);
    });

    test(
      'clearGroupDirtyMark decrements by snapshot and preserves newer edits',
      () async {
        await helper.insertNewGroup(
          const GroupDBCell(uuid: 'clear-dirty', name: 'Original', status: 1),
        );

        final snapshot = await syncHelper.loadGroupDataFromDb(
          'clear-dirty',
          configId: 'cfg',
          sessionId: 'session',
        );
        expect(snapshot, isNotNull);
        expect(snapshot!.dirty, 1);
        expect(snapshot.dirtyTotal, 1);

        await helper.updateExistGroup(
          const GroupDBCell(
            uuid: 'clear-dirty',
            name: 'Local New Edit',
            status: 1,
          ),
        );

        await syncHelper.clearGroupDirtyMark(
          snapshot,
          etag: 'etag-after-upload',
          configId: 'cfg',
          sessionId: 'session',
        );

        final sync = await loadSyncRow('clear-dirty');
        expect(sync[SyncDbCellKey.dirty], 1);
        expect(sync[SyncDbCellKey.dirtyTotal], 1);
        expect(sync[SyncDbCellKey.lastMark2], 'etag-after-upload');
      },
    );
  });
}
