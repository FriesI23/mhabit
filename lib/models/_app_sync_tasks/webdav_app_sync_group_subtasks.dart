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

import 'dart:async';
import 'dart:convert';

import 'package:pool/pool.dart';

import '../../common/consts.dart';
import '../../common/types.dart';
import '../../storage/db/handlers/sync.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';
import 'webdav_app_sync_subtasks.dart';
import 'webdav_app_sync_task_status.dart';

typedef WebDavSyncGroupInfoMerger =
    Converter<WebDavSyncInfoMergerInput, List<WebDavAppSyncGroupInfo>>;

/// Encapsulates the full Group sync sub-flow as a single [AppSyncSubTask].
///
/// After [run], habit sync can proceed with Group data already reconciled.
class GroupSyncTask
    implements
        AppSyncSubTask<Map<WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>> {
  final AppSyncSubTask<List<WebDavResourceContainer>> fetchMetaFromServer;
  final AppSyncSubTask<List<SyncDBCell>> queryFromDb;
  final WebDavSyncGroupInfoMerger Function(AppSyncContext) mergerBuilder;
  final AppSyncSubTask<WebDavAppSyncTaskResult> Function(WebDavAppSyncGroupInfo)
  singleTaskBuilder;

  const GroupSyncTask({
    required this.fetchMetaFromServer,
    required this.queryFromDb,
    required this.mergerBuilder,
    required this.singleTaskBuilder,
  });

  @override
  Future<Map<WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>> run(
    AppSyncContext context,
  ) async {
    final (serverMetas, localCells) = await (
      fetchMetaFromServer.run(context),
      queryFromDb.run(context),
    ).wait;

    final merger = mergerBuilder(context);
    final mergedCells = merger.convert((
      local: localCells,
      server: serverMetas,
    ));

    if (mergedCells.isEmpty) return {};

    final resultMap = <WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>{};
    final pool = Pool(
      mergedCells.length.clamp(1, 5),
      timeout: context.config.timeout ?? defaultAppSyncTimeout,
    );
    await Future.wait(
      mergedCells.map(
        (cell) => pool
            .withResource(() async {
              if (context.isCancalling) {
                return const WebDavAppSyncTaskResult.cancelled();
              }
              return singleTaskBuilder(cell).run(context);
            })
            .onError(
              (e, s) => WebDavAppSyncTaskResult.error(error: e, trace: s),
            )
            .then((result) => resultMap.putIfAbsent(cell, () => result)),
      ),
    );
    return resultMap;
  }
}

class QueryGroupsFromDBTask implements AppSyncSubTask<List<SyncDBCell>> {
  final SyncDBHelper helper;
  const QueryGroupsFromDBTask({required this.helper});

  @override
  Future<List<SyncDBCell>> run(AppSyncContext context) =>
      helper.group.loadAllGroupsSyncInfo().then((result) => result.toList());
}

final class SyncGroupsInfoMergerImpl extends WebDavSyncGroupInfoMerger {
  final AppSyncContext context;
  const SyncGroupsInfoMergerImpl(this.context);

  @override
  List<WebDavAppSyncGroupInfo> convert(
    ({Iterable<SyncDBCell> local, Iterable<WebDavResourceContainer> server})
    input,
  ) {
    final coll = <HabitUUID, WebDavAppSyncGroupInfo>{};

    for (var data in input.local) {
      final uuid = data.groupUUID;
      if (uuid == null) continue;
      final cell =
          coll.putIfAbsent(
              uuid,
              () => WebDavAppSyncGroupInfo(
                configUUID: context.config.identity,
                uuid: uuid,
                status: WebDavAppSyncInfoStatus.local,
              ),
            )
            ..eTagFromLocal = data.lastMark2
            ..status = WebDavAppSyncInfoStatus.local
            ..lastConfgUUID = data.lastConfigUUID;
      if ((data.dirtyTotal ?? 0) != 0) cell.makeDirty();
    }

    for (var data in input.server) {
      final uuid = data.groupUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncGroupInfo(
            configUUID: context.config.identity,
            uuid: uuid,
            status: WebDavAppSyncInfoStatus.server,
          ),
        )
        ..eTagFromServer = data.etag
        ..status = WebDavAppSyncInfoStatus.server
        ..serverPath = data.path;
    }

    return coll.values.toList();
  }
}

class SingleGroupSyncTask implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final WebDavAppSyncGroupInfo cell;
  final Future<WebDavAppSyncTaskResult> Function(
    AppSyncContext context,
    WebDavAppSyncGroupInfo cell,
  )
  serverToLocalTask;
  final Future<WebDavAppSyncTaskResult> Function(
    AppSyncContext context,
    WebDavAppSyncGroupInfo cell,
  )
  localToServerTask;

  SingleGroupSyncTask({
    required this.cell,
    required this.serverToLocalTask,
    required this.localToServerTask,
  });

  bool get isNeedDownload => cell.isNeedDownload;

  bool get isNeedUpload => cell.isNeedUpload;

  @override
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) async {
    if (isNeedDownload) {
      final result = await serverToLocalTask(context, cell);
      if (!result.isSuccessed) return result;
    }
    if (isNeedUpload) {
      final result = await localToServerTask(context, cell);
      if (!result.isSuccessed) return result;
    }
    return const WebDavAppSyncTaskResult.success();
  }

  /// Downloads Group data from the server and writes it to local DB.
  static Future<WebDavAppSyncTaskResult> downloadTask({
    required AppSyncContext context,
    required AppSyncSubTask<WebDavSyncGroupData> fetchGroupDataTask,
    required AppSyncSubTask<WebDavAppSyncTaskResult> Function(
      WebDavSyncGroupData,
    )
    writeToDbTaskBuilder,
  }) async {
    final syncGroupData = await fetchGroupDataTask.run(context);
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();

    final preparedData = syncGroupData.uuid != null ? syncGroupData : null;
    if (preparedData == null) {
      return const WebDavAppSyncTaskResult.success(
        reason: WebDavAppSyncTaskResultSubStatus.empty,
      );
    }

    return writeToDbTaskBuilder(preparedData).run(context);
  }

  /// Loads Group data from local DB and uploads to the server.
  static Future<WebDavAppSyncTaskResult> uploadTask({
    required AppSyncContext context,
    required AppSyncSubTask<WebDavSyncGroupData?> loadFromDBTask,
    required AppSyncSubTask<String?> Function(WebDavSyncGroupData)
    uploadGroupToServerTaskBuilder,
  }) async {
    final group = await loadFromDBTask.run(context);
    if (context.isCancalling) return const WebDavAppSyncTaskResult.cancelled();
    if (group == null) return const WebDavAppSyncTaskResult.success();

    await uploadGroupToServerTaskBuilder(group).run(context);
    return const WebDavAppSyncTaskResult.success();
  }
}

class WriteGroupToDBTask implements AppSyncSubTask<WebDavAppSyncTaskResult> {
  final SyncDBHelper helper;
  final WebDavSyncGroupData data;

  const WriteGroupToDBTask({required this.helper, required this.data});

  @override
  Future<WebDavAppSyncTaskResult> run(AppSyncContext context) async {
    return helper.group
        .syncGroupDataToDb(
          data,
          configId: context.config.identity,
          sessionId: context.sessionId,
        )
        .then(
          (r) => r
              ? const WebDavAppSyncTaskResult.success()
              : const WebDavAppSyncTaskResult.failed(),
        );
  }
}

class LoadGroupFromDBTask implements AppSyncSubTask<WebDavSyncGroupData?> {
  final SyncDBHelper helper;
  final HabitUUID uuid;

  const LoadGroupFromDBTask({required this.helper, required this.uuid});

  @override
  Future<WebDavSyncGroupData?> run(AppSyncContext context) async {
    return helper.group.loadGroupDataFromDb(
      uuid,
      configId: context.config.identity,
      sessionId: context.sessionId,
    );
  }
}

class UploadGroupToServerTask implements AppSyncSubTask<String?> {
  final Uri root;
  final WebDavSyncGroupData data;
  final SyncDBHelper helper;
  final AppSyncSubTask<String?> Function(Uri path, String data, [String? etag])
  uploadTaskBuilder;

  const UploadGroupToServerTask({
    required this.root,
    required this.data,
    required this.helper,
    required this.uploadTaskBuilder,
  });

  @override
  Future<String?> run(AppSyncContext context) async {
    final groupUUID = data.uuid;
    if (groupUUID == null) return null;

    final pathBuilder = WebDavAppSyncPathBuilder(root);
    final groupPath = pathBuilder.group(groupUUID);

    final newEtag =
        await uploadTaskBuilder(
              groupPath,
              json.encode(data.toJson()),
              data.etag,
            )
            .run(context)
            .then(
              (etag) => helper.group
                  .clearGroupDirtyMark(
                    data.copyWith(etag: etag),
                    configId: context.config.identity,
                    sessionId: context.sessionId,
                  )
                  .then((_) => etag),
            );

    return newEtag;
  }
}
