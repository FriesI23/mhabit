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
import 'package:uuid/uuid.dart';

import '../common/enums.dart';
import 'common.dart';

part 'app_sync_server.g.dart';

@JsonEnum(valueField: "code")
enum AppSyncServerType implements EnumWithDBCode<AppSyncServerType> {
  unknown(code: 0),
  webdav(
      code: 1,
      includePathField: true,
      includeUsernameField: true,
      includePasswordField: true,
      includeIgnoreSSLField: true,
      includeConnTimeoutField: true,
      includeRetryCountFIeld: true),
  fake(code: 99);

  final int code;
  final bool includePathField;
  final bool includeUsernameField;
  final bool includePasswordField;
  final bool includeIgnoreSSLField;
  final bool includeConnTimeoutField;
  final bool includeRetryCountFIeld;

  const AppSyncServerType(
      {required this.code,
      this.includePathField = false,
      this.includeUsernameField = false,
      this.includePasswordField = false,
      this.includeIgnoreSSLField = false,
      this.includeConnTimeoutField = false,
      this.includeRetryCountFIeld = false});

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
      case AppSyncServerType.fake:
        return AppFakeSyncServer.fromJson(json);
      default:
        return null;
    }
  }

  static AppSyncServer? newServer(AppSyncServerType type) {
    final identity = const Uuid().v4();
    switch (type) {
      case AppSyncServerType.webdav:
        return AppWebDavSyncServer.newServer(identity: identity, path: '');
      case AppSyncServerType.fake:
        return AppFakeSyncServer.newServer(identity: identity, path: '');
      default:
        return null;
    }
  }

  String get name;
  String get identity;
  DateTime get createTime;
  DateTime get modifyTime;
  AppSyncServerType get type;
  Iterable<AppSyncServerMobileNetwork> get syncMobileNetworks;
  bool get syncInLowData;
  bool get ignoreSSL;
  Duration? get timeout;
  bool get verified;
  bool get configed;

  AppSyncServerForm toForm();
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
  final bool ignoreSSL;
  @override
  final bool syncInLowData;
  @override
  final Duration? timeout;
  @override
  final bool verified;
  @override
  final bool configed;

  final List<AppSyncServerMobileNetwork> _syncMobileNetworks;

  final Uri path;
  final String username;
  final String password;
  final int? connectRetryCount;
  final Duration? connectTimeout;

  const AppWebDavSyncServer({
    required this.identity,
    required this.createTime,
    required this.modifyTime,
    required this.path,
    required this.username,
    required this.password,
    this.timeout,
    this.connectRetryCount,
    this.connectTimeout,
    required this.verified,
    required this.configed,
    required List<AppSyncServerMobileNetwork> syncMobileNetworks,
    required this.ignoreSSL,
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
    bool ignoreSSL = false,
    Duration? timeout,
    Duration? connectTimeout,
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
        ignoreSSL: ignoreSSL,
        timeout: timeout,
        connectRetryCount: maxRetryCount,
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
    this.connectRetryCount,
    this.connectTimeout,
    required this.verified,
    required this.configed,
    required Iterable<AppSyncServerMobileNetwork> syncMobileNetworks,
    required this.syncInLowData,
    required this.ignoreSSL,
  })  : type = AppSyncServerType.webdav,
        _syncMobileNetworks = [] {
    _syncMobileNetworks.addAll(syncMobileNetworks);
  }

  factory AppWebDavSyncServer.fromJson(Map<String, dynamic> json) =>
      _$AppWebDavSyncServerFromJson(json);

  // TODO: implement
  factory AppWebDavSyncServer.fromForm(AppSyncServerForm form) =>
      throw UnimplementedError();

  @override
  Iterable<AppSyncServerMobileNetwork> get syncMobileNetworks =>
      _syncMobileNetworks;

  @override
  @JsonKey()
  String get name => path.toString();

  @override
  Map<String, dynamic> toJson() => _$AppWebDavSyncServerToJson(this);

  @override
  AppSyncServerForm toForm() => AppSyncServerForm(
      uuid: UuidValue.fromString(identity),
      createTime: createTime,
      modifyTime: modifyTime,
      type: type,
      path: path.toString(),
      username: username,
      password: password,
      ignoreSSL: ignoreSSL,
      timeout: timeout,
      connectTimeout: connectTimeout,
      connectRetryCount: connectRetryCount);

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
  connectTimeout: $connectTimeout,
  connectRetryCount: $connectRetryCount,
)""";
  }
}

@JsonSerializable()
@CopyWith(skipFields: true, copyWithNull: false, constructor: '_copyWith')
final class AppFakeSyncServer implements AppSyncServer {
  @override
  final String identity;
  @override
  final String name;
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
  final bool ignoreSSL;
  @override
  final bool syncInLowData;
  @override
  final Duration? timeout;
  @override
  final bool verified;
  @override
  final bool configed;
  @override
  final List<AppSyncServerMobileNetwork> syncMobileNetworks;

  const AppFakeSyncServer({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    required this.ignoreSSL,
    required this.syncInLowData,
    required this.timeout,
    required this.verified,
    required this.configed,
    required this.syncMobileNetworks,
  }) : type = AppSyncServerType.fake;

  factory AppFakeSyncServer.newServer({
    required String identity,
    required String path,
    String username = '',
    String password = '',
    List<AppSyncServerMobileNetwork>? syncMobileNetworks,
    bool syncInLowData = true,
    bool ignoreSSL = false,
    Duration? timeout,
    Duration? connectTimeout,
    int? maxRetryCount,
  }) {
    final now = DateTime.now();
    return AppFakeSyncServer(
      identity: identity,
      name: identity,
      createTime: now,
      modifyTime: now,
      ignoreSSL: ignoreSSL,
      syncInLowData: syncInLowData,
      timeout: timeout,
      verified: false,
      configed: false,
      syncMobileNetworks:
          syncMobileNetworks ?? AppSyncServerMobileNetwork.allowed,
    );
  }

  AppFakeSyncServer._copyWith({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    required this.ignoreSSL,
    required this.syncInLowData,
    this.timeout,
    required this.verified,
    required this.configed,
    required List<AppSyncServerMobileNetwork> syncMobileNetworks,
  })  : type = AppSyncServerType.fake,
        syncMobileNetworks = [] {
    this.syncMobileNetworks.addAll(syncMobileNetworks);
  }

  factory AppFakeSyncServer.fromJson(Map<String, dynamic> json) =>
      _$AppFakeSyncServerFromJson(json);

  // TODO: implement
  factory AppFakeSyncServer.fromForm(AppSyncServerForm form) =>
      throw UnimplementedError();

  @override
  String toDebugString() => """AppFakeSyncServer(
  identity=$identity,
  name=$name,
  createTime=$createTime,
  modifyTime=$modifyTime,
  type=$type,
  ignoreSSL=$ignoreSSL,
  syncInLowData=$syncInLowData,
  timeout=$timeout,
  verified=$verified,
  configed=$configed,
  syncMobileNetworks=$syncMobileNetworks,
)""";

  @override
  AppSyncServerForm toForm() => AppSyncServerForm(
      uuid: UuidValue.fromString(identity),
      createTime: createTime,
      modifyTime: modifyTime,
      type: type,
      path: null,
      username: null,
      password: null,
      ignoreSSL: ignoreSSL,
      timeout: timeout,
      connectTimeout: null,
      connectRetryCount: null);

  @override
  Map<String, dynamic> toJson() => _$AppFakeSyncServerToJson(this);
}

@CopyWith(skipFields: true, copyWithNull: false)
class AppSyncServerForm {
  final UuidValue uuid;
  final DateTime createTime;
  final DateTime modifyTime;

  AppSyncServerType type;

  String? path;
  String? username;
  String? password;
  bool? ignoreSSL;
  Duration? timeout;
  Duration? connectTimeout;
  int? connectRetryCount;

  AppSyncServerForm({
    required this.uuid,
    required this.type,
    required this.createTime,
    required this.modifyTime,
    required this.path,
    required this.username,
    required this.password,
    required this.ignoreSSL,
    required this.timeout,
    required this.connectTimeout,
    required this.connectRetryCount,
  });

  String toDebugString() => """AppSyncServerForm(
  uuid=$uuid,type=$type,
  createTime=$createTime,modifyTime=$modifyTime,
  path=$path,username=$username,password=$password,
  ignoreSSL=$ignoreSSL,timeout=$timeout,
  connectTimeout=$connectTimeout,connectRetryCount=$connectRetryCount
)""";
}
