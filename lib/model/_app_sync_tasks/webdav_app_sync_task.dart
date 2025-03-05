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

import 'package:flutter/material.dart';
import 'package:pool/pool.dart';
import 'package:simple_webdav_client/client.dart';

import '../../common/async.dart';
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

class WebDavAppSyncTask extends AppSyncTaskFramework<AppSyncTaskResult> {
  @override
  final AppWebDavSyncServer config;

  final SyncDBHelper syncDBHelper;

  late final WebDavAppSyncTaskExecutor _task;

  WebDavAppSyncTask(
      {required this.config,
      required this.syncDBHelper,
      super.timeout = Duration.zero}) {
    _task = WebDavAppSyncTaskExecutor.build(
        config: config, syncDBHelper: syncDBHelper);
  }

  @override
  Future<AppSyncTaskResult> error([Object? e, StackTrace? s]) =>
      Future.sync(() => switch (e) {
            TimeoutException() =>
              WebDavAppSyncTaskResult.timeout(error: e, trace: s),
            _ => WebDavAppSyncTaskResult.error(error: e, trace: s),
          });

  @override
  Future<AppSyncTaskResult> exec() => _task.run();

  @override
  Future<void> cancel() {
    _task.cancel();
    return super.cancel();
  }
}

class WebDavAppSyncTaskExecutor
    extends AppSyncTaskFramework<AppSyncTaskResult> {
  @override
  final AppWebDavSyncServer config;

  final AsyncTask<List<WebDavResourceContainer>> fetchHabitsFromServerTask;
  final AsyncTask<List<SyncDBCell>> queryHabitsFromDbTask;
  final WebDavSyncHabitInfoMerger syncInfoMerger;

  final AsyncTask<WebDavAppSyncTaskResult> Function(
          WebDavAppSyncTaskExecutor crtTask, WebDavAppSyncHabitInfo cell)
      singleHabitSyncTaskBuilder;

  late final WeakReference<WebDavStdClient>? _client;

  WebDavAppSyncTaskExecutor({
    required this.config,
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
    final habitsPath = config.path.replace(pathSegments: [
      ...config.path.pathSegments.where((e) => e.isNotEmpty),
      'habits',
      ''
    ]);
    // TODO: indev
    return WebDavAppSyncTaskExecutor(
      config: config,
      fetchHabitsFromServerTask:
          FetchMemberMetaFromServerTask.habits(habitsPath, client),
      queryHabitsFromDbTask: QueryHabitsFromDBTask(helper: syncDBHelper),
      syncInfoMerger: const SyncHabitsInfoMergerImpl(),
      singleHabitSyncTaskBuilder: (crtTask, cell) => SingleHabitSyncTask(
        parent: crtTask,
        config: config,
        cell: cell,
        serverToLocalTask: (parent, config, cell) =>
            SingleHabitSyncTask.downloadTask(
          parent: parent,
          fetchRecordsFromServerTask: FetchHabitRecordsMetaFromServerTask.build(
              parent: parent,
              path: config.path.replace(pathSegments: [
                ...config.path.pathSegments.where((e) => e.isNotEmpty),
                'records',
                'habit-${cell.uuid}',
                ''
              ]),
              client: client),
          queryRecordsFromDbTask: QueryHabitRecordsFromDBTask(
              uuid: cell.uuid, helper: syncDBHelper),
          syncInfoMerger: SyncHabitRecordsInfoMergerImpl(cell.uuid),
          fetchHabitDataTask:
              FetchDataFromServerTask.fetchHabitDataFromServerBuilder(
                  path: cell.serverPath!, client: client),
          fetchRecordDataTaskBuilder: (cell) =>
              FetchDataFromServerTask.fetchRecordDataFromServerBuilder(
                  path: cell.serverPath!, client: client),
          writeToDbTaskBuilder: (cell) =>
              WriteToDBTask(data: cell, helper: syncDBHelper),
        ),
        localToServerTask: (parent, config, cell) async =>
            WebDavAppSyncTaskResult.success(),
      ),
      client: client,
    );
  }

  @override
  Future<AppSyncTaskResult> error(Object e, StackTrace s) =>
      Error.throwWithStackTrace(e, s);

  @override
  Future<AppSyncTaskResult> exec() {
    return doExec().whenComplete(() {
      final client = _client?.target;
      if (client != null && !client.closed) _client?.target?.close();
    });
  }

  Future<AppSyncTaskResult> doExec() async {
    final serverHabitsFuture = fetchHabitsFromServerTask.run();
    final localHabitsFuture = queryHabitsFromDbTask.run();
    final serverHabits = await serverHabitsFuture;
    if (isCancalling) return WebDavAppSyncTaskResult.cancelled();
    final localHabits = await localHabitsFuture;
    if (isCancalling) return WebDavAppSyncTaskResult.cancelled();
    final mergedResult =
        syncInfoMerger.convert((local: localHabits, server: serverHabits));
    final resultMap = <WebDavAppSyncHabitInfo, WebDavAppSyncTaskResult?>{};
    final pool = Pool(math.max(mergedResult.length, 5));
    await Future.wait(mergedResult.map(
      (cell) => pool
          .withResource(() async {
            if (isCancalling) return const WebDavAppSyncTaskResult.cancelled();
            return singleHabitSyncTaskBuilder(this, cell).run();
          })
          .onError((e, s) => WebDavAppSyncTaskResult.error(error: e, trace: s))
          .then((result) => resultMap.putIfAbsent(cell, () => result)),
    ));
    // TODO: indev
    debugPrint("$runtimeType: exec.doExec");
    resultMap.forEach(
        (k, v) => debugPrint("$k \n--> $v || ${v?.error.trace}\n---------"));
    return WebDavAppSyncTaskResult.success();
  }
}
