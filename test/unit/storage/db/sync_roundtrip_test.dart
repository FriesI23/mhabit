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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_models.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db_helper_provider.dart';

/// Minimum required fields for [WebDavSyncHabitData.fromJson] to produce a
/// valid [HabitDBCell] that satisfies DB NOT NULL constraints.
Map<String, Object?> _basePayload(String uuid, String name) => {
  '_convert_type': 'habit_',
  'uuid': uuid,
  'name': name,
  'color': HabitColorType.cc3.dbCode,
  'type': 0,
  'status': 0,
  'daily_goal': 1,
  'daily_goal_unit': 'times',
  'start_date': 1,
};

/// Minimum columns required for a raw SQL insert into mh_habits.
Map<String, Object?> _baseDbRow(String uuid, String name) => {
  'uuid': uuid,
  'name': name,
  'color': HabitColorType.cc3.dbCode,
  'type_': 0,
  'status': 0,
  'daily_goal': 1,
  'daily_goal_unit': 'times',
  'start_date': 1,
  'sort_position': 1,
};

/// Minimum required fields for [WebDavSyncGroupData.fromJson] to produce a
/// valid [GroupDBCell] that satisfies DB NOT NULL constraints.
Map<String, Object?> _baseGroupPayload(String uuid, String name) => {
  '_convert_type': 'group_',
  'uuid': uuid,
  'name': name,
  'status': 1,
};

void main() {
  group('Sync round-trip DB integration', () {
    late DBHelperViewModel viewModel;
    late SyncDBHelper syncHelper;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      viewModel = DBHelperViewModel();
      await viewModel.init();
      syncHelper = SyncDBHelper(viewModel.local);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      viewModel.dispose();
    });

    test('syncHabitDataToDb stores unknown in sync_extras column', () async {
      final data = WebDavSyncHabitData.fromJson({
        ..._basePayload('download-test-uuid', 'Download Test'),
        'unknown_group_id': 'g-db-test',
        'future_field': 42,
      });

      await syncHelper.syncHabitDataToDb(data);

      final rows = await viewModel.local.db.rawQuery(
        'SELECT sync_extras FROM mh_habits WHERE uuid = ?',
        ['download-test-uuid'],
      );
      expect(rows, hasLength(1));
      final extrasJson = rows.first['sync_extras'] as String?;
      expect(extrasJson, isNotNull);
      final extras = jsonDecode(extrasJson!) as Map<String, dynamic>;
      expect(extras['unknown_group_id'], 'g-db-test');
      expect(extras['future_field'], 42);
    });

    test(
      'syncHabitDataToDb with no unknown sets sync_extras to NULL',
      () async {
        final data = WebDavSyncHabitData.fromJson(
          _basePayload('no-unknown-uuid', 'No Unknown'),
        );

        await syncHelper.syncHabitDataToDb(data);

        final rows = await viewModel.local.db.rawQuery(
          'SELECT sync_extras FROM mh_habits WHERE uuid = ?',
          ['no-unknown-uuid'],
        );
        expect(rows, hasLength(1));
        expect(rows.first['sync_extras'], isNull);
      },
    );

    test('loadHabitDataFromBb passes syncExtras as unknown', () async {
      // Seed: insert habit + sync row directly via raw SQL
      await viewModel.local.db.insert('mh_habits', {
        ..._baseDbRow('upload-test-uuid', 'Upload Test'),
        'sync_extras': jsonEncode({
          'unknown_group_id': 'g-upload',
          'extra': 42,
        }),
      });
      await viewModel.local.db.insert('mh_sync', {
        'habit_uuid': 'upload-test-uuid',
        'dirty': 0,
        'dirty_total': 0,
      });

      final data = await syncHelper.loadHabitDataFromBb(
        'upload-test-uuid',
        withRecords: false,
        configId: 'test-config',
        sessionId: 'test-session',
      );

      expect(data, isNotNull);
      expect(data!.unknown, isNotNull);
      expect(data.unknown!['unknown_group_id'], 'g-upload');
      expect(data.unknown!['extra'], 42);

      final json = data.toJson();
      expect(json['unknown_group_id'], 'g-upload');
      expect(json['extra'], 42);
    });

    test(
      'loadHabitDataFromBb with null syncExtras returns null unknown',
      () async {
        await viewModel.local.db.insert('mh_habits', {
          ..._baseDbRow('null-extras-uuid', 'Null Extras'),
          'sync_extras': null,
        });
        await viewModel.local.db.insert('mh_sync', {
          'habit_uuid': 'null-extras-uuid',
          'dirty': 0,
          'dirty_total': 0,
        });

        final data = await syncHelper.loadHabitDataFromBb(
          'null-extras-uuid',
          withRecords: false,
          configId: 'test-config',
          sessionId: 'test-session',
        );

        expect(data, isNotNull);
        expect(data!.unknown, isNull);
      },
    );

    test('full DB round-trip preserves unknown fields', () async {
      final original = WebDavSyncHabitData.fromJson({
        ..._basePayload('full-db-roundtrip', 'Original'),
        'unknown_group_id': 'g-full',
        'custom_attr': [1, 2, 3],
      });

      // Download path: write to DB
      await syncHelper.syncHabitDataToDb(original);

      // Upload path: read back from DB
      final restored = await syncHelper.loadHabitDataFromBb(
        'full-db-roundtrip',
        withRecords: false,
        configId: 'test-config',
        sessionId: 'test-session',
      );

      expect(restored, isNotNull);
      expect(restored!.uuid, 'full-db-roundtrip');
      expect(restored.name, 'Original');

      expect(restored.unknown, isNotNull);
      expect(restored.unknown!['unknown_group_id'], 'g-full');
      expect(restored.unknown!['custom_attr'], [1, 2, 3]);
      final restoredJson = restored.toJson();
      expect(restoredJson['unknown_group_id'], 'g-full');
      expect(restoredJson['custom_attr'], [1, 2, 3]);
    });

    test('second download without unknown clears stale sync_extras', () async {
      final firstDownload = WebDavSyncHabitData.fromJson({
        ..._basePayload('clear-stale-uuid', 'Stale Extras'),
        'sessionId': 'server-session-1',
        'unknown_group_id': 'g-stale',
      });
      await syncHelper.syncHabitDataToDb(firstDownload);

      final secondDownload = WebDavSyncHabitData.fromJson({
        ..._basePayload('clear-stale-uuid', 'Stale Extras'),
        'sessionId': 'server-session-2',
      });
      await syncHelper.syncHabitDataToDb(secondDownload);

      final rows = await viewModel.local.db.rawQuery(
        'SELECT sync_extras FROM mh_habits WHERE uuid = ?',
        ['clear-stale-uuid'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['sync_extras'], isNull);

      final restored = await syncHelper.loadHabitDataFromBb(
        'clear-stale-uuid',
        withRecords: false,
        configId: 'test-config',
        sessionId: 'test-session',
      );

      expect(restored, isNotNull);
      expect(restored!.unknown, isNull);
      expect(restored.toJson().containsKey('unknown_group_id'), isFalse);
    });

    test('second download with partial unknown prunes removed fields', () async {
      // First download: two unknown fields.
      final firstDownload = WebDavSyncHabitData.fromJson({
        ..._basePayload('partial-prune-uuid', 'Partial Prune'),
        'sessionId': 'server-session-1',
        'removed_field': 'will-go',
        'kept_field': 99,
      });
      await syncHelper.syncHabitDataToDb(firstDownload);

      // Second download: 'removed_field' is gone from server, 'kept_field' remains.
      final secondDownload = WebDavSyncHabitData.fromJson({
        ..._basePayload('partial-prune-uuid', 'Partial Prune'),
        'sessionId': 'server-session-2',
        'kept_field': 99,
      });
      await syncHelper.syncHabitDataToDb(secondDownload);

      final rows = await viewModel.local.db.rawQuery(
        'SELECT sync_extras FROM mh_habits WHERE uuid = ?',
        ['partial-prune-uuid'],
      );
      expect(rows, hasLength(1));
      final extrasJson = rows.first['sync_extras'] as String?;
      expect(extrasJson, isNotNull);
      final extras = jsonDecode(extrasJson!) as Map<String, dynamic>;
      expect(extras, hasLength(1));
      expect(extras['kept_field'], 99);
      expect(extras.containsKey('removed_field'), isFalse);

      final restored = await syncHelper.loadHabitDataFromBb(
        'partial-prune-uuid',
        withRecords: false,
        configId: 'test-config',
        sessionId: 'test-session',
      );

      expect(restored, isNotNull);
      expect(restored!.unknown, isNotNull);
      expect(restored.unknown!.containsKey('removed_field'), isFalse);
      expect(restored.unknown!['kept_field'], 99);

      final restoredJson = restored.toJson();
      expect(restoredJson.containsKey('removed_field'), isFalse);
      expect(restoredJson['kept_field'], 99);
    });

    test(
      'syncGroupDataToDb inserts and loadGroupDataFromDb reads it back',
      () async {
        final groupData = WebDavSyncGroupData.fromJson(
          _baseGroupPayload('group-roundtrip-uuid', 'Roundtrip Group'),
        ).copyWith(etag: 'etag-1', sessionId: 'server-session-1');

        final inserted = await syncHelper.group.syncGroupDataToDb(
          groupData,
          configId: 'cfg',
          sessionId: 'session',
        );
        expect(inserted, isTrue);

        final restored = await syncHelper.group.loadGroupDataFromDb(
          'group-roundtrip-uuid',
          configId: 'cfg',
          sessionId: 'session',
        );
        expect(restored, isNotNull);
        expect(restored!.uuid, 'group-roundtrip-uuid');
        expect(restored.name, 'Roundtrip Group');
        expect(restored.etag, 'etag-1');
      },
    );

    test('clearGroupDirtyMark keeps newer local edits dirty', () async {
      final groupData = WebDavSyncGroupData.fromJson(
        _baseGroupPayload('group-clear-uuid', 'Group Clear'),
      ).copyWith(etag: 'etag-1', sessionId: 'server-session-1');
      await syncHelper.group.syncGroupDataToDb(
        groupData,
        configId: 'cfg',
        sessionId: 'session',
      );

      final snapshot = await syncHelper.group.loadGroupDataFromDb(
        'group-clear-uuid',
        configId: 'cfg',
        sessionId: 'session',
      );
      expect(snapshot, isNotNull);

      await viewModel.local.db.rawUpdate(
        'UPDATE mh_sync '
        'SET dirty = dirty + 1, dirty_total = COALESCE(dirty_total, 0) + 1 '
        'WHERE group_uuid = ?',
        ['group-clear-uuid'],
      );

      await syncHelper.group.clearGroupDirtyMark(
        snapshot!,
        etag: 'etag-2',
        configId: 'cfg',
        sessionId: 'session',
      );

      final rows = await viewModel.local.db.query(
        'mh_sync',
        where: 'group_uuid = ?',
        whereArgs: ['group-clear-uuid'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['dirty'], 1);
      expect(rows.first['dirty_total'], 1);
      expect(rows.first['last_mark_2'], 'etag-2');
    });

    test('group status=2 soft delete roundtrip is preserved', () async {
      final active = WebDavSyncGroupData.fromJson(
        _baseGroupPayload('group-soft-delete-uuid', 'Soft Delete Group'),
      ).copyWith(etag: 'etag-active', sessionId: 'server-session-active');
      await syncHelper.group.syncGroupDataToDb(
        active,
        configId: 'cfg',
        sessionId: 'session',
      );

      final deleted = WebDavSyncGroupData.fromJson({
        ..._baseGroupPayload('group-soft-delete-uuid', 'Soft Delete Group'),
        'status': 2,
      }).copyWith(etag: 'etag-deleted', sessionId: 'server-session-deleted');
      await syncHelper.group.syncGroupDataToDb(
        deleted,
        configId: 'cfg',
        sessionId: 'session',
      );

      final restored = await syncHelper.group.loadGroupDataFromDb(
        'group-soft-delete-uuid',
        configId: 'cfg',
        sessionId: 'session',
      );
      expect(restored, isNotNull);
      expect(restored!.status, 2);
      expect(restored.etag, 'etag-deleted');
    });

    test(
      'group update with same etag does not overwrite local edits',
      () async {
        final initial = WebDavSyncGroupData.fromJson(
          _baseGroupPayload('group-same-etag-uuid', 'Initial Name'),
        ).copyWith(etag: 'etag-same', sessionId: 'server-session-1');
        await syncHelper.group.syncGroupDataToDb(
          initial,
          configId: 'cfg',
          sessionId: 'session',
        );

        await viewModel.local.db.update(
          'mh_groups',
          {'name': 'Locally Edited Name'},
          where: 'uuid = ?',
          whereArgs: ['group-same-etag-uuid'],
        );

        final sameEtagPayload = WebDavSyncGroupData.fromJson(
          _baseGroupPayload('group-same-etag-uuid', 'Server Name Should Skip'),
        ).copyWith(etag: 'etag-same', sessionId: 'server-session-2');
        await syncHelper.group.syncGroupDataToDb(
          sameEtagPayload,
          configId: 'cfg',
          sessionId: 'session',
        );

        final rows = await viewModel.local.db.query(
          'mh_groups',
          columns: ['name'],
          where: 'uuid = ?',
          whereArgs: ['group-same-etag-uuid'],
        );
        expect(rows, hasLength(1));
        expect(rows.first['name'], 'Locally Edited Name');
      },
    );

    test(
      'loadGroupDataFromDb returns passed sessionId when dirty > 0',
      () async {
        final groupData = WebDavSyncGroupData.fromJson(
          _baseGroupPayload('group-dirty-uuid', 'Group Dirty'),
        ).copyWith(etag: 'etag-1', sessionId: 'server-session-1');
        await syncHelper.group.syncGroupDataToDb(
          groupData,
          configId: 'cfg',
          sessionId: 'session',
        );

        // Mark as dirty
        await viewModel.local.db.rawUpdate(
          'UPDATE mh_sync '
          'SET dirty = 1 '
          'WHERE group_uuid = ?',
          ['group-dirty-uuid'],
        );

        // Load with different sessionId should return the passed sessionId
        final loaded = await syncHelper.group.loadGroupDataFromDb(
          'group-dirty-uuid',
          configId: 'cfg',
          sessionId: 'passed-session-when-dirty',
        );
        expect(loaded, isNotNull);
        expect(loaded!.sessionId, 'passed-session-when-dirty');
      },
    );

    test(
      'loadGroupDataFromDb returns passed sessionId when configId mismatch',
      () async {
        final groupData = WebDavSyncGroupData.fromJson(
          _baseGroupPayload(
            'group-config-mismatch-uuid',
            'Group Config Mismatch',
          ),
        ).copyWith(etag: 'etag-1', sessionId: 'server-session-1');
        await syncHelper.group.syncGroupDataToDb(
          groupData,
          configId: 'cfg1',
          sessionId: 'session',
        );

        // Load with different configId should return the passed sessionId
        final loaded = await syncHelper.group.loadGroupDataFromDb(
          'group-config-mismatch-uuid',
          configId: 'cfg2', // different configId
          sessionId: 'passed-session-on-config-mismatch',
        );
        expect(loaded, isNotNull);
        expect(loaded!.sessionId, 'passed-session-on-config-mismatch');
      },
    );

    test(
      'loadGroupDataFromDb returns stored sessionId when clean and configId matches',
      () async {
        final groupData = WebDavSyncGroupData.fromJson(
          _baseGroupPayload('group-clean-uuid', 'Group Clean'),
        ).copyWith(etag: 'etag-1', sessionId: 'stored-server-session');
        await syncHelper.group.syncGroupDataToDb(
          groupData,
          configId: 'cfg',
          sessionId: 'session',
        );

        // Load with matching configId and clean state should return stored sessionId
        final loaded = await syncHelper.group.loadGroupDataFromDb(
          'group-clean-uuid',
          configId: 'cfg', // matching configId
          sessionId: 'passed-session-but-should-ignore',
        );
        expect(loaded, isNotNull);
        expect(loaded!.sessionId, 'stored-server-session');
      },
    );
  });
}
