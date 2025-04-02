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
import 'package:retry/retry.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/utils.dart';

import '../../common/consts.dart';
import '../../common/exceptions.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';
import '../app_sync_server.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_subtasks.dart';

enum WebDavAppSyncTaskResultStatus {
  success,
  cancelled,
  timeout,
  error,
  failed
}

class WebDavAppSyncTaskResult implements AppSyncTaskResult {
  final WebDavAppSyncTaskResultStatus status;

  @override
  final ({Object? error, StackTrace? trace}) error;

  const WebDavAppSyncTaskResult._(
      {required this.status, Object? error, StackTrace? trace})
      : error = (error: error, trace: trace);

  const WebDavAppSyncTaskResult.success()
      : this._(status: WebDavAppSyncTaskResultStatus.success);

  const WebDavAppSyncTaskResult.failed()
      : this._(status: WebDavAppSyncTaskResultStatus.failed);

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

  final WebDavProgressController? progressController;
  final void Function(WebDavAppSyncTaskResult result)? onConfigTaskComplete;

  late final AppSyncTask<WebDavAppSyncTaskResult> _configTask;
  late final AppSyncTask<WebDavAppSyncTaskResult> _syncTask;
  late final String _sessionId;

  AppSyncTask<WebDavAppSyncTaskResult>? _crtTask;

  WebDavAppSyncTask({
    String? sessionId,
    required this.config,
    required SyncDBHelper syncDBHelper,
    Duration? configConfirmTimeout = const Duration(seconds: 60),
    this.progressController,
    FutureOr<bool> Function(WebDavConfigTaskChecklist checklist)?
        onNeedConfirmCallback,
    this.onConfigTaskComplete,
  }) : super(timeout: config.timeout ?? defaultAppSyncTimeout) {
    _sessionId = sessionId ?? genSessionId();
    _configTask = WebDavAppSyncConfigTask.build(
        sessionId: _sessionId,
        config: config,
        confirmTimeout: configConfirmTimeout,
        onNeedConfirmCallback: onNeedConfirmCallback);
    _syncTask = WebDavAppSyncTaskExecutor.build(
        sessionId: _sessionId,
        config: config,
        syncDBHelper: syncDBHelper,
        progressController: progressController);
  }

  static String genSessionId() {
    final random = math.Random();
    return List.generate(
        8, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  static WebDavStdClient buildWebDavClient(AppWebDavSyncServer config) {
    final connectRetryCount =
        config.connectRetryCount ?? defaultAppSyncConnectRetryCount;
    final httpClient = HttpClientForWebDav(
        connectRetryOptions: connectRetryCount != null
            ? RetryOptions(
                maxAttempts: connectRetryCount,
                maxDelay:
                    (config.connectTimeout ?? defaultAppSyncConnectTimeout) * 3)
            : null);
    if (config.ignoreSSL) {
      httpClient.badCertificateCallback = (cert, host, port) => true;
    }
    if (config.connectTimeout != Duration.zero) {
      httpClient.connectionTimeout = config.connectTimeout;
    }
    final client = WebDavStdClient.withClient(httpClient);
    if (config.username.isNotEmpty) {
      int count = 0;
      client.setAuthenticate((url, scheme, realm) async {
        if (count++ >= 3) {
          count = 0;
          return false;
        }
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

  @override
  String get sessionId => _sessionId;

  @override
  FutureOr<WebDavAppSyncTaskResult> error([Object? e, StackTrace? s]) {
    _crtTask?.cancel();
    return switch (e) {
      TimeoutException() => WebDavAppSyncTaskResult.timeout(error: e, trace: s),
      _ => WebDavAppSyncTaskResult.error(error: e, trace: s),
    };
  }

  List<
      ({
        AppSyncTask<WebDavAppSyncTaskResult> task,
        void Function(WebDavAppSyncTaskResult result)? onComplete,
      })> buildTaskConfigs() => [
        if (!config.configed)
          (task: _configTask, onComplete: onConfigTaskComplete),
        (task: _syncTask, onComplete: null),
      ];

  @override
  Future<WebDavAppSyncTaskResult> exec() async {
    final taskConfigs = buildTaskConfigs();
    var result = const WebDavAppSyncTaskResult.success();
    if (isDone) return this.result;
    for (var taskConfig in taskConfigs) {
      _crtTask = taskConfig.task;
      result = await doExecTask(taskConfig.task);
      if (isDone) return this.result;
      taskConfig.onComplete?.call(result);
      if (!result.isSuccessed) return result;
    }
    return result;
  }

  Future<WebDavAppSyncTaskResult> doExecTask(
      AppSyncTask<WebDavAppSyncTaskResult> task) {
    final future = task.run();
    appLog.appsynctask.info(task, ex: ['started', config]);
    return future.then((result) {
      if (result.isSuccessed || result.isCancelled) {
        appLog.appsynctask.info(task, ex: ['completed', result, config]);
      } else if (result.withError) {
        appLog.appsynctask.info(task,
            ex: ['comeplte with error', result, config],
            error: result.error.error,
            stackTrace: result.error.trace);
      } else {
        appLog.appsynctask.info(task,
            ex: ['comeplted', result, config],
            error: result.error.error,
            stackTrace: result.error.trace);
      }
      return result;
    });
  }

  @override
  Future<void> cancel() {
    _crtTask?.cancel();
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

  final WebDavProgressController? progressController;
  final AppSyncSubTask<List<WebDavResourceContainer>> fetchHabitsFromServerTask;
  final AppSyncSubTask<List<SyncDBCell>> queryHabitsFromDbTask;
  final WebDavSyncHabitInfoMerger Function(AppSyncContext context)
      syncInfoMergerBuilder;

  final AppSyncSubTask<WebDavAppSyncTaskResult> Function(
      WebDavAppSyncHabitInfo cell) singleHabitSyncTaskBuilder;

  late final WeakReference<WebDavStdClient>? _client;

  WebDavAppSyncTaskExecutor({
    required this.config,
    required this.sessionId,
    super.timeout = Duration.zero,
    this.progressController,
    required this.fetchHabitsFromServerTask,
    required this.queryHabitsFromDbTask,
    required this.syncInfoMergerBuilder,
    required this.singleHabitSyncTaskBuilder,
    WebDavStdClient? client,
  }) {
    _client = client != null ? WeakReference(client) : null;
  }

  factory WebDavAppSyncTaskExecutor.build({
    required String sessionId,
    required AppWebDavSyncServer config,
    required SyncDBHelper syncDBHelper,
    WebDavStdClient? overwriteClient,
    Duration? timeout,
    WebDavProgressController? progressController,
  }) {
    final client =
        overwriteClient ?? WebDavAppSyncTask.buildWebDavClient(config);

    return WebDavAppSyncTaskExecutor(
      sessionId: sessionId,
      config: config,
      client: overwriteClient == null ? client : null,
      timeout: timeout ?? Duration.zero,
      progressController: progressController,
      fetchHabitsFromServerTask: FetchMetaFromServerTask.habits(
          WebDavAppSyncPathBuilder(config.path).habitsDir, client),
      queryHabitsFromDbTask: QueryHabitsFromDBTask(helper: syncDBHelper),
      syncInfoMergerBuilder: SyncHabitsInfoMergerImpl.new,
      singleHabitSyncTaskBuilder: (cell) => SingleHabitSyncTask(
        config: config,
        cell: cell,
        serverToLocalTask: (context, config, cell) =>
            SingleHabitSyncTask.downloadTask(
          context: context,
          fetchRecordsFromServerTask: FetchHabitRecordsMetaFromServerTask.build(
              path: WebDavAppSyncPathBuilder(config.path)
                  .habit(cell.uuid)
                  .recordRootDir,
              client: client),
          queryRecordsFromDbTask: QueryHabitRecordsFromDBTask(
              uuid: cell.uuid, helper: syncDBHelper),
          syncInfoMerger: SyncHabitRecordsInfoMergerImpl(context, cell.uuid),
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
        localToServerTask: (context, config, cell) =>
            SingleHabitSyncTask.uploadTask(
          context: context,
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
    );
  }

  @override
  Future<WebDavAppSyncTaskResult> error(Object e, StackTrace s) {
    appLog.appsynctask
        .error(this, ex: ['un-catched error'], error: e, stackTrace: s);
    cancel();
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

    final mergedResult = syncInfoMergerBuilder(this)
        .convert((local: localHabits, server: serverHabits));
    appLog.appsynctask
        .debug(this, ex: ["merge habits completed", mergedResult.length]);

    final resultMap = <WebDavAppSyncHabitInfo, WebDavAppSyncTaskResult?>{};
    final pool = Pool(mergedResult.length.clamp(1, 5),
        timeout: config.timeout ?? defaultAppSyncTimeout);
    progressController?.initHabitProgress(mergedResult.map((e) => e.uuid),
        override: true);
    await Future.wait(mergedResult.map(
      (cell) => pool
          .withResource(() async {
            if (isCancalling) return const WebDavAppSyncTaskResult.cancelled();
            return singleHabitSyncTaskBuilder(cell).run(this);
            // .then((result) =>
            //    Future.delayed(Duration(milliseconds: 100), () => result))
          })
          .onError((e, s) => WebDavAppSyncTaskResult.error(error: e, trace: s))
          .then((result) => resultMap.putIfAbsent(cell, () => result))
          .whenComplete(() => progressController?.onHabitComplete(cell.uuid)),
    )).whenComplete(() => progressController?.clearHabitProgress());
    appLog.appsynctask.debug(this, ex: ["habits sync completed", resultMap]);

    // TODO: indev (multi result)
    resultMap.forEach((k, v) {
      if (v?.isSuccessed == true) return;
      appLog.debugger.debug("$k \n--> $v || ${v?.error.trace}\n---------");
    });
    return WebDavAppSyncTaskResult.success();
  }
}

class WebDavAppSyncConfigTask
    extends AppSyncTaskFramework<WebDavAppSyncTaskResult> {
  static const warningFileData = """⚠ WARNING ⚠

This directory is managed by an automatic WebDAV sync process of $appName.
Do NOT manually modify, delete, or add files/folders in this directory
unless you know exactly what you are doing.

Unexpected changes may lead to data loss or sync conflicts.

Proceed with caution!
""";

  @override
  final AppWebDavSyncServer config;
  @override
  final String sessionId;

  final Duration confirmTimeout;
  final AppSyncSubTask<WebDavConfigTaskChecklist> checkRootDirTask;
  final AppSyncSubTask createRootDir;
  final AppSyncSubTask createHabitsDir;
  final AppSyncSubTask createRecordsDir;
  final AppSyncSubTask createWarningFile;

  final FutureOr<bool> Function(WebDavConfigTaskChecklist checklist)?
      onNeedConfirmCallback;

  late final WeakReference<WebDavStdClient>? _client;

  WebDavAppSyncConfigTask({
    required this.config,
    required this.sessionId,
    super.timeout = Duration.zero,
    this.confirmTimeout = Duration.zero,
    required this.checkRootDirTask,
    required this.createRootDir,
    required this.createHabitsDir,
    required this.createRecordsDir,
    required this.createWarningFile,
    this.onNeedConfirmCallback,
    WebDavStdClient? client,
  }) {
    _client = client != null ? WeakReference(client) : null;
  }

  factory WebDavAppSyncConfigTask.build({
    required String sessionId,
    required AppWebDavSyncServer config,
    WebDavStdClient? overwriteClient,
    Duration? timeout,
    Duration? confirmTimeout,
    FutureOr<bool> Function(WebDavConfigTaskChecklist checklist)?
        onNeedConfirmCallback,
  }) {
    final client =
        overwriteClient ?? WebDavAppSyncTask.buildWebDavClient(config);

    final rootPathBuilder = WebDavAppSyncPathBuilder(config.path);
    final rootDir = rootPathBuilder.root;
    final habitsDir = rootPathBuilder.habitsDir;
    final recordsDir = rootPathBuilder.recordsDir;
    final warningFile = rootPathBuilder.warningFile;

    return WebDavAppSyncConfigTask(
        sessionId: sessionId,
        config: config,
        client: overwriteClient == null ? client : null,
        timeout: timeout ?? Duration.zero,
        confirmTimeout: timeout ?? Duration.zero,
        onNeedConfirmCallback: onNeedConfirmCallback,
        checkRootDirTask: CheckRootDirTask(
            expectedHabitsPath: habitsDir,
            expectedRecordsPath: recordsDir,
            expectedReadmePath: warningFile,
            fetchRootDirTask: FetchMetaFromServerTask(
              path: rootDir,
              client: client,
              depth: Depth.members,
              filter: (resource) =>
                  (resource..tryToRaiseError()).path.path != rootDir.path,
            )),
        createRootDir: MkDirOnServerTask(path: rootDir, client: client),
        createHabitsDir: MkDirOnServerTask(path: habitsDir, client: client),
        createRecordsDir: MkDirOnServerTask(path: recordsDir, client: client),
        createWarningFile: UploadDataToServerTask(
            path: warningFile, data: warningFileData, client: client));
  }

  @override
  Future<WebDavAppSyncTaskResult> error(Object e, StackTrace s) {
    appLog.appsynctask
        .error(this, ex: ['un-catched error'], error: e, stackTrace: s);
    cancel();
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
    var needCreatRoot = false;
    final checkResult = await checkRootDirTask
        .run(this)
        .onError<HttpStatusException>((e, s) async {
      if (e.status != HttpStatus.notFound) Error.throwWithStackTrace(e, s);
      needCreatRoot = true;
      return WebDavConfigTaskChecklist.dirChecker(
          needCreateHabitsDir: true,
          needCreateRecordsDir: true,
          needCreateWarningFile: true);
    });
    if (isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    final confirmedFuture =
        Future.value(onNeedConfirmCallback?.call(checkResult) ?? true);
    final confirmed = await (timeout != Duration.zero
        ? confirmedFuture.timeout(timeout, onTimeout: () => false)
        : confirmedFuture);

    if (isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    if (!confirmed) return const WebDavAppSyncTaskResult.failed();

    if (needCreatRoot) await createRootDir.run(this);
    await Future.wait([
      if (checkResult.needCreateHabitsDir) createHabitsDir.run(this),
      if (checkResult.needCreateRecordsDir) createRecordsDir.run(this),
      if (checkResult.needCreateWarningFile) createWarningFile.run(this)
    ]);
    return const WebDavAppSyncTaskResult.success();
  }
}
