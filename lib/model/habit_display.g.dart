// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_display.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitsDisplayFilterCWProxy {
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits);

  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits);

  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HabitsDisplayFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitsDisplayFilter call({
    bool? allowInProgressHabits,
    bool? allowArchivedHabits,
    bool? allowCompleteHabits,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitsDisplayFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHabitsDisplayFilter.copyWith.fieldName(...)`
class _$HabitsDisplayFilterCWProxyImpl implements _$HabitsDisplayFilterCWProxy {
  const _$HabitsDisplayFilterCWProxyImpl(this._value);

  final HabitsDisplayFilter _value;

  @override
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits) =>
      this(allowInProgressHabits: allowInProgressHabits);

  @override
  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits) =>
      this(allowArchivedHabits: allowArchivedHabits);

  @override
  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits) =>
      this(allowCompleteHabits: allowCompleteHabits);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HabitsDisplayFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitsDisplayFilter call({
    Object? allowInProgressHabits = const $CopyWithPlaceholder(),
    Object? allowArchivedHabits = const $CopyWithPlaceholder(),
    Object? allowCompleteHabits = const $CopyWithPlaceholder(),
  }) {
    return HabitsDisplayFilter(
      allowInProgressHabits:
          allowInProgressHabits == const $CopyWithPlaceholder() ||
                  allowInProgressHabits == null
              ? _value.allowInProgressHabits
              // ignore: cast_nullable_to_non_nullable
              : allowInProgressHabits as bool,
      allowArchivedHabits:
          allowArchivedHabits == const $CopyWithPlaceholder() ||
                  allowArchivedHabits == null
              ? _value.allowArchivedHabits
              // ignore: cast_nullable_to_non_nullable
              : allowArchivedHabits as bool,
      allowCompleteHabits:
          allowCompleteHabits == const $CopyWithPlaceholder() ||
                  allowCompleteHabits == null
              ? _value.allowCompleteHabits
              // ignore: cast_nullable_to_non_nullable
              : allowCompleteHabits as bool,
    );
  }
}

extension $HabitsDisplayFilterCopyWith on HabitsDisplayFilter {
  /// Returns a callable class that can be used as follows: `instanceOfHabitsDisplayFilter.copyWith(...)` or like so:`instanceOfHabitsDisplayFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitsDisplayFilterCWProxy get copyWith =>
      _$HabitsDisplayFilterCWProxyImpl(this);
}

abstract class _$HabitDisplayOpConfigCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitDisplayOpConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitDisplayOpConfig call({
    UserAction? changeRecordStatus,
    UserAction? openRecordStatusDialog,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitDisplayOpConfig.copyWith(...)`.
class _$HabitDisplayOpConfigCWProxyImpl
    implements _$HabitDisplayOpConfigCWProxy {
  const _$HabitDisplayOpConfigCWProxyImpl(this._value);

  final HabitDisplayOpConfig _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitDisplayOpConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitDisplayOpConfig call({
    Object? changeRecordStatus = const $CopyWithPlaceholder(),
    Object? openRecordStatusDialog = const $CopyWithPlaceholder(),
  }) {
    return HabitDisplayOpConfig(
      changeRecordStatus: changeRecordStatus == const $CopyWithPlaceholder() ||
              changeRecordStatus == null
          ? _value.changeRecordStatus
          // ignore: cast_nullable_to_non_nullable
          : changeRecordStatus as UserAction,
      openRecordStatusDialog:
          openRecordStatusDialog == const $CopyWithPlaceholder() ||
                  openRecordStatusDialog == null
              ? _value.openRecordStatusDialog
              // ignore: cast_nullable_to_non_nullable
              : openRecordStatusDialog as UserAction,
    );
  }
}

extension $HabitDisplayOpConfigCopyWith on HabitDisplayOpConfig {
  /// Returns a callable class that can be used as follows: `instanceOfHabitDisplayOpConfig.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitDisplayOpConfigCWProxy get copyWith =>
      _$HabitDisplayOpConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitsDisplayFilter _$HabitsDisplayFilterFromJson(Map<String, dynamic> json) =>
    HabitsDisplayFilter(
      allowInProgressHabits: json['allowActivedHabits'] as bool,
      allowArchivedHabits: json['allowArchivedHabits'] as bool,
      allowCompleteHabits: json['allowCompleteHabits'] as bool,
    );

Map<String, dynamic> _$HabitsDisplayFilterToJson(
        HabitsDisplayFilter instance) =>
    <String, dynamic>{
      'allowActivedHabits': instance.allowInProgressHabits,
      'allowArchivedHabits': instance.allowArchivedHabits,
      'allowCompleteHabits': instance.allowCompleteHabits,
    };

HabitDisplayOpConfig _$HabitDisplayOpConfigFromJson(
        Map<String, dynamic> json) =>
    HabitDisplayOpConfig(
      changeRecordStatus:
          $enumDecode(_$UserActionEnumMap, json['change_record_status']),
      openRecordStatusDialog:
          $enumDecode(_$UserActionEnumMap, json['open_record_status_dialog']),
    );

Map<String, dynamic> _$HabitDisplayOpConfigToJson(
        HabitDisplayOpConfig instance) =>
    <String, dynamic>{
      'change_record_status': _$UserActionEnumMap[instance.changeRecordStatus]!,
      'open_record_status_dialog':
          _$UserActionEnumMap[instance.openRecordStatusDialog]!,
    };

const _$UserActionEnumMap = {
  UserAction.nothing: 'nothing',
  UserAction.tap: 'tap',
  UserAction.doubleTap: 'doubleTap',
  UserAction.longTap: 'longTap',
};
