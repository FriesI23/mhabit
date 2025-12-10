// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrimaryAppThemeColor _$PrimaryAppThemeColorFromJson(
        Map<String, dynamic> json) =>
    PrimaryAppThemeColor();

Map<String, dynamic> _$PrimaryAppThemeColorToJson(
        PrimaryAppThemeColor instance) =>
    <String, dynamic>{
      'type': _$AppThemeColorTypeEnumMap[instance.type]!,
    };

const _$AppThemeColorTypeEnumMap = {
  AppThemeColorType.primary: 0,
  AppThemeColorType.dynamic: 1,
  AppThemeColorType.internal: 2,
};

DynamicAppThemeColor _$DynamicAppThemeColorFromJson(
        Map<String, dynamic> json) =>
    DynamicAppThemeColor();

Map<String, dynamic> _$DynamicAppThemeColorToJson(
        DynamicAppThemeColor instance) =>
    <String, dynamic>{
      'type': _$AppThemeColorTypeEnumMap[instance.type]!,
    };

InternalAppThemeColor _$InternalAppThemeColorFromJson(
        Map<String, dynamic> json) =>
    InternalAppThemeColor(
      colorType: $enumDecode(_$HabitColorTypeEnumMap, json['color_type']),
    );

Map<String, dynamic> _$InternalAppThemeColorToJson(
        InternalAppThemeColor instance) =>
    <String, dynamic>{
      'type': _$AppThemeColorTypeEnumMap[instance.type]!,
      'color_type': _$HabitColorTypeEnumMap[instance.colorType]!,
    };

const _$HabitColorTypeEnumMap = {
  HabitColorType.cc1: 1,
  HabitColorType.cc2: 2,
  HabitColorType.cc3: 3,
  HabitColorType.cc4: 4,
  HabitColorType.cc5: 5,
  HabitColorType.cc6: 6,
  HabitColorType.cc7: 7,
  HabitColorType.cc8: 8,
  HabitColorType.cc9: 9,
  HabitColorType.cc10: 10,
};
