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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/storage/db/handlers/group.dart';
import 'package:mhabit/storage/db/handlers/record.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Run with the bytemark compose server:
// MHABIT_TEST_WEBDAV_URL=http://127.0.0.1/ CI=true .flutter/bin/flutter test \
//   test_harness/webdav_sync_extras_live_test.dart
Future<void> _createDir(WebDavStdClient client, Uri path) async {
  final response = await (await client.dispatch(path).createDir()).close();
  expect(response.response.statusCode, HttpStatus.created);
  await response.parse();
}

Future<void> _writeJson(WebDavStdClient client, Uri path, Object data) async {
  final body = jsonEncode(data);
  final request = await client.dispatch(path).create(data: body);
  request.request.headers.contentType = ContentType.json;
  request.request.contentLength = utf8.encode(body).length;
  final response = await request.close();
  expect(
    response.response.statusCode,
    isIn([HttpStatus.created, HttpStatus.noContent]),
  );
  await response.parse();
}

Future<Map<String, dynamic>> _readJson(WebDavStdClient client, Uri path) async {
  final response = await (await client.dispatch(path).get()).close();
  expect(response.response.statusCode, HttpStatus.ok);
  await response.parse();
  return jsonDecode(response.body!) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final endpoint = Platform.environment['MHABIT_TEST_WEBDAV_URL'];
  test(
    'live WebDAV sync preserves unknown Habit, Group and Record fields',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final previousHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      final root = Uri.parse(
        endpoint!,
      ).resolve('sync-extras-${DateTime.now().microsecondsSinceEpoch}/');
      final config = AppWebDavSyncServer.newServer(
        identity: 'sync-extras-live',
        path: root.toString(),
        username: Platform.environment['MHABIT_TEST_WEBDAV_USER'] ?? 'admin',
        password:
            Platform.environment['MHABIT_TEST_WEBDAV_PASSWORD'] ?? '123456',
      );
      final client = WebDavAppSyncTask.buildWebDavClient(config);
      final paths = WebDavAppSyncPathBuilder(root);
      const habitUuid = 'sync-extras-live-habit';
      const recordUuid = 'sync-extras-live-record';
      const groupUuid = 'sync-extras-live-group';
      final habitPath = paths.habit(habitUuid).habitFile;
      final groupPath = paths.group(groupUuid);
      DBHelperViewModel? viewModel;
      Directory? dbDir;

      try {
        await _createDir(client, paths.root);
        await _createDir(client, paths.habitsDir);

        final record = WebDavSyncRecordData.fromJson({
          '_convert_type': 'record_',
          'uuid': recordUuid,
          'parent_uuid': habitUuid,
          'record_date': 20000,
          'record_type': 1,
          'record_value': 1,
          'sessionId': 'remote-seed',
          'future_record': {
            'nested': [1, 2],
          },
        });
        final habit = WebDavSyncHabitData.fromJson({
          '_convert_type': 'habit_',
          'uuid': habitUuid,
          'name': 'Remote Habit',
          'color': HabitColorType.cc3.dbCode,
          'type': HabitType.normal.dbCode,
          'status': HabitStatus.activated.dbCode,
          'daily_goal': 1,
          'daily_goal_unit': 'times',
          'start_date': 1,
          'sessionId': 'remote-seed',
          'future_habit': {
            'nested': [3, 4],
          },
        }).copyWith(records: {recordUuid: record});
        final group = WebDavSyncGroupData.fromJson({
          '_convert_type': 'group_',
          'uuid': groupUuid,
          'name': 'Remote Group',
          'status': 1,
          'future_group': {
            'nested': [5, 6],
          },
        });
        await _writeJson(client, habitPath, habit.toJson());
        await _writeJson(client, groupPath, group.toJson());

        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        dbDir = await Directory.systemTemp.createTemp('mhabit_webdav_live_');
        await databaseFactory.setDatabasesPath(dbDir.path);
        viewModel = DBHelperViewModel();
        await viewModel.init();
        final syncHelper = SyncDBHelper(viewModel.local);

        final firstSync = await WebDavAppSyncTaskExecutor.build(
          sessionId: 'live-download',
          config: config,
          syncDBHelper: syncHelper,
          overwriteClient: client,
        ).run();
        final firstHabitResult = (firstSync as WebDavAppSyncTaskMultiResult)
            .habitResults
            .values
            .single;
        expect(
          firstSync.isSuccessed,
          isTrue,
          reason:
              '$firstSync: ${firstHabitResult.error.error}\n'
              '${firstHabitResult.error.trace}',
        );

        final downloaded = await syncHelper.loadHabitDataFromBb(
          habitUuid,
          configId: config.identity,
          sessionId: 'check-download',
        );
        final downloadedGroup = await syncHelper.group.loadGroupDataFromDb(
          groupUuid,
          configId: config.identity,
          sessionId: 'check-download',
        );
        expect(downloaded!.toJson()['future_habit'], {
          'nested': [3, 4],
        });
        expect(downloaded.records[recordUuid]!.toJson()['future_record'], {
          'nested': [1, 2],
        });
        expect(downloadedGroup!.toJson()['future_group'], {
          'nested': [5, 6],
        });

        Future<void> expectStoredExtras(
          String table,
          String uuid,
          String key,
          Object value,
        ) async {
          final rows = await viewModel!.local.db.query(
            table,
            columns: ['sync_extras'],
            where: 'uuid = ?',
            whereArgs: [uuid],
          );
          expect(rows, hasLength(1));
          final extras =
              jsonDecode(rows.single['sync_extras']! as String)
                  as Map<String, dynamic>;
          expect(extras[key], value);
        }

        await expectStoredExtras('mh_habits', habitUuid, 'future_habit', {
          'nested': [3, 4],
        });
        await expectStoredExtras('mh_records', recordUuid, 'future_record', {
          'nested': [1, 2],
        });
        await expectStoredExtras('mh_groups', groupUuid, 'future_group', {
          'nested': [5, 6],
        });

        await RecordDBHelper(viewModel.local).updateRecord(
          RecordDBCell(uuid: recordUuid, parentUUID: habitUuid, recordValue: 2),
        );
        await GroupDBHelper(viewModel.local).updateExistGroup(
          const GroupDBCell(uuid: groupUuid, name: 'Locally Edited'),
        );

        final secondSync = await WebDavAppSyncTaskExecutor.build(
          sessionId: 'live-upload',
          config: config,
          syncDBHelper: syncHelper,
          overwriteClient: client,
        ).run();
        expect(secondSync.isSuccessed, isTrue, reason: '$secondSync');

        final uploadedHabit = WebDavSyncHabitData.fromJson(
          await _readJson(client, habitPath),
        );
        final uploadedGroup = WebDavSyncGroupData.fromJson(
          await _readJson(client, groupPath),
        );
        expect(uploadedHabit.toJson()['future_habit'], {
          'nested': [3, 4],
        });
        expect(uploadedHabit.records[recordUuid]!.recordValue, 2);
        expect(uploadedHabit.records[recordUuid]!.toJson()['future_record'], {
          'nested': [1, 2],
        });
        expect(uploadedGroup.name, 'Locally Edited');
        expect(uploadedGroup.toJson()['future_group'], {
          'nested': [5, 6],
        });
      } finally {
        viewModel?.dispose();
        if (dbDir != null) {
          try {
            await dbDir.delete(recursive: true);
          } on FileSystemException {
            // SQLite may finish closing just after the helper is disposed.
          }
        }
        try {
          final response = await (await client.dispatch(paths.root).deleteDir())
              .close();
          await response.parse();
        } finally {
          client.close(force: true);
          HttpOverrides.global = previousHttpOverrides;
          debugDefaultTargetPlatformOverride = null;
        }
      }
    },
    skip: endpoint == null || endpoint.isEmpty
        ? 'Set MHABIT_TEST_WEBDAV_URL to run against a WebDAV server.'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
