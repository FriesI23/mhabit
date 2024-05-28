// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HabitDBCellCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitDBCell call({
    int? id,
    int? type,
    int? createT,
    int? modifyT,
    String? uuid,
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
    num? sortPosition,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitDBCell.copyWith(...)`.
class _$HabitDBCellCWProxyImpl implements _$HabitDBCellCWProxy {
  const _$HabitDBCellCWProxyImpl(this._value);

  final HabitDBCell _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitDBCell(...).copyWith(id: 12, name: "My name")
  /// ````
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
          : id as int?,
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
          : uuid as String?,
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
          : sortPosition as num?,
    );
  }
}

extension $HabitDBCellCopyWith on HabitDBCell {
  /// Returns a callable class that can be used as follows: `instanceOfHabitDBCell.copyWith(...)`.
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

Map<String, dynamic> _$HabitDBCellToJson(HabitDBCell instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id_', instance.id);
  writeNotNull('type_', instance.type);
  writeNotNull('create_t', instance.createT);
  writeNotNull('modify_t', instance.modifyT);
  writeNotNull('uuid', instance.uuid);
  writeNotNull('status', instance.status);
  writeNotNull('name', instance.name);
  writeNotNull('desc', instance.desc);
  writeNotNull('color', instance.color);
  writeNotNull('daily_goal', instance.dailyGoal);
  writeNotNull('daily_goal_unit', instance.dailyGoalUnit);
  writeNotNull('daily_goal_extra', instance.dailyGoalExtra);
  writeNotNull('freq_type', instance.freqType);
  writeNotNull('freq_custom', instance.freqCustom);
  writeNotNull('start_date', instance.startDate);
  writeNotNull('target_days', instance.targetDays);
  writeNotNull('remind_cutsom', instance.remindCustom);
  writeNotNull('remind_question', instance.remindQuestion);
  writeNotNull('sort_position', instance.sortPosition);
  return val;
}
