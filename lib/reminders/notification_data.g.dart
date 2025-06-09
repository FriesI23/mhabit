// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationData<T> _$NotificationDataFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    NotificationData<T>(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$NotificationDataTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String?,
      channelId: $enumDecode(_$NotificationChannelIdEnumMap, json['channelId']),
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
      child: _$nullableGenericFromJson(json['child'], fromJsonT),
    );

Map<String, dynamic> _$NotificationDataToJson<T>(
  NotificationData<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationDataTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'channelId': _$NotificationChannelIdEnumMap[instance.channelId]!,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'child': _$nullableGenericToJson(instance.child, toJsonT),
    };

const _$NotificationDataTypeEnumMap = {
  NotificationDataType.debug: 1,
  NotificationDataType.habitReminder: 2,
  NotificationDataType.appReminder: 3,
  NotificationDataType.appDebugger: 4,
  NotificationDataType.appSync: 5,
};

const _$NotificationChannelIdEnumMap = {
  NotificationChannelId.debug: 1,
  NotificationChannelId.habitReminder: 2,
  NotificationChannelId.appReminder: 3,
  NotificationChannelId.appDebugger: 4,
  NotificationChannelId.appSyncing: 5,
  NotificationChannelId.appSyncFailed: 6,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
