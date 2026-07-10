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

// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/storage/db/handlers/sync.dart';
import 'package:mhabit/storage/db/handlers/sync_group.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([])
@GenerateMocks([AppSyncSubTask, AppWebDavSyncServer, SyncGroupDBHelper])
import 'webdav_app_sync_group_subtasks_test.mocks.dart';

class _FakeAppSyncServer extends Fake implements AppSyncServer {
  @override
  String get identity => 'cfg-1';

  @override
  Duration? get timeout => null;
}

class _FakeAppSyncContext extends Fake implements AppSyncContext {
  @override
  final String sessionId = 'sid-1';
  bool _cancelling = false;

  @override
  AppSyncServer get config => _FakeAppSyncServer();

  @override
  AppSyncTaskStatus get status => AppSyncTaskStatus.running;

  @override
  bool get isProcessing => true;

  @override
  bool get isCancalling => _cancelling;

  void setCancelling(bool v) => _cancelling = v;

  @override
  bool get isDone => false;
}

class _FakeSyncDBHelper extends Fake implements SyncDBHelper {
  final SyncGroupDBHelper _group;
  _FakeSyncDBHelper(this._group);

  @override
  SyncGroupDBHelper get group => _group;
}

AppSyncSubTask<T> _fakeSubTask<T>(T value) => _FakeAppSyncSubTask(value);

AppSyncSubTask<WebDavAppSyncTaskResult> _fakeSubTaskWithResult(
  WebDavAppSyncTaskResult value,
) => _FakeAppSyncSubTask(value);

class _FakeAppSyncSubTask<T> implements AppSyncSubTask<T> {
  final T _value;
  const _FakeAppSyncSubTask(this._value);

  @override
  Future<T> run(AppSyncContext context) async => _value;
}

void main() {
  group("QueryGroupsFromDBTask", () {
    test("delegates to helper.group.loadAllGroupsSyncInfo", () async {
      final groupHelper = MockSyncGroupDBHelper();
      final helper = _FakeSyncDBHelper(groupHelper);
      when(
        groupHelper.loadAllGroupsSyncInfo(),
      ).thenAnswer((_) async => [SyncDBCell(groupUUID: 'g1')]);

      final task = QueryGroupsFromDBTask(helper: helper);
      final result = await task.run(_FakeAppSyncContext());

      expect(result, hasLength(1));
      expect(result.first.groupUUID, 'g1');
      verify(groupHelper.loadAllGroupsSyncInfo()).called(1);
    });
  });

  group("SyncGroupsInfoMergerImpl", () {
    late AppSyncContext context;

    setUp(() {
      context = _FakeAppSyncContext();
    });

    test("local-only cell is marked local with dirty support", () {
      final merger = SyncGroupsInfoMergerImpl(context);
      final result = merger.convert((
        local: [
          SyncDBCell(
            groupUUID: 'g1',
            dirtyTotal: 1,
            lastMark2: 'a',
            lastConfigUUID: 'c0',
          ),
        ],
        server: <WebDavResourceContainer>[],
      ));

      expect(result, hasLength(1));
      expect(result.first.uuid, 'g1');
      expect(result.first.status, WebDavAppSyncInfoStatus.local);
      expect(result.first.includeDirtyMark, isTrue);
    });

    test("server-only cell is marked server with etag and path", () {
      final merger = SyncGroupsInfoMergerImpl(context);
      final result = merger.convert((
        local: <SyncDBCell>[],
        server: [
          WebDavResourceContainer(
            path: Uri.parse('/a/group-g1.json'),
            etag: 'e1',
          ),
        ],
      ));

      expect(result, hasLength(1));
      expect(result.first.uuid, 'g1');
      expect(result.first.status, WebDavAppSyncInfoStatus.server);
      expect(result.first.eTagFromServer, 'e1');
      expect(result.first.serverPath?.toString(), endsWith('group-g1.json'));
    });

    test("overlapping local+server produces both status", () {
      final merger = SyncGroupsInfoMergerImpl(context);
      final result = merger.convert((
        local: [SyncDBCell(groupUUID: 'g1', dirtyTotal: 0, lastMark2: 'a')],
        server: [
          WebDavResourceContainer(
            path: Uri.parse('/a/group-g1.json'),
            etag: 'e1',
          ),
        ],
      ));

      expect(result, hasLength(1));
      final info = result.first;
      expect(info.status, WebDavAppSyncInfoStatus.both);
      expect(info.eTagFromLocal, 'a');
      expect(info.eTagFromServer, 'e1');
      expect(info.includeDirtyMark, isFalse);
    });
  });

  group("SingleGroupSyncTask", () {
    late WebDavAppSyncGroupInfo cell;

    setUp(() {
      cell = WebDavAppSyncGroupInfo(
        configUUID: 'cfg-1',
        uuid: 'g1',
        status: WebDavAppSyncInfoStatus.both,
      );
    });

    test("download-only when cell only needs download", () async {
      cell.eTagFromLocal = null;
      cell.eTagFromServer = 'e1';

      var serverCalled = false;

      final task = SingleGroupSyncTask(
        cell: cell,
        serverToLocalTask: (c, c2) async {
          serverCalled = true;
          expect(c2.uuid, 'g1');
          return WebDavAppSyncTaskResult.success();
        },
        localToServerTask: (c, c2) async {
          return WebDavAppSyncTaskResult.success();
        },
      );

      final result = await task.run(_FakeAppSyncContext());
      expect(result.isSuccessed, isTrue);
      expect(serverCalled, isTrue);
    });

    test("runs download-then-upload when both needed", () async {
      cell.eTagFromLocal = 'a';
      cell.eTagFromServer = 'b';
      cell.makeDirty();

      final calls = <String>[];
      final task = SingleGroupSyncTask(
        cell: cell,
        serverToLocalTask: (c, c2) async {
          calls.add('download');
          return WebDavAppSyncTaskResult.success();
        },
        localToServerTask: (c, c2) async {
          calls.add('upload');
          return WebDavAppSyncTaskResult.success();
        },
      );

      await task.run(_FakeAppSyncContext());
      expect(calls, ['download', 'upload']);
    });

    test("stops early when download fails", () async {
      cell.eTagFromLocal = 'a';
      cell.eTagFromServer = 'b';

      var uploadCalled = false;
      final task = SingleGroupSyncTask(
        cell: cell,
        serverToLocalTask: (c, c2) async => WebDavAppSyncTaskResult.failed(),
        localToServerTask: (c, c2) async {
          uploadCalled = true;
          return WebDavAppSyncTaskResult.success();
        },
      );

      final result = await task.run(_FakeAppSyncContext());
      expect(result.isSuccessed, isFalse);
      expect(uploadCalled, isFalse);
    });
  });

  group("GroupSyncTask", () {
    late AppSyncContext ctx;

    setUp(() {
      ctx = _FakeAppSyncContext();
    });

    test("noop when merged cells are empty", () async {
      final task = GroupSyncTask(
        fetchMetaFromServer: _fakeSubTask(<WebDavResourceContainer>[]),
        queryFromDb: _fakeSubTask(<SyncDBCell>[]),
        mergerBuilder: (_) => SyncGroupsInfoMergerImpl(_FakeAppSyncContext()),
        singleTaskBuilder: (_) =>
            _fakeSubTaskWithResult(WebDavAppSyncTaskResult.success()),
      );

      final result = await task.run(ctx);
      expect(result, isEmpty);
    });

    test("runs single task for each merged cell", () async {
      final cell1 = WebDavResourceContainer(
        path: Uri.parse('/a/group-g1.json'),
        etag: 'e1',
      );
      final seenCells = <String>[];

      final task = GroupSyncTask(
        fetchMetaFromServer: _fakeSubTask([cell1]),
        queryFromDb: _fakeSubTask(<SyncDBCell>[]),
        mergerBuilder: SyncGroupsInfoMergerImpl.new,
        singleTaskBuilder: (cell) {
          seenCells.add(cell.uuid);
          return _fakeSubTaskWithResult(WebDavAppSyncTaskResult.success());
        },
      );

      final result = await task.run(ctx);
      expect(result, hasLength(1));
      expect(seenCells, ['g1']);
      expect(result.values.first.isSuccessed, isTrue);
    });
  });

  group("WriteGroupToDBTask", () {
    test("calls helper.group.syncGroupDataToDb and returns success", () async {
      final groupHelper = MockSyncGroupDBHelper();
      final helper = _FakeSyncDBHelper(groupHelper);
      when(
        groupHelper.syncGroupDataToDb(
          any,
          configId: anyNamed('configId'),
          sessionId: anyNamed('sessionId'),
        ),
      ).thenAnswer((_) async => true);

      final ctx = _FakeAppSyncContext();

      final data = WebDavSyncGroupData(uuid: 'g1');
      final task = WriteGroupToDBTask(helper: helper, data: data);
      final result = await task.run(ctx);

      expect(result.isSuccessed, isTrue);
      verify(
        groupHelper.syncGroupDataToDb(
          data,
          configId: 'cfg-1',
          sessionId: 'sid-1',
        ),
      ).called(1);
    });
  });

  group("LoadGroupFromDBTask", () {
    test("calls helper.group.loadGroupDataFromDb", () async {
      final groupHelper = MockSyncGroupDBHelper();
      final helper = _FakeSyncDBHelper(groupHelper);
      final expected = WebDavSyncGroupData(uuid: 'g1');
      when(
        groupHelper.loadGroupDataFromDb(
          'g1',
          configId: 'cfg-1',
          sessionId: 'sid-1',
        ),
      ).thenAnswer((_) async => expected);

      final ctx = _FakeAppSyncContext();

      final task = LoadGroupFromDBTask(helper: helper, uuid: 'g1');
      final result = await task.run(ctx);

      expect(result?.uuid, 'g1');
    });
  });
}
