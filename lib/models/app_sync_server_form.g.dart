// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'app_sync_server_form.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FakeSyncServerFormCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// FakeSyncServerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  FakeSyncServerForm call({String uuid});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFakeSyncServerForm.copyWith(...)`.
class _$FakeSyncServerFormCWProxyImpl implements _$FakeSyncServerFormCWProxy {
  const _$FakeSyncServerFormCWProxyImpl(this._value);

  final FakeSyncServerForm _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// FakeSyncServerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  FakeSyncServerForm call({Object? uuid = const $CopyWithPlaceholder()}) {
    return FakeSyncServerForm(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
    );
  }
}

extension $FakeSyncServerFormCopyWith on FakeSyncServerForm {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFakeSyncServerForm.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$FakeSyncServerFormCWProxy get copyWith =>
      _$FakeSyncServerFormCWProxyImpl(this);
}

abstract class _$WebDavSyncServerFormCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// WebDavSyncServerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  WebDavSyncServerForm call({
    String uuid,
    String? path,
    String? username,
    String? password,
    bool? ignoreSSL,
    Duration? timeout,
    Duration? connectTimeout,
    int? connectRetryCount,
    Set<AppSyncServerMobileNetwork>? syncMobileNetworks,
    bool? syncInLowData,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWebDavSyncServerForm.copyWith(...)`.
class _$WebDavSyncServerFormCWProxyImpl
    implements _$WebDavSyncServerFormCWProxy {
  const _$WebDavSyncServerFormCWProxyImpl(this._value);

  final WebDavSyncServerForm _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// WebDavSyncServerForm(...).copyWith(id: 12, name: "My name")
  /// ```
  WebDavSyncServerForm call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? ignoreSSL = const $CopyWithPlaceholder(),
    Object? timeout = const $CopyWithPlaceholder(),
    Object? connectTimeout = const $CopyWithPlaceholder(),
    Object? connectRetryCount = const $CopyWithPlaceholder(),
    Object? syncMobileNetworks = const $CopyWithPlaceholder(),
    Object? syncInLowData = const $CopyWithPlaceholder(),
  }) {
    return WebDavSyncServerForm(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      username: username == const $CopyWithPlaceholder()
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String?,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
      ignoreSSL: ignoreSSL == const $CopyWithPlaceholder()
          ? _value.ignoreSSL
          // ignore: cast_nullable_to_non_nullable
          : ignoreSSL as bool?,
      timeout: timeout == const $CopyWithPlaceholder()
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as Duration?,
      connectTimeout: connectTimeout == const $CopyWithPlaceholder()
          ? _value.connectTimeout
          // ignore: cast_nullable_to_non_nullable
          : connectTimeout as Duration?,
      connectRetryCount: connectRetryCount == const $CopyWithPlaceholder()
          ? _value.connectRetryCount
          // ignore: cast_nullable_to_non_nullable
          : connectRetryCount as int?,
      syncMobileNetworks: syncMobileNetworks == const $CopyWithPlaceholder()
          ? _value.syncMobileNetworks
          // ignore: cast_nullable_to_non_nullable
          : syncMobileNetworks as Set<AppSyncServerMobileNetwork>?,
      syncInLowData: syncInLowData == const $CopyWithPlaceholder()
          ? _value.syncInLowData
          // ignore: cast_nullable_to_non_nullable
          : syncInLowData as bool?,
    );
  }
}

extension $WebDavSyncServerFormCopyWith on WebDavSyncServerForm {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWebDavSyncServerForm.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WebDavSyncServerFormCWProxy get copyWith =>
      _$WebDavSyncServerFormCWProxyImpl(this);
}
