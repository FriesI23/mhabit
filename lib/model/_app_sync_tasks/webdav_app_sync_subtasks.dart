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
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:pool/pool.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart' hide IterableExtension;

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';
import '../app_sync_server.dart';
import '../habit_date.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_task_status.dart';

typedef WebDavSyncInfoMergerInput = ({
  Iterable<SyncDBCell> local,
  Iterable<WebDavResourceContainer> server
});

typedef WebDavSyncHabitInfoMerger
    = Converter<WebDavSyncInfoMergerInput, List<WebDavAppSyncHabitInfo>>;

typedef WebDavSyncRecordInfoMerger
    = Converter<WebDavSyncInfoMergerInput, List<WebDavAppSyncRecordInfo>>;

typedef HabitEtagResult = ({
  String? habitEtag,
  Map<HabitRecordUUID, String?> recordEtagMap
});

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
  Future<List<WebDavResourceContainer>> run(AppSyncContext context) => client
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
        ..eTagFromLocal = data.lastMark
        ..status = WebDavAppSyncInfoStatus.local
        ..lastConfgUUID = data.lastConfigUUID;
      if ((data.dirty ?? 0) != 0) cell.makeDirty();
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

  static Future<WebDavAppSyncTaskResult> downloadTask({
    required AppSyncContext context,
    required AppSyncSubTask<List<WebDavResourceContainer>>
        fetchRecordsFromServerTask,
    required AppSyncSubTask<List<SyncDBCell>> queryRecordsFromDbTask,
    required WebDavSyncRecordInfoMerger syncInfoMerger,
    required AppSyncSubTask<WebDavSyncHabitData> fetchHabitDataTask,
    required AppSyncSubTask<WebDavSyncRecordData> Function(
            WebDavAppSyncRecordInfo cell)
        fetchRecordDataTaskBuilder,
    required AppSyncSubTask<WebDavAppSyncTaskResult> Function(
            WebDavSyncHabitData cell)
        writeToDbTaskBuilder,
    int fetchRecordDataConcurrency = 10,
  }) async {
    assert(fetchRecordDataConcurrency > 0);

    Future<List<WebDavAppSyncRecordInfo>> fetchHabitRecordsMeta() async {
      final serverRecordsFuture = fetchRecordsFromServerTask.run(context);
      final localRecordsFuture = queryRecordsFromDbTask.run(context);

      final serverRecords = await serverRecordsFuture;
      if (context.isCancalling) return [];
      appLog.appsynctask.debug(context,
          ex: ['fetch records form server completed', serverRecords.length]);

      final localRecords = await localRecordsFuture;
      if (context.isCancalling) return [];
      appLog.appsynctask.debug(context,
          ex: ['fetch records form local completed', localRecords.length]);

      final results =
          syncInfoMerger.convert((local: localRecords, server: serverRecords));
      appLog.appsynctask
          .debug(context, ex: ["merge records completed", results.length]);
      return results;
    }

    final fetchHabitDataFuture = fetchHabitDataTask.run(context);
    final pool = Pool(math.max(1, fetchRecordDataConcurrency),
        timeout: context.config.timeout ?? defaultAppSyncTimeout);
    final syncRecordDataList = await fetchHabitRecordsMeta().then(
      (mergedResult) => Future.wait(mergedResult
          .where((e) => e.isNeedDownload)
          .map(fetchRecordDataTaskBuilder)
          .map(
            (e) => pool.withResource(() async {
              if (context.isCancalling) return null;
              return e.run(context);
            }),
          )),
    );
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    final syncHabitData = await fetchHabitDataFuture;
    if (context.isCancalling || syncRecordDataList.any((e) => e == null)) {
      return const WebDavAppSyncTaskResult.cancelled();
    }
    appLog.appsynctask.debug(context, ex: [
      'fetch all data from server completed',
      syncHabitData,
      syncRecordDataList
    ]);

    final preparedData =
        (syncHabitData.uuid != null ? syncHabitData : null)?.copyWith(
      records: syncRecordDataList
          .whereNotNull()
          .where((e) => e.uuid != null)
          .toList(),
    )?..validate();
    appLog.appsynctask
        .debug(context, ex: ["prepare write to db", preparedData]);
    // TOOD: indev (make some warning?)
    if (preparedData == null) return const WebDavAppSyncTaskResult.success();
    return writeToDbTaskBuilder(preparedData).run(context);
  }

  static Future<WebDavAppSyncTaskResult> uploadTask({
    required AppSyncContext context,
    required AppSyncSubTask<WebDavSyncHabitData?> loadFromDBTask,
    required AppSyncSubTask<WebDavAppSyncTaskResult> Function(
            WebDavSyncHabitData data)
        preprocessDirTaskBuilder,
    required AppSyncSubTask<HabitEtagResult> Function(WebDavSyncHabitData data)
        uploadHabitToServerTaskBuilder,
  }) async {
    final habit = await loadFromDBTask.run(context);
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    appLog.appsynctask.debug(context,
        ex: ["load dirty data from db", habit, habit?.records.length]);
    if (habit == null) return const WebDavAppSyncTaskResult.success();

    final preprocessResult = await preprocessDirTaskBuilder(habit).run(context);
    if (!preprocessResult.isSuccessed) return preprocessResult;
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    appLog.appsynctask.debug(context,
        ex: ['pre-preocessing completed', preprocessResult, habit]);

    final results = await uploadHabitToServerTaskBuilder(habit).run(context);
    appLog.appsynctask
        .debug(context, ex: ["upload all to server completed", results]);
    return const WebDavAppSyncTaskResult.success();
  }
}

class FetchHabitRecordsMetaFromServerTask
    implements AppSyncSubTask<List<WebDavResourceContainer>> {
  final Uri path;
  final int concurrency;
  final AppSyncSubTask<List<WebDavResourceContainer>> Function(Uri path)
      recordDirTaskBuilder;
  final AppSyncSubTask<List<WebDavResourceContainer>> Function(Uri path)
      recordsMetaTaskBuilder;

  FetchHabitRecordsMetaFromServerTask({
    required this.concurrency,
    required this.path,
    required this.recordDirTaskBuilder,
    required this.recordsMetaTaskBuilder,
  }) : assert(concurrency > 0);

  factory FetchHabitRecordsMetaFromServerTask.build({
    required Uri path,
    required WebDavStdClient client,
    int concurrency = 10,
  }) =>
      FetchHabitRecordsMetaFromServerTask(
          path: path,
          concurrency: concurrency,
          recordDirTaskBuilder: (path) =>
              FetchMetaFromServerTask.recordDir(path, client),
          recordsMetaTaskBuilder: (path) =>
              FetchMetaFromServerTask.records(path, client));

  @override
  Future<List<WebDavResourceContainer>> run(AppSyncContext context) async {
    final dirTask = recordDirTaskBuilder(path);
    final dirResult = await dirTask.run(context);
    if (context.isCancalling) return [];
    final recordTasks =
        dirResult.map((data) => recordsMetaTaskBuilder(data.path));
    appLog.appsynctask.debug(context,
        ex: ["ready to fetch records props", dirResult, path, concurrency]);

    final pool = Pool(math.max(1, concurrency),
        timeout: context.config.timeout ?? defaultAppSyncTimeout);
    return Future.wait(
      recordTasks.map(
        (e) => pool.withResource(() async {
          if (context.isCancalling) return const <WebDavResourceContainer>[];
          return e.run(context);
        }),
      ),
    ).then((results) => results.expand((e) => e).toList());
  }
}

class QueryHabitRecordsFromDBTask implements AppSyncSubTask<List<SyncDBCell>> {
  final HabitUUID uuid;
  final SyncDBHelper helper;

  const QueryHabitRecordsFromDBTask({required this.uuid, required this.helper});

  @override
  Future<List<SyncDBCell>> run(AppSyncContext context) => helper
      .loadHabitRecordsSyncInfo(uuid: uuid)
      .then((result) => result.toList());
}

final class SyncHabitRecordsInfoMergerImpl extends WebDavSyncRecordInfoMerger {
  final AppSyncContext context;
  final HabitUUID uuid;

  const SyncHabitRecordsInfoMergerImpl(this.context, this.uuid);

  @override
  List<WebDavAppSyncRecordInfo> convert(WebDavSyncInfoMergerInput input) {
    final coll = <HabitUUID, WebDavAppSyncRecordInfo>{};
    for (var data in input.local) {
      final uuid = data.recordUUID;
      if (uuid == null) continue;
      final cell = coll.putIfAbsent(
        uuid,
        () => WebDavAppSyncRecordInfo(
            configUUID: context.config.identity,
            parentUUID: this.uuid,
            uuid: uuid,
            status: WebDavAppSyncInfoStatus.local),
      )
        ..eTagFromLocal = data.lastMark
        ..status = WebDavAppSyncInfoStatus.local
        ..lastConfgUUID = data.lastConfigUUID;
      if ((data.dirty ?? 0) != 0) cell.makeDirty();
    }
    for (var data in input.server) {
      final uuid = data.recordUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncRecordInfo(
              configUUID: context.config.identity,
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
  Future<T> run(AppSyncContext context) =>
      client.dispatch(path).get().then((request) {
        final etag = this.etag;
        if (etag != null) {
          request.request.headers.add(HttpHeaders.ifMatchHeader, etag);
        }
        return request.close();
      }).then((response) {
        appLog.appsynctask.info(context, ex: [
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

class WriteToDBTask implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final SyncDBHelper helper;
  final WebDavSyncHabitData data;

  WriteToDBTask({required this.helper, required this.data});

  @override
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) => helper
      .syncHabitDataToDb(data,
          configId: context.config.identity, sessionId: context.sessionId)
      .then((result) => result
          ? WebDavAppSyncTaskResult.success()
          : WebDavAppSyncTaskResult.error());
}

class LoadFromDBTask implements AppSyncSubTask<WebDavSyncHabitData?> {
  final SyncDBHelper helper;
  final HabitUUID uuid;

  LoadFromDBTask({required this.helper, required this.uuid});

  @override
  Future<WebDavSyncHabitData?> run(AppSyncContext context) =>
      helper.loadDirtyHabitDataFromBb(uuid,
          configId: context.config.identity, sessionId: context.sessionId);
}

class PreprocessHabitWebDavCollectionTask
    implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final Uri path;
  final WebDavSyncHabitData data;
  final int createConcurrency;
  final AppSyncSubTask<List<WebDavResourceContainer>> Function(Uri path)
      recordsRootDirTaskBuilder;
  final AppSyncSubTask<List<WebDavResourceContainer>> Function(Uri path)
      recordDirTaskBuilder;
  final Iterable<Uri> Function(Iterable<Uri> local, Iterable<Uri> server)
      filterToCreateRecordSubDirs;
  final AppSyncSubTask Function(Uri path) createDirBuilder;

  static Iterable<Uri> _defaultFilterToCreateRecordSubDirs(
          Iterable<Uri> local, Iterable<Uri> server) =>
      Set.of(local).difference(Set.of(server));

  PreprocessHabitWebDavCollectionTask({
    required this.path,
    required this.data,
    required this.recordsRootDirTaskBuilder,
    required this.recordDirTaskBuilder,
    required this.createDirBuilder,
    this.filterToCreateRecordSubDirs = _defaultFilterToCreateRecordSubDirs,
    this.createConcurrency = 10,
  });

  factory PreprocessHabitWebDavCollectionTask.build({
    required Uri path,
    required WebDavSyncHabitData data,
    required WebDavStdClient client,
  }) =>
      PreprocessHabitWebDavCollectionTask(
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
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) async {
    assert(data.uuid != null);

    final habitUUID = data.uuid;
    if (habitUUID == null) return const WebDavAppSyncTaskResult.error();

    final rootPathBuilder = WebDavAppSyncPathBuilder(path);
    final habitPathBuilder = rootPathBuilder.habit(habitUUID);
    final recordRootDir = habitPathBuilder.recordRootDir;

    final serverRecordRootResource =
        await recordsRootDirTaskBuilder(rootPathBuilder.recordsDir)
            .run(context)
            .then((results) =>
                results.firstWhereOrNull((e) => e.path == recordRootDir));
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    appLog.appsynctask.debug(context, ex: [
      'fetch habit\'s record root dir completed',
      serverRecordRootResource,
      habitUUID,
      rootPathBuilder.recordsDir
    ]);

    final Future? createRecordRootDirFuture;
    if (serverRecordRootResource == null) {
      createRecordRootDirFuture = createDirBuilder(recordRootDir).run(context);
    } else {
      createRecordRootDirFuture = null;
    }

    final serverSubDirPaths = (createRecordRootDirFuture == null)
        ? await recordDirTaskBuilder(recordRootDir)
            .run(context)
            .then((results) => results.map((e) => e.path))
        : null;
    if (serverSubDirPaths != null) {
      appLog.appsynctask.debug(context, ex: [
        "fetch habit's records sub dirs completed",
        serverSubDirPaths,
        habitUUID,
        recordRootDir
      ]);
    }
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

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
    appLog.appsynctask.debug(context, ex: [
      "filterd habit's records sub dirs",
      needCreatedPaths,
      localSubDirPaths,
      serverSubDirPaths,
      habitUUID
    ]);

    await createRecordRootDirFuture;
    appLog.appsynctask.debug(context,
        ex: ["created habit's record root dir", recordRootDir, habitUUID]);
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    final pool = Pool(math.max(1, createConcurrency),
        timeout: context.config.timeout ?? defaultAppSyncTimeout);
    final results = await Future.wait(
      needCreatedPaths.map(
        (path) => pool.withResource(() async {
          if (context.isCancalling) return false;
          await createDirBuilder(path).run(context);
          return true;
        }),
      ),
    );
    appLog.appsynctask.debug(context, ex: [
      "created habit's records sub dir",
      results,
      needCreatedPaths,
      localSubDirPaths,
      serverSubDirPaths,
      habitUUID,
      createConcurrency
    ]);

    return WebDavAppSyncTaskResult.success();
  }
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
  final WebDavStdClient client;

  const UploadDataToServerTask(
      {required this.path,
      required this.data,
      this.etag,
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
          .then((request) =>
              (request..request.headers.contentType = ContentType.text).close())
          .then((response) async {
        appLog.appsynctask.debug(context, ex: [
          "uplaod file",
          response.path,
          response.response.statusCode,
          response.body,
          path,
          data
        ]);

        await response
            .parse()
            .then((resources) => resources?.firstOrNull?.tryToRaiseError());
        return response.response.headers[HttpHeaders.etagHeader]?.firstOrNull;
      });
}

class UploadHabitToServerTask implements AppSyncSubTask<HabitEtagResult> {
  final Uri root;
  final WebDavSyncHabitData data;
  final bool withRecords;
  final int recordConcurrency;
  final SyncDBHelper helper;
  final AppSyncSubTask<String?> Function(Uri path, String data, [String? etag])
      uploadTaskBuilder;

  UploadHabitToServerTask({
    required this.root,
    required this.data,
    required this.helper,
    this.withRecords = true,
    this.recordConcurrency = 10,
    required this.uploadTaskBuilder,
  })  : assert(data.uuid != null),
        assert(data.records.every((e) => e.uuid != null));

  @override
  Future<({String? habitEtag, Map<HabitRecordUUID, String?> recordEtagMap})>
      run(AppSyncContext context) async {
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
      final pool = Pool(math.max(1, recordConcurrency),
          timeout: context.config.timeout ?? defaultAppSyncTimeout);
      recordSyncEtagMap = await Future.wait(data.records
          .where((e) =>
              e.uuid != null && e.parentUUID != null && e.recordDate != null)
          .map((record) {
        final recordUUID = record.uuid!;
        final recordDate = record.recordDate!;
        final recordFilePath = habitPathBuilder
            .record(recordUUID, HabitDate.fromEpochDay(recordDate))
            .recordFile;
        final task = uploadTaskBuilder(
            recordFilePath, json.encode(record.toJson()), record.etag);
        return pool.withResource(() async {
          if (context.isCancalling) return null;
          final etag = await task.run(context);
          appLog.appsynctask.debug(context, ex: [
            'complete upload records',
            etag,
            recordUUID,
            recordFilePath,
            record
          ]);
          await helper.clearRecordDirtyMark(recordUUID, record.dirty!,
              etag: etag,
              configId: context.config.identity,
              sessionId: context.sessionId);
          return MapEntry(recordUUID, etag);
        });
      })).then((results) => Map.fromEntries(results.whereNotNull()));
    } else {
      recordSyncEtagMap = emptyResult.recordEtagMap;
    }
    appLog.appsynctask.debug(context, ex: [
      'records uploaded',
      habitUUID,
      recordSyncEtagMap,
      withRecords,
      data.records.length
    ]);
    if (context.isCancalling) {
      return (habitEtag: null as String?, recordEtagMap: recordSyncEtagMap);
    }

    final habitSyncEtag = await uploadTaskBuilder(
            habitFilePath, json.encode(data.toJson()), data.etag)
        .run(context)
        .then((etag) async {
      await helper.clearHabitDirtyMark(habitUUID, data.dirty!,
          etag: etag,
          configId: context.config.identity,
          sessionId: context.sessionId);
      return etag;
    });
    appLog.appsynctask.debug(context,
        ex: ['habit uploaded', habitUUID, habitSyncEtag, habitFilePath, data]);

    return (habitEtag: habitSyncEtag, recordEtagMap: recordSyncEtagMap);
  }
}

class CheckRootDirTask implements AppSyncSubTask<WebDavConfigTaskChecklist> {
  final Uri expectedHabitsPath;
  final Uri expectedRecordsPath;
  final Uri expectedReadmePath;
  final AppSyncSubTask<List<WebDavResourceContainer>> fetchRootDirTask;

  const CheckRootDirTask(
      {required this.expectedHabitsPath,
      required this.expectedRecordsPath,
      required this.expectedReadmePath,
      required this.fetchRootDirTask});

  @override
  Future<WebDavConfigTaskChecklist> run(AppSyncContext context) {
    return fetchRootDirTask.run(context).then((results) {
      return WebDavConfigTaskChecklist.dirChecker(
          needCreateHabitsDir:
              !results.any((e) => e.path == expectedHabitsPath),
          needCreateRecordsDir:
              !results.any((e) => e.path == expectedRecordsPath),
          needCreateWarningFile:
              !results.any((e) => e.path == expectedReadmePath));
    });
  }
}
