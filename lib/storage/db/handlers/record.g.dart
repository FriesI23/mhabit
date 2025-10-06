// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordDBCellCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RecordDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordDBCell call({
    int? id,
    int? parentId,
    int? recordDate,
    int? recordType,
    num? recordValue,
    int? createT,
    int? modifyT,
    String? uuid,
    String? parentUUID,
    String? reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecordDBCell.copyWith(...)`.
class _$RecordDBCellCWProxyImpl implements _$RecordDBCellCWProxy {
  const _$RecordDBCellCWProxyImpl(this._value);

  final RecordDBCell _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RecordDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
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
          : id as int?,
      parentId: parentId == const $CopyWithPlaceholder()
          ? _value.parentId
          // ignore: cast_nullable_to_non_nullable
          : parentId as int?,
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
          : uuid as String?,
      parentUUID: parentUUID == const $CopyWithPlaceholder()
          ? _value.parentUUID
          // ignore: cast_nullable_to_non_nullable
          : parentUUID as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $RecordDBCellCopyWith on RecordDBCell {
  /// Returns a callable class that can be used as follows: `instanceOfRecordDBCell.copyWith(...)`.
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
      if (instance.id case final value?) 'id_': value,
      if (instance.parentId case final value?) 'parent_id': value,
      if (instance.recordDate case final value?) 'record_date': value,
      if (instance.recordType case final value?) 'record_type': value,
      if (instance.recordValue case final value?) 'record_value': value,
      if (instance.createT case final value?) 'create_t': value,
      if (instance.modifyT case final value?) 'modify_t': value,
      if (instance.uuid case final value?) 'uuid': value,
      if (instance.parentUUID case final value?) 'parent_uuid': value,
      if (instance.reason case final value?) 'reason': value,
    };
