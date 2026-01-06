// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'habit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitDBCellCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDBCell call({
    DBID? id,
    int? type,
    int? createT,
    int? modifyT,
    HabitUUID? uuid,
    int? status,
    String? name,
    String? desc,
    int? color,
    num? dailyGoal,
    String? dailyGoalUnit,
    num? dailyGoalExtra,
    int? freqType,
    String? freqCustom,
    int? startDate,
    int? targetDays,
    String? remindCustom,
    String? remindQuestion,
    HabitSortPostion? sortPosition,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHabitDBCell.copyWith(...)`.
class _$HabitDBCellCWProxyImpl implements _$HabitDBCellCWProxy {
  const _$HabitDBCellCWProxyImpl(this._value);

  final HabitDBCell _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// HabitDBCell(...).copyWith(id: 12, name: "My name")
  /// ```
  HabitDBCell call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? uuid = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? dailyGoal = const $CopyWithPlaceholder(),
    Object? dailyGoalUnit = const $CopyWithPlaceholder(),
    Object? dailyGoalExtra = const $CopyWithPlaceholder(),
    Object? freqType = const $CopyWithPlaceholder(),
    Object? freqCustom = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? targetDays = const $CopyWithPlaceholder(),
    Object? remindCustom = const $CopyWithPlaceholder(),
    Object? remindQuestion = const $CopyWithPlaceholder(),
    Object? sortPosition = const $CopyWithPlaceholder(),
  }) {
    return HabitDBCell(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as DBID?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as int?,
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
          : uuid as HabitUUID?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      desc: desc == const $CopyWithPlaceholder()
          ? _value.desc
          // ignore: cast_nullable_to_non_nullable
          : desc as String?,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as int?,
      dailyGoal: dailyGoal == const $CopyWithPlaceholder()
          ? _value.dailyGoal
          // ignore: cast_nullable_to_non_nullable
          : dailyGoal as num?,
      dailyGoalUnit: dailyGoalUnit == const $CopyWithPlaceholder()
          ? _value.dailyGoalUnit
          // ignore: cast_nullable_to_non_nullable
          : dailyGoalUnit as String?,
      dailyGoalExtra: dailyGoalExtra == const $CopyWithPlaceholder()
          ? _value.dailyGoalExtra
          // ignore: cast_nullable_to_non_nullable
          : dailyGoalExtra as num?,
      freqType: freqType == const $CopyWithPlaceholder()
          ? _value.freqType
          // ignore: cast_nullable_to_non_nullable
          : freqType as int?,
      freqCustom: freqCustom == const $CopyWithPlaceholder()
          ? _value.freqCustom
          // ignore: cast_nullable_to_non_nullable
          : freqCustom as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as int?,
      targetDays: targetDays == const $CopyWithPlaceholder()
          ? _value.targetDays
          // ignore: cast_nullable_to_non_nullable
          : targetDays as int?,
      remindCustom: remindCustom == const $CopyWithPlaceholder()
          ? _value.remindCustom
          // ignore: cast_nullable_to_non_nullable
          : remindCustom as String?,
      remindQuestion: remindQuestion == const $CopyWithPlaceholder()
          ? _value.remindQuestion
          // ignore: cast_nullable_to_non_nullable
          : remindQuestion as String?,
      sortPosition: sortPosition == const $CopyWithPlaceholder()
          ? _value.sortPosition
          // ignore: cast_nullable_to_non_nullable
          : sortPosition as HabitSortPostion?,
    );
  }
}

extension $HabitDBCellCopyWith on HabitDBCell {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHabitDBCell.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitDBCellCWProxy get copyWith => _$HabitDBCellCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitDBCell _$HabitDBCellFromJson(Map<String, dynamic> json) => HabitDBCell(
  id: (json['id_'] as num?)?.toInt(),
  type: (json['type_'] as num?)?.toInt(),
  createT: (json['create_t'] as num?)?.toInt(),
  modifyT: (json['modify_t'] as num?)?.toInt(),
  uuid: json['uuid'] as String?,
  status: (json['status'] as num?)?.toInt(),
  name: json['name'] as String?,
  desc: json['desc'] as String?,
  color: (json['color'] as num?)?.toInt(),
  dailyGoal: json['daily_goal'] as num?,
  dailyGoalUnit: json['daily_goal_unit'] as String?,
  dailyGoalExtra: json['daily_goal_extra'] as num?,
  freqType: (json['freq_type'] as num?)?.toInt(),
  freqCustom: json['freq_custom'] as String?,
  startDate: (json['start_date'] as num?)?.toInt(),
  targetDays: (json['target_days'] as num?)?.toInt(),
  remindCustom: json['remind_cutsom'] as String?,
  remindQuestion: json['remind_question'] as String?,
  sortPosition: json['sort_position'] as num?,
);

Map<String, dynamic> _$HabitDBCellToJson(HabitDBCell instance) =>
    <String, dynamic>{
      'id_': ?instance.id,
      'type_': ?instance.type,
      'create_t': ?instance.createT,
      'modify_t': ?instance.modifyT,
      'uuid': ?instance.uuid,
      'status': ?instance.status,
      'name': ?instance.name,
      'desc': ?instance.desc,
      'color': ?instance.color,
      'daily_goal': ?instance.dailyGoal,
      'daily_goal_unit': ?instance.dailyGoalUnit,
      'daily_goal_extra': ?instance.dailyGoalExtra,
      'freq_type': ?instance.freqType,
      'freq_custom': ?instance.freqCustom,
      'start_date': ?instance.startDate,
      'target_days': ?instance.targetDays,
      'remind_cutsom': ?instance.remindCustom,
      'remind_question': ?instance.remindQuestion,
      'sort_position': ?instance.sortPosition,
    };
