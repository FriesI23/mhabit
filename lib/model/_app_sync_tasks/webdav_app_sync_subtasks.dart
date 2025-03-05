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

import 'dart:convert';

import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart';

import '../../common/async.dart';
import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';

typedef WebDavSyncCellInfoMerger = Converter<
    ({Iterable<SyncDBCell> local, Iterable<WebDavResourceContainer> server}),
    List<WebDavAppSyncCellInfo>>;

final reAppSyncHabitFileName = RegExp(r'^habit-([^/]+)\.json$');

enum WebDavAppSyncInfoStatus { server, local, both }

class WebDavAppSyncCellInfo {
  final HabitUUID uuid;
  String? eTagFromServer;
  String? eTagFromLocal;

  WebDavAppSyncInfoStatus _status;

  WebDavAppSyncCellInfo(
      {required this.uuid, required WebDavAppSyncInfoStatus status})
      : _status = status;

  WebDavAppSyncInfoStatus get status => _status;

  set status(WebDavAppSyncInfoStatus newStatus) {
    if (_status != newStatus) _status = WebDavAppSyncInfoStatus.both;
  }

  @override
  String toString() => "WebDavAppSyncCellInfo(uuid=$uuid, status=$status, "
      "sEtag=$eTagFromServer, cEtag=$eTagFromLocal"
      ")";
}

class WebDavResourceContainer {
  final Uri path;
  final String? etag;

  const WebDavResourceContainer({
    required this.path,
    this.etag,
  });

  factory WebDavResourceContainer.fromResource(WebDavStdResource resource) {
    final error = resource.error;
    if (error != null) throw error;
    return WebDavResourceContainer(
      path: resource.path,
      etag: resource.getetag.value,
    );
  }

  HabitUUID? get habitUUID {
    final filename = path.pathSegments.lastOrNull;
    if (filename == null || filename.isEmpty) return null;
    return reAppSyncHabitFileName.firstMatch(filename)?.group(1);
  }

  @override
  String toString() => 'WebDavResourceContainer(path=$path, etag=<$etag>)';
}

class FetchHabitsFromServerTask
    implements AsyncTask<List<WebDavResourceContainer>> {
  final Uri path;
  final WebDavStdClient client;

  const FetchHabitsFromServerTask({required this.path, required this.client});

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
        appLog.appsync.debug("FetchHabitsFromServerTask.run",
            ex: ['fetch resources', response.body]);
        return resources
                ?.where((e) {
                  final filename = e.path.pathSegments.lastOrNull;
                  if (filename == null) return false;
                  if (!reAppSyncHabitFileName.hasMatch(filename)) return false;
                  if (e.isCollection) return false;
                  return true;
                })
                .map(WebDavResourceContainer.fromResource)
                .toList() ??
            const [];
      });
}

class QueryHabitsFromDBTask implements AsyncTask<List<SyncDBCell>> {
  final SyncDBHelper helper;

  const QueryHabitsFromDBTask({required this.helper});

  @override
  Future<List<SyncDBCell>> run() =>
      helper.loadAllHabitsSyncInfo().then((result) => result.toList());
}

final class WebDavSyncCellInfoMergerImpl extends WebDavSyncCellInfoMerger {
  const WebDavSyncCellInfoMergerImpl();

  @override
  List<WebDavAppSyncCellInfo> convert(
      ({
        Iterable<SyncDBCell> local,
        Iterable<WebDavResourceContainer> server
      }) input) {
    final coll = <HabitUUID, WebDavAppSyncCellInfo>{};
    for (var data in input.local) {
      final uuid = data.habitUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
        uuid,
        () => WebDavAppSyncCellInfo(
            uuid: uuid, status: WebDavAppSyncInfoStatus.local),
      )
        ..eTagFromLocal = data.lastMark
        ..status = WebDavAppSyncInfoStatus.local;
    }
    for (var data in input.server) {
      final uuid = data.habitUUID;
      if (uuid == null) continue;
      coll.putIfAbsent(
          uuid,
          () => WebDavAppSyncCellInfo(
              uuid: uuid, status: WebDavAppSyncInfoStatus.server))
        ..eTagFromServer = data.etag
        ..status = WebDavAppSyncInfoStatus.server;
    }
    return coll.values.toList();
  }
}
