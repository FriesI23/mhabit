// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'habit_display.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitsDisplayFilterCWProxy {
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits);

  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits);

  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HabitsDisplayFilter(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitsDisplayFilter call({
    bool allowInProgressHabits,
    bool allowArchivedHabits,
    bool allowCompleteHabits,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitsDisplayFilter.copyWith(...)` or call `instanceOfHabitsDisplayFilter.copyWith.fieldName(value)` for a single field.
class _$HabitsDisplayFilterCWProxyImpl implements _$HabitsDisplayFilterCWProxy {
  const _$HabitsDisplayFilterCWProxyImpl(this._value);

  final HabitsDisplayFilter _value;

  @override
  HabitsDisplayFilter allowInProgressHabits(bool allowInProgressHabits) =>
      call(allowInProgressHabits: allowInProgressHabits);

  @override
  HabitsDisplayFilter allowArchivedHabits(bool allowArchivedHabits) =>
      call(allowArchivedHabits: allowArchivedHabits);

  @override
  HabitsDisplayFilter allowCompleteHabits(bool allowCompleteHabits) =>
      call(allowCompleteHabits: allowCompleteHabits);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HabitsDisplayFilter(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HabitsDisplayFilter(...).copyWith(id: 12, name: "My name")
  /// ```
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitsDisplayFilter.copyWith(...)` or `instanceOfHabitsDisplayFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitsDisplayFilterCWProxy get copyWith =>
      _$HabitsDisplayFilterCWProxyImpl(this);
}

abstract class _$HabitDisplayOpConfigCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDisplayOpConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDisplayOpConfig call({
    UserAction changeRecordStatus,
    UserAction openRecordStatusDialog,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitDisplayOpConfig.copyWith(...)`.
class _$HabitDisplayOpConfigCWProxyImpl
    implements _$HabitDisplayOpConfigCWProxy {
  const _$HabitDisplayOpConfigCWProxyImpl(this._value);

  final HabitDisplayOpConfig _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDisplayOpConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDisplayOpConfig call({
    Object? changeRecordStatus = const $CopyWithPlaceholder(),
    Object? openRecordStatusDialog = const $CopyWithPlaceholder(),
  }) {
    return HabitDisplayOpConfig(
      changeRecordStatus:
          changeRecordStatus == const $CopyWithPlaceholder() ||
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitDisplayOpConfig.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitDisplayOpConfigCWProxy get copyWith =>
      _$HabitDisplayOpConfigCWProxyImpl(this);
}

abstract class _$HabitDisplaySearchOptionsCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDisplaySearchOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDisplaySearchOptions call({
    String keyword,
    bool activated,
    bool completed,
    Set<HabitType> types,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitDisplaySearchOptions.copyWith(...)`.
class _$HabitDisplaySearchOptionsCWProxyImpl
    implements _$HabitDisplaySearchOptionsCWProxy {
  const _$HabitDisplaySearchOptionsCWProxyImpl(this._value);

  final HabitDisplaySearchOptions _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDisplaySearchOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDisplaySearchOptions call({
    Object? keyword = const $CopyWithPlaceholder(),
    Object? activated = const $CopyWithPlaceholder(),
    Object? completed = const $CopyWithPlaceholder(),
    Object? types = const $CopyWithPlaceholder(),
  }) {
    return HabitDisplaySearchOptions(
      keyword: keyword == const $CopyWithPlaceholder() || keyword == null
          ? _value.keyword
          // ignore: cast_nullable_to_non_nullable
          : keyword as String,
      activated: activated == const $CopyWithPlaceholder() || activated == null
          ? _value.activated
          // ignore: cast_nullable_to_non_nullable
          : activated as bool,
      completed: completed == const $CopyWithPlaceholder() || completed == null
          ? _value.completed
          // ignore: cast_nullable_to_non_nullable
          : completed as bool,
      types: types == const $CopyWithPlaceholder() || types == null
          ? _value.types
          // ignore: cast_nullable_to_non_nullable
          : types as Set<HabitType>,
    );
  }
}

extension $HabitDisplaySearchOptionsCopyWith on HabitDisplaySearchOptions {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitDisplaySearchOptions.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitDisplaySearchOptionsCWProxy get copyWith =>
      _$HabitDisplaySearchOptionsCWProxyImpl(this);
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
  HabitsDisplayFilter instance,
) => <String, dynamic>{
  'allowActivedHabits': instance.allowInProgressHabits,
  'allowArchivedHabits': instance.allowArchivedHabits,
  'allowCompleteHabits': instance.allowCompleteHabits,
};

HabitDisplayOpConfig _$HabitDisplayOpConfigFromJson(
  Map<String, dynamic> json,
) => HabitDisplayOpConfig(
  changeRecordStatus: $enumDecode(
    _$UserActionEnumMap,
    json['change_record_status'],
  ),
  openRecordStatusDialog: $enumDecode(
    _$UserActionEnumMap,
    json['open_record_status_dialog'],
  ),
);

Map<String, dynamic> _$HabitDisplayOpConfigToJson(
  HabitDisplayOpConfig instance,
) => <String, dynamic>{
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
