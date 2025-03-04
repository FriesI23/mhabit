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

import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart';

import '../../common/async.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/sync.dart';

final reAppSyncHabitFileName = RegExp(r'^habit-[^/]+\.json$');

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
