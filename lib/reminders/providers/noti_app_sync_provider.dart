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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide NotificationDetails;

import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../model/app_sync_server.dart';
import '../../model/app_sync_task.dart';
import '../notification_channel.dart';
import '../notification_data.dart';
import '../notification_details.dart';
import '../notification_id_range.dart';
import '../notification_service.dart';

enum AppSyncNotiTitleEnum { syncing, synced, failed }

abstract interface class NotiAppSyncProvider {
  Future<bool> readyToSync();
  Future<bool> syncing({num? percentage});
  Future<bool> syncComplete({AppSyncTaskResult? result});

  factory NotiAppSyncProvider({
    int? syncId,
    int? syncFailedId,
    AppSyncServerType? type,
    NotificationChannelData? data,
    NotificationService? service,
    L10n? l10n,
  }) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => AndroidNotiAppSyncProvider(
            syncId: syncId!,
            syncedId: syncFailedId!,
            type: type!,
            data: data!,
            service: service!,
            l10n: l10n),
        _ => syncId != null
            ? FakeNotiAppSyncProvider(syncId: syncId)
            : const FakeNotiAppSyncProvider()
      };

  factory NotiAppSyncProvider.generate({
    required AppSyncServerType type,
    required NotificationChannelData data,
    L10n? l10n,
  }) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => AndroidNotiAppSyncProvider.generate(
            data: data, type: type, l10n: l10n),
        _ => FakeNotiAppSyncProvider.generate()
      };
}

final class FakeNotiAppSyncProvider implements NotiAppSyncProvider {
  final int? syncId;

  const FakeNotiAppSyncProvider({this.syncId});

  factory FakeNotiAppSyncProvider.generate() =>
      FakeNotiAppSyncProvider(syncId: getRandomSyncId());

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

@CopyWith(skipFields: true)
final class AndroidNotiAppSyncProvider implements NotiAppSyncProvider {
  final int syncId;
  final int syncedId;
  final AppSyncServerType type;
  final NotificationChannelData data;
  final NotificationService service;

  final L10n? _l10n;

  const AndroidNotiAppSyncProvider({
    required this.syncId,
    required this.syncedId,
    required this.type,
    required this.data,
    required this.service,
    L10n? l10n,
  }) : _l10n = l10n;

  factory AndroidNotiAppSyncProvider.generate({
    int? syncId,
    int? syncFailedId,
    required AppSyncServerType type,
    required NotificationChannelData data,
    NotificationService? service,
    L10n? l10n,
  }) {
    if (syncId != null) {
      assert(isValidSyncId(syncId));
    } else {
      syncId = getRandomSyncId();
    }
    if (syncFailedId != null) {
      assert(isValidSyncId(syncFailedId));
    } else {
      syncFailedId = getRandomSyncId(type.code) + 1;
      assert(isValidSyncId(syncFailedId));
    }
    return AndroidNotiAppSyncProvider(
        syncId: syncId,
        syncedId: syncFailedId,
        type: type,
        data: data,
        service: service ?? NotificationService(),
        l10n: l10n);
  }

  String _buildTitle(AppSyncNotiTitleEnum titleType, [L10n? l10n]) {
    l10n = l10n ?? _l10n;
    if (l10n != null) {
      return l10n.appSync_noti_syncing_title(titleType.name,
          l10n.appSync_syncServerType_text(type.name, false.toString()));
    } else {
      return switch (titleType) {
        AppSyncNotiTitleEnum.syncing => "Syncing",
        AppSyncNotiTitleEnum.synced => "Synced",
        AppSyncNotiTitleEnum.failed => "Sync failed",
      };
    }
  }

  @override
  Future<bool> readyToSync() {
    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    final body = _l10n?.appSync_noti_readyToSync_body ?? "Preparing to sync...";
    return service.show(
        id: syncId,
        title: title,
        body: body,
        type: NotificationDataType.appSync,
        channelId: NotificationChannelId.appSyncing,
        details: data.appSyncing);
  }

  @override
  Future<bool> syncing({num? percentage}) {
    final String body;
    final NotificationDetails details;

    if (percentage == null) {
      body = _l10n?.appSync_nowTile_syncingText ?? "Syncing...";
      details = data.appSyncing.copyWith(
        android: data.appSyncing.android?.copyWith(
          onlyAlertOnce: true,
          channelShowBadge: false,
          showProgress: true,
          indeterminate: true,
        ),
      );
    } else {
      body = _l10n?.appSync_nowTile_syncingText_withPrt(percentage) ??
          "Syncing($percentage)...";
      details = data.appSyncing.copyWith(
        android: data.appSyncing.android?.copyWith(
          onlyAlertOnce: true,
          channelShowBadge: false,
          showProgress: true,
          progress: (percentage * 100).ceil(),
          maxProgress: 100,
        ),
      );
    }

    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    return service.show(
        id: syncId,
        title: title,
        body: body,
        type: NotificationDataType.appSync,
        channelId: NotificationChannelId.appSyncing,
        details: details);
  }

  @override
  Future<bool> syncComplete({AppSyncTaskResult? result}) {
    if (result == null) return Future.value(true);

    String buildBody() {
      switch (result) {
        case WebDavAppSyncTaskResult():
          return result.status.getStatusTextString(result.reason, _l10n);
        default:
          final now = DateTime.now();
          if (result.isSuccessed) {
            return _l10n?.appSync_nowTile_text(now.toIso8601String()) ??
                "Complete";
          } else if (result.isCancelled) {
            return _l10n?.appSync_nowTile_cancelText(now.toIso8601String()) ??
                "Cancelled";
          } else {
            return _l10n?.appSync_nowTile_errorText(now.toIso8601String()) ??
                "Failed";
          }
      }
    }

    final cancelTask = service.cancel(id: syncId);

    final Future<bool> task;
    final body = buildBody();
    if (result.isCancelled) {
      final title = _buildTitle(AppSyncNotiTitleEnum.synced, _l10n);
      task = service.show(
          id: syncedId,
          title: title,
          body: body,
          type: NotificationDataType.appSync,
          channelId: NotificationChannelId.appSyncing,
          details: data.appSyncing.copyWith(
            android: data.appSyncing.android?.copyWith(
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ));
    } else if (!result.isSuccessed) {
      final title = _buildTitle(AppSyncNotiTitleEnum.failed, _l10n);
      final error = result.error.error?.toString();
      final traceInfo = result.withError
          ? BigTextStyleInformation(
              result.error.trace?.toString() ?? body,
              summaryText: "❌",
              contentTitle: error != null
                  ? _l10n?.appSync_failedTile_errorText(error) ?? error
                  : null,
            )
          : null;
      task = service.show(
          id: syncedId,
          title: title,
          body: body,
          type: NotificationDataType.appSync,
          channelId: NotificationChannelId.appSyncFailed,
          details: data.appSyncFailed.copyWith(
            android: data.appSyncFailed.android?.copyWith(
              styleInformation: traceInfo,
            ),
          ));
    } else {
      task = Future.value(true);
    }
    return Stream.fromFutures([cancelTask, task]).every((e) => e);
  }
}
