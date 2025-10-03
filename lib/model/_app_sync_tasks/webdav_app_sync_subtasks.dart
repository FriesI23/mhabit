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
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart' hide IterableExtension;

import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../storage/db/handlers/sync.dart';
import '../app_sync_server.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_task_status.dart';

typedef WebDavSyncInfoMergerInput = ({
  Iterable<SyncDBCell> local,
  Iterable<WebDavResourceContainer> server
});

typedef WebDavSyncHabitInfoMerger
    = Converter<WebDavSyncInfoMergerInput, List<WebDavAppSyncHabitInfo>>;

class FetchMetaFromServerTask
    implements AppSyncSubTask<List<WebDavResourceContainer>> {
  final Uri path;
  final WebDavStdClient client;
  final Depth depth;
  final bool Function(WebDavStdResource resource)? filter;

  const FetchMetaFromServerTask({
    required this.path,
    required this.client,
    required this.depth,
    this.filter,
  });

  static bool _filterFiles(
      WebDavStdResource resource, Uri path, WebDavStdClient client,
      [RegExp? filenameFilter]) {
    if (resource.path.path == path.path) {
      resource.tryToRaiseError();
      return false;
    }
    final filename =
        resource.path.pathSegments.where((e) => e.isNotEmpty).lastOrNull;
    if (filename == null) return false;
    if (!(filenameFilter?.hasMatch(filename) ?? true)) return false;
    if (resource.isCollection) return false;
    resource.tryToRaiseError();
    return true;
  }

  factory FetchMetaFromServerTask.habits(Uri path, WebDavStdClient client) =>
      FetchMetaFromServerTask(
        path: path,
        client: client,
        depth: Depth.members,
        filter: (resource) =>
            _filterFiles(resource, path, client, reAppSyncHabitFileName),
      );

  @override
  Future<List<WebDavResourceContainer>> run(AppSyncContext context) => client
      .dispatch(path)
      .findProps(props: const [
        PropfindRequestProp.dav(WebDavElementNames.getetag),
        PropfindRequestProp.dav(WebDavElementNames.resourcetype),
      ], depth: depth)
      .then((request) => request.close())
      .then((response) async => (await response.parse(), response))
      .then((value) {
        final resources = value.$1;
        final response = value.$2;
        appLog.appsynctask.info(context, ex: [
          "fetch resource props",
          response.path,
          response.response.statusCode,
          resources?.length
        ]);
        // appLog.appsynctask.debug(context, ex: [
        //   "fetch resource props",
        //   response.path,
        //   response.response.statusCode,
        //   response.body,
        //   resources?.toDebugString
        // ]);
        return resources
                ?.where(filter ?? (e) => true)
                .map((resource) => WebDavResourceContainer.fromResource(
                    resource,
                    overridePath: path.resolveUri(resource.path)))
                .toList() ??
            [];
      });
}

class QueryHabitsFromDBTask implements AppSyncSubTask<List<SyncDBCell>> {
  final SyncDBHelper helper;

  const QueryHabitsFromDBTask({required this.helper});

  @override
  Future<List<SyncDBCell>> run(AppSyncContext context) =>
      helper.loadAllHabitsSyncInfo().then((result) => result.toList());
}

final class SyncHabitsInfoMergerImpl extends WebDavSyncHabitInfoMerger {
  final AppSyncContext context;

  const SyncHabitsInfoMergerImpl(this.context);

  @override
  List<WebDavAppSyncHabitInfo> convert(
      ({
        Iterable<SyncDBCell> local,
        Iterable<WebDavResourceContainer> server
      }) input) {
    final coll = <HabitUUID, WebDavAppSyncHabitInfo>{};
    for (var data in input.local) {
      final uuid = data.habitUUID;
      if (uuid == null) continue;
      final cell = coll.putIfAbsent(
        uuid,
        () => WebDavAppSyncHabitInfo(
            configUUID: context.config.identity,
            uuid: uuid,
            status: WebDavAppSyncInfoStatus.local),
      )
        ..eTagFromLocal = data.lastMark2
        ..status = WebDavAppSyncInfoStatus.local
        ..lastConfgUUID = data.lastConfigUUID;
      if ((data.dirtyTotal ?? 0) != 0) cell.makeDirty();
    }
    for (var data in input.server) {
      final uuid = data.habitUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncHabitInfo(
              configUUID: context.config.identity,
              uuid: uuid,
              status: WebDavAppSyncInfoStatus.server))
        ..eTagFromServer = data.etag
        ..status = WebDavAppSyncInfoStatus.server
        ..serverPath = data.path;
    }
    return coll.values.toList();
  }
}

class SingleHabitSyncTask implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final AppWebDavSyncServer config;
  final WebDavAppSyncHabitInfo cell;
  final Future<WebDavAppSyncTaskResult> Function(
      AppSyncContext context,
      AppWebDavSyncServer config,
      WebDavAppSyncHabitInfo cell) serverToLocalTask;
  final Future<WebDavAppSyncTaskResult> Function(
      AppSyncContext context,
      AppWebDavSyncServer config,
      WebDavAppSyncHabitInfo cell) localToServerTask;

  SingleHabitSyncTask({
    required this.config,
    required this.cell,
    required this.serverToLocalTask,
    required this.localToServerTask,
  });

  bool get isNeedDownload => cell.isNeedDownload;

  bool get isNeedUpload => cell.isNeedUpload;

  @override
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) async {
    if (isNeedDownload) {
      appLog.appsynctask
          .info(context, ex: ['server2local sync started', config, cell]);
      final result = await serverToLocalTask(context, config, cell);
      appLog.appsynctask.info(context,
          ex: ['server2local sync completed', result, config, cell]);
      if (!result.isSuccessed) return result;
    }
    if (isNeedUpload) {
      appLog.appsynctask
          .info(context, ex: ['local2server sync started', config, cell]);
      final result = await localToServerTask(context, config, cell);
      appLog.appsynctask.info(context,
          ex: ['local2server sync completed', result, config, cell]);
      if (!result.isSuccessed) return result;
    }
    return const WebDavAppSyncTaskResult.success();
  }

  /// More process design refs:
  /// [Single Habit: Server to Local Task](docs/webdav_sync_design.md#single-habit-server-to-local-task)
  static Future<WebDavAppSyncTaskResult> downloadTask({
    required AppSyncContext context,
    required AppSyncSubTask<WebDavSyncHabitData> fetchHabitDataTask,
    required AppSyncSubTask<WebDavAppSyncTaskResult> Function(
            WebDavSyncHabitData cell)
        writeToDbTaskBuilder,
  }) async {
    final fetchHabitDataFuture = fetchHabitDataTask.run(context);
    final syncHabitData = await fetchHabitDataFuture;
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    appLog.appsynctask.debug(context,
        ex: ['fetch all data from server completed', syncHabitData]);

    final preparedData = (syncHabitData.uuid != null ? syncHabitData : null)
      ?..validate();
    appLog.appsynctask
        .debug(context, ex: ["prepare write to db", preparedData]);
    if (preparedData == null) {
      return const WebDavAppSyncTaskResult.success(
          reason: WebDavAppSyncTaskResultSubStatus.empty);
    }
    return writeToDbTaskBuilder(preparedData).run(context);
  }

  /// More process design refs:
  /// [Single Habit: Local to Server Task](docs/webdav_sync_design.md#single-habit-local-to-server-task)
  static Future<WebDavAppSyncTaskResult> uploadTask({
    required AppSyncContext context,
    required AppSyncSubTask<WebDavSyncHabitData?> loadFromDBTask,
    required AppSyncSubTask<String?> Function(WebDavSyncHabitData data)
        uploadHabitToServerTaskBuilder,
  }) async {
    final habit = await loadFromDBTask.run(context);
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    appLog.appsynctask.debug(context,
        ex: ["load dirty data from db", habit, habit?.records.length]);
    if (habit == null) return const WebDavAppSyncTaskResult.success();

    final results = await uploadHabitToServerTaskBuilder(habit).run(context);
    appLog.appsynctask
        .debug(context, ex: ["upload all to server completed", results]);
    return const WebDavAppSyncTaskResult.success();
  }
}

class FetchDataFromServerTask<T> implements AppSyncSubTask<T> {
  final Uri path;
  final String? etag;
  final WebDavStdClient client;
  final FutureOr<T> Function(WebDavStdResponse response) responseHandler;

  FetchDataFromServerTask({
    required this.path,
    this.etag,
    required this.client,
    required this.responseHandler,
  });

  static Future<({JsonMap data, String? etag})> _responseHandler(
      WebDavStdResponse response, Uri path) async {
    const emptyResult = <String, dynamic>{};
    final resources = await response.parse();
    final etag = response.response.headers[HttpHeaders.etagHeader]?.firstOrNull;
    final requestPath = path.path;
    resources?.firstWhere((e) => e.path.path == requestPath).tryToRaiseError();
    final rawData = response.body;

    final data = rawData != null && rawData.isNotEmpty
        ? json.decode(rawData)
        : emptyResult;
    return (
      data: switch (data) {
        JsonMap() => data,
        List<JsonMap>() => data.firstOrNull ?? emptyResult,
        _ => emptyResult,
      },
      etag: etag
    );
  }

  static FetchDataFromServerTask<WebDavSyncHabitData>
      fetchHabitDataFromServerBuilder(
              {required Uri path,
              required WebDavStdClient client,
              String? etag}) =>
          FetchDataFromServerTask(
            path: path,
            client: client,
            responseHandler: (response) =>
                _responseHandler(response, path).then(
              (value) => WebDavSyncHabitData.fromJson(value.data)
                  .copyWith(etag: etag ?? value.etag),
            ),
          );

  @override
  Future<T> run(AppSyncContext context) =>
      client.dispatch(path).get().then((request) {
        final etag = this.etag;
        if (etag != null) {
          request.request.headers.add(HttpHeaders.ifMatchHeader, etag);
        }
        return request.close();
      }).then((response) {
        appLog.appsynctask.debug(context, ex: [
          'get data',
          response.path,
          response.response.statusCode,
          response.response.headers[HttpHeaders.etagHeader],
          response.body?.length
        ]);
        // appLog.appsynctask.debug(context, ex: [
        //   'get data',
        //   response.path,
        //   response.response.statusCode,
        //   response.response.headers[HttpHeaders.etagHeader],
        //   response.body
        // ]);
        return responseHandler(response);
      });
}

/// More process design refs:
/// [Write Habit/Records to DB Task](docs/webdav_sync_design.md#write-habitrecords-to-db-task)
class WriteToDBTask implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final SyncDBHelper helper;
  final WebDavSyncHabitData data;

  WriteToDBTask({required this.helper, required this.data});

  @override
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) async {
    if (data.uuid == null) {
      return const WebDavAppSyncTaskResult.failed(
          reason: WebDavAppSyncTaskResultSubStatus.missingHabitUuid);
    }
    return helper
        .syncHabitDataToDb(data,
            configId: context.config.identity, sessionId: context.sessionId)
        .then((result) => result
            ? const WebDavAppSyncTaskResult.success()
            : const WebDavAppSyncTaskResult.failed());
  }
}

/// More process design refs:
/// [Load Habit/Records From DB Task](docs/webdav_sync_design.md#load-habitrecords-from-db-task)
class LoadFromDBTask implements AppSyncSubTask<WebDavSyncHabitData?> {
  final SyncDBHelper helper;
  final HabitUUID uuid;

  LoadFromDBTask({required this.helper, required this.uuid});

  @override
  Future<WebDavSyncHabitData?> run(AppSyncContext context) =>
      helper.loadHabitDataFromBb(uuid,
          configId: context.config.identity, sessionId: context.sessionId);
}

class MkDirOnServerTask implements AppSyncSubTask<void> {
  final Uri path;
  final WebDavStdClient client;

  const MkDirOnServerTask({required this.path, required this.client});

  @override
  Future<void> run(AppSyncContext context) => client
          .dispatch(path)
          .createDir()
          .then((request) => request.close())
          .then((response) async {
        appLog.appsynctask.debug(context, ex: [
          "create dir",
          response.path,
          response.response.statusCode,
          response.body,
          path
        ]);
        final resource = (await response.parse())?.firstOrNull;

        if (resource == null) return;
        // skip if collection already created
        if (resource.status == HttpStatus.methodNotAllowed) return;
        resource.tryToRaiseError();
      });
}

class UploadDataToServerTask implements AppSyncSubTask<String?> {
  final Uri path;
  final String data;
  final String? etag;
  final ContentType? contentType;
  final WebDavStdClient client;

  const UploadDataToServerTask(
      {required this.path,
      required this.data,
      this.etag,
      this.contentType,
      required this.client});

  @override
  Future<String?> run(AppSyncContext context) => client
          .dispatch(path)
          .create(
              data: data,
              condition: etag != null
                  ? IfOr.notag([
                      IfAnd.notag([IfCondition.etag(etag!)])
                    ])
                  : null)
          .then((request) {
        if (contentType != null) {
          request.request.headers.contentType = contentType;
        }
        // Specify Content-Length to avoid chunked transfer
        // see: https://github.com/nextcloud/server/issues/7995
        request.request.contentLength = utf8.encode(data).length;
        return request.close();
      }).then((response) async {
        appLog.appsynctask.debug(context, ex: [
          "upload file",
          response.path,
          response.response.statusCode,
          response.body,
          path,
          () {
            final str = data.toString();
            if (str.length > 200) return "${str.substring(0, 200)}...";
            return str;
          },
        ]);

        await response
            .parse()
            .then((resources) => resources?.firstOrNull?.tryToRaiseError());
        return response.response.headers[HttpHeaders.etagHeader]?.firstOrNull;
      });
}

class UploadHabitToServerTask implements AppSyncSubTask<String?> {
  final Uri root;
  final WebDavSyncHabitData data;
  final SyncDBHelper helper;
  final AppSyncSubTask<String?> Function(Uri path, String data, [String? etag])
      uploadTaskBuilder;

  UploadHabitToServerTask({
    required this.root,
    required this.data,
    required this.helper,
    required this.uploadTaskBuilder,
  })  : assert(data.uuid != null),
        assert(data.records.values.every((e) => e.uuid != null));

  @override
  Future<String?> run(AppSyncContext context) async {
    final habitUUID = data.uuid;
    if (habitUUID == null) return null;

    final rootPathBuilder = WebDavAppSyncPathBuilder(root);
    final habitPathBuilder = rootPathBuilder.habit(habitUUID);
    final habitFilePath = habitPathBuilder.habitFile;

    final habitSyncEtag = await uploadTaskBuilder(
            habitFilePath, json.encode(data.toJson()), data.etag)
        .run(context)
        .then((etag) => helper
            .clearHabitDirtyMark(data,
                etag: etag,
                configId: context.config.identity,
                sessionId: context.sessionId)
            .then((_) => etag));

    appLog.appsynctask.debug(context,
        ex: ['habit uploaded', habitUUID, habitSyncEtag, habitFilePath, data]);
    return habitSyncEtag;
  }
}

class CheckRootDirTask implements AppSyncSubTask<WebDavConfigTaskChecklist> {
  final Uri expectedHabitsPath;
  final Uri expectedReadmePath;
  final AppSyncSubTask<List<WebDavResourceContainer>> fetchRootDirTask;

  const CheckRootDirTask(
      {required this.expectedHabitsPath,
      required this.expectedReadmePath,
      required this.fetchRootDirTask});

  @override
  Future<WebDavConfigTaskChecklist> run(AppSyncContext context) {
    return fetchRootDirTask.run(context).then((results) {
      return WebDavConfigTaskChecklist.dirChecker(
          needCreateHabitsDir:
              !results.any((e) => e.path == expectedHabitsPath),
          needCreateWarningFile:
              !results.any((e) => e.path == expectedReadmePath));
    });
  }
}
