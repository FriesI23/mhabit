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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/async.dart';
import 'package:mhabit/model/app_sync_server.dart';
import 'package:mhabit/model/app_sync_task.dart';
import 'package:mhabit/persistent/local/handler/sync.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  AppWebDavSyncServer,
  AppSyncServer,
  AsyncTask,
])
import 'webdav_app_sync_task_test.mocks.dart';

void testWebdavAppSyncTaskMainBody() =>
    group("test WebdavAppSyncTaskMainBody", () {
      late AsyncTask<List<WebDavResourceContainer>> fetchHabitsFromServerTask;
      late AsyncTask<List<SyncDBCell>> queryHabitsFromDbTask;
      late WebDavAppSyncTaskMainBody task;

      test("test normal progress", () async {
        final config = MockAppWebDavSyncServer();
        fetchHabitsFromServerTask = MockAsyncTask();
        when(fetchHabitsFromServerTask.run()).thenAnswer((inv) async => [
              WebDavResourceContainer(
                  path: Uri.parse("/a/habit-x1.json"), etag: 'xxx1'),
              WebDavResourceContainer(
                  path: Uri.parse("/a/habit-x2.json"), etag: 'xxx2'),
              WebDavResourceContainer(
                  path: Uri.parse("/a/habit-x3.json"), etag: 'xxx3'),
            ]);

        queryHabitsFromDbTask = MockAsyncTask();
        when(queryHabitsFromDbTask.run()).thenAnswer((inv) async => []);
        task = WebDavAppSyncTaskMainBody(
            config: config,
            fetchHabitsFromServerTask: fetchHabitsFromServerTask,
            queryHabitsFromDbTask: queryHabitsFromDbTask);
        final result = await task.run();
        expect(result.isSuccessed, isTrue);
      });
    });

void main() {
  testWebdavAppSyncTaskMainBody();
}
