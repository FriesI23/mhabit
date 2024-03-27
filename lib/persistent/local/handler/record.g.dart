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
      id: json['id_'] as int?,
      parentId: json['parent_id'] as int?,
      recordDate: json['record_date'] as int?,
      recordType: json['record_type'] as int?,
      recordValue: json['record_value'] as num?,
      createT: json['create_t'] as int?,
      modifyT: json['modify_t'] as int?,
      uuid: json['uuid'] as String?,
      parentUUID: json['parent_uuid'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$RecordDBCellToJson(RecordDBCell instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id_', instance.id);
  writeNotNull('parent_id', instance.parentId);
  writeNotNull('record_date', instance.recordDate);
  writeNotNull('record_type', instance.recordType);
  writeNotNull('record_value', instance.recordValue);
  writeNotNull('create_t', instance.createT);
  writeNotNull('modify_t', instance.modifyT);
  writeNotNull('uuid', instance.uuid);
  writeNotNull('parent_uuid', instance.parentUUID);
  writeNotNull('reason', instance.reason);
  return val;
}
