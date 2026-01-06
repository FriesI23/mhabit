// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'app_notify_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotifyConfig _$AppNotifyConfigFromJson(Map<String, dynamic> json) =>
    AppNotifyConfig._(
      channels: channelsFromJson(json['channels'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppNotifyConfigToJson(AppNotifyConfig instance) =>
    <String, dynamic>{'channels': channelsToJson(instance.channels)};
