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
import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import 'common.dart';

part 'app_sync_server.g.dart';

@JsonEnum(valueField: "code")
enum AppSyncServerType implements EnumWithDBCode<AppSyncServerType> {
  unknown(code: 0),
  webdav(code: 1);

  final int code;

  const AppSyncServerType({required this.code});

  @override
  int get dbCode => code;

  static AppSyncServerType? getFromDBCode(int dbCode,
      {AppSyncServerType? withDefault = AppSyncServerType.unknown}) {
    for (var value in AppSyncServerType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

@JsonEnum(valueField: "code")
enum AppSyncServerMobileNetwork
    implements EnumWithDBCode<AppSyncServerMobileNetwork> {
  none(code: 0),
  wifi(code: 1),
  mobile(code: 2);

  final int code;

  const AppSyncServerMobileNetwork({required this.code});

  @override
  int get dbCode => code;

  static List<AppSyncServerMobileNetwork> get allowed => const [
        AppSyncServerMobileNetwork.mobile,
        AppSyncServerMobileNetwork.wifi,
      ];
}

abstract interface class AppSyncServer implements JsonAdaptor {
  static const typeJsonKey = 'type_';

  static AppSyncServer? fromJson(Map<String, dynamic> json) {
    final type = AppSyncServerType.getFromDBCode(json[typeJsonKey],
        withDefault: AppSyncServerType.unknown);
    switch (type) {
      case AppSyncServerType.webdav:
        return AppWebDavSyncServer.fromJson(json);
      default:
        return null;
    }
  }

  String get identity;
  DateTime get createTime;
  DateTime get modifyTime;
  AppSyncServerType get type;
  Iterable<AppSyncServerMobileNetwork> get syncMobileNetworks;
  bool get syncInLowData;
  DateTime? get timeout;
  bool get verified;
  bool get configed;

  String toDebugString();
}

@JsonSerializable()
@CopyWith(skipFields: true, copyWithNull: false, constructor: '_copyWith')
final class AppWebDavSyncServer implements AppSyncServer {
  @override
  final String identity;
  @override
  final DateTime createTime;
  @override
  final DateTime modifyTime;
  @override
  @JsonKey(
      name: AppSyncServer.typeJsonKey,
      includeToJson: true,
      includeFromJson: false)
  final AppSyncServerType type;
  @override
  final bool syncInLowData;
  @override
  final DateTime? timeout;
  @override
  final bool verified;
  @override
  final bool configed;

  final List<AppSyncServerMobileNetwork> _syncMobileNetworks;

  final Uri path;
  final String username;
  final String password;
  final int? maxRetryCount;
  final DateTime? connectTimeout;

  const AppWebDavSyncServer({
    required this.identity,
    required this.createTime,
    required this.modifyTime,
    required this.path,
    required this.username,
    required this.password,
    this.timeout,
    this.maxRetryCount,
    this.connectTimeout,
    required this.verified,
    required this.configed,
    required List<AppSyncServerMobileNetwork> syncMobileNetworks,
    required this.syncInLowData,
  })  : type = AppSyncServerType.webdav,
        _syncMobileNetworks = syncMobileNetworks;

  factory AppWebDavSyncServer.newServer({
    required String identity,
    required String path,
    String username = '',
    String password = '',
    Iterable<AppSyncServerMobileNetwork>? syncMobileNetworks,
    bool syncInLowData = true,
    DateTime? timeout,
    DateTime? connectTimeout,
    int? maxRetryCount,
  }) {
    final now = DateTime.now();
    return AppWebDavSyncServer(
        identity: identity,
        createTime: now,
        modifyTime: now,
        path: Uri.parse(path),
        username: username,
        password: password,
        verified: false,
        configed: false,
        syncMobileNetworks:
            syncMobileNetworks?.toList() ?? AppSyncServerMobileNetwork.allowed,
        syncInLowData: syncInLowData,
        timeout: timeout,
        maxRetryCount: maxRetryCount,
        connectTimeout: connectTimeout);
  }

  AppWebDavSyncServer._copyWith({
    required this.identity,
    required this.createTime,
    required this.modifyTime,
    required this.path,
    required this.username,
    required this.password,
    this.timeout,
    this.maxRetryCount,
    this.connectTimeout,
    required this.verified,
    required this.configed,
    required Iterable<AppSyncServerMobileNetwork> syncMobileNetworks,
    required this.syncInLowData,
  })  : type = AppSyncServerType.webdav,
        _syncMobileNetworks = [] {
    _syncMobileNetworks.addAll(syncMobileNetworks);
  }

  factory AppWebDavSyncServer.fromJson(Map<String, dynamic> json) =>
      _$AppWebDavSyncServerFromJson(json);

  @override
  Iterable<AppSyncServerMobileNetwork> get syncMobileNetworks =>
      _syncMobileNetworks;

  @override
  Map<String, dynamic> toJson() => _$AppWebDavSyncServerToJson(this);

  @override
  String toDebugString() {
    return """AppWebDavSyncServer(
    identity: $identity,
    createTime: $createTime,
    modifyTime: $modifyTime,
    type: $type,
    syncInLowData: $syncInLowData,
    timeout: $timeout,
    verified: $verified,
    configed: $configed,
    syncMobileNetworks: $_syncMobileNetworks,
    path: $path,
    username: $username,
    password: $password,
    maxRetryCount: $maxRetryCount,
    connectTimeout: $connectTimeout
    )""";
  }
}
