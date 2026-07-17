// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'group.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GroupDBCellCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// GroupDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupDBCell call({
    DBID? id,
    int? createT,
    int? modifyT,
    String? uuid,
    String? name,
    String? desc,
    int? icon,
    int? color,
    int? customColor,
    int? customColorTinted,
    int? status,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGroupDBCell.copyWith(...)`.
class _$GroupDBCellCWProxyImpl implements _$GroupDBCellCWProxy {
  const _$GroupDBCellCWProxyImpl(this._value);

  final GroupDBCell _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// GroupDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupDBCell call({
    Object? id = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? customColor = const $CopyWithPlaceholder(),
    Object? customColorTinted = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return GroupDBCell(
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
      uuid: uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      desc: desc == const $CopyWithPlaceholder()
          ? _value.desc
          // ignore: cast_nullable_to_non_nullable
          : desc as String?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as int?,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as int?,
      customColor: customColor == const $CopyWithPlaceholder()
          ? _value.customColor
          // ignore: cast_nullable_to_non_nullable
          : customColor as int?,
      customColorTinted: customColorTinted == const $CopyWithPlaceholder()
          ? _value.customColorTinted
          // ignore: cast_nullable_to_non_nullable
          : customColorTinted as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
    );
  }
}

extension $GroupDBCellCopyWith on GroupDBCell {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGroupDBCell.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$GroupDBCellCWProxy get copyWith => _$GroupDBCellCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupDBCell _$GroupDBCellFromJson(Map<String, dynamic> json) => GroupDBCell(
  id: (json['id_'] as num?)?.toInt(),
  createT: (json['create_t'] as num?)?.toInt(),
  modifyT: (json['modify_t'] as num?)?.toInt(),
  uuid: json['uuid'] as String?,
  name: json['name'] as String?,
  desc: json['desc'] as String?,
  icon: (json['icon'] as num?)?.toInt(),
  color: (json['color'] as num?)?.toInt(),
  customColor: (json['custom_color'] as num?)?.toInt(),
  customColorTinted: (json['custom_color_tinted'] as num?)?.toInt(),
  status: (json['status'] as num?)?.toInt(),
);

Map<String, dynamic> _$GroupDBCellToJson(GroupDBCell instance) =>
    <String, dynamic>{
      'id_': ?instance.id,
      'create_t': ?instance.createT,
      'modify_t': ?instance.modifyT,
      'uuid': ?instance.uuid,
      'name': ?instance.name,
      'desc': ?instance.desc,
      'icon': instance.icon,
      'color': instance.color,
      'custom_color': instance.customColor,
      'custom_color_tinted': instance.customColorTinted,
      'status': ?instance.status,
    };
