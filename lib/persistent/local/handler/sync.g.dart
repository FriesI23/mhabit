// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncDBCellCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SyncDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncDBCell call({
    int? id,
    int? createT,
    int? modifyT,
    String? habitUUID,
    String? recordUUID,
    int? dirty,
    String? lastConfigUUID,
    String? lastSesionUUID,
    String? lastMark,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSyncDBCell.copyWith(...)`.
class _$SyncDBCellCWProxyImpl implements _$SyncDBCellCWProxy {
  const _$SyncDBCellCWProxyImpl(this._value);

  final SyncDBCell _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SyncDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncDBCell call({
    Object? id = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? habitUUID = const $CopyWithPlaceholder(),
    Object? recordUUID = const $CopyWithPlaceholder(),
    Object? dirty = const $CopyWithPlaceholder(),
    Object? lastConfigUUID = const $CopyWithPlaceholder(),
    Object? lastSesionUUID = const $CopyWithPlaceholder(),
    Object? lastMark = const $CopyWithPlaceholder(),
  }) {
    return SyncDBCell(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
      habitUUID: habitUUID == const $CopyWithPlaceholder()
          ? _value.habitUUID
          // ignore: cast_nullable_to_non_nullable
          : habitUUID as String?,
      recordUUID: recordUUID == const $CopyWithPlaceholder()
          ? _value.recordUUID
          // ignore: cast_nullable_to_non_nullable
          : recordUUID as String?,
      dirty: dirty == const $CopyWithPlaceholder()
          ? _value.dirty
          // ignore: cast_nullable_to_non_nullable
          : dirty as int?,
      lastConfigUUID: lastConfigUUID == const $CopyWithPlaceholder()
          ? _value.lastConfigUUID
          // ignore: cast_nullable_to_non_nullable
          : lastConfigUUID as String?,
      lastSesionUUID: lastSesionUUID == const $CopyWithPlaceholder()
          ? _value.lastSesionUUID
          // ignore: cast_nullable_to_non_nullable
          : lastSesionUUID as String?,
      lastMark: lastMark == const $CopyWithPlaceholder()
          ? _value.lastMark
          // ignore: cast_nullable_to_non_nullable
          : lastMark as String?,
    );
  }
}

extension $SyncDBCellCopyWith on SyncDBCell {
  /// Returns a callable class that can be used as follows: `instanceOfSyncDBCell.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncDBCellCWProxy get copyWith => _$SyncDBCellCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncDBCell _$SyncDBCellFromJson(Map<String, dynamic> json) => SyncDBCell(
      id: (json['id_'] as num?)?.toInt(),
      createT: (json['create_t'] as num?)?.toInt(),
      modifyT: (json['modify_t'] as num?)?.toInt(),
      habitUUID: json['habit_uuid'] as String?,
      recordUUID: json['record_uuid'] as String?,
      dirty: (json['dirty'] as num?)?.toInt(),
      lastConfigUUID: json['last_config_uuid'] as String?,
      lastSesionUUID: json['last_session_uuid'] as String?,
      lastMark: json['last_mark'] as String?,
    );

Map<String, dynamic> _$SyncDBCellToJson(SyncDBCell instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id_': value,
      if (instance.createT case final value?) 'create_t': value,
      if (instance.modifyT case final value?) 'modify_t': value,
      if (instance.habitUUID case final value?) 'habit_uuid': value,
      if (instance.recordUUID case final value?) 'record_uuid': value,
      if (instance.dirty case final value?) 'dirty': value,
      if (instance.lastConfigUUID case final value?) 'last_config_uuid': value,
      if (instance.lastSesionUUID case final value?) 'last_session_uuid': value,
      if (instance.lastMark case final value?) 'last_mark': value,
    };
