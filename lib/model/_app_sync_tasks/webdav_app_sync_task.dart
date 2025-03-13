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

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:pool/pool.dart';
import 'package:simple_webdav_client/client.dart';

import '../../common/types.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';
import '../app_sync_server.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_subtasks.dart';

enum WebDavAppSyncTaskResultStatus { success, cancelled, timeout, error }

class WebDavAppSyncTaskResult implements AppSyncTaskResult {
  final WebDavAppSyncTaskResultStatus status;

  @override
  final ({Object? error, StackTrace? trace}) error;

  const WebDavAppSyncTaskResult._(
      {required this.status, Object? error, StackTrace? trace})
      : error = (error: error, trace: trace);

  const WebDavAppSyncTaskResult.success()
      : this._(status: WebDavAppSyncTaskResultStatus.success);

  const WebDavAppSyncTaskResult.cancelled({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.cancelled,
          error: error,
          trace: trace,
        );

  const WebDavAppSyncTaskResult.timeout({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.timeout,
          error: error,
          trace: trace,
        );

  const WebDavAppSyncTaskResult.error({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.error,
          error: error,
          trace: trace,
        );

  @override
  bool get isCancelled => status == WebDavAppSyncTaskResultStatus.cancelled;

  @override
  bool get isSuccessed => status == WebDavAppSyncTaskResultStatus.success;

  @override
  bool get isTimeout => status == WebDavAppSyncTaskResultStatus.timeout;

  @override
  bool get withError =>
      status == WebDavAppSyncTaskResultStatus.error || error.error != null;

  @override
  String toString() =>
      "WebDavAppSyncTaskResult(status=$status, " "error=${error.error})";
}

class WebDavAppSyncTask extends AppSyncTaskFramework<WebDavAppSyncTaskResult> {
  @override
  final AppWebDavSyncServer config;

  late final WebDavAppSyncTaskExecutor _task;
  late final String _sessionId;

  WebDavAppSyncTask(
      {required this.config,
      required SyncDBHelper syncDBHelper,
      super.timeout = Duration.zero}) {
    _sessionId = genSessionId();
    _task = WebDavAppSyncTaskExecutor.build(
        sessionId: _sessionId, config: config, syncDBHelper: syncDBHelper);
  }

  static String genSessionId() {
    final random = math.Random();
    return List.generate(
        8, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  String get sessionId => _sessionId;

  @override
  Future<WebDavAppSyncTaskResult> error([Object? e, StackTrace? s]) =>
      Future.sync(() => switch (e) {
            TimeoutException() =>
              WebDavAppSyncTaskResult.timeout(error: e, trace: s),
            _ => WebDavAppSyncTaskResult.error(error: e, trace: s),
          });

  @override
  Future<WebDavAppSyncTaskResult> exec() {
    final future = _task.run();
    appLog.appsynctask.info(this, ex: ['started', config, _task]);
    return future.then((result) {
      if (result.isSuccessed || result.isCancelled) {
        appLog.appsynctask.info(this, ex: ['completed', result, config, _task]);
      } else if (result.withError) {
        appLog.appsynctask.info(this,
            ex: ['comeplte with error', result, config, _task],
            error: result.error.error,
            stackTrace: result.error.trace);
      } else {
        appLog.appsynctask.info(this,
            ex: ['comeplted', result, config, _task],
            error: result.error.error,
            stackTrace: result.error.trace);
      }
      return result;
    });
  }

  @override
  Future<void> cancel() {
    _task.cancel();
    return super.cancel();
  }

  @override
  String toString() =>
      "WebDavAppSyncTask(sessionId=$sessionId, config=$config)";
}

class WebDavAppSyncTaskExecutor
    extends AppSyncTaskFramework<WebDavAppSyncTaskResult> {
  @override
  final AppWebDavSyncServer config;
  @override
  final String sessionId;

  final AppSyncSubTask<List<WebDavResourceContainer>> fetchHabitsFromServerTask;
  final AppSyncSubTask<List<SyncDBCell>> queryHabitsFromDbTask;
  final WebDavSyncHabitInfoMerger syncInfoMerger;

  final AppSyncSubTask<WebDavAppSyncTaskResult> Function(
      WebDavAppSyncHabitInfo cell) singleHabitSyncTaskBuilder;

  late final WeakReference<WebDavStdClient>? _client;

  WebDavAppSyncTaskExecutor({
    required this.config,
    required this.sessionId,
    super.timeout = Duration.zero,
    required this.fetchHabitsFromServerTask,
    required this.queryHabitsFromDbTask,
    required this.syncInfoMerger,
    required this.singleHabitSyncTaskBuilder,
    WebDavStdClient? client,
  }) {
    _client = client != null ? WeakReference(client) : null;
  }

  factory WebDavAppSyncTaskExecutor.build({
    required String sessionId,
    required AppWebDavSyncServer config,
    required SyncDBHelper syncDBHelper,
  }) {
    WebDavStdClient buildWebDavClient() {
      final httpClient = HttpClient();
      if (config.ignoreSSL) {
        httpClient.badCertificateCallback = (cert, host, port) => true;
      }
      final client = WebDavStdClient.withClient(httpClient);
      if (config.username.isNotEmpty) {
        int count = 0;
        client.setAuthenticate((url, scheme, realm) async {
          if (count++ >= 3) return false;
          if (scheme == "Digest") {
            client.addCredentials(config.path, realm ?? '',
                HttpClientDigestCredentials(config.username, config.password));
          } else {
            client.addCredentials(config.path, realm ?? '',
                HttpClientBasicCredentials(config.username, config.password));
          }
          return true;
        });
      }
      return client;
    }

    final client = buildWebDavClient();

    return WebDavAppSyncTaskExecutor(
      sessionId: sessionId,
      config: config,
      fetchHabitsFromServerTask: FetchMetaFromServerTask.habits(
          WebDavAppSyncPathBuilder(config.path).habitsDir, client),
      queryHabitsFromDbTask: QueryHabitsFromDBTask(helper: syncDBHelper),
      syncInfoMerger: const SyncHabitsInfoMergerImpl(),
      singleHabitSyncTaskBuilder: (cell) => SingleHabitSyncTask(
        config: config,
        cell: cell,
        serverToLocalTask: (parent, config, cell) =>
            SingleHabitSyncTask.downloadTask(
          context: parent,
          fetchRecordsFromServerTask: FetchHabitRecordsMetaFromServerTask.build(
              path: WebDavAppSyncPathBuilder(config.path)
                  .habit(cell.uuid)
                  .recordRootDir,
              client: client),
          queryRecordsFromDbTask: QueryHabitRecordsFromDBTask(
              uuid: cell.uuid, helper: syncDBHelper),
          syncInfoMerger: SyncHabitRecordsInfoMergerImpl(cell.uuid),
          fetchHabitDataTask:
              FetchDataFromServerTask.fetchHabitDataFromServerBuilder(
                  path: cell.serverPath!,
                  client: client,
                  etag: cell.eTagFromServer),
          fetchRecordDataTaskBuilder: (cell) =>
              FetchDataFromServerTask.fetchRecordDataFromServerBuilder(
                  path: cell.serverPath!,
                  client: client,
                  etag: cell.eTagFromServer),
          writeToDbTaskBuilder: (cell) =>
              WriteToDBTask(data: cell, helper: syncDBHelper),
        ),
        localToServerTask: (parent, config, cell) =>
            SingleHabitSyncTask.uploadTask(
          context: parent,
          loadFromDBTask: LoadFromDBTask(helper: syncDBHelper, uuid: cell.uuid),
          preprocessDirTaskBuilder: (data) =>
              PreprocessHabitWebDavCollectionTask.build(
                  path: config.path, data: data, client: client),
          uploadHabitToServerTaskBuilder: (data) => UploadHabitToServerTask(
            root: config.path,
            data: data,
            helper: syncDBHelper,
            uploadTaskBuilder: (path, data, [etag]) => UploadDataToServerTask(
                path: path, data: data, etag: etag, client: client),
          ),
        ),
      ),
      client: client,
    );
  }

  @override
  Future<WebDavAppSyncTaskResult> error(Object e, StackTrace s) {
    appLog.appsynctask
        .error(this, ex: ['un-catched error'], error: e, stackTrace: s);
    Error.throwWithStackTrace(e, s);
  }

  @override
  Future<WebDavAppSyncTaskResult> exec() {
    return doExec().whenComplete(() {
      final client = _client?.target;
      if (client != null && !client.closed) _client?.target?.close();
    });
  }

  Future<WebDavAppSyncTaskResult> doExec() async {
    final serverHabitsFuture = fetchHabitsFromServerTask.run(this);
    final localHabitsFuture = queryHabitsFromDbTask.run(this);

    final serverHabits = await serverHabitsFuture;
    appLog.appsynctask.debug(this,
        ex: ['fetch habits form server completed', serverHabits.length]);
    if (isCancalling) return WebDavAppSyncTaskResult.cancelled();

    final localHabits = await localHabitsFuture;
    appLog.appsynctask.debug(this,
        ex: ['fetch babits form local completed', localHabits.length]);
    if (isCancalling) return WebDavAppSyncTaskResult.cancelled();

    final mergedResult =
        syncInfoMerger.convert((local: localHabits, server: serverHabits));
    appLog.appsynctask
        .debug(this, ex: ["merge habits completed", mergedResult.length]);

    final resultMap = <WebDavAppSyncHabitInfo, WebDavAppSyncTaskResult?>{};
    final pool = Pool(math.max(mergedResult.length, 5));
    await Future.wait(mergedResult.map(
      (cell) => pool
          .withResource(() async {
            if (isCancalling) return const WebDavAppSyncTaskResult.cancelled();
            return singleHabitSyncTaskBuilder(cell).run(this);
          })
          .onError((e, s) => WebDavAppSyncTaskResult.error(error: e, trace: s))
          .then((result) => resultMap.putIfAbsent(cell, () => result)),
    ));
    appLog.appsynctask.debug(this, ex: ["habits sync completed", resultMap]);

    // TODO: indev (multi result)
    resultMap.forEach((k, v) =>
        appLog.debugger.debug("$k \n--> $v || ${v?.error.trace}\n---------"));
    return WebDavAppSyncTaskResult.success();
  }
}

class WebDavAppSyncPathBuilder {
  final Uri root;

  final Uri habitsDir;
  final Uri recordsDir;

  static Uri _buildPath(Uri root, String subDir) {
    return root.replace(pathSegments: [
      ...root.pathSegments.where((e) => e.isNotEmpty),
      subDir,
      ''
    ]);
  }

  WebDavAppSyncPathBuilder(this.root)
      : habitsDir = _buildPath(root, 'habits'),
        recordsDir = _buildPath(root, 'records');

  WebDavAppSyncHabitPathBuilder habit(HabitUUID uuid) =>
      WebDavAppSyncHabitPathBuilder(uuid, habitsDir, recordsDir);
}

class WebDavAppSyncHabitPathBuilder {
  final HabitUUID uuid;
  final Uri habitsDir;
  final Uri recordsDir;

  final Uri habitFile;
  final Uri recordRootDir;

  static Uri _buildHabitFile(Uri base, HabitUUID uuid) {
    return base.replace(pathSegments: [
      ...base.pathSegments.where((e) => e.isNotEmpty),
      'habit-$uuid.json'
    ]);
  }

  static Uri _buildHabitRecordDir(Uri base, HabitUUID uuid) {
    return base.replace(pathSegments: [
      ...base.pathSegments.where((e) => e.isNotEmpty),
      'habit-$uuid',
      ''
    ]);
  }

  static Uri _buildRecordSubDir(Uri base, int year) {
    return base.replace(pathSegments: [
      ...base.pathSegments.where((e) => e.isNotEmpty),
      year.toString(),
      ''
    ]);
  }

  WebDavAppSyncHabitPathBuilder(this.uuid, this.habitsDir, this.recordsDir)
      : habitFile = _buildHabitFile(habitsDir, uuid),
        recordRootDir = _buildHabitRecordDir(recordsDir, uuid);

  Uri recordSubDir(int year) => _buildRecordSubDir(recordRootDir, year);

  WebDavAppSyncRecordPathBuilder record(
          HabitRecordUUID uuid, DateTime recordDate) =>
      WebDavAppSyncRecordPathBuilder(uuid, recordSubDir(recordDate.year));
}

class WebDavAppSyncRecordPathBuilder {
  final HabitRecordUUID uuid;
  final Uri recordSubDir;

  final Uri recordFile;

  static Uri _buildRecordFile(Uri base, HabitRecordUUID uuid) {
    return base.replace(pathSegments: [
      ...base.pathSegments.where((e) => e.isNotEmpty),
      'record-$uuid.json'
    ]);
  }

  WebDavAppSyncRecordPathBuilder(this.uuid, this.recordSubDir)
      : recordFile = _buildRecordFile(recordSubDir, uuid);
}
