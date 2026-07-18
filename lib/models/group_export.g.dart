// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'group_export.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GroupExportDataCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// GroupExportData(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupExportData call({
    String? uuid,
    String? name,
    String? desc,
    int? icon,
    int? color,
    int? customColor,
    int? customColorTinted,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGroupExportData.copyWith(...)`.
class _$GroupExportDataCWProxyImpl implements _$GroupExportDataCWProxy {
  const _$GroupExportDataCWProxyImpl(this._value);

  final GroupExportData _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// GroupExportData(...).copyWith(id: 12, name: "My name")
  /// ```
  GroupExportData call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? customColor = const $CopyWithPlaceholder(),
    Object? customColorTinted = const $CopyWithPlaceholder(),
  }) {
    return GroupExportData(
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
    );
  }
}

extension $GroupExportDataCopyWith on GroupExportData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGroupExportData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$GroupExportDataCWProxy get copyWith => _$GroupExportDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupExportData _$GroupExportDataFromJson(Map<String, dynamic> json) =>
    GroupExportData(
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      desc: json['desc'] as String?,
      icon: (json['icon'] as num?)?.toInt(),
      color: (json['color'] as num?)?.toInt(),
      customColor: (json['custom_color'] as num?)?.toInt(),
      customColorTinted: (json['custom_color_tinted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GroupExportDataToJson(GroupExportData instance) =>
    <String, dynamic>{
      'uuid': ?instance.uuid,
      'name': ?instance.name,
      'desc': ?instance.desc,
      'icon': ?instance.icon,
      'color': ?instance.color,
      'custom_color': ?instance.customColor,
      'custom_color_tinted': ?instance.customColorTinted,
    };
