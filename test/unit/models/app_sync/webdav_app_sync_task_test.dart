// Copyright 2025 Fries_I23
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

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  Converter,
  AppWebDavSyncServer,
  AppSyncServer,
  AppSyncContext,
  AppSyncSubTask,
])
@GenerateNiceMocks([
  MockSpec<AppSyncSubTask<WebDavAppSyncTaskResult>>(
    as: #MockAppSyncSubTaskWithResult,
  ),
])
import 'webdav_app_sync_task_test.mocks.dart';

void testWebdavAppSyncTaskMainBody() =>
    group("test WebdavAppSyncTaskMainBody", () {
      late AppSyncSubTask<List<WebDavResourceContainer>>
      fetchHabitsFromServerTask;
      late AppSyncSubTask<List<SyncDBCell>> queryHabitsFromDbTask;
      late WebDavSyncHabitInfoMerger syncInfoMerger;
      late AppSyncSubTask<Map<WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>>
      groupSyncSubTask;
      late WebDavAppSyncTaskExecutor task;

      test("test normal progress", () async {
        final config = MockAppWebDavSyncServer();
        when(config.timeout).thenReturn(null);

        fetchHabitsFromServerTask = MockAppSyncSubTask();
        queryHabitsFromDbTask = MockAppSyncSubTask();
        syncInfoMerger = MockConverter();
        groupSyncSubTask = MockAppSyncSubTask();

        final singleHabitTasks = <AppSyncSubTask<WebDavAppSyncTaskResult>>[];

        task = WebDavAppSyncTaskExecutor(
          sessionId: '123',
          config: config,
          fetchHabitsMetaFromServerTask: fetchHabitsFromServerTask,
          queryHabitsFromDbTask: queryHabitsFromDbTask,
          syncInfoMergerBuilder: (context) => syncInfoMerger,
          singleHabitSyncTaskBuilder: (cell) {
            final task = MockAppSyncSubTaskWithResult();
            when(
              task.run(any),
            ).thenAnswer((_) async => WebDavAppSyncTaskResult.success());
            singleHabitTasks.add(task);
            return task;
          },
          groupSyncSubTask: groupSyncSubTask,
        );

        final serverResult = [
          WebDavResourceContainer(
            path: Uri.parse("/a/habit-x1.json"),
            etag: 'xxx1',
          ),
          WebDavResourceContainer(
            path: Uri.parse("/a/habit-x2.json"),
            etag: 'xxx2',
          ),
          WebDavResourceContainer(
            path: Uri.parse("/a/habit-x3.json"),
            etag: 'xxx3',
          ),
        ];
        when(groupSyncSubTask.run(task)).thenAnswer(
          (_) async => <WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>{},
        );
        when(
          fetchHabitsFromServerTask.run(task),
        ).thenAnswer((inv) async => serverResult);

        final localResult = <SyncDBCell>[
          SyncDBCell(habitUUID: 'z1'),
          SyncDBCell(habitUUID: 'z2', lastMark: 'zzz2'),
        ];
        when(
          queryHabitsFromDbTask.run(task),
        ).thenAnswer((inv) async => localResult);

        final mergeResult = <WebDavAppSyncHabitInfo>[
          WebDavAppSyncHabitInfo(
            configUUID: 'yy1',
            uuid: 'xx1',
            status: WebDavAppSyncInfoStatus.both,
          ),
          WebDavAppSyncHabitInfo(
            configUUID: 'yy1',
            uuid: 'xx2',
            status: WebDavAppSyncInfoStatus.server,
          ),
        ];
        when(
          syncInfoMerger.convert((local: localResult, server: serverResult)),
        ).thenReturn(mergeResult);

        final result = await task.run();

        expect(result.isSuccessed, isTrue);
        verify(config.timeout).called(1);
        verify(fetchHabitsFromServerTask.run(task)).called(1);
        verify(queryHabitsFromDbTask.run(task)).called(1);
        verify(
          syncInfoMerger.convert((local: localResult, server: serverResult)),
        ).called(1);
        for (var singleHabitTask in singleHabitTasks) {
          verify(singleHabitTask.run(task)).called(1);
        }
      });

      test("successful download reports the applied habit once", () async {
        final config = MockAppWebDavSyncServer();
        final context = MockAppSyncContext();
        when(context.sessionId).thenReturn('session-1');
        when(context.status).thenReturn(AppSyncTaskStatus.running);
        final applied = <String>[];
        final cell = WebDavAppSyncHabitInfo(
          configUUID: 'config',
          uuid: 'habit-1',
          status: WebDavAppSyncInfoStatus.server,
        );
        final task = SingleHabitSyncTask(
          config: config,
          cell: cell,
          onDownloadApplied: applied.add,
          serverToLocalTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
          localToServerTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
        );

        final result = await task.run(context);

        expect(result.isSuccessed, isTrue);
        expect(applied, ['habit-1']);
      });

      test("failed download does not report an applied habit", () async {
        final config = MockAppWebDavSyncServer();
        final context = MockAppSyncContext();
        when(context.sessionId).thenReturn('session-1');
        when(context.status).thenReturn(AppSyncTaskStatus.running);
        final applied = <String>[];
        final task = SingleHabitSyncTask(
          config: config,
          cell: WebDavAppSyncHabitInfo(
            configUUID: 'config',
            uuid: 'habit-1',
            status: WebDavAppSyncInfoStatus.server,
          ),
          onDownloadApplied: applied.add,
          serverToLocalTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.failed(),
          localToServerTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
        );

        await task.run(context);

        expect(applied, isEmpty);
      });

      test("successful download remains reported when upload fails", () async {
        final config = MockAppWebDavSyncServer();
        final context = MockAppSyncContext();
        when(context.sessionId).thenReturn('session-1');
        when(context.status).thenReturn(AppSyncTaskStatus.running);
        final applied = <String>[];
        final cell =
            WebDavAppSyncHabitInfo(
                configUUID: 'config',
                uuid: 'habit-1',
                status: WebDavAppSyncInfoStatus.both,
              )
              ..eTagFromLocal = 'local'
              ..eTagFromServer = 'server'
              ..makeDirty();
        final task = SingleHabitSyncTask(
          config: config,
          cell: cell,
          onDownloadApplied: applied.add,
          serverToLocalTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
          localToServerTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.failed(),
        );

        final result = await task.run(context);

        expect(result.isSuccessed, isFalse);
        expect(applied, ['habit-1']);
      });

      test(
        "successful download remains reported when upload is cancelled",
        () async {
          final config = MockAppWebDavSyncServer();
          final context = MockAppSyncContext();
          when(context.sessionId).thenReturn('session-1');
          when(context.status).thenReturn(AppSyncTaskStatus.running);
          final applied = <String>[];
          final cell =
              WebDavAppSyncHabitInfo(
                  configUUID: 'config',
                  uuid: 'habit-1',
                  status: WebDavAppSyncInfoStatus.both,
                )
                ..eTagFromLocal = 'local'
                ..eTagFromServer = 'server'
                ..makeDirty();
          final task = SingleHabitSyncTask(
            config: config,
            cell: cell,
            onDownloadApplied: applied.add,
            serverToLocalTask: (_, _, _) async =>
                WebDavAppSyncTaskResult.success(),
            localToServerTask: (_, _, _) async =>
                WebDavAppSyncTaskResult.cancelled(),
          );

          final result = await task.run(context);

          expect(result.isCancelled, isTrue);
          expect(applied, ['habit-1']);
        },
      );

      test("upload-only sync does not report an applied habit", () async {
        final config = MockAppWebDavSyncServer();
        final context = MockAppSyncContext();
        when(context.sessionId).thenReturn('session-1');
        when(context.status).thenReturn(AppSyncTaskStatus.running);
        final applied = <String>[];
        final task = SingleHabitSyncTask(
          config: config,
          cell: WebDavAppSyncHabitInfo(
            configUUID: 'config',
            uuid: 'habit-1',
            status: WebDavAppSyncInfoStatus.local,
          ),
          onDownloadApplied: applied.add,
          serverToLocalTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
          localToServerTask: (_, _, _) async =>
              WebDavAppSyncTaskResult.success(),
        );

        final result = await task.run(context);

        expect(result.isSuccessed, isTrue);
        expect(applied, isEmpty);
      });
    });

void main() {
  testWebdavAppSyncTaskMainBody();
}
