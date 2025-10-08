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
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../common/enums.dart';
import '../common/types.dart';
import 'app_sync_server_form.dart';
import 'common.dart';

part 'app_sync_server.g.dart';

@JsonEnum(valueField: "code")
enum AppSyncServerType implements EnumWithDBCode<AppSyncServerType> {
  unknown(code: 0),
  webdav(
      code: 1,
      config: AppSyncServerTypeConfig(
        pathField: true,
        usernameField: true,
        passwordField: true,
        ignoreSSLField: true,
        connTimeoutField: true,
        connRetryCountField: true,
        syncNetworkField: true,
      )),
  fake(code: 99);

  final int code;
  final AppSyncServerTypeConfig config;
  const AppSyncServerType({
    required this.code,
    this.config = const AppSyncServerTypeConfig(),
  });

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

class AppSyncServerTypeConfig {
  final bool pathField;
  final bool usernameField;
  final bool passwordField;
  final bool ignoreSSLField;
  final bool connTimeoutField;
  final bool connRetryCountField;
  final bool syncNetworkField;

  const AppSyncServerTypeConfig({
    this.pathField = false,
    this.usernameField = false,
    this.passwordField = false,
    this.ignoreSSLField = false,
    this.connTimeoutField = false,
    this.connRetryCountField = false,
    this.syncNetworkField = false,
  });
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

  static AppSyncServer? fromJson(JsonMap json) {
    final type = AppSyncServerType.getFromDBCode(
        (json[typeJsonKey] as int?) ?? -1,
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
    final identity = genNewIdentity();
    switch (type) {
      case AppSyncServerType.webdav:
        return AppWebDavSyncServer.newServer(identity: identity, path: '');
      case AppSyncServerType.fake:
        return AppFakeSyncServer.newServer(identity: identity, path: '');
      default:
        return null;
    }
  }

  static String genNewIdentity() => const Uuid().v4();

  String get name;
  String get identity;
  DateTime get createTime;
  DateTime get modifyTime;
  AppSyncServerType get type;
  Duration? get timeout;
  bool get configed;

  /// Checks if the server configuration is identical to [other].
  /// Ignores password if [withoutPassword] is `true`.
  bool isSameConfig(AppSyncServer other, {bool withoutPassword = false});

  /// Checks if this and [other] represent the same server.
  /// Always `true` if `isSameConfig` returns `true`.
  bool isSameServer(AppSyncServer other, {bool withoutPassword = false});

  AppSyncServerForm toForm();
  String toDebugString();
}

@JsonSerializable()
@CopyWith(skipFields: true, copyWithNull: false, constructor: '_copyWith')
class AppWebDavSyncServer implements AppSyncServer {
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
  final Duration? timeout;
  @override
  final bool configed;

  final List<AppSyncServerMobileNetwork> _syncMobileNetworks;

  final Uri path;
  final String username;
  final String password;
  final bool ignoreSSL;
  final bool syncInLowData;
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

  factory AppWebDavSyncServer.fromForm(WebDavSyncServerForm form,
          {required DateTime createTime,
          required DateTime modifyTime,
          required bool configed}) =>
      AppWebDavSyncServer(
          identity: form.uuid,
          createTime: createTime,
          modifyTime: modifyTime,
          path: Uri.parse(form.path!),
          username: form.username!,
          password: form.password!,
          timeout: form.timeout,
          connectTimeout: form.connectTimeout,
          connectRetryCount: form.connectRetryCount,
          configed: configed,
          syncMobileNetworks: form.syncMobileNetworks!.toList(),
          ignoreSSL: form.ignoreSSL!,
          syncInLowData: form.syncInLowData!);

  Iterable<AppSyncServerMobileNetwork> get syncMobileNetworks =>
      _syncMobileNetworks;

  @override
  @JsonKey()
  String get name => path.toString();

  @override
  bool isSameConfig(AppSyncServer other, {bool withoutPassword = false}) {
    if (identical(this, other)) return true;
    if (other is! AppWebDavSyncServer) return false;
    return (identity == other.identity &&
        path == other.path &&
        username == other.username &&
        ignoreSSL == other.ignoreSSL &&
        timeout == other.timeout &&
        connectRetryCount == other.connectRetryCount &&
        connectTimeout == other.connectTimeout &&
        setEquals(
            syncMobileNetworks.toSet(), other.syncMobileNetworks.toSet()) &&
        syncInLowData == other.syncInLowData &&
        (withoutPassword ? true : password == other.password));
  }

  @override
  bool isSameServer(AppSyncServer other, {bool withoutPassword = false}) {
    if (isSameConfig(other, withoutPassword: withoutPassword)) return true;
    if (other is! AppWebDavSyncServer) return false;
    return (identity == other.identity && path == other.path);
  }

  @override
  Map<String, dynamic> toJson() => _$AppWebDavSyncServerToJson(this);

  @override
  AppSyncServerForm toForm() => WebDavSyncServerForm(
      uuid: identity,
      path: path.toString(),
      username: username,
      password: password,
      ignoreSSL: ignoreSSL,
      timeout: timeout,
      connectTimeout: connectTimeout,
      connectRetryCount: connectRetryCount,
      syncMobileNetworks: Set.of(syncMobileNetworks),
      syncInLowData: syncInLowData);

  @override
  String toDebugString() {
    final password = kDebugMode
        ? this.password
        : List.generate(this.password.length, (_) => "*").join();
    return """AppWebDavSyncServer(
  identity: $identity,
  createTime: $createTime,
  modifyTime: $modifyTime,
  type: $type,
  syncInLowData: $syncInLowData,
  timeout: $timeout,
  configed: $configed,
  syncMobileNetworks: $_syncMobileNetworks,
  path: $path,
  username: $username,
  password: $password,
  connectTimeout: $connectTimeout,
  connectRetryCount: $connectRetryCount,
)""";
  }

  @override
  String toString() => 'AppWebDavSyncServer[$identity](path=$path,'
      'username=$username,'
      'password=${List.generate(password.length, (_) => "*").join()},'
      'c=$configed'
      ')';
}

@JsonSerializable()
@CopyWith(skipFields: true, copyWithNull: false, constructor: '_copyWith')
class AppFakeSyncServer implements AppSyncServer {
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
  final Duration? timeout;
  @override
  final bool configed;

  final Map<String, String>? data;

  const AppFakeSyncServer({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    required this.timeout,
    required this.configed,
    required this.data,
  }) : type = AppSyncServerType.fake;

  factory AppFakeSyncServer.newServer({
    required String identity,
    required String path,
    Duration? timeout,
  }) {
    final now = DateTime.now();
    return AppFakeSyncServer(
        identity: identity,
        name: identity,
        createTime: now,
        modifyTime: now,
        timeout: timeout,
        configed: false,
        data: const {});
  }

  AppFakeSyncServer._copyWith({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    this.timeout,
    this.data = const {},
    required this.configed,
  }) : type = AppSyncServerType.fake;

  factory AppFakeSyncServer.fromJson(Map<String, dynamic> json) =>
      _$AppFakeSyncServerFromJson(json);

  factory AppFakeSyncServer.fromForm(FakeSyncServerForm form,
          {required DateTime createTime,
          required DateTime modifyTime,
          Duration? timeout,
          Map<String, String>? data,
          required bool configed}) =>
      AppFakeSyncServer(
          identity: form.uuid,
          name: form.uuid,
          createTime: createTime,
          modifyTime: modifyTime,
          timeout: timeout,
          data: data ?? {},
          configed: configed);

  @override
  String toDebugString() => """AppFakeSyncServer(
  identity=$identity,
  name=$name,
  createTime=$createTime,
  modifyTime=$modifyTime,
  type=$type,
  timeout=$timeout,
  configed=$configed,
)""";

  @override
  bool isSameConfig(AppSyncServer other, {bool withoutPassword = true}) {
    if (identical(this, other)) return true;
    if (other is! AppFakeSyncServer) return false;
    return identity == other.identity;
  }

  @override
  bool isSameServer(AppSyncServer other, {bool withoutPassword = false}) =>
      isSameConfig(other, withoutPassword: withoutPassword);

  @override
  AppSyncServerForm toForm() => FakeSyncServerForm(uuid: identity);

  @override
  Map<String, dynamic> toJson() => _$AppFakeSyncServerToJson(this);

  @override
  String toString() => 'AppFakeSyncServer[$identity]('
      'c=$configed'
      ')';
}
