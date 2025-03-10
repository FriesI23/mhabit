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
import 'package:pool/pool.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart' hide IterableExtension;

import '../../common/async.dart';
import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';
import '../app_sync_server.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_task.dart';

typedef WebDavSyncHabitInfoMerger = Converter<
    ({Iterable<SyncDBCell> local, Iterable<WebDavResourceContainer> server}),
    List<WebDavAppSyncHabitInfo>>;

typedef WebDavSyncRecordInfoMerger = Converter<
    ({Iterable<SyncDBCell> local, Iterable<WebDavResourceContainer> server}),
    List<WebDavAppSyncRecordInfo>>;

final reAppSyncHabitFileName = RegExp(r'^habit-([^/]+)\.json$');
final reAppSyncRecordDirName = RegExp(r'^\d{4}$');
final reAppSyncRecordFileName = RegExp(r'^record-([^/]+)\.json$');

enum WebDavAppSyncInfoStatus { server, local, both }

class FetchMemberMetaFromServerTask
    implements AsyncTask<List<WebDavResourceContainer>> {
  final Uri path;
  final WebDavStdClient client;
  final bool Function(WebDavStdResource resource)? filter;

  const FetchMemberMetaFromServerTask({
    required this.path,
    required this.client,
    this.filter,
  });

  factory FetchMemberMetaFromServerTask.habits(
          Uri path, WebDavStdClient client) =>
      FetchMemberMetaFromServerTask(
        path: path,
        client: client,
        filter: (resource) {
          if (resource.path.path == path.path) {
            resource.tryToRaiseError();
            return false;
          }
          final filename =
              resource.path.pathSegments.where((e) => e.isNotEmpty).lastOrNull;
          if (filename == null) return false;
          if (!reAppSyncHabitFileName.hasMatch(filename)) return false;
          if (resource.isCollection) return false;
          resource.tryToRaiseError();
          return true;
        },
      );

  factory FetchMemberMetaFromServerTask.recordDir(
          Uri path, WebDavStdClient client) =>
      FetchMemberMetaFromServerTask(
        path: path,
        client: client,
        filter: (resource) {
          if (resource.path.path == path.path) {
            resource.tryToRaiseError();
            return false;
          }
          final filename =
              resource.path.pathSegments.where((e) => e.isNotEmpty).lastOrNull;
          if (filename == null) return false;
          if (!reAppSyncRecordDirName.hasMatch(filename)) return false;
          if (!resource.isCollection) return false;
          resource.tryToRaiseError();
          return true;
        },
      );

  factory FetchMemberMetaFromServerTask.records(
          Uri path, WebDavStdClient client) =>
      FetchMemberMetaFromServerTask(
        path: path,
        client: client,
        filter: (resource) {
          if (resource.path.path == path.path) {
            resource.tryToRaiseError();
            return false;
          }
          final filename =
              resource.path.pathSegments.where((e) => e.isNotEmpty).lastOrNull;
          if (filename == null) return false;
          if (!reAppSyncRecordFileName.hasMatch(filename)) return false;
          if (resource.isCollection) return false;
          resource.tryToRaiseError();
          return true;
        },
      );

  @override
  Future<List<WebDavResourceContainer>> run() => client
      .dispatch(path)
      .findProps(props: [
        PropfindRequestProp.dav(WebDavElementNames.getetag),
        PropfindRequestProp.dav(WebDavElementNames.resourcetype),
      ], depth: Depth.members)
      .then((request) => request.close())
      .then((response) async => (await response.parse(), response))
      .then((value) {
        final resources = value.$1;
        final response = value.$2;
        appLog.appsync.debug("FetchMemberMetaFromServerTask.run", ex: [
          'fetch resources',
          response.path,
          response.response.statusCode,
          response.body,
          resources?.length,
        ]);
        return resources
                ?.where(filter ?? (e) => true)
                .map((resource) => WebDavResourceContainer.fromResource(
                    resource,
                    overridePath: path.resolveUri(resource.path)))
                .toList() ??
            [];
      });
}

class QueryHabitsFromDBTask implements AsyncTask<List<SyncDBCell>> {
  final SyncDBHelper helper;

  const QueryHabitsFromDBTask({required this.helper});

  @override
  Future<List<SyncDBCell>> run() =>
      helper.loadAllHabitsSyncInfo().then((result) => result.toList());
}

final class SyncHabitsInfoMergerImpl extends WebDavSyncHabitInfoMerger {
  const SyncHabitsInfoMergerImpl();

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
            uuid: uuid, status: WebDavAppSyncInfoStatus.local),
      )
        ..eTagFromLocal = data.lastMark
        ..status = WebDavAppSyncInfoStatus.local;
      if ((data.dirty ?? 0) != 0) cell.makeDirty();
    }
    for (var data in input.server) {
      final uuid = data.habitUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncHabitInfo(
              uuid: uuid, status: WebDavAppSyncInfoStatus.server))
        ..eTagFromServer = data.etag
        ..status = WebDavAppSyncInfoStatus.server
        ..serverPath = data.path;
    }
    return coll.values.toList();
  }
}

class SingleHabitSyncTask implements AsyncTask<WebDavAppSyncTaskResult> {
  final AppSyncTask parent;
  final AppWebDavSyncServer config;
  final WebDavAppSyncHabitInfo cell;
  final Future<WebDavAppSyncTaskResult> Function(
      AppSyncTask parent,
      AppWebDavSyncServer config,
      WebDavAppSyncHabitInfo cell) serverToLocalTask;
  final Future<WebDavAppSyncTaskResult> Function(
      AppSyncTask parent,
      AppWebDavSyncServer config,
      WebDavAppSyncHabitInfo cell) localToServerTask;

  SingleHabitSyncTask({
    required this.parent,
    required this.config,
    required this.cell,
    required this.serverToLocalTask,
    required this.localToServerTask,
  });

  bool get isNeedDownload => cell.isNeedDownload;

  bool get isNeedUpload => cell.isNeedUpload;

  @override
  Future<WebDavAppSyncTaskResult> run() async {
    if (isNeedDownload) {
      final result = await serverToLocalTask(parent, config, cell);
      if (!result.isSuccessed) return result;
    }
    if (isNeedUpload) {
      final result = await localToServerTask(parent, config, cell);
      if (!result.isSuccessed) return result;
    }
    return const WebDavAppSyncTaskResult.success();
  }

  static Future<WebDavAppSyncTaskResult> downloadTask({
    required AppSyncTask parent,
    required AsyncTask<List<WebDavResourceContainer>>
        fetchRecordsFromServerTask,
    required AsyncTask<List<SyncDBCell>> queryRecordsFromDbTask,
    required WebDavSyncRecordInfoMerger syncInfoMerger,
    required AsyncTask<({WebDavSyncHabitData? data, String? etag})>
        fetchHabitDataTask,
    required AsyncTask<({WebDavSyncRecordData? data, String? etag})> Function(
            WebDavAppSyncRecordInfo cell)
        fetchRecordDataTaskBuilder,
    required AsyncTask<WebDavAppSyncTaskResult> Function(
            WebDavSyncHabitData cell)
        writeToDbTaskBuilder,
    int fetchRecordDataConcurrency = 10,
  }) async {
    assert(fetchRecordDataConcurrency > 0);

    Future<List<WebDavAppSyncRecordInfo>> fetchHabitRecordsMeta() async {
      final serverRecordsFuture = fetchRecordsFromServerTask.run();
      final localRecordsFuture = queryRecordsFromDbTask.run();
      final serverRecords = await serverRecordsFuture;
      if (parent.isCancalling) return [];
      final localRecords = await localRecordsFuture;
      if (parent.isCancalling) return [];
      final results =
          syncInfoMerger.convert((local: localRecords, server: serverRecords));
      appLog.appsync.debug("SingleHabitSyncTask.downloadTask",
          ex: ["fetched records metainfo", results]);
      return results;
    }

    appLog.appsync.debug("SingleHabitSyncTask.downloadTask", ex: ["started"]);
    final fetchHabitDataFuture = fetchHabitDataTask.run();
    final pool = Pool(fetchRecordDataConcurrency);
    final syncRecordDataTupleList = await fetchHabitRecordsMeta().then(
      (mergedResult) => Future.wait(mergedResult
          .where((e) => e.isNeedDownload)
          .map(fetchRecordDataTaskBuilder)
          .map((e) async {
        if (parent.isCancalling) return null;
        return pool.withResource(() => e.run());
      })),
    );
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    final syncHabitDataTuple = await fetchHabitDataFuture;
    appLog.appsync.debug("SingleHabitSyncTask.downloadTask",
        ex: ["fetch data", syncHabitDataTuple, syncRecordDataTupleList]);
    if (parent.isCancalling || syncRecordDataTupleList.any((e) => e == null)) {
      return const WebDavAppSyncTaskResult.cancelled();
    }

    final syncHabitData = syncHabitDataTuple.data?.copyWith(
      records:
          syncRecordDataTupleList.map((e) => e?.data).whereNotNull().toList(),
    )?..validate();
    appLog.appsync.debug("SingleHabitSyncTask.downloadTask",
        ex: ["prepare write to db", syncHabitData]);
    if (syncHabitData == null) return const WebDavAppSyncTaskResult.success();
    return writeToDbTaskBuilder(syncHabitData).run();
  }
}

class FetchHabitRecordsMetaFromServerTask
    implements AsyncTask<List<WebDavResourceContainer>> {
  final AppSyncTask parent;
  final Uri path;
  final int concurrency;
  AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
      recordDirTaskBuilder;
  AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
      recordsMetaTaskBuilder;

  FetchHabitRecordsMetaFromServerTask({
    required this.concurrency,
    required this.parent,
    required this.path,
    required this.recordDirTaskBuilder,
    required this.recordsMetaTaskBuilder,
  }) : assert(concurrency > 0);

  factory FetchHabitRecordsMetaFromServerTask.build({
    required AppSyncTask parent,
    required Uri path,
    required WebDavStdClient client,
    int concurrency = 10,
  }) =>
      FetchHabitRecordsMetaFromServerTask(
          parent: parent,
          path: path,
          concurrency: concurrency,
          recordDirTaskBuilder: (path) =>
              FetchMemberMetaFromServerTask.recordDir(path, client),
          recordsMetaTaskBuilder: (path) =>
              FetchMemberMetaFromServerTask.records(path, client));

  @override
  Future<List<WebDavResourceContainer>> run() async {
    final dirTask = recordDirTaskBuilder(path);
    final dirResult = await dirTask.run();
    if (parent.isCancalling) return [];
    final recordTasks =
        dirResult.map((data) => recordsMetaTaskBuilder(data.path));
    final pool = Pool(concurrency);
    return Future.wait(recordTasks.map((e) async {
      if (parent.isCancalling) return const <WebDavResourceContainer>[];
      return pool.withResource(e.run);
    })).then((results) => results.expand((e) => e).toList());
  }
}

class QueryHabitRecordsFromDBTask implements AsyncTask<List<SyncDBCell>> {
  final HabitUUID uuid;
  final SyncDBHelper helper;

  const QueryHabitRecordsFromDBTask({required this.uuid, required this.helper});

  @override
  Future<List<SyncDBCell>> run() => helper
      .loadHabitRecordsSyncInfo(uuid: uuid)
      .then((result) => result.toList());
}

final class SyncHabitRecordsInfoMergerImpl extends WebDavSyncRecordInfoMerger {
  final HabitUUID uuid;

  const SyncHabitRecordsInfoMergerImpl(this.uuid);

  @override
  List<WebDavAppSyncRecordInfo> convert(
      ({
        Iterable<SyncDBCell> local,
        Iterable<WebDavResourceContainer> server
      }) input) {
    final coll = <HabitUUID, WebDavAppSyncRecordInfo>{};
    for (var data in input.local) {
      final uuid = data.recordUUID;
      if (uuid == null) continue;
      final cell = coll.putIfAbsent(
        uuid,
        () => WebDavAppSyncRecordInfo(
            parentUUID: this.uuid,
            uuid: uuid,
            status: WebDavAppSyncInfoStatus.local),
      )
        ..eTagFromLocal = data.lastMark
        ..status = WebDavAppSyncInfoStatus.local;
      if ((data.dirty ?? 0) != 0) cell.makeDirty();
    }
    for (var data in input.server) {
      final uuid = data.recordUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncRecordInfo(
              parentUUID: this.uuid,
              uuid: uuid,
              status: WebDavAppSyncInfoStatus.server))
        ..eTagFromServer = data.etag
        ..status = WebDavAppSyncInfoStatus.server
        ..serverPath = data.path;
    }
    return coll.values.toList();
  }
}

class FetchDataFromServerTask<T> implements AsyncTask<T> {
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
    appLog.appsync.debug("FetchDataFromServerTask.run", ex: [
      'get data',
      response.path,
      response.response.statusCode,
      response.body,
      resources?.length,
      etag
    ]);
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

  static FetchDataFromServerTask<({JsonMap data, String? etag})>
      fetchJsonDataFromServerBuilder(
              {required Uri path, required WebDavStdClient client}) =>
          FetchDataFromServerTask(
              path: path,
              client: client,
              responseHandler: (response) => _responseHandler(response, path));

  static FetchDataFromServerTask<({WebDavSyncHabitData? data, String? etag})>
      fetchHabitDataFromServerBuilder(
              {required Uri path, required WebDavStdClient client}) =>
          FetchDataFromServerTask(
            path: path,
            client: client,
            responseHandler: (response) =>
                _responseHandler(response, path).then(
              (value) => (
                data: value.data.isEmpty
                    ? null
                    : WebDavSyncHabitData.fromJson(value.data),
                etag: value.etag
              ),
            ),
          );

  static FetchDataFromServerTask<({WebDavSyncRecordData? data, String? etag})>
      fetchRecordDataFromServerBuilder(
              {required Uri path, required WebDavStdClient client}) =>
          FetchDataFromServerTask(
            path: path,
            client: client,
            responseHandler: (response) =>
                _responseHandler(response, path).then(
              (value) => (
                data: value.data.isEmpty
                    ? null
                    : WebDavSyncRecordData.fromJson(value.data),
                etag: value.etag
              ),
            ),
          );

  @override
  Future<T> run() => client.dispatch(path).get().then((request) {
        final etag = this.etag;
        if (etag != null) {
          request.request.headers.add(HttpHeaders.ifMatchHeader, etag);
        }
        return request.close();
      }).then(responseHandler);
}

class WriteToDBTask implements AsyncTask<WebDavAppSyncTaskResult> {
  final SyncDBHelper helper;
  final WebDavSyncHabitData data;

  WriteToDBTask({required this.helper, required this.data});

  @override
  Future<WebDavAppSyncTaskResult> run() =>
      helper.syncHabitDataToDb(data).then((result) => result
          ? WebDavAppSyncTaskResult.success()
          : WebDavAppSyncTaskResult.error());
}
