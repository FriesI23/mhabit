// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_reminder.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitReminderCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitReminder(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitReminder call({
    HabitReminderType type,
    List<int> extra,
    TimeOfDay time,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitReminder.copyWith(...)`.
class _$HabitReminderCWProxyImpl implements _$HabitReminderCWProxy {
  const _$HabitReminderCWProxyImpl(this._value);

  final HabitReminder _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitReminder(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitReminder call({
    Object? type = const $CopyWithPlaceholder(),
    Object? extra = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
  }) {
    return HabitReminder(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as HabitReminderType,
      extra: extra == const $CopyWithPlaceholder()
          ? _value.extra
          // ignore: cast_nullable_to_non_nullable
          : extra as List<int>,
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as TimeOfDay,
    );
  }
}

extension $HabitReminderCopyWith on HabitReminder {
  /// Returns a callable class that can be used as follows: `instanceOfHabitReminder.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitReminderCWProxy get copyWith => _$HabitReminderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitReminder _$HabitReminderFromJson(Map<String, dynamic> json) =>
    HabitReminder(
      type: $enumDecode(_$HabitReminderTypeEnumMap, json['type']),
      extra: (json['extra'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      time: const TimeOfDayConverter()
          .fromJson(json['time'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HabitReminderToJson(HabitReminder instance) =>
    <String, dynamic>{
      'type': _$HabitReminderTypeEnumMap[instance.type]!,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'extra': instance.extra,
    };

const _$HabitReminderTypeEnumMap = {
  HabitReminderType.unknown: 0,
  HabitReminderType.whenNeeded: 1,
  HabitReminderType.day: 2,
  HabitReminderType.week: 3,
  HabitReminderType.month: 4,
};
