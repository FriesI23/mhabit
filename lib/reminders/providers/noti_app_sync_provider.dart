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

import '../../logging/helper.dart';
import '../../model/_app_sync_tasks/app_sync_task.dart';
import '../notification_channel.dart';
import '../notification_id_range.dart';

abstract interface class NotiAppSyncProvider {
  Future<bool> readyToSync();
  Future<bool> syncing({num? percentage});
  Future<bool> syncComplete({AppSyncTaskResult? result});

  factory NotiAppSyncProvider({
    int? syncId,
    NotificationChannelData? data,
  }) =>
      syncId != null
          ? _FakeNotiAppSyncProvider(syncId: syncId)
          : const _FakeNotiAppSyncProvider();

  factory NotiAppSyncProvider.generate({NotificationChannelData? data}) =>
      NotiAppSyncProvider(syncId: getRandomSyncId(), data: data);
}

final class _FakeNotiAppSyncProvider implements NotiAppSyncProvider {
  final int? syncId;

  const _FakeNotiAppSyncProvider({this.syncId});

  String get pfx => syncId != null ? "sid:$syncId" : hashCode.toString();

  @override
  Future<bool> readyToSync() async {
    appLog.appsync.debug("_FakeNotiAppSyncProvider[$pfx].readyToSync");
    return false;
  }

  @override
  Future<bool> syncComplete({AppSyncTaskResult? result}) async {
    appLog.appsync
        .debug("_FakeNotiAppSyncProvider[$pfx].syncComplete", ex: [result]);
    return false;
  }

  @override
  Future<bool> syncing({num? percentage}) async {
    appLog.appsync
        .debug("_FakeNotiAppSyncProvider[$pfx].syncing", ex: [percentage]);
    return false;
  }
}
