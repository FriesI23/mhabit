// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_reminder_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppReminderConfigCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppReminderConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  AppReminderConfig call({
    bool? enabled,
    AppReminderConfigType? type,
    TimeOfDay? timeOfDay,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppReminderConfig.copyWith(...)`.
class _$AppReminderConfigCWProxyImpl implements _$AppReminderConfigCWProxy {
  const _$AppReminderConfigCWProxyImpl(this._value);

  final AppReminderConfig _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AppReminderConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  AppReminderConfig call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? timeOfDay = const $CopyWithPlaceholder(),
  }) {
    return AppReminderConfig(
      enabled: enabled == const $CopyWithPlaceholder() || enabled == null
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as AppReminderConfigType,
      timeOfDay: timeOfDay == const $CopyWithPlaceholder()
          ? _value.timeOfDay
          // ignore: cast_nullable_to_non_nullable
          : timeOfDay as TimeOfDay?,
    );
  }
}

extension $AppReminderConfigCopyWith on AppReminderConfig {
  /// Returns a callable class that can be used as follows: `instanceOfAppReminderConfig.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppReminderConfigCWProxy get copyWith =>
      _$AppReminderConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppReminderConfig _$AppReminderConfigFromJson(Map<String, dynamic> json) =>
    AppReminderConfig(
      enabled: json['enabled'] as bool,
      type: $enumDecode(_$AppReminderConfigTypeEnumMap, json['type']),
      timeOfDay: _$JsonConverterFromJson<Map<String, dynamic>, TimeOfDay>(
          json['timeOfDay'], const TimeOfDayConverter().fromJson),
    );

Map<String, dynamic> _$AppReminderConfigToJson(AppReminderConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'type': _$AppReminderConfigTypeEnumMap[instance.type]!,
      'timeOfDay': _$JsonConverterToJson<Map<String, dynamic>, TimeOfDay>(
          instance.timeOfDay, const TimeOfDayConverter().toJson),
    };

const _$AppReminderConfigTypeEnumMap = {
  AppReminderConfigType.daily: 1,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
