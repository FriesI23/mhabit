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
        'group_id': 'g-db-test',
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
      expect(extras['group_id'], 'g-db-test');
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
        'sync_extras': jsonEncode({'group_id': 'g-upload', 'extra': 42}),
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
      expect(data.unknown!['group_id'], 'g-upload');
      expect(data.unknown!['extra'], 42);

      final json = data.toJson();
      expect(json['group_id'], 'g-upload');
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
        'group_id': 'g-full',
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
      expect(restored.unknown!['group_id'], 'g-full');
      expect(restored.unknown!['custom_attr'], [1, 2, 3]);
      final restoredJson = restored.toJson();
      expect(restoredJson['group_id'], 'g-full');
      expect(restoredJson['custom_attr'], [1, 2, 3]);
    });

    test('second download without unknown clears stale sync_extras', () async {
      final firstDownload = WebDavSyncHabitData.fromJson({
        ..._basePayload('clear-stale-uuid', 'Stale Extras'),
        'sessionId': 'server-session-1',
        'group_id': 'g-stale',
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
      expect(restored.toJson().containsKey('group_id'), isFalse);
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
  });
}
