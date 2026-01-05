// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'record.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordDBCellCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// RecordDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  RecordDBCell call({
    DBID? id,
    DBID? parentId,
    int? recordDate,
    int? recordType,
    num? recordValue,
    int? createT,
    int? modifyT,
    HabitRecordUUID? uuid,
    HabitUUID? parentUUID,
    String? reason,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRecordDBCell.copyWith(...)`.
class _$RecordDBCellCWProxyImpl implements _$RecordDBCellCWProxy {
  const _$RecordDBCellCWProxyImpl(this._value);

  final RecordDBCell _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// RecordDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  RecordDBCell call({
    Object? id = const $CopyWithPlaceholder(),
    Object? parentId = const $CopyWithPlaceholder(),
    Object? recordDate = const $CopyWithPlaceholder(),
    Object? recordType = const $CopyWithPlaceholder(),
    Object? recordValue = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? uuid = const $CopyWithPlaceholder(),
    Object? parentUUID = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return RecordDBCell(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as DBID?,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as DBID?,
      recordDate: recordDate == const $CopyWithPlaceholder()
          ? _value.recordDate
          // ignore: cast_nullable_to_non_nullable
          : recordDate as int?,
      recordType: recordType == const $CopyWithPlaceholder()
          ? _value.recordType
          // ignore: cast_nullable_to_non_nullable
          : recordType as int?,
      recordValue: recordValue == const $CopyWithPlaceholder()
          ? _value.recordValue
          // ignore: cast_nullable_to_non_nullable
          : recordValue as num?,
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
      uuid: uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as HabitRecordUUID?,
      parentUUID: parentUUID == const $CopyWithPlaceholder()
          ? _value.parentUUID
          // ignore: cast_nullable_to_non_nullable
          : parentUUID as HabitUUID?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $RecordDBCellCopyWith on RecordDBCell {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRecordDBCell.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RecordDBCellCWProxy get copyWith => _$RecordDBCellCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordDBCell _$RecordDBCellFromJson(Map<String, dynamic> json) => RecordDBCell(
  id: (json['id_'] as num?)?.toInt(),
  parentId: (json['parent_id'] as num?)?.toInt(),
  recordDate: (json['record_date'] as num?)?.toInt(),
  recordType: (json['record_type'] as num?)?.toInt(),
  recordValue: json['record_value'] as num?,
  createT: (json['create_t'] as num?)?.toInt(),
  modifyT: (json['modify_t'] as num?)?.toInt(),
  uuid: json['uuid'] as String?,
  parentUUID: json['parent_uuid'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$RecordDBCellToJson(RecordDBCell instance) =>
    <String, dynamic>{
      'id_': ?instance.id,
      'parent_id': ?instance.parentId,
      'record_date': ?instance.recordDate,
      'record_type': ?instance.recordType,
      'record_value': ?instance.recordValue,
      'create_t': ?instance.createT,
      'modify_t': ?instance.modifyT,
      'uuid': ?instance.uuid,
      'parent_uuid': ?instance.parentUUID,
      'reason': ?instance.reason,
    };
