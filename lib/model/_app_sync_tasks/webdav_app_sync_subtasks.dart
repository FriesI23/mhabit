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
import '../habit_date.dart';
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
final reAppSyncHabitRecordRootDirName = RegExp(r'^habit-([^/]+)$');
final reAppSyncRecordDirName = RegExp(r'^\d{4}$');
final reAppSyncRecordFileName = RegExp(r'^record-([^/]+)\.json$');

enum WebDavAppSyncInfoStatus { server, local, both }

class FetchMetaFromServerTask
    implements AsyncTask<List<WebDavResourceContainer>> {
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

  static bool _filterCollections(
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
    if (!resource.isCollection) return false;
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

  factory FetchMetaFromServerTask.habitRecordsRootDir(
          Uri path, WebDavStdClient client) =>
      FetchMetaFromServerTask(
        path: path,
        client: client,
        depth: Depth.members,
        filter: (resource) => _filterCollections(
            resource, path, client, reAppSyncHabitRecordRootDirName),
      );

  factory FetchMetaFromServerTask.records(Uri path, WebDavStdClient client) =>
      FetchMetaFromServerTask(
        path: path,
        client: client,
        depth: Depth.members,
        filter: (resource) =>
            _filterFiles(resource, path, client, reAppSyncRecordFileName),
      );

  factory FetchMetaFromServerTask.recordDir(Uri path, WebDavStdClient client) =>
      FetchMetaFromServerTask(
        path: path,
        client: client,
        depth: Depth.members,
        filter: (resource) =>
            _filterCollections(resource, path, client, reAppSyncRecordDirName),
      );

  @override
  Future<List<WebDavResourceContainer>> run() => client
      .dispatch(path)
      .findProps(props: [
        PropfindRequestProp.dav(WebDavElementNames.getetag),
        PropfindRequestProp.dav(WebDavElementNames.resourcetype),
      ], depth: depth)
      .then((request) => request.close())
      .then((response) async => (await response.parse(), response))
      .then((value) {
        final resources = value.$1;
        final response = value.$2;
        appLog.appsync.debug("FetchMetaFromServerTask.run", ex: [
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
      appLog.appsync.debug("SingleHabitSyncTask.run",
          ex: ['need download', parent, config, cell]);
      final result = await serverToLocalTask(parent, config, cell);
      if (!result.isSuccessed) return result;
    }
    if (isNeedUpload) {
      appLog.appsync.debug("SingleHabitSyncTask.run",
          ex: ['need upload', parent, config, cell]);
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
    required AsyncTask<WebDavSyncHabitData> fetchHabitDataTask,
    required AsyncTask<WebDavSyncRecordData> Function(
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
    final syncRecordDataList = await fetchHabitRecordsMeta().then(
      (mergedResult) => Future.wait(mergedResult
          .where((e) => e.isNeedDownload)
          .map(fetchRecordDataTaskBuilder)
          .map(
            (e) => pool.withResource(() async {
              if (parent.isCancalling) return null;
              return e.run();
            }),
          )),
    );
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    final syncHabitData = await fetchHabitDataFuture;
    appLog.appsync.debug("SingleHabitSyncTask.downloadTask",
        ex: ["fetch data", syncHabitData, syncRecordDataList]);
    if (parent.isCancalling || syncRecordDataList.any((e) => e == null)) {
      return const WebDavAppSyncTaskResult.cancelled();
    }

    final preparedData =
        (syncHabitData.uuid != null ? syncHabitData : null)?.copyWith(
      records: syncRecordDataList
          .whereNotNull()
          .where((e) => e.uuid != null)
          .toList(),
    )?..validate();
    appLog.appsync.debug("SingleHabitSyncTask.downloadTask",
        ex: ["prepare write to db", preparedData]);
    if (preparedData == null) return const WebDavAppSyncTaskResult.success();
    return writeToDbTaskBuilder(preparedData).run();
  }

  static Future<WebDavAppSyncTaskResult> uploadTask({
    required AppSyncTask parent,
    required AsyncTask<WebDavSyncHabitData?> loadFromDBTask,
    required AsyncTask<WebDavAppSyncTaskResult> Function(
            WebDavSyncHabitData data)
        preprocessDirTaskBuilder,
    required AsyncTask<
                ({
                  String? habitEtag,
                  Map<HabitRecordUUID, String?> recordEtagMap
                })>
            Function(WebDavSyncHabitData data)
        uploadHabitToServerTaskBuilder,
  }) async {
    final habit = await loadFromDBTask.run();
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    if (habit == null) return const WebDavAppSyncTaskResult.success();

    final preprocessResult = await preprocessDirTaskBuilder(habit).run();
    if (!preprocessResult.isSuccessed) return preprocessResult;
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    await uploadHabitToServerTaskBuilder(habit).run();

    // TODO: indev
    return const WebDavAppSyncTaskResult.success();
  }
}

class FetchHabitRecordsMetaFromServerTask
    implements AsyncTask<List<WebDavResourceContainer>> {
  final AppSyncTask parent;
  final Uri path;
  final int concurrency;
  final AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
      recordDirTaskBuilder;
  final AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
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
              FetchMetaFromServerTask.recordDir(path, client),
          recordsMetaTaskBuilder: (path) =>
              FetchMetaFromServerTask.records(path, client));

  @override
  Future<List<WebDavResourceContainer>> run() async {
    final dirTask = recordDirTaskBuilder(path);
    final dirResult = await dirTask.run();
    if (parent.isCancalling) return [];
    final recordTasks =
        dirResult.map((data) => recordsMetaTaskBuilder(data.path));
    final pool = Pool(concurrency);
    return Future.wait(
      recordTasks.map(
        (e) => pool.withResource(() async {
          if (parent.isCancalling) return const <WebDavResourceContainer>[];
          return e.run();
        }),
      ),
    ).then((results) => results.expand((e) => e).toList());
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

  static FetchDataFromServerTask<WebDavSyncRecordData>
      fetchRecordDataFromServerBuilder(
              {required Uri path,
              required WebDavStdClient client,
              String? etag}) =>
          FetchDataFromServerTask(
            path: path,
            client: client,
            responseHandler: (response) =>
                _responseHandler(response, path).then(
              (value) => WebDavSyncRecordData.fromJson(value.data)
                  .copyWith(etag: etag ?? value.etag),
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

class LoadFromDBTask implements AsyncTask<WebDavSyncHabitData?> {
  final SyncDBHelper helper;
  final HabitUUID uuid;

  LoadFromDBTask({required this.helper, required this.uuid});

  @override
  Future<WebDavSyncHabitData?> run() => helper.loadDirtyHabitDataFromBb(uuid);
}

class PreprocessHabitWebDavCollectionTask
    implements AsyncTask<WebDavAppSyncTaskResult> {
  final AppSyncTask parent;
  final Uri path;
  final WebDavSyncHabitData data;
  final int createConcurrency;
  final AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
      recordsRootDirTaskBuilder;
  final AsyncTask<List<WebDavResourceContainer>> Function(Uri path)
      recordDirTaskBuilder;
  final Iterable<Uri> Function(Iterable<Uri> local, Iterable<Uri> server)
      filterToCreateRecordSubDirs;
  final AsyncTask Function(Uri path) createDirBuilder;

  static Iterable<Uri> _defaultFilterToCreateRecordSubDirs(
          Iterable<Uri> local, Iterable<Uri> server) =>
      Set.of(local).difference(Set.of(server));

  PreprocessHabitWebDavCollectionTask({
    required this.parent,
    required this.path,
    required this.data,
    required this.recordsRootDirTaskBuilder,
    required this.recordDirTaskBuilder,
    required this.createDirBuilder,
    this.filterToCreateRecordSubDirs = _defaultFilterToCreateRecordSubDirs,
    this.createConcurrency = 10,
  });

  factory PreprocessHabitWebDavCollectionTask.build({
    required AppSyncTask parent,
    required Uri path,
    required WebDavSyncHabitData data,
    required WebDavStdClient client,
  }) =>
      PreprocessHabitWebDavCollectionTask(
        parent: parent,
        path: path,
        data: data,
        recordsRootDirTaskBuilder: (path) =>
            FetchMetaFromServerTask.habitRecordsRootDir(path, client),
        recordDirTaskBuilder: (path) =>
            FetchMetaFromServerTask.recordDir(path, client),
        createDirBuilder: (path) =>
            MkDirOnServerTask(path: path, client: client),
      );

  @override
  Future<WebDavAppSyncTaskResult> run() async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return const WebDavAppSyncTaskResult.error();

    final rootPathBuilder = WebDavAppSyncPathBuilder(path);
    final habitPathBuilder = rootPathBuilder.habit(habitUUID);
    final recordRootDir = habitPathBuilder.recordRootDir;

    final serverRecordRootResource =
        await recordsRootDirTaskBuilder(rootPathBuilder.recordsDir).run().then(
            (results) =>
                results.firstWhereOrNull((e) => e.path == recordRootDir));
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    final Future? createRecordRootDirFuture;
    if (serverRecordRootResource == null) {
      createRecordRootDirFuture = createDirBuilder(recordRootDir).run();
    } else {
      createRecordRootDirFuture = null;
    }

    final serverSubDirPaths = (createRecordRootDirFuture == null)
        ? await recordDirTaskBuilder(recordRootDir)
            .run()
            .then((results) => results.map((e) => e.path))
        : null;
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    Iterable<Uri> fetchHabitRecordsSubDirs() {
      final years = <int>{};
      for (var record in data.records) {
        final date = record.recordDate;
        if (date == null) continue;
        final year = HabitDate.fromEpochDay(date).year;
        for (int i = -1; i <= 1; i++) {
          years.add(year + i);
        }
      }
      return years.map(habitPathBuilder.recordSubDir);
    }

    final localSubDirPaths = fetchHabitRecordsSubDirs();
    final needCreatedPaths = filterToCreateRecordSubDirs(
        localSubDirPaths, serverSubDirPaths ?? const []);

    await createRecordRootDirFuture;
    if (parent.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    final pool = Pool(createConcurrency);
    await Future.wait(
      needCreatedPaths.map(
        (path) => pool.withResource(() async {
          if (parent.isCancalling) return;
          await createDirBuilder(path).run();
        }),
      ),
    );

    return WebDavAppSyncTaskResult.success();
  }
}

class MkDirOnServerTask implements AsyncTask<void> {
  final Uri path;
  final WebDavStdClient client;

  const MkDirOnServerTask({required this.path, required this.client});

  @override
  Future<void> run() => client
          .dispatch(path)
          .createDir()
          .then((request) => request.close())
          .then((response) async {
        appLog.appsync.debug("MkDirOnServer.run", ex: [
          response.path,
          response.response.statusCode,
          response.body,
        ]);
        final resource = (await response.parse())?.firstOrNull;

        if (resource == null) return;
        // skip if collection already created
        if (resource.status == HttpStatus.methodNotAllowed) return;
        resource.tryToRaiseError();
      });
}

class UploadDataToServerTask implements AsyncTask<String?> {
  final Uri path;
  final String data;
  final String? etag;
  final WebDavStdClient client;

  const UploadDataToServerTask(
      {required this.path,
      required this.data,
      this.etag,
      required this.client});

  @override
  Future<String?> run() => client
          .dispatch(path)
          .create(
              data: data,
              condition: etag != null
                  ? IfOr.notag([
                      IfAnd.notag([IfCondition.etag(etag!)])
                    ])
                  : null)
          .then((request) => request.close())
          .then((response) async {
        appLog.appsync.debug("UploadDataToServer.run", ex: [
          response.path,
          response.response.statusCode,
          response.body,
        ]);

        await response
            .parse()
            .then((resources) => resources?.firstOrNull?.tryToRaiseError());
        return response.response.headers[HttpHeaders.etagHeader]?.firstOrNull;
      });
}

class UploadHabitToServerTask
    implements
        AsyncTask<
            ({
              String? habitEtag,
              Map<HabitRecordUUID, String?> recordEtagMap
            })> {
  final AppSyncTask parent;
  final Uri root;
  final WebDavSyncHabitData data;
  final bool withRecords;
  final int recordConcurrency;
  final SyncDBHelper helper;
  final AsyncTask<String?> Function(Uri path, String data, [String? etag])
      uploadTaskBuilder;

  UploadHabitToServerTask(
      {required this.parent,
      required this.root,
      required this.data,
      required this.helper,
      this.withRecords = true,
      this.recordConcurrency = 10,
      required this.uploadTaskBuilder})
      : assert(data.uuid != null),
        assert(data.records.every((e) => e.uuid != null));

  @override
  Future<({String? habitEtag, Map<HabitRecordUUID, String?> recordEtagMap})>
      run() async {
    const emptyResult = (
      habitEtag: null as String?,
      recordEtagMap: <HabitRecordUUID, String?>{}
    );

    final habitUUID = data.uuid;
    if (habitUUID == null) return emptyResult;

    final rootPathBuilder = WebDavAppSyncPathBuilder(root);
    final habitPathBuilder = rootPathBuilder.habit(habitUUID);
    final habitFilePath = habitPathBuilder.habitFile;

    final Map<HabitRecordUUID, String?> recordSyncEtagMap;
    if (withRecords && data.records.isNotEmpty) {
      final pool = Pool(recordConcurrency);
      recordSyncEtagMap = await Future.wait(data.records
          .where((e) =>
              e.uuid != null && e.parentUUID != null && e.recordDate != null)
          .map((record) {
        final recordUUID = record.uuid!;
        final recordData = record.recordDate!;
        final task = uploadTaskBuilder(
            habitPathBuilder
                .record(recordUUID, HabitDate.fromEpochDay(recordData))
                .recordFile,
            json.encode(record.toJson()),
            record.etag);
        return pool.withResource(() async {
          if (parent.isCancalling) return null;
          final etag = await task.run();
          await helper.clearRecordDirtyMark(recordUUID, etag);
          return MapEntry(recordUUID, etag);
        });
      })).then((results) => Map.fromEntries(results.whereNotNull()));
      appLog.appsync.debug("UploadHabitToServerTask.run",
          ex: ['records uploaded', habitUUID, recordSyncEtagMap]);
    } else {
      recordSyncEtagMap = emptyResult.recordEtagMap;
    }

    if (parent.isCancalling) {
      return (habitEtag: null as String?, recordEtagMap: recordSyncEtagMap);
    }

    final habitSyncEtag = await uploadTaskBuilder(
            habitFilePath, json.encode(data.toJson()), data.etag)
        .run()
        .then((etag) async {
      await helper.clearHabitDirtyMark(habitUUID, etag);
      return etag;
    });
    appLog.appsync.debug("UploadHabitToServerTask.run",
        ex: ['habit uploaded', habitUUID, habitSyncEtag, data, habitFilePath]);

    return (habitEtag: habitSyncEtag, recordEtagMap: recordSyncEtagMap);
  }
}
