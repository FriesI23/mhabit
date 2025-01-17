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
    String? identity,
    DateTime? createTime,
    DateTime? modifyTime,
    Uri? path,
    String? username,
    String? password,
    DateTime? timeout,
    int? maxRetryCount,
    DateTime? connectTimeout,
    bool? verified,
    bool? configed,
    Iterable<AppSyncServerMobileNetwork>? syncMobileNetworks,
    bool? syncInLowData,
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
    Object? maxRetryCount = const $CopyWithPlaceholder(),
    Object? connectTimeout = const $CopyWithPlaceholder(),
    Object? verified = const $CopyWithPlaceholder(),
    Object? configed = const $CopyWithPlaceholder(),
    Object? syncMobileNetworks = const $CopyWithPlaceholder(),
    Object? syncInLowData = const $CopyWithPlaceholder(),
  }) {
    return AppWebDavSyncServer._copyWith(
      identity: identity == const $CopyWithPlaceholder() || identity == null
          ? _value.identity
          // ignore: cast_nullable_to_non_nullable
          : identity as String,
      createTime:
          createTime == const $CopyWithPlaceholder() || createTime == null
              ? _value.createTime
              // ignore: cast_nullable_to_non_nullable
              : createTime as DateTime,
      modifyTime:
          modifyTime == const $CopyWithPlaceholder() || modifyTime == null
              ? _value.modifyTime
              // ignore: cast_nullable_to_non_nullable
              : modifyTime as DateTime,
      path: path == const $CopyWithPlaceholder() || path == null
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as Uri,
      username: username == const $CopyWithPlaceholder() || username == null
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
      password: password == const $CopyWithPlaceholder() || password == null
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      timeout: timeout == const $CopyWithPlaceholder()
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as DateTime?,
      maxRetryCount: maxRetryCount == const $CopyWithPlaceholder()
          ? _value.maxRetryCount
          // ignore: cast_nullable_to_non_nullable
          : maxRetryCount as int?,
      connectTimeout: connectTimeout == const $CopyWithPlaceholder()
          ? _value.connectTimeout
          // ignore: cast_nullable_to_non_nullable
          : connectTimeout as DateTime?,
      verified: verified == const $CopyWithPlaceholder() || verified == null
          ? _value.verified
          // ignore: cast_nullable_to_non_nullable
          : verified as bool,
      configed: configed == const $CopyWithPlaceholder() || configed == null
          ? _value.configed
          // ignore: cast_nullable_to_non_nullable
          : configed as bool,
      syncMobileNetworks: syncMobileNetworks == const $CopyWithPlaceholder() ||
              syncMobileNetworks == null
          ? _value.syncMobileNetworks
          // ignore: cast_nullable_to_non_nullable
          : syncMobileNetworks as Iterable<AppSyncServerMobileNetwork>,
      syncInLowData:
          syncInLowData == const $CopyWithPlaceholder() || syncInLowData == null
              ? _value.syncInLowData
              // ignore: cast_nullable_to_non_nullable
              : syncInLowData as bool,
    );
  }
}

extension $AppWebDavSyncServerCopyWith on AppWebDavSyncServer {
  /// Returns a callable class that can be used as follows: `instanceOfAppWebDavSyncServer.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppWebDavSyncServerCWProxy get copyWith =>
      _$AppWebDavSyncServerCWProxyImpl(this);
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
          : DateTime.parse(json['timeout'] as String),
      maxRetryCount: (json['maxRetryCount'] as num?)?.toInt(),
      connectTimeout: json['connectTimeout'] == null
          ? null
          : DateTime.parse(json['connectTimeout'] as String),
      verified: json['verified'] as bool,
      configed: json['configed'] as bool,
      syncMobileNetworks: (json['syncMobileNetworks'] as List<dynamic>)
          .map((e) => $enumDecode(_$AppSyncServerMobileNetworkEnumMap, e))
          .toList(),
      syncInLowData: json['syncInLowData'] as bool,
    );

Map<String, dynamic> _$AppWebDavSyncServerToJson(
        AppWebDavSyncServer instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'createTime': instance.createTime.toIso8601String(),
      'modifyTime': instance.modifyTime.toIso8601String(),
      'type_': _$AppSyncServerTypeEnumMap[instance.type]!,
      'syncInLowData': instance.syncInLowData,
      'timeout': instance.timeout?.toIso8601String(),
      'verified': instance.verified,
      'configed': instance.configed,
      'path': instance.path.toString(),
      'username': instance.username,
      'password': instance.password,
      'maxRetryCount': instance.maxRetryCount,
      'connectTimeout': instance.connectTimeout?.toIso8601String(),
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
};
