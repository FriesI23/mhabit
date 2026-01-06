// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'sync.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncDBCellCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// SyncDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncDBCell call({
    DBID? id,
    int? createT,
    int? modifyT,
    HabitUUID? habitUUID,
    HabitUUID? recordUUID,
    int? dirty,
    int? dirtyTotal,
    String? lastConfigUUID,
    String? lastSesionUUID,
    String? lastMark,
    String? lastMark2,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSyncDBCell.copyWith(...)`.
class _$SyncDBCellCWProxyImpl implements _$SyncDBCellCWProxy {
  const _$SyncDBCellCWProxyImpl(this._value);

  final SyncDBCell _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// SyncDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncDBCell call({
    Object? id = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? habitUUID = const $CopyWithPlaceholder(),
    Object? recordUUID = const $CopyWithPlaceholder(),
    Object? dirty = const $CopyWithPlaceholder(),
    Object? dirtyTotal = const $CopyWithPlaceholder(),
    Object? lastConfigUUID = const $CopyWithPlaceholder(),
    Object? lastSesionUUID = const $CopyWithPlaceholder(),
    Object? lastMark = const $CopyWithPlaceholder(),
    Object? lastMark2 = const $CopyWithPlaceholder(),
  }) {
    return SyncDBCell(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as DBID?,
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
          : habitUUID as HabitUUID?,
      recordUUID: recordUUID == const $CopyWithPlaceholder()
          ? _value.recordUUID
          // ignore: cast_nullable_to_non_nullable
          : recordUUID as HabitUUID?,
      dirty: dirty == const $CopyWithPlaceholder()
          ? _value.dirty
          // ignore: cast_nullable_to_non_nullable
          : dirty as int?,
      dirtyTotal: dirtyTotal == const $CopyWithPlaceholder()
          ? _value.dirtyTotal
          // ignore: cast_nullable_to_non_nullable
          : dirtyTotal as int?,
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
      lastMark2: lastMark2 == const $CopyWithPlaceholder()
          ? _value.lastMark2
          // ignore: cast_nullable_to_non_nullable
          : lastMark2 as String?,
    );
  }
}

extension $SyncDBCellCopyWith on SyncDBCell {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSyncDBCell.copyWith(...)`.
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
  dirtyTotal: (json['dirty_total'] as num?)?.toInt(),
  lastConfigUUID: json['last_config_uuid'] as String?,
  lastSesionUUID: json['last_session_uuid'] as String?,
  lastMark: json['last_mark'] as String?,
  lastMark2: json['last_mark_2'] as String?,
);

Map<String, dynamic> _$SyncDBCellToJson(SyncDBCell instance) =>
    <String, dynamic>{
      'id_': ?instance.id,
      'create_t': ?instance.createT,
      'modify_t': ?instance.modifyT,
      'habit_uuid': ?instance.habitUUID,
      'record_uuid': ?instance.recordUUID,
      'dirty': ?instance.dirty,
      'dirty_total': ?instance.dirtyTotal,
      'last_config_uuid': ?instance.lastConfigUUID,
      'last_session_uuid': ?instance.lastSesionUUID,
      'last_mark': ?instance.lastMark,
      'last_mark_2': ?instance.lastMark2,
    };
