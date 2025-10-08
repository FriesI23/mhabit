// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_sync_server.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppWebDavSyncServerCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppWebDavSyncServer(...).copyWith(id: 12, name: "My name")
  /// ````
  AppWebDavSyncServer call({
    String identity,
    DateTime createTime,
    DateTime modifyTime,
    Uri path,
    String username,
    String password,
    Duration? timeout,
    int? connectRetryCount,
    Duration? connectTimeout,
    bool configed,
    Iterable<AppSyncServerMobileNetwork> syncMobileNetworks,
    bool syncInLowData,
    bool ignoreSSL,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppWebDavSyncServer.copyWith(...)`.
class _$AppWebDavSyncServerCWProxyImpl implements _$AppWebDavSyncServerCWProxy {
  const _$AppWebDavSyncServerCWProxyImpl(this._value);

  final AppWebDavSyncServer _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppWebDavSyncServer(...).copyWith(id: 12, name: "My name")
  /// ````
  AppWebDavSyncServer call({
    Object? identity = const $CopyWithPlaceholder(),
    Object? createTime = const $CopyWithPlaceholder(),
    Object? modifyTime = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? timeout = const $CopyWithPlaceholder(),
    Object? connectRetryCount = const $CopyWithPlaceholder(),
    Object? connectTimeout = const $CopyWithPlaceholder(),
    Object? configed = const $CopyWithPlaceholder(),
    Object? syncMobileNetworks = const $CopyWithPlaceholder(),
    Object? syncInLowData = const $CopyWithPlaceholder(),
    Object? ignoreSSL = const $CopyWithPlaceholder(),
  }) {
    return AppWebDavSyncServer._copyWith(
      identity: identity == const $CopyWithPlaceholder()
          ? _value.identity
          // ignore: cast_nullable_to_non_nullable
          : identity as String,
      createTime: createTime == const $CopyWithPlaceholder()
          ? _value.createTime
          // ignore: cast_nullable_to_non_nullable
          : createTime as DateTime,
      modifyTime: modifyTime == const $CopyWithPlaceholder()
          ? _value.modifyTime
          // ignore: cast_nullable_to_non_nullable
          : modifyTime as DateTime,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as Uri,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      timeout: timeout == const $CopyWithPlaceholder()
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as Duration?,
      connectRetryCount: connectRetryCount == const $CopyWithPlaceholder()
          ? _value.connectRetryCount
          // ignore: cast_nullable_to_non_nullable
          : connectRetryCount as int?,
      connectTimeout: connectTimeout == const $CopyWithPlaceholder()
          ? _value.connectTimeout
          // ignore: cast_nullable_to_non_nullable
          : connectTimeout as Duration?,
      configed: configed == const $CopyWithPlaceholder()
          ? _value.configed
          // ignore: cast_nullable_to_non_nullable
          : configed as bool,
      syncMobileNetworks: syncMobileNetworks == const $CopyWithPlaceholder()
          ? _value.syncMobileNetworks
          // ignore: cast_nullable_to_non_nullable
          : syncMobileNetworks as Iterable<AppSyncServerMobileNetwork>,
      syncInLowData: syncInLowData == const $CopyWithPlaceholder()
          ? _value.syncInLowData
          // ignore: cast_nullable_to_non_nullable
          : syncInLowData as bool,
      ignoreSSL: ignoreSSL == const $CopyWithPlaceholder()
          ? _value.ignoreSSL
          // ignore: cast_nullable_to_non_nullable
          : ignoreSSL as bool,
    );
  }
}

extension $AppWebDavSyncServerCopyWith on AppWebDavSyncServer {
  /// Returns a callable class that can be used as follows: `instanceOfAppWebDavSyncServer.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppWebDavSyncServerCWProxy get copyWith =>
      _$AppWebDavSyncServerCWProxyImpl(this);
}

abstract class _$AppFakeSyncServerCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppFakeSyncServer(...).copyWith(id: 12, name: "My name")
  /// ````
  AppFakeSyncServer call({
    String identity,
    String name,
    DateTime createTime,
    DateTime modifyTime,
    Duration? timeout,
    Map<String, String>? data,
    bool configed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppFakeSyncServer.copyWith(...)`.
class _$AppFakeSyncServerCWProxyImpl implements _$AppFakeSyncServerCWProxy {
  const _$AppFakeSyncServerCWProxyImpl(this._value);

  final AppFakeSyncServer _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppFakeSyncServer(...).copyWith(id: 12, name: "My name")
  /// ````
  AppFakeSyncServer call({
    Object? identity = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? createTime = const $CopyWithPlaceholder(),
    Object? modifyTime = const $CopyWithPlaceholder(),
    Object? timeout = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? configed = const $CopyWithPlaceholder(),
  }) {
    return AppFakeSyncServer._copyWith(
      identity: identity == const $CopyWithPlaceholder()
          ? _value.identity
          // ignore: cast_nullable_to_non_nullable
          : identity as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      createTime: createTime == const $CopyWithPlaceholder()
          ? _value.createTime
          // ignore: cast_nullable_to_non_nullable
          : createTime as DateTime,
      modifyTime: modifyTime == const $CopyWithPlaceholder()
          ? _value.modifyTime
          // ignore: cast_nullable_to_non_nullable
          : modifyTime as DateTime,
      timeout: timeout == const $CopyWithPlaceholder()
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as Duration?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Map<String, String>?,
      configed: configed == const $CopyWithPlaceholder()
          ? _value.configed
          // ignore: cast_nullable_to_non_nullable
          : configed as bool,
    );
  }
}

extension $AppFakeSyncServerCopyWith on AppFakeSyncServer {
  /// Returns a callable class that can be used as follows: `instanceOfAppFakeSyncServer.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppFakeSyncServerCWProxy get copyWith =>
      _$AppFakeSyncServerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppWebDavSyncServer _$AppWebDavSyncServerFromJson(Map<String, dynamic> json) =>
    AppWebDavSyncServer(
      identity: json['identity'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      modifyTime: DateTime.parse(json['modifyTime'] as String),
      path: Uri.parse(json['path'] as String),
      username: json['username'] as String,
      password: json['password'] as String,
      timeout: json['timeout'] == null
          ? null
          : Duration(microseconds: (json['timeout'] as num).toInt()),
      connectRetryCount: (json['connectRetryCount'] as num?)?.toInt(),
      connectTimeout: json['connectTimeout'] == null
          ? null
          : Duration(microseconds: (json['connectTimeout'] as num).toInt()),
      configed: json['configed'] as bool,
      syncMobileNetworks: (json['syncMobileNetworks'] as List<dynamic>)
          .map((e) => $enumDecode(_$AppSyncServerMobileNetworkEnumMap, e))
          .toList(),
      ignoreSSL: json['ignoreSSL'] as bool,
      syncInLowData: json['syncInLowData'] as bool,
    );

Map<String, dynamic> _$AppWebDavSyncServerToJson(
        AppWebDavSyncServer instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'createTime': instance.createTime.toIso8601String(),
      'modifyTime': instance.modifyTime.toIso8601String(),
      'type_': _$AppSyncServerTypeEnumMap[instance.type]!,
      'timeout': instance.timeout?.inMicroseconds,
      'configed': instance.configed,
      'path': instance.path.toString(),
      'username': instance.username,
      'password': instance.password,
      'ignoreSSL': instance.ignoreSSL,
      'syncInLowData': instance.syncInLowData,
      'connectRetryCount': instance.connectRetryCount,
      'connectTimeout': instance.connectTimeout?.inMicroseconds,
      'syncMobileNetworks': instance.syncMobileNetworks
          .map((e) => _$AppSyncServerMobileNetworkEnumMap[e]!)
          .toList(),
    };

const _$AppSyncServerMobileNetworkEnumMap = {
  AppSyncServerMobileNetwork.none: 0,
  AppSyncServerMobileNetwork.wifi: 1,
  AppSyncServerMobileNetwork.mobile: 2,
};

const _$AppSyncServerTypeEnumMap = {
  AppSyncServerType.unknown: 0,
  AppSyncServerType.webdav: 1,
  AppSyncServerType.fake: 99,
};

AppFakeSyncServer _$AppFakeSyncServerFromJson(Map<String, dynamic> json) =>
    AppFakeSyncServer(
      identity: json['identity'] as String,
      name: json['name'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      modifyTime: DateTime.parse(json['modifyTime'] as String),
      timeout: json['timeout'] == null
          ? null
          : Duration(microseconds: (json['timeout'] as num).toInt()),
      configed: json['configed'] as bool,
      data: (json['data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$AppFakeSyncServerToJson(AppFakeSyncServer instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'name': instance.name,
      'createTime': instance.createTime.toIso8601String(),
      'modifyTime': instance.modifyTime.toIso8601String(),
      'type_': _$AppSyncServerTypeEnumMap[instance.type]!,
      'timeout': instance.timeout?.inMicroseconds,
      'configed': instance.configed,
      'data': instance.data,
    };
