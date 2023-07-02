// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_export.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordExportDataCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RecordExportData(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordExportData call({
    int? recordDate,
    int? recordType,
    num? recordValue,
    int? createT,
    int? modifyT,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecordExportData.copyWith(...)`.
class _$RecordExportDataCWProxyImpl implements _$RecordExportDataCWProxy {
  const _$RecordExportDataCWProxyImpl(this._value);

  final RecordExportData _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// RecordExportData(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordExportData call({
    Object? recordDate = const $CopyWithPlaceholder(),
    Object? recordType = const $CopyWithPlaceholder(),
    Object? recordValue = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
  }) {
    return RecordExportData(
      recordDate: recordDate == const $CopyWithPlaceholder()
          ? _value.recordDate
          // ignore: cast_nullable_to_non_nullable
          : recordDate as int?,
      recordType: recordType == const $CopyWithPlaceholder()
          ? _value.recordType
          // ignore: cast_nullable_to_non_nullable
          : recordType as int?,
      recordValue: recordValue == const $CopyWithPlaceholder()
          ? _value.recordValue
          // ignore: cast_nullable_to_non_nullable
          : recordValue as num?,
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
    );
  }
}

extension $RecordExportDataCopyWith on RecordExportData {
  /// Returns a callable class that can be used as follows: `instanceOfRecordExportData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$RecordExportDataCWProxy get copyWith => _$RecordExportDataCWProxyImpl(this);
}

abstract class _$HabitExportDataCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitExportData(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitExportData call({
    int? createT,
    int? modifyT,
    int? status,
    String? name,
    String? desc,
    int? color,
    num? dailyGoal,
    String? dailyGoalUnit,
    num? dailyGoalExtra,
    int? freqType,
    String? freqCustom,
    String? reminder,
    String? reminderQuest,
    int? startDate,
    int? targetDays,
    List<RecordExportData>? records,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHabitExportData.copyWith(...)`.
class _$HabitExportDataCWProxyImpl implements _$HabitExportDataCWProxy {
  const _$HabitExportDataCWProxyImpl(this._value);

  final HabitExportData _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// HabitExportData(...).copyWith(id: 12, name: "My name")
  /// ````
  HabitExportData call({
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? dailyGoal = const $CopyWithPlaceholder(),
    Object? dailyGoalUnit = const $CopyWithPlaceholder(),
    Object? dailyGoalExtra = const $CopyWithPlaceholder(),
    Object? freqType = const $CopyWithPlaceholder(),
    Object? freqCustom = const $CopyWithPlaceholder(),
    Object? reminder = const $CopyWithPlaceholder(),
    Object? reminderQuest = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? targetDays = const $CopyWithPlaceholder(),
    Object? records = const $CopyWithPlaceholder(),
  }) {
    return HabitExportData(
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
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
      reminder: reminder == const $CopyWithPlaceholder()
          ? _value.reminder
          // ignore: cast_nullable_to_non_nullable
          : reminder as String?,
      reminderQuest: reminderQuest == const $CopyWithPlaceholder()
          ? _value.reminderQuest
          // ignore: cast_nullable_to_non_nullable
          : reminderQuest as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as int?,
      targetDays: targetDays == const $CopyWithPlaceholder()
          ? _value.targetDays
          // ignore: cast_nullable_to_non_nullable
          : targetDays as int?,
      records: records == const $CopyWithPlaceholder() || records == null
          ? _value.records
          // ignore: cast_nullable_to_non_nullable
          : records as List<RecordExportData>,
    );
  }
}

extension $HabitExportDataCopyWith on HabitExportData {
  /// Returns a callable class that can be used as follows: `instanceOfHabitExportData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$HabitExportDataCWProxy get copyWith => _$HabitExportDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordExportData _$RecordExportDataFromJson(Map<String, dynamic> json) =>
    RecordExportData(
      recordDate: json['record_date'] as int?,
      recordType: json['record_type'] as int?,
      recordValue: json['record_value'] as num?,
      createT: json['create_t'] as int?,
      modifyT: json['modify_t'] as int?,
    );

Map<String, dynamic> _$RecordExportDataToJson(RecordExportData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('record_date', instance.recordDate);
  writeNotNull('record_type', instance.recordType);
  writeNotNull('record_value', instance.recordValue);
  writeNotNull('create_t', instance.createT);
  writeNotNull('modify_t', instance.modifyT);
  return val;
}

HabitExportData _$HabitExportDataFromJson(Map<String, dynamic> json) =>
    HabitExportData(
      createT: json['create_t'] as int?,
      modifyT: json['modify_t'] as int?,
      status: json['status'] as int?,
      name: json['name'] as String?,
      desc: json['desc'] as String?,
      color: json['color'] as int?,
      dailyGoal: json['daily_goal'] as num?,
      dailyGoalUnit: json['daily_goal_unit'] as String?,
      dailyGoalExtra: json['daily_goal_extra'] as num?,
      freqType: json['freq_type'] as int?,
      freqCustom: json['freq_custom'] as String?,
      reminder: json['reminder'] as String?,
      reminderQuest: json['reminder_quest'] as String?,
      startDate: json['start_date'] as int?,
      targetDays: json['target_days'] as int?,
      records: (json['records'] as List<dynamic>?)
              ?.map(RecordExportData.fromJson)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HabitExportDataToJson(HabitExportData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('create_t', instance.createT);
  writeNotNull('modify_t', instance.modifyT);
  writeNotNull('status', instance.status);
  writeNotNull('name', instance.name);
  writeNotNull('desc', instance.desc);
  writeNotNull('color', instance.color);
  writeNotNull('daily_goal', instance.dailyGoal);
  writeNotNull('daily_goal_unit', instance.dailyGoalUnit);
  writeNotNull('daily_goal_extra', instance.dailyGoalExtra);
  writeNotNull('freq_type', instance.freqType);
  writeNotNull('freq_custom', instance.freqCustom);
  writeNotNull('reminder', instance.reminder);
  writeNotNull('reminder_quest', instance.reminderQuest);
  writeNotNull('start_date', instance.startDate);
  writeNotNull('target_days', instance.targetDays);
  val['records'] = HabitExportData._recordsToJson(instance.records);
  return val;
}
