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
      includeConnRetryCountField: true,
      includeSyncNetworkField: true),
  fake(
    code: 99,
    includePasswordField: true,
  );

  final int code;
  final bool includePathField;
  final bool includeUsernameField;
  final bool includePasswordField;
  final bool includeIgnoreSSLField;
  final bool includeConnTimeoutField;
  final bool includeConnRetryCountField;
  final bool includeSyncNetworkField;

  const AppSyncServerType(
      {required this.code,
      this.includePathField = false,
      this.includeUsernameField = false,
      this.includePasswordField = false,
      this.includeIgnoreSSLField = false,
      this.includeConnTimeoutField = false,
      this.includeConnRetryCountField = false,
      this.includeSyncNetworkField = false});

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

  static AppSyncServer? fromForm(AppSyncServerForm? form) {
    if (form == null) return null;
    switch (form.type) {
      case AppSyncServerType.webdav:
        return AppWebDavSyncServer.fromForm(form);
      case AppSyncServerType.fake:
        return AppFakeSyncServer.fromForm(form);
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
  bool get verified;
  bool get configed;

  String? get password;

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
  final bool verified;
  @override
  final bool configed;
  @override
  final String password;

  final List<AppSyncServerMobileNetwork> _syncMobileNetworks;

  final Uri path;
  final String username;
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

  factory AppWebDavSyncServer.fromForm(AppSyncServerForm form) =>
      AppWebDavSyncServer(
          identity: form.uuid.uuid,
          createTime: form.createTime,
          modifyTime: form.modifyTime,
          path: Uri.parse(form.path!),
          username: form.username!,
          password: form.password!,
          timeout: form.timeout,
          connectTimeout: form.connectTimeout,
          connectRetryCount: form.connectRetryCount,
          verified: form.verified,
          configed: form.configed,
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
      connectRetryCount: connectRetryCount,
      syncMobileNetworks: Set.of(syncMobileNetworks),
      syncInLowData: syncInLowData,
      verified: verified,
      configed: configed);

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

  @override
  String toString() => 'AppWebDavSyncServer[$identity](path=$path,'
      'username=$username,'
      'password=${List.generate(password.length, (_) => "*").join()},'
      'v|c=$verified|$configed'
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
  final bool verified;
  @override
  final bool configed;
  @override
  final String? password;

  const AppFakeSyncServer({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    required this.timeout,
    required this.verified,
    required this.configed,
    required this.password,
  }) : type = AppSyncServerType.fake;

  factory AppFakeSyncServer.newServer({
    required String identity,
    required String path,
    String password = '',
    Duration? timeout,
  }) {
    final now = DateTime.now();
    return AppFakeSyncServer(
      identity: identity,
      name: identity,
      createTime: now,
      modifyTime: now,
      timeout: timeout,
      verified: false,
      configed: false,
      password: password,
    );
  }

  AppFakeSyncServer._copyWith({
    required this.identity,
    required this.name,
    required this.createTime,
    required this.modifyTime,
    this.password,
    this.timeout,
    required this.verified,
    required this.configed,
  }) : type = AppSyncServerType.fake;

  factory AppFakeSyncServer.fromJson(Map<String, dynamic> json) =>
      _$AppFakeSyncServerFromJson(json);

  factory AppFakeSyncServer.fromForm(AppSyncServerForm form) =>
      AppFakeSyncServer(
          identity: form.uuid.uuid,
          name: form.uuid.uuid,
          createTime: form.createTime,
          modifyTime: form.modifyTime,
          timeout: form.timeout,
          verified: form.verified,
          configed: form.configed,
          password: form.password);

  @override
  String toDebugString() => """AppFakeSyncServer(
  identity=$identity,
  name=$name,
  createTime=$createTime,
  modifyTime=$modifyTime,
  type=$type,
  timeout=$timeout,
  verified=$verified,
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
  AppSyncServerForm toForm() => AppSyncServerForm(
      uuid: UuidValue.fromString(identity),
      createTime: createTime,
      modifyTime: modifyTime,
      type: type,
      path: null,
      username: null,
      password: null,
      ignoreSSL: null,
      timeout: timeout,
      connectTimeout: null,
      connectRetryCount: null,
      syncMobileNetworks: null,
      syncInLowData: null,
      verified: verified,
      configed: configed);

  @override
  Map<String, dynamic> toJson() => _$AppFakeSyncServerToJson(this);

  @override
  String toString() => 'AppFakeSyncServer[$identity]('
      'v|c=$verified|$configed'
      ')';
}

@CopyWith(skipFields: true, copyWithNull: false)
class AppSyncServerForm {
  final UuidValue uuid;
  final DateTime createTime;
  final DateTime modifyTime;

  AppSyncServerType type;
  bool verified;
  bool configed;

  String? path;
  String? username;
  String? password;
  bool? ignoreSSL;
  Duration? timeout;
  Duration? connectTimeout;
  int? connectRetryCount;
  Set<AppSyncServerMobileNetwork>? syncMobileNetworks;
  bool? syncInLowData;

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
    required this.syncMobileNetworks,
    required this.syncInLowData,
    required this.verified,
    required this.configed,
  });

  String toDebugString() {
    final password = kDebugMode
        ? this.password
        : List.generate(this.password?.length ?? 0, (_) => "*").join();
    return """AppSyncServerForm(
  uuid=$uuid,type=$type,
  createTime=$createTime,modifyTime=$modifyTime,
  path=$path,username=$username,password=$password,
  ignoreSSL=$ignoreSSL,timeout=$timeout,
  connectTimeout=$connectTimeout,connectRetryCount=$connectRetryCount,
  syncMobileNetworks=$syncMobileNetworks,
  syncInLowData=$syncInLowData,
  vertified=$verified,configed=$configed,
  )""";
  }

  @override
  String toString() => 'AppSyncServerForm[$uuid](path=$path,'
      'username=$username,'
      'password=${List.generate(password?.length ?? 0, (_) => "*").join()},'
      'v|c=$verified|$configed'
      ')';
}
