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
    Duration? delayed,
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
        TargetPlatform.iOS || TargetPlatform.macOS => DrawinNotiAppSyncProvider(
            syncId: syncId!,
            syncedId: syncFailedId!,
            type: type!,
            data: data!,
            service: service!,
            delayed: delayed,
            l10n: l10n),
        _ => syncId != null
            ? FakeNotiAppSyncProvider(syncId: syncId)
            : const FakeNotiAppSyncProvider()
      };

  factory NotiAppSyncProvider.generate({
    required AppSyncServerType type,
    required NotificationChannelData data,
    Duration? delayed = const Duration(seconds: 2),
    L10n? l10n,
  }) =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => AndroidNotiAppSyncProvider.generate(
            data: data, type: type, l10n: l10n),
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          DrawinNotiAppSyncProvider.generate(
              type: type, data: data, delayed: delayed, l10n: l10n),
        _ => FakeNotiAppSyncProvider.generate()
      };
}

class _NotiThrottle {
  final Map<String, Future> _trottleMap = {};

  _NotiThrottle();

  bool isThrottled(String identity) => _trottleMap.containsKey(identity);

  bool regr(String identity, {required Duration delay}) {
    if (isThrottled(identity)) return false;
    _trottleMap[identity] = Future.delayed(delay).whenComplete(
      () => _trottleMap.remove(identity),
    );
    return true;
  }

  bool unregr(String identity) => _trottleMap.remove(identity) != null;
}

abstract class _Helper {
  static int buildSyncId(int? id) {
    if (id != null) {
      assert(isValidSyncId(id));
    } else {
      id = getRandomSyncId();
    }
    return id;
  }

  static int buildSyncedId(int? id, [AppSyncServerType? type]) {
    if (id != null) {
      assert(isValidSyncId(id));
    } else {
      id = getRandomSyncId(type?.code) + 1;
      assert(isValidSyncId(id));
    }
    return id;
  }

  static String buildSyncTitle(
      AppSyncNotiTitleEnum titleType, AppSyncServerType type,
      [L10n? l10n]) {
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

  static String buildSyncResultBody(AppSyncTaskResult result, [L10n? l10n]) {
    switch (result) {
      case WebDavAppSyncTaskResult():
        return result.status.getStatusTextString(result.reason, l10n);
      default:
        final now = DateTime.now();
        if (result.isSuccessed) {
          return l10n?.appSync_nowTile_text(now.toIso8601String()) ??
              "Complete";
        } else if (result.isCancelled) {
          return l10n?.appSync_nowTile_cancelText(now.toIso8601String()) ??
              "Cancelled";
        } else {
          return l10n?.appSync_nowTile_errorText(now.toIso8601String()) ??
              "Failed";
        }
    }
  }

  static String buildReadyToSyncBody([L10n? l10n]) =>
      l10n?.appSync_noti_readyToSync_body ?? "Preparing to sync...";

  static String buildSyncingBody(num? percentage, [L10n? l10n]) {
    if (percentage == null) {
      return l10n?.appSync_nowTile_syncingText ?? "Syncing...";
    } else {
      return l10n?.appSync_nowTile_syncingText_withPrt(percentage) ??
          "Syncing($percentage)...";
    }
  }
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

abstract class BaseNotiAppSyncProvider implements NotiAppSyncProvider {
  final int syncId;
  final int syncedId;
  final AppSyncServerType type;
  final NotificationChannelData data;
  final NotificationService service;

  const BaseNotiAppSyncProvider({
    required this.syncId,
    required this.syncedId,
    required this.type,
    required this.data,
    required this.service,
  });

  Future<bool> _show(
          {required int id,
          required String title,
          String? body,
          required NotificationChannelId channelId,
          required NotificationDetails details}) =>
      service.show(
          id: id,
          title: title,
          body: body,
          type: NotificationDataType.appSync,
          channelId: channelId,
          details: details);

  Future<bool> showAppSyncing(
          {required String title,
          String? body,
          NotificationDetails? details}) =>
      _show(
          id: syncId,
          title: title,
          body: body,
          channelId: NotificationChannelId.appSyncing,
          details: details ?? data.appSyncing);

  Future<bool> showAppSyncFailed(
          {required String title,
          String? body,
          NotificationDetails? details}) =>
      _show(
          id: syncedId,
          title: title,
          body: body,
          channelId: NotificationChannelId.appSyncFailed,
          details: details ?? data.appSyncFailed);
}

final class AndroidNotiAppSyncProvider extends BaseNotiAppSyncProvider {
  final L10n? _l10n;

  const AndroidNotiAppSyncProvider({
    required super.syncId,
    required super.syncedId,
    required super.type,
    required super.data,
    required super.service,
    L10n? l10n,
  }) : _l10n = l10n;

  factory AndroidNotiAppSyncProvider.generate({
    int? syncId,
    int? syncedId,
    required AppSyncServerType type,
    required NotificationChannelData data,
    NotificationService? service,
    L10n? l10n,
  }) =>
      AndroidNotiAppSyncProvider(
          syncId: _Helper.buildSyncId(syncId),
          syncedId: _Helper.buildSyncedId(syncedId, type),
          type: type,
          data: data,
          service: service ?? NotificationService(),
          l10n: l10n);

  String _buildTitle(AppSyncNotiTitleEnum titleType, [L10n? l10n]) =>
      _Helper.buildSyncTitle(titleType, type, l10n ?? _l10n);

  @override
  Future<bool> readyToSync() {
    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    final body = _Helper.buildReadyToSyncBody(_l10n);
    return showAppSyncing(title: title, body: body);
  }

  @override
  Future<bool> syncing({num? percentage}) {
    NotificationDetails buildDetails() {
      if (percentage == null) {
        return data.appSyncing.copyWith(
            android: data.appSyncing.android?.copyWith(
                onlyAlertOnce: true,
                channelShowBadge: false,
                showProgress: true,
                indeterminate: true));
      } else {
        return data.appSyncing.copyWith(
            android: data.appSyncing.android?.copyWith(
                onlyAlertOnce: true,
                channelShowBadge: false,
                showProgress: true,
                progress: (percentage * 100).ceil(),
                maxProgress: 100));
      }
    }

    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    final body = _Helper.buildSyncingBody(percentage, _l10n);
    return showAppSyncing(title: title, body: body, details: buildDetails());
  }

  @override
  Future<bool> syncComplete({AppSyncTaskResult? result}) {
    if (result == null) return Future.value(true);
    final cancelTask = service.cancel(id: syncId);
    final body = _Helper.buildSyncResultBody(result, _l10n);
    final Future<bool> task;
    if (result.isCancelled) {
      final title = _buildTitle(AppSyncNotiTitleEnum.synced, _l10n);
      final details = data.appSyncing.copyWith(
          android: data.appSyncing.android?.copyWith(
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority));
      task = showAppSyncing(title: title, body: body, details: details);
    } else if (!result.isSuccessed) {
      final title = _buildTitle(AppSyncNotiTitleEnum.failed, _l10n);
      final error = result.error.error?.toString();
      final sytleInformation = result.withError
          ? BigTextStyleInformation(
              result.error.trace?.toString() ?? body,
              summaryText: "❌",
              contentTitle: error != null
                  ? _l10n?.appSync_failedTile_errorText(error) ?? error
                  : null,
            )
          : null;
      final details = data.appSyncFailed.copyWith(
          android: data.appSyncFailed.android
              ?.copyWith(styleInformation: sytleInformation));
      task = showAppSyncFailed(title: title, body: body, details: details);
    } else {
      task = Future.value(true);
    }
    return Stream.fromFutures([cancelTask, task]).every((e) => e);
  }
}

final class DrawinNotiAppSyncProvider extends BaseNotiAppSyncProvider {
  final Duration? delayed;

  final L10n? _l10n;
  late final String _syncTrKey;
  late final _NotiThrottle? _throttle;

  DrawinNotiAppSyncProvider({
    required super.syncId,
    required super.syncedId,
    required super.type,
    required super.data,
    required super.service,
    this.delayed,
    L10n? l10n,
  }) : _l10n = l10n {
    _syncTrKey = "id.$syncId.${type.code}";
    _throttle = delayed != null ? _NotiThrottle() : null;
  }

  factory DrawinNotiAppSyncProvider.generate({
    int? syncId,
    int? syncFailedId,
    required AppSyncServerType type,
    required NotificationChannelData data,
    NotificationService? service,
    Duration? delayed,
    L10n? l10n,
  }) =>
      DrawinNotiAppSyncProvider(
          syncId: _Helper.buildSyncId(syncId),
          syncedId: _Helper.buildSyncedId(syncFailedId, type),
          type: type,
          data: data,
          service: service ?? NotificationService(),
          l10n: l10n,
          delayed: delayed);

  String _buildTitle(AppSyncNotiTitleEnum titleType, [L10n? l10n]) =>
      _Helper.buildSyncTitle(titleType, type, l10n ?? _l10n);

  @override
  Future<bool> readyToSync() {
    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    final body = _Helper.buildReadyToSyncBody(_l10n);
    return showAppSyncing(title: title, body: body);
  }

  @override
  Future<bool> syncing({num? percentage}) {
    if (_throttle?.isThrottled(_syncTrKey) == true) return Future.value(false);
    _throttle?.regr(_syncTrKey, delay: delayed ?? Duration.zero);

    NotificationDetails buildDetails() {
      if (percentage == null) {
        return data.appSyncing;
      } else {
        return data.appSyncing.copyWith(
            iOS: data.appSyncing.iOS?.copyWith(
                subtitle: _Helper.buildSyncingBody(percentage, _l10n)));
      }
    }

    final title = _buildTitle(AppSyncNotiTitleEnum.syncing, _l10n);
    final body = _Helper.buildSyncingBody(null, _l10n);
    return showAppSyncing(title: title, body: body, details: buildDetails());
  }

  @override
  Future<bool> syncComplete({AppSyncTaskResult? result}) {
    if (result == null) return Future.value(true);
    final cancelTask = service.cancel(id: syncId);
    final Future<bool> task;
    if (result.isCancelled) {
      final title = _buildTitle(AppSyncNotiTitleEnum.synced, _l10n);
      final body = _Helper.buildSyncResultBody(result, _l10n);
      final details = data.appSyncing.copyWith(
          iOS: data.appSyncing.iOS
              ?.copyWith(interruptionLevel: InterruptionLevel.active));
      task = showAppSyncing(title: title, body: body, details: details);
    } else if (!result.isSuccessed) {
      final title = _buildTitle(AppSyncNotiTitleEnum.failed, _l10n);
      final error = result.error.error?.toString();
      final details = data.appSyncFailed.copyWith(
          iOS: data.appSyncFailed.iOS
              ?.copyWith(subtitle: _Helper.buildSyncResultBody(result, _l10n)));
      final body = error != null
          ? _l10n?.appSync_failedTile_errorText(error) ?? error
          : null;
      task = showAppSyncFailed(title: title, body: body, details: details);
    } else {
      task = Future.value(true);
    }
    return Stream.fromFutures([cancelTask, task]).every((e) => e);
  }
}
